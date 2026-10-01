# Lunarion UI Library

> A modern, themeable Roblox UI library with a liquid glass window, live theming, auto-config, a key system, a Homeboard dashboard, and a locked public API.

![Status](https://img.shields.io/badge/status-pre--beta-orange)
![Version](https://img.shields.io/badge/version-3.0.0-blue)
![Author](https://img.shields.io/badge/author-surrre4L-purple)

**Pre-Beta Release · V3.0.0**

---

## Table of Contents

- [📦 Loading](#-loading)
- [🪟 Creating a Window](#-creating-a-window)
- [🧩 Tabs](#-tabs)
- [🧱 Elements](#-elements)
- [🎨 Themes](#-themes)
- [🖼️ Icons](#️-icons)
- [🔔 Notifications](#-notifications)
- [🔐 Key System](#-key-system)
- [🏠 Homeboard](#-homeboard)
- [📊 Analytics](#-analytics)
- [⚙️ Settings Page](#️-settings-page)
- [🤖 Lunae AI Hook](#-lunae-ai-hook)
- [🧰 Library Lifecycle](#-library-lifecycle)
- [🛡️ Shield Security](#️-shield-security)
- [🔒 Public API](#-public-api)
- [📋 Aliases Cheat Sheet](#-aliases-cheat-sheet)
- [🧪 Full Example](#-full-example)

---

## 📦 Loading

```lua
local Lunarion = loadstring(game:HttpGet("https://raw.githubusercontent.com/surrre4l/Lunarion/main/Lunarion.lua"))()
```

> Icons are loaded on demand (Lucide, Solar, Gravity). Nothing is embedded.

---

## 🪟 Creating a Window

```lua
local Window = Lunarion:MakeWindow({
    Name = "My Hub",
    Author = "you",
    Subtitle = "v1.0",
    Theme = "Lunarion",              -- theme name (see Themes)
    Icon = "rbxassetid://124641107046093",
    ShowIcon = true,
    IntroEnabled = true,
    IntroText = "My Hub",
    IntroSubtitle = "loading...",
    IntroDuration = 1.6,
    SaveConfig = true,
    AutoLoad = true,
    ConfigName = "MyHubConfig",
    ConfigFolder = "MyHub",
    ToggleKey = Enum.KeyCode.RightShift,
    Platform = "PC",                  -- "PC" | "Mobile" | "Console"
    TabStyle = "Side",                -- "Side" | "Top"
    ShowPill = nil,                   -- nil = auto (Mobile/Console only), true/false = force
    PillText = nil,                   -- default "Toggle <Name>"
    InterfaceName = nil,              -- word used in the pill, default = Name
    Security = true,                  -- Shield integrity layer
    SmartMinimize = true,
    CloseCallback = function() end,
    Homeboard = true,                 -- or a table (see Homeboard)
    Analytics = false,
    Themes = {                        -- extra themes in one go
        MyTheme = {Accent = Color3.fromRGB(255, 90, 90)}
    }
})
```

### Window Methods

| Method | Alias | Description |
|---|---|---|
| `Window:MakeTab(TabConfig)` | `Window.Page` | Adds a tab |
| `Window:MakeTabSection(Config)` | `Window.Divider`, `Window.AddTabSection`, `Window.MakeTabDivider` | Divider / section header in the tab list |
| `Window:MakeHomeboard(Config)` | `Window.Dashboard` | Adds the Homeboard dashboard tab |
| `Window:ToggleInterface()` | `Window.Flip` | Show / hide the window (SmartPill) |
| `Window:Minimize(State)` | — | `true` / `false` / `nil` = toggle |
| `Window:Resize(W, H)` | — | Resize the window in pixels |
| `Window:SetTabStyle(Style)` | — | `"Side"` or `"Top"`, `nil` toggles |
| `Window:OpenSearch()` | — | Opens search (Ctrl + K also works) |

---

## 🧩 Tabs

```lua
local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    ImageSource = nil,       -- "Lucide" / "Solar" / "Gravity" / custom library
    Section = "Combat",      -- optional, inserts a section header
    PremiumOnly = false,
    Hidden = false,
    Custom = function(Container)
        -- optional custom builder
    end
})

local Section = Tab:AddSection({Name = "Combat"})   -- alias: Tab:Group
```

---

## 🧱 Elements

All elements live on a **Tab** or a **Section**.

### Label / Paragraph

```lua
Tab:AddLabel("Hello")                              -- alias: Tab:Text
Tab:AddParagraph("Title", "Body text")             -- alias: Tab:Paragraph

Tab:AddWarningLabel("Danger")                      -- alias: Tab:Warn
Tab:AddApproveLabel("All good")                    -- alias: Tab:Approve
Tab:AddCustomLabel("Notice", Color3.fromRGB(255,140,0), "sparkles")  -- alias: Tab:Note
```

### Button

```lua
local Btn = Tab:AddButton({                       -- alias: Tab:Button
    Name = "Click me",
    Icon = "zap",
    Callback = function() print("clicked") end
})
Btn:Set("New text")
```

### Toggle

```lua
local Toggle = Tab:AddToggle({                    -- alias: Tab:Switch
    Name = "Enable",
    Default = false,
    Flag = "enableFlag",                          -- enables Save when set
    Save = true,
    Color = nil,                                  -- nil = theme Accent
    Callback = function(value) print(value) end
})
Toggle:Set(true)
```

### Slider

```lua
local Slider = Tab:AddSlider({                    -- alias: Tab:Slider
    Name = "Speed",
    Min = 0, Max = 100, Increment = 1,
    Default = 50,
    ValueName = "studs",
    Flag = "speedFlag",
    Color = nil,
    Callback = function(value) end
})
Slider:Set(75)
```

### Dropdown

```lua
local Drop = Tab:AddDropdown({                    -- alias: Tab:Select
    Name = "Mode",
    Options = {"A", "B", "C"},
    Default = "A",
    Multi = false,
    Search = nil,                                 -- auto-on for 7+ options
    Placeholder = "Select...",
    MaxRows = 6,
    CloseOnSelect = true,
    Flag = "modeFlag",
    Callback = function(value) end
})
Drop:Set("B")
Drop:Refresh({"X","Y"}, false)   -- false = keep & merge
```

### Input

```lua
local Input = Tab:AddInput({                      -- alias: Tab:Input, Tab:AddTextbox, Tab:TextBox
    Name = "Amount",
    Description = "Numeric supported",
    Default = "10",
    Placeholder = "Type...",
    Numeric = true,                               -- supports "2*8"
    Min = 0, Max = 1000,
    MaxLength = 12,
    Live = false,
    ClearOnFinish = false,
    Trim = true,
    Flag = "amountFlag",
    Callback = function(text) end
})
Input:Set("42")
Input:Get()
Input:SetPlaceholder("...")
Input:SetName("New name")
Input:Focus()
```

### Bind / Hotkey

```lua
local Bind = Tab:AddBind({                        -- alias: Tab:Keybind, Tab:Hotkey
    Name = "Toggle Aimbot",
    Default = Enum.KeyCode.X,
    Hold = false,                                 -- true = hold-to-fire
    AllowMouse = true,
    Flag = "aimFlag",
    Callback = function(down)
        if down ~= nil then print("holding:", down) else print("pressed") end
    end,
    OnChange = function(keyName) end
})
Bind:Set(Enum.KeyCode.Z)
Bind:Get()
Bind:Clear()
```

### Colorpicker

```lua
local Picker = Tab:AddColorpicker({               -- alias: Tab:ColorPick, Tab:Colorpicker, Tab:ColorPicker, Tab:AddColorPicker
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 80, 80),
    Presets = {Color3.new(1,0,0), Color3.new(0,1,0)}, -- optional
    Flag = "espColor",
    Callback = function(color) end
})
Picker:Set(Color3.fromRGB(0,255,0))
```

---

## 🎨 Themes

Eight built-in themes: `Lunarion`, `Default`, `Amethyst`, `Ocean`, `Rose`, `Emerald`, `Light`, `Sakura`.

Every theme uses these keys:

`Main` · `Second` · `Stroke` · `Divider` · `Text` · `TextDark` · `Accent` · `GradientFrom` · `GradientTo` · `GradientRotation`

```lua
Lunarion:AddTheme("MyTheme", {              -- alias: Lunarion.DefineTheme
    Main = Color3.fromRGB(20,20,25),
    Accent = Color3.fromRGB(255, 90, 90)
})

Lunarion:SetTheme("MyTheme")                -- alias: Lunarion.UseTheme
Lunarion:GetTheme()                         -- alias: Lunarion.CurrentTheme
Lunarion:GetThemes()                        -- alias: Lunarion.ListThemes
```

---

## 🖼️ Icons

```lua
Lunarion:AddIconLibrary("mylib", function(name)
    return {Image = "rbxassetid://123", RectSize = Vector2.new(0,0), RectOffset = Vector2.new(0,0)}
end)
Lunarion:SetIconSet("solar")
Lunarion:GetIconSets()
```

**Icon reference formats:**

- `"home"` → default library (Lucide)
- `"solar:home-2-bold"`, `"lucide:home"`, `"gravity:..."`
- `"rbxassetid://123"`, `123`, `"https://..."`
- Legacy Material names still resolve (`"visibility_off"` → `"eye-off"`, etc.)

---

## 🔔 Notifications

```lua
local Handle = Lunarion:MakeNotification({   -- alias: Lunarion.Alert
    Name = "Saved",
    Content = "Your settings were saved.",
    Icon = "check",
    ImageSource = "Lucide",
    Type = "success",                        -- "success" | "warning" | "error"
    Color = nil,                             -- custom accent
    Time = 5,                                -- seconds; false/0/math.huge = sticky
    ShowProgress = true,
    Dismissable = true,
    OnClick = function() end
})
Handle:Dismiss()
```

---

## 🔐 Key System

```lua
local ok = Lunarion:MakeKeySystem({          -- alias: Lunarion.Gate
    Title = "My Hub Key System",
    Subtitle = "Enter your key",
    About = "Get a key from the link below.",
    Key = "MY-KEY",                          -- string OR table of strings
    -- GrabKeyFromSite = true,               -- Key becomes a URL whose body is the valid key
    SaveKey = true,
    FileName = "MyHubKey.txt",
    Icon = "key-round",
    GetKeyLink = "https://example.com/getkey",
    GetKeyText = "Get Key",
    TutorialLink = "https://youtube.com/...",
    Warning = "Do not share your key.",
    Theme = "Ocean",
    Closable = true,
    Tabs = {                                 -- optional tabbed key card
        {Name = "Key"},
        {Name = "Info", Icon = "info", Text = "Info here"},
        {Name = "Links", Links = {
            {Name = "Discord", Link = "https://discord.gg/...", Icon = "message-circle"}
        }}
    }
})
if not ok then return end
```

---

## 🏠 Homeboard

```lua
Window:MakeHomeboard({                        -- alias: Window.Dashboard
    Name = "Dashboard",
    Icon = "layout-dashboard",
    Discord = "https://discord.gg/abc",
    Executors = {"Synapse", "Script-Ware"},
    ShowProfile = true,
    ShowFriends = true,
    ShowServer = true
})
```

Cards: profile, executor, discord, friends (All / Online / In this server / Offline), server (Players / Max / Latency / FPS / Server time / Region).

---

## 📊 Analytics

> Local only. No network calls. All in-memory unless exported.

```lua
Lunarion:EnableAnalytics(true)               -- alias: Lunarion.EnableTelemetry
Lunarion:TrackEvent("MyEvent", {Foo = "Bar"})-- alias: Lunarion.LogEvent
Lunarion:GetAnalytics()                      -- alias: Lunarion.TelemetryData
Lunarion:ClearAnalytics()                    -- alias: Lunarion.ResetTelemetry
Lunarion:ExportAnalytics("log.json")         -- alias: Lunarion.ExportTelemetry
```

---

## ⚙️ Settings Page

Add your own rows to the built-in Settings page:

```lua
Lunarion:AddSetting({
    Name = "My toggle",
    Type = "Toggle",                         -- "Toggle" | "Button" | "Dropdown"
    Section = "General",
    Default = false,                         -- or a function
    Options = {"A","B"},                     -- for Dropdown
    Icon = "zap",                            -- for Button
    Callback = function(value) end
})
```

**Built-in rows:** Auto config · Close notification · Theme · Icon library · Copy config · Reset config · Rejoin server · Unload UI

---

## 🤖 Lunae AI Hook

```lua
Lunarion.Lunae:Register(function(Action, Data)
    -- Action: "WindowOpened" | "WindowClosed" | "ThemeChanged" | "Command"
end)
Lunarion.Lunae:Command("do something")
```

---

## 🧰 Library Lifecycle

```lua
Lunarion:Init()               -- alias: Lunarion.Boot
Lunarion:SaveConfig()         -- alias: Lunarion.Persist
Lunarion:IsRunning()          -- alias: Lunarion.Alive
Lunarion:Destroy()            -- alias: Lunarion.Teardown
```

---

## 🛡️ Shield Security

Enabled by default. Every instance is `Archivable = false`, the ScreenGui has a random name, and a watchdog trips if a known explorer/spy (Dex, RemoteSpy, Cobalt, etc.) appears — the UI destroys itself and refuses to build.

Disable while developing:

```lua
Window:MakeWindow({Security = false})
```

---

## 🔒 Public API

The module returns a **locked proxy**. Only these are readable:

**Functions:** `MakeWindow`, `MakeNotification`, `MakeKeySystem`, `AddTheme`, `SetTheme`, `GetTheme`, `GetThemes`, `EnableAnalytics`, `TrackEvent`, `GetAnalytics`, `ClearAnalytics`, `ExportAnalytics`, `Init`, `SaveConfig`, `Destroy`, `IsRunning`, and all their new aliases (`Spawn`, `Alert`, `DefineTheme`, `UseTheme`, `CurrentTheme`, `ListThemes`, `EnableTelemetry`, `LogEvent`, `TelemetryData`, `ResetTelemetry`, `ExportTelemetry`, `Boot`, `Persist`, `Gate`, `Alive`, `Teardown`).

**Read-only:** `Name`, `Version`, `Platform`.

> Internals (`Flags`, `Connections`, `Elements`, `Analytics`, `Themes`, `Settings`, `Lunae`) are **not** reachable through the public table.

---

## 📋 Aliases Cheat Sheet

| Old name | New name |
|---|---|
| `MakeWindow` | `Spawn` |
| `MakeNotification` | `Alert` |
| `MakeKeySystem` | `Gate` |
| `AddTheme` | `DefineTheme` |
| `SetTheme` | `UseTheme` |
| `GetTheme` | `CurrentTheme` |
| `GetThemes` | `ListThemes` |
| `EnableAnalytics` | `EnableTelemetry` |
| `TrackEvent` | `LogEvent` |
| `GetAnalytics` | `TelemetryData` |
| `ClearAnalytics` | `ResetTelemetry` |
| `ExportAnalytics` | `ExportTelemetry` |
| `Init` | `Boot` |
| `SaveConfig` | `Persist` |
| `Destroy` | `Teardown` |
| `IsRunning` | `Alive` |
| `Window:MakeTab` | `Window.Page` |
| `Window:MakeTabSection` | `Window.Divider`, `Window.AddTabSection` |
| `Window:MakeHomeboard` | `Window.Dashboard` |
| `Window:ToggleInterface` | `Window.Flip` |
| `Tab:AddLabel` | `Tab:Text` |
| `Tab:AddWarningLabel` | `Tab:Warn` |
| `Tab:AddApproveLabel` | `Tab:Approve` |
| `Tab:AddCustomLabel` | `Tab:Note` |
| `Tab:AddButton` | `Tab:Button` |
| `Tab:AddToggle` | `Tab:Switch` |
| `Tab:AddSlider` | `Tab:Slider` |
| `Tab:AddDropdown` | `Tab:Select` |
| `Tab:AddInput` | `Tab:Input`, `Tab:AddTextbox`, `Tab:TextBox` |
| `Tab:AddBind` | `Tab:Keybind`, `Tab:Hotkey` |
| `Tab:AddColorpicker` | `Tab:ColorPick`, `Tab:ColorPicker`, `Tab:AddColorPicker` |
| `Tab:AddSection` | `Tab:Group` |

---

## 🧪 Full Example

```lua
local Lunarion = loadstring(game:HttpGet("https://raw.githubusercontent.com/surrre4l/Lunarion/main/Lunarion.lua"))()

if not Lunarion:MakeKeySystem({
    Title = "Demo Hub",
    Key = "DEMO-KEY",
    GetKeyLink = "https://example.com/key"
}) then return end

local Window = Lunarion:MakeWindow({
    Name = "Demo Hub",
    Author = "you",
    Subtitle = "v1.0",
    Theme = "Lunarion",
    SaveConfig = true,
    ConfigName = "DemoHub"
})

local Main = Window:MakeTab({Name = "Main", Icon = "home"})

Main:AddParagraph("Welcome", "Thanks for using the demo.")

Main:AddToggle({
    Name = "Auto farm",
    Flag = "autoFarm",
    Callback = function(v) print("Auto farm:", v) end
})

Main:AddSlider({
    Name = "Speed",
    Min = 16, Max = 200, Default = 16,
    ValueName = "studs/s",
    Flag = "speed",
    Callback = function(v) end
})

Main:AddDropdown({
    Name = "Mode",
    Options = {"Safe", "Fast", "Rage"},
    Default = "Safe",
    Flag = "mode",
    Callback = function(v) print("Mode:", v) end
})

Main:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255,80,80),
    Flag = "espColor",
    Callback = function(c) end
})

Main:AddButton({
    Name = "Notify me",
    Icon = "bell",
    Callback = function()
        Lunarion:MakeNotification({Name = "Hi", Content = "Button pressed.", Type = "success"})
    end
})

Lunarion:Init()
```

---

**Lunarion is client-side only.** Pre-Beta Release V3.0.0 — combine with an obfuscator and a server-checked key for production use.