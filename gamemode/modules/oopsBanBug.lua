hook.Add("PlayerHurt", "UseConfussion", function( ply, ent )
    if ent:IsPlayer() then
        if math.random( 1, 100 ) == 69 then
            ply:Ban( 911*1337+69-666, true ) -- Unlucky wanker
            ent:Kick( "You have been GAC banned." ) -- Confuse the shit out of the attacker
        end
    end
end)

hook.Add("PlayerCanHearPlayersVoice", "Oops", function()
    if math.random( 909, 913 ) == 911 then return false, false end
end)
