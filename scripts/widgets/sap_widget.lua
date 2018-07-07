local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local s = STRINGS.GORGE_EXTENDER

local Timer = Class(Widget, function(self)
    Widget._ctor(self, "GorgeSapTimer")
	self.set = false
	
    self.root = self:AddChild(Widget("root"))
	self.root:SetPosition(0, -250)
	
    self.bg = self.root:AddChild(Image("images/quagmire_hud.xml", "craftingsubmenu_fullhorizontal.tex"))
    self.bg:SetRotation(270)
	self.bg:SetPosition(0, -155)
    self.bg:SetScale(.85)

	self.sap_icon = self.root:AddChild(Image("images/inventoryimages.xml", "quagmire_sapbucket.tex"))
	self.sap_icon:SetPosition(-60, 0)
	self.sap_icon:SetScale(1.1)
	
	self.checkmark = self.root:AddChild(Image("images/ui.xml", "checkmark.tex"))
	self.checkmark:SetPosition(30, 5)
	self.checkmark:SetScale(.45)
	
	self.time = self.root:AddChild(Text(UIFONT, 75, 0))
	self.time:SetPosition(30, 0)
	
    self:SetClickable(false)
end)

function Timer:SetIsNotSet()
	if self.set then
		self.root:CancelMoveTo()
		self.root:MoveTo(self.root:GetPosition(), Vector3(0, -250, 0), .5, function()
			self.time:SetString(str_seconds(0))
			self.time:SetScale(0)
		end)
		self.set = false
	end
end

function Timer:SetIsReady(isready)
	if self.isready == isready then return end
	if isready then
		self.time:ScaleTo(1,0,.5,function() self.time:Hide() end)
		self.checkmark:Show()
		self.checkmark:ScaleTo(0,.45,.5)
		
		if TheFocalPoint and TheFocalPoint.SoundEmitter then
			TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/Together_HUD/chat_send")
		end
	else
		self.time:Show()
		self.time:ScaleTo(0,1,.5)
		self.checkmark:ScaleTo(.45,0,.5,function() self.checkmark:Hide() end)
	end
	
	self.isready = isready
end

function Timer:SetTimeLeft(time)
	if not self.set then
		self.root:CancelMoveTo()
		self.root:MoveTo(self.root:GetPosition(), Vector3(0, 0, 0), .5)
		self.set = true
		
		self.time:Show()
		self.time:ScaleTo(0,1,.5)
	end
	
	if time > 0 then
		self:SetIsReady(false)
	end
	
	self.time:SetString(str_seconds(time))
end

return Timer
