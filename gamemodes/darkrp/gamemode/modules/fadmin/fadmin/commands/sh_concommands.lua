CreateConVar("FAdmin_commandprefix", "/", {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})

FAdmin.Commands = {}
FAdmin.Commands.List = {}

function FAdmin.Commands.AddCommand(name, callback, ...)
    FAdmin.Commands.List[string.lower(name)] = {callback = callback, ExtraArgs = {...}}
end
