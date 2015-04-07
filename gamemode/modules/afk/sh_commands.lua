fprp.registerfprpVar("AFK", net.WriteBit, fn.Compose{tobool, net.ReadBit});
fprp.registerfprpVar("AFKDemoted", net.WriteBit, fn.Compose{tobool, net.ReadBit});

fprp.declareChatCommand{
	command = "afk",
	description = "Go AFK",
	delay = 1.5
}
