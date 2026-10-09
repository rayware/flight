# FlightUi

Roblox UI-библиотека от **rayware**. Плотное стекло, лёгкий объём, светлые края, плавные переключатели, bounce-анимации, загрузка с приветствием по нику и компактное перетаскиваемое мини-меню.

Внутри нет ESP или других игровых функций. Библиотека рисует интерфейс; поведение элементов задаёт автор скрипта через `Callback`.

## Файлы

- `FlightUi.lua` — библиотека. Возвращает таблицу FlightUi; самостоятельно окно не открывает.
- `demo.lua` — тестовый скрипт. Печатает сообщения и значения в консоль, обновляет текст интерфейса.
- `README.md` — инструкция.

## 1. Как опубликовать библиотеку

1. Создай публичный GitHub-репозиторий, например `FlightUi`.
2. Загрузи `FlightUi.lua` в корень репозитория, в ветку `main`.
3. Открой файл и скопируй адрес кнопки **Raw**.
4. Подставь этот адрес в `LIBRARY_URL` в демо или в свой скрипт.

Для репозитория `rayware/FlightUi` и файла `FlightUi.lua` в ветке `main` адрес будет таким **после загрузки файла**:

```lua
https://raw.githubusercontent.com/rayware/FlightUi/refs/heads/main/FlightUi.lua
```

Репозиторий и файл должны существовать и быть доступны. В приложенных примерах `YOUR_USERNAME` — заглушка, которую нужно заменить. Этот комплект не публикует файлы на GitHub автоматически.

## 2. Минимальный пользовательский скрипт

```lua
local FlightUi = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/YOUR_USERNAME/FlightUi/refs/heads/main/FlightUi.lua"
))()

local Window = FlightUi:CreateWindow({
    Title = "My Script",
    Subtitle = "MY OWN INTERFACE",
    Author = "rayware",
    Theme = "Blue",
})

local Main = Window:AddTab("Main")

Main:AddButton({
    Name = "Hello",
    Callback = function()
        print("Hello!")
    end,
})

Main:AddToggle({
    Name = "Test toggle",
    Default = false,
    Callback = function(value)
        print("Toggle:", value)
    end,
})

Main:AddSlider({
    Name = "Test slider",
    Min = 0,
    Max = 100,
    Step = 1,
    Default = 50,
    Callback = function(value)
        print("Slider:", value)
    end,
})

Window:AddSettingsTab()
```

Автор скрипта может добавить любую свою функцию в `Callback`: включение меняет значение на `true`, выключение на `false`, слайдер передаёт число, кнопка вызывает функцию без аргументов.

## 3. Использование в Roblox Studio

`loadstring(game:HttpGet(...))` требует клиентского окружения, предоставляющего эти функции. В обычном LocalScript этот способ подключения недоступен.

В Studio помести содержимое `FlightUi.lua` в **ModuleScript** с именем `FlightUi`, например в `ReplicatedStorage`. Создай LocalScript в `StarterPlayerScripts`:

```lua
local FlightUi = require(game:GetService("ReplicatedStorage"):WaitForChild("FlightUi"))

local Window = FlightUi:CreateWindow({Title = "Studio Demo"})
local Main = Window:AddTab("Main")
Main:AddButton({Name = "Print", Callback = function() print("Works!") end})
Window:AddSettingsTab()
```

Для запуска полного `demo.lua` в Studio замени строку загрузки библиотеки на этот `require`.

## 4. Настройка окна

```lua
local Window = FlightUi:CreateWindow({
    Id = "MyFlightWindow",                 -- имя ScreenGui
    Title = "My Hub",                      -- заголовок
    Subtitle = "MY PERSONAL SCRIPT",       -- подпись
    Author = "rayware",                    -- автор в стандартных настройках
    Width = 430,                           -- базовая ширина, минимум 340
    Height = 450,                          -- базовая высота, минимум 340
    Theme = "Rose",
    Footer = "READY",
    MiniTitle = "My Hub",                  -- отдельное имя мини-меню
    MiniSubtitle = "tap to open",
    Position = UDim2.fromScale(0.5, 0.5),
    Welcome = true,                        -- false отключает приветствие
    WelcomeText = "welcome,",
    -- WelcomeName = "Custom Name",        -- по умолчанию Roblox username
    LoadingText = "Preparing your interface",
    LoadingDuration = 1.5,                 -- длительность приветствия в секундах
    ReduceMotion = false,                  -- true отключает анимации движения
    DisplayOrder = 1000,
    -- Parent = game.Players.LocalPlayer.PlayerGui,
    OnDestroy = function()
        print("Window closed")
    end,
})
```

Окно уменьшается под размер экрана. Вкладки прокручиваются горизонтально, элементы — вертикально. Перетаскивание работает мышью и пальцем: за заголовок окна или левую часть мини-меню. Кнопка `−` сворачивает окно, `↗` раскрывает, `×` удаляет.

Загрузка — анимированное приветствие, а не индикатор сетевого скачивания. Стеклянный вид создаётся средствами GUI: плотными полупрозрачными слоями, градиентами и бликами.

## 5. Элементы и их изменение

### Кнопка

```lua
local Button = Main:AddButton({
    Name = "Print message",
    Description = "Optional explanation",
    Callback = function()
        print("Clicked")
        Window:Notify("Message printed", 3)
    end,
})

Button:SetText("New button name")
Button:SetCallback(function() print("New action") end)
Button:SetDisabled(true)
Button:SetDisabled(false)
```

### Переключатель

```lua
local Toggle = Main:AddToggle({
    Name = "Example toggle",
    Description = "Does nothing in the game",
    Default = false,
    Flag = "ExampleEnabled",
    FireOnInit = false,
    Callback = function(value)
        print(value)
    end,
})

Toggle:SetValue(true)        -- меняет UI без вызова Callback
Toggle:SetValue(false, true) -- меняет UI и вызывает Callback, если значение изменилось
print(Toggle:GetValue())
print(Window.Values.ExampleEnabled)
```

### Слайдер

```lua
local Slider = Main:AddSlider({
    Name = "Example slider",
    Description = "Optional explanation",
    Min = 0,
    Max = 100,
    Step = 0.5,
    Default = 25,
    Suffix = "%",
    Flag = "ExampleValue",
    FireOnInit = false,
    Callback = function(value)
        print(value)
    end,
})

Slider:SetValue(35)
Slider:SetValue(40, true)
print(Slider:GetValue())
```

`Max` должен быть больше `Min`, а `Step` — больше нуля. Значение ограничивается диапазоном и округляется по шагу от `Min`. Конечные точки диапазона доступны даже при шаге, который не делит диапазон целиком.

### Надпись и заголовок секции

```lua
Main:AddSection("MY CONTROLS")
local Label = Main:AddLabel({Text = "Status", Description = "Optional description"})
Label:SetText("Updated status")
Label:SetDescription("Updated description")
Main:AddLabel("A simple line of text")
```

### Общие методы элементов

| Метод | Действие |
| --- | --- |
| `SetText(text)` | Меняет имя/текст элемента |
| `SetDescription(text)` | Меняет подпись |
| `SetCallback(fn)` | Заменяет функцию |
| `SetDisabled(bool)` | Блокирует пользовательское управление |
| `Destroy()` | Удаляет элемент и его обработчики |
| `GetValue()` | Читает значение переключателя или слайдера |
| `SetValue(value, fireCallback)` | Меняет значение переключателя или слайдера |

`Default` самостоятельно не вызывает Callback. Для вызова при создании поставь `FireOnInit = true`. Уведомления Callback выполняются отдельно, ошибки выводятся как предупреждение `[FlightUi callback]`. Частые изменения слайдера могут вызвать много callbacks; длительным пользовательским действиям стоит добавить собственное ограничение частоты.

`Flag` необязателен и должен быть уникальным в окне. `Window.Values` хранит значения в памяти текущего запуска; сохранение на диск не встроено.

## 6. Свои темы

Готовые темы: `Rose`, `Red`, `Blue`, `Green`, `Gold`, `White`.

```lua
Window:AddTheme("Ocean", {
    Accent = Color3.fromRGB(95, 205, 255),
    Background = Color3.fromRGB(18, 27, 39),
    Surface = Color3.fromRGB(29, 47, 65),
    Text = Color3.fromRGB(237, 246, 255),
    Muted = Color3.fromRGB(148, 177, 200),
    Stroke = Color3.fromRGB(185, 227, 255),
})

Window:SetTheme("Ocean")
print(Window:GetTheme())
```

Каждый цвет — `Color3`. Неуказанные цвета берутся из стандартной тёмной палитры. Темы можно передать и при создании окна:

```lua
local Window = FlightUi:CreateWindow({
    Theme = "Violet",
    Themes = {
        Violet = {Accent = Color3.fromRGB(180, 146, 255)},
    },
})
```

Собственная тема появится в созданных через библиотеку селекторах тем. Повторный `AddTheme` с тем же именем обновляет её.

## 7. Вкладки и настройки

```lua
local Main = Window:AddTab({Name = "Main"})
local Other = Window:AddTab("Other")
Other:SetName("Tools")
Window:SelectTab(Other)
Window:SelectTab("Main")

Window:AddSettingsTab({
    Name = "Settings",
    ThemeLabel = "CHOOSE YOUR THEME",
    Credit = "made by rayware",
    Description = "My custom settings page",
})
```

`CreateTab` — другое имя метода `AddTab`. Можно создать сколько угодно вкладок. Для своей страницы настроек используй `Tab:AddThemePicker({Name = "THEMES"})`, а другие элементы добавляй обычными методами.

## 8. Методы окна

```lua
Window:SetTitle("New title")
Window:SetSubtitle("New subtitle")
Window:SetMiniText("Mini title", "tap to open")
Window:Notify("Done!", 3) -- временное сообщение в нижней строке
Window:Minimize()
Window:Restore()
Window:Destroy()
```

Если отдельный `MiniTitle` не задан, мини-меню повторяет заголовок окна. Закрытие окна отключает обработчики библиотеки и удаляет GUI. Пользовательские фоновые задачи и подключения, созданные внутри callbacks, должен очищать автор скрипта, например через `OnDestroy`.

При повторном запуске сохраняй объект окна, чтобы убрать предыдущий экземпляр:

```lua
local env = getgenv and getgenv() or _G
if env.MyWindow then env.MyWindow:Destroy() end
local Window = FlightUi:CreateWindow({Title = "My Window"})
env.MyWindow = Window
```

## Проверка версии

Проверены синтаксис и логика API с имитацией Roblox-сервисов: callbacks, флаги, блокировка элементов, границы и ввод слайдера, пользовательские темы, сворачивание, загрузка и отключение обработчиков. Проверки пройдены.

В реальном Roblox клиенте визуальный вид и взаимодействие ещё не проверялись. Для первой проверки запусти `demo.lua` с правильным Raw-адресом или в Studio через ModuleScript.
