-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

if GetLocale() ~= "zhCN" then return end

-- Chinese (Simplified) localization
-- Values set to true use the English default

-- General
L["VUI Gfinder"] = "VUI 团队查找器"
L["Enhances the Group Finder with advanced filtering"] = "通过高级筛选增强团队查找器"

-- UI Text
L["Enable"] = "启用"
L["Open Filter Dialog"] = "打开筛选对话框"
L["Dialog Scale"] = "对话框缩放"
L["Enhanced Tooltips"] = "增强工具提示"
L["One-Click Sign Up"] = "一键报名"
L["Remember Sign Up Notes"] = "记住报名备注"
L["Sign Up on Enter"] = "按回车键报名"
L["Show Filter Button"] = "显示筛选按钮"

-- Advanced Filter
L["Enable Advanced Mode"] = "启用高级模式"
L["Filter Expression"] = "筛选表达式"
L["Enable Custom Sorting"] = "启用自定义排序"
L["Sorting Expression"] = "排序表达式"

-- Difficulties
L["Normal"] = "普通"
L["Heroic"] = "英雄"
L["Mythic"] = "史诗"
L["Mythic+"] = "史诗+"
L["Arena 2v2"] = "竞技场 2v2"
L["Arena 3v3"] = "竞技场 3v3"

-- Dialog
L["Minimum Difficulty"] = "最低难度"
L["Maximum Difficulty"] = "最高难度"
L["Min Mythic+ Level"] = "最低史诗+等级"
L["Max Mythic+ Level"] = "最高史诗+等级"
L["Min Rating"] = "最低评级"
L["Max Rating"] = "最高评级"
L["Find Groups"] = "查找队伍"
L["Reset Filters"] = "重置筛选"
L["Close"] = "关闭"

-- Tooltip
L["Group Details"] = "队伍详情"
L["Activity"] = "活动"
L["Difficulty"] = "难度"
L["Leader Score"] = "队长评分"
L["Members"] = "成员"
L["Created"] = "创建时间"
L["ago"] = "前"

-- Categories
L["Dungeon"] = "地下城"
L["Raid"] = "团队副本"
L["Arena"] = "竞技场"
L["Rated Battleground"] = "评级战场"

-- Roles
L["Tank"] = "坦克"
L["Healer"] = "治疗"
L["DPS"] = "伤害"

-- Misc
L["Advanced Filtering"] = "高级筛选"
L["Use Expression"] = "使用表达式"
L["Expression Help"] = "表达式帮助"