------------------------------
--      Are you local?      --
------------------------------
local boss = AceLibrary("Babble-Boss-2.2")["Nefarian"]
local victor = AceLibrary("Babble-Boss-2.2")["Lord Victor Nefarius"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local warnpairs = nil

-- bow vars
local BowBag = 0
local BowSlot = 0

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	landing_soon_trigger = "Let the games begin!",
	landing_trigger = "Burn, you wretches",
	-- landing_trigger = "Enough! Now you",
	zerg_trigger = "Impossible! Rise my",
	fear_trigger = "Nefarian begins to cast Bellowing Roar",
	shadowflame_trigger = "Nefarian begins to cast Shadow Flame",

	shadowcurseyou_trigger = "You are afflicted by Veil of Shadow\.",
	shadowcurseother_trigger = "(.+) is afflicted by Veil of Shadow\.",

	triggerfear = "by Panic.",
	fbar = "Fear",
	land = "Landing",
	Mob_Spawn = "Mob Spawn",
	warn = "Fear in 1.5sec!",

	triggershamans	= "Shamans, show me",
	triggerdruid	= "Druids and your silly",
	triggerwarlock	= "Warlocks, you shouldn't be playing",
	triggerpriest	= "Priests! If you're going to keep",
	triggerhunter	= "Hunters and your annoying",
	triggerwarrior	= "Warriors, I know you can hit harder",
	triggerrogue	= "Rogues%? Stop hiding",
	triggerpaladin	= "Paladins",
	triggermage		= "Mages too%?",

	landing_soon_warning = "Nefarian landing in 30 seconds!",
	landing_very_soon = "Nefarian landing in 10 seconds!",
	landing_warning = "Nefarian is landing!",
	zerg_warning = "Zerg incoming!",
	fear_warning = "Fear in 2 sec!",
	fear_soon_warning = "Possible fear in ~5 sec",
	shadowflame_warning = "Shadow Flame incoming!",
	shadowflame_bar = "Shadow Flame",
	curse_warning = "%s has Curse : Decurse now !",
	curse_bar = "Possible Curse",
	classcall_warning = "Class call incoming!",

	warnshaman	= "Shamans - Totems spawned!",
	warndruid	= "Druids - Stuck in cat form!",
	warnwarlock	= "Warlocks - Incoming Infernals!",
	warnpriest	= "Priests - Heals hurt!",
	warnhunter	= "Hunters - Bows/Guns broken!",
	warnwarrior	= "Warriors - Stuck in berserking stance!",
	warnrogue	= "Rogues - Ported and rooted!",
	warnpaladin	= "Paladins - Blessing of Protection!",
	warnmage	= "Mages - Incoming polymorphs!",

	classcall_bar = "Class call",
	fear_bar = "Possible fear",

	cmd = "Nefarian",

	shadowflame_cmd = "shadowflame",
	shadowflame_name = "Shadow Flame alert",
	shadowflame_desc = "Warn for Shadow Flame",

	curse_cmd = "curse",
	curse_name = "Warn for Curse",
	curse_desc = "-75% heal curse timer and alert",

	fear_cmd = "fear",
	fear_name = "Warn for Fear",
	fear_desc = "Warn when Nefarian casts AoE Fear",

	classcall_cmd = "classcall",
	classcall_name = "Class Call alert",
	classcall_desc = "Warn for Class Calls",

	bowunequip_cmd = "bowunequip",
	bowunequip_name = "Unequip bow / gun",
	bowunequip_desc = "Auto Unequip Bow / Gun before classcall",

	ktm_cmd = "ktm",
	ktm_name = "Phase 2 KTM reset",
	ktm_desc = "Default is to not reset KTM (to avoid spam from too many assistants). Uncheck to reset KTM.\n\n(Requires assistant or higher)",

	otherwarn_cmd = "otherwarn",
	otherwarn_name = "Other alerts",
	otherwarn_desc = "Landing and Zerg warnings",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsNefarian = BigWigs:NewModule(boss)
BigWigsNefarian.zonename = AceLibrary("Babble-Zone-2.2")["Blackwing Lair"]
BigWigsNefarian.enabletrigger = { boss, victor }
BigWigsNefarian.toggleoptions = {"shadowflame", "curse", "fear", "classcall", "otherwarn", "bowunequip", "ktm","bosskill"}
BigWigsNefarian.revision = tonumber(string.sub("$Revision: 16641 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsNefarian:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "NefarianShadowflame", 10)
	self:TriggerEvent("BigWigs_ThrottleSync", "NefarianFear", 15)
	self:TriggerEvent("BigWigs_ThrottleSync", "NefarianCurse", 12)
	
	if not warnpairs then warnpairs = {
		[L["triggershamans"]] = {L["warnshaman"], true},
		[L["triggerdruid"]] = {L["warndruid"], true},
		[L["triggerwarlock"]] = {L["warnwarlock"], true},
		[L["triggerpriest"]] = {L["warnpriest"], true},
		[L["triggerhunter"]] = {L["warnhunter"], true},
		[L["triggerwarrior"]] = {L["warnwarrior"], true},
		[L["triggerrogue"]] = {L["warnrogue"], true},
		[L["triggerpaladin"]] = {L["warnpaladin"], true},
		[L["triggermage"]] = {L["warnmage"], true},
		[L["landing_soon_trigger"]] = {L["landing_soon_warning"]},
		[L["landing_trigger"]] = {L["landing_warning"]},
		[L["zerg_trigger"]] = {L["zerg_warning"]},
	} end
end

------------------------------
--   Hunter bow functions   --
------------------------------

function BigWigsNefarian:UnEquipBow( )
	AttackTarget();
	ClearTarget();
	TargetLastTarget();
	for i = 0, 4 do
		if GetContainerNumSlots(i) then
			for j = 1, GetContainerNumSlots(i) do
				if GetContainerItemInfo(i, j) == nil then
					ClearCursor();
					PickupInventoryItem(18);
					if CursorHasItem() then
						PickupContainerItem(i, j)
						BowBag = i;
						BowSlot = j;
						DEFAULT_CHAT_FRAME:AddMessage("OK ! bow unequiped");
					else
						DEFAULT_CHAT_FRAME:AddMessage("Error unequip bow : bow not found on char");
						-- UIErrorsFrame:AddMessage("Coucou", 1.0, 0.5, 0.0, 3);
					end
					return;	
				end
			end
		end
	end
end

function BigWigsNefarian:EquipBow( )
	if GetInventoryItemLink("player", 18) == nil then
		if GetContainerItemInfo( BowBag, BowSlot ) then
			ClearCursor();
			PickupContainerItem( BowBag, BowSlot );
			if CursorHasItem() then
				PickupInventoryItem(18);	
				BowBag = 0;
				BowSlot = 0;
				BowUnequipped = false;
				DEFAULT_CHAT_FRAME:AddMessage("OK ! bow equiped");
			else
				DEFAULT_CHAT_FRAME:AddMessage("Error equip bow : bow not selected from bags");
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("Error equip bow : bow not found in bags");
		end
	end
end

function BigWigsNefarian:ResetKtm( )
	if IsAddOnLoaded("KLHThreatMeter") and not self.db.profile.ktm and (IsRaidLeader() or IsRaidOfficer()) then
		klhtm.net.clearraidthreat()
	end
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsNefarian:CHAT_MSG_MONSTER_YELL(msg)
	local _, myclass = UnitClass("player")
	for i,v in pairs(warnpairs) do
		if string.find(msg, i) then
			if v[2] then
				if self.db.profile.bowunequip and myclass == "HUNTER" then
				-- self:ScheduleEvent("equipbow", self.EquipBow, 5)
					self:ScheduleEvent(self.EquipBow, 1)
					self:ScheduleEvent(self.UnEquipBow, 26)
				end
				if self.db.profile.classcall then
					self:TriggerEvent("BigWigs_Message", v[1], "Important")
					self:ScheduleEvent("BigWigs_Message", 25, L["classcall_warning"], "Important", true, "Alarm")
					self:TriggerEvent("BigWigs_StartBar", self, L["classcall_bar"], 30, "Interface\\Icons\\Spell_Shadow_Charm")
				end
			end
			if self.db.profile.otherwarn and string.find(msg, L["landing_soon_trigger"]) then 
				self:TriggerEvent("BigWigs_Message", v[1], "Important", true, "Long")
				self:TriggerEvent("BigWigs_StartBar", self, L["land"], 135, "Interface\\Icons\\INV_Misc_Head_Dragon_Black")
				self:TriggerEvent("BigWigs_StartBar", self, L["Mob_Spawn"], 10, "Interface\\Icons\\Spell_Holy_PrayerOfHealing")
				self:ScheduleEvent("BigWigs_Message", 105, L["landing_soon_warning"], "Important", true, "Alarm")
				self:ScheduleEvent("BigWigs_Message", 125, L["landing_very_soon"], "Important", true, "Long")
			elseif self.db.profile.otherwarn and string.find(msg, L["landing_trigger"]) then 
				self:TriggerEvent("BigWigs_Message", v[1], "Important", true, "Long")
				self:ScheduleEvent(self.ResetKtm, 10)
				-- first remove 25s after landing 5s before class call
				if self.db.profile.bowunequip and myclass == "HUNTER" then
					self:ScheduleEvent(self.UnEquipBow, 24)
				end
			elseif self.db.profile.otherwarn and string.find(msg, L["zerg_trigger"]) then 
				self:TriggerEvent("BigWigs_Message", v[1], "Important", true, "Long")
			end
			return
		end
	end
end

function BigWigsNefarian:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE(msg)
	if string.find(msg, L["fear_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "NefarianFear")
	elseif string.find(msg, L["shadowflame_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "NefarianShadowflame")
	end
end

function BigWigsNefarian:Event(msg)
	local _,_,shadowcurseother,_ = string.find(msg, L["shadowcurseother_trigger"])
	if string.find(msg, L["shadowcurseyou_trigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "NefarianCurse "..UnitName("player"))
	elseif shadowcurseother then
		self:TriggerEvent("BigWigs_SendSync", "NefarianCurse "..shadowcurseother)
	end
end

function BigWigsNefarian:BigWigs_RecvSync( sync , rest )
	if sync == "NefarianShadowflame" and self.db.profile.shadowflame then
		self:TriggerEvent("BigWigs_StartBar", self, L["shadowflame_bar"], 2, "Interface\\Icons\\Spell_Fire_Incinerate")
		self:TriggerEvent("BigWigs_Message", L["shadowflame_warning"], "Important")
	elseif sync == "NefarianFear" and self.db.profile.fear then
		self:TriggerEvent("BigWigs_Message", L["fear_warning"], "Important", true, "Alert")
		self:TriggerEvent("BigWigs_StartBar", self, L["fear_bar"], 1.5, "Interface\\Icons\\Spell_Shadow_Charm")
		self:ScheduleEvent("BigWigs_StartBar", 1.5, self, L["fear_bar"], 23.5, "Interface\\Icons\\Spell_Shadow_Charm")
	elseif sync == "NefarianCurse" and self.db.profile.curse then
		self:TriggerEvent("BigWigs_StartBar", self, L["curse_bar"], 12, "Interface\\Icons\\Spell_Shadow_GatherShadows")
		-- self:TriggerEvent("BigWigs_Message", L["curse_warning"], "Important")
		self:TriggerEvent("BigWigs_Message", string.format(L["curse_warning"], rest), "Attention")
	end
end

