-- VUISkin Core
local AddonName, VUI = ...

-- Get our module with safety check
local VUISkin = VUI and VUI.VUISkin or {}
if not VUISkin then return end

-- Local variables
local LSM = LibStub('LibSharedMedia-3.0')
local skinName = '|cff8080ffVUI Theme|r'
local retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

-- Initialize skinTable with references to our module path
local skinTable = {
    file = [[Interface\AddOns\Details\images\skins\flat_skin.blp]],
    author = "VUI Team",
    version = VUI.Version,
    site = "https://github.com/VUI-Team/VUI",
    desc = "VUI integrated skin for Details! Damage Meter.\n\nThis skin automatically adapts to the current VUI theme.",
    no_cache = true,

    -- micro frames
    micro_frames = {color = {1, 1, 1, 1}, font = "Accidental Presidency", size = 10, textymod = 1},

    can_change_alpha_head = true,
    icon_anchor_main = {-1, -5},
    icon_anchor_plugins = {-7, -13},
    icon_plugins_size = {19, 18},

    -- anchors:
    icon_point_anchor = {-37, 0},
    left_corner_anchor = {-107, 0},
    right_corner_anchor = {96, 0},

    icon_point_anchor_bottom = {-37, 12},
    left_corner_anchor_bottom = {-107, 0},
    right_corner_anchor_bottom = {96, 0},

    icon_on_top = true,
    icon_ignore_alpha = true,
    icon_titletext_position = {3, 3},

    instance_cprops = {
        -- titlebar
        titlebar_shown = true,
        titlebar_height = 32,
        titlebar_texture = "VUISkinHeader",
        titlebar_texture_color = {1.0, 1.0, 1.0, 1.0},
        --
        ["toolbar_icon_file"] = "Interface\\AddOns\\Details\\images\\toolbar_icons_shadow",
        ["toolbar_side"] = 1,
        ["menu_anchor"] = {
            10, -- [1]
            10, -- [2]
            ["side"] = 2
        },
        --
        ["attribute_text"] = {
            ["enabled"] = true,
            ["shadow"] = false,
            ["side"] = 1,
            ["text_size"] = 13,
            ["custom_text"] = "{name}",
            ["text_face"] = "Friz Quadrata TT",
            ["anchor"] = {
                -4, -- [1]
                10 -- [2]
            },
            ["text_color"] = {
                NORMAL_FONT_COLOR.r, -- [1]
                NORMAL_FONT_COLOR.g, -- [2]
                NORMAL_FONT_COLOR.b, -- [3]
                NORMAL_FONT_COLOR.a -- [4]
            },
            ["enable_custom_text"] = false,
            ["show_timer"] = true
        },
        --
        ["row_info"] = {
            ["texture_highlight"] = "Interface\\FriendsFrame\\UI-FriendsList-Highlight",
            ["fixed_text_color"] = {
                1, -- [1]
                1, -- [2]
                1 -- [3]
            },
            ["height"] = 28, --
            ["space"] = {["right"] = 0, ["left"] = 0, ["between"] = 4}, --
            row_offsets = {left = 29, right = -29 - 8, top = 0, bottom = 0}, --
            ["texture_background_class_color"] = false,
            ["font_face_file"] = "Interface\\Addons\\Details\\fonts\\Accidental Presidency.ttf",
            ["backdrop"] = {
                ["enabled"] = false,
                ["size"] = 12,
                ["color"] = {
                    1, -- [1]
                    1, -- [2]
                    1, -- [3]
                    1 -- [4]
                },
                ["texture"] = "Details BarBorder 2"
            },
            ["icon_file"] = "Interface\\AddOns\\VUI\\VModules\\VUISkin\\Textures\\ClassIconsTWW",
            start_after_icon = false, --
            icon_offset = {-30, 0}, --
            --
            ["textL_show_number"] = true, --
            ["textL_outline"] = false,
            ["textL_enable_custom_text"] = false, --
            ["textL_custom_text"] = "{data1}. {data3}{data2}", --
            ["textL_class_colors"] = false,
            --
            ["textR_outline"] = false, --
            ["textR_bracket"] = "(",
            ["textR_enable_custom_text"] = false,
            ["textR_custom_text"] = "{data1} ({data2}, {data3}%)",
            ["textR_class_colors"] = false,
            ["textR_show_data"] = {
                true, -- [1]
                true, -- [2]
                true -- [3]
            },
            --
            ["fixed_texture_color"] = {
                0, -- [1]
                0, -- [2]
                0 -- [3]
            },
            ["models"] = {
                ["upper_model"] = "Spells\\AcidBreath_SuperGreen.M2",
                ["lower_model"] = "World\\EXPANSION02\\DOODADS\\Coldarra\\COLDARRALOCUS.m2",
                ["upper_alpha"] = 0.5,
                ["lower_enabled"] = false,
                ["lower_alpha"] = 0.1,
                ["upper_enabled"] = false
            },
            ["texture_custom_file"] = "Interface\\",
            ["texture_custom"] = "",
            ["alpha"] = 1,
            ["no_icon"] = false,
            ["texture"] = "VUISkinBar",
            ["texture_file"] = "Interface\\AddOns\\VUI\\VModules\\VUISkin\\Textures\\bar",
            ["texture_background"] = "VUISkinBackground", --
            ["texture_background_file"] = "Interface\\AddOns\\VUI\\VModules\\VUISkin\\Textures\\background", --        

            ["fixed_texture_background_color"] = {1, 1, 1, 1}, --
            ["font_face"] = "Friz Quadrata TT", --
            ["font_size"] = 11, --
            ["textL_offset"] = 0, --
            ["text_yoffset"] = 7, --
            ["texture_class_colors"] = true,
            ["percent_type"] = 1,
            ["fast_ps_update"] = false,
            ["textR_separator"] = ",",
            ["use_spec_icons"] = true, --
            ["spec_file"] = "Interface\\AddOns\\VUI\\VModules\\VUISkin\\Textures\\specs", --
            icon_size_offset = 1.2
        },
        --
        menu_icons_alpha = 1,
        ["show_statusbar"] = false,
        ["menu_icons_size"] = 1.07,
        ["color"] = {
            0.333333333333333, -- [1]
            0.333333333333333, -- [2]
            0.333333333333333, -- [3]
            0 -- [4]
        },
        ["bg_r"] = 0.0941176470588235,
        ["hide_out_of_combat"] = false,
        ["following"] = {
            ["bar_color"] = {
                1, -- [1]
                1, -- [2]
                1 -- [3]
            },
            ["enabled"] = false,
            ["text_color"] = {
                1, -- [1]
                1, -- [2]
                1 -- [3]
            }
        },
        ["color_buttons"] = {
            1, -- [1]
            1, -- [2]
            1, -- [3]
            1 -- [4]
        },
        ["skin_custom"] = "",
        ["menu_anchor_down"] = {
            16, -- [1]
            -3 -- [2]
        },
        ["micro_displays_locked"] = true,
        ["row_show_animation"] = {["anim"] = "Fade", ["options"] = {}},
        ["tooltip"] = {["n_abilities"] = 3, ["n_enemies"] = 3},
        ["total_bar"] = {
            ["enabled"] = false,
            ["only_in_group"] = true,
            ["icon"] = "Interface\\ICONS\\INV_Sigil_Thorim",
            ["color"] = {
                1, -- [1]
                1, -- [2]
                1 -- [3]
            },
        },
        ["switch_damager"] = false,
        ["bars_sort_direction"] = 1,
        ["show_sidebars"] = false,
        ["window_scale"] = 1,
        ["bars_grow_direction"] = 1,
        ["grab_on_top"] = false,
        ["menu_alpha"] = {
            ["enabled"] = false,
            ["onleave"] = 1,
            ["ignorebars"] = false,
            ["iconstoo"] = true,
            ["onenter"] = 1
        },
        ["statusbar_info"] = {
            ["alpha"] = 0.3777777777777,
            ["overlay"] = {
                0.333333333333333, -- [1]
                0.333333333333333, -- [2]
                0.333333333333333, -- [3]
            },
        },
        ["libwindow"] = {
        },
    },
}

-- Register textures with LibSharedMedia
function VUISkin:RegisterTextures()
    self:Debug("Registering textures with LibSharedMedia")
    
    LSM:Register('statusbar', 'VUISkinHeader', [[Interface\AddOns\VUI\VModules\VUISkin\Textures\header.blp]])
    LSM:Register('statusbar', 'VUISkinBar', [[Interface\AddOns\VUI\VModules\VUISkin\Textures\bar.blp]])
    LSM:Register('statusbar', 'VUISkinBackground', [[Interface\AddOns\VUI\VModules\VUISkin\Textures\background.blp]])
    
    -- Force update LibSharedMedia cache
    if LSM.UpdateMediaTable then
        LSM:UpdateMediaTable('statusbar', 'VUISkinHeader')
        LSM:UpdateMediaTable('statusbar', 'VUISkinBar')
        LSM:UpdateMediaTable('statusbar', 'VUISkinBackground')
    end
    
    self:Debug("Textures registered successfully")
end

-- Register the VUI skin in Details
function VUISkin:RegisterSkin()
    self:Debug("Registering VUI skin with Details!")
    
    -- Ensure Details is loaded
    if not _G.Details then
        self:Debug("Details not loaded yet")
        return false
    end
    
    -- Register skin
    _G._detalhes:InstallSkin(skinName, skinTable)
    
    self:Debug("VUI skin registered successfully")
    return true
end

-- Apply the VUI skin to Details
function VUISkin:ApplySkin()
    self:Debug("Applying VUI skin to Details")
    
    -- Ensure Details is loaded
    if not _G.Details then
        self:Debug("Details not loaded, scheduling retry")
        C_Timer.After(1, function() self:ApplySkin() end)
        return false
    end
    
    -- Register textures
    self:RegisterTextures()
    
    -- Register and apply skin
    if self:RegisterSkin() then
        -- Apply to all windows
        for index, instance in ipairs(_G.Details:GetAllInstances()) do
            instance:ChangeSkin(skinName)
        end
        
        -- Fix title bar and augmentation bar
        self:FixTitleBar()
        if retail then self:ChangeAugmentationBar() end
        
        self:Debug("VUI skin applied successfully")
        return true
    end
    
    return false
end

-- Remove the VUI skin from Details
function VUISkin:RemoveSkin()
    self:Debug("Removing VUI skin from Details")
    
    -- Ensure Details is loaded
    if not _G.Details then
        self:Debug("Details not loaded")
        return false
    end
    
    -- Change all windows to default skin
    for index, instance in ipairs(_G.Details:GetAllInstances()) do
        instance:ChangeSkin("Minimalistic")
    end
    
    self:Debug("VUI skin removed successfully")
    return true
end

-- Import the default profile
function VUISkin:ImportDefaultProfile()
    self:Debug("Importing default profile")
    
    -- Ensure Details is loaded
    if not _G.Details then
        self:Debug("Details not loaded")
        return false
    end
    
    -- Load and import the profile string
    if self.DefaultProfileImport then
        _G.Details:ImportProfile(self.DefaultProfileImport, self.db.profile.importProfileName or "VUI Theme")
        self:Debug("Default profile imported successfully")
        return true
    else
        self:Debug("Default profile not found")
        return false
    end
end

-- Fix title bar appearance
function VUISkin:FixTitleBar()
    self:Debug("Fixing title bar appearance")
    
    -- Ensure Details is loaded
    if not _G.Details then
        self:Debug("Details not loaded")
        return false
    end
    
    -- Fix title bar for each instance
    for index, instance in ipairs(_G.Details:GetAllInstances()) do
        if instance.baseframe then
            local titleBar = instance.baseframe.cabecalho
            if titleBar then
                titleBar:SetHeight(32)
                
                -- Apply settings
                if instance.skin_custom_textures then
                    if instance.skin_custom_textures.title_bar then
                        instance.skin_custom_textures.title_bar:SetHeight(32)
                    end
                end
            end
        end
    end
    
    self:Debug("Title bar fixed successfully")
    return true
end

-- Change augmentation bar appearance (retail only)
function VUISkin:ChangeAugmentationBar()
    self:Debug("Changing augmentation bar appearance")
    
    -- Return if not retail
    if not retail then
        self:Debug("Not retail, skipping augmentation bar changes")
        return false
    end
    
    -- Ensure Details is loaded
    if not _G.Details then
        self:Debug("Details not loaded")
        return false
    end
    
    -- Hook into AugmentationStatusBar creation
    hooksecurefunc(Details.player_class, "GetAugmentationBars", function()
        if not Details or not Details.player_class.GetAugmentationBars then return end
        
        local extraStatusbar = _G["DetailsAugmentationStatusBar"]
        if extraStatusbar then
            -- Set textures
            extraStatusbar:SetStatusBarTexture([[Interface\AddOns\VUI\VModules\VUISkin\Textures\augment]])
            
            -- Apply theme color
            local themeColor = VUI and VUI.GetThemeColor and VUI:GetThemeColor() or {r=0.6, g=0.6, b=1.0}
            extraStatusbar:SetStatusBarColor(themeColor.r, themeColor.g, themeColor.b, 0.8)
            
            local extraStatusbar2 = _G["DetailsAugmentationStatusBar2"]
            if extraStatusbar2 then
                extraStatusbar2:SetStatusBarTexture([[Interface\AddOns\VUI\VModules\VUISkin\Textures\augment]])
                extraStatusbar2:SetStatusBarColor(themeColor.r, themeColor.g, themeColor.b, 0.8)
            end
        end
    end)
    
    self:Debug("Augmentation bar changed successfully")
    return true
end

-- Initialize after Details is loaded
function VUISkin:SetupAfterLogin()
    self:Debug("Setting up VUISkin after login")
    
    -- Check if Details is loaded yet
    if not _G.Details or (Details.IsLoaded and not Details.IsLoaded()) then
        self:Debug("Details not loaded yet, retrying in 1 second")
        C_Timer.After(1, function()
            self:SetupAfterLogin()
        end)
        return
    end
    
    -- Register and apply skin if autoApply is enabled
    if self.db.profile.autoApply then
        self:ApplySkin()
    end
    
    -- Import profile if useDefaultProfile is enabled
    if self.db.profile.useDefaultProfile then
        self:ImportDefaultProfile()
    end
    
    self:Debug("VUISkin setup completed")
end

-- Initialize the VUISkin module
VUISkin:RegisterTextures()

-- Hook player login event
local frame = CreateFrame('FRAME')
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(1, function()
            VUISkin:SetupAfterLogin()
        end)
    end
end)
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")