local Module = VUI:NewModule("UnitFrames.Boss");
function Module:OnEnable()
    local db = VUI.db.profile.general
    function VUIBossFrames(self, event)
        if self then
            if self.healthbar then
                self.healthbar:SetStatusBarTexture(db.texture)
            end

            if self.TargetFrameContent.TargetFrameContentMain.ReputationColor and VUI:Color() then
                self.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetVertexColor(unpack(VUI:Color(0.15)))
            end
        end
    end

    --hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", VUIBossFramesText)
    Boss1TargetFrame:HookScript("OnEvent", function(self, event)
        VUIBossFrames(self, event)
    end)

    Boss2TargetFrame:HookScript("OnEvent", function(self, event)
        VUIBossFrames(self, event)
    end)

    Boss3TargetFrame:HookScript("OnEvent", function(self, event)
        VUIBossFrames(self, event)
    end)

    Boss4TargetFrame:HookScript("OnEvent", function(self, event)
        VUIBossFrames(self, event)
    end)

    Boss5TargetFrame:HookScript("OnEvent", function(self, event)
        VUIBossFrames(self, event)
    end)
end
