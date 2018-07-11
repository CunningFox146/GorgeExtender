name = " Gorge extender"
author = "Cunning fox, Zarklord"
version = "2.1"

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

local KEYS = {
	{description = "F1", data = 282},
	{description = "F2", data = 283},
	{description = "F3", data = 284},
	{description = "F4", data = 285},
	{description = "F5", data = 286},
	{description = "F6", data = 287},
	{description = "F7", data = 288},
	{description = "F8", data = 289},
	{description = "F9", data = 290},
	{description = "F10", data = 291},
	{description = "F11", data = 292},
	{description = "F12", data = 293},
	
	{description = "A", data = 97},
	{description = "B", data = 98},
	{description = "C", data = 99},
	{description = "D", data = 100},
	{description = "E", data = 101},
	{description = "F", data = 102},
	{description = "G", data = 103},
	{description = "H", data = 104},
	{description = "I", data = 105},
	{description = "J", data = 106},
	{description = "K", data = 107},
	{description = "L", data = 108},
	{description = "M", data = 109},
	{description = "N", data = 110},
	{description = "O", data = 111},
	{description = "P", data = 112},
	{description = "Q", data = 113},
	{description = "R", data = 114},
	{description = "S", data = 115},
	{description = "T", data = 116},
	{description = "U", data = 117},
	{description = "V", data = 118},
	{description = "W", data = 119},
	{description = "X", data = 120},
	{description = "Y", data = 121},
	{description = "Z", data = 122},
	
	{description = "0", data = 48},
	{description = "1", data = 49},
	{description = "2", data = 50},
	{description = "3", data = 51},
	{description = "4", data = 52},
	{description = "5", data = 53},
	{description = "6", data = 54},
	{description = "7", data = 55},
	{description = "8", data = 56},
	{description = "9", data = 57},
}

local opt_YesNo = {
	{description = russian and "Да" or "Yes", data = true},
	{description = russian and "Нет" or "No", data = false},
}

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
	Title(russian and "Главное" or "Main"),
	
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
		options = opt_YesNo,
		default = true,
	},
	
	{
		name = "rename_seeds",
		label = russian and "Переименовать семена?" or "Rename the seeds?",
		options = opt_YesNo,
		default = true,
	},
	
	Title(russian and "Таймер сока" or "Sap timer"),
	
	{
		name = "sap_start_key",
		label = russian and "Кнопка запуска таймера" or "Timer start key",
		options = KEYS,
		default = 282,
	},
	
	{
		name = "sap_stop_key",
		label = russian and "Кнопка остановки таймера" or "Timer stop key",
		options = KEYS,
		default = 283,
	},
	
	{
		name = "use_ctrl",
		label = russian and "Запуск таймера только с нажатым ctrl" or "Using key with ctrl needed",
		options = opt_YesNo,
		default = false,
	},
	
	Title(russian and "Счетчик" or "Gorge counter"),
	
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
	
	Title(russian and "Остальное" or "Other"),
	
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
