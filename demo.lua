-- FlightUi demo: every callback only prints or updates the interface.
-- Upload FlightUi.lua to your public repository first, then replace this URL.
local LIBRARY_URL = 'https://raw.githubusercontent.com/YOUR_USERNAME/FlightUi/refs/heads/main/FlightUi.lua'
local FlightUi = loadstring(game:HttpGet(LIBRARY_URL))()

-- Re-running this demo replaces its own previous window.
local env = getgenv and getgenv() or _G
if env.FlightUiDemo then env.FlightUiDemo:Destroy() end

local Window = FlightUi:CreateWindow({
    Id = 'FlightUiDemo',
    Title = 'FlightUi',
    Subtitle = 'LIQUID GLASS / TEST INTERFACE',
    Author = 'rayware',
    Theme = 'Rose',
    Width = 430,
    Height = 450,
    Welcome = true,
    WelcomeText = 'welcome,',
    LoadingText = 'Preparing FlightUi',
    LoadingDuration = 1.5,
    MiniTitle = 'FlightUi',
    MiniSubtitle = 'demo / tap to open',
    Footer = 'FLIGHTUI / DEMO',
    Themes = {
        Violet = {
            Accent = Color3.fromRGB(180, 146, 255),
            Background = Color3.fromRGB(27, 25, 43),
            Surface = Color3.fromRGB(44, 38, 65),
        },
    },
    OnDestroy = function() print('[FlightUi] demo closed') end,
})
env.FlightUiDemo = Window

local Main = Window:AddTab({Name = 'Main'})
Main:AddSection('TEST CONTROLS')

local Status = Main:AddLabel({
    Text = 'Ready to test',
    Description = 'These controls have no gameplay effects.',
})

Main:AddButton({
    Name = 'Say hello',
    Description = 'Print a message in the console.',
    Callback = function()
        print('[FlightUi] Hello from rayware!')
        Status:SetText('Hello from rayware!')
        Window:Notify('Message printed in the console', 3)
    end,
})

Main:AddToggle({
    Name = 'Test toggle',
    Description = 'Print true / false in the console.',
    Default = false,
    Flag = 'TestEnabled',
    Callback = function(value)
        print('[FlightUi] Test toggle:', value)
        Status:SetText(value and 'Test toggle is ON' or 'Test toggle is OFF')
    end,
})

Main:AddSlider({
    Name = 'Test value',
    Description = 'A slider with no gameplay function.',
    Min = 0,
    Max = 100,
    Step = 1,
    Default = 45,
    Suffix = '%',
    Flag = 'TestValue',
    Callback = function(value) print('[FlightUi] Test value:', value) end,
})

local Extra = Window:AddTab('More')
Extra:AddSlider({
    Name = 'Decimal slider',
    Min = -1,
    Max = 1,
    Step = 0.1,
    Default = 0,
    Callback = function(value) print('[FlightUi] Decimal:', value) end,
})
Extra:AddButton({
    Name = 'Print current values',
    Callback = function()
        for flag, value in pairs(Window.Values) do
            print('[FlightUi]', flag, value)
        end
    end,
})
Extra:AddButton({Name = 'Minimize window', Callback = function() Window:Minimize() end})
Extra:AddLabel('Drag the window title. Drag the mini-menu to move it.')

Window:AddSettingsTab({
    Name = 'Settings',
    Credit = 'made by rayware',
    Description = 'FlightUi 1.0 / choose your color theme above',
})
