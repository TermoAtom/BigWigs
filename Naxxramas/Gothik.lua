﻿------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.0")("Gothik the Harvester")
local L = AceLibrary("AceLocale-2.0"):new("BigWigs"..boss)

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {

	cmd = "gothik",

	room_cmd = "room",
	room_name = "Room Arrival Alerts",
	room_desc = "Warn for Gothik's arrival",

	add_cmd = "add",
	add_name = "Add Warnings",
	add_desc = "Warn for adds",

	disabletrigger = "I... am... undone.",		

	starttrigger1 = "Foolishly you have sought your own demise.",
	starttrigger2 = "Teamanare shi rikk mannor rikk lok karkun",
	startwarn = "Gothik the Harvester engaged! 4:30 till he's in the room.",
	
	riderdietrigger = "Unrelenting Rider dies.",
	dkdietrigger = "Unrelenting Deathknight dies.",
	
	riderdiewarn = "Rider dead!",
	dkdiewarn = "Death Knight dead!",
	
	warn1 = "In room in 3 minutes",
	warn2 = "In room in 90 seconds",
	warn3 = "In room in 60 seconds",
	warn4 = "In room in 30 seconds",
	warn5 = "Gothik Incoming in 10 seconds",
	
	wave = "%d/18: ",
	
	trawarn = "Trainees in 3 seconds",
	dkwarn = "Deathknight in 3 seconds",
	riderwarn = "Rider in 3 seconds",

	trabar = "Trainees",
	dkbar = "Deathknight",
	riderbar = "Rider",
	
	inroomtrigger = "I have waited long enough. Now you face the harvester of souls.",
	inroomwarn = "He's in the room!",
	
	inroombartext = "In Room",
} end )

L:RegisterTranslations("deDE", function() return {
	disabletrigger = "I... am... undone.", -- ?

	starttrigger1 = "Ihr Narren habt euren eigenen Untergang heraufbeschworen.",
	starttrigger2 = "Maz Azgala veni kamil toralar Naztheros zennshinagas.", -- ?
	startwarn = "Gothik der Ernter angegriffen! 4:30 bis er in den Raum kommt!",
	
	riderdietrigger = "Unerbittlicher Reiter stirbt.",
	dkdietrigger = "Unerbittlicher Todesritter stirbt.",
	
	riderdiewarn = "Reiter tot!",
	dkdiewarn = "Todesritter tot!",
	
	warn1 = "Im Raum in 3 Minuten",
	warn2 = "Im Raum in 90 Sekunden",
	warn3 = "Im Raum in 60 Sekunden",
	warn4 = "Im Raum in 30 Sekunden",
	warn5 = "Gothik im Raum in 10 Sekunden",
	
	wave = "%d/18: ",
	
	trawarn = "Lehrlinge in 3 Sekunden",
	dkwarn = "Todesritter in 3 Sekunden",
	riderwarn = "Reiter in 3 Sekunden",

	trabar = "Lehrlinge",
	dkbar = "Todesritter",
	riderbar = "Reiter",
	
	inroomtrigger = "Ich habe lange genug gewartet. Stellt euch dem Seelenj\195\164ger.", -- ?
	inroomwarn = "Er ist im Raum!",
	
	inroombartext = "Im Raum",
} end )

L:RegisterTranslations("zhCN", function() return {
	room_name = "进入房间警报",
	room_desc = "收割者戈提克进入房间时发出警报",

	add_name = "增援警报",
	add_desc = "增援警报",

	disabletrigger = "I... am... undone.",		

	starttrigger1 = "你愚蠢地寻找自己的困境。",
	starttrigger2 = "Teamanare shi rikk mannor rikk lok karkun",
	startwarn = "收割者戈提克已激活 - 4:30后进入房间",
	
	riderdietrigger = "冷酷的骑兵死亡了。",
	dkdietrigger = "冷酷的死亡骑士死亡了。",
	
	riderdiewarn = "骑兵已死亡！",
	dkdiewarn = "死亡骑士已死亡！",
	
	warn1 = "3分钟后进入房间",
	warn2 = "90秒后进入房间",
	warn3 = "60秒后进入房间",
	warn4 = "30秒后进入房间",
	warn5 = "收割者戈提克10后进入房间！",
	
	trawarn = "3秒后学徒出现",
	dkwarn = "3秒后死亡骑士出现",
	riderwarn = "3秒后骑兵出现",

	trabar = "学徒",
	dkbar = "死亡骑士",
	riderbar = "骑兵",
	
	inroomtrigger = "我等待了太久。现在你面对灵魂收割机。",
	inroomwarn = "收割者戈提克进入了房间！",
	
	inroombartext = "进入房间",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsGothik = BigWigs:NewModule(boss)
BigWigsGothik.zonename = AceLibrary("Babble-Zone-2.0")("Naxxramas")
BigWigsGothik.enabletrigger = boss
BigWigsGothik.toggleoptions = { "room", "add", "bosskill"}
BigWigsGothik.revision = tonumber(string.sub("$Revision$", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsGothik:OnEnable()
	self.wave = 0
	self.tratime = 27
	self.dktime = 77
	self.ridertime = 137

	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
end

function BigWigsGothik:PLAYER_REGEN_ENABLED()
	local go = self:Scan()
	local running = self:IsEventScheduled("Gothik_CheckWipe")
	if (not go) then
		self:TriggerEvent("BigWigs_RebootModule", self)
	elseif (not running) then
		self:ScheduleRepeatingEvent("Gothik_CheckWipe", self.PLAYER_REGEN_ENABLED, 2, self)
	end
end

function BigWigsGothik:Scan()
	if (UnitName("target") == boss and UnitAffectingCombat("target")) then
		return true
	elseif (UnitName("playertarget") == boss and UnitAffectingCombat("playertarget")) then
		return true
	else
		local i
		for i = 1, GetNumRaidMembers(), 1 do
			if (UnitName("raid"..i.."target") == boss and UnitAffectingCombat("raid"..i.."target")) then
				return true
			end
		end
	end
	return false
end

function BigWigsGothik:CHAT_MSG_COMBAT_HOSTILE_DEATH( msg )
	if msg == L["riderdietrigger"] and self.db.profile.add then
		self:TriggerEvent("BigWigs_Message", L["riderdiewarn"], "Red")
	elseif msg == L["dkdietrigger"] and self.db.profile.add  then
		self:TriggerEvent("BigWigs_Message", L["dkdiewarn"], "Red")
	end
end

function BigWigsGothik:StopRoom()
	self:TriggerEvent("BigWigs_StopBar", self, L["inroombartext"])
	self:CancelScheduledEvent("bwgothikwarn1")
	self:CancelScheduledEvent("bwgothikwarn2")
	self:CancelScheduledEvent("bwgothikwarn3")
	self:CancelScheduledEvent("bwgothikwarn4")
	self:CancelScheduledEvent("bwgothikwarn5")
	self:TriggerEvent("BigWigs_StopBar", self, L["trabar"])
	self:TriggerEvent("BigWigs_StopBar", self, L["dkbar"])
	self:TriggerEvent("BigWigs_StopBar", self, L["riderbar"])
	self:CancelScheduledEvent("bwgothiktrawarn")
	self:CancelScheduledEvent("bwgothikdkwarn")
	self:CancelScheduledEvent("bwgothikriderwarn")
	self:CancelScheduledEvent("bwgothiktrarepop")
	self:CancelScheduledEvent("bwgothikdkrepop")
	self:CancelScheduledEvent("bwgothikriderrepop")
end

function BigWigsGothik:WaveWarn(message, L, color)
	self.wave = self.wave + 1
	if self.db.profile.add then self:TriggerEvent("BigWigs_Message", string.format(L["wave"], self.wave) .. message, color) end
end

function BigWigsGothik:Trainee()
	if self.db.profile.add then
		self:TriggerEvent("BigWigs_StartBar", self, L["trabar"], self.tratime, "Interface\\Icons\\Ability_Seal", "Yellow", "Orange", "Red")
	end
	self:ScheduleEvent("bwgothiktrawarn", self.WaveWarn, self.tratime - 3, self, L["trawarn"], L, "Yellow")
	self:ScheduleRepeatingEvent("bwgothiktrarepop", self.Trainee, self.tratime, self)
end

function BigWigsGothik:DeathKnight()
	if self.db.profile.add then
		self:TriggerEvent("BigWigs_StartBar", self, L["dkbar"], self.dktime, "Interface\\Icons\\INV_Boots_Plate_08", "Yellow", "Orange", "Red")
	end
	self:ScheduleEvent("bwgothikdkwarn", self.WaveWarn, self.dktime - 3, self, L["dkwarn"], L, "Orange")
	self:ScheduleRepeatingEvent("bwgothikdkrepop", self.DeathKnight, self.dktime, self)
end

function BigWigsGothik:Rider()
	if self.db.profile.add then
		self:TriggerEvent("BigWigs_StartBar", self, L["riderbar"], self.ridertime, "Interface\\Icons\\Spell_Shadow_DeathPact", "Yellow", "Orange", "Red")
	end
	self:ScheduleEvent("bwgothikriderwarn", self.WaveWarn, self.ridertime - 3, self, L["riderwarn"], L, "Red")
	self:ScheduleRepeatingEvent("bwgothikriderrepop", self.Rider, self.ridertime, self)
end

function BigWigsGothik:CHAT_MSG_MONSTER_YELL( msg )
	if msg == L["starttrigger1"] or msg == L["starttrigger2"] then
		if self.db.profile.room then
			self:TriggerEvent("BigWigs_Message", L["startwarn"], "Red")
			self:TriggerEvent("BigWigs_StartBar", self, L["inroombartext"], 270, "Interface\\Icons\\Spell_Magic_LesserInvisibilty", "Green", "Yellow", "Orange", "Red")
			self:ScheduleEvent("bwgothikwarn1", "BigWigs_Message", 90, L["warn1"], "Green")
			self:ScheduleEvent("bwgothikwarn2", "BigWigs_Message", 180, L["warn2"], "Yellow")
			self:ScheduleEvent("bwgothikwarn3", "BigWigs_Message", 210, L["warn3"], "Orange")
			self:ScheduleEvent("bwgothikwarn4", "BigWigs_Message", 240, L["warn4"], "Red")
			self:ScheduleEvent("bwgothikwarn5", "BigWigs_Message", 260, L["warn5"], "Red")
		end
		if self.db.profile.add then		
			self:Trainee()
			self:DeathKnight()
			self:Rider()
		end
		-- set the new times
		self.tratime = 20
		self.dktime = 25
		self.ridertime = 30
	elseif msg == L["inroomtrigger"] then
		if self.db.profile.room then self:TriggerEvent("BigWigs_Message", L["inroomwarn"], "Red") end
		self:StopRoom()
	elseif string.find(msg, L["disabletrigger"]) then
		if self.db.profile.bosskill then self:TriggerEvent("BigWigs_Message", string.format(AceLibrary("AceLocale-2.0"):new("BigWigs")("%s has been defeated"), boss), "Green", nil, "Victory") end
		self.core:ToggleModuleActive(self, false)
	end
end
