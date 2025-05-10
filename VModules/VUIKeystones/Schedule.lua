local VUI = select(2, ...)
local Module = VUI:GetModule("VUIKeystones")
local Schedule = Module:NewSubmodule("Schedule")

local rowCount = 3

local requestPartyKeystones

-- 1:Overflowing, 2:Skittish, 3:Volcanic, 4:Necrotic, 5:Teeming, 6:Raging, 7:Bolstering, 8:Sanguine, 9:Tyrannical, 10:Fortified, 11:Bursting, 12:Grievous, 13:Explosive, 14:Quaking, 16:Infested, 117: Reaping, 119:Beguiling 120:Awakened, 121:Prideful, 122:Inspiring, 123:Spiteful, 124:Storming
-- 134:Entangling, 135：Afflicted, 136:Incorporeal
-- TWW 
-- 147:Xal'atath's Guile, 148:Xal'atath's Bargain: Ascendant,158:Xal'atath's Bargain: Voidbound, 159:Xal'atath's Bargain: Oblivion, 160:Xal'atath's Bargain: Devour, 162:Xal'atath's Bargain: Pulsar
-- Season 2  
-- 9, 10, 147, 148, 158, 160, 162,
local affixSchedule = {
-- TWW Season 2 (Sort:[1](Level 4+);[2](Level 7+);[3](Level 10+);[4](Level 12+))
-- Information from(资料来自)：https://www.wowhead.com/guide/mythic-plus-dungeons/the-war-within-season-2/overview
{ [1]=148, [2] =9 , [3]=10, [4]=147, }, -- (1) Xal'atath's Bargain: Ascendant | Tyrannical | Fortified  | Xal'atath's Guile
{ [1]=162, [2] =10, [3]=9 , [4]=147, }, -- (2) Xal'atath's Bargain: Pulsar    | Fortified  | Tyrannical | Xal'atath's Guile
{ [1]=158, [2] =9 , [3]=10, [4]=147, }, -- (3) Xal'atath's Bargain: Voidbound | Tyrannical | Fortified  | Xal'atath's Guile
{ [1]=160, [2] =10, [3]=9 , [4]=147, }, -- (4) Xal'atath's Bargain: Devour    | Fortified  | Tyrannical | Xal'atath's Guile
{ [1]=162, [2] =9 , [3]=10, [4]=147, }, -- (5) Xal'atath's Bargain: Pulsar    | Tyrannical | Fortified  | Xal'atath's Guile
{ [1]=148, [2] =10, [3]=9 , [4]=147, }, -- (6) Xal'atath's Bargain: Ascendant | Fortified  | Tyrannical | Xal'atath's Guile
{ [1]=160, [2] =9 , [3]=10, [4]=147, }, -- (7) Xal'atath's Bargain: Devour    | Tyrannical | Fortified  | Xal'atath's Guile
{ [1]=158, [2] =10, [3]=9 , [4]=147, }, -- (8) Xal'atath's Bargain: Voidbound | Fortified  | Tyrannical | Xal'atath's Guile
}

local scheduleEnabled = true
local affixScheduleUnknown = true
local currentWeek
local currentKeystoneMapID
local currentKeystoneLevel
local unitKeystones = {}
local hookedIconTooltips = false

local function GetNameForKeystone(keystoneMapID, keystoneLevel)
	local keystoneMapName = keystoneMapID and C_ChallengeMode.GetMapUIInfo(keystoneMapID)
	if keystoneMapID and keystoneMapName then
		if Module.Locale:Local("dungeon_"..keystoneMapName) then
			keystoneMapName = Module.Locale:Get("dungeon_"..keystoneMapName)
		end
		keystoneMapName = gsub(keystoneMapName, ".-%-", "") -- Mechagon
		keystoneMapName = gsub(keystoneMapName, ".-"..HEADER_COLON, "") -- Tazavesh
		return string.format("(%d) %s", keystoneLevel, keystoneMapName)
	end
end

local function UpdatePartyKeystones()
	Schedule:CheckCurrentKeystone()
	if requestPartyKeystones then
		Schedule:SendPartyKeystonesRequest()
	end

	if not scheduleEnabled then return end
	if not C_AddOns.IsAddOnLoaded("Blizzard_ChallengesUI") then return end

	local playerRealm = select(2, UnitFullName("player")) or ""

	local e = 1
	for i = 1, 4 do
		local entry = Schedule.PartyFrame.Entries[e]
		local name, realm = UnitName("party"..i)

		if name then
			local fullName
			if not realm or realm == "" then
				fullName = name.."-"..playerRealm
			else
				fullName = name.."-"..realm
			end

			if unitKeystones[fullName] ~= nil then
				local keystoneName
				if unitKeystones[fullName] == 0 then
					keystoneName = NONE
				else
					keystoneName = GetNameForKeystone(unitKeystones[fullName][1], unitKeystones[fullName][2])
				end
				if keystoneName then
					entry:Show()
					local _, class = UnitClass("party"..i)
					local color = RAID_CLASS_COLORS[class]
					entry.Text:SetText(name)
					entry.Text:SetTextColor(color:GetRGBA())
					entry.Text2:SetText(keystoneName)
					e = e + 1
				end
			end
		end
	end
	if e == 1 then
		Schedule.AffixFrame:ClearAllPoints()
		Schedule.AffixFrame:SetPoint("LEFT", ChallengesFrame.WeeklyInfo.Child.WeeklyChest, "RIGHT", 130, 0)
		Schedule.PartyFrame:Hide()
	else
		Schedule.AffixFrame:ClearAllPoints()
		Schedule.AffixFrame:SetPoint("TOPLEFT", ChallengesFrame.WeeklyInfo.Child.WeeklyChest, "TOPRIGHT", 130, 55)
		Schedule.PartyFrame:Show()
	end
	while e <= 4 do
		Schedule.PartyFrame.Entries[e]:Hide()
		e = e + 1
	end
end

function Schedule:CheckCurrentKeystone(sendParty)
	local keystoneMapID = C_MythicPlus.GetOwnedKeystoneMapID()
	local keystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()

	if keystoneMapID ~= currentKeystoneMapID or keystoneLevel ~= currentKeystoneLevel then
		currentKeystoneMapID = keystoneMapID
		currentKeystoneLevel = keystoneLevel
		
		if sendParty ~= false and IsInGroup() then
			self:SendKeystoneToParty()
		end
	end

	if ((not keystoneMapID) or (not keystoneLevel)) then
		unitKeystones[UnitName("player").."-"..select(2, UnitFullName("player"))] = 0
	else
		unitKeystones[UnitName("player").."-"..select(2, UnitFullName("player"))] = { keystoneMapID, keystoneLevel }
	end

	if self.AffixFrame and self.AffixFrame:IsShown() then
		UpdatePartyKeystones()
	end
end

function Schedule:SetPartyKeystoneRequest()
	requestPartyKeystones = true
	if IsInGroup() and (self.AffixFrame and self.AffixFrame:IsShown()) then
		self:SendPartyKeystonesRequest()
	end
end

function Schedule:SendKeystoneToParty()
	if IsInGroup() and self.db.profile.sendKeystoneToParty and (currentKeystoneMapID and currentKeystoneLevel) then
		Module:SendAddOnComm("Keystone", currentKeystoneMapID..":"..currentKeystoneLevel)
	end
end

function Schedule:SendPartyKeystonesRequest()
	requestPartyKeystones = false
	if IsInGroup() and self.db.profile.announceKeystones then
		Module:SendAddOnComm("KeystoneRequest")
	end
end

function Schedule:OnAddOnCommReceived(prefix, message, channel, sender)
	if prefix ~= "Keystone" and prefix ~= "KeystoneRequest" then return end
	if sender == UnitName("player").."-"..select(2, UnitFullName("player")) then return end
	
	if prefix == "KeystoneRequest" then
		self:SendKeystoneToParty()
	elseif prefix == "Keystone" then
		local arg1, arg2 = strsplit(":", message)
		local keystoneMapID = arg1 and tonumber(arg1)
		local keystoneLevel = arg2 and tonumber(arg2)
		if keystoneMapID and keystoneLevel and (unitKeystones[sender] == nil or unitKeystones[sender] == 0
		or not (unitKeystones[sender][1] == keystoneMapID and unitKeystones[sender][2] == keystoneLevel)) then
			unitKeystones[sender] = { keystoneMapID, keystoneLevel }
			UpdatePartyKeystones()
		end
	end
end

function Schedule:CHALLENGE_MODE_START()
	self:CheckCurrentKeystone(false)
	C_Timer.After(2, function() self:CheckCurrentKeystone(false) end)
	self:SetPartyKeystoneRequest()
end

function Schedule:CHALLENGE_MODE_COMPLETED()
	self:CheckCurrentKeystone()
	C_Timer.After(2, function() self:CheckCurrentKeystone() end)
	self:SetPartyKeystoneRequest()
end

function Schedule:CHALLENGE_MODE_UPDATED()
	self:CheckCurrentKeystone()
end

function Schedule:Startup()
	scheduleEnabled = Module.db.profile.schedule

	self:RegisterAddOnLoaded("Blizzard_ChallengesUI")
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "SetPartyKeystoneRequest")
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("CHAT_MSG_LOOT")
	self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
	self:RegisterEvent("CHALLENGE_MODE_START")
	self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE", "CHALLENGE_MODE_UPDATED")
	self:RegisterEvent("CHALLENGE_MODE_LEADERS_UPDATE", "CHALLENGE_MODE_UPDATED")
	self:RegisterEvent("CHALLENGE_MODE_MEMBER_INFO_UPDATED", "CHALLENGE_MODE_UPDATED")
	self:RegisterAddOnComm()
	self:CheckCurrentKeystone()

	C_Timer.After(3, function()
		C_MythicPlus.RequestCurrentAffixes()
		C_MythicPlus.RequestRewards()
	end)

	C_Timer.NewTicker(60, function() self:CheckCurrentKeystone() end)

	requestPartyKeystones = true
end

Module:RegisterSubmodule(Schedule)