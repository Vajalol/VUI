local Module = VUI:NewModule("CastBars.Player");

function Module:OnEnable()
    local db = VUI.db.profile.castbars

    if (db.style == 'Custom') then
        -- Create latency display
        if not PlayerCastingBarFrame.LatencyBar then
            PlayerCastingBarFrame.LatencyBar = PlayerCastingBarFrame:CreateTexture(nil, "OVERLAY")
            PlayerCastingBarFrame.LatencyBar:SetHeight(18)
            PlayerCastingBarFrame.LatencyBar:SetTexture(VUI.db.profile.general.texture or [[Interface\Addons\VUI\Media\Textures\Status\Smooth.blp]])
            PlayerCastingBarFrame.LatencyBar:SetVertexColor(1, 0, 0, 0.5) -- Red with 50% transparency
            PlayerCastingBarFrame.LatencyBar:Hide()
            
            -- Create latency text
            PlayerCastingBarFrame.LatencyText = PlayerCastingBarFrame:CreateFontString(nil, "OVERLAY")
            PlayerCastingBarFrame.LatencyText:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
            PlayerCastingBarFrame.LatencyText:SetTextColor(1, 1, 1)
            PlayerCastingBarFrame.LatencyText:SetPoint("LEFT", PlayerCastingBarFrame, "LEFT", 3, 0)
            PlayerCastingBarFrame.LatencyText:Hide()
            
            -- Create target text
            PlayerCastingBarFrame.TargetText = PlayerCastingBarFrame:CreateFontString(nil, "OVERLAY")
            PlayerCastingBarFrame.TargetText:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
            PlayerCastingBarFrame.TargetText:SetTextColor(1, 1, 1)
            PlayerCastingBarFrame.TargetText:SetPoint("RIGHT", PlayerCastingBarFrame, "RIGHT", -3, 0)
            PlayerCastingBarFrame.TargetText:Hide()
        end

        -- Main castbar customization
        PlayerCastingBarFrame:HookScript("OnEvent", function(self, event, ...)
            -- Only customize on specific events
            if event ~= "UNIT_SPELLCAST_START" and 
               event ~= "UNIT_SPELLCAST_STOP" and 
               event ~= "UNIT_SPELLCAST_CHANNEL_START" and 
               event ~= "UNIT_SPELLCAST_CHANNEL_STOP" and 
               event ~= "UNIT_SPELLCAST_CHANNEL_UPDATE" and 
               event ~= "UNIT_SPELLCAST_DELAYED" and 
               event ~= "UNIT_SPELLCAST_INTERRUPTIBLE" and 
               event ~= "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" and
               event ~= "PLAYER_ENTERING_WORLD" then
                return
            end
            
            -- Basic styling
            self.StandardGlow:Hide()
            self.TextBorder:Hide()
            self:SetSize(209, 18)
            self.TextBorder:ClearAllPoints()
            self.TextBorder:SetAlpha(0)
            self.Border:ClearAllPoints()
            self.Border:SetAlpha(0)
            self.Text:ClearAllPoints()
            self.Text:SetPoint("TOP", self, "TOP", 0, -1)
            self.Text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")

            if VUI:Color() then
                self.Background:SetVertexColor(unpack(VUI:Color(0.15)))
            end

            -- Spell icon
            if db.icon then
                self.Icon:Show()
                self.Icon:SetSize(20, 20)
            else
                self.Icon:Hide()
            end
        end)
        
        -- Track when the cast updates
        PlayerCastingBarFrame:HookScript("OnUpdate", function(self, elapsed)
            -- Don't do anything if castbar isn't showing
            if not self:IsShown() then
                self.LatencyBar:Hide()
                self.LatencyText:Hide()
                self.TargetText:Hide()
                return
            end
            
            -- Handle latency display
            if db.latency then
                local _, _, _, startTime, endTime = UnitCastingInfo("player")
                local _, _, _, _, endTimeChannel = UnitChannelInfo("player")
                
                -- Display for casting spells
                if startTime and endTime then
                    local latency = select(4, GetNetStats()) / 1000 -- Convert ms to seconds
                    if latency > 0 then
                        local castLength = (endTime - startTime) / 1000
                        local latencyPercent = latency / castLength
                        
                        -- Position the latency bar at the end of the cast bar
                        self.LatencyBar:ClearAllPoints()
                        self.LatencyBar:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
                        self.LatencyBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
                        self.LatencyBar:SetWidth(self:GetWidth() * latencyPercent)
                        self.LatencyBar:Show()
                        
                        -- Show the latency text
                        self.LatencyText:SetText(string.format("%dms", latency * 1000))
                        self.LatencyText:Show()
                    else
                        self.LatencyBar:Hide()
                        self.LatencyText:Hide()
                    end
                -- Display for channeling spells
                elseif endTimeChannel then
                    local latency = select(4, GetNetStats()) / 1000
                    if latency > 0 then
                        self.LatencyText:SetText(string.format("%dms", latency * 1000))
                        self.LatencyText:Show()
                    else
                        self.LatencyBar:Hide()
                        self.LatencyText:Hide()
                    end
                else
                    self.LatencyBar:Hide()
                    self.LatencyText:Hide()
                end
            else
                self.LatencyBar:Hide()
                self.LatencyText:Hide()
            end
            
            -- Handle target name display
            if db.targetname then
                -- Get the current target of the spell
                local target = UnitExists("target") and UnitName("target") or nil
                if target then
                    -- Truncate long names
                    if #target > 12 then
                        target = string.sub(target, 1, 10) .. ".."
                    end
                    
                    local _, className = UnitClass("target")
                    if className and RAID_CLASS_COLORS[className] then
                        local color = RAID_CLASS_COLORS[className]
                        self.TargetText:SetText(string.format("|cff%02x%02x%02x%s|r", 
                            color.r * 255, color.g * 255, color.b * 255, target))
                    else
                        self.TargetText:SetText(target)
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
