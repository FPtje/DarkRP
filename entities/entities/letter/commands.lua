local function MakeLetter(ply, args, type)
	if not GAMEMODE.Config.letters then
		fprp.notify(ply, 1, 4, fprp.getPhrase("disabled", "/write / /type", ""));
		return ""
	end

	if ply.maxletters and ply.maxletters >= GAMEMODE.Config.maxletters then
		fprp.notify(ply, 1, 4, fprp.getPhrase("limit", "letter"));
		return ""
	end

	if CurTime() - ply:GetTable().LastLetterMade < 3 then
		fprp.notify(ply, 1, 4, fprp.getPhrase("have_to_wait", math.ceil(3 - (CurTime() - ply:GetTable().LastLetterMade)), "/write / /type"));
		return ""
	end

	ply:GetTable().LastLetterMade = CurTime();

	-- Instruct the player's letter window to open

	local ftext = string.gsub(args, "//", "\n");
	ftext = string.gsub(ftext, "\\n", "\n") .. "\n\n" .. fprp.getPhrase("signed_yours") .. "\n"..ply:Nick();
	local length = string.len(ftext);

	local numParts = math.floor(length / 39) + 1

	local tr = {}
	tr.start = ply:EyePos();
	tr.endpos = ply:EyePos() + 95 * ply:GetAimVector();
	tr.filter = ply
	local trace = util.TraceLine(tr);

	local letter = ents.Create("letter");
	letter:SetModel("models/props_c17/paper01.mdl");
	letter:Setowning_ent(ply);
	letter.ShareGravgun = true
	letter:SetPos(trace.HitPos);
	letter.nodupe = true
	letter:Spawn();

	letter:GetTable().Letter = true
	letter.type = type
	letter.numPts = numParts

	local startpos = 1
	local endpos = 39
	letter.Parts = {}
	for k=1, numParts do
		table.insert(letter.Parts, string.sub(ftext, startpos, endpos));
		startpos = startpos + 39
		endpos = endpos + 39
	end
	letter.SID = ply.SID

	fprp.printMessageAll(2, fprp.getPhrase("created_x", ply:Nick(), "mail"));
	if not ply.maxletters then
		ply.maxletters = 0
	end
	ply.maxletters = ply.maxletters + 1
	timer.Simple(600, function() if IsValid(letter) then letter:Remove() end end)
end

local function WriteLetter(ply, args)
	if args == "" then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
		return ""
	end
	MakeLetter(ply, args, 1);
	return ""
end
fprp.defineChatCommand("write", WriteLetter);

local function TypeLetter(ply, args)
	if args == "" then
		fprp.notify(ply, 1, 4, fprp.getPhrase("invalid_x", "argument", ""));
		return ""
	end
	MakeLetter(ply, args, 2);
	return ""
end
fprp.defineChatCommand("type", TypeLetter);

local function RemoveLetters(ply)
	for k, v in pairs(ents.FindByClass("letter")) do
		if v.SID == ply.SID then v:Remove() end
	end
	fprp.notify(ply, 4, 4, fprp.getPhrase("cleaned_up", "mails"));
	return ""
end
fprp.defineChatCommand("removeletters", RemoveLetters);
