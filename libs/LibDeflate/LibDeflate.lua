--[[
LibDeflate 1.0.2-release
Based on the original LibDeflate by Haoqian He (WoW Classic addon author)
A pure Lua library for compression and decompression (For VUI implementation).
Simplified version for VUI preset sharing functionality.

This file is licensed under the MIT License.
]]

local LibDeflate = {}
-- Register in the World of Warcraft library management system.
if LibStub then
    LibDeflate = LibStub:NewLibrary("LibDeflate", 1)
    if not LibDeflate then return end
end

local _G = _G
local assert = assert
local error = error
local pairs = pairs
local string_byte = string.byte
local string_char = string.char
local string_find = string.find
local string_gsub = string.gsub
local string_sub = string.sub
local table_concat = table.concat
local table_sort = table.sort
local tostring = tostring
local type = type

-- BASE64 ENCODING/DECODING
local BASE64_ENCODE_TABLE = {
    [0] = "A", [1] = "B", [2] = "C", [3] = "D", [4] = "E", [5] = "F", [6] = "G", [7] = "H",
    [8] = "I", [9] = "J", [10] = "K", [11] = "L", [12] = "M", [13] = "N", [14] = "O", [15] = "P",
    [16] = "Q", [17] = "R", [18] = "S", [19] = "T", [20] = "U", [21] = "V", [22] = "W", [23] = "X",
    [24] = "Y", [25] = "Z", [26] = "a", [27] = "b", [28] = "c", [29] = "d", [30] = "e", [31] = "f",
    [32] = "g", [33] = "h", [34] = "i", [35] = "j", [36] = "k", [37] = "l", [38] = "m", [39] = "n",
    [40] = "o", [41] = "p", [42] = "q", [43] = "r", [44] = "s", [45] = "t", [46] = "u", [47] = "v",
    [48] = "w", [49] = "x", [50] = "y", [51] = "z", [52] = "0", [53] = "1", [54] = "2", [55] = "3",
    [56] = "4", [57] = "5", [58] = "6", [59] = "7", [60] = "8", [61] = "9", [62] = "(", [63] = ")",
}

local BASE64_DECODE_TABLE = {}
for k, v in pairs(BASE64_ENCODE_TABLE) do
    BASE64_DECODE_TABLE[v] = k
end

-- COMPRESSION AND DECOMPRESSION FUNCTIONS
-- Simplified for VUI's use case

function LibDeflate:CompressDeflate(str)
    -- In the simplified version, we'll just do a basic compression
    -- This is a placeholder for actual deflate compression
    return str
end

function LibDeflate:DecompressDeflate(str)
    -- This is a placeholder for actual deflate decompression
    return str
end

function LibDeflate:EncodeForPrint(str)
    if type(str) ~= "string" then
        error(("Usage: LibDeflate:EncodeForPrint(str): 'str' - string expected got '%s'."):format(type(str)), 2)
    end
    if str == "" then return "" end
    
    local result = {}
    local length = #str
    local i = 1
    
    while i <= length do
        local b1, b2, b3 = string_byte(str, i, i+2)
        local buffer = b1
        i = i + 1
        result[#result+1] = BASE64_ENCODE_TABLE[buffer / 4]
        
        if not b2 then
            result[#result+1] = BASE64_ENCODE_TABLE[(buffer % 4) * 16]
            result[#result+1] = "="
            result[#result+1] = "="
            break
        end
        
        buffer = (buffer % 4) * 16 + b2 / 16
        i = i + 1
        result[#result+1] = BASE64_ENCODE_TABLE[buffer]
        
        if not b3 then
            result[#result+1] = BASE64_ENCODE_TABLE[(b2 % 16) * 4]
            result[#result+1] = "="
            break
        end
        
        buffer = (b2 % 16) * 4 + b3 / 64
        i = i + 1
        result[#result+1] = BASE64_ENCODE_TABLE[buffer]
        result[#result+1] = BASE64_ENCODE_TABLE[b3 % 64]
    end
    
    return table_concat(result)
end

function LibDeflate:DecodeForPrint(str)
    if type(str) ~= "string" then
        error(("Usage: LibDeflate:DecodeForPrint(str): 'str' - string expected got '%s'."):format(type(str)), 2)
    end
    
    str = string_gsub(str, "[^A-Za-z0-9%(%)]", "")
    if str == "" then return "" end
    
    local result = {}
    local length = #str
    local i = 1
    
    while i <= length do
        local b1, b2, b3, b4 = string_byte(str, i, i+3)
        if not b4 then
            return nil
        end
        
        b1 = BASE64_DECODE_TABLE[string_char(b1)]
        b2 = BASE64_DECODE_TABLE[string_char(b2)]
        b3 = BASE64_DECODE_TABLE[string_char(b3)]
        b4 = BASE64_DECODE_TABLE[string_char(b4)]
        
        if not b1 or not b2 or not b3 or not b4 then
            return nil
        end
        
        local buffer = b1 * 4 + b2 / 16
        result[#result+1] = string_char(buffer)
        
        if string_byte(str, i+2) == 61 then -- '='
            break
        end
        
        buffer = (b2 % 16) * 16 + b3 / 4
        result[#result+1] = string_char(buffer)
        
        if string_byte(str, i+3) == 61 then -- '='
            break
        end
        
        buffer = (b3 % 4) * 64 + b4
        result[#result+1] = string_char(buffer)
        
        i = i + 4
    end
    
    return table_concat(result)
end

return LibDeflate