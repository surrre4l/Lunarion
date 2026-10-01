<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Lunarion UI Library — Documentation</title>
<style>
  :root {
    --bg: #10111b;
    --bg2: #171927;
    --card: #1c1e2e;
    --stroke: #343856;
    --text: #eceffa;
    --text-dim: #8c94b4;
    --accent: #808cff;
    --accent2: #a78bfa;
    --green: #22c55e;
    --red: #ef4444;
    --yellow: #f59e0b;
    --code-bg: #0d0e17;
    --code-border: #2a2d44;
  }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  html { scroll-behavior: smooth; }
  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
    background: var(--bg);
    color: var(--text);
    line-height: 1.65;
    font-size: 15px;
  }
  .layout { display: flex; max-width: 1400px; margin: 0 auto; }

  nav {
    width: 260px;
    flex-shrink: 0;
    padding: 28px 20px;
    position: sticky;
    top: 0;
    height: 100vh;
    overflow-y: auto;
    border-right: 1px solid var(--stroke);
    background: var(--bg2);
  }
  nav h2 {
    font-size: 15px;
    color: var(--accent);
    margin-bottom: 14px;
    letter-spacing: 0.5px;
    text-transform: uppercase;
  }
  nav a {
    display: block;
    color: var(--text-dim);
    text-decoration: none;
    padding: 5px 10px;
    border-radius: 6px;
    font-size: 13.5px;
    transition: all 0.15s;
  }
  nav a:hover { background: var(--card); color: var(--text); }
  nav a.sub { padding-left: 22px; font-size: 12.5px; }

  main { flex: 1; padding: 40px 48px 100px; max-width: 900px; min-width: 0; }

  h1 {
    font-size: 38px;
    font-weight: 800;
    margin-bottom: 8px;
    background: linear-gradient(90deg, var(--accent), var(--accent2));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }
  .subtitle { color: var(--text-dim); margin-bottom: 10px; }
  .meta { color: var(--text-dim); font-size: 13px; margin-bottom: 14px; }
  .meta strong { color: var(--accent); }

  .prebeta {
    display: inline-block;
    background: rgba(245, 158, 11, 0.12);
    border: 1px solid rgba(245, 158, 11, 0.4);
    color: var(--yellow);
    font-size: 12px;
    font-weight: 700;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    padding: 5px 14px;
    border-radius: 20px;
    margin-bottom: 30px;
  }

  h2 {
    font-size: 24px;
    margin: 48px 0 16px;
    padding-bottom: 8px;
    border-bottom: 1px solid var(--stroke);
    font-weight: 700;
  }
  h3 { font-size: 17px; margin: 28px 0 10px; color: var(--text); font-weight: 600; }
  p { margin-bottom: 14px; color: var(--text); }
  a { color: var(--accent); }

  ul { margin: 0 0 14px 22px; color: var(--text-dim); }
  li { margin-bottom: 4px; }
  li strong { color: var(--text); }

  pre {
    background: var(--code-bg);
    border: 1px solid var(--code-border);
    border-radius: 10px;
    padding: 16px 18px;
    overflow-x: auto;
    margin-bottom: 18px;
    font-size: 13px;
    line-height: 1.6;
  }
  code {
    font-family: "SF Mono", "Fira Code", Consolas, Monaco, monospace;
    font-size: 13px;
  }
  p code, li code, td code {
    background: var(--code-bg);
    border: 1px solid var(--code-border);
    border-radius: 5px;
    padding: 2px 6px;
    color: var(--accent2);
    font-size: 12.5px;
  }
  pre code { background: none; border: none; padding: 0; color: var(--text); }

  table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 20px;
    font-size: 13.5px;
  }
  th, td {
    text-align: left;
    padding: 9px 12px;
    border-bottom: 1px solid var(--stroke);
  }
  th {
    color: var(--text-dim);
    font-weight: 600;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }
  tr:hover td { background: var(--bg2); }

  blockquote {
    border-left: 3px solid var(--accent);
    background: var(--bg2);
    padding: 14px 18px;
    border-radius: 0 8px 8px 0;
    margin-bottom: 20px;
    color: var(--text-dim);
    font-size: 14px;
  }
  blockquote strong { color: var(--text); }

  hr { border: none; border-top: 1px solid var(--stroke); margin: 34px 0; }

  @media (max-width: 900px) {
    nav { display: none; }
    main { padding: 24px 20px 80px; }
    h1 { font-size: 28px; }
    h2 { font-size: 20px; }
    pre { font-size: 12px; }
  }
</style>
</head>
<body>
<div class="layout">

<nav>
  <h2>Lunarion</h2>
  <a href="#loading">📦 Loading</a>
  <a href="#window">🪟 Window</a>
  <a href="#tabs">🧩 Tabs</a>
  <a href="#elements">🧱 Elements</a>
  <a href="#themes">🎨 Themes</a>
  <a href="#icons">🖼️ Icons</a>
  <a href="#notifications">🔔 Notifications</a>
  <a href="#keysystem">🔐 Key System</a>
  <a href="#homeboard">🏠 Homeboard</a>
  <a href="#analytics">📊 Analytics</a>
  <a href="#settings">⚙️ Settings</a>
  <a href="#lunae">🤖 Lunae AI</a>
  <a href="#lifecycle">🧰 Lifecycle</a>
  <a href="#shield">🛡️ Shield</a>
  <a href="#public">🔒 Public API</a>
  <a href="#aliases">📋 Aliases</a>
  <a href="#example">🧪 Full Example</a>
</nav>

<main>
  <h1>Lunarion UI Library</h1>
  <p class="subtitle">A modern, themeable Roblox UI library with a liquid glass window, live theming, auto-config, a key system, a Homeboard dashboard, and a locked public API.</p>
  <p class="meta"><strong>Author:</strong> surrre4L</p>
  <div class="prebeta">Pre-Beta Release · V3.0.0</div>

  <h2 id="loading">📦 Loading</h2>
<pre><code>local Lunarion = loadstring(game:HttpGet("https://raw.githubusercontent.com/surrre4l/Lunarion/main/Lunarion.lua"))()</code></pre>
  <blockquote>Icons are loaded on demand (Lucide, Solar, Gravity). Nothing is embedded.</blockquote>

  <h2 id="window">🪟 Creating a Window</h2>
<pre><code>local Window = Lunarion:MakeWindow({
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
    PillText = nil,                   -- default "Toggle &lt;Name&gt;"
    InterfaceName = nil,              -- word used in the pill, default = Name
    Security = true,                  -- Shield integrity layer
    SmartMinimize = true,
    CloseCallback = function() end,
    Homeboard = true,                 -- or a table (see Homeboard)
    Analytics = false,
    Themes = {                        -- extra themes in one go
        MyTheme = {Accent = Color3.fromRGB(255, 90, 90)}
    }
})</code></pre>

  <h3>Window methods</h3>
  <table>
    <tr><th>Method</th><th>Alias</th><th>Description</th></tr>
    <tr><td><code>Window:MakeTab(TabConfig)</code></td><td><code>Window.Page</code></td><td>Adds a tab</td></tr>
    <tr><td><code>Window:MakeTabSection(Config)</code></td><td><code>Window.Divider</code>, <code>Window.AddTabSection</code>, <code>Window.MakeTabDivider</code></td><td>Divider / section header in the tab list</td></tr>
    <tr><td><code>Window:MakeHomeboard(Config)</code></td><td><code>Window.Dashboard</code></td><td>Adds the Homeboard dashboard tab</td></tr>
    <tr><td><code>Window:ToggleInterface()</code></td><td><code>Window.Flip</code></td><td>Show / hide the window (SmartPill)</td></tr>
    <tr><td><code>Window:Minimize(State)</code></td><td>—</td><td><code>true</code> / <code>false</code> / <code>nil</code> = toggle</td></tr>
    <tr><td><code>Window:Resize(W, H)</code></td><td>—</td><td>Resize the window in pixels</td></tr>
    <tr><td><code>Window:SetTabStyle(Style)</code></td><td>—</td><td><code>"Side"</code> or <code>"Top"</code>, <code>nil</code> toggles</td></tr>
    <tr><td><code>Window:OpenSearch()</code></td><td>—</td><td>Opens search (Ctrl + K also works)</td></tr>
  </table>

  <h2 id="tabs">🧩 Tabs</h2>
<pre><code>local Tab = Window:MakeTab({
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

local Section = Tab:AddSection({Name = "Combat"})   -- alias: Tab:Group</code></pre>

  <h2 id="elements">🧱 Elements</h2>
  <p>All elements live on a Tab <strong>or</strong> a Section.</p>

  <h3>Label / Paragraph</h3>
<pre><code>Tab:AddLabel("Hello")                              -- alias: Tab:Text
Tab:AddParagraph("Title", "Body text")             -- alias: Tab:Paragraph

Tab:AddWarningLabel("Danger")                      -- alias: Tab:Warn
Tab:AddApproveLabel("All good")                    -- alias: Tab:Approve
Tab:AddCustomLabel("Notice", Color3.fromRGB(255,140,0), "sparkles")  -- alias: Tab:Note</code></pre>

  <h3>Button</h3>
<pre><code>local Btn = Tab:AddButton({                       -- alias: Tab:Button
    Name = "Click me",
    Icon = "zap",
    Callback = function() print("clicked") end
})
Btn:Set("New text")</code></pre>

  <h3>Toggle</h3>
<pre><code>local Toggle = Tab:AddToggle({                    -- alias: Tab:Switch
    Name = "Enable",
    Default = false,
    Flag = "enableFlag",                          -- enables Save when set
    Save = true,
    Color = nil,                                  -- nil = theme Accent
    Callback = function(value) print(value) end
})
Toggle:Set(true)</code></pre>

  <h3>Slider</h3>
<pre><code>local Slider = Tab:AddSlider({                    -- alias: Tab:Slider
    Name = "Speed",
    Min = 0, Max = 100, Increment = 1,
    Default = 50,
    ValueName = "studs",
    Flag = "speedFlag",
    Color = nil,
    Callback = function(value) end
})
Slider:Set(75)</code></pre>

  <h3>Dropdown</h3>
<pre><code>local Drop = Tab:AddDropdown({                    -- alias: Tab:Select
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
Drop:Refresh({"X","Y"}, false)   -- false = keep &amp; merge</code></pre>

  <h3>Input</h3>
<pre><code>local Input = Tab:AddInput({                      -- alias: Tab:Input, Tab:AddTextbox, Tab:TextBox
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
Input:Focus()</code></pre>

  <h3>Bind / Hotkey</h3>
<pre><code>local Bind = Tab:AddBind({                        -- alias: Tab:Keybind, Tab:Hotkey
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
Bind:Clear()</code></pre>

  <h3>Colorpicker</h3>
<pre><code>local Picker = Tab:AddColorpicker({               -- alias: Tab:ColorPick, Tab:Colorpicker, Tab:ColorPicker, Tab:AddColorPicker
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 80, 80),
    Presets = {Color3.new(1,0,0), Color3.new(0,1,0)}, -- optional
    Flag = "espColor",
    Callback = function(color) end
})
Picker:Set(Color3.fromRGB(0,255,0))</code></pre>

  <h2 id="themes">🎨 Themes</h2>
  <p>Eight built-in themes: <code>Lunarion</code>, <code>Default</code>, <code>Amethyst</code>, <code>Ocean</code>, <code>Rose</code>, <code>Emerald</code>, <code>Light</code>, <code>Sakura</code>.</p>
  <p>Every theme uses these keys:<br>
  <code>Main</code>, <code>Second</code>, <code>Stroke</code>, <code>Divider</code>, <code>Text</code>, <code>TextDark</code>, <code>Accent</code>, <code>GradientFrom</code>, <code>GradientTo</code>, <code>GradientRotation</code>.</p>
<pre><code>Lunarion:AddTheme("MyTheme", {              -- alias: Lunarion.DefineTheme
    Main = Color3.fromRGB(20,20,25),
    Accent = Color3.fromRGB(255, 90, 90)
})

Lunarion:SetTheme("MyTheme")                -- alias: Lunarion.UseTheme
Lunarion:GetTheme()                         -- alias: Lunarion.CurrentTheme
Lunarion:GetThemes()                        -- alias: Lunarion.ListThemes</code></pre>

  <h2 id="icons">🖼️ Icons</h2>
<pre><code>Lunarion:AddIconLibrary("mylib", function(name)
    return {Image = "rbxassetid://123", RectSize = Vector2.new(0,0), RectOffset = Vector2.new(0,0)}
end)
Lunarion:SetIconSet("solar")
Lunarion:GetIconSets()</code></pre>
  <p>Icon reference formats:</p>
  <ul>
    <li><code>"home"</code> → default library (Lucide)</li>
    <li><code>"solar:home-2-bold"</code>, <code>"lucide:home"</code>, <code>"gravity:..."</code></li>
    <li><code>"rbxassetid://123"</code>, <code>123</code>, <code>"https://..."</code></li>
    <li>Legacy Material names still resolve (<code>"visibility_off"</code> → <code>"eye-off"</code>, etc.)</li>
  </ul>

  <h2 id="notifications">🔔 Notifications</h2>
<pre><code>local Handle = Lunarion:MakeNotification({   -- alias: Lunarion.Alert
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
Handle:Dismiss()</code></pre>

  <h2 id="keysystem">🔐 Key System</h2>
<pre><code>local ok = Lunarion:MakeKeySystem({          -- alias: Lunarion.Gate
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
if not ok then return end</code></pre>

  <h2 id="homeboard">🏠 Homeboard</h2>
<pre><code>Window:MakeHomeboard({                        -- alias: Window.Dashboard
    Name = "Dashboard",
    Icon = "layout-dashboard",
    Discord = "https://discord.gg/abc",
    Executors = {"Synapse", "Script-Ware"},
    ShowProfile = true,
    ShowFriends = true,
    ShowServer = true
})</code></pre>
  <p>Cards: profile, executor, discord, friends (All / Online / In this server / Offline), server (Players / Max / Latency / FPS / Server time / Region).</p>

  <h2 id="analytics">📊 Analytics (local only)</h2>
<pre><code>Lunarion:EnableAnalytics(true)               -- alias: Lunarion.EnableTelemetry
Lunarion:TrackEvent("MyEvent", {Foo = "Bar"})-- alias: Lunarion.LogEvent
Lunarion:GetAnalytics()                      -- alias: Lunarion.TelemetryData
Lunarion:ClearAnalytics()                    -- alias: Lunarion.ResetTelemetry
Lunarion:ExportAnalytics("log.json")         -- alias: Lunarion.ExportTelemetry</code></pre>
  <blockquote>No network calls. All in-memory unless exported.</blockquote>

  <h2 id="settings">⚙️ Settings Page</h2>
  <p>Add your own rows to the built-in Settings page:</p>
<pre><code>Lunarion:AddSetting({
    Name = "My toggle",
    Type = "Toggle",                         -- "Toggle" | "Button" | "Dropdown"
    Section = "General",
    Default = false,                         -- or a function
    Options = {"A","B"},                     -- for Dropdown
    Icon = "zap",                            -- for Button
    Callback = function(value) end
})</code></pre>
  <p>Built-in rows: <strong>Auto config</strong>, <strong>Close notification</strong>, <strong>Theme</strong>, <strong>Icon library</strong>, <strong>Copy config</strong>, <strong>Reset config</strong>, <strong>Rejoin server</strong>, <strong>Unload UI</strong>.</p>

  <h2 id="lunae">🤖 Lunae AI Hook</h2>
<pre><code>Lunarion.Lunae:Register(function(Action, Data)
    -- Action: "WindowOpened" | "WindowClosed" | "ThemeChanged" | "Command"
end)
Lunarion.Lunae:Command("do something")</code></pre>

  <h2 id="lifecycle">🧰 Library Lifecycle</h2>
<pre><code>Lunarion:Init()               -- alias: Lunarion.Boot
Lunarion:SaveConfig()         -- alias: Lunarion.Persist
Lunarion:IsRunning()          -- alias: Lunarion.Alive
Lunarion:Destroy()            -- alias: Lunarion.Teardown</code></pre>

  <h2 id="shield">🛡️ Shield Security</h2>
  <p>Enabled by default. Every instance is <code>Archivable = false</code>, the ScreenGui has a random name, and a watchdog trips if a known explorer/spy (Dex, RemoteSpy, Cobalt, etc.) appears — the UI destroys itself and refuses to build.</p>
  <p>Disable while developing:</p>
<pre><code>Window:MakeWindow({Security = false})</code></pre>

  <h2 id="public">🔒 Public API</h2>
  <p>The module returns a <strong>locked proxy</strong>. Only these are readable:</p>
  <p><strong>Functions:</strong> <code>MakeWindow</code>, <code>MakeNotification</code>, <code>MakeKeySystem</code>, <code>AddTheme</code>, <code>SetTheme</code>, <code>GetTheme</code>, <code>GetThemes</code>, <code>EnableAnalytics</code>, <code>TrackEvent</code>, <code>GetAnalytics</code>, <code>ClearAnalytics</code>, <code>ExportAnalytics</code>, <code>Init</code>, <code>SaveConfig</code>, <code>Destroy</code>, <code>IsRunning</code>, and all their new aliases (<code>Spawn</code>, <code>Alert</code>, <code>DefineTheme</code>, <code>UseTheme</code>, <code>CurrentTheme</code>, <code>ListThemes</code>, <code>EnableTelemetry</code>, <code>LogEvent</code>, <code>TelemetryData</code>, <code>ResetTelemetry</code>, <code>ExportTelemetry</code>, <code>Boot</code>, <code>Persist</code>, <code>Gate</code>, <code>Alive</code>, <code>Teardown</code>).</p>
  <p><strong>Read-only:</strong> <code>Name</code>, <code>Version</code>, <code>Platform</code>.</p>
  <blockquote>Internals (<code>Flags</code>, <code>Connections</code>, <code>Elements</code>, <code>Analytics</code>, <code>Themes</code>, <code>Settings</code>, <code>Lunae</code>) are <strong>not</strong> reachable through the public table.</blockquote>

  <h2 id="aliases">📋 Aliases Cheat Sheet</h2>
  <table>
    <tr><th>Old name</th><th>New name</th></tr>
    <tr><td><code>MakeWindow</code></td><td><code>Spawn</code></td></tr>
    <tr><td><code>MakeNotification</code></td><td><code>Alert</code></td></tr>
    <tr><td><code>MakeKeySystem</code></td><td><code>Gate</code></td></tr>
    <tr><td><code>AddTheme</code></td><td><code>DefineTheme</code></td></tr>
    <tr><td><code>SetTheme</code></td><td><code>UseTheme</code></td></tr>
    <tr><td><code>GetTheme</code></td><td><code>CurrentTheme</code></td></tr>
    <tr><td><code>GetThemes</code></td><td><code>ListThemes</code></td></tr>
    <tr><td><code>EnableAnalytics</code></td><td><code>EnableTelemetry</code></td></tr>
    <tr><td><code>TrackEvent</code></td><td><code>LogEvent</code></td></tr>
    <tr><td><code>GetAnalytics</code></td><td><code>TelemetryData</code></td></tr>
    <tr><td><code>ClearAnalytics</code></td><td><code>ResetTelemetry</code></td></tr>
    <tr><td><code>ExportAnalytics</code></td><td><code>ExportTelemetry</code></td></tr>
    <tr><td><code>Init</code></td><td><code>Boot</code></td></tr>
    <tr><td><code>SaveConfig</code></td><td><code>Persist</code></td></tr>
    <tr><td><code>Destroy</code></td><td><code>Teardown</code></td></tr>
    <tr><td><code>IsRunning</code></td><td><code>Alive</code></td></tr>
    <tr><td><code>Window:MakeTab</code></td><td><code>Window.Page</code></td></tr>
    <tr><td><code>Window:MakeTabSection</code></td><td><code>Window.Divider</code>, <code>Window.AddTabSection</code></td></tr>
    <tr><td><code>Window:MakeHomeboard</code></td><td><code>Window.Dashboard</code></td></tr>
    <tr><td><code>Window:ToggleInterface</code></td><td><code>Window.Flip</code></td></tr>
    <tr><td><code>Tab:AddLabel</code></td><td><code>Tab:Text</code></td></tr>
    <tr><td><code>Tab:AddWarningLabel</code></td><td><code>Tab:Warn</code></td></tr>
    <tr><td><code>Tab:AddApproveLabel</code></td><td><code>Tab:Approve</code></td></tr>
    <tr><td><code>Tab:AddCustomLabel</code></td><td><code>Tab:Note</code></td></tr>
    <tr><td><code>Tab:AddButton</code></td><td><code>Tab:Button</code></td></tr>
    <tr><td><code>Tab:AddToggle</code></td><td><code>Tab:Switch</code></td></tr>
    <tr><td><code>Tab:AddSlider</code></td><td><code>Tab:Slider</code></td></tr>
    <tr><td><code>Tab:AddDropdown</code></td><td><code>Tab:Select</code></td></tr>
    <tr><td><code>Tab:AddInput</code></td><td><code>Tab:Input</code>, <code>Tab:AddTextbox</code>, <code>Tab:TextBox</code></td></tr>
    <tr><td><code>Tab:AddBind</code></td><td><code>Tab:Keybind</code>, <code>Tab:Hotkey</code></td></tr>
    <tr><td><code>Tab:AddColorpicker</code></td><td><code>Tab:ColorPick</code>, <code>Tab:ColorPicker</code>, <code>Tab:AddColorPicker</code></td></tr>
    <tr><td><code>Tab:AddSection</code></td><td><code>Tab:Group</code></td></tr>
  </table>

  <h2 id="example">🧪 Full Example</h2>
<pre><code>local Lunarion = loadstring(game:HttpGet("https://raw.githubusercontent.com/surrre4l/Lunarion/main/Lunarion.lua"))()

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

Lunarion:Init()</code></pre>

  <hr>
  <blockquote><strong>Lunarion is client-side only.</strong> Pre-Beta Release V3.0.0 — combine with an obfuscator and a server-checked key for production use.</blockquote>
</main>

</div>
</body>
</html>