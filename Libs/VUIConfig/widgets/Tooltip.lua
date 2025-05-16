--- @type VUIConfig
local VUIConfig = LibStub and LibStub('VUIConfig', true);
if not VUIConfig then
	return
end

local module, version = 'Tooltip', 3;
if not VUIConfig:UpgradeNeeded(module, version) then
	return
end

VUIConfig.tooltips = {};
VUIConfig.frameTooltips = {};

----------------------------------------------------
--- Tooltip
----------------------------------------------------

local TooltipEvents = {
	OnEnter = function(self)
		local tip = self.VUIConfigTooltip;
		tip:SetOwner(tip.owner or UIParent, tip.anchor or 'ANCHOR_NONE');

		if type(tip.text) == 'string' then
			tip:SetText(tip.text,
				tip.VUIConfig.config.font.color.r,
				tip.VUIConfig.config.font.color.g,
				tip.VUIConfig.config.font.color.b,
				tip.VUIConfig.config.font.color.a
			);
		elseif type(tip.text) == 'function' then
			tip.text(tip);
		end

		tip:Show();
		tip:ClearAllPoints();
		tip.VUIConfig:GlueOpposite(tip, tip.owner, 0, 0, tip.anchor);
	end,

	OnLeave = function(self)
		local tip = self.VUIConfigTooltip;
		tip:Hide();
	end
}

--- Standard blizzard tooltip
--@return GameTooltip
function VUIConfig:Tooltip(owner, text, tooltipName, anchor, automatic)
	--- @type GameTooltip
	local tip;

	if tooltipName and self.tooltips[tooltipName] then
		tip = self.tooltips[tooltipName];
	else
		tip = CreateFrame('GameTooltip', tooltipName, UIParent, 'GameTooltipTemplate');
		self:ApplyBackdrop(tip, 'panel');
	end

	tip.owner = owner;
	tip.anchor = anchor;
	tip.text = text;
	tip.VUIConfig = self;
	owner.VUIConfigTooltip = tip;

	if automatic then
		for k, v in pairs(TooltipEvents) do
			owner:HookScript(k, v);
		end
	end

	return tip;
end

----------------------------------------------------
--- Tooltip
----------------------------------------------------

local FrameTooltipMethods = {
	SetText         = function(self, text, r, g, b)
		if r and g and b then
			text = self.VUIConfig.Util.WrapTextInColor(text, r, g, b, 1);
		end
		self.text:SetText(text);

		self:RecalculateSize();
	end,

	GetText         = function(self)
		return self.text:GetText();
	end,

	AddLine         = function(self, text, r, g, b)
		local txt = self:GetText();
		if not txt then
			txt = '';
		else
			txt = txt .. '\n'
		end
		if r and g and b then
			text = self.VUIConfig.Util.WrapTextInColor(text, r, g, b, 1);
		end
		self:SetText(txt .. text);
	end,

	RecalculateSize = function(self)
		self:SetSize(
			self.text:GetWidth() + self.padding * 2,
			self.text:GetHeight() + self.padding * 2
		);
	end
};

local OnShowFrameTooltip = function(self)
	self:RecalculateSize();
	self:ClearAllPoints();

	local _, _, _, xOfs, _ = self.owner:GetPoint()
	
	if xOfs == 15 then
		self.VUIConfig:GlueLeft(self, self.owner, 0, 25, self.anchor);
	elseif xOfs > 275 then
		self.VUIConfig:GlueRight(self, self.owner, 0, 25, self.anchor);
	else
		self.VUIConfig:GlueOpposite(self, self.owner, 0, 0, self.anchor);
	end
end

local FrameTooltipEvents = {
	OnEnter = function(self)
		self.VUIConfigTooltip:Show();
	end,

	OnLeave = function(self)
		self.VUIConfigTooltip:Hide();
	end,
};

function VUIConfig:FrameTooltip(owner, text, tooltipName, anchor, automatic, manualPosition)
	local tip;

	if tooltipName and self.frameTooltips[tooltipName] then
		tip = self.frameTooltips[tooltipName];
	else
		tip = self:Panel(owner, 10, 10);
		tip.VUIConfig = self;
		tip:SetFrameStrata('TOOLTIP');
		self:ApplyBackdrop(tip, 'panel');

		tip.padding = self.config.tooltip.padding;

		tip.text = self:FontString(tip, '');
		self:GlueTop(tip.text, tip, tip.padding, -tip.padding, 'LEFT');

		for k, v in pairs(FrameTooltipMethods) do
			tip[k] = v;
		end

		if not manualPosition then
			hooksecurefunc(tip, 'Show', OnShowFrameTooltip);
		end
	end

	tip.owner = owner;
	tip.anchor = anchor;

	owner.VUIConfigTooltip = tip;

	if type(text) == 'string' then
		tip:SetText(text);
	elseif type(text) == 'function' then
		text(tip);
	end

	if automatic then
		for k, v in pairs(FrameTooltipEvents) do
			owner:HookScript(k, v);
		end
	end

	return tip;
end

VUIConfig:RegisterModule(module, version);