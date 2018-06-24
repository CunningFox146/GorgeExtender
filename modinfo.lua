name = " Gorge extender"
author = "Cunning fox"
version = "1.4"

russian = name.utf8len and (russian or language == "ru")

description = (
	russian and
	"Мод добавляет виджет, показывающий чем нужно кормить Существо, виджет, показывающий что говорит Мамси, счетчик скормленной еды, таймер, считающий сколько времени прошло с начала игры, и виджет, показывающий сколько времени у вас осталось до смерти! \nVer. "..version
	or
	"Adds timer, meal counter, talker widget and meal reminder and more! \nVer. "..version
)
forumthread = ""

client_only_mod = true
dst_compatible = true

icon_atlas = "images/preview.xml"
icon = "preview.tex"

api_version = 10
priority = -12.041124582

local scales = {
}

for i = 1, 20 do
	scales[i] = {description = "x"..i/10, data = i/10}
end

local pos = {
	[1] = {description = "Default", data = 0}
}

for i = 2, 15 do
	pos[i] = {description = "+"..i.."0", data = i*10}
end

local opt_Empty = {{description = "", data = 0}}
local function Title(title,hover)
	return {
		name=title,
		hover=hover,
		options=opt_Empty,
		default=0,
	}
end

local SEPARATOR = Title("")

configuration_options = {
	Title("Main"),
	{
		name = "counter_mode",
		label = russian and "Обратный отсчет" or "Mermification countdown",
		options = {
			{description = russian and "Проценты, секунды" or "Persents & sec", data = 3},
			{description = russian and "Секунды" or "Seconds", data = 2},
			{description = russian and "Проценты" or "Persents", data = 1},
		},
		default = 3,
	},
	
	{
		name = "mumsy",
		label = russian and "Добавить виджет Мамси?" or "Add mumsy talker widget?",
		options = {
			{description = russian and "Да" or "Yes", data = true},
			{description = russian and "Нет" or "No", data = false},
		},
		default = true,
	},
	Title("Gorge counter"),
	
	{
		name = "counter_leftright",
		label = russian and "Расположение счетчика" or "Conter side",
		options = {
			{description = russian and "Слева" or "Left", data = 1},
			{description = russian and "Справа" or "Right", data = 2},
		},
		default = 1,
	},
	
	{
		name = "counter_scale",
		label = russian and "Размер счетчика" or "Counter scale",
		options = scales,
		default = 1,
	},
	
	{
		name = "counter_pos",
		label = russian and "Позиция счетчика" or "Counter position",
		options = pos,
		default = 0,
	},
	
	Title("Other"),
	
	{
		name = "rounding",
		label = russian and "Округление счетчика смерти" or "Rounding death counter",
		options = {
			{description = russian and "В большую" or "Up", data = 1},
			{description = russian and "В меньшую" or "Down", data = 2},
			{description = russian and "До десятых" or "To tenths", data = 3},
			{description = russian and "До сотых" or "To hundredths", data = 4},
		},
		default = 2,
	},
}