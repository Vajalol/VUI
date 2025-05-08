-- VUIAnyFrame - Math Helper Functions
local VUIAnyFrame = LibStub("AceAddon-3.0"):GetAddon("VUIAnyFrame")

-- Math helper functions from MoveAny
function VUIAnyFrame:round(val, decimal)
    if decimal then
        return math.floor((val * 10^decimal) + 0.5) / (10^decimal)
    else
        return math.floor(val + 0.5)
    end
end

function VUIAnyFrame:CalcDecimals(val)
    if not val then return 0 end
    if val == 0 then return 0 end
    
    local num
    num = 0
    if math.floor(val) == val then
        return num
    end
    
    for i = 1, 10 do
        val = val * 10
        num = num + 1
        if math.floor(val) == val then break end
    end
    
    return num
end

function VUIAnyFrame:RGBToHex(r, g, b)
    if type(r) == "table" then
        g = r.g or r[2]
        b = r.b or r[3]
        r = r.r or r[1]
    end
    
    r = r <= 1 and r >= 0 and r or 0
    g = g <= 1 and g >= 0 and g or 0
    b = b <= 1 and b >= 0 and b or 0
    
    return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end