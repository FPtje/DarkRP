FAdmin.Commands = {}
FAdmin.Commands.List = {}

function FAdmin.Commands.AddCommand(name, callback, ...)
    FAdmin.Commands.List[string.lower(name)] = {callback = callback, ExtraArgs = {...}}
end
