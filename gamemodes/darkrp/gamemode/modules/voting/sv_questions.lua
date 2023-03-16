local Question = {}
local Questions = {}

local function ccDoQuestion(ply, cmd, args)
    local q = Questions[args[1]]
    if not q then return end
    if not tonumber(args[2]) then return end
    if q.Ent and q.Ent ~= ply then return end

    q:handleNewQuestion(tonumber(args[2]))
end
concommand.Add("ans", ccDoQuestion)

local function handleQuestionEnd(id)
    if not Questions[id] then return end
    local q = Questions[id]
    q.Callback(q.yn, q.Ent, q.Initiator, q.Target, unpack(q.Args))
    Questions[id] = nil
end

function Question:handleNewQuestion(response)
    if response == 1 or response == 0 then
        self.yn = tobool(response)
    end

    handleQuestionEnd(self.ID)
end

function DarkRP.createQuestion(question, quesid, ent, delay, callback, fromPly, toPly, ...)
    local newques = {}
    for k, v in pairs(Question) do newques[k] = v end

    newques.ID = quesid
    newques.Callback = callback
    newques.Ent = ent
    newques.Initiator = fromPly
    newques.Target = toPly
    newques.Args = {...}

    newques.yn = 0

    Questions[quesid] = newques

    umsg.Start("DoQuestion", ent)
        umsg.String(question)
        umsg.String(quesid)
        umsg.Float(delay)
    umsg.End()

    timer.Create(quesid .. "timer", delay, 1, function() handleQuestionEnd(quesid) end)
end

function DarkRP.destroyQuestion(id)
    umsg.Start("KillQuestionVGUI", Questions[id].Ent)
        umsg.String(Questions[id].ID)
    umsg.End()

    Questions[id] = nil
end

function DarkRP.destroyQuestionsWithEnt(ent)
    for _, v in pairs(Questions) do
        if v.Ent == ent then
            DarkRP.destroyQuestion(v.ID)
        end
    end
end
