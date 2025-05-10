-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

if GetLocale() ~= "ruRU" then return end

-- Russian localization
-- Values set to true use the English default

-- General
L["VUI Gfinder"] = "VUI Поиск Групп"
L["Enhances the Group Finder with advanced filtering"] = "Улучшает поиск групп с помощью расширенной фильтрации"

-- UI Text
L["Enable"] = "Включить"
L["Open Filter Dialog"] = "Открыть диалог фильтра"
L["Dialog Scale"] = "Масштаб диалога"
L["Enhanced Tooltips"] = "Улучшенные подсказки"
L["One-Click Sign Up"] = "Запись в один клик"
L["Remember Sign Up Notes"] = "Запоминать заметки при записи"
L["Sign Up on Enter"] = "Запись по нажатию Enter"
L["Show Filter Button"] = "Показать кнопку фильтра"

-- Advanced Filter
L["Enable Advanced Mode"] = "Включить расширенный режим"
L["Filter Expression"] = "Выражение фильтра"
L["Enable Custom Sorting"] = "Включить пользовательскую сортировку"
L["Sorting Expression"] = "Выражение сортировки"

-- Difficulties
L["Normal"] = "Обычный"
L["Heroic"] = "Героический"
L["Mythic"] = "Эпохальный"
L["Mythic+"] = "Эпохальный+"
L["Arena 2v2"] = "Арена 2v2"
L["Arena 3v3"] = "Арена 3v3"

-- Dialog
L["Minimum Difficulty"] = "Минимальная сложность"
L["Maximum Difficulty"] = "Максимальная сложность"
L["Min Mythic+ Level"] = "Мин. уровень Эпохального+"
L["Max Mythic+ Level"] = "Макс. уровень Эпохального+"
L["Min Rating"] = "Мин. рейтинг"
L["Max Rating"] = "Макс. рейтинг"
L["Find Groups"] = "Найти группы"
L["Reset Filters"] = "Сбросить фильтры"
L["Close"] = "Закрыть"

-- Tooltip
L["Group Details"] = "Сведения о группе"
L["Activity"] = "Активность"
L["Difficulty"] = "Сложность"
L["Leader Score"] = "Рейтинг лидера"
L["Members"] = "Участники"
L["Created"] = "Создано"
L["ago"] = "назад"

-- Categories
L["Dungeon"] = "Подземелье"
L["Raid"] = "Рейд"
L["Arena"] = "Арена"
L["Rated Battleground"] = "Рейтинговое поле боя"

-- Roles
L["Tank"] = "Танк"
L["Healer"] = "Лекарь"
L["DPS"] = "ДПС"

-- Misc
L["Advanced Filtering"] = "Расширенная фильтрация"
L["Use Expression"] = "Использовать выражение"
L["Expression Help"] = "Помощь по выражениям"