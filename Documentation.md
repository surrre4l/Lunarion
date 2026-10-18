# Lunarion

A UI library for Roblox executors — windows, tabs, a full set of elements, notifications, an optional key system, and a theme engine. Built for a clean, non-generic look rather than the usual Orion-derived skin.

> **Note:** The Dynamic Island / minimized-pill-as-assistant feature has been scrapped and is no longer part of Lunarion. Minimizing now simply folds the window down to a small capsule; nothing beyond that.

## Installation

```lua
local Lunarion = loadstring(game:HttpGet("https://raw.githubusercontent.com/surrre4l/Lunarion/main/Lunarion.lua"))()
```

## Quick Start

```lua
local Window = Lunarion:MakeWindow({
    Name = "Lunarion",
    Resizable = true,   -- set false to lock the window to a fixed size
    SaveConfig = true,
    ConfigFolder = "Lunarion"
})

local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "home"
})

Tab:AddButton({
    Name = "Click me",
    Callback = function()
        Lunarion:MakeNotification({
            Name = "Hello",
            Content = "This is a notification.",
            Duration = 4
        })
    end
})
```

## Window

`Lunarion:MakeWindow(WindowConfig)` returns a `Window` object and accepts:

| Field | Type | Description |
|---|---|---|
| `Name` | string | Window title |
| `Subtitle` / `Author` | string | Optional secondary text under the title |
| `Icon` | string | Lucide/Material icon name for the title bar |
| `Resizable` | boolean | `false` removes the resize handle; the window keeps a fixed size |
| `SecureMode` | boolean | Defaults on; blocks common remote-spy hooks and prevents the UI from being archived/dumped |
| `TabStyle` | `"Sidebar"` \| `"Top"` | Tabs down the side, or a horizontal bar under the title |
| `SaveConfig` | boolean | Persist flagged elements to a config file |
| `ConfigFolder` | string | Folder name used for saved configs |
| `CloseNotification` | boolean | Shows a "Toggle Closed" notification when the window is hidden (default on) |
| `ShowPill` | boolean | Whether a capsule appears when minimized/closed on mobile/console |

### Methods

- `Window:MakeTab(TabConfig)` → `Tab` — `{Name, Icon, ImageSource}`
- `Window:MakeTabSection(SectionConfig)` — groups the *tabs themselves* in the sidebar/top bar under a heading. `{Name}`
- `Window:SetTabStyle("Sidebar" | "Top")`
- `Window:Destroy()`

## Tabs & Elements

Every method below is called on a `Tab` (the object returned by `MakeTab`).

- `Tab:AddSection({Name})` — a header *inside* the tab's content, for grouping elements (not to be confused with `Window:MakeTabSection`, which groups tabs)
- `Tab:AddLabel(Text)`
- `Tab:AddWarningLabel(Text)`
- `Tab:AddApproveLabel(Text)`
- `Tab:AddCustomLabel(Text, Color, Icon)`
- `Tab:AddParagraph(Title, Content)`
- `Tab:AddButton({Name, Icon, Callback})`
- `Tab:AddDualButton({Left = {...}, Right = {...}})` — two actions side by side; either side can be `Type = "Button"` or `"Toggle"`
- `Tab:AddToggle({Name, Default, Flag, Callback})`
- `Tab:AddSlider({Name, Min, Max, Increment, Default, ValueName, Flag, Callback})`
- `Tab:AddDropdown({Name, Options, Default, Multi, Flag, Callback})`
- `Tab:AddInput({Name, Placeholder, Flag, Callback})`
- `Tab:AddBind({Name, Default, Flag, Callback})` — keybind capture
- `Tab:AddColorpicker({Name, Default, Flag, Callback})`
- `Tab:AddSegmented({Name, Options, Default, Flag, Callback})`
- `Tab:AddProgressBar({Name, Value, Color})`

Any element taking `Flag` is saved/restored automatically when `SaveConfig = true`.

## Notifications

```lua
Lunarion:MakeNotification({
    Name = "Title",
    Content = "Body text.",
    Icon = "bell",
    Duration = 4
})
```

## Key System

```lua
local Verified = Lunarion:MakeKeySystem({
    Title = "Lunarion",
    Subtitle = "Key System",
    Key = {"your-key-here"},       -- string or table of valid keys
    GetKeyLink = "https://...",
    SaveKey = true,
    Tabs = true,                   -- optional "Key" / "About" tabs
    SecureMode = true              -- keys are hashed, never stored/held in plain text
})

if not Verified then return end
```

Visually matches the main window's chrome (same corner radius, same theme colors) and pops in/out quickly rather than fading slowly. No minimize button — close only.

## Themes

```lua
Lunarion:SetTheme("Dark") -- or any registered theme name
Lunarion:AddTheme("MyTheme", { Main = Color3..., Second = Color3..., Accent = Color3..., Text = Color3..., ... })
```

Every element, the window chrome, the key system, and notifications re-color live when the theme changes.

## Flags

```lua
local Flags = Lunarion.Flags
Flags.MyToggle:Set(true)
print(Flags.MySlider.Value)
```

## Changelog

**Update 1.1.0**
- Removed the Dynamic Island / minimized-assistant feature entirely
- Rebuilt notification, window-open, toggle, button-press, and tab-switch-indicator animations for a smoother, more iOS-like feel
- Added `WindowConfig.Resizable` to disable the resize handle
- Key system now shares the main window's visual chrome and animates in/out faster

## License

MIT — see [LICENSE](LICENSE).
