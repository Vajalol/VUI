-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

if GetLocale() ~= "zhTW" then return end

-- Chinese (Traditional) localization
-- Values set to true use the English default

-- General
L["VUI Gfinder"] = "VUI 團隊查找器"
L["Enhances the Group Finder with advanced filtering"] = "通過高級篩選增強團隊查找器"

-- UI Text
L["Enable"] = "啟用"
L["Open Filter Dialog"] = "打開篩選對話框"
L["Dialog Scale"] = "對話框縮放"
L["Enhanced Tooltips"] = "增強工具提示"
L["One-Click Sign Up"] = "一鍵報名"
L["Remember Sign Up Notes"] = "記住報名備註"
L["Sign Up on Enter"] = "按回車鍵報名"
L["Show Filter Button"] = "顯示篩選按鈕"

-- Advanced Filter
L["Enable Advanced Mode"] = "啟用高級模式"
L["Filter Expression"] = "篩選表達式"
L["Enable Custom Sorting"] = "啟用自定義排序"
L["Sorting Expression"] = "排序表達式"

-- Difficulties
L["Normal"] = "普通"
L["Heroic"] = "英雄"
L["Mythic"] = "傳奇"
L["Mythic+"] = "傳奇+"
L["Arena 2v2"] = "競技場 2v2"
L["Arena 3v3"] = "競技場 3v3"

-- Dialog
L["Minimum Difficulty"] = "最低難度"
L["Maximum Difficulty"] = "最高難度"
L["Min Mythic+ Level"] = "最低傳奇+等級"
L["Max Mythic+ Level"] = "最高傳奇+等級"
L["Min Rating"] = "最低評級"
L["Max Rating"] = "最高評級"
L["Find Groups"] = "查找隊伍"
L["Reset Filters"] = "重置篩選"
L["Close"] = "關閉"

-- Tooltip
L["Group Details"] = "隊伍詳情"
L["Activity"] = "活動"
L["Difficulty"] = "難度"
L["Leader Score"] = "隊長評分"
L["Members"] = "成員"
L["Created"] = "創建時間"
L["ago"] = "前"

-- Categories
L["Dungeon"] = "地城"
L["Raid"] = "團隊副本"
L["Arena"] = "競技場"
L["Rated Battleground"] = "積分戰場"

-- Roles
L["Tank"] = "坦克"
L["Healer"] = "補師"
L["DPS"] = "傷害輸出"

-- Misc
L["Advanced Filtering"] = "高級篩選"
L["Use Expression"] = "使用表達式"
L["Expression Help"] = "表達式幫助"