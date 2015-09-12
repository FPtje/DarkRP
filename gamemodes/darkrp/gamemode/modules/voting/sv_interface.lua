DarkRP.createQuestion = DarkRP.stub{
    name = "createQuestion",
    description = "Ask someone a question.",
    parameters = {
        {
            name = "question",
            description = "The question to ask.",
            type = "string",
            optional = false
        },
        {
            name = "quesid",
            description = "A unique question id.",
            type = "string",
            optional = false
        },
        {
            name = "target",
            description = "Who to ask the question.",
            type = "Player",
            optional = false
        },
        {
            name = "delay",
            description = "For how long the player will be able to answer.",
            type = "number",
            optional = false
        },
        {
            name = "callback",
            description = "The function that gets called after the question.",
            type = "function",
            optional = false
        },
        {
            name = "fromPly",
            description = "The player who asked the question.",
            type = "Player",
            optional = true
        },
        {
            name = "toPly",
            description = "A third involved player.",
            type = "Player",
            optional = true
        },
        {
            name = "...",
            description = "Any other information.",
            type = "any",
            optional = true
        }
    },
    returns = {
    },
    metatable = DarkRP
}

DarkRP.destroyQuestion = DarkRP.stub{
    name = "destroyQuestion",
    description = "Destroy a question by ID.",
    parameters = {
        {
            name = "id",
            description = "The id of the question.",
            type = "string",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP
}

DarkRP.destroyQuestionsWithEnt = DarkRP.stub{
    name = "destroyQuestionsWithEnt",
    description = "Destroy all questions that have something to do with this ent.",
    parameters = {
        {
            name = "ent",
            description = "The Entity.",
            type = "Entity",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP
}

DarkRP.createVote = DarkRP.stub{
    name = "createVote",
    description = "Create a vote.",
    parameters = {
        {
            name = "question",
            description = "The question to ask in the vote.",
            type = "string",
            optional = false
        },
        {
            name = "voteid",
            description = "A unique vote id.",
            type = "string",
            optional = false
        },
        {
            name = "target",
            description = "Whom the vote is about.",
            type = "Player",
            optional = false
        },
        {
            name = "delay",
            description = "For how long the player will be able to answer.",
            type = "number",
            optional = false
        },
        {
            name = "callback",
            description = "The function that gets called after the vote.",
            type = "function",
            optional = false
        },
        {
            name = "excludeVoters",
            description = "The players to exclude from voting.",
            type = "table",
            optional = true
        },
        {
            name = "fail",
            description = "A callback for when the vote fails.",
            type = "function",
            optional = true
        },
        {
            name = "...",
            description = "Any other information.\n\nIf the vote involves multiple parties (i.e. the target of the vote and person who started it are different) you should provide a table with the \"source\" field set to the player who intiated the vote. This ensures the notifications about the vote are sent to the correct player.",
            type = "any",
            optional = true
        }
    },
    returns = {
        {
            name = "vote",
            description = "All the vote information. Returns nil if the vote did not start because the canStartVote hook blocked it.",
            type = "table"
        }
    },
    metatable = DarkRP
}

DarkRP.destroyVotesWithEnt = DarkRP.stub{
    name = "destroyVotesWithEnt",
    description = "Destroy all votes that have something to do with this ent.",
    parameters = {
        {
            name = "ent",
            description = "The Entity.",
            type = "Entity",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP
}

DarkRP.destroyLastVote = DarkRP.stub{
    name = "destroyLastVote",
    description = "Destroy the last created vote.",
    parameters = {
    },
    returns = {
        {
            name = "destroyed",
            description = "Whether there was a last vote to destroy or not.",
            type = "boolean"
        }
    },
    metatable = DarkRP
}

DarkRP.hookStub{
    name = "getVoteResults",
    description = "Override the results of a vote.",
    parameters = {
        {
            name = "vote",
            description = "A table that contains information about the vote.",
            type = "table"
        },
        {
            name = "yea",
            description = "The amount of people that voted yes.",
            type = "number"
        },
        {
            name = "nay",
            description = "The amount of people that voted no.",
            type = "number"
        }
    },
    returns = {
        {
            name = "result",
            description = "The result of the vote. Return 1 for win, -1 for lose, 0 for undecided.",
            type = "number"
        }
    }
}

DarkRP.hookStub{
    name = "canStartVote",
    description = "Whether the vote can be started or not.",
    parameters = {
        {
            name = "vote",
            description = "A table that contains information about the vote.",
            type = "table"
        }
    },
    returns = {
        {
            name = "canStartVote",
            description = "Whether the vote can be started or not.",
            type = "boolean"
        },
        {
            name = "callSuccess",
            description = "True if the callback for a successful vote should be called, false if the callback for a failed vote should be called. Only works when canStartVote is false.",
            type = "boolean"
        },
        {
            name = "message",
            description = "The message to show when the vote cannot be started. Only works when callSuccess is false.",
            type = "string"
        }
    }
}

DarkRP.hookStub{
    name = "onVoteStarted",
    description = "Called when a vote has been started.",
    parameters = {
        {
            name = "vote",
            description = "A table that contains information about the vote.",
            type = "table"
        }
    },
    returns = {
    }
}
