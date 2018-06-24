local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local s = STRINGS.GORGE_EXTENDER

local Counter = Class(Widget, function(self, owner)
    Widget._ctor(self, "GorgeCounter")
    self.owner = owner

    self.root = self:AddChild(Widget("root"))
	
    self.bg = self.root:AddChild(Image("images/quagmire_hud.xml", "craftingsubmenu_fullhorizontal.tex"))
	self.bg:SetPosition(-155, 0)
    self.bg:SetScale(.5)

	self.time_icon = self.root:AddChild(Image("images/gorge_foods_data.xml", "timer.tex"))
	self.time_icon:SetPosition(-120, 35)
	self.time_icon:SetScale(.7)
	
	self.time = self.root:AddChild(Text(UIFONT, 38, 0))
	self.time:SetPosition(-60, 32)
	
	self.meals_icon = self.root:AddChild(Image("images/quagmire_recipebook.xml", "pot.tex"))
	self.meals_icon:SetPosition(-120, -30)
	
	self.meals = self.root:AddChild(Text(UIFONT, 40, "0"))
	self.meals:SetHAlign(ANCHOR_LEFT)
	self.meals:SetVAlign(ANCHOR_BOTTOM)
	self.meals:SetPosition(-60, -32)
	
	self.current_time = 0
	self.current_meals = 0
	
    self:SetClickable(false)
	self:StartUpdating()
end)

function Counter:AddMeal()
	self.current_meals = self.current_meals + 1
	self.meals:ScaleTo(1, 1.25, .35, function()
		self.meals:SetString(tostring(self.current_meals))
		self.meals:ScaleTo(1.25, 1, .35)
	end)
end

function Counter:OnUpdate(dt)
	self.current_time = self.current_time + dt
	
	self.time:SetString(str_seconds(self.current_time))
end

return Counter
