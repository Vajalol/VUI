local Module = VUI:NewModule("Skins.Calendar");

function Module:OnEnable()
    if (VUI:Color()) then
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, name)
            if name == "Blizzard_Calendar" then
                VUI:Skin(CalendarFrame, true)
                VUI:Skin(CalendarCreateEventFrame, true)
                VUI:Skin(CalendarCreateEventFrame.Header, true)
                VUI:Skin(CalendarCreateEventFrame.Border, true)
                VUI:Skin(CalendarViewHolidayFrame, true)
                VUI:Skin(CalendarViewHolidayFrame.Header, true)
                VUI:Skin(CalendarViewHolidayFrame.Border, true)
                VUI:Skin({
                    CalendarCreateEventDivider,
                    CalendarCreateEventFrameButtonBackground,
                    CalendarCreateEventMassInviteButtonBorder,
                    CalendarCreateEventCreateButtonBorder
                }, true, true)
            end
        end)
    end
end
