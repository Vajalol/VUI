-- LibSharedMedia-3.0 placeholder
local MAJOR, MINOR = "LibSharedMedia-3.0", 1
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

lib.MediaType = {
    BACKGROUND = "background",
    BORDER = "border",
    FONT = "font",
    STATUSBAR = "statusbar",
    SOUND = "sound",
}

function lib:Register(mediatype, key, data, langmask)
    -- Placeholder function that would normally register media with the library
    return
end

function lib:Fetch(mediatype, key, noDefault)
    -- Placeholder function that would normally fetch media from the library
    if mediatype == "font" then
        return "Fonts\\FRIZQT__.TTF"
    elseif mediatype == "statusbar" then
        return "Interface\\TargetingFrame\\UI-StatusBar"
    else
        return ""
    end
end

function lib:IsValid(mediatype, key)
    -- Placeholder function that would normally check if media is valid
    return true
end