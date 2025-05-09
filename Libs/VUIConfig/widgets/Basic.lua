--- @type VUIConfig
local VUIConfig = LibStub and LibStub('VUIConfig', true);
if not VUIConfig then
	return
end

local module, version = 'Basic', 3;
if not VUIConfig:UpgradeNeeded(module, version) then return end;

function VUIConfig:Frame(parent, width, height, inherits)
	local frame = CreateFrame('Frame', nil, parent, inherits);
	self:InitWidget(frame);
	self:SetObjSize(frame, width, height);

	return frame;
end

function VUIConfig:Panel(parent, width, height, inherits)
	local frame = self:Frame(parent, width, height, inherits);
	self:ApplyBackdrop(frame, 'panel');

	return frame;
end

function VUIConfig:PanelWithLabel(parent, width, height, inherits, text)
	local frame = self:Panel(parent, width, height, inherits);

	frame.label = self:Header(frame, text, 18);
	frame.label:SetAllPoints();
	--frame.label:SetJustifyH('MIDDLE');

	return frame;
end

function VUIConfig:PanelWithTitle(parent, width, height, text)
	local frame = self:Panel(parent, width, height);

	frame.titlePanel = self:PanelWithLabel(frame, 100, 20, nil, text);
	frame.titlePanel:SetPoint('TOP', 0, -10);
	frame.titlePanel:SetPoint('LEFT', 35, 0);
	frame.titlePanel:SetPoint('RIGHT', -35, 0);


	--frame.titlePanel:SetBackdrop(nil);

	return frame;
end

--- @return Texture
function VUIConfig:Texture(parent, width, height, texture)
	local tex = parent:CreateTexture(nil, 'ARTWORK');

	self:SetObjSize(tex, width, height);
	if texture then
		tex:SetTexture(texture);
	end

	return tex;
end

--- @return Texture
function VUIConfig:ArrowTexture(parent, direction)
	local texture = self:Texture(parent, 12, 6, [[Interface\Buttons\Arrow-Up-Down]]);

	if direction == 'UP' then
		texture:SetTexCoord(0, 1, 0.5, 1);
	else
		texture:SetTexCoord(0, 1, 1, 0.5);
	end

	return texture;
end

VUIConfig:RegisterModule(module, version);