local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local SpeedDisplay = Class(Widget, function(self)
    Widget._ctor(self, "GorgeSpeedDisplay")
    self.root = self:AddChild(Widget("root"))
	
    self.bg = self.root:AddChild(Image("images/quagmire_hud.xml", "craftingsubmenu_fullhorizontal.tex"))
    self.bg:SetRotation(270)
	self.bg:SetPosition(0, -155)
    self.bg:SetScale(.85)

    self.speed_icon = self.root:AddChild(Image("images/gorge_foods_data.xml", "speed.tex"))
	self.speed_icon:SetPosition(-60, 0)
	self.speed_icon:SetScale(1.1)
	
	self.speed = self.root:AddChild(Text(UIFONT, 75, 0))
	self.speed:SetPosition(30, 0)
	
    self:SetClickable(false)
end)

return SpeedDisplay
