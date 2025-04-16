-- VUI Media handling

-- Register addon with LibSharedMedia if available
function VUI:RegisterMedia()
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    
    if LSM then
        -- Register fonts
        LSM:Register("font", "Expressway", [[Interface\AddOns\VUI\media\fonts\expressway.ttf]])
        
        -- Register statusbar textures
        LSM:Register("statusbar", "VUI Smooth", [[Interface\AddOns\VUI\media\textures\statusbar.tga]])
        
        -- Register sounds
        -- LSM:Register("sound", "VUI Alert", [[Interface\AddOns\VUI\media\sounds\alert.ogg]])
        
        -- Register backgrounds
        -- LSM:Register("background", "VUI Background", [[Interface\AddOns\VUI\media\textures\background.tga]])
        
        -- Register borders
        -- LSM:Register("border", "VUI Border", [[Interface\AddOns\VUI\media\textures\border.tga]])
    end
end

-- Load media files and prepare them for use
function VUI:LoadMedia()
    -- Register with LSM if available
    self:RegisterMedia()
    
    -- Create media table for direct access
    self.media = {
        fonts = {
            expressway = [[Interface\AddOns\VUI\media\fonts\expressway.ttf]],
            normal = GameFontNormal:GetFont(),
            bold = GameFontHighlight:GetFont()
        },
        textures = {
            statusbar = [[Interface\AddOns\VUI\media\textures\statusbar.tga]],
            blank = [[Interface\Buttons\WHITE8x8]],
            gloss = [[Interface\AddOns\VUI\media\textures\gloss.tga]]
        },
        colors = {
            primary = {0.09, 0.51, 0.82}, -- #1784d1
            secondary = {0.9, 0.3, 0.3},
            class = {},
            reaction = {
                [1] = {0.87, 0.37, 0.37}, -- Hated
                [2] = {0.87, 0.37, 0.37}, -- Hostile
                [3] = {0.87, 0.37, 0.37}, -- Unfriendly
                [4] = {0.85, 0.77, 0.36}, -- Neutral
                [5] = {0.29, 0.67, 0.30}, -- Friendly
                [6] = {0.29, 0.67, 0.30}, -- Honored
                [7] = {0.29, 0.67, 0.30}, -- Revered
                [8] = {0.29, 0.67, 0.30}, -- Exalted
            }
        }
    }
    
    -- Add class colors
    for k, v in pairs(RAID_CLASS_COLORS) do
        self.media.colors.class[k] = {v.r, v.g, v.b}
    end
    
    -- Build texture path list for dropdown selection
    self.textureList = {"Smooth", "Flat", "Gloss", "Gradient"}
    
    -- Build font list for dropdown selection
    self.fontList = {"Expressway", "Friz Quadrata", "Arial Narrow", "Morpheus"}
end

-- Get color function for convenience
function VUI:GetColor(name, class)
    if class and self.media.colors.class[class] then
        return unpack(self.media.colors.class[class])
    elseif self.media.colors[name] then
        return unpack(self.media.colors[name])
    else
        return 1, 1, 1
    end
end

-- Get texture path function for convenience
function VUI:GetTexture(name)
    if self.media.textures[name] then
        return self.media.textures[name]
    else
        return self.media.textures.statusbar
    end
end

-- Get font path function for convenience
function VUI:GetFont(name)
    if self.media.fonts[name] then
        return self.media.fonts[name]
    else
        return self.media.fonts.expressway
    end
end

-- Color conversion functions
function VUI:RGBToHex(r, g, b)
    if type(r) == "table" then
        g = r[2]
        b = r[3]
        r = r[1]
    end
    return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

function VUI:HexToRGB(hex)
    hex = hex:gsub("|cff", ""):gsub("|r", "")
    return tonumber("0x"..hex:sub(1,2))/255, tonumber("0x"..hex:sub(3,4))/255, tonumber("0x"..hex:sub(5,6))/255
end
