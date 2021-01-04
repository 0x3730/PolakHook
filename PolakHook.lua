
local ref = gui.Tab(gui.Reference("Ragebot"), "polakmenu", "PolakHook");

--Anti-Aims
local guiAntiaimBlock = gui.Groupbox(ref, "Custom AA", 16, 16, 250, 250);
local guiAntiaimSwitchKey = gui.Keybox(guiAntiaimBlock , "aaswitchkey", "Switch Key", 70);
local guiArrowsColor = gui.ColorPicker(guiAntiaimBlock, "arrowscolorpicker", "Arrows Color", 255, 0, 0, 255);
local guiAntiaimDeltaSlider = gui.Slider(guiAntiaimBlock, "aadelta", "Desync Delta", 150, 0, 180);
local guiAntiaimRealMaxDeltaJitter = gui.Slider(guiAntiaimBlock, "aajittermaxdelta", "Desync Max Real Delta (Jitter)", 58, 0, 58);
local guiAntiaimRealMinDeltaJitter = gui.Slider(guiAntiaimBlock, "aajittermindelta", "Desync Min Real Delta (Jitter)", 50, 0, 58);
local guiAntiaimAntialignFlicking = gui.Checkbox(guiAntiaimBlock, "antialignflick", "Anti-Align Flicking", 1);
local guiAntiaimDesyncTypeFlicking = gui.Checkbox(guiAntiaimBlock, "desyncmodeflick", "Desync Type Flicking", 0);
local guiAntiaimMode = gui.Checkbox(guiAntiaimBlock, "aamode", "Rage mode", 0);
local guiAntiaimType = gui.Combobox(guiAntiaimBlock, "aatype", "Desync type", "Static (Non-recomend)", "Jitter", "Sway");

--Misc Func
local guiMiscBlock = gui.Groupbox(ref, "Misc", 280, 16, 250, 250);
local guiVoteRevealer = gui.Checkbox(guiMiscBlock, "voterevealerkey", "Vote Revealer", 1);
local guiShowKeyBinds = gui.Checkbox(guiMiscBlock, "keybindskey", "Show Keybinds", 1);
local guiBaimKey = gui.Checkbox(guiMiscBlock, "forcebaimkey", "Force BAim", 0);
local guiMindmgKey = gui.Checkbox(guiMiscBlock, "mindmgbaimkey", "Force Min Damage", 0);
local guiMinDmgSlider = gui.Slider(guiMiscBlock, "mindmgslider", "Min Damage", 0, 0, 130);

--Some Vars
local screenCenterX, screenCenterY = draw.GetScreenSize();
screenCenterX = screenCenterX * 0.5;
screenCenterY = screenCenterY * 0.5;


local aaInverted = 1;

--User Cfg
local aMinDmg = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };	
local aBAim = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
local wTypes = { 'shared', 'zeus', 'pistol', 'hpistol', 'smg', 'rifle', 'shotgun', 'scout', 'asniper', 'sniper', 'lmg' }

--Vote vars
local voteType = -1;
local voteResult = -1;
local tTimer = 0;
local voteTarget = "";
local voteName = { "", "", "", "", "", "", "", ""};
local voteVal = { "", "", "", "", "", "", "", ""};
local vIndex = 1;
--

local function getVoteEnd(um)
	if um:GetID() == 46 then
		voteType = um:GetInt(3);
		voteTarget = um:GetString(5);
		if (string.len(voteTarget) > 20) then
			voteTarget = string.sub(voteTarget, 0, 15) .. "..."
		end
		
	elseif um:GetID() == 47 then
		tTimer = math.floor(globals.RealTime());
		voteResult = 1
	elseif um:GetID() == 48 then
		tTimer = math.floor(globals.RealTime());
		voteResult = 2
	end
end

local function voteCast(e)
    if (e:GetName() == "vote_cast") then
		local index = e:GetInt("entityid");
		local vote = e:GetInt("vote_option");
        local name = client.GetPlayerNameByIndex(index)
        if (string.len(name) > 20) then
            name = string.sub(name, 0, 15) .. "..."
        end
		
		voteName[vIndex] = name;
		
		if vote == 0 then
			voteVal[vIndex] = "YES";
		elseif vote == 1 then
			voteVal[vIndex] = "NO";
		else
			voteVal[vIndex] = "N/A";
		end
		vIndex = vIndex + 1;
		
		if vIndex + 1 > 9 then
			vIndex = 1;
		end
    end
end

local function DrawFooterVote()
	
	if string.len(voteVal[1]) < 1 or string.len(voteName[1]) < 1 or voteType == -1 then
		return;
	end
	
	if entities.GetLocalPlayer() == nil then
		voteResult = -1;
		voteType = -1;
		vIndex = 1;
		for i=1, #voteVal do
			voteVal[i] = "";
			voteName[i] = "";
		end
	end
	
	if guiVoteRevealer:GetValue() == 0 then
		return;
	end
	
	local VotescreenCenterX, VotescreenCenterY = draw.GetScreenSize();
	VotescreenCenterY = VotescreenCenterY * 0.62;
	
	local voteFooterText = "";
	
	if voteType == 0 then
		voteFooterText = "Vote - Kick player: "..voteTarget;
	elseif voteType == 6 then
		voteFooterText = "Vote - Surrender";
	elseif voteType == 13 then
		voteFooterText = "Vote - Timeout";
	else
		voteFooterText = "Vote - Some shit :)";
	end
	
	draw.Color(255, 255, 255, 255);
	draw.TextShadow(35, VotescreenCenterY, voteFooterText);
	draw.FilledRect(35, VotescreenCenterY + 14, draw.GetTextSize(voteFooterText) + 35, VotescreenCenterY + 16);
	
	for i=1, #voteVal do
	
		if string.len(voteVal[i]) < 1 and string.len(voteName[i]) < 1 then
			break;
		end
		
		VotescreenCenterY = VotescreenCenterY + 25;
		draw.Color(255, 255, 255, 255);
		draw.TextShadow(35, VotescreenCenterY, "["..voteVal[i].."] "..voteName[i]);
		
		if voteVal[i] == "YES" then
			draw.Color(78, 217, 28, 255);
		elseif voteVal[i] == "NO" then
			draw.Color(217, 28, 28, 255);
		else
			draw.Color(191, 191, 191, 255);
		end
		
		draw.FilledRect(35, VotescreenCenterY + 14, draw.GetTextSize("["..voteVal[i].."] "..voteName[i]) + 35, VotescreenCenterY + 16);
	end 
	
	if voteResult == 1 or voteResult == 2 then
		if voteResult == 1 then
			draw.Color(78, 217, 28, 255);
			draw.TextShadow(35, VotescreenCenterY + 25, "Vote Result - Succesfull");
		elseif voteResult == 2 then
			draw.Color(217, 28, 28, 255);
			draw.TextShadow(35, VotescreenCenterY + 25, "Vote Result - Failed");
		end
		
		if math.floor(globals.RealTime()) > tTimer + 1.8 then
			voteResult = -1;
			voteType = -1;
			vIndex = 1;
			for i=1, #voteVal do
				voteVal[i] = "";
				voteName[i] = "";
			end
		end
	end
	
end

local function RandomRange(Min, Max)
	return Min + (math.random(Max * 2 + 1) % (Max - Min + 1));
end

local function RestoreDamage()
	for i=1, #wTypes do
		gui.SetValue("rbot.accuracy.weapon."..wTypes[i]..".mindmg", aMinDmg[i]);
	end
end

local function SetDamage(iMinDmg)
	for i=1, #wTypes do
		gui.SetValue("rbot.accuracy.weapon."..wTypes[i]..".mindmg", iMinDmg);
	end
end

local function SetBaim()
	for i=1, #wTypes do
		gui.SetValue("rbot.hitscan.mode."..wTypes[i]..".bodyaim.force", 1);
	end
end

local function RestoreBaim()
	for i=1, #wTypes do
		gui.SetValue("rbot.hitscan.mode."..wTypes[i]..".bodyaim.force", aBAim[i]);
	end
end

local function StaticSync(bSide)
	if bSide == 1 then
		gui.SetValue("rbot.antiaim.base.rotation", 58);
		gui.SetValue("rbot.antiaim.base.lby", guiAntiaimDeltaSlider:GetValue() * -1);
	else
		gui.SetValue("rbot.antiaim.base.rotation", -58);
		gui.SetValue("rbot.antiaim.base.lby", guiAntiaimDeltaSlider:GetValue());
	end
end

local function JitterSync(bSide)
	if bSide == 1 then
		gui.SetValue("rbot.antiaim.base.rotation", RandomRange(guiAntiaimRealMinDeltaJitter:GetValue(), guiAntiaimRealMaxDeltaJitter:GetValue()));
		gui.SetValue("rbot.antiaim.base.lby", math.random(guiAntiaimDeltaSlider:GetValue() * -1));
	else
		gui.SetValue("rbot.antiaim.base.rotation", RandomRange(guiAntiaimRealMinDeltaJitter:GetValue() * -1, guiAntiaimRealMaxDeltaJitter:GetValue() * -1));
		gui.SetValue("rbot.antiaim.base.lby", math.random(guiAntiaimDeltaSlider:GetValue()));
	end
end

local iSwayIndex = 18;
local function SwaySync(bSide)
	if bSide == 1 then
		gui.SetValue("rbot.antiaim.base.rotation", 58);
		gui.SetValue("rbot.antiaim.base.lby", iSwayIndex * -1);
	else
		gui.SetValue("rbot.antiaim.base.rotation", -58);
		gui.SetValue("rbot.antiaim.base.lby", iSwayIndex);
	end
	
	if iSwayIndex + 5 > guiAntiaimDeltaSlider:GetValue() + 1 then
	   iSwayIndex = 0;
	end
	
	iSwayIndex = iSwayIndex + 5;	
end

local function CustomDesync()
	local aaRMode = 0;
	local aaSide = 0;
	
	gui.SetValue("rbot.antiaim.left", 0);
    gui.SetValue("rbot.antiaim.right", 0);
	gui.SetValue("rbot.antiaim.advanced.autodir.edges", 0);
    gui.SetValue("rbot.antiaim.advanced.autodir.targets", 0);
	
	if guiAntiaimMode:GetValue() then
		gui.SetValue("rbot.antiaim.base", "180.0 Desync");
		gui.SetValue("rbot.antiaim.advanced.pitch", 1);
		aaRMode = 1;
	else
		gui.SetValue("rbot.antiaim.base", "0.0 Desync");
		gui.SetValue("rbot.antiaim.advanced.pitch", 0);
	end
	
	if guiAntiaimAntialignFlicking:GetValue() == true then
		if math.random(34) == 1 then
			gui.SetValue("rbot.antiaim.advanced.antialign", 1);
		else
			gui.SetValue("rbot.antiaim.advanced.antialign", 0);
		end
	end
	
	if guiAntiaimSwitchKey:GetValue() then
		if input.IsButtonPressed(guiAntiaimSwitchKey:GetValue()) then
			if aaInverted == 1 then
				aaInverted = 0;
			else
				aaInverted = 1;
			end
		end
	end
	
	if aaRMode == 1 then
		aaSide = 1 - aaInverted;
	else
		aaSide = aaInverted;
	end
	
	if guiAntiaimType:GetValue() == 0 then
		StaticSync(aaSide);
	elseif guiAntiaimType:GetValue() == 1 then
		JitterSync(aaSide);
	else
		SwaySync(aaSide);
	end
end

local function MiscFunctions()
	if guiMindmgKey:GetValue() then
		SetDamage(guiMinDmgSlider:GetValue());
	else
		RestoreDamage();
	end
	
	if guiBaimKey:GetValue() then
		SetBaim();
	else
		RestoreBaim();
	end
end

local function DrawInfo()
	local YAdd = 50;
	
	--Draw AA Arows
	draw.Color(46, 46, 46, 200);
	draw.Triangle(screenCenterX + 50, screenCenterY - 7, screenCenterX + 65, screenCenterY - 7 + 8, screenCenterX + 50, screenCenterY - 7 + 15);
	draw.Triangle(screenCenterX - 50, screenCenterY - 7, screenCenterX - 65, screenCenterY - 7 + 8, screenCenterX - 50, screenCenterY - 7 + 15);
	local r, g, b, a = guiArrowsColor:GetValue();
	draw.Color(r, g, b, a);
	
	if aaInverted == 1 then
		draw.Line(screenCenterX + 50, screenCenterY - 7, screenCenterX + 65, screenCenterY - 7 + 8);
		draw.Line(screenCenterX + 50, screenCenterY - 7 + 15, screenCenterX + 65, screenCenterY - 7 + 8);
	else
		draw.Line(screenCenterX - 50, screenCenterY - 7, screenCenterX - 65, screenCenterY - 7 + 8);
		draw.Line(screenCenterX - 50, screenCenterY - 7 + 15, screenCenterX - 65, screenCenterY - 7 + 8);
	end	
	--
	
	if not guiShowKeyBinds:GetValue() then
		return;
	end
	
	if guiAntiaimMode:GetValue() then
		local sInfo = "Rage desync active!";
		draw.Color(255, 0, 0, 255);
		draw.TextShadow(screenCenterX - draw.GetTextSize(sInfo) / 2, screenCenterY + YAdd, sInfo);
		YAdd = YAdd + 15;
	end
	
	draw.Color(68, 255, 0, 255);
	
	if gui.GetValue("rbot.antiaim.condition.shiftonshot") then
		local sInfo = "Hide Shots";
		draw.TextShadow(screenCenterX - draw.GetTextSize(sInfo) / 2, screenCenterY + YAdd, sInfo);
		YAdd = YAdd + 15;
	end
	
	if guiMindmgKey:GetValue() then
		local sInfo = "Min Damage: "..guiMinDmgSlider:GetValue();
		draw.TextShadow(screenCenterX - draw.GetTextSize(sInfo) / 2, screenCenterY + YAdd, sInfo);
		YAdd = YAdd + 15;
	end
	
	if guiBaimKey:GetValue() then
		local sInfo = "Force Baim";
		draw.TextShadow(screenCenterX - draw.GetTextSize(sInfo) / 2, screenCenterY + YAdd, sInfo);
		YAdd = YAdd + 15;
	end
	
end

local function BackupCfg()
	for i=1, #wTypes do
		aMinDmg[i] = gui.GetValue("rbot.accuracy.weapon."..wTypes[i]..".mindmg");
		aBAim[i] = gui.GetValue("rbot.hitscan.mode."..wTypes[i]..".bodyaim.force");
	end
end

BackupCfg(); --Store user cfg
callbacks.Register("Draw", CustomDesync);
callbacks.Register("Draw", MiscFunctions);
callbacks.Register("Draw", DrawInfo);
--Vote rev
callbacks.Register("Draw", DrawFooterVote);
callbacks.Register('FireGameEvent', voteCast)
callbacks.Register("DispatchUserMessage", getVoteEnd)
