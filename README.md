# FlightUi

**A customizable Roblox UI library by rayware.**

FlightUi combines a dense glass look, subtle depth, reflective edges, smooth controls, bounce animations, a username welcome screen, and a draggable mini-menu.

The library includes a built-in demo. Its buttons, toggles, and sliders only print test messages or update the interface. FlightUi does not include gameplay features.

## Features

- Custom window titles, subtitles, footer text, and mini-menu labels.
- Multiple tabs with horizontal tab scrolling and vertical content scrolling.
- Buttons, toggles, sliders, labels, and section headings.
- User-defined callbacks and optional value flags.
- Six built-in color themes and support for custom palettes.
- Animated welcome screen showing the player's Roblox username.
- Mouse and touch dragging, responsive scaling, and screen position limits.
- Animated minimize, restore, and close transitions.
- A reduced-motion option.
- Built-in demo in `FlightUi.lua`; no separate demo file is required.

## Installation

Upload `FlightUi.lua` to a public GitHub repository. Open the uploaded file, click **Raw**, and copy its URL.

Replace `YOUR_RAW_URL` in the examples below with that URL. For a repository named `FlightUi`, a typical address is:

```text
https://raw.githubusercontent.com/YOUR_USERNAME/FlightUi/refs/heads/main/FlightUi.lua
```

The username, repository, branch, and file path must match your uploaded file.

## Run the built-in demo

```lua
loadstring(game:HttpGet("YOUR_RAW_URL"))()
```

This displays the welcome screen and creates the demo window, including test controls and theme settings. Running the demo again replaces its previous window.

## Create your own script

Pass `{Demo = false}` directly to the loaded function to disable the built-in demo and receive the library API:

```lua
local FlightUi = loadstring(game:HttpGet("YOUR_RAW_URL"))({
    Demo = false
})

local Window = FlightUi:CreateWindow({
    Title = "My Script",
    Subtitle = "MY CUSTOM INTERFACE",
    Author = "rayware",
    Theme = "Blue",
})

local Main = Window:AddTab("Main")

Main:AddButton({
    Name = "Say hello",
    Callback = function()
        print("Hello!")
        Window:Notify("Message printed", 3)
    end,
})

Main:AddToggle({
    Name = "Test toggle",
    Default = false,
    Flag = "TestEnabled",
    Callback = function(enabled)
        print("Enabled:", enabled)
    end,
})

Main:AddSlider({
    Name = "Test slider",
    Min = 0,
    Max = 100,
    Step = 1,
    Default = 50,
    Flag = "TestValue",
    Callback = function(value)
        print("Value:", value)
    end,
})

Window:AddSettingsTab()
```

`{demo = false}` also works. Set the option during loading, rather than assigning it after the library has already loaded. Disabling the demo does not disable the welcome screen on your own windows; use `Welcome = false` for that.

## Window configuration

```lua
local Window = FlightUi:CreateWindow({
    Id = "MyFlightWindow",
    Title = "My Hub",
    Subtitle = "MY PERSONAL SCRIPT",
    Author = "rayware",
    Width = 430,
    Height = 450,
    Position = UDim2.fromScale(0.5, 0.5),
    Theme = "Rose",
    Footer = "READY",
    MiniTitle = "My Hub",
    MiniSubtitle = "tap to open",
    Welcome = true,
    WelcomeText = "welcome,",
    -- WelcomeName = "Custom Name", -- Defaults to the Roblox username.
    LoadingText = "Preparing your interface",
    LoadingDuration = 1.5,
    ReduceMotion = false,
    DisplayOrder = 1000,
    OnDestroy = function()
        print("Window closed")
    end,
})
```

`Width` and `Height` are the base dimensions, with a minimum of 340 each. The window scales down to fit the screen. `Parent` can optionally specify a GUI parent; otherwise FlightUi uses `gethui()` when available, then falls back to the local player's `PlayerGui`.

Drag the window title to move it. Press **−** to minimize, tap the mini-menu or **↗** to restore, and press **×** to close. Drag the left side of the mini-menu to reposition it.

The glass appearance uses GUI layers, gradients, highlights, and borders. The welcome animation is a timed introduction, not a network download progress indicator.

## Tabs

```lua
local Main = Window:AddTab({Name = "Main"})
local Tools = Window:AddTab("Tools")

Tools:SetName("Utilities")
Window:SelectTab(Tools)
Window:SelectTab("Main")
```

`CreateTab` is an alias for `AddTab`. Add your controls to the returned tab.

## Buttons

```lua
local Button = Main:AddButton({
    Name = "Print message",
    Description = "An optional description",
    Callback = function()
        print("Clicked")
    end,
})

Button:SetText("New button name")
Button:SetCallback(function()
    print("New action")
end)
```

A button callback receives no arguments.

## Toggles

```lua
local Toggle = Main:AddToggle({
    Name = "Example toggle",
    Description = "An optional description",
    Default = false,
    Flag = "ExampleEnabled",
    FireOnInit = false,
    Callback = function(enabled)
        print(enabled) -- true or false
    end,
})

Toggle:SetValue(true)        -- Update without calling the callback.
Toggle:SetValue(false, true) -- Call the callback if the value changes.
print(Toggle:GetValue())
print(Window.Values.ExampleEnabled)
```

## Sliders

```lua
local Slider = Main:AddSlider({
    Name = "Example slider",
    Description = "An optional description",
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

`Max` must be greater than `Min`, and `Step` must be positive. Values are clamped to the range and rounded in steps starting from `Min`. Both endpoints remain available even when the step does not divide the range evenly.

## Labels and sections

```lua
Main:AddSection("MY CONTROLS")

local Status = Main:AddLabel({
    Text = "Ready",
    Description = "An optional description",
})

Status:SetText("Updated status")
Status:SetDescription("Updated description")

Main:AddLabel("A simple line of text")
```

## Control methods

| Method | Purpose |
| --- | --- |
| `SetText(text)` | Change the control's title or label. |
| `SetDescription(text)` | Change its description. |
| `SetCallback(fn)` | Replace its callback. |
| `SetDisabled(bool)` | Enable or disable user interaction. |
| `Destroy()` | Remove the control and disconnect its handlers. |
| `GetValue()` | Read a toggle or slider value. |
| `SetValue(value, fireCallback)` | Update a toggle or slider. |

Callbacks do not run for default values unless `FireOnInit = true`. They run in separate tasks, and callback errors produce a `[FlightUi callback]` warning. Slider callbacks can run frequently during dragging; throttle expensive work inside your callback if needed.

Each optional `Flag` must be unique within its window. `Window.Values` stores flagged values for the current session; persistent configuration saving is not included.

## Themes

Built-in themes: **Rose**, **Red**, **Blue**, **Green**, **Gold**, and **White**.

```lua
Window:SetTheme("Green")
print(Window:GetTheme())
```

Add a custom theme:

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
```

All palette values must be `Color3`. Omitted colors use the default dark palette. Calling `AddTheme` again with the same name updates that theme.

You can also register themes when creating a window:

```lua
local Window = FlightUi:CreateWindow({
    Theme = "Violet",
    Themes = {
        Violet = {
            Accent = Color3.fromRGB(180, 146, 255),
        },
    },
})
```

Custom themes appear in FlightUi theme pickers.

## Settings tab

```lua
Window:AddSettingsTab({
    Name = "Settings",
    ThemeLabel = "CHOOSE YOUR THEME",
    Credit = "made by rayware",
    Description = "My custom settings page",
})
```

For a fully custom settings page, create a regular tab and add a theme picker alongside your own controls:

```lua
local Settings = Window:AddTab("Settings")
Settings:AddThemePicker({Name = "COLOR THEME"})
Settings:AddLabel("made by rayware")
```

## Window methods

| Method | Purpose |
| --- | --- |
| `SetTitle(text)` | Change the window title. |
| `SetSubtitle(text)` | Change the window subtitle. |
| `SetMiniText(title, subtitle)` | Customize the mini-menu text. |
| `AddTab(config)` | Create a tab. |
| `SelectTab(tabOrName)` | Select a tab. |
| `AddSettingsTab(config)` | Create theme settings and a credit label. |
| `AddTheme(name, palette)` | Register or update a theme. |
| `SetTheme(name)` | Apply a registered theme. |
| `GetTheme()` | Read the active theme name. |
| `Notify(text, seconds)` | Temporarily display a message in the footer. |
| `Minimize()` | Collapse the window. |
| `Restore()` | Expand the mini-menu. |
| `Destroy()` | Delete the GUI and disconnect library handlers. |

If no separate `MiniTitle` is configured, the mini-menu follows the window title.

FlightUi cleans up its own handlers and animations. Clean up any background tasks or connections created by your own callbacks, for example through `OnDestroy`.

## Prevent duplicate custom windows

The built-in demo replaces its previous instance automatically. For your own scripts, keep a reference to the window:

```lua
local FlightUi = loadstring(game:HttpGet("YOUR_RAW_URL"))({Demo = false})
local env = getgenv and getgenv() or _G

if env.MyFlightWindow then
    env.MyFlightWindow:Destroy()
end

env.MyFlightWindow = FlightUi:CreateWindow({Title = "My Script"})
```

## Customize the built-in demo

```lua
loadstring(game:HttpGet("YOUR_RAW_URL"))({
    DemoConfig = {
        Title = "FlightUi Preview",
        Theme = "Blue",
        Welcome = false,
    },
})
```

You can also create the demo manually after loading without it:

```lua
local FlightUi = loadstring(game:HttpGet("YOUR_RAW_URL"))({Demo = false})
local DemoWindow = FlightUi:CreateDemo({Theme = "Green"})
```

## Roblox Studio

The `loadstring(game:HttpGet(...))` examples require a client environment that provides those functions. For a regular Roblox Studio project, put the library source into a **ModuleScript** named `FlightUi` in `ReplicatedStorage`.

To load only the API through `require`, add this line at the very top of the ModuleScript, before the existing `local launchOptions = ...` line:

```lua
local launchOptions = {Demo = false}
```

Then remove the original `local launchOptions = ...` line so the option is not overwritten. From a LocalScript in `StarterPlayerScripts`, use:

```lua
local FlightUi = require(game:GetService("ReplicatedStorage"):WaitForChild("FlightUi"))
local Window = FlightUi:CreateWindow({Title = "Studio Demo"})
local Main = Window:AddTab("Main")
Main:AddButton({Name = "Print", Callback = function() print("Hello!") end})
```

Leaving the ModuleScript unchanged opens the built-in demo when it is first required.

## Validation

The API and bootstrap logic have been tested with mocked Roblox services, including callbacks, flags, slider bounds and input, themes, loading, minimize/restore, cleanup, and both demo-enabled and demo-disabled loading.

Visual appearance and interaction still need verification in a real Roblox client.

---

**FlightUi 1.1.0 — made by rayware.**
