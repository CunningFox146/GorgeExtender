local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local s = STRINGS.GORGE_EXTENDER

local Score = Class(Widget, function(self)
    Widget._ctor(self, "GorgeScore")
    self.score = 0

    self.root = self:AddChild(Widget("root"))
    self.root:SetPosition(35, 0)
	
    self.bg = self.root:AddChild(Image("images/quagmire_hud.xml", "quagmire_announcement_bg.tex"))
	self.bg:SetPosition(50, 0)

	self.icn = self.root:AddChild(Image("images/quagmire_achievements.xml", "quagmire_challenge.tex"))
	self.icn:SetPosition(-160, 0)
	self.icn:SetScale(.52)
	
	self.str = self.root:AddChild(Text(UIFONT, 35, "0"))
	self.str:SetPosition(-70, 0)
	
    self:SetClickable(false)
end)

function Score:SetIsFailed()
	if self.failed then return end
	
	self.failed = true
	
	self.str:ScaleTo(1, 0, .35, function()
		self.str:SetString("Failed")
		self.str:SetColour({255/255, 155/255, 155/255, 1})
		self.inst:DoTaskInTime(FRAMES, function() self.str:ScaleTo(0, 1, .35) end)
	end)
end

function Score:SetScore(score)
	if self.failed or self.score == score then return end
	
	self.str:SetString(tostring(math.floor(score))) --Не пишет, что не удовлетворили глотку
	self.score = score
end

return Score
