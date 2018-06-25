local Image = require "widgets/image"
local Widget = require "widgets/widget"

local s = STRINGS.GORGE_EXTENDER

local Timer = Class(Widget, function(self)
    Widget._ctor(self, "GorgeSaltTimer")
	
	self.is_ready = false
	
    self.root = self:AddChild(Widget("root"))
	self.root:SetPosition(0, -250)
	
    self.bg = self.root:AddChild(Image("images/quagmire_hud.xml", "craftingsubmenu_fullhorizontal.tex"))
    self.bg:SetRotation(270)
	self.bg:SetPosition(0, -155)
    self.bg:SetScale(.85)

	self.salt_icon = self.root:AddChild(Image("images/inventoryimages.xml", "quagmire_salt.tex"))
	self.salt_icon:SetPosition(-60, 0)
	self.salt_icon:SetScale(1.1)
	
	self.checkmark = self.root:AddChild(Image("images/ui.xml", "checkmark.tex"))
	self.checkmark:SetPosition(30, 5)
	self.checkmark:SetScale(.45)
	self.checkmark:Hide()
	
    self:SetClickable(false)
end)


function Timer:PlayReady()
	if self.is_ready then return end
	
	self.is_ready = true
	
	self.root:MoveTo(self.root:GetPosition(), Vector3(0, 0, 0), .5, function()
		self.checkmark:Show()
		self.checkmark:ScaleTo(0,.45,.5)
		
		if TheFocalPoint and TheFocalPoint.SoundEmitter then
			TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/Together_HUD/chat_receive")
		end
		
		self.inst:DoTaskInTime(5, function()
			self.is_ready = false
			self.checkmark:ScaleTo(.45,0,.5,function() 
				self.root:MoveTo(self.root:GetPosition(), Vector3(0, -250, 0), .25)
				self.checkmark:Hide()
			end)
		end)
	end)
end

return Timer
