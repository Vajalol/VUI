-- Ensure global VUI exists
if not _G.VUI then
	_G.VUI = {}
end

-- Create an empty module initially
local Module = {}

-- Try to create the module using the available methods
if type(VUI.TryCreateModule) == "function" then
	Module = VUI:TryCreateModule("RaidFrames.Core")
elseif type(VUI.NewModule) == "function" then 
	Module = VUI:NewModule("RaidFrames.Core")
else
	-- Fallback if module creation is not available yet
	VUI.RaidFramesCore = VUI.RaidFramesCore or Module
	
	-- Retry after a delay
	C_Timer.After(1, function()
		if type(VUI.NewModule) == "function" then
			local realModule = VUI:NewModule("RaidFrames.Core")
			-- Copy any properties that might have been set
			for k, v in pairs(Module) do
				if k ~= "OnEnable" and k ~= "OnDisable" and k ~= "OnInitialize" then
					realModule[k] = v
				end
			end
			-- Replace the reference
			VUI.RaidFramesCore = realModule
			
			-- Call OnEnable if it was defined
			if realModule.OnEnable then
				realModule:OnEnable()
			end
		end
	end)
end

function Module:OnEnable()
	-- Make sure VUI and its database are available
	if not VUI or not VUI.db or not VUI.db.profile or not VUI.db.profile.raidframes then
		-- Try again after a short delay if VUI isn't fully initialized
		C_Timer.After(0.5, function()
			if VUI and VUI.db and VUI.db.profile and VUI.db.profile.raidframes then
				self:OnEnable()
			end
		end)
		return
	end
	
	local db = VUI.db.profile.raidframes
	if db then
		local function updateTextures(self)
			if self:IsForbidden() then return end
			if self and self:GetName() then
				local name = self:GetName()
				if name and name:match("^Compact") then
					if self:IsForbidden() then return end
					if db.texture ~= [[Interface\Default]] then
						self.healthBar:SetStatusBarTexture(db.texture)
						self.healthBar:GetStatusBarTexture():SetDrawLayer("BORDER")
						self.powerBar:SetStatusBarTexture(db.texture)
						self.powerBar:GetStatusBarTexture():SetDrawLayer("BORDER")
						self.myHealPrediction:SetTexture(db.texture)
						self.otherHealPrediction:SetTexture(db.texture)
					end

					if name:find('CompactPartyFrame') then
						if VUI.Color and type(VUI.Color) == "function" then
							self.horizDivider:SetVertexColor(.3, .3, .3)
							for _, region in pairs({ CompactPartyFrameBorderFrame:GetRegions() }) do
								if region:IsObjectType("Texture") then
									local color = VUI:Color(0.15) or {0.15, 0.15, 0.15, 1.0}
									region:SetVertexColor(unpack(color))
								end
							end
						end
					end

					self.vertLeftBorder:Hide()
					self.vertRightBorder:Hide()
					self.horizTopBorder:Hide()
					self.horizBottomBorder:Hide()
				end
			end
		end

		hooksecurefunc("CompactUnitFrame_UpdateAll", function(self)
			updateTextures(self)
		end)

		local function updateSize(self)
			if self:IsForbidden() then return end
			if self and self:GetName() then
				local name = self:GetName()

				if name and name:match("^CompactPartyFrameMember") then
					if not InCombatLockdown() then
						self:SetWidth(db.width)
						self:SetHeight(db.height)
						self.statusText:ClearAllPoints()
						self.statusText:SetPoint("CENTER", self, "CENTER")
						self.centerStatusIcon:ClearAllPoints()
						self.centerStatusIcon:SetPoint("CENTER", self, "CENTER")
					end
				elseif name and name:match("^CompactPartyFramePet") then
					if self:IsForbidden() then return end
					if not InCombatLockdown() then
						self:SetWidth(db.width)
					end
				end
			end
		end

		-- Hide Titles
		CompactPartyFrameTitle:Hide()

		-- Update PartyFrame Size
		if (db.size) then
			local eventFrame = CreateFrame("Frame")
			eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
			eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
			eventFrame:SetScript("OnEvent", function(_, event)
				local partyFrames = {
					CompactPartyFrameMember1,
					CompactPartyFrameMember2,
					CompactPartyFrameMember3,
					CompactPartyFrameMember4,
					CompactPartyFrameMember5
				}

				if event == "PLAYER_REGEN_DISABLED" then
					CompactPartyFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
					for i = 1, #partyFrames do
						partyFrames[i]:UnregisterEvent("UNIT_PET")
					end
				else
					CompactPartyFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
					for i = 1, #partyFrames do
						partyFrames[i]:RegisterEvent("UNIT_PET")
						updateSize(partyFrames[i])
					end
				end
			end)

			hooksecurefunc("CompactUnitFrame_UpdateAll", function(self)
				updateSize(self)
			end)
		end
	end
end