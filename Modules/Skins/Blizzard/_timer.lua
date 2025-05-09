local Module = VUI:NewModule("Skins.Timer");

function Module:OnEnable()
    if (VUI:Color()) then
        TimerTracker:HookScript("OnEvent", function(self, event, timerType, timeSeconds, totalTime)
            for i = 1, #self.timerList do
                _G['TimerTrackerTimer' .. i .. 'StatusBarBorder']:SetVertexColor(unpack(VUI:Color(0.15)))
            end
        end)
        for _, region in pairs({ StopwatchFrame:GetRegions() }) do
            region:SetVertexColor(unpack(VUI:Color(0.15)))
        end
    end
end
