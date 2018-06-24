local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"

local SYMBOLS = {
	"goatmom_torso",
	"goatmom_tail",
	"goatmom_leg",
	--"goatmom_head",
	--"goatmom_ear",
	"goatmom_arm",
}

local Mumsy = Class(Widget, function(self, owner)
    Widget._ctor(self, "Mumsy")
    self.owner = owner
    self.head = self:AddChild(UIAnim())
    self.head:GetAnimState():SetBuild("quagmire_goatmom_basic")
    self.head:GetAnimState():SetBank("quagmire_goatmom_basic")
	for i, symbol in ipairs(SYMBOLS) do
		self.head:GetAnimState():HideSymbol(symbol)
	end
	self.head:GetAnimState():PlayAnimation("talk1", true)
	self.head:SetScale(.8)
	self.head:SetPosition(0, -225)
	
	self.text = self:AddChild(Text(TALKINGFONT, 75, "test"))
	self.text:SetHAlign(ANCHOR_LEFT)
	self.text:SetVAlign(ANCHOR_BOTTOM)
	self.text:SetPosition(0, 0)
	
	self.head:Hide()
	self.text:Hide()
	
    self:SetClickable(false)
end)


function Mumsy:Say(txt)
	if self.hide_task ~= nil then
		self.hide_task:Cancel()
	end
	
	self.hide_task = nil
	
	self.head:Show()
	self.text:Show()

	self.text:SetString(txt)
	local x = self.text:GetRegionSize()
    self.head:SetPosition(-.5 * x - 175, -225)
	
	self.head:GetAnimState():PlayAnimation("talk"..tostring(math.random(1,3)), true)
	
	self.hide_task = self.inst:DoTaskInTime(2.5, function()
		self.head:Hide()
		self.text:Hide()
	end)
end

return Mumsy
