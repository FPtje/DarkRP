DarkRP.lockdown = DarkRP.stub{
    name = "lockdown",
    description = "Start a lockdown.",
    parameters = {
        {
            name = "ply",
            description = "The player who initiated the lockdown.",
            type = "Player",
            optional = false
        }
    },
    returns = {
        {
            name = "str",
            description = "Empty string (since it's a called in a chat command)",
            type = "string"
        }
    },
    metatable = DarkRP
}

DarkRP.unLockdown = DarkRP.stub{
    name = "unLockdown",
    description = "Stop the lockdown.",
    parameters = {
        {
            name = "ply",
            description = "The player who stopped the lockdown.",
            type = "Player",
            optional = false
        }
    },
    returns = {
        {
            name = "str",
            description = "Empty string (since it's a called in a chat command)",
            type = "string"
        }
    },
    metatable = DarkRP
}

DarkRP.PLAYER.requestWarrant = DarkRP.stub{
    name = "requestWarrant",
    description = "File a request for a search warrant.",
    parameters = {
        {
            name = "suspect",
            description = "The player who is suspected.",
            type = "Player",
            optional = false
        },
        {
            name = "actor",
            description = "The player who wants the warrant.",
            type = "Player",
            optional = false
        },
        {
            name = "reason",
            description = "The reason for the warrant.",
            type = "string",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.warrant = DarkRP.stub{
    name = "warrant",
    description = "Get a search warrant for this person.",
    parameters = {
        {
            name = "warranter",
            description = "The player who set the warrant.",
            type = "Player",
            optional = false
        },
        {
            name = "reason",
            description = "The reason for the warrant.",
            type = "string",
            optional = false
        }
    },
    returns = {
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.unWarrant = DarkRP.stub{
    name = "unWarrant",
    description = "Remove the search warrant for this person.",
    parameters = {
        {
            name = "unwarranter",
            description = "The player who removed the warrant.",
            type = "Player",
            optional = true
        }
    },
    returns = {
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.wanted = DarkRP.stub{
    name = "wanted",
    description = "Make this person wanted by the police.",
    parameters = {
        {
            name = "actor",
            description = "The player who made the other person wanted.",
            type = "Player",
            optional = false
        },
        {
            name = "reason",
            description = "The reason for the wanted status.",
            type = "string",
            optional = false
        },
        {
            name = "time",
            description = "The time in seconds for which the player should be wanted.",
            type = "number",
            optional = true
        }
    },
    returns = {
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.unWanted = DarkRP.stub{
    name = "unWanted",
    description = "Clear the wanted status for this person.",
    parameters = {
        {
            name = "actor",
            description = "The player who cleared the wanted status.",
            type = "Player",
            optional = true
        }
    },
    returns = {
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.arrest = DarkRP.stub{
    name = "arrest",
    description = "Arrest a player.",
    parameters = {
        {
            name = "time",
            description = "For how long the player is arrested.",
            type = "number",
            optional = true
        },
        {
            name = "Arrester",
            description = "The player who arrested the target.",
            type = "Player",
            optional = true
        }
    },
    returns = {
    },
    metatable = DarkRP.PLAYER
}

DarkRP.PLAYER.unArrest = DarkRP.stub{
    name = "unArrest",
    description = "Unarrest a player.",
    parameters = {
        {
            name = "Unarrester",
            description = "The player who unarrested the target.",
            type = "Player",
            optional = true
        }
    },
    returns = {
    },
    metatable = DarkRP.PLAYER
}

DarkRP.iterateArrestedPlayers = DarkRP.stub{
    name = "iterateArrestedPlayers",
    description = "An iterator that walks over the arrested players. Use as follows: for arrestedPlayer in DarkRP.iterateArrestedPlayers() do print(arrestedPlayer) end",
    parameters = {
    },
    returns = {
        {
            name = "arrestedPlayer",
            description = "Much like the next function, this returns the next arrested player until the table is fully iterated.",
            type = "Player"
        }
    },
    metatable = DarkRP,
    realm = "Server"
}

DarkRP.arrestedPlayers = DarkRP.stub{
    name = "arrestedPlayers",
    description = "Returns a table that contains all arrested players. NOTE: This function is defined using DarkRP.iterateArrestedPlayers. It might be more efficient to use that function instead, because this function builds the table anew.",
    parameters = {
    },
    returns = {
        {
            name = "arrestedPlayers",
            description = "An array of arrested players, in no particular order.",
            type = "table"
        }
    },
    metatable = DarkRP,
    realm = "Server"
}

DarkRP.arrestedPlayerCount = DarkRP.stub{
    name = "arrestedPlayerCount",
    description = "Returns the amount of players that are currently arrested.",
    parameters = {
    },
    returns = {
        {
            name = "arrestedPlayerCount",
            description = "The amount of arrested players.",
            type = "number"
        }
    },
    metatable = DarkRP,
    realm = "Server"
}

DarkRP.hookStub{
    name = "playerArrested",
    description = "When a player is arrested.",
    parameters = {
        {
            name = "criminal",
            description = "The arrested criminal.",
            type = "Player"
        },
        {
            name = "time",
            description = "The jail time.",
            type = "number"
        },
        {
            name = "actor",
            description = "The person who arrested the criminal.",
            type = "Player"
        }
    },
    returns = {
    }
}

DarkRP.hookStub{
    name = "playerUnArrested",
    description = "When a player is unarrested.",
    parameters = {
        {
            name = "criminal",
            description = "The unarrested criminal.",
            type = "Player"
        },
        {
            name = "actor",
            description = "The person who unarrested the criminal.",
            type = "Player"
        }
    },
    returns = {
    }
}

DarkRP.hookStub{
    name = "playerWarranted",
    description = "When a player is warranted.",
    parameters = {
        {
            name = "criminal",
            description = "The potential criminal.",
            type = "Player"
        },
        {
            name = "actor",
            description = "The person who wanted the potential criminal.",
            type = "Player"
        },
        {
            name = "reason",
            description = "The reason for wanting this person.",
            type = "string"
        }
    },
    returns = {
        {
            name = "suppressMsg",
            description = "Return true to make the warrant silent.",
            type = "boolean"
        }
    }
}

DarkRP.hookStub{
    name = "playerUnWarranted",
    description = "When a player is unwarranted.",
    parameters = {
        {
            name = "excriminal",
            description = "The potential criminal.",
            type = "Player"
        },
        {
            name = "actor",
            description = "The person who unwarranted the potential criminal",
            type = "Player"
        }
    },
    returns = {
        {
            name = "suppressMsg",
            description = "Return true to make the unwarrant silent.",
            type = "boolean"
        }
    }
}

DarkRP.hookStub{
    name = "playerWanted",
    description = "When a player is wanted.",
    parameters = {
        {
            name = "criminal",
            description = "The criminal.",
            type = "Player"
        },
        {
            name = "actor",
            description = "The person who wanted the criminal.",
            type = "Player"
        },
        {
            name = "reason",
            description = "The reason for wanting this person.",
            type = "string"
        }
    },
    returns = {
        {
            name = "suppressMsg",
            description = "Return true to make the wanted silent.",
            type = "boolean"
        }
    }
}

DarkRP.hookStub{
    name = "playerUnWanted",
    description = "When a player is unwanted.",
    parameters = {
        {
            name = "excriminal",
            description = "The ex criminal.",
            type = "Player"
        },
        {
            name = "actor",
            description = "The person who unwanted the ex criminal.",
            type = "Player"
        }
    },
    returns = {
        {
            name = "suppressMsg",
            description = "Return true to make the unwanted silent.",
            type = "boolean"
        }
    }
}

DarkRP.hookStub{
    name = "agendaUpdated",
    description = "When the agenda is updated.",
    parameters = {
        {
            name = "ply",
            description = "The player who changed the agenda. Warning: can be nil!",
            type = "Player"
        },
        {
            name = "agenda",
            description = "Agenda table (also holds the previous text).",
            type = "table"
        },
        {
            name = "text",
            description = "The text the player wants to set the agenda to.",
            type = "string"
        }
    },
    returns = {
        {
            name = "text",
            description = "An override for the text.",
            type = "string"
        }
    }
}

DarkRP.hookStub{
        name = "playerEnteredLottery",
        description = "When a player has entered the lottery.",
        parameters = {
                {
                        name = "ply",
                        description = "The player.",
                        type = "Player"
                }
        },
        returns = {
        }
}

DarkRP.hookStub{
        name = "lotteryEnded",
        description = "When a lottery has ended.",
        parameters = {
                {
                        name = "participants",
                        description = "The participants of the lottery. An empty table when no one entered the lottery.",
                        type = "table"
                },
                {
                        name = "chosen",
                        description = "The winner of the lottery.",
                        type = "Player"
                },
                {
                        name = "amount",
                        description = "The amount won by the winner.",
                        type = "number"
                }
        },
        returns = {
        }
}


DarkRP.hookStub{
        name = "lotteryStarted",
        description = "When a lottery has started.",
        parameters = {
                {
                        name = "ply",
                        description = "The player who started the lottery.",
                        type = "Player"
                },
                {
                        name = "price",
                        description = "The amount of money people have to pay to enter.",
                        type = "number"
                }
        },
        returns = {
        }
}


DarkRP.hookStub{
    name = "canGiveLicense",
    description = "Whether a player is allowed to give another player a license.",
    parameters = {
            {
                    name = "ply",
                    description = "The player who tries to give the license.",
                    type = "Player"
            },
            {
                    name = "target",
                    description = "The player who should receive the license.",
                    type = "Player"
            }
    },
    returns = {
        {
            name = "canGiveLicense",
            description = "Whether the player is allowed to give the target a license.",
            type = "boolean"
        },
        {
            name = "cantGiveReason",
            description = "Why the target is not allowed to receive a license from the player.",
            type = "string"
        },
    }
}
