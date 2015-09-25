------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Vaelastrasz the Corrupt"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local playerName = nil

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Vaelastrasz",

	trigger1 = "^([^%s]+) ([^%s]+) afflicted by Burning Adrenaline",
	
	yell1 = "^Too late, friends",
	yell2 = "^I beg you, mortals",
	yell3 = "^FLAME! DEATH! DESTRUCTION!",
	
	start_bar = "Start",

	you = "You",
	are = "are",

	warn1 = "You are burning!",
	warn2 = " is burning!",

	start_cmd = "start",
	start_name = "Start",
	start_desc = "Start of fight. Yells and shit.",

	youburning_cmd = "youburning",
	youburning_name = "You are burning alert",
	youburning_desc = "Warn when you are burning",

	elseburning_cmd = "elseburning",
	elseburning_name = "Someone else is burning alert",
	elseburning_desc = "Warn when others are burning",

	burningbar_cmd = "burningbar",
	burningbar_name = "Burning Adrenaline bar",
	burningbar_desc = "Shows a timer bar for Burning Adrenaline",

	icon_cmd = "icon",
	icon_name = "Raid Icon on bomb",
	icon_desc = "Put a Raid Icon on the person who's the bomb. (Requires promoted or higher)",
} end)

L:RegisterTranslations("deDE", function() return {
	trigger1 = "^([^%s]+) ([^%s]+) von Brennendes Adrenalin betroffen",

	you = "Ihr",
	are = "seid",

	warn1 = "Du brennst!",
	warn2 = " brennt!",

	youburning_name = "Du brennst",
	youburning_desc = "Warnung, wenn Du brennst.",

	elseburning_name = "X brennt",
	elseburning_desc = "Warnung, wenn andere Spieler brennen.",

	burningbar_name = "Brennendes Adrenalin",
	burningbar_desc = "Zeigt einen Anzeigebalken f\195\188r Brennendes Adrenalin.",

	icon_name = "Symbol",
	icon_desc = "Platziert ein Symbol \195\188ber dem Spieler der brennt. (Ben\195\182tigt Anf\195\188hrer oder Bef\195\182rdert Status.)",
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsVaelastrasz = BigWigs:NewModule(boss)
BigWigsVaelastrasz.zonename = AceLibrary("Babble-Zone-2.2")["Blackwing Lair"]
BigWigsVaelastrasz.enabletrigger = boss
BigWigsVaelastrasz.toggleoptions = { "start", "youburning", "elseburning", "burningbar", "icon", "bosskill" }
BigWigsVaelastrasz.revision = tonumber(string.sub("$Revision: 11201 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsVaelastrasz:OnEnable()
	barstarted = false
	playerName = UnitName("player")

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "VaelBomb", 1)
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsVaelastrasz:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["yell1"]) and self.db.profile.start then
		self:TriggerEvent("BigWigs_StartBar", self, L["start_bar"], 36, "Interface\\Icons\\Spell_Holy_PrayerOfHealing")
		barstarted = true
	elseif string.find(msg, L["yell2"]) and self.db.profile.start and not barstarted then
		self:TriggerEvent("BigWigs_StartBar", self, L["start_bar"], 26, "Interface\\Icons\\Spell_Holy_PrayerOfHealing")
		barstarted = true
	elseif string.find(msg, L["yell3"]) and self.db.profile.start and not barstarted then
		self:TriggerEvent("BigWigs_StartBar", self, L["start_bar"], 10, "Interface\\Icons\\Spell_Holy_PrayerOfHealing")
	end
end

function BigWigsVaelastrasz:BigWigs_RecvSync(sync, rest, nick)
end

function BigWigsVaelastrasz:Event(msg)
	local _, _, baPlayer = string.find(msg, L["trigger1"])
	if baPlayer then
		if baPlayer == L["you"] then
			baPlayer = playerName
		end
		self:TriggerEvent("BigWigs_SendSync", "VaelBomb "..baPlayer)
	end
end
