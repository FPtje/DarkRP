-- Create a table for the preferred playermodels
sql.Query([[CREATE TABLE IF NOT EXISTS darkp_playermodels(
    jobcmd VARCHAR(45) NOT NULL PRIMARY KEY,
    model VARCHAR(140) NOT NULL
);]])

sql.Query("ALTER TABLE darkp_playermodels ADD COLUMN IF NOT EXISTS server VARCHAR(21);")

local preferredModels = {}


--[[---------------------------------------------------------------------------
Interface functions
---------------------------------------------------------------------------]]
function DarkRP.setPreferredJobModel(teamNr, model)
    local job = RPExtraTeams[teamNr]
    if not job then return end
    preferredModels[job.command] = model
    sql.Query(string.format([[REPLACE INTO darkp_playermodels VALUES(%s, %s, %s);]], sql.SQLStr(job.command), sql.SQLStr(model), sql.SQLStr(game.GetIPAddress())))

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

--[[---------------------------------------------------------------------------
Load the preferred models
---------------------------------------------------------------------------]]
local function sendModels()
    net.Start("DarkRP_preferredjobmodels")
        for _, job in pairs(RPExtraTeams) do
            if not preferredModels[job.command] then net.WriteBit(false) continue end

            net.WriteBit(true)
            net.WriteString(preferredModels[job.command])
        end
    net.SendToServer()
end

local function jobHasModel(job, model)
    return istable(job.model) and table.HasValue(job.model, model) or job.model == model
end

timer.Simple(0, function()
    -- run after the jobs have loaded
    local models = sql.Query(string.format([[SELECT jobcmd, model FROM darkp_playermodels WHERE server IS NULL OR server = %s;]], sql.SQLStr(game.GetIPAddress())))

    for _, v in ipairs(models or {}) do
        local job = DarkRP.getJobByCommand(v.jobcmd)
        if job == nil or not jobHasModel(job, v.model) then continue end

        preferredModels[v.jobcmd] = v.model
    end

    sendModels()
end)
