if CPPI then return end
CPPI = {}
CPPI.CPPI_DEFER = 100100 --\100\100 = dd
CPPI.CPPI_NOTIMPLEMENTED = 7080

function CPPI:GetName()
    return "DarkRP"
end

function CPPI:GetVersion()
    return CPPI.CPPI_NOTIMPLEMENTED
end

function CPPI:GetInterfaceVersion()
    return CPPI.CPPI_NOTIMPLEMENTED
end

function CPPI:GetNameFromUID(uid)
    return CPPI.CPPI_NOTIMPLEMENTED
end

local PLAYER = FindMetaTable("Player")
function PLAYER:CPPIGetFriends()
    return CPPI.CPPI_NOTIMPLEMENTED
end

local ENTITY = FindMetaTable("Entity")
function ENTITY:CPPIGetOwner()
    return NULL, CPPI.CPPI_NOTIMPLEMENTED
end

if SERVER then
    function ENTITY:CPPISetOwner(ply)
        return CPPI.CPPI_NOTIMPLEMENTED
    end

    function ENTITY:CPPISetOwnerUID(UID)
        return CPPI.CPPI_NOTIMPLEMENTED
    end

    function ENTITY:CPPICanTool(ply, tool)
        return CPPI.CPPI_NOTIMPLEMENTED
    end

    function ENTITY:CPPICanPhysgun(ply)
        return CPPI.CPPI_NOTIMPLEMENTED
    end

    function ENTITY:CPPICanPickup(ply)
        return CPPI.CPPI_NOTIMPLEMENTED
    end

    function ENTITY:CPPICanPunt(ply)
        return CPPI.CPPI_NOTIMPLEMENTED
    end
end
