-- Ensure VUI is available or create a minimal version
if not _G.VUI then
    _G.VUI = {}
end

-- Use the resilient module creation pattern
local User = VUI:TryCreateModule('Data.Users')

-- Safely get colors or create default placeholder
local Colors = {}
if VUI.GetModule then
    Colors = VUI:GetModule('Data.Colors') or {}
else
    -- Default color codes for class colors if module isn't available
    Colors = {
        aut = "|cffea00ff", -- author color (purple)
        rog = "|cffffff00", -- rogue color (yellow)
        warri = "|cffc79c6e", -- warrior color (tan)
        druid = "|cffff7d0a", -- druid color (orange)
        dk = "|cffc41f3b", -- death knight color (red)
        monk = "|cff00ff96", -- monk color (green)
        sham = "|cff0070de", -- shaman color (blue)
        priest = "|cffffffff", -- priest color (white)
        hunter = "|cffa9d271", -- hunter color (green)
        lock = "|cff9482c9", -- warlock color (purple)
        pala = "|cfff58cba", -- paladin color (pink)
        dh = "|cffa330c9"  -- demon hunter color (purple)
    }
end

User.team = {
    { text = Colors.aut .. 'VortexQ8|r' },
}

User.specials = {
    { text = Colors.rog .. 'Holyface|r' },
    { text = Colors.warri .. 'TwistyQ8|r' },
    { text = Colors.druid .. 'Adroenz|r' },
    { text = Colors.dk .. 'Elcamelum|r' },
    { text = Colors.monk .. 'HolaRinga|r' },
    { text = Colors.sham .. 'Foolmedames|r' },
    { text = Colors.priest .. 'Huf|r' },
    { text = Colors.hunter .. 'Yazo|r' },
    { text = Colors.lock .. 'Reko|r' },
    { text = Colors.warri .. 'Nano|r' },
    { text = Colors.warri .. 'Chili|r' },
}

User.supporter = {
    { text = Colors.pala .. 'Imbact|r' },
    { text = Colors.rog .. 'Exit|r' },
    { text = Colors.priest .. 'Sky|r' },
    { text = Colors.pala .. 'Pix|r' },
    { text = Colors.druid .. 'Souilkiller|r' },
    { text = Colors.rog .. 'Boildegg|r' },
    { text = Colors.pala .. 'AdmiralFahood|r' },
    { text = Colors.rog .. 'Omid|r' },
    { text = Colors.dk .. 'Cursed4eva|r' },
    { text = Colors.dh .. 'Law|r' },
    { text = Colors.priest .. 'Nino_s04|r' },
    { text = Colors.dk .. 'Zimmy|r' },
}

User.banned = {}
