local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local DEFAULT_ATLAS = "images/gorge_foods_data.xml"
local DEFAULT_ITEM = "unknown.tex"
local s = STRINGS.GORGE_EXTENDER

local function RGB(r, g, b)
	return {r = r / 255, g = g / 255, b = b / 255, a = 1 }
end

local CHANGES = {
    RGB(219, 112, 147),
	RGB(250, 128, 114),
	RGB(178, 34, 34),
	RGB(255, 99, 71),
	RGB(255, 127, 80),
	RGB(240, 230, 140),
	RGB(255, 228, 196),
	RGB(244, 164, 96),
	RGB(218, 165, 32),
	RGB(0, 255, 127),
	RGB(64, 224, 208),
	RGB(135, 206, 250),
	RGB(221, 160, 221),
}

local FoodBage = Class(Widget, function(self, owner)
    Widget._ctor(self, "FoodBage")
    self.owner = owner
	
	self.last_tint = RGB(255,255,255)
	
    self:SetClickable(false)

    self.root = self:AddChild(Widget("root"))
	
    self.icon = self.root:AddChild(Widget("target"))
    self.icon:SetScale(.8)
	
    self.headbg = self.icon:AddChild(Image("images/avatars.xml", "avatar_bg.tex"))
    self.food = self.icon:AddChild(Image(DEFAULT_ATLAS, DEFAULT_ITEM))
    self.headframe = self.icon:AddChild(Image("images/avatars.xml", "avatar_frame_white.tex"))
	
	self.text = self.icon:AddChild(Text(UIFONT, 36, s.UNKNOWN))
	self.text:SetPosition(0, 65)
	
	self.current_colour = 0
end)

function FoodBage:Set(food)
	if food == self.cached_food then return end
	
	self.cached_food = food
	
	self.current_colour = self.current_colour >= #CHANGES and 1 or self.current_colour + 1
	
	self.headframe:TintTo(self.last_tint, CHANGES[self.current_colour], .7)
	self.last_tint = CHANGES[self.current_colour]
	
	self.text:ScaleTo(1,0,.35)
	self.food:TintTo(RGB(255,255,255), RGB(255, 219, 73), .35)
	self.food:ScaleTo(1, 1.2, .35, function()
		self.text:SetString(s[food] or s.UNKNOWN)
		self.text:ScaleTo(0,1,.35)
		self.food:SetTexture(DEFAULT_ATLAS, string.lower(food)..".tex")
		self.food:TintTo(RGB(255, 219, 73), RGB(255,255,255), .35)
		self.food:ScaleTo(1.1, 1, .35)
	end)
end

return FoodBage
