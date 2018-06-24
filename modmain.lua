modimport("scripts/libs/lib_ver.lua")
--_G.CHEATS_ENABLED = true
--Не запусаем дважды
if mods.quagmire_cunningfox ~= nil then
	print("ERROR! Mod already enabled!")
	return
end
--Нет смысла запускать вне ивента
if TheNet:GetServerGameMode() ~= "quagmire" then
	print("ERROR! Not in Gorge. Aborting...")
	return
end

mods.quagmire_cunningfox = {
	root = MODROOT,
}

Assets = 
{
	Asset("ANIM", "anim/quagmire_goatmom_basic.zip"),
	Asset("ATLAS", "images/gorge_foods_data.xml"),
	Asset("ATLAS", "images/quagmire_hud.xml"),
}

local STRINGS = _G.STRINGS

STRINGS.GORGE_EXTENDER = {
	SALT_HINT = "Press %s to start salt timer, and %s to stop!",
	UNKNOWN = "???",
	SNACK = "Snack",
	MEAT = "Meat",
	SOUP = "Soup",
	VEGETABLE = "Vegetable",
	FISH = "Fish",
	BREAD = "Bread",
	CHEESE = "Cheese",
	PASTA = "Pasta",
	DESERT = "Dessert",
}
--Нативный русский
if mods.RussianLanguagePack then
	STRINGS.GORGE_EXTENDER = {
		SALT_HINT = "Нажми %s чтоб запустить таймер, и %s чтоб отключить!",
		UNKNOWN = "???",
		SNACK = "Закуска",
		MEAT = "Мясо",
		SOUP = "Суп",
		VEGETABLE = "Овощи",
		FISH = "Рыба",
		BREAD = "Хлеб",
		CHEESE = "Сыр",
		PASTA = "Макароны",
		DESERT = "Десерт",
	}
end

local COUNTER_MODE = GetModConfigData("counter_mode") or 1
local COUNTER_POS = GetModConfigData("counter_leftright") or 1
local COUNTER_OVERRIDE = GetModConfigData("counter_pos") or 0
local COUNTER_SCALE = GetModConfigData("counter_scale") or 1
local ROUNDING = GetModConfigData("rounding") or 1

local Text = require "widgets/text"
local Mum = require "widgets/goatmum_talker"
local FoodBage = require "widgets/food_bage"
local CounterLeft = require "widgets/gorge_counter_left"
local CounterRight = require "widgets/gorge_counter_right"
local SaltWidget = require "widgets/salt_widget"
local SpeedWidget = require "widgets/speed_widget"

AddClassPostConstruct("widgets/controls", function(self)
	if GetModConfigData("mumsy") then
		self.mumsy = self.inv:AddChild(Mum(self.owner))
		self.mumsy:SetPosition(0, 212)
		self.mumsy:SetScale(.55)
	end
	
	self.food_bage = self.inv:AddChild(FoodBage(self.owner))
	self.food_bage:SetPosition(-290, 75)
	self.food_bage:SetScale(1.15)
	
	if COUNTER_POS == 1 then
		self.gorge_counter = self.left_root:AddChild(CounterLeft(self.owner))
		self.gorge_counter:SetPosition(150, -300+COUNTER_OVERRIDE)
	else
		self.gorge_counter = self.right_root:AddChild(CounterRight(self.owner))
		self.gorge_counter:SetPosition(-150, -200+COUNTER_OVERRIDE)
	end
	
	self.gorge_counter:MoveToBack()
	self.gorge_counter:SetScale(COUNTER_SCALE)
	
	GetGlobal("test_override", function(pos, scale)
		self.gorge_counter:SetPosition(150, -300 + pos)
		self.gorge_counter:SetScale(scale)
	end)
end)

AddClassPostConstruct("components/talker", function(self)
	local _Say = self.Say
	
	function self:Say(script, time, noanim, ...)
		local lines = type(script) == "string" and { _G.Line(script, noanim) } or script
		if lines ~= nil then
			for i, line in ipairs(lines) do
				local display_message = _G.GetSpecialCharacterPostProcess(
					self.inst.prefab,
					self.mod_str_fn ~= nil and self.mod_str_fn(line.message) or line.message
				)
				--когда мамка что-то говорит
				if self.inst.prefab=="quagmire_goatmum"	then
					if _G.ThePlayer.HUD.controls.mumsy ~= nil then
						_G.ThePlayer.HUD.controls.mumsy:Say(display_message)--Показываем
					end
					
					local to_feed
					local j=0
					local sayings = --На что реагируем
					{
						"SNACK","MEAT","SOUP","VEGETABLE","FISH","BREAD","CHEESE","PASTA", "DESSERT",
						"ХЛЕБНОЕ","СЫРОМ","РЫБУ","МЯСО","МАКАРОНЫ","ЗАКУСКУ","СУП","ДЕСЕРТ", "ОВОЩНОЕ",
					}
					
					local transl = 
					{
						SNACK = "SNACK",
						MEAT = "MEAT",
						SOUP = "SOUP",
						VEGETABLE = "VEGETABLE",
						FISH = "FISH",
						BREAD = "BREAD",
						CHEESE = "CHEESE",
						PASTA = "PASTA",
						DESSERT = "DESERT",
						
						["ХЛЕБНОЕ"] = "BREAD",
						["СЫРОМ"] = "CHEESE",
						["РЫБУ"] = "FISH",
						["МЯСО"] = "MEAT",
						["МАКАРОНЫ"] = "PASTA",
						["ЗАКУСКУ"] = "SNACK",
						["СУП"] = "SOUP",
						["ДЕСЕРТ"] = "DESERT",
						["ОВОЩНОЕ"] = "VEGETABLE",
					}
					for i=1, #display_message do
						--Разбиваем
						if string.sub(display_message,i,i)==" " or
						string.sub(display_message,i,i)=="!" or
						string.sub(display_message,i,i)=="," or 
						string.sub(display_message,i,i)=="." then
							if i~=j then
								to_feed=string.sub(display_message,j+1,i-1)--Нашли!
								j=i
							end
							
							if table.contains(sayings, to_feed) and transl[to_feed] then --Проверяем разбитое
								--print(to_feed, transl[to_feed])
								_G.ThePlayer.HUD.controls.food_bage:Set(transl[to_feed])--Собсна, отправляем
							end
						end
					end
				end
			end
		end
		
		return _Say(self, script, time, noanim, ...)
	end
end)

AddWorldPostInit(function(w)
	--когда скармливаем
	w:ListenForEvent("quagmire_recipeappraised", function(w, data)
		_G.ThePlayer.HUD.controls.gorge_counter:AddMeal()
	end)
end)

AddClassPostConstruct("widgets/statusdisplays_quagmire_cravings", function(self)
	local Image = require "widgets/image"
	
	local function GetMeter()
		local TheWorld = _G.TheWorld
		return TheWorld.net ~= nil and (
			ROUNDING == 1 and math.ceil(TheWorld.net.components.quagmire_hangriness:GetPercent()*100) or
			ROUNDING == 2 and math.floor(TheWorld.net.components.quagmire_hangriness:GetPercent()*100) or
			ROUNDING == 3 and math.round(TheWorld.net.components.quagmire_hangriness:GetPercent()*100, 1) or
			math.round(TheWorld.net.components.quagmire_hangriness:GetPercent()*100, 2)
		) or 0
	end
	
	local function GetTimeRemaining()
		local TheWorld = _G.TheWorld
		return TheWorld.net ~= nil and
		TheWorld.net.components.quagmire_hangriness:GetTimeRemaining() ~= nil and
		TheWorld.net.components.quagmire_hangriness:GetTimeRemaining() - 1
		or 0
	end
	
	if COUNTER_MODE == 1 then
		self.percent = self.mouth:AddChild(Text(_G.UIFONT, 50, "100%"))
		self.percent:SetScale(.9)
		self.percent:SetPosition(5, -74.5)
		self.percent:SetClickable(false)
	elseif COUNTER_MODE == 2 then
		self.time = self.mouth:AddChild(Text(_G.UIFONT, 50, "0:00"))
		self.time:SetScale(.9)
		self.time:SetPosition(5, -74.5)
		self.time:SetClickable(false)
	else
		self.percent = self.mouth:AddChild(Text(_G.UIFONT, 50, "100%"))
		self.percent:SetScale(.9)
		self.percent:SetPosition(5, -74.5)
		self.percent:SetClickable(false)
		
		self.time = self.mouth:AddChild(Text(_G.UIFONT, 35, "0:00"))
		self.time:SetScale(.9)
		self.time:SetPosition(5, -111.5)
		self.time:SetClickable(false)
	end
	
	self.percent_bg = self.mouth:AddChild(Image("images/global_redux.xml", "progressbar_wxplarge_glow.tex"))
	self.percent_bg:SetScale(.15, .65, 1)
	self.percent_bg:SetPosition(0, COUNTER_MODE > 2 and -25 - 74.5 or 0 -74.5)
	self.percent_bg:MoveToBack()

	local _OnUpdate = self.OnUpdate
	function self:OnUpdate(dt)
		_OnUpdate(self, dt)
		
		if self.time then
			self.time:SetString(_G.str_seconds(GetTimeRemaining()))
		end
		
		if self.percent then
			self.percent:SetString(tostring(GetMeter()).."%")
		end
	end
end)

_G.TheInput:AddKeyUpHandler(_G.KEY_F1, function()
	-- if _G.ThePlayer.HUD and _G.ThePlayer.HUD.controls.inv.salt_hint then
		-- local hint = _G.ThePlayer.HUD.controls.inv.salt_hint
		-- hint:MoveTo(hint:GetPosition(), Vector3(hint:GetRegionSize()+10, -100, 0), .5)
	-- end
	
	_G.TheWorld.salt_timer = _G.os.time()
	_G.TheWorld.salt_closed = 1
end)


_G.TheInput:AddKeyUpHandler(_G.KEY_F2, function()
	-- if _G.ThePlayer.HUD and _G.ThePlayer.HUD.controls.inv.salt_hint then
		-- local hint = _G.ThePlayer.HUD.controls.inv.salt_hint
		-- hint:MoveTo(hint:GetPosition(), Vector3(hint:GetRegionSize()+10, -100, 0), .5)
	-- end
	
	if _G.TheWorld.salt_closed then
		_G.TheWorld.salt_closed = _G.TheWorld.salt_closed + 1
	else
		_G.TheWorld.salt_closed = 1
	end
end)

local SALT_TIMING = 150
local TheInput = _G.TheInput
local UpHacker = require "tools/upvaluehacker"

AddClassPostConstruct("widgets/inventorybar", function(self)
	-- self.salt_hint = self:AddChild(Text(_G.UIFONT, 42, string.format(STRINGS.GORGE_EXTENDER.SALT_HINT, "F1", "F2")))
	-- self.salt_hint:SetPosition(self.salt_hint:GetRegionSize()+10, 77)
	
	self.salt_timer = self:AddChild(SaltWidget())
    self.salt_timer:SetPosition(350, 75)
    self.salt_timer:SetScale(.8)
	
	self.speed_timer = self:AddChild(SpeedWidget())
    self.speed_timer:SetPosition(-450, 75)
    self.speed_timer:SetScale(.8)
	
	self.speed_timer.net_speed = UpHacker.GetUpvalue(_G.TheWorld.net.components.quagmire_hangriness.GetLevel, "_netvars").speed
	
	local _OnUpdate = self.OnUpdate or function(...) end
	function self:OnUpdate(dt)
		_OnUpdate(self, dt)
		
		self.speed_timer.speed:SetString(string.format("%.2f", self.speed_timer.net_speed:value()))
		
		if _G.TheWorld.salt_timer and _G.TheWorld.salt_closed then
			if _G.TheWorld.salt_closed % 2 == 1 then
				if (_G.os.time()-_G.TheWorld.salt_timer)<SALT_TIMING then
					self.salt_timer:SetTimeLeft(SALT_TIMING-(_G.os.time()-_G.TheWorld.salt_timer))
				else
					self.salt_timer:SetIsReady(true)
				end
			else
				self.salt_timer:SetIsNotSet()
			end
		else
			self.salt_timer:SetIsNotSet()
		end
	end
end)
