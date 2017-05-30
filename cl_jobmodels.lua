sql.Query([[CREATE TABLE IF NOT EXISTS darkp_playermodels(
    jobcmd VARCHAR(45) NOT NULL PRIMARY KEY,
    model VARCHAR(140) NOT NULL
);]])
local preferredModels = {}

function DarkRP.setPreferredJobModel(teamNr, model)
    local job = RPExtraTeams[teamNr]
    if not job then return end
    preferredModels[job.command] = model
    sql.Query(string.format([[REPLACE INTO darkp_playermodels VALUES(%s, %s);]], sql.SQLStr(job.command), sql.SQLStr(model)))
    net.Start("DarkRP_preferredjobmodel")
    net.WriteUInt(teamNr, 8)
    net.WriteString(model)
    net.SendToServer()
end

function DarkRP.getPreferredJobModel(teamNr)
    local job = RPExtraTeams[teamNr]
    if not job then return end

    return preferredModels[job.command]
end

local function sendModels()
    net.Start("DarkRP_preferredjobmodels")

    for _, job in ipairs(RPExtraTeams) do
        if not preferredModels[job.command] then
            net.WriteBit(false)
            continue
        end

        net.WriteBit(true)
        net.WriteString(preferredModels[job.command])
    end

    net.SendToServer()
end

do
    local models = sql.Query([[SELECT jobcmd, model FROM darkp_playermodels;]])

    for k, v in pairs(models or {}) do
        preferredModels[v.jobcmd] = v.model
    end

    timer.Simple(0, sendModels)
end
