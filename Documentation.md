# Lunarion

A UI library for Roblox executors — windows, tabs, a full set of elements, notifications, an optional key system, and a theme engine.

**Version 1.0.0**

## Installation

```lua
local Lunarion = loadstring(game:HttpGet("https://raw.githubusercontent.com/surrre4l/Lunarion/main/Lunarion.lua"))()
```

## Quick Start

```lua
local Window = Lunarion:MakeWindow({
    Name = "Lunarion",
    Resizable = true,
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

## Window — `Lunarion:MakeWindow(WindowConfig)`

Every customizable field on `WindowConfig`:

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | string | `"Lunarion"` | Window title |
| `Subtitle` | string | — | Secondary text next to the title |
| `Author` | string | — | Author line under the title |
| `Icon` | string | Lunarion logo | Title bar icon |
| `ImageSource` | string | — | Icon source (`"Lucide"`, `"Material"`, asset id) |
| `Logo` | string | — | Overrides `Icon` specifically for the title-bar logo image |
| `LogoSource` | string | `ImageSource` | Icon source for `Logo` |
| `LogoColor` | Color3 | theme text | Tints the logo image |
| `ShowIcon` | boolean | — | Shows `Icon` as the logo when `Logo` isn't set |
| `Resizable` | boolean | `true` | `false` removes the resize handle; fixed size |
| `SecureMode` | boolean | `true` | Blocks common remote-spy hooks; prevents the UI being archived/dumped |
| `TabStyle` | `"Side"` \| `"Top"` | `"Side"` | Sidebar tabs or a horizontal top bar |
| `SaveConfig` | boolean | — | Persist flagged elements to a config file |
| `ConfigFolder` | string | `Name` | Folder used for saved configs |
| `ConfigName` | string | `game.GameId` | File name used for the saved config |
| `InterfaceName` | string | `Name` | Name shown in the reopen hint / pill |
| `PillText` | string | `"Toggle " .. InterfaceName` | Text on the minimized capsule |
| `PillIcon` | string | Lunarion logo | Icon on the minimized capsule |
| `PillPosition` | UDim2 | top-center | Where the capsule sits on desktop |
| `PillPositionMobile` | UDim2 | — | Separate capsule position for mobile |
| `ForcePill` | boolean | — | Forces the capsule to show on PC too |
| `ToggleKey` | Enum.KeyCode | `RightShift` | Key that shows/hides the window |
| `CloseNotification` | boolean | `false`\* | Shows a "Toggle Closed" notification on hide (also follows `Lunarion.Settings.Notify`) |
| `CloseCallback` | function | no-op | Runs when the window is closed |
| `HidePremium` | boolean | `false` | Hides Roblox-Premium-only UI |
| `IntroText` | string | `"Lunarion"` | Text shown on the loading splash |
| `IntroIcon` | string | Lunarion logo | Splash icon |
| `IntroIconColor` | Color3 | white | Tints the splash icon |
| `IntroIconSize` | number | `64` | Splash icon size in pixels |
| `IntroTextSize` | number | `34` | Splash text size |
| `IntroDuration` | number | `1.6` | Seconds the splash stays up |
| `Platform` | string | auto-detected | Force `"PC"` / `"Mobile"` / `"Console"` instead of detecting it |

\* `CloseNotification` defaults off; set `true` to enable it, or toggle `Lunarion.Settings.Notify` globally.

### Window methods

- `Window:MakeTab(TabConfig)` → `Tab` — fields: `Name`, `Icon`, `PremiumOnly`
- `Window:MakeTabSection(SectionConfig)` — groups tabs themselves in the sidebar/top bar. Fields: `Name`
- `Window:SetTabStyle("Side" | "Top")`
- `Window:Destroy()`

## Elements (called on a `Tab`)

### `Tab:AddSection({Name})`
Header inside a tab's content, for grouping elements (different from `Window:MakeTabSection`, which groups tabs).

### Labels
- `Tab:AddLabel(Text)`
- `Tab:AddWarningLabel(Text)`
- `Tab:AddApproveLabel(Text)`
- `Tab:AddCustomLabel(Text, Color, Icon)` — any color, any icon
- `Tab:AddParagraph(Title, Content)`

### `Tab:AddButton(ButtonConfig)`
| Field | Default |
|---|---|
| `Name` | `"Button"` |
| `Icon` | `"mouse-pointer-click"` |
| `ImageSource` | — |
| `Callback` | no-op |

### `Tab:AddDualButton(DualConfig)`
`{Left = {...}, Right = {...}}` — each side takes the same fields as a button or toggle, plus:
| Field | Default |
|---|---|
| `Type` | `"Button"` (or `"Toggle"`) |
| `Name` | `"Left"` / `"Right"` |
| `Default` | `false` (toggle side only) |
| `Callback` | no-op |

### `Tab:AddToggle(ToggleConfig)`
| Field | Default |
|---|---|
| `Name` | `"Toggle"` |
| `Default` | `false` |
| `Color` | theme accent |
| `Flag` | — |
| `Callback` | no-op |

### `Tab:AddSlider(SliderConfig)`
| Field | Default |
|---|---|
| `Name` | `"Slider"` |
| `Min` | `0` |
| `Max` | `100` |
| `Increment` | `1` |
| `Default` | `50` |
| `ValueName` | `""` (unit suffix, e.g. `"%"`) |
| `Color` | theme accent |
| `Flag` | — |
| `Callback` | no-op |

### `Tab:AddDropdown(DropdownConfig)`
| Field | Default |
|---|---|
| `Name` | `"Dropdown"` |
| `Options` | `{}` |
| `Default` | — |
| `Multi` | `false` — allow multiple selections |
| `MaxRows` | `6` — visible rows before scrolling |
| `Placeholder` | `"Select..."` |
| `Flag` | — |
| `Callback` | no-op |

### `Tab:AddInput(InputConfig)`
| Field | Default |
|---|---|
| `Name` | `"Input"` |
| `Placeholder` | `"Type..."` |
| `ClearOnFinish` (alias `TextDisappear`) | `false` |
| `Numeric` | `false` — digits only |
| `Trim` | — trims whitespace (ignored if `Numeric`) |
| `MaxLength` | — caps input length |
| `Live` | `false` — fires `Callback` while typing, not just on submit |
| `Flag` | — |
| `Callback` | no-op |

### `Tab:AddBind(BindConfig)`
| Field | Default |
|---|---|
| `Name` | `"Bind"` |
| `Default` | `Enum.KeyCode.Unknown` |
| `Flag` | — |
| `Callback` | no-op |

### `Tab:AddColorpicker(ColorpickerConfig)`
| Field | Default |
|---|---|
| `Name` | `"Colorpicker"` |
| `Default` | white |
| `Presets` | built-in swatch set — pass your own array of `Color3` |
| `Flag` | — |
| `Callback` | no-op |

### `Tab:AddSegmented(SegmentedConfig)`
| Field | Default |
|---|---|
| `Options` | `{"One", "Two"}` |
| `Default` | first option |
| `Flag` | — |
| `Callback` | no-op |

### `Tab:AddProgressBar(ProgressConfig)`
| Field | Default |
|---|---|
| `Name` | `"Progress"` |
| `Value` | — (0 to 1) |
| `Color` | theme accent |

Any element with a `Flag` field is automatically saved/restored when `WindowConfig.SaveConfig = true`.

## Notifications

```lua
Lunarion:MakeNotification({
    Name = "Title",
    Content = "Body text.",
    Icon = "bell",
    Color = Color3.fromRGB(255, 255, 255), -- overrides the type-based accent color
    Duration = 4
})
```

## Key System

```lua
local Verified = Lunarion:MakeKeySystem({
    Title = "Lunarion",
    Subtitle = "Key System",
    Key = {"your-key-here"},
    GetKeyLink = "https://...",
    GetKeyText = "Get Key",
    FileName = "LunarionKey.txt",
    SaveKey = true,
    About = "Grab a key from the link below, then paste it above and press Enter.",
    Icon = "key-round",
    Tabs = true,
    SecureMode = true
})

if not Verified then return end
```

Matches the main window's chrome (same radius, same theme colors), pops in and out quickly, and has no minimize button — close only.

## Themes

```lua
Lunarion:SetTheme("Dark")
Lunarion:AddTheme("MyTheme", {
    Main = Color3...,
    Second = Color3...,
    Accent = Color3...,
    Text = Color3...,
    TextDark = Color3...,
    Stroke = Color3...,
    Divider = Color3...
})
```

Every element, the window chrome, the key system, and notifications re-color live when the theme changes.

## Flags

```lua
local Flags = Lunarion.Flags
Flags.MyToggle:Set(true)
print(Flags.MySlider.Value)
```

## License

MIT — see [LICENSE](LICENSE).
