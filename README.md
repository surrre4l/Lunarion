🌙 Lunarion

<p align="center">
  <img src="https://img.shields.io/badge/Lunarion-UI%20Library-8B5CF6?style=for-the-badge" alt="Lunarion">
  <img src="https://img.shields.io/badge/Roblox-Lua-00A2FF?style=for-the-badge&logo=roblox" alt="Roblox Lua">
  <img src="https://img.shields.io/badge/Status-Active-22C55E?style=for-the-badge" alt="Status">
</p><p align="center">
  A modern, customizable Roblox UI library built for clean and flexible interfaces.
</p>---

✨ Features

- 🌙 Modern and customizable UI
- 📱 Mobile-friendly interface
- 🎨 Built-in themes
- 🧩 Buttons, toggles, sliders, dropdowns, inputs, binds, and more
- 🎨 Colorpicker support
- 🖼️ Multiple icon providers
- 🏠 Optional Homeboard
- 📑 Flexible tab and section system
- ⚙️ Configuration and flag support
- 🔄 Refreshable UI elements
- 🧱 Custom tab styles

📦 Installation

Load Lunarion directly:

local Lunarion = loadstring(game:HttpGet(
    "https://h.uguu.se/JtkDzXsm.lua"
))()

🪟 Creating a Window

local Window = Lunarion:MakeWindow({
    Name = "My Hub",
    Subtitle = "Powered by Lunarion",
    LogoID = 124779391499370,
    Homeboard = true,
    Theme = "Lunarion"
})

📑 Creating a Tab

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home"
})

🧩 Elements

Lunarion provides a flexible element API:

AddButton
AddToggle
AddSlider
AddDropdown
AddInput
AddBind
AddColorpicker
AddParagraph
AddSection

Example:

MainTab:AddButton({
    Name = "Test Button",
    Callback = function()
        print("Hello from Lunarion!")
    end
})

🎨 Themes

Lunarion currently includes:

Theme
Lunarion
Default
Amethyst
Ocean
Rose
Emerald
Light
Sakura

Example:

Theme = "Amethyst"

🗂️ Tab Styles

Lunarion supports multiple tab layouts:

Window:SetTabStyle("Top")
Window:SetTabStyle("Side")
Window:SetTabStyle("Toggle")

🏠 Homeboard

Enable the Homeboard when creating your window:

Homeboard = true

The Homeboard provides a dashboard-style starting interface for your UI.

🔐 Key System

Lunarion includes a built-in key system:

local Verified = Lunarion:MakeKeySystem({
    Title = "Key System",
    Subtitle = "Enter your key",
    Key = "YOUR_KEY",
    SaveKey = true
})

if not Verified then
    return
end

🖼️ Icons

Lunarion supports several icon sources, including:

- Lucide
- Material
- Feather
- Custom icons

«[!NOTE]
All Icons credits to Nebula Softworks.»

📚 Inspiration

Lunarion is based off LunaUI and OrionLib, combining ideas from both libraries into its own interface system and API.

Lunarion is not intended to be a direct copy of either library.

📁 Repository Structure

Lunarion/
├── Lunarion.lua
├── README.md
├── LICENSE
└── docs/
    └── API.md

🤖 Lunae

Lunae is an AI assistant built specifically around Lunarion.

It can help developers:

- Understand the Lunarion API
- Find documented functions
- Build UI examples
- Debug Lunarion code
- Explain elements and parameters

🛠️ Development

Clone the repository:

git clone https://github.com/surrre4l/Lunarion.git
cd Lunarion

Then make your changes and submit a pull request.

🐛 Issues

Found a bug or have a feature request?

Open an issue in the repository's Issues tab.

When reporting a bug, include:

- Roblox environment
- Lunarion version
- Relevant code
- Expected behavior
- Actual behavior
- Error message, if any

🤝 Contributing

Contributions are welcome.

1. Fork the repository
2. Create a new branch
3. Make your changes
4. Test your changes
5. Open a pull request

Please keep contributions focused and maintainable.

📄 License

See ""LICENSE"" (LICENSE) for the applicable license and usage terms.

---

<p align="center">
  Made with 🌙 for Roblox UI developers
</p>