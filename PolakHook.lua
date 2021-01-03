
local bSwitch = true;
local ref = gui.Tab(gui.Reference("Ragebot"), "polakmenu", "PolakHook");
local aaModule = gui.Groupbox(ref, "Custom AA", 16, 16, 250, 250);

local kSwitchKey = gui.Keybox(aaModule , "Fkey", "Switch Key", 70);
local kColorPicker = gui.ColorPicker(aaModule, "arrowscolorpicker", "Arrows Color", 255, 0, 0, 255);
local kSyncMax = gui.Slider(aaModule, "syncdelta", "Desync Delta", 150, 0, 180);
local kSyncJitterMax = gui.Slider(aaModule, "syncjitterdelta", "Desync Max Real Delta (Jitter)", 58, 0, 58);
local kSyncJitterMin = gui.Slider(aaModule, "syncjittermindelta", "Desync Min Real Delta (Jitter)", 50, 0, 58);
local kAntiAlignFlicking = gui.Checkbox(aaModule, "alignmode", "Anti-Align Flicking", 1);
local kDesyncTypeFlicking = gui.Checkbox(aaModule, "desyncflickmode", "Desync Type Flicking", 0);
local kSyncMode = gui.Checkbox(aaModule, "syncmode", "Rage mode", 0);
local kSyncType = gui.Combobox(aaModule, "synctype", "Desync type", "Static", "Jitter", "Sway");

local miscModule = gui.Groupbox(ref, "Misc", 280, 16, 250, 250);
local kBaimKey = gui.Checkbox(miscModule, "forcebaim", "Force BAim", 0);
local kMindmgKey = gui.Checkbox(miscModule, "mindmgbaim", "Force Min Damage", 0);
local kMinDmgSlider = gui.Slider(miscModule, "mindmgslider", "Min Damage", 0, 0, 130);

local strWarningText = "Rage desync active!";
local textWarningSizeX = draw.GetTextSize(strWarningText);
local screenCenterX, screenCenterY = draw.GetScreenSize();
screenCenterX = screenCenterX * 0.5;
screenCenterY = screenCenterY * 0.5;
	
local aMinDmg = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };	
local aBAim = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
local wTypes = { 'shared', 'zeus', 'pistol', 'hpistol', 'smg', 'rifle', 'shotgun', 'scout', 'asniper', 'sniper', 'lmg' }

local Random = function(iMax, iMin)
	return iMin + (math.random(999) % (iMax - iMin + 1));
end

local LegitDesync = function()
	gui.SetValue("rbot.antiaim.base", "0.0 Desync");
    gui.SetValue("rbot.antiaim.advanced.pitch", 0);
end

local RageDesync = function()
	gui.SetValue("rbot.antiaim.base", "180.0 Desync");
    gui.SetValue("rbot.antiaim.advanced.pitch", 1);
end

local StaticSync = function(bSide)
	if bSide == true then
		gui.SetValue("rbot.antiaim.base.rotation", 58);
		gui.SetValue("rbot.antiaim.base.lby", kSyncMax:GetValue() * -1);
	else
		gui.SetValue("rbot.antiaim.base.rotation", -58);
		gui.SetValue("rbot.antiaim.base.lby", kSyncMax:GetValue());
	end
end

local JitterSync = function(bSide)
	if bSide == true then
		gui.SetValue("rbot.antiaim.base.rotation", Random(kSyncJitterMin:GetValue(), kSyncJitterMax:GetValue()));
		gui.SetValue("rbot.antiaim.base.lby", math.random(kSyncMax:GetValue() * -1));
	else
		gui.SetValue("rbot.antiaim.base.rotation", Random(kSyncJitterMin:GetValue() * -1, kSyncJitterMax:GetValue() * -1));
		gui.SetValue("rbot.antiaim.base.lby", math.random(kSyncMax:GetValue()));
	end
end

local iSwayIndex = 18;

local SwaySync = function(bSide)

	if bSide == true then
		gui.SetValue("rbot.antiaim.base.rotation", 58);
		gui.SetValue("rbot.antiaim.base.lby", iSwayIndex * -1);
	else
		gui.SetValue("rbot.antiaim.base.rotation", -58);
		gui.SetValue("rbot.antiaim.base.lby", iSwayIndex);
	end
	
	if iSwayIndex + 5 > kSyncMax:GetValue() + 1 then
	   iSwayIndex = 0;
	end
	
	iSwayIndex = iSwayIndex + 5;	
end

local BackupCfg = function()
	for i=1, #wTypes do
		aMinDmg[i] = gui.GetValue("rbot.accuracy.weapon."..wTypes[i]..".mindmg");
		aBAim[i] = gui.GetValue("rbot.hitscan.mode."..wTypes[i]..".bodyaim.force");
	end
end

local RestoreDamage = function()
	for i=1, #wTypes do
		gui.SetValue("rbot.accuracy.weapon."..wTypes[i]..".mindmg", aMinDmg[i]);
	end
end

local SetDamage = function(iMinDmg)
	for i=1, #wTypes do
		gui.SetValue("rbot.accuracy.weapon."..wTypes[i]..".mindmg", iMinDmg);
	end
end

local SetBaim = function()
	for i=1, #wTypes do
		gui.SetValue("rbot.hitscan.mode."..wTypes[i]..".bodyaim.force", 1);
	end
end

local RestoreBaim = function()
	for i=1, #wTypes do
		gui.SetValue("rbot.hitscan.mode."..wTypes[i]..".bodyaim.force", aBAim[i]);
	end
end

BackupCfg();

callbacks.Register("Draw", function()
	
	local iYAdd = 75;
	gui.SetValue("rbot.antiaim.left", 0);
    gui.SetValue("rbot.antiaim.right", 0);
	gui.SetValue("rbot.antiaim.advanced.autodir.edges", 0);
    gui.SetValue("rbot.antiaim.advanced.autodir.targets", 0);
	
	if kSyncMode:GetValue() == false then
		LegitDesync();
	else
		RageDesync();
		draw.Color(255, 0, 0, 255);
		draw.TextShadow(screenCenterX - textWarningSizeX / 2, screenCenterY + iYAdd, strWarningText);
		iYAdd = iYAdd + 15;
	end
		
	if kAntiAlignFlicking:GetValue() == true then
		if math.random(35) == 1 then
			gui.SetValue("rbot.antiaim.advanced.antialign", 1);
		else
			gui.SetValue("rbot.antiaim.advanced.antialign", 0);
		end
	end
	
	if kDesyncTypeFlicking:GetValue() == true then
		if math.random(5) == 1 then
			gui.SetValue("rbot.polakmenu.synctype", 1);
		else
			gui.SetValue("rbot.polakmenu.synctype", 2);
		end
	end
	
	if kSwitchKey:GetValue() ~= 0 then
		if input.IsButtonPressed(kSwitchKey:GetValue()) then
			if bSwitch == true then
				bSwitch = false;
			else
				bSwitch = true;
			end
		end
	end
	
	draw.Color(46, 46, 46, 200);
	draw.Triangle(screenCenterX + 50, screenCenterY - 7, screenCenterX + 65, screenCenterY - 7 + 8, screenCenterX + 50, screenCenterY - 7 + 15);
	draw.Triangle(screenCenterX - 50, screenCenterY - 7, screenCenterX - 65, screenCenterY - 7 + 8, screenCenterX - 50, screenCenterY - 7 + 15);
	local r, g, b, a = kColorPicker:GetValue();
	draw.Color(r, g, b, a);

	if bSwitch == true then	
		if kSyncType:GetValue() == 0 then
			if kSyncMode:GetValue() == false then
				StaticSync(true);
			else
				StaticSync(false);
			end
		elseif kSyncType:GetValue() == 1 then
			if kSyncMode:GetValue() == false then
				JitterSync(true);
			else
				JitterSync(false);
			end
		else
			if kSyncMode:GetValue() == false then
				SwaySync(true);
			else
				SwaySync(false);
			end
		end
		
		draw.Line(screenCenterX + 50, screenCenterY - 7, screenCenterX + 65, screenCenterY - 7 + 8);
		draw.Line(screenCenterX + 50, screenCenterY - 7 + 15, screenCenterX + 65, screenCenterY - 7 + 8);
	else
		if kSyncType:GetValue() == 0 then
			if kSyncMode:GetValue() == false then
				StaticSync(false);
			else
				StaticSync(true);
			end
		elseif kSyncType:GetValue() == 1 then
			if kSyncMode:GetValue() == false then
				JitterSync(false);
			else
				JitterSync(true);
			end
		else
			if kSyncMode:GetValue() == false then
				SwaySync(false);
			else
				SwaySync(true);
			end
		end
		
		draw.Line(screenCenterX - 50, screenCenterY - 7, screenCenterX - 65, screenCenterY - 7 + 8);
		draw.Line(screenCenterX - 50, screenCenterY - 7 + 15, screenCenterX - 65, screenCenterY - 7 + 8);

	end
	
	draw.Color(68, 255, 0, 255);
	
	if gui.GetValue("rbot.antiaim.condition.shiftonshot") == true then
		local strHideshotsText = "Hide Shots";
		draw.TextShadow(screenCenterX - draw.GetTextSize(strHideshotsText) / 2, screenCenterY + iYAdd, strHideshotsText);
		iYAdd = iYAdd + 15;
	end
	
	if kMindmgKey:GetValue() == true then
		local iMinDmg = kMinDmgSlider:GetValue();
		SetDamage(iMinDmg);
		
		local strDamageText = "Min Damage: "..iMinDmg;
		draw.TextShadow(screenCenterX - draw.GetTextSize(strDamageText) / 2, screenCenterY + iYAdd, strDamageText);
		iYAdd = iYAdd + 15;
	else
		RestoreDamage();
	end
	
	if kBaimKey:GetValue() == true then
		SetBaim();
		local strBaimText = "Force Baim";
		draw.TextShadow(screenCenterX - draw.GetTextSize(strBaimText) / 2, screenCenterY + iYAdd, strBaimText);
		iYAdd = iYAdd + 15;
	else
		RestoreBaim();
	end
end)
