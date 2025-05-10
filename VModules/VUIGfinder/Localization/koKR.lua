-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

if GetLocale() ~= "koKR" then return end

-- Korean localization
-- Values set to true use the English default

-- General
L["VUI Gfinder"] = "VUI Gfinder"
L["Enhances the Group Finder with advanced filtering"] = "고급 필터링으로 그룹 찾기를 강화합니다"

-- UI Text
L["Enable"] = "활성화"
L["Open Filter Dialog"] = "필터 대화 상자 열기"
L["Dialog Scale"] = "대화 상자 크기"
L["Enhanced Tooltips"] = "향상된 툴팁"
L["One-Click Sign Up"] = "원클릭 가입"
L["Remember Sign Up Notes"] = "가입 메모 기억"
L["Sign Up on Enter"] = "엔터로 가입"
L["Show Filter Button"] = "필터 버튼 표시"

-- Advanced Filter
L["Enable Advanced Mode"] = "고급 모드 활성화"
L["Filter Expression"] = "필터 표현식"
L["Enable Custom Sorting"] = "사용자 정의 정렬 활성화"
L["Sorting Expression"] = "정렬 표현식"

-- Difficulties
L["Normal"] = "일반"
L["Heroic"] = "영웅"
L["Mythic"] = "신화"
L["Mythic+"] = "신화+"
L["Arena 2v2"] = "투기장 2v2"
L["Arena 3v3"] = "투기장 3v3"

-- Dialog
L["Minimum Difficulty"] = "최소 난이도"
L["Maximum Difficulty"] = "최대 난이도"
L["Min Mythic+ Level"] = "최소 신화+ 레벨"
L["Max Mythic+ Level"] = "최대 신화+ 레벨"
L["Min Rating"] = "최소 점수"
L["Max Rating"] = "최대 점수"
L["Find Groups"] = "그룹 찾기"
L["Reset Filters"] = "필터 초기화"
L["Close"] = "닫기"

-- Tooltip
L["Group Details"] = "그룹 세부 정보"
L["Activity"] = "활동"
L["Difficulty"] = "난이도"
L["Leader Score"] = "리더 점수"
L["Members"] = "멤버"
L["Created"] = "생성됨"
L["ago"] = "전"

-- Categories
L["Dungeon"] = "던전"
L["Raid"] = "공격대"
L["Arena"] = "투기장"
L["Rated Battleground"] = "평점 전장"

-- Roles
L["Tank"] = "탱커"
L["Healer"] = "힐러"
L["DPS"] = "딜러"

-- Misc
L["Advanced Filtering"] = "고급 필터링"
L["Use Expression"] = "표현식 사용"
L["Expression Help"] = "표현식 도움말"