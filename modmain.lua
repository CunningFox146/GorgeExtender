modimport("scripts/libs/lib_ver.lua")

--_G.CHEATS_ENABLED = true

--Not launching if some other fork is enabled
if mods.quagmire_cunningfox ~= nil then
	print("[Gorge Extender] ERROR: Mod already enabled!")
	return
end

mods.quagmire_cunningfox = {
	root = MODROOT,
	version = modinfo.version,
}

local STRINGS = _G.STRINGS
local s = STRINGS

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
	
	WARNING = "Warning!",
	UPDATE_BODY = "You need to update Gorge extender! Latest version:",
	UPDATE = "Update!",
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
		
		WARNING = "Внимание!",
		UPDATE_BODY = "Вам нужно обновить Gorge extender! Последняя версия:",
		UPDATE = "Обновить!",
	}
end

--No warning about mods in events
AddClassPostConstruct("screens/redux/multiplayermainscreen", function(self)
	local TheFrontEnd = _G.TheFrontEnd
	local PopupDialogScreen = require "screens/redux/popupdialog"
	
	--I don't know how to get it from here, so just replacing it
	function self:OnFestivalEventButton()
		if TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode() then
			TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_TITLE, STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_BODY[WORLD_FESTIVAL_EVENT], 
				{
					{text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_LOGIN, cb = function()
							_G.SimReset()
						end},
					{text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_BACK, cb=function() TheFrontEnd:PopScreen() end },
				}))
		else
			self:_GoToFestfivalEventScreen()
		end
	end
end)

--Checking for mod updates
local UpdateChecker = require("widgets/gorge_updater")

AddClassPostConstruct("screens/redux/multiplayermainscreen", function(self, ...)
	self.gorge_updater = self.title:AddChild(UpdateChecker())
	self.gorge_updater:SetScale(2.15)
	self.gorge_updater:SetPosition(875, -50)
end)

--We don't need to do other things outside the gorge
if TheNet:GetServerGameMode() ~= "quagmire" then
	print("[Gorge extender] Not in Gorge. Aborting...")
	return
end

Assets = 
{
	Asset("ANIM", "anim/quagmire_goatmom_basic.zip"),
	Asset("ATLAS", "images/gorge_foods_data.xml"),
	Asset("ATLAS", "images/quagmire_hud.xml"),
}

do
	SearchForModsByName()
	if mods.active_mods_by_name["Lemom"] then 
		TUNING.FIDOOOP_MOD = true
	end
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
local SapWidget = require "widgets/sap_widget"

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
end)

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
	
	--[[
		"BREAD",
		"CHEESE",
		"FISH",
		"MEAT",
		"PASTA",
		"SNACK",
		"SOUP",
		"DESERT",
		"VEGETABLE",
	]]
}

--For modders: If you want to add your strings and reactions, or you want to add translation compatibility, then use:
--[[
	local mods = _G.rawget(_G, "mods") or {}
	if mods.quagmire_cunningfox then
        mods.quagmire_cunningfox:AddSayingReaction(v, k == "SWEET" and "DESERT" or v)
	end
	
	where string is what we are searchin for in her sayings, and reaction is what we are doing when we see this string
	
	--reaction can be:
	"BREAD",
	"CHEESE",
	"FISH",
	"MEAT",
	"PASTA",
	"SNACK",
	"SOUP",
	"DESERT", -- Yeah, not dessert
	"VEGETABLE",
]]

local assert = _G.assert

local function AddSayingReaction(str, val)
	assert(str, "Failed to find a string when using AddSayingReaction.")
	assert(val, "Failed to find a value when using AddSayingReaction.")
	
	table.insert(sayings, str)
	transl[str] = val
end

mods.quagmire_cunningfox.AddSayingReaction = AddSayingReaction

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
					
					local FIDOOOP_MOD_STRINGS = {
						SNACK = "SNACK",
						SOUP = "SOUP",
						VEGGIE = "VEGETABLE",
						FISH = "FISH",
						BREAD = "BREAD",
						MEAT = "MEAT",
						CHEESE = "CHEESE",
						PASTA = "PASTA",
						SWEET = "DESERT"
					}
					
					if TUNING.FIDOOOP_MOD then
						if FIDOOOP_MOD_STRINGS[display_message] ~= nil then
							_G.ThePlayer.HUD.controls.food_bage:Set(FIDOOOP_MOD_STRINGS[display_message])
							return
						end
					end
					
					local to_feed
					local j=0
					
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
    self.percent_bg:SetClickable(false)

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

local SAP_TIMING = 120
local TheInput = _G.TheInput
local UpHacker = require "tools/upvaluehacker"
local SaltTimer
local SapClosed
local SapTiming

AddClassPostConstruct("widgets/inventorybar", function(self)
	-- self.salt_hint = self:AddChild(Text(_G.UIFONT, 42, string.format(STRINGS.GORGE_EXTENDER.SALT_HINT, "F1", "F2")))
	-- self.salt_hint:SetPosition(self.salt_hint:GetRegionSize()+10, 77)
	
	self.salt_timer = self:AddChild(SaltWidget())
    self.salt_timer:SetPosition(350, 75)
    self.salt_timer:SetScale(.8)
	
	SaltTimer = self.salt_timer
	
	self.speed_timer = self:AddChild(SpeedWidget())
    self.speed_timer:SetPosition(-450, 75)
    self.speed_timer:SetScale(.8)
	
	self.speed_timer.net_speed = UpHacker.GetUpvalue(_G.TheWorld.net.components.quagmire_hangriness.GetLevel, "_netvars").speed
	
	TheFrontEnd:StartUpdatingWidget(self.speed_timer)
	
	--Sap Timer
	self.sap_timer = self:AddChild(SapWidget())
    self.sap_timer:SetPosition(550, 75)
    self.sap_timer:SetScale(.8)
	local _OnUpdate = self.OnUpdate or function(...) end
	
	function self:OnUpdate(dt)
		_OnUpdate(self, dt)
		
		if SapTiming and SapClosed then
			if SapClosed % 2 == 1 then
				if (_G.os.time()-SapTiming)<SAP_TIMING then
					self.sap_timer:SetTimeLeft(SAP_TIMING-(_G.os.time()-SapTiming))
				else
					self.sap_timer:SetIsReady(true)
				end
			else
				self.sap_timer:SetIsNotSet()
			end
		else
			self.sap_timer:SetIsNotSet()
		end
	end
end)

local KEY_START = GetModConfigData("sap_start_key")
local KEY_STOP = GetModConfigData("sap_stop_key")

if KEY_START == KEY_STOP then
	print("ERROR! Start and stop keys are the same. Reseting to F1 and F2.")
	KEY_START = 282
	KEY_STOP = 283
end

local function CanUse()
	if not _G.InGamePlay() then
		return false
	elseif GetModConfigData("use_ctrl") and TheInput:IsKeyDown(_G.KEY_CTRL) then
		return true
	end
	
	return false
end

_G.TheInput:AddKeyUpHandler(KEY_START, function()
	if CanUse() then
		SapTiming = _G.os.time()
		SapClosed = 1
	end
end)


_G.TheInput:AddKeyUpHandler(KEY_STOP, function()
	if not CanUse() then return end
	
	if SapClosed then
		SapClosed = SapClosed + 1
	else
		SapClosed = 1
	end
end)

--Extended salt timer
--Zarklord: we don't currently properly handle having mutliple salt racks so we do this for the first salt rack only.
local once
AddPrefabPostInit("quagmire_salt_rack", function(inst)
	local x, y, z = inst:GetPosition()
	if once == nil or (once.x == x and once.y == y and once.z == z) then
		if inst.find_task then inst.find_task:Cancel() end
		inst.find_task = inst:DoPeriodicTask(FRAMES, function(inst)
			if SaltTimer.start_time == 0 and not inst:HasTag("harvestable") then
				SaltTimer:Start()
			elseif SaltTimer.start_time ~= 0 and inst:HasTag("harvestable") then
				SaltTimer:Finish()
			end
		end)
		once = {x = x, y = y, z = z}
	end
end)

--Renaming seeds
local nm = _G.STRINGS.NAMES

nm.QUAGMIRE_SEEDS_1 = "Wheat Seeds"
nm.QUAGMIRE_SEEDS_2 = "Potato Seeds"
nm.QUAGMIRE_SEEDS_3 = "Tomato Seeds"
nm.QUAGMIRE_SEEDS_4 = "Onion Seeds"
nm.QUAGMIRE_SEEDS_5 = "Turnip Seeds"
nm.QUAGMIRE_SEEDS_6 = "Carrot Seeds"
nm.QUAGMIRE_SEEDS_7 = "Garlic Seed Pods"
nm.QUAGMIRE_SEEDPACKET_1 = "Packet of Wheat Seeds"
nm.QUAGMIRE_SEEDPACKET_2 = "Packet of Potato Seeds"
nm.QUAGMIRE_SEEDPACKET_3 = "Packet of Tomato Seeds"
nm.QUAGMIRE_SEEDPACKET_4 = "Packet of Onion Seeds"
nm.QUAGMIRE_SEEDPACKET_5 = "Packet of Turnip Seeds"
nm.QUAGMIRE_SEEDPACKET_6 = "Packet of Carrot Seeds"
nm.QUAGMIRE_SEEDPACKET_7 = "Packet of Garlic Seed Pods"

local rus = mods.RussianLanguagePack
local RegisterRussianName = rus and rus.RegisterRussianName
	
if RegisterRussianName then
	RegisterRussianName("QUAGMIRE_SEEDS_1", "Семена пшеницы", 5, 1)
	RegisterRussianName("QUAGMIRE_SEEDS_2", "Семена картошки", 5, 1)
	RegisterRussianName("QUAGMIRE_SEEDS_3", "Семена томатов", 5, 1)
	RegisterRussianName("QUAGMIRE_SEEDS_4", "Семена лука", 5, 1)
	RegisterRussianName("QUAGMIRE_SEEDS_5", "Семена брюквы", 5, 1)
	RegisterRussianName("QUAGMIRE_SEEDS_6", "Семена моркови", 5, 1)
	RegisterRussianName("QUAGMIRE_SEEDS_7", "Семена чеснока", 5, 1)
	
	RegisterRussianName("QUAGMIRE_SEEDPACKET_1", "Семена пшеницы", 5, 1)
	RegisterRussianName("QUAGMIRE_SEEDPACKET_2", "Семена картошки", 5, 1)
	RegisterRussianName("QUAGMIRE_SEEDPACKET_3", "Семена томатов", 5, 1)
	RegisterRussianName("QUAGMIRE_SEEDPACKET_4", "Семена лука", 5, 1)
	RegisterRussianName("QUAGMIRE_SEEDPACKET_5", "Семена брюквы", 5, 1)
	RegisterRussianName("QUAGMIRE_SEEDPACKET_6", "Семена моркови", 5, 1)
	RegisterRussianName("QUAGMIRE_SEEDPACKET_7", "Семена чеснока", 5, 1)
end

