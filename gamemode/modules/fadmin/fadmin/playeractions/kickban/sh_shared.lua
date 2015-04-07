function FAdmin.PlayerActions.ConvertBanTime(time)
	local Add = ""
	time = math.Round(time);
	if time <= 0 then return "permanent"
	elseif time < 60 then -- minutes
		return math.ceil(time) ..  " minute(s)"
	elseif time >= 60 and time < 1440 then -- hours
		if math.floor((time/60 - math.floor(time/60))*60) > 0 then
			Add = ", "..FAdmin.PlayerActions.ConvertBanTime((time/60 - math.floor(time/60))*60);
		end
		return math.floor(time/60).. " hour(s)".. Add
	elseif time >= 1440 and time < 10080 then -- days
		if math.floor((time/1440 - math.floor(time/1440))*1440) > 0 then
			Add = ", "..FAdmin.PlayerActions.ConvertBanTime((time/1440 - math.floor(time/1440))*1440);
		end
		return math.floor(time/1440).. " day(s)".. Add
	elseif time >= 10080 and time < 525948 then -- weeks
		if math.floor((time/10080 - math.floor(time/10080))*10080) > 0 then
			Add = ", "..FAdmin.PlayerActions.ConvertBanTime((time/10080 - math.floor(time/10080))*10080);
		end
		return math.floor(time/10080).. " week(s)".. Add
	elseif time >= 525948 then -- years
		if math.floor((time/525948 - math.floor(time/525948))*525948) > 0 then
			Add = ", "..FAdmin.PlayerActions.ConvertBanTime((time/525948 - math.floor(time/525948))*525948);
		end
		return math.floor(time/525948).. " year(s)".. Add
	end
	return time
end