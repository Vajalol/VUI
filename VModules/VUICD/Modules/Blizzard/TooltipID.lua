local AddOnName, NS = ...

-- Use global reference pattern to avoid load order issues
_G["VUICD"] = _G["VUICD"] or {}
local VUICD = _G["VUICD"]

-- Initialize properties that are referenced
VUICD.postDF = VUICD.postDF or (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
VUICD.TocVersion = VUICD.TocVersion or select(4, GetBuildInfo())

-- Create the tooltip frame
local TT = CreateFrame("Frame")

local strmatch = strmatch
local UnitBuff, UnitDebuff, UnitAura = UnitBuff, UnitDebuff, UnitAura
local C_TooltipInfo_GetUnitDebuffByAuraInstanceID = C_TooltipInfo and C_TooltipInfo.GetUnitDebuffByAuraInstanceID
local C_TooltipInfo_GetUnitBuffByAuraInstanceID = C_TooltipInfo and C_TooltipInfo.GetUnitBuffByAuraInstanceID
local C_UnitAuras_GetAuraDataByIndex = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
local GetItemInfoInstant = C_Item and C_Item.GetItemInfoInstant

local ID_TYPE = {
	["HELPFUL"] = "Buff ID:",
	["HARMFUL"] = "Debuff ID:",
	["SPELL"] = "Spell ID:",
	["ITEM"] = "Item ID:",
}

local function AppendID(tooltip, id, strType)
	for i = 1, 15 do
		local frame = _G[tooltip:GetName() .. "TextLeft" .. i]
		local text = frame and frame:GetText()

		if not text then break end
		if strmatch(text, strType) then
			return
		end
	end

	tooltip:AddLine("\n" .. strType .. " |cff33ff99" .. id, 1, 1, 1, true)
	tooltip:Show()
end

local AddAuraID = VUICD.postDF and function(self, unit, slotNumber, auraType)
	local auraData = C_UnitAuras_GetAuraDataByIndex(unit, slotNumber, auraType)
	if auraData and auraData.spellId and auraData.name then
	    AppendID(self, auraData.spellId, ID_TYPE[auraType])
	end
end or function(self, unit, slotNumber, auraType)
	if auraType == "HELPFUL" or auraType == "HARMFUL" then
		local _,_,_,_,_,_,_,_,_, id = UnitAura(unit, slotNumber, auraType)
		if id then AppendID(self, id, ID_TYPE[auraType]) end
	end
end

local AddBuffID = VUICD.postDF and function(self, unitTokenString, auraInstanceID)
	local data = C_TooltipInfo_GetUnitBuffByAuraInstanceID(unitTokenString, auraInstanceID)
	local id
	if VUICD.TocVersion >= 100100 then
		id = data.id
	else
		id = data.args and data.args[2] and data.args[2].intVal
	end
	if id then AppendID(self, id, ID_TYPE.HELPFUL) end
end or function(self, ...)
	local id = select(10, UnitBuff(...))
	if id then AppendID(self, id, ID_TYPE.HELPFUL) end
end

local AddDebuffID = VUICD.postDF and function(self, unitTokenString, auraInstanceID)
	local data = C_TooltipInfo_GetUnitDebuffByAuraInstanceID(unitTokenString, auraInstanceID)
	if not data then
		return
	end
	local id
	if VUICD.TocVersion >= 100100 then
		id = data.id
	else
		id = data.args and data.args[2] and data.args[2].intVal
	end
	if id then AppendID(self, id, ID_TYPE.HARMFUL) end
end or function(self, ...)
	local id = select(10, UnitDebuff(...))
	if id then AppendID(self, id, ID_TYPE.HARMFUL) end
end

local function AddSpellID(tooltip)
	if (tooltip == GameTooltip or tooltip == EmbeddedItemTooltip) then
		local _, id = tooltip:GetSpell()
		if id then AppendID(tooltip, id, ID_TYPE.SPELL) end
	end
end

local function AddItemID(tooltip)
	if (tooltip == GameTooltip or tooltip == ItemRefTooltip) then
		local _, itemLink = tooltip:GetItem()
		if itemLink then
			local id = GetItemInfoInstant(itemLink)
			if id then AppendID(tooltip, id, ID_TYPE.ITEM) end
		end
	end
end

-- More robust method for tooltip hooking that works across WoW API changes
function TT:SafeHookTooltips()
    -- These are the possible script names across different WoW versions
    local scriptHooks = {
        item = {"OnTooltipSetItem", "TooltipDataItem"},
        spell = {"OnTooltipSetSpell", "TooltipDataSpell"}
    }
    
    -- Try to use TooltipDataProcessor if available (DF)
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
        if Enum and Enum.TooltipDataType then
            if Enum.TooltipDataType.Item then
                TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, AddItemID)
            end
            if Enum.TooltipDataType.Spell then
                TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, AddSpellID)
            end
            
            -- Modern API available, mark as hooked
            TT.tooltipsHooked = true
            return true
        end
    end
    
    -- Try to use HookScript for older API versions
    if GameTooltip.HookScript then
        -- Try to hook item tooltip
        local itemHookSuccess = false
        for _, scriptName in ipairs(scriptHooks.item) do
            local success = pcall(function()
                GameTooltip:HookScript(scriptName, AddItemID)
            end)
            
            if success then
                itemHookSuccess = true
                break
            end
        end
        
        -- Try to hook spell tooltip
        local spellHookSuccess = false
        for _, scriptName in ipairs(scriptHooks.spell) do
            local success = pcall(function()
                GameTooltip:HookScript(scriptName, AddSpellID)
            end)
            
            if success then
                spellHookSuccess = true
                break
            end
        end
        
        -- If either hook succeeded, mark as hooked
        if itemHookSuccess or spellHookSuccess then
            TT.tooltipsHooked = true
            return true
        end
    end
    
    -- Ultimate fallback: use secure hooks instead of script hooks
    if hooksecurefunc then
        -- Hook item functions
        hooksecurefunc(GameTooltip, "SetItem", AddItemID)
        hooksecurefunc(GameTooltip, "SetHyperlink", AddItemID)
        hooksecurefunc(GameTooltip, "SetBagItem", AddItemID)
        hooksecurefunc(GameTooltip, "SetInventoryItem", AddItemID)
        hooksecurefunc(GameTooltip, "SetTradePlayerItem", AddItemID)
        hooksecurefunc(GameTooltip, "SetTradeTargetItem", AddItemID)
        hooksecurefunc(GameTooltip, "SetLootItem", AddItemID)
        
        -- Hook spell functions
        hooksecurefunc(GameTooltip, "SetSpellByID", AddSpellID)
        hooksecurefunc(GameTooltip, "SetSpellBookItem", AddSpellID)
        
        -- Mark as hooked
        TT.tooltipsHooked = true
        return true
    end
    
    -- Could not hook tooltips
    TT.tooltipsHooked = false
    return false
end

function TT:Enable()
	if TT.hooked then
		return
	end
	hooksecurefunc(GameTooltip, "SetUnitAura", AddAuraID)
	if VUICD.postDF then
		hooksecurefunc(GameTooltip, "SetUnitBuffByAuraInstanceID", AddBuffID)
		hooksecurefunc(GameTooltip, "SetUnitDebuffByAuraInstanceID", AddDebuffID)
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, AddSpellID)
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.PetAction, AddSpellID)
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, AddItemID)
	else
		hooksecurefunc(GameTooltip, "SetUnitBuff", AddBuffID)
		hooksecurefunc(GameTooltip, "SetUnitDebuff", AddDebuffID)
		
		-- Use the robust SafeHookTooltips method to handle different client versions
		self:SafeHookTooltips()
	end
	TT.hooked = true
end

VUICD["TooltipID"] = TT
