local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local s = STRINGS.GORGE_EXTENDER

local Timer = Class(Widget, function(self)
    Widget._ctor(self, "GorgeSaltTimer")
	self.set = false
	
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
	
	self.time = self.root:AddChild(Text(UIFONT, 75, 0))
	self.time:SetPosition(30, 0)
	
	self.start_time = 0

    self:SetClickable(false)
end)

function Timer:Start()
	TheFrontEnd:StartUpdatingWidget(self)
	self.start_time = os.time()

	if not self.set then
		self.root:CancelMoveTo()
		self.root:MoveTo(self.root:GetPosition(), Vector3(0, 0, 0), .5)
		self.set = true
	end

	self.time:Show()
	self.time:ScaleTo(0,1,.5)
	self.checkmark:ScaleTo(.45,0,.5,function() self.checkmark:Hide() end)
end


function Timer:Finish()
	TheFrontEnd:StopUpdatingWidget(self)

	self.start_time = 0
	self.time:ScaleTo(1, 0, .5, function() self.time:Hide() end)
	self.checkmark:Show()
	self.checkmark:ScaleTo(0,.45,.5)
	
	if TheFocalPoint and TheFocalPoint.SoundEmitter then
		TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/Together_HUD/chat_receive")
	end
end

local SALT_TIMING = 150

function Timer:OnUpdate(dt)
	if (os.time() - self.start_time) < SALT_TIMING then
		self.time:SetString(str_seconds(SALT_TIMING - (os.time() - self.start_time)))
	else
		self:Finish()
	end
end

return Timer
