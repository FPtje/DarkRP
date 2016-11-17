if not CAMI then return end

CAMI.RegisterPrivilege{
    Name = "FSpectate",
    MinAccess = "admin"
}

CAMI.RegisterPrivilege{
    Name = "FSpectateTeleport",
    MinAccess = "admin"
}
