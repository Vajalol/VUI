---@class VUIBuffs: AceModule
local VUIBuffs = LibStub("AceAddon-3.0"):GetAddon("VUIBuffs")

local pairs, IsAddOnLoaded, next, type = pairs, C_AddOns.IsAddOnLoaded, next, type
local addOnsExist = true
local enabledPatterns = {}
local framesToFind = {}
local tempFrameCache = {}

VUIBuffs.frames = {}

--[[ addonFrameInfo

    key:    The name of the addon. This key checked with IsAddOnLoaded, so it must match the name of the
            addon's .toc file exactly.

    frame:  The pattern to match the frame name against. Be as specific as possible, preferrably with beginnings (^)
            and endings ($) as we want to minimize the number of frames we need to process and avoid attaching
            to incorrect frames.

    type:   The filter type of frame. This is used to determine which bars to show/hide when the user changes
            visibility settings.

            Current valid types are "arena", "raid", "party", "pet", "tank", "assist", and "player". If adding more types,
            be sure to update the defaultBarSettings table in VUIBuffs.lua.

    unit:   The name of the key that the addon uses to identify the frame's corresponding displayed unit.
]]
local addonFrameInfo = {
    ["ElvUI"] = {
        {
            frame = "^ElvUF_Raid%d+Group%dUnitButton%d+$",
            type = "raid",
            unit = "unit",
        },
        {
            frame = "^ElvUF_PartyGroup1UnitButton%d+$",
            type = "party",
            unit = "unit",
        },
        {
            frame = "^ElvUF_RaidpetGroup%dUnitButton%d+$",
            type = "pet",
            unit = "unit",
        },
        {
            frame = "^ElvUF_TankUnitButton%d$",
            type = "tank",
            unit = "unit",
        },
        {
            frame = "^ElvUF_AssistUnitButton%d$",
            type = "assist",
            unit = "unit",
        },
        {
            frame = "^ElvUF_Player$",
            type = "player",
            unit = "unit",
        },
    },
    ["Grid"] = {
        {
            frame = "Grid2LayoutHeader%d%a%d+UnitButton%d%d?$",
            type = "raid",
            unit = "unit",
        },
    },
    ["Grid2"] = {
        {
            frame = "Grid2LayoutHeader%d%a%d+UnitButton%d%d?$",
            type = "raid",
            unit = "unit",
        },
    },
    ["CompactRaidFrame"] = {
        {
            frame = "^CompactRaidFrame%d+$",
            type = "raid",
            unit = "unit",
        },
        {
            frame = "^CompactRaidGroup%dMember%d+$",
            type = "raid",
            unit = "unit",
        },
        {
            frame = "^CompactPartyFrameMember%d$",
            type = "party",
            unit = "unit",
        },
    },
    ["VuhDo"] = {
        {
            frame = "^Vd%d+$",
            type = "raid",
            unit = "unit",
        },
        {
            frame = "^Vd%d+H%d+$", -- Find VuhDo HOT frames
            type = "raid",
            unit = "unit",
            useParent = true,
        },
    },
    ["Healbot"] = {
        {
            frame = "^HealBot_Action_HealUnit%d+$",
            type = "raid",
            unit = "unit",
        },
        {
            frame = "^HealBot_Action_HealUnit%d+Trt%d+$",
            type = "raid",
            unit = "unit",
            useParent = true,
        },
    },
    ["Gladius"] = {
        {
            frame = "^GladiusButtonFrame%d$",
            type = "arena",
            unit = "unit",
        },
    },
    ["GladiusEx"] = {
        {
            frame = "^GladiusExButtonFrame%d$",
            type = "arena",
            unit = "unit",
        },
    },
    ["Plexus"] = {
        {
            frame = "^PlexusLayoutHeader%d%a%d+UnitButton%d%d?$",
            type = "raid",
            unit = "unit",
        },
    },
    ["InvenRaidFrames3"] = {
        {
            frame = "^InvenRaidFrames3Group%dUnitButton(%d+)$",
            type = "raid",
            unit = "displayedUnit",
        },
        {
            frame = "^InvenRaidFrames3Pet_PetHeaderUnitButton(%d+)$",
            type = "pet",
            unit = "unit",
        },
    },
    ["ShadowUF"] = {
        {
            frame = "^SUFHeaderraid%dUnitButton%d+$",
            type = "raid",
            unit = "unit",
        },
        {
            frame = "^SUFHeaderpartyUnitButton%d$",
            type = "party",
            unit = "unit",
        },
        {
            frame = "^SUFUnitplayer$",
            type = "player",
            unit = "unit",
        },
    },
    ["Cell"] = {
        {
            frame = "^CellPartyFrameMember%d$",
            type = "party",
            unit = "unit",
        },
        {
            frame = "^CellRaidFrameMember%d+$",
            type = "raid",
            unit = "unit",
        },
    },
    ["Aptechka"] = {
        {
            frame = "^AptechkaUnitFrame%d+$",
            type = "raid",
            unit = "unit",
        },
    },
    ["KkthnxUI"] = {
        {
            frame = "^oUF_Raid%d+UnitButton%d+$",
            type = "raid",
            unit = "unit",
        },
        {
            frame = "^oUF_PartyUnitButton%d$",
            type = "party",
            unit = "unit",
        },
    },
}

if not CompactRaidFrameContainer then
    addonFrameInfo.CompactRaidFrame = nil
end

function VUIBuffs:CheckForSupportedAddons()
    enabledPatterns = {}
    for addon, info in pairs(addonFrameInfo) do
        if IsAddOnLoaded(addon) then
            for _, pattern in pairs(info) do
                framesToFind[pattern.frame] = pattern
                enabledPatterns[pattern.frame] = pattern
            end
        end
    end

    addOnsExist = next(enabledPatterns) ~= nil
end

function VUIBuffs:AddFrame(frame, pattern)
    local unitDataKey = pattern.unit
    local useParent = pattern.useParent

    if useParent and frame:GetParent() then
        frame = frame:GetParent()
    end

    if not frame[unitDataKey] or not frame[unitDataKey]:match("^raid%d+$") and not frame[unitDataKey]:match("^party%d$") and
        not frame[unitDataKey]:match("^arena%d$") and not frame[unitDataKey]:match("^player$") and
        not frame[unitDataKey]:match("^playerpet$") and not frame[unitDataKey]:match("^raidpet%d+$") then
        return
    end

    if not self.frames[frame] then
        self.frames[frame] = {}
    end

    tempFrameCache[frame] = nil
    self.frames[frame].pattern = pattern
end

function VUIBuffs:ProcessNewFrames(frame)
    if not frame:GetName() then
        return
    end

    for framePattern, pattern in pairs(framesToFind) do
        if frame:GetName():match(framePattern) then
            tempFrameCache[frame] = pattern
            return
        end
    end
end

function VUIBuffs:CollectNewFrames()
    wipe(tempFrameCache)

    if not addOnsExist then
        return
    end

    local isInThrottledSection = self.barDisplayUpdateThrottled
    if isInThrottledSection then
        -- Only refresh existing frames
        for frame, pattern in pairs(tempFrameCache) do
            self:AddFrame(frame, pattern)
        end
        return
    end

    local frameCache = {}
    local frameCount = 0

    -- Collect all frames
    for i = 1, 5000 do
        local frame = _G["ElvUF_Raid" .. i]
        if frame then
            frameCache[frame] = true
            frameCount = frameCount + 1
        end
    end

    for name, obj in pairs(_G) do
        if type(obj) == "table" and obj.GetObjectType and obj:GetObjectType() == "Button" and obj:GetName() then
            frameCache[obj] = true
            frameCount = frameCount + 1
        end
    end

    -- Process collected frames
    for frame in pairs(frameCache) do
        self:ProcessNewFrames(frame)
    end

    for frame, pattern in pairs(tempFrameCache) do
        self:AddFrame(frame, pattern)
    end

    wipe(tempFrameCache)
end