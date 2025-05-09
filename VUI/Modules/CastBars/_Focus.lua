local Module = VUI:NewModule("CastBars.Focus");

function Module:OnEnable()
    local db = VUI.db.profile.castbars

    if (db.style == 'Custom' and db.focusCastbar) then
        -- Create focus cast latency text
        if not FocusFrameSpellBar.LatencyText then
            FocusFrameSpellBar.LatencyText = FocusFrameSpellBar:CreateFontString(nil, "OVERLAY")
            FocusFrameSpellBar.LatencyText:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
            FocusFrameSpellBar.LatencyText:SetTextColor(1, 1, 1)
            FocusFrameSpellBar.LatencyText:SetPoint("LEFT", FocusFrameSpellBar, "LEFT", 3, 0)
            FocusFrameSpellBar.LatencyText:Hide()
            
            -- Create spell target text
            FocusFrameSpellBar.TargetText = FocusFrameSpellBar:CreateFontString(nil, "OVERLAY")
            FocusFrameSpellBar.TargetText:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
            FocusFrameSpellBar.TargetText:SetTextColor(1, 1, 1)
            FocusFrameSpellBar.TargetText:SetPoint("RIGHT", FocusFrameSpellBar, "RIGHT", -3, 0)
            FocusFrameSpellBar.TargetText:Hide()
        end

        -- Handle castbar position if it should be on top
        if (db.focusOnTop) then
            FocusFrameSpellBar:HookScript("OnUpdate", function(self)
                self:ClearAllPoints()
                self:SetPoint("TOPLEFT", FocusFrame, "TOPLEFT", 45, 0)
            end)
        end

        -- Main castbar customization
        FocusFrameSpellBar:HookScript("OnEvent", function(self, event, ...)
            if self:IsForbidden() then return end
            if InCombatLockdown() then return end

            -- Basic styling
            if db.focusSize then
                self:SetScale(db.focusSize)
            end

            self.Icon:SetSize(16, 16)
            self.Icon:ClearAllPoints()
            self.Icon:SetPoint("TOPLEFT", self, "TOPLEFT", -20, 2)
            self.BorderShield:ClearAllPoints()
            self.BorderShield:SetPoint("CENTER", self.Icon, "CENTER", 0, -2.5)
            self:SetSize(150, 12)
            self.TextBorder:ClearAllPoints()
            self.TextBorder:SetAlpha(0)
            self.Text:ClearAllPoints()
            self.Text:SetPoint("TOP", self, "TOP", 0, 2.5)
            self.Text:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
            
            if VUI:Color() then
                self.Border:SetVertexColor(unpack(VUI:Color(0.15)))
                self.Background:SetVertexColor(unpack(VUI:Color(0.15)))
            end
            
            -- Show/hide spell icon
            if not db.icon then
                self.Icon:Hide()
            end

            -- Truncate long spell names
            local castText = self.Text:GetText()
            if castText ~= nil then
                if (strlen(castText) > 19) then
                    local newCastText = strsub(castText, 0, 19)
                    self.Text:SetText(newCastText .. "...")
                end
            end
        end)
        
        -- Track when the cast updates
        FocusFrameSpellBar:HookScript("OnUpdate", function(self, elapsed)
            -- Don't do anything if castbar isn't showing
            if not self:IsShown() then
                self.LatencyText:Hide()
                self.TargetText:Hide()
                return
            end
            
            -- Handle latency display on focus castbar (shows estimated latency)
            if db.latency then
                local latency = select(4, GetNetStats())
                if latency > 0 then
                    self.LatencyText:SetText(string.format("%dms", latency))
                    self.LatencyText:Show()
                else
                    self.LatencyText:Hide()
                end
            else
                self.LatencyText:Hide()
            end
            
            -- Handle focus's target name display (who the focus is casting at)
            if db.targetname then
                local focusTarget = UnitExists("focustarget") and UnitName("focustarget") or nil
                if focusTarget then
                    -- Truncate long names
                    if #focusTarget > 10 then
                        focusTarget = string.sub(focusTarget, 1, 8) .. ".."
                    end
                    
                    local _, className = UnitClass("focustarget")
                    if className and RAID_CLASS_COLORS[className] then
                        local color = RAID_CLASS_COLORS[className]
                        self.TargetText:SetText(string.format("|cff%02x%02x%02x%s|r", 
                            color.r * 255, color.g * 255, color.b * 255, focusTarget))
                    else
                        self.TargetText:SetText(focusTarget)
                    end
                    self.TargetText:Show()
                else
                    self.TargetText:Hide()
                end
            else
                self.TargetText:Hide()
            end
        end)
    end
end
