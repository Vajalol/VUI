local Layout = VUI:NewModule('Config.Layout.FAQ')

function Layout:OnEnable()
    -- Database
    local db = VUI.db

    -- Components
    local VUIConfig = LibStub('VUIConfig')

    -- Imports
    local User = VUI:GetModule("Data.User")

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'Credits'
                }
            },
            {
                team = {
                    type = 'scroll',
                    label = 'Team',
                    scrollChild = function(self)
                        local items = {};
                        local function update(parent, label, data)
                            label.data = data;
                            label:SetText(data.text);
                            VUIConfig:SetObjSize(label, 60, 20);
                            label:SetPoint('RIGHT');
                            label:SetPoint('LEFT');
                            return label;
                        end

                        VUIConfig:ObjectList(self.scrollChild, items, 'Label', update, User.team);
                    end,
                    height = 220,
                    column = 4,
                    order = 1
                },
                special = {
                    type = 'scroll',
                    label = 'Specials',
                    scrollChild = function(self)
                        local items = {};
                        local function update(parent, label, data)
                            label.data = data;
                            label:SetText(data.text);
                            VUIConfig:SetObjSize(label, 60, 20);
                            label:SetPoint('RIGHT');
                            label:SetPoint('LEFT');
                            return label;
                        end

                        VUIConfig:ObjectList(self.scrollChild, items, 'Label', update, User.specials);
                    end,
                    height = 220,
                    column = 4,
                    order = 2
                },
                supporter = {
                    type = 'scroll',
                    label = 'Supporter',
                    scrollChild = function(self)
                        local items = {};
                        local function update(parent, label, data)
                            label.data = data;
                            label:SetText(data.text);
                            VUIConfig:SetObjSize(label, 60, 20);
                            label:SetPoint('RIGHT');
                            label:SetPoint('LEFT');
                            return label;
                        end

                        VUIConfig:ObjectList(self.scrollChild, items, 'Label', update, User.supporter);
                    end,
                    height = 220,
                    column = 4,
                    order = 3
                },
            },
            {
                header = {
                    type = 'header',
                    label = 'Help'
                }
            },
            {
                discord = {
                    type = 'button',
                    text = 'Discord',
                    onClick = function()
                        VUIConfig:Dialog('Discord', 'https://discord.gg/z5W3EWUrwu')
                    end,
                    column = 3,
                    order = 1
                },
                twitch = {
                    type = 'button',
                    text = 'Twitch',
                    onClick = function()
                        VUIConfig:Dialog('Twitch', 'twitch.tv/vajalol')
                    end,
                    column = 3,
                    order = 2
                }
            }
        },
    }
end
