--[[



██╗     ██╗   ██╗███╗   ██╗ █████╗ ██████╗ ██╗ ██████╗ ███╗   ██╗
██║     ██║   ██║████╗  ██║██╔══██╗██╔══██╗██║██╔═══██╗████╗  ██║
██║     ██║   ██║██╔██╗ ██║███████║██████╔╝██║██║   ██║██╔██╗ ██║
██║     ██║   ██║██║╚██╗██║██╔══██║██╔══██╗██║██║   ██║██║╚██╗██║
███████╗╚██████╔╝██║ ╚████║██║  ██║██║  ██║██║╚██████╔╝██║ ╚████║
╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝
by    .d8888. db    db d8888b. d8888b. d8888b. d88888b    d88  db
      88'  YP 88    88 88  `8D 88  `8D 88  `8D 88'       d888  88
      `8bo.   88    88 88oobY' 88oobY' 88oobY' 88ooooo  d8'88  88
        `Y8b. 88    88 88`8b   88`8b   88`8b   88~~~~~ d8oo88o 88
      db   8D 88b  d88 88 `88. 88 `88. 88 `88. 88.     `~~~88~ 88booo.
      `8888Y' ~Y8888P' 88   YD 88   YD 88   YD Y88888P     YP  Y88888P

    Lunarion UI Library  |  made by surrre4L

    Icon credits (loaded on demand, nothing is embedded):
      - Lucide Icons          ISC license   (lucide.dev, via latte-soft/lucide-roblox)
      - Solar Icon Set        CC BY 4.0     (c) 480 Design - https://github.com/480-Design/Solar-Icon-Set
      - Gravity UI Icons      MIT license   (c) YANDEX LLC - https://github.com/gravity-ui/icons
      Solar, Gravity and Lucide are loaded through Footagesus/Icons (MIT).

]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

-- ============================================================================================
-- Shield: client-side integrity layer.
--  * every instance is created non-archivable, so :Clone() and saveinstance() come back empty
--  * the ScreenGui gets a random name every run (nothing to search for in an explorer)
--  * a watchdog looks for instance browsers / remote spies next to the UI; when one shows up the UI
--    wipes itself (frames, flags, config cache, connections) and refuses to build again
--  * the public table is a locked proxy: no internals, API functions cannot be overwritten, no raw metatable
-- Turn the watchdog off while developing with MakeWindow({Security = false}).
-- A client can never be made 100% tamper-proof; combine this with an obfuscator and a server-checked key.
-- ============================================================================================
local Shield = {Tripped = false, Strikes = 0, Started = false, Tag = "lz_7f3a91"}
do
	local Alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	function Shield.Rand(Length)
		local Out = {}
		for Index = 1, Length do
			local Pick = math.random(1, #Alphabet)
			Out[Index] = string.sub(Alphabet, Pick, Pick)
		end
		return table.concat(Out)
	end

	local Known = {
		dex = true, darkdex = true, dexexplorer = true, dexv2 = true, dexv3 = true, dexv4 = true,
		remotespy = true, simplespy = true, simplespyv3 = true, hydroxide = true, cobalt = true,
		cobaltspy = true, scriptdumper = true, saveinstance = true, decompiler = true, explorer = true
	}
	local function Normalise(Name)
		return (string.lower(tostring(Name)):gsub("[^%w]", ""))
	end

	function Shield.Inspecting()
		local Hosts = {}
		if gethui then
			pcall(function() table.insert(Hosts, gethui()) end)
		end
		pcall(function() table.insert(Hosts, game:GetService("CoreGui")) end)
		for _, Host in ipairs(Hosts) do
			local Ok, Kids = pcall(function() return Host:GetChildren() end)
			if Ok then
				for _, Kid in ipairs(Kids) do
					if Kid ~= Shield.Root then
						local Name = Normalise(Kid.Name)
						if Known[Name] then
							return true
						end
					end
				end
			end
		end
		return false
	end

	function Shield.Trip()
		if Shield.Tripped then
			return
		end
		Shield.Tripped = true
		pcall(function()
			if Shield.OnTrip then
				Shield.OnTrip()
			end
		end)
	end

	function Shield.Start()
		if Shield.Started then
			return
		end
		Shield.Started = true
		task.spawn(function()
			while Shield.Root and Shield.Root.Parent and not Shield.Tripped do
				if Shield.Inspecting() then
					Shield.Strikes = Shield.Strikes + 1
				else
					Shield.Strikes = 0
				end
				if Shield.Strikes >= 2 then
					Shield.Trip()
					break
				end
				pcall(function()
					if Shield.Root.Archivable ~= false then
						Shield.Root.Archivable = false
					end
				end)
				task.wait(1.2 + math.random())
			end
		end)
	end
end

-- Typography
--   Title    : Atkinson Hyperlegible Bold (titles, bold headings)
--   Body     : Helvetica (buttons, labels, everything normal)
--   Thin     : Bahnschrift (subtitles, author line)
-- Roblox ships none of these three, so they are loaded as custom fonts when your executor can do it
-- (writefile + getcustomasset). Atkinson Hyperlegible is free and downloads itself. Helvetica and Bahnschrift are
-- licensed fonts, so Lunarion never downloads them: drop your own copies into  <workspace>/Lunarion/Fonts/
-- named  Helvetica.ttf  and  Bahnschrift.ttf  (Helvetica-Bold.ttf etc. are not needed).
-- Anything missing falls back to a close built-in face (Arimo ~ Helvetica, Roboto Condensed ~ Bahnschrift).
local FontDir = "Lunarion/Fonts"
local FontPlan = {
	Title = {Name = "AtkinsonHyperlegible", Files = {"AtkinsonHyperlegible-Bold.ttf", "AtkinsonHyperlegible-Bold.otf"}, Weight = 700,
		Url = "https://raw.githubusercontent.com/googlefonts/atkinson-hyperlegible/main/fonts/ttf/AtkinsonHyperlegible-Bold.ttf",
		Fallback = {"rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold}},
	Body = {Name = "Helvetica", Files = {"Helvetica.ttf", "Helvetica.otf", "HelveticaNeue.ttf"}, Weight = 400,
		Fallback = {"rbxasset://fonts/families/Arimo.json", Enum.FontWeight.Regular}},
	Thin = {Name = "Bahnschrift", Files = {"Bahnschrift.ttf", "bahnschrift.ttf"}, Weight = 400,
		Fallback = {"rbxasset://fonts/families/RobotoCondensed.json", Enum.FontWeight.Regular}}
}

local function MakeFace(Family, Weight)
	local Ok, Face = pcall(function()
		return Font.new(Family, Weight, Enum.FontStyle.Normal)
	end)
	return Ok and Face or Font.fromEnum(Enum.Font.Gotham)
end

local function CanCustomFonts()
	return type(writefile) == "function" and type(isfile) == "function" and type(getcustomasset) == "function"
end

-- returns a Font made from a local / downloaded file, or nil
local function LoadCustomFace(Plan)
	if not CanCustomFonts() then
		return nil
	end
	local Found
	pcall(function()
		if makefolder and isfolder then
			for _, Folder in ipairs({"Lunarion", FontDir}) do
				if not isfolder(Folder) then makefolder(Folder) end
			end
		end
		for _, File in ipairs(Plan.Files) do
			if isfile(FontDir .. "/" .. File) then
				Found = FontDir .. "/" .. File
				return
			end
		end
		if Plan.Url then
			local Path = FontDir .. "/" .. Plan.Files[1]
			writefile(Path, game:HttpGet(Plan.Url))
			Found = Path
		end
	end)
	if not Found then
		return nil
	end
	local Face
	local Ok = pcall(function()
		local FamilyPath = FontDir .. "/" .. Plan.Name .. ".json"
		writefile(FamilyPath, game:GetService("HttpService"):JSONEncode({
			name = Plan.Name,
			faces = {{name = "Regular", weight = Plan.Weight, style = "normal", assetId = getcustomasset(Found)}}
		}))
		Face = Font.new(getcustomasset(FamilyPath), Plan.Weight >= 700 and Enum.FontWeight.Bold or Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	end)
	return Ok and Face or nil
end

local Fonts = {}
for Key, Plan in pairs(FontPlan) do
	Fonts[Key] = LoadCustomFace(Plan) or MakeFace(Plan.Fallback[1], Plan.Fallback[2])
end

local function MeasureText(Text, Size, Face, Bounds)
	local Ok, Result = pcall(function()
		local Params = Instance.new("GetTextBoundsParams")
		Params.Text = Text
		Params.Font = Face
		Params.Size = Size
		Params.Width = Bounds.X
		return TextService:GetTextBoundsAsync(Params)
	end)
	if Ok and Result then
		return Result
	end
	return TextService:GetTextSize(Text, Size, Enum.Font.Gotham, Bounds)
end

local Lunarion = {
	Name = "Lunarion",
	Version = "3.0.0",
	Elements = {},
	ThemeObjects = {},
	ThemeListeners = {},
	Connections = {},
	Flags = {},
	Themes = {
		Lunarion = {
			Main = Color3.fromRGB(16, 17, 27),
			Second = Color3.fromRGB(23, 25, 39),
			Stroke = Color3.fromRGB(52, 56, 86),
			Divider = Color3.fromRGB(52, 56, 86),
			Text = Color3.fromRGB(236, 239, 250),
			TextDark = Color3.fromRGB(140, 148, 180),
			Accent = Color3.fromRGB(128, 140, 255),
			GradientFrom = Color3.fromRGB(40, 44, 86),
			GradientTo = Color3.fromRGB(14, 15, 25),
			GradientRotation = 20
		},
		Default = {
			Main = Color3.fromRGB(25, 25, 25),
			Second = Color3.fromRGB(32, 32, 32),
			Stroke = Color3.fromRGB(60, 60, 60),
			Divider = Color3.fromRGB(60, 60, 60),
			Text = Color3.fromRGB(240, 240, 240),
			TextDark = Color3.fromRGB(150, 150, 150),
			Accent = Color3.fromRGB(9, 99, 195),
			GradientFrom = Color3.fromRGB(45, 45, 52),
			GradientTo = Color3.fromRGB(20, 20, 24),
			GradientRotation = 15
		},
		Amethyst = {
			Main = Color3.fromRGB(22, 20, 30),
			Second = Color3.fromRGB(30, 27, 42),
			Stroke = Color3.fromRGB(58, 52, 82),
			Divider = Color3.fromRGB(58, 52, 82),
			Text = Color3.fromRGB(240, 236, 250),
			TextDark = Color3.fromRGB(150, 142, 176),
			Accent = Color3.fromRGB(139, 92, 246),
			GradientFrom = Color3.fromRGB(56, 42, 92),
			GradientTo = Color3.fromRGB(22, 20, 30),
			GradientRotation = 20
		},
		Ocean = {
			Main = Color3.fromRGB(16, 24, 30),
			Second = Color3.fromRGB(22, 33, 41),
			Stroke = Color3.fromRGB(44, 66, 80),
			Divider = Color3.fromRGB(44, 66, 80),
			Text = Color3.fromRGB(232, 244, 248),
			TextDark = Color3.fromRGB(130, 158, 172),
			Accent = Color3.fromRGB(20, 184, 166),
			GradientFrom = Color3.fromRGB(18, 52, 60),
			GradientTo = Color3.fromRGB(14, 20, 26),
			GradientRotation = 15
		},
		Rose = {
			Main = Color3.fromRGB(28, 20, 24),
			Second = Color3.fromRGB(38, 27, 32),
			Stroke = Color3.fromRGB(74, 52, 62),
			Divider = Color3.fromRGB(74, 52, 62),
			Text = Color3.fromRGB(250, 236, 242),
			TextDark = Color3.fromRGB(170, 140, 154),
			Accent = Color3.fromRGB(244, 63, 94),
			GradientFrom = Color3.fromRGB(70, 30, 44),
			GradientTo = Color3.fromRGB(28, 20, 24),
			GradientRotation = 15
		},
		Emerald = {
			Main = Color3.fromRGB(18, 26, 21),
			Second = Color3.fromRGB(25, 36, 29),
			Stroke = Color3.fromRGB(48, 70, 55),
			Divider = Color3.fromRGB(48, 70, 55),
			Text = Color3.fromRGB(236, 248, 240),
			TextDark = Color3.fromRGB(140, 168, 150),
			Accent = Color3.fromRGB(34, 197, 94),
			GradientFrom = Color3.fromRGB(30, 62, 42),
			GradientTo = Color3.fromRGB(16, 24, 19),
			GradientRotation = 15
		},
		Light = {
			Main = Color3.fromRGB(240, 240, 244),
			Second = Color3.fromRGB(255, 255, 255),
			Stroke = Color3.fromRGB(212, 212, 222),
			Divider = Color3.fromRGB(212, 212, 222),
			Text = Color3.fromRGB(30, 30, 36),
			TextDark = Color3.fromRGB(110, 110, 122),
			Accent = Color3.fromRGB(37, 99, 235),
			GradientFrom = Color3.fromRGB(255, 255, 255),
			GradientTo = Color3.fromRGB(222, 226, 236),
			GradientRotation = 15
		},
		Sakura = {
			Main = Color3.fromRGB(30, 22, 27),
			Second = Color3.fromRGB(40, 29, 35),
			Stroke = Color3.fromRGB(82, 56, 68),
			Divider = Color3.fromRGB(82, 56, 68),
			Text = Color3.fromRGB(253, 240, 245),
			TextDark = Color3.fromRGB(196, 152, 170),
			Accent = Color3.fromRGB(244, 143, 177),
			GradientFrom = Color3.fromRGB(94, 48, 70),
			GradientTo = Color3.fromRGB(30, 22, 27),
			GradientRotation = 25
		}
	},
	SelectedTheme = "Lunarion",
	Folder = nil,
	SaveCfg = false,
	LoadedConfig = {},
	ConfigLoaded = false,
	ConfigName = nil,
	Analytics = {
		Enabled = false, -- turn on with Lunarion:EnableAnalytics() or WindowConfig.Analytics = true
		Log = {},        -- {Event = "...", Data = {...}, Time = os.time()} entries, newest last
		Counts = {}       -- Counts[EventName] = number of times it fired
	}
}

-- Platform detection: "Mobile" (touch, no keyboard), "Console" (gamepad / ten-foot UI) or "PC"
local function DetectPlatform()
	local Touch = UserInputService.TouchEnabled
	local Keyboard = UserInputService.KeyboardEnabled
	local Gamepad = UserInputService.GamepadEnabled
	local TenFoot = false
	pcall(function()
		TenFoot = GuiService:IsTenFootInterface()
	end)
	if TenFoot or (Gamepad and not Keyboard and not Touch) then
		return "Console"
	end
	if Touch and not Keyboard then
		return "Mobile"
	end
	return "PC"
end
Lunarion.Platform = DetectPlatform()

-- ============================================================================================
-- Icons: nothing is embedded. Icon libraries are loaded on demand and cached.
--   "home"            -> default set (Lucide unless you call Lunarion:SetIconSet("solar"))
--   "solar:home-2-bold", "lucide:home", "gravity:..."
--   "rbxassetid://123" / a number / a URL -> used as is
-- Add your own library: Lunarion:AddIconLibrary("name", function(IconName) return {Image = ..., RectSize = ..., RectOffset = ...} end)
-- ============================================================================================
local IconLibraries = {}
local DefaultIconSet = "lucide"
local Aliases = { -- old Material-style names still resolve to the right icon
	visibility_off = "eye-off", report_problem = "triangle-alert", check_circle = "circle-check",
	auto_awesome = "sparkles", dashboard = "layout-dashboard", forum = "message-square", menu = "menu",
	computer = "monitor", group = "users", groups = "users-round", network_check = "signal", people = "users",
	public = "globe", schedule = "clock", speed = "gauge", sports_esports = "gamepad-2", home = "house"
}

local function Trim(Text)
	return (tostring(Text):gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Lucide (latte-soft/lucide-roblox spritesheet)
local LucideSet, LucideTried = nil, false
local function LoadLucide()
	if LucideTried then
		return LucideSet
	end
	LucideTried = true
	local Ok, Result = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/latte-soft/lucide-roblox/refs/heads/master/lib/Icons.luau"))()
	end)
	if Ok and type(Result) == "table" then
		LucideSet = Result["48px"]
	else
		warn("\nLunarion - Failed to load Lucide Icons.\n")
	end
	return LucideSet
end
IconLibraries.lucide = function(Name)
	local Set = LoadLucide()
	if not Set then return nil end
	local Key = string.lower(Trim(Name))
	local Entry = Set[Key] or Set[(Key:gsub("_", "-"))] or Set[(Key:gsub(" ", "-"))] or Set[Aliases[Key] or ""]
	if type(Entry) ~= "table" or type(Entry[1]) ~= "number" or type(Entry[2]) ~= "table" or type(Entry[3]) ~= "table" then
		return nil
	end
	return {
		Image = "rbxassetid://" .. Entry[1],
		RectSize = Vector2.new(Entry[2][1], Entry[2][2]),
		RectOffset = Vector2.new(Entry[3][1], Entry[3][2])
	}
end

-- Solar and Gravity (Footagesus/Icons, one asset per icon)
local Pack, PackTried = nil, false
local function LoadPack()
	if PackTried then
		return Pack
	end
	PackTried = true
	local Ok, Result = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
	end)
	if Ok and type(Result) == "table" then
		Pack = Result
	else
		warn("\nLunarion - Failed to load the extra icon pack (solar / gravity).\n")
	end
	return Pack
end
for _, SetName in ipairs({"solar", "gravity"}) do
	IconLibraries[SetName] = function(Name)
		local Loaded = LoadPack()
		if not Loaded or not Loaded.GetIcon then return nil end
		local Ok, Image = pcall(Loaded.GetIcon, SetName .. ":" .. Trim(Name))
		if Ok and type(Image) == "string" and Image ~= "" then
			return {Image = Image}
		end
		return nil
	end
end
IconLibraries.custom = function(Name)
	return {Image = "rbxassetid://" .. Name}
end
IconLibraries.material, IconLibraries.feather = IconLibraries.lucide, IconLibraries.lucide -- old source names map to Lucide

function Lunarion:AddIconLibrary(Name, Resolver)
	IconLibraries[string.lower(tostring(Name))] = Resolver
end
function Lunarion:SetIconSet(Name)
	Name = string.lower(tostring(Name))
	if IconLibraries[Name] then
		DefaultIconSet = Name
	end
end
function Lunarion:GetIconSets()
	local Out = {}
	for Name in pairs(IconLibraries) do table.insert(Out, Name) end
	table.sort(Out)
	return Out
end

local function ResolveIcon(Icon, Source)
	if Icon == nil or Icon == "" then
		return nil
	end
	if type(Icon) == "number" then
		return {Image = "rbxassetid://" .. Icon}
	end
	Icon = tostring(Icon)
	if string.find(Icon, "^rbx") or string.find(Icon, "^https?://") then
		return {Image = Icon}
	end
	if string.match(Icon, "^%d+$") then
		return {Image = "rbxassetid://" .. Icon}
	end
	local Prefix, Name = string.match(Icon, "^(%a+):(.+)$")
	if Prefix and IconLibraries[string.lower(Prefix)] then
		Source, Icon = Prefix, Name
	end
	local Library = IconLibraries[string.lower(tostring(Source or DefaultIconSet))] or IconLibraries[DefaultIconSet]
	local Found = Library and Library(Icon)
	if Found then
		return Found
	end
	-- fall back to Lucide so a missing icon in one library never leaves a hole
	return IconLibraries.lucide(Icon)
end

local function ApplyIcon(Object, Icon, Source)
	local Resolved = ResolveIcon(Icon, Source)
	if not Resolved then
		if type(Icon) == "string" and Icon ~= "" then
			Object.Image = Icon
		end
		return
	end
	Object.Image = Resolved.Image
	Object.ImageRectSize = Resolved.RectSize or Vector2.new(0, 0)
	Object.ImageRectOffset = Resolved.RectOffset or Vector2.new(0, 0)
end

local Root = Instance.new("ScreenGui")
Root.Name = Shield.Rand(math.random(12, 20))
Root.Archivable = false
Root:SetAttribute(Shield.Tag, true)
Shield.Root = Root
Root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- layers: 1 notifications, 2 window, 3 search
Root.ResetOnSpawn = false
if syn then
	syn.protect_gui(Root)
	Root.Parent = game.CoreGui
else
	Root.Parent = (gethui and gethui()) or game.CoreGui
end

for _, Host in ipairs({(gethui and gethui()) or game.CoreGui}) do
	for _, Interface in ipairs(Host:GetChildren()) do
		if Interface ~= Root and Interface:GetAttribute(Shield.Tag) then
			Interface:Destroy()
		end
	end
end
Shield.OnTrip = function()
	for _, Connection in ipairs(Lunarion.Connections) do
		pcall(function() Connection:Disconnect() end)
	end
	table.clear(Lunarion.Connections)
	table.clear(Lunarion.Flags)
	table.clear(Lunarion.LoadedConfig)
	table.clear(Lunarion.ThemeObjects)
	table.clear(Lunarion.ThemeListeners)
	pcall(function() Root:ClearAllChildren() end)
	pcall(function() Root:Destroy() end)
end
Root.DescendantAdded:Connect(function(Descendant)
	pcall(function()
		Descendant.Archivable = false
	end)
end)

function Lunarion:IsRunning()
	if gethui then
		return Root.Parent == gethui()
	else
		return Root.Parent == game:GetService("CoreGui")
	end

end

local function AddConnection(Signal, Function)
	if (not Lunarion:IsRunning()) then
		return
	end
	local SignalConnect = Signal:Connect(Function)
	table.insert(Lunarion.Connections, SignalConnect)
	return SignalConnect
end

task.spawn(function()
	while (Lunarion:IsRunning()) do
		task.wait()
	end

	for _, Connection in next, Lunarion.Connections do
		Connection:Disconnect()
	end
end)

-- A drag follow-tween that is still running while the window closes fights the close animation for the
-- window's Position every frame, that is what made the close shake. Track it so it can be cancelled.
local DragTweens = setmetatable({}, {__mode = "k"})
local DragLocks = setmetatable({}, {__mode = "k"})
local function CancelDragTween(Main)
	local Running = DragTweens[Main]
	if Running then
		Running:Cancel()
		DragTweens[Main] = nil
	end
end

local function AddDraggingFunctionality(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false
		local function ClampWindowPosition(Position)
			local Cam = workspace.CurrentCamera
			local View = Cam and Cam.ViewportSize or Vector2.new(1280, 720)
			local Size = Main.AbsoluteSize
			local Pad = 8
			local MinX = Pad
			local MinY = Pad
			local MaxX = math.max(MinX, View.X - Size.X - 28)
			local MaxY = math.max(MinY, View.Y - Size.Y - 28)
			local AbsoluteX = View.X * Position.X.Scale + Position.X.Offset
			local AbsoluteY = View.Y * Position.Y.Scale + Position.Y.Offset
			AbsoluteX = math.clamp(AbsoluteX, MinX, MaxX)
			AbsoluteY = math.clamp(AbsoluteY, MinY, MaxY)
			return UDim2.new(Position.X.Scale, AbsoluteX - View.X * Position.X.Scale, Position.Y.Scale, AbsoluteY - View.Y * Position.Y.Scale)
		end

		DragPoint.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				if DragLocks[Main] then return end
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position
				CancelDragTween(Main)
				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
						CancelDragTween(Main)
					end
				end)
			end
		end)
		DragPoint.InputChanged:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
				DragInput = Input
			end
		end)
		UserInputService.InputChanged:Connect(function(Input)
			if Input == DragInput and Dragging and not DragLocks[Main] then
				local Delta = Input.Position - MousePos
				local Target = UDim2.new(
					FramePos.X.Scale, FramePos.X.Offset + Delta.X,
					FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y
				)
				Target = ClampWindowPosition(Target)
				Main.Position = Target
			end
		end)
	end)
end   

local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	pcall(function()
		Object.Archivable = false
	end)
	for i, v in next, Properties or {} do
		Object[i] = v
	end
	for i, v in next, Children or {} do
		v.Parent = Object
	end
	return Object
end

local function CreateElement(ElementName, ElementFunction)
	Lunarion.Elements[ElementName] = function(...)
		return ElementFunction(...)
	end
end

local function MakeElement(ElementName, ...)
	local NewElement = Lunarion.Elements[ElementName](...)
	return NewElement
end

local function SetProps(Element, Props)
	for Property, Value in pairs(Props) do
		Element[Property] = Value
	end
	return Element
end

local function SetChildren(Element, Children)
	for _, Child in pairs(Children) do
		Child.Parent = Element
	end
	return Element
end

local function Round(Number, Factor)
	local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then Result = Result + Factor end
	return Result
end

local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then
		return "BackgroundColor3"
	end 
	if Object:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	end 
	if Object:IsA("UIStroke") then
		return "Color"
	end 
	if Object:IsA("TextLabel") or Object:IsA("TextBox") then
		return "TextColor3"
	end   
	if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
		return "ImageColor3"
	end   
end

local function ThemeColor(Name)
	local Theme = Lunarion.Themes[Lunarion.SelectedTheme] or Lunarion.Themes.Default
	return Theme[Name] or Lunarion.Themes.Default[Name]
end

-- customizable per-theme gradient: set GradientFrom / GradientTo / GradientRotation on any theme
-- (via Lunarion:AddTheme or the Themes = {} table in MakeWindow) to change how gradients look everywhere.
local function ThemeGradient()
	local Theme = Lunarion.Themes[Lunarion.SelectedTheme] or Lunarion.Themes.Default
	local Main, Accent = ThemeColor("Main"), ThemeColor("Accent")
	local From = Theme.GradientFrom or Lunarion.Themes.Default.GradientFrom or Main:Lerp(Accent, 0.4)
	local To = Theme.GradientTo or Lunarion.Themes.Default.GradientTo or Main
	local Rotation = Theme.GradientRotation or Lunarion.Themes.Default.GradientRotation or 15
	return From, To, Rotation
end

local function AddThemeObject(Object, Type)
	if not Lunarion.ThemeObjects[Type] then
		Lunarion.ThemeObjects[Type] = {}
	end
	table.insert(Lunarion.ThemeObjects[Type], Object)
	Object[ReturnProperty(Object)] = ThemeColor(Type)
	-- neutral gray, semi-transparent scrollbars everywhere (never the accent/blue)
	if Object:IsA("ScrollingFrame") then
		Object.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
		Object.ScrollBarImageTransparency = 1
		Object.ScrollBarThickness = 0
	end
	return Object
end

local function SetTheme(Animate)
	for Name, Objects in pairs(Lunarion.ThemeObjects) do
		for Index = #Objects, 1, -1 do
			if not Objects[Index].Parent then
				table.remove(Objects, Index)
			end
		end
		local Color = ThemeColor(Name)
		for _, Object in pairs(Objects) do
			local Property = ReturnProperty(Object)
			if Property and Object.Parent then
				if Animate then
					TweenService:Create(Object, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {[Property] = Color}):Play()
				else
					Object[Property] = Color
				end
			end
		end
	end
	for _, Listener in pairs(Lunarion.ThemeListeners) do
		pcall(Listener)
	end
end

local ActiveTweens = setmetatable({}, {__mode = "k"})
local function Tw(Object, Time, Style, Direction, Props)
	-- an older tween that only animates properties this one also animates is cancelled, so quick
	-- hover / press changes never fight each other (less jitter, fewer live tweens)
	local Running = ActiveTweens[Object]
	if Running then
		for Index = #Running, 1, -1 do
			local Entry = Running[Index]
			local Covered = true
			for Prop in pairs(Entry.Props) do
				if Props[Prop] == nil then
					Covered = false
					break
				end
			end
			if Covered then
				Entry.Tween:Cancel()
				table.remove(Running, Index)
			end
		end
	else
		Running = {}
		ActiveTweens[Object] = Running
	end
	local Tween = TweenService:Create(Object, TweenInfo.new(Time, Style or Enum.EasingStyle.Quint, Direction or Enum.EasingDirection.Out), Props)
	local Entry = {Tween = Tween, Props = Props}
	table.insert(Running, Entry)
	Tween.Completed:Once(function()
		local Index = table.find(Running, Entry)
		if Index then
			table.remove(Running, Index)
		end
	end)
	Tween:Play()
	return Tween
end

-- lightens dark colors and darkens light colors, so hover states work in every theme
local function Shift(Color, Amount)
	local Luminance = Color.R * 0.3 + Color.G * 0.59 + Color.B * 0.11
	if Luminance > 0.6 then
		Amount = -Amount
	end
	return Color3.fromRGB(
		math.clamp(Color.R * 255 + Amount, 0, 255),
		math.clamp(Color.G * 255 + Amount, 0, 255),
		math.clamp(Color.B * 255 + Amount, 0, 255)
	)
end

-- runs a user callback safely; on error the element flashes red for a moment
local function RunCallback(Frame, Callback, ...)
	local Ok, Err = pcall(Callback, ...)
	if not Ok then
		warn("Lunarion | Callback error: " .. tostring(Err))
		if Frame then
			Tw(Frame, 0.2, nil, nil, {BackgroundColor3 = Color3.fromRGB(85, 0, 0)})
			task.delay(0.6, function()
				Tw(Frame, 0.4, nil, nil, {BackgroundColor3 = ThemeColor("Second")})
			end)
		end
	end
end

local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function ConfigPath()
	return Lunarion.Folder .. "/" .. tostring(Lunarion.ConfigName or game.GameId) .. ".txt"
end

-- manual loader (kept for compatibility); the auto system below normally does this for you
local function LoadCfg(Config)
	local Data = type(Config) == "string" and HttpService:JSONDecode(Config) or Config
	for Key, Value in pairs(Data) do
		if string.sub(tostring(Key), 1, 2) ~= "__" then
			local Flag = Lunarion.Flags[Key]
			if Flag then
				task.spawn(function()
					if Flag.Type == "Colorpicker" then
						Flag:Set(UnpackColor(Value))
					else
						Flag:Set(Value)
					end
				end)
			else
				warn("Lunarion Config Loader - Could not find ", Key, Value)
			end
		end
	end
end

local function SaveCfg()
	local Data = {}
	-- keep values of elements that have not been created (yet) so nothing gets lost
	for Key, Value in pairs(Lunarion.LoadedConfig) do
		Data[Key] = Value
	end
	for Key, Flag in pairs(Lunarion.Flags) do
		if Flag.Save then
			if Flag.Type == "Colorpicker" then
				Data[Key] = PackColor(Flag.Value)
			else
				Data[Key] = Flag.Value
			end
		end
	end
	Data.__Theme = Lunarion.SelectedTheme
	writefile(ConfigPath(), HttpService:JSONEncode(Data))
	Lunarion.LoadedConfig = Data
end

-- called by every element right after it registers its Flag: restores the saved value
local function ApplySaved(FlagName, Object)
	if not Lunarion.SaveCfg or not Object.Save then
		return
	end
	local Saved = Lunarion.LoadedConfig[FlagName]
	if Saved == nil then
		return
	end
	pcall(function()
		if Object.Type == "Colorpicker" then
			Object:Set(UnpackColor(Saved))
		else
			Object:Set(Saved)
		end
	end)
end

-- debounced: many changes in a row (dragging a slider) result in a single file write
local SavePending = false
local function AutoSave()
	if not Lunarion.SaveCfg or SavePending then
		return
	end
	SavePending = true
	task.delay(0.4, function()
		SavePending = false
		pcall(SaveCfg)
	end)
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Up,Enum.KeyCode.Left,Enum.KeyCode.Down,Enum.KeyCode.Right,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.Escape}

local function CheckKey(Table, Key)
	for _, v in next, Table do
		if v == Key then
			return true
		end
	end
end

CreateElement("Corner", function(Scale, Offset)
	local Corner = Create("UICorner", {
		CornerRadius = UDim.new(Scale or 0, Offset or 10)
	})
	return Corner
end)

CreateElement("Stroke", function(Color, Thickness)
	local Stroke = Create("UIStroke", {
		Color = Color or Color3.fromRGB(255, 255, 255),
		Thickness = Thickness or 1
	})
	return Stroke
end)

CreateElement("List", function(Scale, Offset)
	local List = Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(Scale or 0, Offset or 0)
	})
	return List
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
	local Padding = Create("UIPadding", {
		PaddingBottom = UDim.new(0, Bottom or 4),
		PaddingLeft = UDim.new(0, Left or 4),
		PaddingRight = UDim.new(0, Right or 4),
		PaddingTop = UDim.new(0, Top or 4)
	})
	return Padding
end)

CreateElement("TFrame", function()
	local TFrame = Create("Frame", {
		BackgroundTransparency = 1
	})
	return TFrame
end)

CreateElement("Frame", function(Color)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	})
	return Frame
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(Scale, Offset)
		})
	})
	return Frame
end)

CreateElement("Button", function()
	local Button = Create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	return Button
end)

CreateElement("ScrollFrame", function(Color, Width)
	local ScrollFrame = Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		MidImage = "rbxassetid://7445543667",
		BottomImage = "rbxassetid://7445543667",
		TopImage = "rbxassetid://7445543667",
		ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150),
		ScrollBarImageTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0, -- no scrollbars: scrolling still works by wheel / touch
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})
	return ScrollFrame
end)

CreateElement("Image", function(ImageID, ImageSource)
	local ImageNew = Create("ImageLabel", {
		BackgroundTransparency = 1
	})

	ApplyIcon(ImageNew, ImageID, ImageSource)

	return ImageNew
end)

CreateElement("ImageButton", function(ImageID)
	local Image = Create("ImageButton", {
		Image = ImageID,
		BackgroundTransparency = 1
	})
	return Image
end)

CreateElement("Label", function(Text, TextSize, Transparency)
	local Label = Create("TextLabel", {
		Text = Text or "",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = Transparency or 0,
		TextSize = TextSize or 15,
		FontFace = Fonts.Body,
		RichText = true,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	return Label
end)

local NotifWidth = Lunarion.Platform == "Console" and 360 or 300
local NotifOrder = 0
local NotifColors = {
	success = Color3.fromRGB(34, 197, 94),
	warning = Color3.fromRGB(245, 158, 11),
	error = Color3.fromRGB(239, 68, 68)
}

local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
	SetProps(MakeElement("List"), {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 0)
	})
}), {
	Position = UDim2.new(1, -25, 1, -25),
	Size = UDim2.new(0, NotifWidth, 1, -25),
	AnchorPoint = Vector2.new(1, 1),
	ZIndex = 1, -- layer 1: the window (layer 2) always sits on top of notifications
	Parent = Root
})

-- Glassmorphic notification: a translucent rounded card (not a pill) with a soft glass stroke and sheen.
-- Enter: it rises in slightly small, grows to size and un-fades. Exit: it drifts DOWN and SHRINKS (same rounded
-- shape, it never turns into a pill), then fades away, then the space closes up.
-- Config: Name/Title, Content, Image/Icon (+ImageSource), Time/Duration (seconds, default 15; 0 / false / math.huge = stays until clicked),
--         Type ("success" | "warning" | "error"), Color (accent, defaults to the theme's Accent),
--         ShowProgress (default true), Dismissable (default true), OnClick (function)
-- Click anywhere on the card (if Dismissable) or the X to close it. The X always closes.
-- Returns a handle: Handle:Dismiss()
function Lunarion:MakeNotification(Config)
	Config = Config or {}
	local Handle = {}
	local Dismissed = false
	function Handle:Dismiss()
		Dismissed = true
	end

	task.spawn(function()
		local Name = tostring(Config.Name or Config.Title or "Notification")
		local Content = tostring(Config.Content or "Test")
		local Icon = Config.Image or Config.Icon or "rbxassetid://124641107046093"

		local Duration = Config.Time
		if Duration == nil then
			Duration = Config.Duration
		end
		local Sticky = false
		if Duration == nil then
			Duration = 15
		elseif Duration == false or Duration == math.huge then
			Sticky = true
		elseif type(Duration) ~= "number" then
			Duration = 15
		elseif Duration <= 0 then
			Sticky = true
		end

		local ShowProgress = (not Sticky) and Config.ShowProgress ~= false
		local Accent = Config.Color or NotifColors[string.lower(tostring(Config.Type or ""))] or ThemeColor("Accent")
		Lunarion:TrackEvent("NotificationShown", {Name = Name, Type = Config.Type})

		local White = Color3.fromRGB(255, 255, 255)
		local Black = Color3.fromRGB(0, 0, 0)
		local Glass = ThemeColor("Main"):Lerp(Black, 0.3)
		local GlassLight = ThemeColor("Main"):Lerp(White, 0.12)
		local GlassAlpha = 0.16
		local StrokeAlpha = 0.8

		local ContentH = 0
		if Content ~= "" then
			local Plain = string.gsub(Content, "<[^>]+>", "")
			ContentH = math.ceil(MeasureText(Plain, 13, Fonts.Body, Vector2.new(NotifWidth - 32, 1000)).Y)
		end
		-- the timer bar sits a bit higher than before (13px from the bottom edge), so it needs a little more room
		local Height = 12 + 20 + (ContentH > 0 and (4 + ContentH) or 0) + 12 + (ShowProgress and 10 or 0)

		NotifOrder = NotifOrder + 1
		local Slot = SetProps(MakeElement("TFrame"), {
			Name = "NotificationSlot",
			Size = UDim2.new(1, 0, 0, 0),
			ClipsDescendants = true,
			LayoutOrder = NotifOrder,
			Parent = NotificationHolder
		})

		local CenterY = Height / 2
		local Card = Create("Frame", {
			Name = "Card",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, CenterY + 16),
			Size = UDim2.new(1, 0, 0, Height),
			BackgroundColor3 = Glass,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Parent = Slot
		}, {
			Create("UICorner", {Name = "Corner", CornerRadius = UDim.new(0, 12)}),
			Create("UIScale", {Name = "Scale", Scale = 0.9}),
			-- frosted rim
			Create("UIStroke", {
				Name = "Rim",
				Color = White,
				Thickness = 1,
				Transparency = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}),
			-- glass body: light catches the top-left, falls off toward the bottom-right
			Create("UIGradient", {
				Color = ColorSequence.new(GlassLight, Glass),
				Rotation = 35
			}),
			-- shine that sweeps across on arrival
			Create("Frame", {
				Name = "Shine",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(-0.3, 0, 0.5, 0),
				Size = UDim2.new(0.22, 0, 1.8, 0),
				Rotation = 18,
				BackgroundColor3 = White,
				BorderSizePixel = 0,
				ZIndex = 2
			}, {
				Create("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.5, 0.93),
						NumberSequenceKeypoint.new(1, 1)
					})
				})
			}),
			SetProps(MakeElement("Image", Icon, Config.ImageSource), {
				Name = "Icon",
				Position = UDim2.new(0, 14, 0, 12),
				Size = UDim2.new(0, 20, 0, 20),
				ImageColor3 = Accent:Lerp(White, 0.55),
				ImageTransparency = 1,
				ZIndex = 3
			}),
			SetProps(MakeElement("Label", Name, 14), {
				Name = "Title",
				Position = UDim2.new(0, 44, 0, 12),
				Size = UDim2.new(1, -70, 0, 20),
				FontFace = Fonts.Title,
				TextColor3 = White,
				TextTransparency = 1,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 3
			}),
			SetProps(MakeElement("Label", Content, 13), {
				Name = "Content",
				Position = UDim2.new(0, 14, 0, 36),
				Size = UDim2.new(1, -28, 0, ContentH),
				FontFace = Fonts.Body,
				TextColor3 = Color3.fromRGB(210, 212, 222),
				TextTransparency = 1,
				TextWrapped = true,
				TextYAlignment = Enum.TextYAlignment.Top,
				Visible = ContentH > 0,
				ZIndex = 3
			})
		})
		local Scale = Card.Scale
		local Rim = Card.Rim

		local XBtn = SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
			Name = "Close",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 0, 12),
			Size = UDim2.new(0, 14, 0, 14),
			ImageColor3 = Color3.fromRGB(220, 220, 225),
			ImageTransparency = 1,
			ZIndex = 4,
			Parent = Card
		})
		local XClick = SetProps(MakeElement("Button"), {
			Name = "CloseClick",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -20, 0, 4),
			Size = UDim2.new(0, 28, 0, 28),
			ZIndex = 5,
			Parent = Card
		})

		local Progress
		if ShowProgress then
			Progress = Create("Frame", {
				Name = "Progress",
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 14, 1, -13),
				Size = UDim2.new(1, -28, 0, 2),
				BackgroundColor3 = Accent:Lerp(White, 0.35),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 3,
				Parent = Card
			}, {
				Create("UICorner", {CornerRadius = UDim.new(1, 0)})
			})
		end

		local Click = SetProps(MakeElement("Button"), {
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 1,
			Parent = Card
		})

		local ExitStarted = false
		local function PlayExit()
			if ExitStarted then
				return
			end
			ExitStarted = true
			Click.Active = false
			XClick.Active = false
			Dismissed = true
			Slot.ClipsDescendants = false

			-- 1) the card shrinks, sinks downward and fades AT THE SAME TIME (same rounded shape, uniform scale)
			local Sink = 0.42
			Tw(Card, Sink, Enum.EasingStyle.Quint, Enum.EasingDirection.In, {Position = UDim2.new(0.5, 0, 0, CenterY + 30)})
			local Shrink = Tw(Scale, Sink, Enum.EasingStyle.Quint, Enum.EasingDirection.In, {Scale = 0.62})
			Tw(Card, Sink, Enum.EasingStyle.Sine, Enum.EasingDirection.In, {BackgroundTransparency = 1})
			Tw(Rim, Sink * 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {Transparency = 1})
			Tw(Card.Icon, Sink * 0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {ImageTransparency = 1})
			Tw(Card.Title, Sink * 0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {TextTransparency = 1})
			Tw(Card.Content, Sink * 0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {TextTransparency = 1})
			Tw(XBtn, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {ImageTransparency = 1})
			if Progress then
				Tw(Progress, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {BackgroundTransparency = 1})
			end
			Shrink.Completed:Wait()
			if not Slot.Parent then
				return
			end

			-- 2) (already faded while shrinking)
			-- 3) the gap closes and the others settle
			Card.Visible = false
			local Collapse = Tw(Slot, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = UDim2.new(1, 0, 0, 0)})
			Collapse.Completed:Wait()
			Slot:Destroy()
		end

		AddConnection(XClick.MouseButton1Click, PlayExit)
		AddConnection(Click.MouseButton1Click, function()
			if type(Config.OnClick) == "function" then
				task.spawn(Config.OnClick)
			end
			if Config.Dismissable ~= false then
				Dismissed = true
			end
		end)

		local Shine = Card.Shine

		-- ENTER: the slot opens (pushing the others up); the glass rises in, grows from slightly small and un-fades
		Tw(Slot, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = UDim2.new(1, 0, 0, Height + 8)})
		Tw(Card, 0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Position = UDim2.new(0.5, 0, 0, CenterY)})
		Tw(Scale, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Scale = 1})
		Tw(Card, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundTransparency = GlassAlpha})
		Tw(Rim, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Transparency = StrokeAlpha})
		task.delay(0.12, function()
			if not Card.Parent or ExitStarted then return end
			Tw(Card.Icon, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {ImageTransparency = 0})
			Tw(Card.Title, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = 0})
			Tw(Card.Content, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = 0})
			Tw(XBtn, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {ImageTransparency = 0.35})
			if Progress then
				Tw(Progress, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundTransparency = 0.25})
			end
		end)
		task.delay(0.25, function()
			if Card.Parent and not ExitStarted then
				Tw(Shine, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, {Position = UDim2.new(1.3, 0, 0.5, 0)})
			end
		end)
		-- once it has settled, stop clipping so the exit drift is never cut off
		task.delay(0.65, function()
			if Slot.Parent and not ExitStarted then
				Slot.ClipsDescendants = false
			end
		end)

		-- WAIT: timed, or until dismissed
		if Progress then
			Tw(Progress, Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In, {Size = UDim2.new(0, 0, 0, 2)})
		end
		local Started = os.clock()
		while not Dismissed and Slot.Parent and Lunarion:IsRunning() and (Sticky or os.clock() - Started < Duration) do
			task.wait(0.1)
		end
		if not Slot.Parent then
			return
		end

		PlayExit()
	end)

	return Handle
end
Lunarion.MakeLegacyNotification = Lunarion.MakeNotification

function Lunarion:AddTheme(Name, Theme)
	local Full = {}
	for Key, Value in pairs(Lunarion.Themes.Default) do
		Full[Key] = Value
	end
	for Key, Value in pairs(Theme or {}) do
		Full[Key] = Value
	end
	Lunarion.Themes[Name] = Full
end

function Lunarion:SetTheme(Name)
	if not Lunarion.Themes[Name] then
		warn("Lunarion | Unknown theme: " .. tostring(Name))
		return false
	end
	Lunarion.SelectedTheme = Name
	SetTheme(true)
	Lunarion:TrackEvent("ThemeChanged", {Theme = Name})
	AutoSave()
	return true
end

function Lunarion:GetTheme()
	return Lunarion.SelectedTheme
end

function Lunarion:GetThemes()
	local List = {}
	for Name in pairs(Lunarion.Themes) do
		table.insert(List, Name)
	end
	table.sort(List)
	return List
end

-- Local analytics: your own, no remote fetch, no loadstring, no network calls of any kind.
-- Everything stays in-memory (Lunarion.Analytics.Log / .Counts) unless you export it to a local file yourself.
function Lunarion:EnableAnalytics(State)
	Lunarion.Analytics.Enabled = State ~= false
end

-- Fires internally on key events (window created, key system passed/failed, notification shown, theme changed)
-- and you can call it yourself too: Lunarion:TrackEvent("MyEvent", {Foo = "Bar"})
function Lunarion:TrackEvent(Name, Data)
	if not Lunarion.Analytics.Enabled then
		return
	end
	local Entry = {Event = Name, Data = Data or {}, Time = os.time()}
	table.insert(Lunarion.Analytics.Log, Entry)
	Lunarion.Analytics.Counts[Name] = (Lunarion.Analytics.Counts[Name] or 0) + 1
	if type(Lunarion.OnAnalyticsEvent) == "function" then
		task.spawn(Lunarion.OnAnalyticsEvent, Entry)
	end
end

-- Snapshot of everything tracked so far: {Log = {...}, Counts = {...}}
function Lunarion:GetAnalytics()
	return Lunarion.Analytics
end

function Lunarion:ClearAnalytics()
	Lunarion.Analytics.Log = {}
	Lunarion.Analytics.Counts = {}
end

-- Writes the analytics log to a local file (writefile), as JSON. Still no network involved.
function Lunarion:ExportAnalytics(FileName)
	if not writefile then
		return false, "writefile is not available on this executor"
	end
	FileName = FileName or "LunarionAnalytics.json"
	local Ok, Err = pcall(writefile, FileName, HttpService:JSONEncode(Lunarion.Analytics))
	if not Ok then
		return false, Err
	end
	return true, FileName
end

function Lunarion:Init()
	-- configs are loaded automatically while elements are created; this only tells the user
	if Lunarion.SaveCfg and Lunarion.ConfigLoaded then
		Lunarion:MakeNotification({
			Name = "Configuration",
			Content = "Auto-loaded your saved configuration.",
			Time = 5
		})
	end
end

function Lunarion:SaveConfig()
	if Lunarion.SaveCfg then
		return pcall(SaveCfg)
	end
	return false
end

-- Key system, Rayfield gen1 layout in the Lunarion look: a solid black card (tinted by the active theme),
-- title + subtitle on the left, a single X on the right (no minimize), a long key input and an
-- "About Key System" note underneath. Call this BEFORE MakeWindow; it yields until the key is
-- verified (or the user closes it). Press Enter in the box to submit.
-- Config: Title, Subtitle, About (or Note), Key (a string, or a table of valid strings), GrabKeyFromSite
--         (fetch each Key as a URL and match its trimmed body instead), SaveKey (default true; remembers a good
--         key on disk), FileName (default "LunarionKey.txt"), Icon (+ImageSource, default Lucide "key-round"),
--         GetKeyLink (adds a "Get Key" button that copies it), GetKeyText, Warning, TutorialLink,
--         Theme (theme name to use for the card), Closable (default true)
-- Returns true if a valid key was entered (or one was already saved), false if the user closed it.
function Lunarion:MakeKeySystem(Config)
	Config = Config or {}
	if Shield.Tripped then
		error("Lunarion: integrity check failed", 0)
	end
	if Config.Security ~= false then
		Shield.Start()
	end
	Config.Title = Config.Title or "Lunarion Key System"
	Config.Subtitle = Config.Subtitle or "Key System"
	Config.SaveKey = Config.SaveKey ~= false
	Config.FileName = Config.FileName or "LunarionKey.txt"
	Config.Closable = Config.Closable ~= false
	Config.About = Config.About or Config.Note or "This script requires a key to continue. Grab one from the link below, then paste it into the box above and press Enter."
	Config.GetKeyText = Config.GetKeyText or "Get Key"
	Config.KeyIconIsLogo = Config.Icon == nil
	Config.Icon = Config.Icon or "rbxassetid://124641107046093"

	if Config.Theme and Lunarion.Themes[Config.Theme] then
		Lunarion.SelectedTheme = Config.Theme
	end

	local ValidKeys = {}
	local function Trim(Text)
		return (tostring(Text or ""):gsub("^%s+", ""):gsub("%s+$", ""))
	end
	if type(Config.Key) == "table" then
		for _, K in ipairs(Config.Key) do
			ValidKeys[string.lower(Trim(K))] = true
		end
	elseif type(Config.Key) == "string" and not Config.GrabKeyFromSite then
		ValidKeys[string.lower(Trim(Config.Key))] = true
	end

	local function CheckKey(Input)
		Input = string.lower(Trim(Input))
		if Input == "" then
			return false
		end
		if Config.GrabKeyFromSite then
			local Urls = type(Config.Key) == "table" and Config.Key or {Config.Key}
			for _, Url in ipairs(Urls) do
				if type(Url) == "string" then
					local Ok, Body = pcall(game.HttpGet, game, Url)
					if Ok and type(Body) == "string" and Input == string.lower(Trim(Body)) then
						return true
					end
				end
			end
			return false
		end
		return ValidKeys[Input] == true
	end

	local SaveOk = writefile and readfile and isfile
	if Config.SaveKey and SaveOk then
		local Ok, Saved = pcall(function()
			return isfile(Config.FileName) and readfile(Config.FileName) or nil
		end)
		if Ok and Saved and CheckKey(Saved) then
			return true
		end
	end

	local Verified, Closed, Busy = false, false, false

	-- black, but still "your theme": the theme's Main colour pushed towards black
	local Black = Color3.fromRGB(0, 0, 0)
	local Base = ThemeColor("Main"):Lerp(Black, 0.6)
	local Field = Base:Lerp(ThemeColor("Text"), 0.07)
	local StrokeCol = ThemeColor("Stroke"):Lerp(Black, 0.25)
	local DividerCol = ThemeColor("Divider"):Lerp(Black, 0.35)
	local Accent = ThemeColor("Accent")
	local TextCol = ThemeColor("Text")
	local TextDark = ThemeColor("TextDark")
	local Red = Color3.fromRGB(239, 68, 68)
	local Green = Color3.fromRGB(34, 197, 94)

	local Overlay = Create("Frame", {
		Name = "LunarionKeySystem",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Black,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false, -- never sinks input, so you can keep walking / moving the camera behind the key card
		ZIndex = 50,
		Parent = Root
	})

	local Card = Create("CanvasGroup", {
		Name = "Card",
		Size = UDim2.new(1, -24, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 24),
		BackgroundColor3 = Base,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		Active = true, -- only the card itself catches clicks
		ZIndex = 51,
		Parent = Overlay
	}, {
		Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
		Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0)}),
		Create("UISizeConstraint", {MaxSize = Vector2.new(480, math.huge)})
	})
	-- keep the card inside small (mobile) screens
	Create("UIScale", {Scale = 1, Name = "Scale", Parent = Card})
	do
		local Cam = workspace.CurrentCamera
		if false and Cam then
			Card.Scale.Scale = math.clamp((Cam.ViewportSize.X - 24) / 480, 0.6, 1)
		end
	end

	-- top bar: [icon] Title / Subtitle ........ [X]
	local TopBarH = 60
	local TopBar = Create("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, TopBarH),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 1,
		ZIndex = 52,
		Parent = Card
	})

	local IconResolved = ResolveIcon(Config.Icon, Config.ImageSource)
	local TextX = 22
	if IconResolved then
		local IconImg = SetProps(MakeElement("Image", Config.Icon, Config.ImageSource), {
			Name = "KeyIcon",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 22, 0.5, 0),
			Size = UDim2.new(0, 22, 0, 22),
			ImageColor3 = Config.KeyIconIsLogo and Color3.new(1, 1, 1) or Accent,
			ZIndex = 53,
			Parent = TopBar
		})
		TextX = 56
	end

	SetProps(MakeElement("Label", Config.Title, 18), {
		Name = "Title",
		Position = UDim2.new(0, TextX, 0, 11),
		Size = UDim2.new(1, -(TextX + 56), 0, 22),
		FontFace = Fonts.Title,
		TextColor3 = TextCol,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 53,
		Parent = TopBar
	})
	SetProps(MakeElement("Label", Config.Subtitle, 12), {
		Name = "Subtitle",
		Position = UDim2.new(0, TextX, 0, 33),
		Size = UDim2.new(1, -(TextX + 56), 0, 16),
		FontFace = Fonts.Thin,
		TextColor3 = TextDark,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 53,
		Parent = TopBar
	})

	-- the only window button: X (no minimize)
	if Config.Closable then
		local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
			Name = "Close",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -16, 0.5, 0),
			Size = UDim2.new(0, 30, 0, 30),
			BackgroundColor3 = TextCol,
			BackgroundTransparency = 1,
			ZIndex = 54,
			Parent = TopBar
		}), {
			Create("UICorner", {CornerRadius = UDim.new(0, 7)}),
			SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 16, 0, 16),
				ImageColor3 = TextCol,
				ImageTransparency = 0.25,
				ZIndex = 55
			})
		})
		AddConnection(CloseBtn.MouseEnter, function()
			Tw(CloseBtn, 0.15, nil, nil, {BackgroundTransparency = 0.88})
		end)
		AddConnection(CloseBtn.MouseLeave, function()
			Tw(CloseBtn, 0.15, nil, nil, {BackgroundTransparency = 1})
		end)
		AddConnection(CloseBtn.MouseButton1Click, function()
			Closed = true
		end)
	end

	-- thin divider under the top bar (like the window's header)
	Create("Frame", {
		Name = "Divider",
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = DividerCol,
		BorderSizePixel = 0,
		LayoutOrder = 2,
		ZIndex = 52,
		Parent = Card
	})

	local Content = Create("Frame", {
		Name = "Content",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 3,
		ZIndex = 52,
		Parent = Card
	}, {
		MakeElement("Padding", 22, 22, 22, 18),
		MakeElement("List", 0, 8)
	})

	local Order = 0
	local function Next()
		Order = Order + 1
		return Order
	end

	-- "Key" caption (Rayfield gen1 has this above the box)
	SetProps(MakeElement("Label", "Key", 12), {
		Name = "KeyCaption",
		Size = UDim2.new(1, 0, 0, 14),
		FontFace = Fonts.Body,
		TextColor3 = TextDark,
		LayoutOrder = Next(),
		ZIndex = 53,
		Parent = Content
	})

	-- long input, full width
	local InputStroke = Create("UIStroke", {
		Color = StrokeCol,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	})
	local InputWrap = SetChildren(Create("Frame", {
		Name = "Input",
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Field,
		BorderSizePixel = 0,
		LayoutOrder = Next(),
		ZIndex = 53,
		Parent = Content
	}), {
		Create("UICorner", {CornerRadius = UDim.new(0, 7)}),
		InputStroke
	})

	local LockX = 14
	if ResolveIcon("lock", "Lucide") then
		SetProps(MakeElement("Image", "lock", "Lucide"), {
			Name = "LockIcon",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 14, 0.5, 0),
			Size = UDim2.new(0, 16, 0, 16),
			ImageColor3 = TextDark,
			ZIndex = 54,
			Parent = InputWrap
		})
		LockX = 40
	end

	local InputBox = Create("TextBox", {
		Name = "InputBox",
		Size = UDim2.new(1, -(LockX + 14), 1, 0),
		Position = UDim2.new(0, LockX, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = "Enter key here...",
		PlaceholderColor3 = TextDark,
		TextColor3 = TextCol,
		FontFace = Fonts.Body,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ClipsDescendants = true,
		ZIndex = 54,
		Parent = InputWrap
	})

	local ErrorLbl = SetProps(MakeElement("Label", " ", 12), {
		Name = "Status",
		Size = UDim2.new(1, 0, 0, 14),
		FontFace = Fonts.Body,
		TextColor3 = Red,
		TextTransparency = 1,
		LayoutOrder = Next(),
		ZIndex = 53,
		Parent = Content
	})

	-- "About Key System" (the Note block from Rayfield gen1)
	SetProps(MakeElement("Label", "About Key System", 13), {
		Name = "AboutHeader",
		Size = UDim2.new(1, 0, 0, 16),
		FontFace = Fonts.Body,
		TextColor3 = TextCol,
		LayoutOrder = Next(),
		ZIndex = 53,
		Parent = Content
	})
	SetProps(MakeElement("Label", Config.About, 12), {
		Name = "AboutText",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		FontFace = Fonts.Body,
		TextColor3 = TextDark,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		LayoutOrder = Next(),
		ZIndex = 53,
		Parent = Content
	})

	if Config.Warning and Config.Warning ~= "" then
		SetProps(MakeElement("Label", Config.Warning, 11), {
			Name = "Warning",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			FontFace = Fonts.Body,
			TextColor3 = Color3.fromRGB(250, 204, 21),
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			LayoutOrder = Next(),
			ZIndex = 53,
			Parent = Content
		})
	end

	-- optional small buttons (Get Key / Tutorial) that copy their link
	local function LinkButton(Text, Link, IconName, Done)
		local Btn = SetChildren(Create("Frame", {
			Name = Text,
			Size = UDim2.new(0, 0, 0, 30),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Field,
			BorderSizePixel = 0,
			ZIndex = 53
		}), {
			Create("UICorner", {CornerRadius = UDim.new(0, 7)}),
			Create("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)}),
			Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 6)
			})
		})
		if IconName and ResolveIcon(IconName, "Lucide") then
			SetProps(MakeElement("Image", IconName, "Lucide"), {
				Size = UDim2.new(0, 14, 0, 14),
				ImageColor3 = TextCol,
				LayoutOrder = 1,
				ZIndex = 54,
				Parent = Btn
			})
		end
		local Lbl = SetProps(MakeElement("Label", Text, 12), {
			Size = UDim2.new(0, 0, 0, 30),
			AutomaticSize = Enum.AutomaticSize.X,
			FontFace = Fonts.Body,
			TextColor3 = TextCol,
			LayoutOrder = 2,
			ZIndex = 54,
			Parent = Btn
		})
		local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0), ZIndex = 56, Parent = Btn})
		AddConnection(Click.MouseEnter, function() Tw(Btn, 0.15, nil, nil, {BackgroundColor3 = Field:Lerp(TextCol, 0.08)}) end)
		AddConnection(Click.MouseLeave, function() Tw(Btn, 0.15, nil, nil, {BackgroundColor3 = Field}) end)
		AddConnection(Click.MouseButton1Click, function()
			pcall(setclipboard, Link)
			Lunarion:MakeNotification({
				Name = Text,
				Content = Done,
				Icon = "copy",
				ImageSource = "Lucide",
				Duration = 4
			})
		end)
		return Btn
	end

	if (Config.GetKeyLink and Config.GetKeyLink ~= "") or (Config.TutorialLink and Config.TutorialLink ~= "") then
		local Row = Create("Frame", {
			Name = "Links",
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = Next(),
			ZIndex = 53,
			Parent = Content
		}, {
			Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8)
			})
		})
		if Config.GetKeyLink and Config.GetKeyLink ~= "" then
			local B = LinkButton(Config.GetKeyText, Config.GetKeyLink, "key-round", "Link copied to your clipboard. Open it in a browser to get your key.")
			B.LayoutOrder = 1
			B.Parent = Row
		end
		if Config.TutorialLink and Config.TutorialLink ~= "" then
			local B = LinkButton("Tutorial", Config.TutorialLink, "circle-help", "Link copied to your clipboard.")
			B.LayoutOrder = 2
			B.Parent = Row
		end
	end

	-- Optional tabs on the key card: Tabs = {{Name = "Key"}, {Name = "Info", Icon = "info", Text = "..."},
	-- {Name = "Links", Links = {{Name = "Discord", Link = "https://...", Icon = "message-circle"}}}}
	-- The tab flagged Key = true (or named "Key", or simply the first one) holds the key box; the others show
	-- their Text / Links. Without Tabs the card looks exactly as before.
	if type(Config.Tabs) == "table" and #Config.Tabs > 0 then
		local Specs = Config.Tabs
		local KeyIndex = 1
		for Index, Spec in ipairs(Specs) do
			if Spec.Key == true or string.lower(tostring(Spec.Name)) == "key" then
				KeyIndex = Index
				break
			end
		end
		Content.LayoutOrder = 4

		local Strip = Create("Frame", {
			Name = "Tabs",
			Size = UDim2.new(1, 0, 0, 44),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 3,
			ZIndex = 52,
			Parent = Card
		}, {
			Create("UIPadding", {PaddingLeft = UDim.new(0, 22), PaddingRight = UDim.new(0, 22), PaddingTop = UDim.new(0, 10)}),
			Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 6)
			})
		})

		local Pages, Buttons = {}, {}
		local Current
		local function Show(Index)
			if Current == Index then
				return
			end
			Current = Index
			Tw(Card, 0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {GroupTransparency = 0.4})
			for Slot, Page in pairs(Pages) do
				Page.Visible = Slot == Index
			end
			for Slot, Button in pairs(Buttons) do
				local On = Slot == Index
				Tw(Button, 0.2, nil, nil, {BackgroundTransparency = On and 0.84 or 1})
				Tw(Button.Label, 0.2, nil, nil, {TextColor3 = On and TextCol or TextDark})
			end
			task.delay(0.09, function()
				Tw(Card, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {GroupTransparency = 0})
			end)
		end

		for Index, Spec in ipairs(Specs) do
			local Label = tostring(Spec.Name or ("Tab " .. Index))
			local Width = math.ceil(MeasureText(Label, 13, Fonts.Body, Vector2.new(1000, 100)).X) + 28
			local Button = SetChildren(Create("TextButton", {
				Name = "Tab" .. Index,
				Text = "",
				AutoButtonColor = false,
				Size = UDim2.new(0, Width, 0, 28),
				BackgroundColor3 = Accent,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = Index,
				ZIndex = 53,
				Parent = Strip
			}), {
				Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
				SetProps(MakeElement("Label", Label, 13), {
					Name = "Label",
					Size = UDim2.new(1, 0, 1, 0),
					FontFace = Fonts.Body,
					TextColor3 = TextDark,
					TextXAlignment = Enum.TextXAlignment.Center,
					ZIndex = 54
				})
			})
			Buttons[Index] = Button
			if Index == KeyIndex then
				Pages[Index] = Content
			else
				local Page = Create("Frame", {
					Name = "Page" .. Index,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 5,
					Visible = false,
					ZIndex = 52,
					Parent = Card
				}, {
					MakeElement("Padding", 22, 22, 22, 14),
					MakeElement("List", 0, 8)
				})
				if type(Spec.Text) == "string" and Spec.Text ~= "" then
					SetProps(MakeElement("Label", Spec.Text, 13), {
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						FontFace = Fonts.Body,
						TextColor3 = TextDark,
						TextWrapped = true,
						TextYAlignment = Enum.TextYAlignment.Top,
						LayoutOrder = 1,
						ZIndex = 53,
						Parent = Page
					})
				end
				if type(Spec.Links) == "table" then
					local Row = Create("Frame", {
						Name = "Links",
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 2,
						ZIndex = 53,
						Parent = Page
					}, {
						Create("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							Wraps = true,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, 8)
						})
					})
					for LinkIndex, Item in ipairs(Spec.Links) do
						local Made = LinkButton(tostring(Item.Name or "Link"), tostring(Item.Link or ""), Item.Icon or "link", "Link copied to your clipboard.")
						Made.LayoutOrder = LinkIndex
						Made.Parent = Row
					end
				end
				Pages[Index] = Page
			end
			AddConnection(Button.MouseButton1Click, function()
				Show(Index)
			end)
		end
		for Slot, Page in pairs(Pages) do
			Page.Visible = Slot == KeyIndex
		end
		Current = nil
		Show(KeyIndex)
	end

	AddDraggingFunctionality(TopBar, Card)

	-- input feedback
	AddConnection(InputBox.Focused, function()
		Tw(InputStroke, 0.2, nil, nil, {Color = Accent})
	end)

	local function Shake()
		local Base0 = Card.Position
		Tw(Card, 0.06, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, {Position = Base0 + UDim2.new(0, 8, 0, 0)})
		task.delay(0.06, function() Tw(Card, 0.06, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, {Position = Base0 - UDim2.new(0, 8, 0, 0)}) end)
		task.delay(0.12, function() Tw(Card, 0.06, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, {Position = Base0}) end)
		ErrorLbl.Text = "Invalid key. Try again."
		ErrorLbl.TextColor3 = Red
		Tw(ErrorLbl, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = 0})
		Tw(InputStroke, 0.2, nil, nil, {Color = Red})
	end

	AddConnection(InputBox.FocusLost, function()
		if Busy or Verified or Closed then
			return
		end
		if Trim(InputBox.Text) == "" then
			Tw(InputStroke, 0.2, nil, nil, {Color = StrokeCol})
			return
		end
		Busy = true
		if CheckKey(InputBox.Text) then
			ErrorLbl.Text = "Key accepted."
			ErrorLbl.TextColor3 = Green
			Tw(ErrorLbl, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = 0})
			Tw(InputStroke, 0.2, nil, nil, {Color = Green})
			if Config.SaveKey and SaveOk then
				pcall(writefile, Config.FileName, Trim(InputBox.Text))
			end
			Lunarion:TrackEvent("KeySystemPassed", {Title = Config.Title})
			task.wait(0.35)
			Verified = true
		else
			Shake()
			Lunarion:TrackEvent("KeySystemFailed", {Title = Config.Title})
			Busy = false
		end
	end)

	-- Live theme: whenever the theme changes the whole card is re-coloured. Every colour in the card is one of a
	-- few palette roles, so the card walks its own descendants and swaps old palette values for the new ones.
	local function ComputePalette()
		local Theme_Base = ThemeColor("Main"):Lerp(Color3.fromRGB(0, 0, 0), 0.6)
		return {
			Base = Theme_Base,
			Field = Theme_Base:Lerp(ThemeColor("Text"), 0.07),
			Stroke = ThemeColor("Stroke"):Lerp(Color3.fromRGB(0, 0, 0), 0.25),
			Divider = ThemeColor("Divider"):Lerp(Color3.fromRGB(0, 0, 0), 0.35),
			Accent = ThemeColor("Accent"),
			Text = ThemeColor("Text"),
			TextDark = ThemeColor("TextDark")
		}
	end
	local Palette = ComputePalette()
	local function Recolor()
		local New = ComputePalette()
		local function Swap(Object, Property)
			local Ok, Value = pcall(function() return Object[Property] end)
			if not Ok or typeof(Value) ~= "Color3" then
				return
			end
			for Role, Old in pairs(Palette) do
				if Value == Old then
					Tw(Object, 0.3, nil, nil, {[Property] = New[Role]})
					return
				end
			end
		end
		local Everything = Card:GetDescendants()
		table.insert(Everything, Card)
		for _, Object in ipairs(Everything) do
			for _, Property in ipairs({"BackgroundColor3", "TextColor3", "ImageColor3", "PlaceholderColor3", "Color"}) do
				Swap(Object, Property)
			end
		end
		Palette = New
		Base, Field, StrokeCol, DividerCol = New.Base, New.Field, New.Stroke, New.Divider
		Accent, TextCol, TextDark = New.Accent, New.Text, New.TextDark
	end
	table.insert(Lunarion.ThemeListeners, function()
		if Card.Parent then
			Recolor()
		end
	end)

	-- enter
	-- no dim behind the card (the overlay stays fully transparent, it only blocks clicks)
	Tw(Card, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {GroupTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)})

	while not Verified and not Closed and Lunarion:IsRunning() do
		task.wait(0.1)
	end

	-- leave: fade + drift down, then remove everything
	local Fade = Tw(Card, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In, {
		GroupTransparency = 1,
		Position = Card.Position + UDim2.new(0, 0, 0, 20)
	})
	Fade.Completed:Wait()
	Overlay:Destroy()

	if Verified and Config.SaveKey and SaveOk then
		Lunarion:MakeNotification({
			Name = "Key System",
			Content = "The key for this script has been saved successfully.",
			Icon = "check",
			ImageSource = "Lucide",
			Duration = 4
		})
	end

	return Verified
end

-- friendly names for the Bind keycap
local KeyLabels = {
	LeftControl = "L-Ctrl", RightControl = "R-Ctrl", LeftShift = "L-Shift", RightShift = "R-Shift",
	LeftAlt = "L-Alt", RightAlt = "R-Alt", Return = "Enter", Backquote = "`", Minus = "-", Equals = "=",
	LeftBracket = "[", RightBracket = "]", Semicolon = ";", Quote = "'", Comma = ",", Period = ".",
	Slash = "/", BackSlash = "\\", Insert = "Ins", Delete = "Del", PageUp = "PgUp", PageDown = "PgDn",
	CapsLock = "Caps", MouseButton1 = "Mouse 1", MouseButton2 = "Mouse 2", MouseButton3 = "Mouse 3",
	Zero = "0", One = "1", Two = "2", Three = "3", Four = "4", Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9"
}

-- ============================================================================================
-- Settings page: lives INSIDE the window as a hidden page (no tab button). The gear spins, the page slides in.
-- Rows use the real Lunarion elements, so they follow every theme. Add your own:
--   Lunarion:AddSetting({Name = "My toggle", Type = "Toggle", Default = false, Section = "General", Callback = function(v) end})
--   Lunarion:AddSetting({Name = "Do something", Type = "Button", Section = "Actions", Icon = "zap", Callback = function() end})
--   Lunarion:AddSetting({Name = "Mode", Type = "Dropdown", Options = {"A", "B"}, Default = "A", Callback = function(v) end})
-- ============================================================================================
Lunarion.Settings = {Notify = false}
Lunarion.SettingRows = {}
function Lunarion:AddSetting(Config)
	table.insert(Lunarion.SettingRows, Config)
end

Lunarion:AddSetting({Name = "Auto config", Section = "General", Type = "Toggle",
	Default = function() return Lunarion.SaveCfg and true or false end,
	Callback = function(V)
		if V then
			Lunarion.SaveCfg = Lunarion.SavedCfgMode or true
		else
			if Lunarion.SaveCfg then Lunarion.SavedCfgMode = Lunarion.SaveCfg end
			Lunarion.SaveCfg = false
		end
	end})
Lunarion:AddSetting({Name = "Close notification", Section = "General", Type = "Toggle", Default = false,
	Callback = function(V) Lunarion.Settings.Notify = V end})
Lunarion:AddSetting({Name = "Theme", Section = "Appearance", Type = "Dropdown",
	Options = function() return Lunarion:GetThemes() end,
	Default = function() return Lunarion.SelectedTheme end,
	Callback = function(V) if V ~= Lunarion.SelectedTheme then Lunarion:SetTheme(V) end end})
Lunarion:AddSetting({Name = "Icon library", Section = "Appearance", Type = "Dropdown",
	Options = function() return Lunarion:GetIconSets() end,
	Default = function() return "lucide" end,
	Callback = function(V) Lunarion:SetIconSet(V) end})

Lunarion:AddSetting({Name = "Copy config", Section = "Actions", Type = "Button", Icon = "copy", Callback = function()
	local Data = {}
	for Key, Flag in pairs(Lunarion.Flags) do
		if Flag.Save then
			Data[Key] = Flag.Type == "Colorpicker" and PackColor(Flag.Value) or Flag.Value
		end
	end
	Data.__Theme = Lunarion.SelectedTheme
	local Ok = pcall(function() setclipboard(HttpService:JSONEncode(Data)) end)
	Lunarion:MakeNotification({Name = Ok and "Config copied" or "Clipboard unavailable", Content = Ok and "Your current config is on the clipboard." or "This executor has no setclipboard.", Duration = 3})
end})
Lunarion:AddSetting({Name = "Reset config", Section = "Actions", Type = "Button", Icon = "rotate-ccw", Callback = function()
	local Ok = pcall(function()
		if isfile(ConfigPath()) then delfile(ConfigPath()) end
	end)
	table.clear(Lunarion.LoadedConfig)
	Lunarion:MakeNotification({Name = Ok and "Config reset" or "Could not reset", Content = Ok and "Saved values removed. Rejoin or re-execute to apply defaults." or "File functions are not available.", Duration = 4})
end})
Lunarion:AddSetting({Name = "Rejoin server", Section = "Actions", Type = "Button", Icon = "log-in", Callback = function()
	pcall(function()
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end)
end})
Lunarion:AddSetting({Name = "Unload UI", Section = "Actions", Type = "Button", Icon = "power", Callback = function()
	Lunarion:Destroy()
end})

-- ============================================================================================
-- Lunae AI hook (personal assistant of Lunarion, coming soon).
-- Lunarion.Lunae:Register(Handler) lets the assistant attach later without touching the core.
-- Handler(Action, Data) receives UI events: "WindowOpened", "WindowClosed", "ThemeChanged", "Command".
-- ============================================================================================
Lunarion.Lunae = {Handler = nil, Ready = false}
function Lunarion.Lunae:Register(Handler)
	Lunarion.Lunae.Handler = Handler
	Lunarion.Lunae.Ready = true
end
function Lunarion.Lunae:Emit(Action, Data)
	if Lunarion.Lunae.Handler then
		task.spawn(pcall, Lunarion.Lunae.Handler, Action, Data)
	end
end
function Lunarion.Lunae:Command(Text)
	Lunarion.Lunae:Emit("Command", {Text = Text, Flags = Lunarion.Flags})
end

local function PrettyKey(Name)
	if Name == nil or Name == "" or Name == "None" or Name == "Unknown" then
		return "None"
	end
	return KeyLabels[Name] or tostring(Name)
end

local WindowBinds = {}
function Lunarion:MakeWindow(WindowConfig)
	local FirstTab = true
	local Minimized = false
	local Loaded = false
	local UIHidden = false
	local MinimizeBusy = false
	local AdaptWindow

	WindowConfig = WindowConfig or {}
	if Shield.Tripped then
		error("Lunarion: integrity check failed", 0)
	end
	if WindowConfig.Security ~= false then
		Shield.Start()
	end
	if WindowConfig.Theme and Lunarion.Themes[WindowConfig.Theme] then
		Lunarion.SelectedTheme = WindowConfig.Theme
	end
	WindowConfig.Name = WindowConfig.Name or "Lunarion"
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
	if WindowConfig.Analytics then
		Lunarion:EnableAnalytics(true)
	end
	Lunarion:TrackEvent("WindowCreated", {
		Name = WindowConfig.Name,
		Theme = Lunarion.SelectedTheme,
		SaveConfig = WindowConfig.SaveConfig
	})
	-- themes passed straight into MakeWindow: Themes = {MyTheme = {Main = ..., Accent = ...}}
	if type(WindowConfig.Themes) == "table" then
		for ThemeName, ThemeData in pairs(WindowConfig.Themes) do
			Lunarion:AddTheme(ThemeName, ThemeData)
		end
		if WindowConfig.Theme and Lunarion.Themes[WindowConfig.Theme] then
			Lunarion.SelectedTheme = WindowConfig.Theme
		end
	end
	-- auto config: on by default whenever the executor can read and write files
	if WindowConfig.SaveConfig == nil then
		WindowConfig.SaveConfig = (writefile and readfile and isfile and isfolder and makefolder) and true or false
	end
	if WindowConfig.AutoLoad == nil then
		WindowConfig.AutoLoad = true
	end
	Lunarion.ConfigName = tostring(WindowConfig.ConfigName or game.GameId)

	WindowConfig.HidePremium = WindowConfig.HidePremium or false
	if WindowConfig.IntroEnabled == nil then
		WindowConfig.IntroEnabled = true
	end
	WindowConfig.IntroText = WindowConfig.IntroText or "Lunarion"
	WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
	if WindowConfig.ShowIcon == nil then WindowConfig.ShowIcon = true end
	WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://124641107046093"
	WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://124641107046093"
	-- SmartPill:
	-- InterfaceName controls the word after "Toggle". It defaults to the window name,
	-- so a window named "Hun" gets "Toggle Hun" instead of the old "Toggle Interface".
	-- PillText is still an explicit override when you want a completely custom label.
	WindowConfig.InterfaceName = tostring(WindowConfig.InterfaceName or WindowConfig.Name)
	WindowConfig.PillText = tostring(WindowConfig.PillText or ("Toggle " .. WindowConfig.InterfaceName))
	local InterfaceLabel = WindowConfig.InterfaceName == "Interface" and "the interface" or WindowConfig.InterfaceName
	WindowConfig.PillIconIsLogo = WindowConfig.PillIcon == nil
	WindowConfig.PillIcon = WindowConfig.PillIcon or "rbxassetid://124641107046093"
	-- SmartPill customization:
	-- InterfaceName = "Menu" -> default pill text becomes "Toggle Menu".
	-- PillText = "Open Hub" -> overrides the complete SmartPill label.
	-- The pill and minimize capsule both auto-size from their actual text.

	-- Platform + window size. Phones keep the compact mobile sizing, PC and console get a bigger window.
	local Camera = workspace.CurrentCamera
	local ViewSize = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
	local IsSmall = not (ViewSize.X > 774 and ViewSize.Y > 503)
	local Platform = WindowConfig.Platform
	if Platform ~= "PC" and Platform ~= "Mobile" and Platform ~= "Console" then
		Platform = Lunarion.Platform
	end
	local IsMobile = Platform == "Mobile"
	local IsConsole = Platform == "Console"
	local IsPC = Platform == "PC"

	-- pill: mobile + console get it by default, PC uses the toggle key only (ForcePill = true brings it back)
	if WindowConfig.ShowPill == nil then
		WindowConfig.ShowPill = not IsPC
	end
	if IsPC and not WindowConfig.ForcePill then
		WindowConfig.ShowPill = false
	end

	local ToggleKey = WindowConfig.ToggleKey or Enum.KeyCode.RightShift
	if type(ToggleKey) == "string" then
		local Found = Enum.KeyCode[ToggleKey]
		ToggleKey = Found or Enum.KeyCode.RightShift
	end

	local ReopenHint
	if WindowConfig.ShowPill and IsPC then
		ReopenHint = "Press " .. ToggleKey.Name .. " or click \"" .. WindowConfig.PillText .. "\" to reopen " .. InterfaceLabel
	elseif WindowConfig.ShowPill then
		ReopenHint = (IsConsole and "Select" or "Tap") .. " \"" .. WindowConfig.PillText .. "\" to reopen " .. InterfaceLabel
	else
		ReopenHint = "Press " .. ToggleKey.Name .. " to reopen " .. InterfaceLabel
	end

	if IsMobile then
		WindowConfig.PillPosition = WindowConfig.PillPositionMobile or WindowConfig.PillPosition or UDim2.new(0.512, 0, 0, -41)
	else
		WindowConfig.PillPosition = WindowConfig.PillPosition or UDim2.new(0.5, 0, 0, 10)
	end

	local MainSize, SideWidth
	if IsSmall then
		MainSize = UDim2.fromOffset(math.max(ViewSize.X - 100, 320), math.max(ViewSize.Y - 100, 220))
		SideWidth = 130
	elseif IsConsole then
		MainSize = UDim2.fromOffset(math.min(880, ViewSize.X - 80), math.min(500, ViewSize.Y - 80))
		SideWidth = 190
	else
		MainSize = UDim2.fromOffset(math.min(720, ViewSize.X - 60), math.min(410, ViewSize.Y - 60))
		SideWidth = 170
	end
	if typeof(WindowConfig.Size) == "UDim2" then
		MainSize = WindowConfig.Size
	end

	local ExpandedWidth = SideWidth
	local IconWidth = 58
	local SidebarCollapsed = false
	local ManualSidebar = false
	local SetSidebarCollapsed

	Lunarion.Folder = WindowConfig.ConfigFolder
	Lunarion.SaveCfg = WindowConfig.SaveConfig

	if WindowConfig.SaveConfig then
		if not isfolder(WindowConfig.ConfigFolder) then
			makefolder(WindowConfig.ConfigFolder)
		end	
	end

	if WindowConfig.SaveConfig and WindowConfig.AutoLoad then
		pcall(function()
			local Path = Lunarion.Folder .. "/" .. Lunarion.ConfigName .. ".txt"
			if isfile(Path) then
				local Data = HttpService:JSONDecode(readfile(Path))
				if type(Data) == "table" then
					Lunarion.LoadedConfig = Data
					Lunarion.ConfigLoaded = true
					if WindowConfig.RememberTheme ~= false and type(Data.__Theme) == "string" and Lunarion.Themes[Data.__Theme] then
						Lunarion.SelectedTheme = Data.__Theme
					end
				end
			end
		end)
	end

	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
		Size = UDim2.new(1, 0, 1, -50)
	}), {
		MakeElement("List"),
		MakeElement("Padding", 8, 0, 0, 8)
	}), "Divider")
	TabHolder.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
	end)

	-- Control capsule: [ search | layout | minimize | close ] live inside ONE rounded pill, so search is part of
	-- the window buttons instead of a separate floating thing. The search field grows out of the capsule
	-- (towards the left) with a single width tween; the capsule itself auto-sizes around whatever is inside.
	local function CapsuleButton(Name, IconRef, Source, Order)
		return SetChildren(SetProps(MakeElement("Button"), {
			Name = Name,
			Size = UDim2.new(0, 28, 0, 28),
			BackgroundTransparency = 1,
			LayoutOrder = Order
		}), {
			Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
			AddThemeObject(SetProps(MakeElement("Image", IconRef, Source), {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 15, 0, 15),
				Name = "Ico"
			}), "Text")
		})
	end

	local SearchBtn = CapsuleButton("SearchBadge", "search", nil, 1)
	local SearchField = Create("Frame", {
		Name = "SearchField",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		LayoutOrder = 2
	})
	local CapsuleSep = AddThemeObject(SetProps(MakeElement("Frame"), {
		Name = "Sep",
		Size = UDim2.new(0, 1, 0, 14),
		BackgroundTransparency = 0.4,
		LayoutOrder = 3
	}), "Stroke")
	local LayoutIconName = "panel-top"
	local LayoutIconSource = nil
	local LayoutBtn = CapsuleButton("LayoutBadge", LayoutIconName, LayoutIconSource, 4)
	LayoutBtn.Visible = WindowConfig.TabStyleToggle ~= false
	local SettingsBtn = CapsuleButton("SettingsBadge", "settings", nil, 4.5)
	SettingsBtn.Visible = WindowConfig.Settings ~= false
	local MinimizeBtn = CapsuleButton("MinimizeBadge", "rbxassetid://7072719338", nil, 5)
	local CloseBtn = CapsuleButton("CloseBadge", "rbxassetid://7072725342", nil, 6)

	local Capsule = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 1, 0), {
		Name = "Controls",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 34),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 0.3
	}), {
		AddThemeObject(Create("UIStroke", {Thickness = 1, Transparency = 0.4}), "Stroke"),
		Create("UIPadding", {PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3)}),
		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2)
		}),
		SearchBtn, SearchField, CapsuleSep, LayoutBtn, SettingsBtn, MinimizeBtn, CloseBtn
	}), "Second")

	local function HoverFill(Btn, Fill, IconHover)
		AddConnection(Btn.MouseEnter, function()
			Tw(Btn, 0.18, nil, nil, {BackgroundTransparency = 0, BackgroundColor3 = Fill()})
			if IconHover then
				Tw(Btn.Ico, 0.18, nil, nil, {ImageColor3 = IconHover})
			end
		end)
		AddConnection(Btn.MouseLeave, function()
			Tw(Btn, 0.22, nil, nil, {BackgroundTransparency = 1})
			if IconHover then
				Tw(Btn.Ico, 0.22, nil, nil, {ImageColor3 = ThemeColor("Text")})
			end
		end)
		AddConnection(Btn.MouseButton1Down, function()
			Tw(Btn.Ico, 0.08, nil, nil, {Size = UDim2.new(0, 12, 0, 12)})
		end)
		AddConnection(Btn.MouseButton1Up, function()
			Tw(Btn.Ico, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Size = UDim2.new(0, 15, 0, 15)})
		end)
	end
	local function SoftFill()
		return Shift(ThemeColor("Second"), 18)
	end
	HoverFill(SearchBtn, SoftFill)
	HoverFill(LayoutBtn, SoftFill)
	HoverFill(MinimizeBtn, SoftFill)
	HoverFill(SettingsBtn, SoftFill)
	HoverFill(CloseBtn, function() return Color3.fromRGB(232, 76, 61) end, Color3.fromRGB(255, 255, 255))

	local DragPoint = SetProps(MakeElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 50)
	})

	local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Size = UDim2.new(0, SideWidth, 1, -50),
		Position = UDim2.new(0, 0, 0, 50)
	}), {
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(1, 0, 0, 10),
			Position = UDim2.new(0, 0, 0, 0)
		}), "Second"), 
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(0, 10, 1, 0),
			Position = UDim2.new(1, -10, 0, 0)
		}), "Second"), 
		TabHolder,
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 50),
			Position = UDim2.new(0, 0, 1, -50)
		}), {
			AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
				AnchorPoint = Vector2.new(0, 0.5),
				Name = "Avatar",
				Size = UDim2.new(0, 32, 0, 32),
				Position = UDim2.new(0, 10, 0.5, 0)
			}), {
				SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=".. LocalPlayer.UserId .."&width=420&height=420&format=png"), {
					Size = UDim2.new(1, 0, 1, 0)
				}),
				MakeElement("Corner", 0, 9)
			}), "Divider"),
			SetChildren(SetProps(MakeElement("TFrame"), {
				AnchorPoint = Vector2.new(0, 0.5),
				Name = "AvatarRing",
				Size = UDim2.new(0, 32, 0, 32),
				Position = UDim2.new(0, 10, 0.5, 0)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				MakeElement("Corner", 0, 9)
			}),
			AddThemeObject(SetProps(MakeElement("Label", LocalPlayer.DisplayName, WindowConfig.HidePremium and 14 or 13), {
				Name = "ProfileName",
				Size = UDim2.new(1, -60, 0, 14),
				Position = WindowConfig.HidePremium and UDim2.new(0, 50, 0, 18) or UDim2.new(0, 50, 0, 9),
				FontFace = Fonts.Body,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ClipsDescendants = true
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", "@" .. LocalPlayer.Name, 11), {
				Name = "ProfileUser",
				Size = UDim2.new(1, -60, 0, 12),
				Position = UDim2.new(0, 50, 0, 26),
				FontFace = Fonts.Thin,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Visible = not WindowConfig.HidePremium
			}), "TextDark")
		}),
	}), "Second")
	-- Search now lives in the top bar (see the block right after the window is assembled below),
	-- not in the sidebar, so the sidebar no longer reserves space for it.
	local SearchBox, ResultsList, ResultsCard, CloseSearchResults, SearchClickToExpand, SearchRoot, SearchLayer, SetSearchExpanded
	local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {
		Size = UDim2.new(1, -30, 2, 0),
		Position = UDim2.new(0, 25, 0, -24),
		FontFace = Fonts.Title,
		TextSize = 20,
		TextTruncate = Enum.TextTruncate.AtEnd
	}), "Text")

	local TopBarLineGradient = Create("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.18, 0.55),
			NumberSequenceKeypoint.new(0.82, 0.55),
			NumberSequenceKeypoint.new(1, 1)
		})
	})
	local WindowTopBarLine = SetChildren(SetProps(MakeElement("Frame"), {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	}), {
		TopBarLineGradient
	})
	local function RefreshTopBarLine()
		local Accent = ThemeColor("Accent")
		TopBarLineGradient.Color = ColorSequence.new(Accent, Accent)
	end
	RefreshTopBarLine()
	table.insert(Lunarion.ThemeListeners, RefreshTopBarLine)

	local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 18), {
		Parent = Root,
		Position = UDim2.new(0.5, -MainSize.X.Offset / 2, 0.5, -MainSize.Y.Offset / 2),
		Size = MainSize,
		ZIndex = 2, -- layer 2: always above notifications (1), always below search (3)
		Active = true, -- clicks on the window never leak through to the game
		ClipsDescendants = true
	}), {
		--SetProps(MakeElement("Image", "rbxassetid://3523728077"), {
		--	AnchorPoint = Vector2.new(0.5, 0.5),
		--	Position = UDim2.new(0.5, 0, 0.5, 0),
		--	Size = UDim2.new(1, 80, 1, 320),
		--	ImageColor3 = Color3.fromRGB(33, 33, 33),
		--	ImageTransparency = 0.7
		--}),
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 50),
			Name = "TopBar"
		}), {
			WindowName,
			WindowTopBarLine,
			Capsule,
		}),
		DragPoint,
		WindowStuff
	}), "Main")

	-- Logo (next to the script name) + Subtitle (beside the name) + Author (under the name)
	local LogoValue = WindowConfig.Logo or (WindowConfig.ShowIcon and WindowConfig.Icon) or nil
	local LogoSize = tonumber(WindowConfig.LogoSize) or 26
	local NameX = 25
	local Logo
	SidebarCollapsed = LogoValue ~= nil
	if LogoValue then
		NameX = 22 + LogoSize + 10
		Logo = SetProps(MakeElement("Image", LogoValue, WindowConfig.LogoSource or WindowConfig.ImageSource), {
			Name = "Logo",
			Parent = MainWindow.TopBar,
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.new(0, LogoSize, 0, LogoSize),
			Position = UDim2.new(0, 22, 0, 25),
			ScaleType = Enum.ScaleType.Fit
		})
		if WindowConfig.LogoColor then
			Logo.ImageColor3 = WindowConfig.LogoColor
		end
		if WindowConfig.LogoRounded then
			Create("UICorner", {CornerRadius = UDim.new(WindowConfig.LogoRounded == true and 0.25 or 0, WindowConfig.LogoRounded == true and 0 or WindowConfig.LogoRounded), Parent = Logo})
		end
	end

	do
		local HasAuthor = type(WindowConfig.Author) == "string" and WindowConfig.Author ~= ""
		local HasSubtitle = type(WindowConfig.Subtitle) == "string" and WindowConfig.Subtitle ~= ""
		local NameCenter = HasAuthor and 18 or 26

		WindowName.Position = UDim2.new(0, NameX, 0, NameCenter - 50)

		if HasAuthor then
			AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Author, 11), {
				Name = "Author",
				Parent = MainWindow.TopBar,
				Size = UDim2.new(1, -(NameX + 100), 0, 14),
				Position = UDim2.new(0, NameX, 0, 30),
				FontFace = Fonts.Thin,
				TextTransparency = 0.35,
				TextTruncate = Enum.TextTruncate.AtEnd
			}), "TextDark")
		end

		if HasSubtitle then
			local NameWidth = MeasureText(WindowConfig.Name, 20, Fonts.Title, Vector2.new(1000, 100)).X
			local SubX = NameX + NameWidth + 8
			AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Subtitle, 12), {
				Name = "Subtitle",
				Parent = MainWindow.TopBar,
				Size = UDim2.new(1, -(SubX + 100), 0, 16),
				Position = UDim2.new(0, SubX, 0, NameCenter - 7),
				FontFace = Fonts.Thin,
				TextTransparency = 0.35,
				TextTruncate = Enum.TextTruncate.AtEnd
			}), "TextDark")
		end
	end

	-- Icon-only sidebar : click the logo to expand/collapse tab names & sections
	if Logo then
		local LogoClick = SetProps(MakeElement("Button"), {
			Name = "LogoClick",
			Size = UDim2.new(0, LogoSize, 0, LogoSize),
			Position = Logo.Position,
			AnchorPoint = Logo.AnchorPoint,
			BackgroundTransparency = 1,
			ZIndex = 5,
			Parent = MainWindow.TopBar
		})
		AddConnection(LogoClick.MouseButton1Click, function()
			if Minimized then
				return
			end
			ManualSidebar = true
			SetSidebarCollapsed(not SidebarCollapsed)
		end)
	end

	-- Smart top bar: the title, subtitle and author always fit next to the control capsule. Whatever does not
	-- fit is hidden instead of colliding, and everything returns as the window grows again.
	do
		local NameW = MeasureText(WindowConfig.Name, 20, Fonts.Title, Vector2.new(2000, 100)).X
		local function Measure(Text, Size, Face)
			return MeasureText(Text, Size, Face, Vector2.new(2000, 100)).X
		end
		function AdaptWindow()
			if Minimized or MinimizeBusy then
				return
			end
			local Width = MainWindow.AbsoluteSize.X
			local Free = Width - NameX - Capsule.AbsoluteSize.X - 30
			WindowName.Size = UDim2.new(0, math.max(40, Free), 2, 0)
			local TopBar = MainWindow:FindFirstChild("TopBar")
			if not TopBar then
				return
			end
			local Sub, Author = TopBar:FindFirstChild("Subtitle"), TopBar:FindFirstChild("Author")
			if Sub then
				local Need = NameW + 10 + Measure(Sub.Text, 12, Fonts.Thin)
				Sub.Visible = Free >= Need
				Sub.Position = UDim2.new(0, NameX + NameW + 8, 0, Sub.Position.Y.Offset)
				Sub.Size = UDim2.new(0, math.max(0, Free - NameW - 10), 0, 16)
			end
			if Author then
				Author.Visible = Free >= 90
				Author.Size = UDim2.new(0, math.max(0, Free), 0, 14)
			end
		end
		AddConnection(MainWindow:GetPropertyChangedSignal("AbsoluteSize"), AdaptWindow)
		AddConnection(Capsule:GetPropertyChangedSignal("AbsoluteSize"), AdaptWindow)
		task.defer(AdaptWindow)
	end

	AddDraggingFunctionality(DragPoint, MainWindow)

	-- Search lives on its OWN layer (3): it sits above the window (2) which sits above notifications (1).
	-- A follower loop (further down) keeps it glued to the top-right of the window and hides it while the
	-- window is minimized, closed or animating. Nothing inside the window can clip or cover it.
	-- Search (inside the control capsule). Expanding widens the capsule with one tween; the results drop down
	-- as a card under it. Nothing floats on its own layer any more, so nothing can "pop out".
	SearchRoot = Capsule
	SearchLayer = SearchField
	SearchClickToExpand = SearchBtn
	do
		local SearchExpanded = false
		local ExpandedW = 250
		local TitleWidth = MeasureText(WindowConfig.Name, 20, Fonts.Title, Vector2.new(2000, 100)).X

		local function FieldWidth()
			-- as wide as the top bar allows: window - (logo + name + capsule buttons) - breathing room
			local Free = MainWindow.AbsoluteSize.X - (NameX + TitleWidth + 200)
			return math.floor(math.clamp(Free, 96, 230))
		end

		SearchBox = AddThemeObject(Create("TextBox", {
			Name = "SearchBox",
			Size = UDim2.new(1, -6, 1, 0),
			Position = UDim2.new(0, 3, 0, 0),
			BackgroundTransparency = 1,
			FontFace = Fonts.Body,
			TextSize = 13,
			Text = "",
			PlaceholderText = "",
			ClearTextOnFocus = false,
			TextEditable = false,
			Visible = false,
			TextTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = SearchField
		}), "Text")
		SearchBox.PlaceholderColor3 = ThemeColor("TextDark")
		table.insert(Lunarion.ThemeListeners, function()
			if SearchBox.Parent then
				SearchBox.PlaceholderColor3 = ThemeColor("TextDark")
			end
		end)

		-- results: a real card (solid theme background + stroke) that sits inside the window, under the capsule
		ResultsCard = AddThemeObject(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 12), {
			Name = "SearchResults",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 0, 56),
			Size = UDim2.new(0, ExpandedW, 0, 0),
			ClipsDescendants = true,
			Visible = false,
			ZIndex = 70,
			Parent = MainWindow
		}), "Second")
		ResultsCard:SetAttribute("lzKeep", true)
		AddThemeObject(Create("UIStroke", {Thickness = 1, Parent = ResultsCard}), "Stroke")

		ResultsList = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 3), {
			Name = "List",
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 71,
			Parent = ResultsCard
		}), {
			MakeElement("List", 0, 2),
			MakeElement("Padding", 4, 4, 4, 4)
		}), "Divider")

		function CloseSearchResults()
			ResultsCard.Visible = false
			ResultsCard.Size = UDim2.new(0, ExpandedW, 0, 0)
		end

		function SetSearchExpanded(On, FocusIt)
			if On and (Minimized or not MainWindow.Visible) then
				return
			end
			if SearchExpanded == On then
				if On and FocusIt then
					SearchBox:CaptureFocus()
				end
				return
			end
			SearchExpanded = On
			SearchBox.TextEditable = On
			Tw(SearchField, 0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = UDim2.new(0, On and FieldWidth() or 0, 1, 0)})
			Tw(SearchBox, On and 0.3 or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = On and 0 or 1})
			Tw(SearchBtn.Ico, 0.25, nil, nil, {ImageColor3 = On and ThemeColor("Accent") or ThemeColor("Text")})
			if On then
				SearchBox.Visible = true
				SearchBox.PlaceholderText = "Search tabs, buttons, toggles..."
				if FocusIt then
					task.delay(0.12, function()
						if SearchExpanded then
							SearchBox:CaptureFocus()
						end
					end)
				end
			else
				SearchBox:ReleaseFocus()
				SearchBox.Text = ""
				SearchBox.PlaceholderText = ""
				CloseSearchResults()
				task.delay(0.4, function()
					if not SearchExpanded then
						SearchBox.Visible = false
					end
				end)
			end
		end

		AddConnection(SearchBtn.MouseButton1Click, function()
			SetSearchExpanded(not SearchExpanded, true)
		end)
		-- the field re-fits when the window is resized while it is open
		AddConnection(MainWindow:GetPropertyChangedSignal("AbsoluteSize"), function()
			if SearchExpanded then
				SearchField.Size = UDim2.new(0, FieldWidth(), 1, 0)
			end
		end)
	end

	-- Glass overlays + liquid open/close animation ---------------------------------
	local WindowCorner = MainWindow:FindFirstChildOfClass("UICorner")

	Create("UIStroke", {
		Name = "GlassStroke",
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.86,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = MainWindow
	})

	-- the veil hides the window contents while the glass is still "filling up"
	local Veil = Create("Frame", {
		Name = "GlassVeil",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = ThemeColor("Main"),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 60,
		Active = false,
		Visible = false,
		Parent = MainWindow
	}, {
		Create("UICorner", {CornerRadius = UDim.new(0, 10)})
	})

	-- soft highlight along the top edge, gives the window its glassy look
	local Sheen = Create("Frame", {
		Name = "GlassSheen",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ZIndex = 61,
		Active = false,
		Parent = MainWindow
	}, {
		Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
		Create("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new(1)
		})
	})

	local Corners = {WindowCorner, Veil:FindFirstChildOfClass("UICorner"), Sheen:FindFirstChildOfClass("UICorner")}
	-- the veil and sheen always copy the window's corner radius. Before, they stayed at 10 while the capsule
	-- tweened to 25, so their square-ish corners poked out behind the pill as grey blocks.
	AddConnection(WindowCorner:GetPropertyChangedSignal("CornerRadius"), function()
		for _, Corner in ipairs(Corners) do
			if Corner ~= WindowCorner then
				Corner.CornerRadius = WindowCorner.CornerRadius
			end
		end
	end)
	local function RestCorner()
		return Minimized and 25 or 10
	end
	local function SetCorner(Radius)
		Radius = math.floor(Radius + 0.5)
		for _, Corner in ipairs(Corners) do
			Corner.CornerRadius = UDim.new(0, Radius)
		end
	end

	-- SmartPill geometry: width follows the actual pill label.
	-- Nothing is hard-coded to "Toggle Interface"; long names simply produce a wider pill,
	-- while very small screens get a safe maximum width.
	local PillTextWidth = math.ceil(MeasureText(WindowConfig.PillText, 14, Fonts.Body, Vector2.new(2000, 100)).X)
	local PillMinText = 32
	local PillMaxText = math.max(PillMinText, math.floor(ViewSize.X - 86))
	PillTextWidth = math.clamp(PillTextWidth, PillMinText, PillMaxText)
	local PillW, PillH = PillTextWidth + 14 + 16 + 8 + 14, 34
	local PillAnchor = WindowConfig.PillPosition
	local PillPos = UDim2.new(PillAnchor.X.Scale, PillAnchor.X.Offset - PillW / 2, PillAnchor.Y.Scale, PillAnchor.Y.Offset)
	local PillGeometry = {UDim2.new(0, PillW, 0, PillH), PillPos}

	local Pill, PillScale -- created further down; only visible while the interface is closed
	local WindowToken = 0
	local HiddenRest, OpenTarget
	local Animating = false
	local ClipRest = true

	local function SetPillAlpha(Alpha)
		if not Pill then
			return
		end
		Pill.BackgroundTransparency = Alpha
		local Stroke = Pill:FindFirstChildOfClass("UIStroke")
		if Stroke then
			Stroke.Transparency = Alpha
		end
		Pill.Content.Ico.ImageTransparency = Alpha
		Pill.Content.Title.TextTransparency = Alpha
	end

	local function Ease(Alpha, Style, Direction)
		return TweenService:GetValue(Alpha, Style, Direction)
	end

	-- runs Step(0..1) every frame; stops by itself if a newer open/close started
	local function Drive(Duration, Token, Step, Done)
		local Start = os.clock()
		local Connection
		Step(0) -- apply the first pose immediately so there is no one-frame flash
		Connection = AddConnection(RunService.RenderStepped, function()
			if Token ~= WindowToken then
				Connection:Disconnect()
				return
			end
			local Alpha = math.clamp((os.clock() - Start) / Duration, 0, 1)
			Step(Alpha)
			if Alpha >= 1 then
				Connection:Disconnect()
				if Done then
					Done()
				end
			end
		end)
	end

	-- width, height and position follow separate curves, that is what makes it feel liquid
	local function Morph(From, To, Ax, Ay, Ap, Wobble)
		local FromSize, FromPos, ToSize, ToPos = From[1], From[2], To[1], To[2]
		local View = Root.AbsoluteSize
		-- Everything is solved in absolute pixels and snapped: the size to EVEN numbers and the centre to a
		-- whole pixel. With odd sizes the left edge alternated between moving 0px and 1px every frame, and that
		-- flicker is the shake you saw when the window got small near the pill.
		local function Snap(N, Progress, Exact)
			if Progress >= 0.999 then
				return math.max(2, Exact)
			end
			return math.max(2, 2 * math.floor(N / 2 + 0.5))
		end
		local Sx = Snap((FromSize.X.Offset + (ToSize.X.Offset - FromSize.X.Offset) * Ax) * (1 + Wobble), Ax, ToSize.X.Offset)
		local Sy = Snap(FromSize.Y.Offset + (ToSize.Y.Offset - FromSize.Y.Offset) * Ay, Ay, ToSize.Y.Offset)
		local FromCX = FromPos.X.Scale * View.X + FromPos.X.Offset + FromSize.X.Offset / 2
		local ToCX = ToPos.X.Scale * View.X + ToPos.X.Offset + ToSize.X.Offset / 2
		local FromTY = FromPos.Y.Scale * View.Y + FromPos.Y.Offset
		local ToTY = ToPos.Y.Scale * View.Y + ToPos.Y.Offset
		local CX = math.floor(FromCX + (ToCX - FromCX) * Ap + 0.5)
		local TY = math.floor(FromTY + (ToTY - FromTY) * Ap + 0.5)
		MainWindow.Size = UDim2.fromOffset(Sx, Sy)
		MainWindow.Position = UDim2.fromOffset(math.floor(CX - Sx / 2 + 0.5), TY)
	end

	local Glass = MainWindow:FindFirstChild("GlassStroke")

	-- while the window shrinks / grows, its contents are hidden so nothing garbled shows at tiny sizes
	local ContentsHidden = {}
	local function HideContents()
		for _, Child in ipairs(MainWindow:GetChildren()) do
			if Child:IsA("GuiObject") and Child ~= Veil and Child ~= Sheen and Child.Visible then
				Child.Visible = false
				table.insert(ContentsHidden, Child)
			end
		end
	end
	local function RestoreContents()
		for _, Child in ipairs(ContentsHidden) do
			if Child.Parent then
				Child.Visible = true
			end
		end
		table.clear(ContentsHidden)
	end

	local function ShrunkGeometry(Size, Pos, Factor)
		local W, H = Size.X.Offset * Factor, Size.Y.Offset * Factor
		return {
			UDim2.new(0, W, 0, H),
			UDim2.new(Pos.X.Scale, Pos.X.Offset + (Size.X.Offset - W) / 2, Pos.Y.Scale, Pos.Y.Offset + (Size.Y.Offset - H) / 2)
		}
	end

	local function FinishWindow(RestSize, RestPos)
		Animating = false
		DragLocks[MainWindow] = nil
		MainWindow.Size = RestSize
		MainWindow.Position = RestPos
		MainWindow.BackgroundTransparency = 0
		MainWindow.BackgroundColor3 = ThemeColor("Main")
		SetCorner(RestCorner())
		Veil.Visible = false
		Veil.BackgroundTransparency = 1
		Sheen.BackgroundTransparency = 0
		if Glass then
			Glass.Transparency = 0.86
		end
		RestoreContents()
		MainWindow.ClipsDescendants = ClipRest
		if ResizeGrip and ResizeGrip.Parent then
			ResizeGrip.Visible = false
		end
	end

	local PillTweens = {}
	local function CancelPillTweens()
		for _, PillTween in ipairs(PillTweens) do
			PillTween:Cancel()
		end
		table.clear(PillTweens)
	end

	-- the window has already become the pill shape: hand over to the real pill and fade its icon + text in
	local function FadePillIn()
		if not Pill then
			return
		end
		CancelPillTweens()
		Pill.Size = UDim2.new(0, PillW, 0, PillH)
		PillScale.Scale = 1
		-- The old handoff called SetPillAlpha(1), which made the entire pill transparent.
		-- Then only the text/icon were tweened back, causing the "empty pill" flash.
		-- Start fully visible so the closed pill is solid from the first frame.
		SetPillAlpha(0)
		Pill.BackgroundTransparency = 0
		Pill.Visible = true
		local Stroke = Pill:FindFirstChildOfClass("UIStroke")
		if Stroke then
			Stroke.Transparency = 0
		end
		Pill.Content.Ico.ImageTransparency = 0
		Pill.Content.Title.TextTransparency = 0
	end

	-- OPEN. Intro / pill: the pill stretches, a glass drop hangs off it, droops down (bouncy) and fills out into the window.
	-- No pill (PC) after a close: the window fades back in and settles where it was (mirror of the close).
	local function PlayOpen(Token, FromIntro)
		CancelDragTween(MainWindow)
		DragLocks[MainWindow] = true
		local Rest = HiddenRest or {MainWindow.Size, MainWindow.Position}
		HiddenRest = nil
		local RestSize, RestPos = Rest[1], Rest[2]
		OpenTarget = {RestSize, RestPos}
		local Target = {RestSize, RestPos}
		local Interrupt = MainWindow.Visible
		local MainColor = ThemeColor("Main")

		CancelPillTweens()
		if not Animating then
			ClipRest = MainWindow.ClipsDescendants
		end
		Animating = true
		MainWindow.ClipsDescendants = true

		if not Pill and not FromIntro then
			local From, FromBg, FromVeil
			if Interrupt then
				From = {MainWindow.Size, MainWindow.Position}
				FromBg = MainWindow.BackgroundTransparency
				FromVeil = Veil.Visible and Veil.BackgroundTransparency or 1
			else
				From = ShrunkGeometry(RestSize, RestPos, 0.92)
				FromBg, FromVeil = 1, 1
			end
			HideContents()
			Veil.Visible = true
			MainWindow.Visible = true
			local Revealed = false
			Drive(0.5, Token, function(a)
				local Grow = Ease(math.clamp(a / 0.85, 0, 1), Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				Morph(From, Target, Grow, Grow, Grow, 0)
				SetCorner(RestCorner())
				MainWindow.BackgroundColor3 = MainColor
				Veil.BackgroundColor3 = MainColor
				local Fade = Ease(math.clamp(a / 0.45, 0, 1), Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				MainWindow.BackgroundTransparency = FromBg * (1 - Fade)
				Sheen.BackgroundTransparency = 1 - Fade
				if Glass then
					Glass.Transparency = 1 - 0.14 * Fade
				end
				if a < 0.4 then
					Veil.BackgroundTransparency = FromVeil * (1 - Fade)
				else
					if not Revealed then
						Revealed = true
						RestoreContents()
					end
					Veil.BackgroundTransparency = Ease(math.clamp((a - 0.4) / 0.5, 0, 1), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
				end
			end, function()
				FinishWindow(RestSize, RestPos)
				OpenTarget = nil
			end)
			return
		end

		RestoreContents()
		local From, FromCorner, FromColor, FromVeil
		if Interrupt then
			From = {MainWindow.Size, MainWindow.Position}
			FromCorner = WindowCorner.CornerRadius.Offset
			FromColor = MainWindow.BackgroundColor3
			FromVeil = Veil.Visible and Veil.BackgroundTransparency or 1
		else
			From = PillGeometry
			FromCorner = PillH / 2
			FromColor = ThemeColor("Second")
			FromVeil = 0
		end

		Veil.Visible = true
		MainWindow.Visible = true
		local Stretch = Pill and not Interrupt
		if Stretch then
			Pill.Visible = true
			PillScale.Scale = 1
		end

		Drive(0.95, Token, function(a)
			local Ax = Ease(math.clamp(a / 0.7, 0, 1), Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			local Ay = Ease(math.clamp((a - 0.06) / 0.94, 0, 1), Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			local Ap = Ease(math.clamp(a / 0.8, 0, 1), Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			local Jiggle = 0.025 * math.sin(a * math.pi * 4) * (1 - a)
			Morph(From, Target, Ax, Ay, Ap, Jiggle)

			local Fill = Ease(math.clamp(a / 0.5, 0, 1), Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			SetCorner(FromCorner + (RestCorner() - FromCorner) * Fill)
			local Color = FromColor:Lerp(MainColor, Fill)
			MainWindow.BackgroundColor3 = Color
			Veil.BackgroundColor3 = Color
			Veil.BackgroundTransparency = FromVeil + (1 - FromVeil) * math.clamp((a - 0.3) / 0.35, 0, 1)
			MainWindow.BackgroundTransparency = 0.25 * (1 - math.clamp(a / 0.9, 0, 1))

			if Stretch then
				-- the pill stretches downward, then melts into the drop
				local Pulse = math.sin(math.clamp(a / 0.2, 0, 1) * math.pi)
				Pill.Size = UDim2.new(0, PillW * (1 - 0.1 * Pulse), 0, PillH * (1 + 0.3 * Pulse))
				SetPillAlpha(Ease(math.clamp((a - 0.02) / 0.28, 0, 1), Enum.EasingStyle.Quad, Enum.EasingDirection.In))
				if a >= 0.3 then
					Pill.Visible = false
				end
			end
		end, function()
			FinishWindow(RestSize, RestPos)
			OpenTarget = nil
			if Pill then
				Pill.Visible = false
				Pill.Size = UDim2.new(0, PillW, 0, PillH)
			end
		end)
	end

	-- CLOSE: the mirror of the open. The contents are veiled, the window folds down cleanly
	-- with no positional shake, then either hands over to the real pill (mobile / console)
	-- or melts away completely (PC).
	local function PlayClose(Token)
		CancelDragTween(MainWindow)
		DragLocks[MainWindow] = true
		if not Animating then
			ClipRest = MainWindow.ClipsDescendants
		end
		local RestSize, RestPos
		if OpenTarget then
			RestSize, RestPos = OpenTarget[1], OpenTarget[2]
		else
			RestSize, RestPos = MainWindow.Size, MainWindow.Position
		end
		HiddenRest = {RestSize, RestPos}
		OpenTarget = nil

		local From = {MainWindow.Size, MainWindow.Position}
		local FromCorner = WindowCorner.CornerRadius.Offset
		local FromColor = MainWindow.BackgroundColor3
		local FromVeil = Veil.Visible and Veil.BackgroundTransparency or 1
		local FromBg = MainWindow.BackgroundTransparency

		CancelPillTweens()
		Animating = true
		MainWindow.ClipsDescendants = true
		Veil.Visible = true
		if Pill then
			Pill.Visible = false
		end

		local ToPill = Pill ~= nil
		local To = PillGeometry
		local ToCorner = PillH / 2
		local ToColor = ThemeColor("Second")
		local Hidden = false

		Drive(0.8, Token, function(a)
			local Cover = Ease(math.clamp(a / 0.15, 0, 1), Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			if a >= 0.15 and not Hidden then
				Hidden = true
				HideContents()
			end

			-- 1) fold into the pill: height leads, width follows, position glides (opening curves, reversed)
			local m = math.clamp(a / 0.58, 0, 1)
			local Ay = Ease(m, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
			local Ax = Ease(math.clamp((a - 0.05) / 0.53, 0, 1), Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
			local Ap = Ay
			local Stretch = 0 -- no width pulse while closing (it made the edges wobble)
			Morph(From, To, Ax, Ay, Ap, Stretch)

			-- 2) stable finish: never perturb Position after the fold.
			-- The old sinusoidal offset caused visible shaking and could fight the final restore.
			local p = Ease(m, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			SetCorner(FromCorner + (ToCorner - FromCorner) * p)
			local Color = FromColor:Lerp(ToColor, p)
			MainWindow.BackgroundColor3 = Color
			Veil.BackgroundColor3 = Color
			Veil.BackgroundTransparency = FromVeil * (1 - Cover) + 0.15 * p
			MainWindow.BackgroundTransparency = FromBg + (1 - FromBg) * p
			Sheen.BackgroundTransparency = p
			if Glass then
				Glass.Transparency = 0.86 + 0.14 * p
			end

			-- 2b) the real pill fades its icon + text in ON TOP of the finishing shape, so the capsule is never empty
			if ToPill and a >= 0.3 then
				if not Pill.Visible then
					Pill.Size = UDim2.new(0, PillW, 0, PillH)
					PillScale.Scale = 1
					Pill.Visible = true
					SetPillAlpha(1)
					Pill.BackgroundTransparency = 0
				end
				local Show = Ease(math.clamp((a - 0.3) / 0.25, 0, 1), Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				Pill.Content.Ico.ImageTransparency = 1 - Show
				Pill.Content.Title.TextTransparency = 1 - Show
				local PStroke = Pill:FindFirstChildOfClass("UIStroke")
				if PStroke then
					PStroke.Transparency = 1 - Show
				end
			end

			-- 3) no pill on this platform: the shaken blob melts away, "fully closed"
			if not ToPill and a > 0.88 then
				local f = Ease(math.clamp((a - 0.88) / 0.12, 0, 1), Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				Veil.BackgroundTransparency = 0.15 + 0.85 * f
				if Glass then
					Glass.Transparency = 1
				end
			end
		end, function()
			MainWindow.Visible = false
			FinishWindow(RestSize, RestPos)
			if ToPill then
				FadePillIn()
			end
		end)
	end

	local function SetUIHidden(Hidden)
		if Hidden == UIHidden then
			return
		end
		if Hidden and not MainWindow.Visible then
			return -- still in the intro
		end
		UIHidden = Hidden
		WindowToken = WindowToken + 1
		local Token = WindowToken
		if Hidden then
			PlayClose(Token)
		else
			PlayOpen(Token)
		end
	end

	local OpenSettingsPage -- assigned once the tab system exists
	local SpinBusy = false
	AddConnection(SettingsBtn.MouseButton1Click, function()
		if SpinBusy then
			return
		end
		SpinBusy = true
		SettingsBtn.Ico.Rotation = 0
		local Spin = Tw(SettingsBtn.Ico, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Rotation = 360})
		Tw(SettingsBtn.Ico, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Size = UDim2.new(0, 17, 0, 17)})
		task.delay(0.2, function() Tw(SettingsBtn.Ico, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = UDim2.new(0, 15, 0, 15)}) end)
		Spin.Completed:Connect(function()
			SettingsBtn.Ico.Rotation = 0
			SpinBusy = false
			-- end of the spin: open the settings panel (replace this with whatever you want to happen)
			if WindowConfig.OnSettings then
				pcall(WindowConfig.OnSettings)
			elseif OpenSettingsPage then
				OpenSettingsPage()
			end
		end)
	end)

	AddConnection(CloseBtn.MouseButton1Click, function()
		SetUIHidden(true)
		Lunarion.Lunae:Emit("WindowClosed")
		if WindowConfig.CloseNotification or Lunarion.Settings.Notify then
			Lunarion:MakeNotification({
				Name = "Toggle Closed",
				Content = ReopenHint,
				Icon = "eye-off",
				ImageSource = nil,
				Duration = 4
			})
		end
		WindowConfig.CloseCallback()
	end)

	AddConnection(UserInputService.InputBegan, function(Input)
		if Input.KeyCode == ToggleKey and not UserInputService:GetFocusedTextBox() then
			SetUIHidden(not UIHidden)
		end
	end)

	-- Smart minimize (remade): the window folds into a compact capsule that only holds the logo, the script
	-- name and the restore / close buttons. Author, subtitle, search, sidebar, tabs and the resize grip all
	-- go away and come back on restore. WindowConfig.SmartMinimize = false makes it a plain fixed bar.
	local function CapsuleWidth()
		-- SmartMinimize uses the real rendered title width, not a fixed pill/capsule width.
		-- The minimum leaves room for the logo and action buttons; longer names grow naturally.
		local NameW = MeasureText(WindowConfig.Name, 20, Fonts.Title, Vector2.new(2000, 100)).X
		local AuthorW = 0
		local SubtitleW = 0
		if type(WindowConfig.Author) == "string" and WindowConfig.Author ~= "" then
			AuthorW = MeasureText(WindowConfig.Author, 11, Fonts.Thin, Vector2.new(2000, 100)).X
		end
		if type(WindowConfig.Subtitle) == "string" and WindowConfig.Subtitle ~= "" then
			SubtitleW = MeasureText(WindowConfig.Subtitle, 12, Fonts.Thin, Vector2.new(2000, 100)).X
		end

		local InfoW = math.max(NameW, AuthorW, SubtitleW)
		local ActionW = 92
		local Width = NameX + InfoW + ActionW + 18

		-- SmartMinimize can be disabled for callers that want the legacy fixed-bar feel.
		if WindowConfig.SmartMinimize == false then
			Width = math.max(Width, NameW + NameX + 200)
		end

		local MaxWidth = math.max(180, ViewSize.X - 20)
		return math.clamp(math.ceil(Width), 180, MaxWidth)
	end

	local BodyParked = {}
	local function SetMinimized(On)
		On = On and true or false
		if On == Minimized or MinimizeBusy or Animating or not MainWindow.Visible then
			return
		end
		MinimizeBusy = true
		DragLocks[MainWindow] = true
		local TopBar = MainWindow.TopBar
		local Author = TopBar:FindFirstChild("Author")
		local Subtitle = TopBar:FindFirstChild("Subtitle")
		local View = Root.AbsoluteSize
		CancelDragTween(MainWindow)
		SetSearchExpanded(false)

		-- everything below the top bar sits behind a "curtain" while the frame changes size, so the window never
		-- shows squashed content: cover, resize, uncover.
		local function MakeCurtain(Transparency)
			local Old = MainWindow:FindFirstChild("BodyCurtain")
			if Old then
				Old:Destroy()
			end
			return Create("Frame", {
				Name = "BodyCurtain",
				Position = UDim2.new(0, 0, 0, 50),
				Size = UDim2.new(1, 0, 1, -50),
				BackgroundColor3 = ThemeColor("Main"),
				BackgroundTransparency = Transparency,
				BorderSizePixel = 0,
				ZIndex = 62,
				Active = false,
				Parent = MainWindow
			})
		end
		local function MoveTo(Width, Height, Corner, Direction, Time)
			local Pos, Size = MainWindow.AbsolutePosition - Root.AbsolutePosition, MainWindow.AbsoluteSize
			local CenterX = Pos.X + Size.X / 2
			local Left = math.clamp(math.floor(CenterX - Width / 2 + 0.5), 8, math.max(8, View.X - Width - 8))
			local Top = math.clamp(math.floor(Pos.Y + 0.5), 8, math.max(8, View.Y - Height - 8))
			MainWindow.Position = UDim2.fromOffset(Pos.X, Pos.Y) -- normalise to pixels so the tween has one clean start
			local Info = TweenInfo.new(Time or 0.46, Enum.EasingStyle.Quint, Direction or Enum.EasingDirection.InOut)
			TweenService:Create(MainWindow, Info, {Size = UDim2.fromOffset(Width, Height), Position = UDim2.fromOffset(Left, Top)}):Play()
			TweenService:Create(WindowCorner, Info, {CornerRadius = UDim.new(0, Corner)}):Play()
		end

		task.spawn(function()
			if On then
				Minimized = true
				for _, Obj in ipairs(MainWindow:GetDescendants()) do
					if Obj:IsA("UIStroke") and Obj:GetAttribute("LunarionPreMinT") == nil then
						Obj:SetAttribute("LunarionPreMinT", Obj.Transparency)
						Tw(Obj, 0.3, nil, nil, {Transparency = 1})
					end
				end
				MinimizeBtn.Ico.Image = "rbxassetid://7072720870"
				for _, Piece in ipairs({Author, Subtitle}) do
					if Piece then
						Tw(Piece, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = 1})
					end
				end
				SettingsBtn.Visible = false
				local Curtain = MakeCurtain(1)
				Tw(Curtain, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundTransparency = 0})
				task.wait(0.2)
				if not Minimized then
					Curtain:Destroy()
					MinimizeBusy = false
					DragLocks[MainWindow] = nil
					return
				end
				table.clear(BodyParked)
				for _, Child in ipairs(MainWindow:GetChildren()) do
					if Child:IsA("GuiObject") and Child.Visible and Child ~= Curtain and Child ~= Veil and Child ~= Sheen
						and Child ~= DragPoint and Child.Name ~= "TopBar" then
						Child.Visible = false
						table.insert(BodyParked, Child)
					end
				end
				Curtain:Destroy()
				if Author then Author.Visible = false end
				if Subtitle then Subtitle.Visible = false end
				SearchBtn.Visible, LayoutBtn.Visible, CapsuleSep.Visible = false, false, false
				SettingsBtn.Visible = false
				WindowTopBarLine.Visible = false
				TweenService:Create(WindowName, TweenInfo.new(0.46, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
					Position = UDim2.new(0, NameX, 0, 25 - 50)
				}):Play()
				WindowName.Size = UDim2.new(0, math.max(40, CapsuleWidth() - NameX - 100), 2, 0)
				MoveTo(CapsuleWidth(), 50, 25)
				task.wait(0.5)
			else
				-- Restore: 1) the shell grows (body stays parked, nothing is squashed), 2) the content appears behind a
				-- curtain once the shell is almost full size, 3) the curtain fades out while buttons and strokes fade in.
				Minimized = false
				MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
				local GrowTime = 0.44
				TweenService:Create(WindowName, TweenInfo.new(GrowTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Position = UDim2.new(0, NameX, 0, (Author and 18 or 26) - 50)
				}):Play()
				MoveTo(MainSize.X.Offset, MainSize.Y.Offset, 10, Enum.EasingDirection.Out, GrowTime)
				task.wait(GrowTime * 0.62)
				if Minimized then
					return
				end
				local Curtain = MakeCurtain(0)
				for _, Child in ipairs(BodyParked) do
					if Child.Parent then
						Child.Visible = true
					end
				end
				table.clear(BodyParked)
				WindowTopBarLine.Visible = true
				local Revealed = {SearchBtn, LayoutBtn, SettingsBtn}
				SearchBtn.Visible, CapsuleSep.Visible = true, true
				LayoutBtn.Visible = WindowConfig.TabStyleToggle ~= false
				SettingsBtn.Visible = WindowConfig.Settings ~= false
				for _, Btn in ipairs(Revealed) do
					if Btn.Visible and Btn:FindFirstChild("Ico") then
						Btn.Ico.ImageTransparency = 1
						Tw(Btn.Ico, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {ImageTransparency = 0})
					end
				end
				task.wait(GrowTime * 0.38 + 0.02)
				MainWindow.Size = MainSize
				for _, Obj in ipairs(MainWindow:GetDescendants()) do
					if Obj:IsA("UIStroke") then
						local Pre = Obj:GetAttribute("LunarionPreMinT")
						if Pre ~= nil then
							Tw(Obj, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Transparency = Pre})
							Obj:SetAttribute("LunarionPreMinT", nil)
						end
					end
				end
				for _, Piece in ipairs({Author, Subtitle}) do
					if Piece then
						Piece.Visible = true
						Piece.TextTransparency = 1
						Tw(Piece, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = 0.35})
					end
				end
				Tw(Curtain, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundTransparency = 1})
				task.wait(0.32)
				Curtain:Destroy()
			end
			DragLocks[MainWindow] = nil
			MinimizeBusy = false
			if not Minimized and AdaptWindow then
				AdaptWindow()
			end
		end)
	end

	AddConnection(MinimizeBtn.MouseButton1Click, function()
		SetMinimized(not Minimized)
	end)

	-- Follower loop: keeps the search on its layer, glued to the window; hides it (and the resize grip)
	-- whenever the window is minimized, closed or in the middle of an animation.
	local ResizeGrip
	AddConnection(RunService.RenderStepped, function()
		local Idle = MainWindow.Visible and not Minimized and not MinimizeBusy and not Animating and not UIHidden
		if not Idle and SearchBox and SearchBox.TextEditable then
			SetSearchExpanded(false)
		end
		if ResizeGrip and ResizeGrip.Parent then
			ResizeGrip.Visible = Idle
		end
	end)

	-- Ctrl + K jumps straight into search
	AddConnection(UserInputService.InputBegan, function(Input)
		if Input.KeyCode == Enum.KeyCode.K and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
			if MainWindow.Visible and not Minimized and not Animating then
				SetSearchExpanded(true, true)
			end
		end
	end)

	-- Resize handle: ONE smooth curved line that follows the window's bottom-right corner from the outside.
	-- It is drawn as a chain of overlapping rounded segments on an arc concentric with the corner (tapered
	-- like a brush stroke), so it stays perfectly curved at every corner radius. It draws itself in when the
	-- window settles, thickens and takes the accent colour when hovered or dragged.
	do
		ResizeGrip = Create("Frame", {
			Name = "ResizeGrip",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(0, 0),
			ZIndex = 90,
			Visible = false,
			Parent = Root
		})

		local ArcFrom, ArcTo = 10, 80 -- degrees (0 = right, 90 = down)
		local ArcGap = 7
		local Segs = 30
		local SegList = {}
		for Index = 1, Segs do
			SegList[Index] = Create("Frame", {
				Name = "Seg" .. Index,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(0, 0),
				BackgroundColor3 = ThemeColor("TextDark"),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 92,
				Parent = ResizeGrip
			}, {
				Create("UICorner", {CornerRadius = UDim.new(1, 0)})
			})
		end

		local Hits = {}
		for Index, Angle in ipairs({25, 45, 65}) do
			Hits[Index] = {Angle = math.rad(Angle), Btn = Create("TextButton", {
				Name = "Hit" .. Index,
				Text = "",
				AutoButtonColor = false,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(22, 22),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 93,
				Parent = ResizeGrip
			})}
		end

		local MinW = math.min(460, MainSize.X.Offset)
		local MinH = math.min(300, MainSize.Y.Offset)
		local Resizing, StartMouse, StartSize = false, nil, nil
		local Shown, Hovering = false, 0
		local Reveal, Weight, Tint = 0, 0, ThemeColor("TextDark") -- Weight: 0 idle .. 1 hovered/dragged

		local function Step(Delta)
			if not ResizeGrip.Parent or not MainWindow.Parent then return end
			local Pos = MainWindow.AbsolutePosition - Root.AbsolutePosition
			local Size = MainWindow.AbsoluteSize
			local Radius = WindowCorner.CornerRadius.Offset
			local CenterX, CenterY = Pos.X + Size.X - Radius, Pos.Y + Size.Y - Radius
			local Reach = Radius + ArcGap
			local Ease = math.clamp(Delta * 14, 0, 1)
			local Target = (Hovering > 0 or Resizing) and 1 or 0
			Weight = Weight + (Target - Weight) * Ease
			Reveal = math.clamp(Reveal + (Shown and Delta / 0.55 or -Delta / 0.25), 0, 1)
			local Goal = Resizing and ThemeColor("Accent") or (Hovering > 0 and ThemeColor("Text") or ThemeColor("TextDark"))
			Tint = Tint:Lerp(Goal, Ease)
			local Span = math.rad(ArcTo - ArcFrom)
			local Length = Reach * Span / (Segs - 1) * 1.35 + 1
			for Index, Seg in ipairs(SegList) do
				local Fraction = (Index - 1) / (Segs - 1)
				local Angle = math.rad(ArcFrom) + Span * Fraction
				local Mid = math.sin(Fraction * math.pi) -- 0 at the tips, 1 in the middle
				local Thick = (1.4 + Mid * (1.6 + Weight * 1.6)) * (1 + Weight * 0.15)
				local Own = math.clamp((Reveal - Fraction * 0.55) / 0.45, 0, 1)
				Own = 1 - (1 - Own) ^ 3
				Seg.Position = UDim2.fromOffset(math.floor(CenterX + math.cos(Angle) * Reach + 0.5), math.floor(CenterY + math.sin(Angle) * Reach + 0.5))
				Seg.Rotation = math.deg(Angle) + 90
				Seg.Size = UDim2.fromOffset(math.max(0, Length * Own), math.max(0, Thick * Own))
				Seg.BackgroundColor3 = Tint
				Seg.BackgroundTransparency = 1 - Own * (0.62 + Weight * 0.38)
			end
			for _, Hit in ipairs(Hits) do
				Hit.Btn.Position = UDim2.fromOffset(math.floor(CenterX + math.cos(Hit.Angle) * Reach + 0.5), math.floor(CenterY + math.sin(Hit.Angle) * Reach + 0.5))
			end
		end

		for _, Hit in ipairs(Hits) do
			AddConnection(Hit.Btn.MouseEnter, function()
				Hovering = Hovering + 1
			end)
			AddConnection(Hit.Btn.MouseLeave, function()
				Hovering = math.max(0, Hovering - 1)
			end)
			AddConnection(Hit.Btn.InputBegan, function(Input)
				if Minimized or Animating or UIHidden or MinimizeBusy then return end
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
					Resizing = true
					StartMouse = Vector2.new(Input.Position.X, Input.Position.Y)
					StartSize = MainWindow.AbsoluteSize
					CancelDragTween(MainWindow)
					DragLocks[MainWindow] = true
					SetSearchExpanded(false)
				end
			end)
		end

		AddConnection(UserInputService.InputChanged, function(Input)
			if not Resizing then return end
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
				local Cam = workspace.CurrentCamera
				local View = Cam and Cam.ViewportSize or ViewSize
				local Delta = Vector2.new(Input.Position.X, Input.Position.Y) - StartMouse
				local WindowPos = MainWindow.AbsolutePosition
				local MaxW = math.max(MinW, View.X - WindowPos.X - 28)
				local MaxH = math.max(MinH, View.Y - WindowPos.Y - 28)
				local W = math.clamp(StartSize.X + Delta.X, MinW, MaxW)
				local H = math.clamp(StartSize.Y + Delta.Y, MinH, MaxH)
				MainWindow.Size = UDim2.fromOffset(math.floor(W), math.floor(H))
				MainSize = MainWindow.Size
				-- smart sidebar: a narrow window folds the sidebar to icons by itself, a wide one opens it again
				if not ManualSidebar then
					local Narrow = W < 540
					if Narrow ~= SidebarCollapsed then
						SetSidebarCollapsed(Narrow, true)
					end
				end
			end
		end)

		AddConnection(UserInputService.InputEnded, function(Input)
			if Resizing and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
				Resizing = false
				if not Animating and not MinimizeBusy then DragLocks[MainWindow] = nil end
			end
		end)

		AddConnection(RunService.RenderStepped, function(Delta)
			if not (ResizeGrip and ResizeGrip.Parent) then return end
			local Idle = MainWindow.Visible and not Minimized and not MinimizeBusy and not Animating and not UIHidden
			Shown = Idle
			ResizeGrip.Visible = Idle or Reveal > 0
			if ResizeGrip.Visible then
				Step(Delta)
			end
		end)
	end

	-- Intro / loading screen: ONLY the logo and white text, on a fully clear layer. There is no backdrop and it
	-- never sinks input, so you can keep walking around while it plays. They fade in, hold, fade out, then the
	-- window opens.
	local function LoadSequence()
		MainWindow.Visible = false

		local Layer = Create("Frame", {
			Name = "IntroLayer",
			Parent = Root,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Active = false,
			ZIndex = 90
		})

		local IconSize = WindowConfig.IntroIconSize or 64
		local TextSize = WindowConfig.IntroTextSize or 34
		local TextWidth = math.ceil(MeasureText(WindowConfig.IntroText, TextSize, Fonts.Title, Vector2.new(2000, 200)).X)
		local Gap = 16
		local TotalWidth = IconSize + Gap + TextWidth
		local White = Color3.fromRGB(255, 255, 255)

		local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon, WindowConfig.ImageSource), {
			Parent = Layer,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, -TotalWidth / 2 + IconSize / 2, 0.5, 8),
			Size = UDim2.new(0, IconSize, 0, IconSize),
			ImageColor3 = WindowConfig.IntroIconColor or White,
			ImageTransparency = 1,
			ZIndex = 91
		})

		local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, TextSize), {
			Parent = Layer,
			Size = UDim2.new(0, TextWidth, 0, TextSize + 10),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0.5, -TotalWidth / 2 + IconSize + Gap, 0.5, 8),
			TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = Fonts.Title,
			TextColor3 = White,
			TextTransparency = 1,
			ZIndex = 91
		})

		local LoadSequenceSub
		if type(WindowConfig.IntroSubtitle) == "string" and WindowConfig.IntroSubtitle ~= "" then
			LoadSequenceSub = SetProps(MakeElement("Label", WindowConfig.IntroSubtitle, 13), {
				Parent = Layer,
				Size = UDim2.new(0, TextWidth, 0, 16),
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.new(0.5, -TotalWidth / 2 + IconSize + Gap, 0.5, TextSize / 2 + 14),
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = Fonts.Thin,
				TextColor3 = White,
				TextTransparency = 1,
				ZIndex = 91
			})
		end

		local FadeIn = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		TweenService:Create(LoadSequenceLogo, FadeIn, {ImageTransparency = 0, Position = UDim2.new(0.5, -TotalWidth / 2 + IconSize / 2, 0.5, 0)}):Play()
		task.wait(0.2)
		TweenService:Create(LoadSequenceText, FadeIn, {TextTransparency = 0, Position = UDim2.new(0.5, -TotalWidth / 2 + IconSize + Gap, 0.5, 0)}):Play()
		if LoadSequenceSub then
			TweenService:Create(LoadSequenceSub, FadeIn, {TextTransparency = 0.25}):Play()
		end
		task.wait(WindowConfig.IntroDuration or 1.6)

		local FadeOut = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(LoadSequenceLogo, FadeOut, {ImageTransparency = 1}):Play()
		TweenService:Create(LoadSequenceText, FadeOut, {TextTransparency = 1}):Play()
		if LoadSequenceSub then
			TweenService:Create(LoadSequenceSub, FadeOut, {TextTransparency = 1}):Play()
		end
		task.wait(0.25)

		WindowToken = WindowToken + 1
		PlayOpen(WindowToken, true)
		task.delay(0.3, function()
			Layer:Destroy()
		end)
	end

	if WindowConfig.IntroEnabled then
		LoadSequence()
	end	

	-- SmartPill: fixed position (not draggable), shown only while the interface is closed --
	if WindowConfig.ShowPill then
		-- the eye + label are pushed toward pure white on dark themes (light themes keep their dark text)
		local function PillTint()
			local Text = ThemeColor("Text")
			if Text.R * 0.3 + Text.G * 0.59 + Text.B * 0.11 > 0.5 then
				return Text:Lerp(Color3.fromRGB(255, 255, 255), 0.85)
			end
			return Text
		end

		local PillClick = SetProps(MakeElement("Button"), {
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 6,
			Name = "Interact"
		})

		Pill = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 1, 0), {
			Parent = Root,
			Name = "Pill",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = WindowConfig.PillPosition,
			Size = UDim2.new(0, PillW, 0, PillH),
			BackgroundTransparency = 0,
			ZIndex = 2,
			Visible = UIHidden
		}), {
			AddThemeObject(MakeElement("Stroke"), "Stroke"),
			SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 1, 0),
				Name = "Content"
			}), {
				SetProps(MakeElement("List", 0, 8), {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center
				}),
				SetProps(MakeElement("Image", WindowConfig.PillIcon, WindowConfig.PillImageSource), {
					Size = UDim2.new(0, 16, 0, 16),
					ImageColor3 = WindowConfig.PillIconIsLogo and Color3.new(1, 1, 1) or PillTint(),
					LayoutOrder = 1,
					Name = "Ico"
				}),
				SetProps(MakeElement("Label", WindowConfig.PillText, 14), {
					Size = UDim2.new(0, PillTextWidth, 1, 0),
					FontFace = Fonts.Body,
					TextColor3 = PillTint(),
					TextTruncate = Enum.TextTruncate.AtEnd,
					LayoutOrder = 2,
					Name = "Title"
				})
			}),
			PillClick
		}), "Second")

		PillScale = Create("UIScale", {Scale = 1, Parent = Pill})

		table.insert(Lunarion.ThemeListeners, function()
			if Pill and Pill.Parent then
				Pill.Content.Ico.ImageColor3 = WindowConfig.PillIconIsLogo and Color3.new(1, 1, 1) or PillTint()
				Pill.Content.Title.TextColor3 = PillTint()
			end
		end)

		AddConnection(PillClick.MouseEnter, function()
			if not Animating then
				Tw(PillScale, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Scale = 1.06})
			end
		end)

		AddConnection(PillClick.MouseLeave, function()
			if not Animating then
				Tw(PillScale, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Scale = 1})
			end
		end)

		AddConnection(PillClick.MouseButton1Down, function()
			if not Animating then
				Tw(PillScale, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Scale = 0.94})
			end
		end)

		AddConnection(PillClick.MouseButton1Click, function()
			SetUIHidden(not UIHidden)
		end)
	end

	local TabOrder = 0
	local function NextTabOrder()
		TabOrder = TabOrder + 1
		return TabOrder
	end
	local CurrentSection
	local ActiveContainer, ActiveTabIndex, ActiveSlide = nil, 0, nil
	local TabCounter = 0
	local ActiveTabButton
	local AllTabButtons = {}
	local AllContainers = {}
	local AllSections = {}
	local TopMode = false
	local TopH = 40
	local SetTabStyle
	local function ContentPos()
		return TopMode and UDim2.new(0, 0, 0, 50 + TopH) or UDim2.new(0, SideWidth, 0, 50)
	end
	local function ContentSize()
		return TopMode and UDim2.new(1, 0, 1, -(50 + TopH)) or UDim2.new(1, -SideWidth, 1, -50)
	end
	local function Compact()
		return SidebarCollapsed and not TopMode
	end

	-- Top tab bar (the Rayfield-style alternative to the sidebar). Same buttons, same containers: the tab buttons
	-- are simply re-parented, so nothing about tabs, search or sections changes between the two layouts.
	local TopTabs = AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
		Name = "TopTabs",
		Position = UDim2.new(0, 0, 0, 50),
		Size = UDim2.new(1, 0, 0, TopH),
		Visible = false,
		Parent = MainWindow
	}), {
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Name = "Edge",
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundTransparency = 0.4
		}), "Stroke")
	}), "Second")
	local TopScroll = SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 2), {
		Name = "Scroll",
		Size = UDim2.new(1, 0, 1, -1),
		ScrollingDirection = Enum.ScrollingDirection.X,
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		Parent = TopTabs
	}), {
		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4)
		}),
		Create("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})
	})
	local RestPositions = setmetatable({}, {__mode = "k"})
	local TabActivators = setmetatable({}, {__mode = "k"})
	local SearchIndex = {}
	local function RegisterSearchable(ItemName, TabBtn, Cont, Target)
		table.insert(SearchIndex, {Name = ItemName, TabFrame = TabBtn, Container = Cont, Target = Target})
	end

	local function TabWidth(Btn)
		return 12 + 16 + 8 + math.ceil(MeasureText(Btn.Title.Text, 13, Fonts.Body, Vector2.new(1000, 100)).X) + 14
	end

	local function ApplySidebarMode(Btn, Animate)
		local Ico, Title = Btn.Ico, Btn.Title
		local Time = Animate and 0.3 or 0
		local Slim = Compact()
		local PillSize
		if TopMode then
			PillSize = UDim2.new(0, TabWidth(Btn), 0, 28)
		else
			PillSize = Slim and UDim2.new(0, 30, 0, 30) or UDim2.new(1, -16, 0, 28)
		end
		if Time == 0 then
			Btn.Size = PillSize
		else
			Tw(Btn, Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = PillSize})
		end
		if Slim then
			Ico.AnchorPoint = Vector2.new(0.5, 0.5)
			Tw(Ico, Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Position = UDim2.new(0.5, 0, 0.5, 0)})
			Tw(Title, Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = 1})
		else
			Ico.AnchorPoint = Vector2.new(0, 0.5)
			Tw(Ico, Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Position = UDim2.new(0, 12, 0.5, 0)})
			Tw(Title, Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = (Btn == ActiveTabButton) and 0 or 0.4})
		end
	end

	function SetSidebarCollapsed(Collapsed, Animate)
		SidebarCollapsed = Collapsed
		SideWidth = Collapsed and IconWidth or ExpandedWidth
		local Time = Animate == false and 0 or 0.4
		Tw(WindowStuff, Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = UDim2.new(0, SideWidth, 1, -50)})
		for _, Btn in ipairs(AllTabButtons) do
			ApplySidebarMode(Btn, Animate ~= false)
		end
		for _, Section in ipairs(AllSections) do
			Section.Relayout()
		end
		-- icon-only mode: the nickname and @user fade out (and stay hidden), the avatar slides to the middle
		local Profile = WindowStuff:FindFirstChild("ProfileName") and WindowStuff or (WindowStuff:FindFirstChild("ProfileName", true) and WindowStuff:FindFirstChild("ProfileName", true).Parent)
		if Profile then
			local NameLbl, UserLbl = Profile:FindFirstChild("ProfileName"), Profile:FindFirstChild("ProfileUser")
			local Avatar, Ring = Profile:FindFirstChild("Avatar"), Profile:FindFirstChild("AvatarRing")
			for _, Piece in ipairs({NameLbl, UserLbl}) do
				if Piece then
					if Collapsed then
						Tw(Piece, Time == 0 and 0 or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = 1})
					else
						task.delay(Time == 0 and 0 or 0.16, function()
							if SidebarCollapsed or not Piece.Parent then return end
							Tw(Piece, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = Piece == UserLbl and 0.15 or 0})
						end)
					end
					Piece.Visible = (Piece == NameLbl) or not WindowConfig.HidePremium
				end
			end
			for _, Piece in ipairs({Avatar, Ring}) do
				if Piece then
					Piece.AnchorPoint = Vector2.new(0.5, 0.5)
					Tw(Piece, Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
						Position = Collapsed and UDim2.new(0, IconWidth / 2, 0.5, 0) or UDim2.new(0, 26, 0.5, 0)
					})
				end
			end
		end
		for _, Cont in ipairs(AllContainers) do
			local NewRest = ContentPos()
			local NewSize = ContentSize()
			RestPositions[Cont] = NewRest
			if Cont.Visible then
				Tw(Cont, Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Position = NewRest, Size = NewSize})
			else
				Cont.Position = NewRest
				Cont.Size = NewSize
			end
		end
	end

	-- pulse an accent glow on the thing that was found so it is impossible to miss
	local function Flash(Target)
		if not (Target and Target.Parent) then
			return
		end
		local Old = Target:FindFirstChild("SearchGlow")
		if Old then
			Old:Destroy()
		end
		local Corner = Target:FindFirstChildOfClass("UICorner")
		local Accent = ThemeColor("Text") -- neutral highlight, never the accent hue
		local GlowStroke = Create("UIStroke", {Color = Accent, Thickness = 1.5, Transparency = 1})
		local Glow = Create("Frame", {
			Name = "SearchGlow",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Active = false,
			ZIndex = 50,
			Parent = Target
		}, {
			Create("UICorner", {CornerRadius = Corner and Corner.CornerRadius or UDim.new(0, 6)}),
			GlowStroke
		})
		task.spawn(function()
			for _ = 1, 3 do
				if not Glow.Parent then
					return
				end
				Tw(Glow, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundTransparency = 0.88})
				Tw(GlowStroke, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Transparency = 0.35})
				task.wait(0.34)
				if not Glow.Parent then
					return
				end
				Tw(Glow, 0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {BackgroundTransparency = 1})
				Tw(GlowStroke, 0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {Transparency = 1})
				task.wait(0.4)
			end
			Glow:Destroy()
		end)
	end

	-- open the tab the result lives in, scroll to it, then highlight it (a tab result highlights the tab button)
	local function GoTo(Item)
		local Container, Target = Item.Container, Item.Target
		local Activate = TabActivators[Container]
		if Activate then
			Activate()
		end
		SearchBox.Text = ""
		SetSearchExpanded(false)
		if not (Target and Target.Parent and Container and Container.Parent) then
			return
		end
		task.spawn(function()
			task.wait(0.12) -- let the tab's layout settle
			if not (Target.Parent and Container.Parent) then
				return
			end
			if Target == Container then
				Flash(Item.TabFrame)
				return
			end
			local Offset = Target.AbsolutePosition.Y - Container.AbsolutePosition.Y + Container.CanvasPosition.Y
			local MaxY = math.max(Container.AbsoluteCanvasSize.Y - Container.AbsoluteWindowSize.Y, 0)
			local Goal = math.clamp(Offset - 20, 0, MaxY)
			Tw(Container, 0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {CanvasPosition = Vector2.new(0, Goal)})
			task.wait(0.35)
			Flash(Target)
		end)
	end

	local LastMatches = {}
	local function RenderResults(Query)
		for _, Child in ipairs(ResultsList:GetChildren()) do
			if Child:IsA("GuiObject") then
				Child:Destroy()
			end
		end
		Query = string.lower(Query)
		local Starts, Contains = {}, {}
		for _, Item in ipairs(SearchIndex) do
			if Item.Target and Item.Target.Parent then
				local Found = string.find(string.lower(Item.Name), Query, 1, true)
				if Found == 1 then
					table.insert(Starts, Item)
				elseif Found then
					table.insert(Contains, Item)
				end
			end
		end
		local Matches = {}
		for _, List in ipairs({Starts, Contains}) do
			for _, Item in ipairs(List) do
				if #Matches < 10 then
					table.insert(Matches, Item)
				end
			end
		end
		LastMatches = Matches

		local CardW = ResultsCard.Size.X.Offset
		ResultsCard.Visible = true

		if #Matches == 0 then
			AddThemeObject(SetProps(MakeElement("Label", "No results", 13), {
				Size = UDim2.new(1, 0, 0, 30),
				FontFace = Fonts.Body,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextTransparency = 0.3,
				ZIndex = 7,
				Parent = ResultsList
			}), "TextDark")
			ResultsList.CanvasSize = UDim2.new(0, 0, 0, 38)
			Tw(ResultsCard, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = UDim2.new(0, CardW, 0, 38)})
			return
		end

		local HoverColor = Shift(ThemeColor("Second"), 12)
		for Index, Item in ipairs(Matches) do
			local TabName = "Tab"
			if Item.Target ~= Item.Container and Item.TabFrame and Item.TabFrame:FindFirstChild("Title") then
				TabName = Item.TabFrame.Title.Text
			end
			local Row = SetChildren(SetProps(MakeElement("RoundFrame", HoverColor, 0, 6), {
				Size = UDim2.new(1, 0, 0, 30),
				LayoutOrder = Index,
				BackgroundTransparency = 1,
				ZIndex = 7,
				Parent = ResultsList
			}), {
				AddThemeObject(SetProps(MakeElement("Label", Item.Name, 13), {
					Size = UDim2.new(0.62, -8, 1, 0),
					Position = UDim2.new(0, 8, 0, 0),
					FontFace = Fonts.Body,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 8
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", TabName, 11), {
					Size = UDim2.new(0.38, -10, 1, 0),
					Position = UDim2.new(0.62, 0, 0, 0),
					FontFace = Fonts.Thin,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextTransparency = 0.25,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 8
				}), "TextDark"),
				SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0), Name = "Click", ZIndex = 9})
			})
			AddConnection(Row.Click.MouseEnter, function()
				Tw(Row, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundTransparency = 0})
			end)
			AddConnection(Row.Click.MouseLeave, function()
				Tw(Row, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundTransparency = 1})
			end)
			AddConnection(Row.Click.MouseButton1Click, function()
				GoTo(Item)
			end)
		end
		local Height = math.min(#Matches * 32 + 8, 210)
		ResultsList.CanvasSize = UDim2.new(0, 0, 0, #Matches * 32 + 8)
		Tw(ResultsCard, 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = UDim2.new(0, CardW, 0, Height)})
	end

	AddConnection(SearchBox:GetPropertyChangedSignal("Text"), function()
		if SearchBox.Text == "" then
			CloseSearchResults()
		else
			RenderResults(SearchBox.Text)
		end
	end)

	AddConnection(SearchBox.FocusLost, function(EnterPressed)
		if EnterPressed and LastMatches[1] and SearchBox.Text ~= "" then
			GoTo(LastMatches[1])
			return
		end
		if SearchBox.Text == "" then
			task.delay(0.12, function()
				if SearchBox.Text == "" then
					SetSearchExpanded(false)
				end
			end)
		end
	end)

	SetSidebarCollapsed(SidebarCollapsed, false)

	local function PickIcon(Candidates)
		for _, Entry in ipairs(Candidates) do
			if ResolveIcon(Entry[1], Entry[2]) then
				return Entry[1], Entry[2]
			end
		end
		return Candidates[#Candidates][1], Candidates[#Candidates][2]
	end

	-- "Side" (sidebar) or "Top" (tab bar under the title). Animated when Animate is true.
	function SetTabStyle(Top, Animate)
		Top = Top and true or false
		TopMode = Top
		WindowStuff.Visible = not Top and not Minimized
		TopTabs.Visible = Top and not Minimized
		for _, Btn in ipairs(AllTabButtons) do
			Btn.Parent = Top and TopScroll or TabHolder
		end
		for _, Section in ipairs(AllSections) do
			Section.Frame.Parent = Top and TopScroll or TabHolder
			Section.Relayout()
		end
		for _, Btn in ipairs(AllTabButtons) do
			ApplySidebarMode(Btn, false)
		end
		local Time = Animate and 0.4 or 0
		for _, Cont in ipairs(AllContainers) do
			RestPositions[Cont] = ContentPos()
			if Time > 0 and Cont.Visible then
				Tw(Cont, Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Position = ContentPos(), Size = ContentSize()})
			else
				Cont.Position = ContentPos()
				Cont.Size = ContentSize()
			end
		end
		local Name, Source = PickIcon(Top and {{"panel-left", nil}} or {{"panel-top", nil}})
		ApplyIcon(LayoutBtn.Ico, Name, Source)
		if AdaptWindow then
			task.defer(AdaptWindow)
		end
	end

	AddConnection(LayoutBtn.MouseButton1Click, function()
		if Minimized or MinimizeBusy or Animating then
			return
		end
		SetTabStyle(not TopMode, true)
	end)
	SetTabStyle(tostring(WindowConfig.TabStyle or "Side"):lower() == "top", false)


	local TabFunction = {}
	function TabFunction:ToggleInterface()
		SetUIHidden(not UIHidden)
	end

	function TabFunction:Minimize(State)
		if State == nil then
			State = not Minimized
		end
		SetMinimized(State)
	end

	function TabFunction:Resize(Width, Height)
		local Cam = workspace.CurrentCamera
		local View = Cam and Cam.ViewportSize or ViewSize
		local MinWidth = math.min(460, MainSize.X.Offset)
		local MinHeight = math.min(300, MainSize.Y.Offset)
		Width = math.clamp(tonumber(Width) or MainSize.X.Offset, MinWidth, math.max(MinWidth, View.X - 20))
		Height = math.clamp(tonumber(Height) or MainSize.Y.Offset, MinHeight, math.max(MinHeight, View.Y - 20))
		MainSize = UDim2.fromOffset(Width, Height)
		if not Minimized and not Animating then
			local Size = MainWindow.AbsoluteSize
			local X = math.clamp(MainWindow.AbsolutePosition.X, 8, math.max(8, View.X - Width - 8))
			local Y = math.clamp(MainWindow.AbsolutePosition.Y, 8, math.max(8, View.Y - Height - 8))
			MainWindow.Position = UDim2.fromOffset(X, Y)
			MainWindow.Size = MainSize
		end
	end

	function TabFunction:SetTabStyle(Style)
		if Style == nil or Style == "Toggle" then
			SetTabStyle(not TopMode, true)
		else
			SetTabStyle(tostring(Style):lower() == "top", true)
		end
	end

	function TabFunction:OpenSearch()
		if MainWindow.Visible and not Minimized and not Animating then
			SetSearchExpanded(true, true)
		end
	end

	-- Divider between tabs, with an optional name and icon:
	--   Window:MakeTabSection("Combat")  or  Window:MakeTabSection({Name = "Combat", Icon = "sword", Line = true})
	--   Window:MakeTabSection()          -> just a line
	function TabFunction:MakeTabSection(SectionConfig)
		if type(SectionConfig) == "string" then
			SectionConfig = {Name = SectionConfig}
		end
		SectionConfig = SectionConfig or {}
		local Name = type(SectionConfig.Name) == "string" and SectionConfig.Name ~= "" and SectionConfig.Name or nil
		local HasIcon = SectionConfig.Icon ~= nil and SectionConfig.Icon ~= ""
		local ShowLine = SectionConfig.Line ~= false
		local Rich = Name ~= nil or HasIcon
		CurrentSection = Name or CurrentSection

		local Frame = SetProps(MakeElement("TFrame"), {
			Name = "TabSection",
			Size = UDim2.new(1, 0, 0, Rich and 24 or 14),
			LayoutOrder = NextTabOrder(),
			Parent = TopMode and TopScroll or TabHolder
		})
		local Line = AddThemeObject(SetProps(MakeElement("Frame"), {
			Name = "Line",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 14, 0.5, 0),
			Size = UDim2.new(1, -28, 0, 1),
			BackgroundTransparency = 0.35,
			Visible = ShowLine,
			Parent = Frame
		}), "Stroke")

		-- A section is a plain line. If it has an icon / name, a small chip sits on the line; the name slides out
		-- of the chip when the row is hovered or tapped. Nothing is ever drawn truncated: the label shrinks to fit.
		local Chip, Mark, Label
		local NameWidth = 0
		local Open = false
		if Rich then
			Chip = AddThemeObject(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 1, 0), {
				Name = "Chip",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 10, 0.5, 0),
				Size = UDim2.new(0, 24, 0, 22),
				ClipsDescendants = true,
				Parent = Frame
			}), "Second")
			if HasIcon then
				Mark = AddThemeObject(SetProps(MakeElement("Image", SectionConfig.Icon, SectionConfig.ImageSource), {
					Name = "Mark",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0, 12, 0.5, 0),
					Size = UDim2.new(0, 14, 0, 14),
					ImageTransparency = 0.3,
					Parent = Chip
				}), "TextDark")
			else
				Mark = AddThemeObject(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 1, 0), {
					Name = "Mark",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0, 12, 0.5, 0),
					Size = UDim2.new(0, 6, 0, 6),
					Parent = Chip
				}), "TextDark")
			end
			if Name then
				Label = AddThemeObject(SetProps(MakeElement("Label", Name, 11), {
					Name = "Title",
					Position = UDim2.new(0, 28, 0, 0),
					Size = UDim2.new(0, 10, 1, 0),
					FontFace = Fonts.Title,
					TextTransparency = 1,
					TextScaled = true,
					TextWrapped = false,
					Parent = Chip
				}), "TextDark")
				Create("UITextSizeConstraint", {MaxTextSize = 11, MinTextSize = 7, Parent = Label})
				NameWidth = math.ceil(MeasureText(Name, 11, Fonts.Title, Vector2.new(1000, 100)).X)
			end
		end

		local function Relayout()
			if TopMode then
				Frame.Size = UDim2.new(0, Rich and 26 or 12, 0, 28)
				Line.AnchorPoint = Vector2.new(0.5, 0.5)
				Line.Position = UDim2.new(0.5, 0, 0.5, 0)
				Line.Size = UDim2.new(0, 1, 0, 18)
				if Chip then
					Chip.AnchorPoint = Vector2.new(0.5, 0.5)
					Chip.Position = UDim2.new(0.5, 0, 0.5, 0)
					Chip.Size = UDim2.new(0, 22, 0, 22)
				end
			else
				Frame.Size = UDim2.new(1, 0, 0, Rich and 24 or 14)
				Line.AnchorPoint = Vector2.new(0, 0.5)
				Line.Position = UDim2.new(0, 14, 0.5, 0)
				Line.Size = UDim2.new(1, -28, 0, 1)
				if Chip then
					if Compact() then
						Chip.AnchorPoint = Vector2.new(0.5, 0.5)
						Chip.Position = UDim2.new(0.5, 0, 0.5, 0)
					else
						Chip.AnchorPoint = Vector2.new(0, 0.5)
						Chip.Position = UDim2.new(0, 10, 0.5, 0)
					end
					Chip.Size = UDim2.new(0, 24, 0, 22)
				end
			end
			Open = false
			if Label then
				Label.TextTransparency = 1
			end
		end

		local function SetOpen(On)
			if not Chip or not Label or TopMode or Compact() then
				return
			end
			Open = On
			local Avail = math.max(24, Frame.AbsoluteSize.X - 24)
			local Wide = math.min(28 + NameWidth + 12, Avail)
			Tw(Chip, 0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = UDim2.new(0, On and Wide or 24, 0, 22)})
			Label.Size = UDim2.new(0, math.max(10, Wide - 28 - 10), 1, 0)
			Tw(Label, On and 0.35 or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {TextTransparency = On and 0.05 or 1})
			if Mark:IsA("ImageLabel") then
				Tw(Mark, 0.25, nil, nil, {ImageTransparency = On and 0 or 0.3})
			end
		end

		if Chip then
			local Hit = SetProps(MakeElement("Button"), {Name = "Hit", Size = UDim2.new(1, 0, 1, 0), ZIndex = 5, Parent = Frame})
			AddConnection(Hit.MouseEnter, function() SetOpen(true) end)
			AddConnection(Hit.MouseLeave, function() SetOpen(false) end)
			AddConnection(Hit.MouseButton1Click, function() SetOpen(not Open) end) -- touch: tap to reveal
		end

		local Section = {Frame = Frame, Relayout = Relayout}
		table.insert(AllSections, Section)
		Relayout()

		function Section:SetName(NewName)
			if Label then
				Label.Text = tostring(NewName)
				NameWidth = math.ceil(MeasureText(Label.Text, 11, Fonts.Title, Vector2.new(1000, 100)).X)
			end
		end
		function Section:Destroy()
			for Index, Entry in ipairs(AllSections) do
				if Entry == Section then
					table.remove(AllSections, Index)
					break
				end
			end
			Frame:Destroy()
		end
		return Section
	end
	TabFunction.AddTabSection = TabFunction.MakeTabSection
	TabFunction.MakeTabDivider = TabFunction.MakeTabSection

	function TabFunction:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Name = TabConfig.Name or "Tab"
		TabConfig.Icon = TabConfig.Icon or ""
		TabConfig.PremiumOnly = TabConfig.PremiumOnly or false
		if type(TabConfig.Section) == "string" and TabConfig.Section ~= "" and TabConfig.Section ~= CurrentSection then
			TabFunction:MakeTabSection(TabConfig.Section)
		end

		local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
			Size = UDim2.new(1, -16, 0, 28),
			LayoutOrder = NextTabOrder(),
			Parent = TopMode and TopScroll or TabHolder
		}), {
			AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon, TabConfig.ImageSource), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0, 12, 0.5, 0),
				ImageTransparency = 0.4,
				Name = "Ico"
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 13), {
				Size = UDim2.new(1, -40, 1, 0),
				Position = UDim2.new(0, 34, 0, 0),
				FontFace = Fonts.Body,
				TextTransparency = 0.4,
				Name = "Title"
			}), "Text")
		})

		if TabConfig.Hidden then
			TabFrame.Visible = false -- a page without a sidebar / top-bar button
		end
		table.insert(AllTabButtons, TabFrame)
		ApplySidebarMode(TabFrame, false)

		-- selected-tab styling: a soft accent wash on a round pill
		Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = TabFrame})
		AddThemeObject(TabFrame, "Accent")
		TabFrame.BackgroundTransparency = 1

		TabCounter = TabCounter + 1
		local TabIndex = TabCounter
		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 5), {
			Size = ContentSize(),
			Position = ContentPos(),
			Parent = MainWindow,
			Visible = false,
			Name = "ItemContainer"
		}), {
			MakeElement("List", 0, 6),
			MakeElement("Padding", 15, 10, 10, 15)
		}), "Divider")

		table.insert(AllContainers, Container)
		RestPositions[Container] = ContentPos()

		AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
		end)

		if TabConfig.Custom then
			TabConfig.Custom(Container)
		end

		if FirstTab and not TabConfig.Hidden then
			FirstTab = false
			TabFrame.Ico.ImageTransparency = 0
			TabFrame.BackgroundTransparency = 0.9
			if not Compact() then
				TabFrame.Title.TextTransparency = 0
			end
			TabFrame.Title.FontFace = Fonts.Body
			Container.Visible = true
			ActiveContainer, ActiveTabIndex, ActiveTabButton = Container, TabIndex, TabFrame
		end    

		local function ActivateTab()
			if ActiveContainer == Container then
				return
			end
			for _, Tab in ipairs(AllTabButtons) do
				if Tab:IsA("TextButton") then
					Tab.Title.FontFace = Fonts.Body
					Tw(Tab, 0.25, nil, nil, {BackgroundTransparency = 1})
					TweenService:Create(Tab.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.4}):Play()
					if not Compact() then
						TweenService:Create(Tab.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
					end
				end    
			end
			if ActiveSlide then
				ActiveSlide:Cancel()
				ActiveSlide = nil
			end
			for _, ItemContainer in next, MainWindow:GetChildren() do
				if ItemContainer.Name == "ItemContainer" then
					ItemContainer.Visible = false
					ItemContainer.Position = RestPositions[ItemContainer] or ContentPos()
				end    
			end  
			TweenService:Create(TabFrame.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
			Tw(TabFrame, 0.25, nil, nil, {BackgroundTransparency = 0.9})
			if not Compact() then
				TweenService:Create(TabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
			end
			TabFrame.Title.FontFace = Fonts.Body

			-- content slides in from the direction of the tab (down the list = from below, up = from above)
			local Direction = TabIndex > ActiveTabIndex and 1 or -1
			ActiveContainer, ActiveTabIndex, ActiveTabButton = Container, TabIndex, TabFrame
			local Rest = RestPositions[Container] or ContentPos()
			Container.Position = UDim2.new(Rest.X.Scale, Rest.X.Offset, 0, Rest.Y.Offset + 22 * Direction)
			Container.ScrollBarImageTransparency = 1
			Container.Visible = true
			ActiveSlide = Tw(Container, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Position = Rest})
			
		end
		TabActivators[Container] = ActivateTab
		RegisterSearchable(tostring(TabConfig.Name), TabFrame, Container, Container)
		AddConnection(TabFrame.MouseButton1Click, ActivateTab)

		-- Smart text card: the text size steps down as the text gets longer, the card height follows the wrapped
		-- text and glides (instead of jumping) whenever the text or the window width changes.
		local function SmartFit(Frame, Content, PadY, MinH, Base)
			local Last
			local function Fit(Animate)
				local H = math.max(MinH, Content.AbsoluteSize.Y + PadY)
				if Last == H then
					return
				end
				if Last == nil or not Animate then
					Frame.Size = UDim2.new(1, 0, 0, H)
				else
					Tw(Frame, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = UDim2.new(1, 0, 0, H)})
				end
				Last = H
			end
			local function Retier()
				local Count = utf8.len(Content.Text) or #Content.Text
				Content.TextSize = Count <= 70 and Base or (Count <= 150 and Base - 1 or (Count <= 280 and Base - 2 or Base - 3))
			end
			Retier()
			AddConnection(Content:GetPropertyChangedSignal("Text"), Retier)
			AddConnection(Content:GetPropertyChangedSignal("AbsoluteSize"), function()
				Fit(true)
			end)
			task.defer(function()
				Fit(false)
			end)
		end

		local function GetElements(ItemParent)
			local ElementFunction = {}
			function ElementFunction:AddLabel(Text)
				local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					MakeElement("Padding", 7, 12, 12, 7),
					AddThemeObject(SetProps(MakeElement("Label", tostring(Text or "Label"), 15), {
						Size = UDim2.new(1, 0, 0, 16),
						AutomaticSize = Enum.AutomaticSize.Y,
						FontFace = Fonts.Body,
						TextWrapped = true,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")
				SmartFit(LabelFrame, LabelFrame.Content, 14, 30, 15)

				local LabelFunction = {}
				function LabelFunction:Set(ToChange)
					LabelFrame.Content.Text = tostring(ToChange)
				end
				return LabelFunction
			end
			-- Coloured labels: AddWarningLabel (red + triangle), AddApproveLabel (green + check), AddCustomLabel (your colour/icon)
			-- Usage: AddWarningLabel("text")  or  AddWarningLabel({Text = "text", Color = ..., Icon = ...})
			-- AddCustomLabel("text", Color3, "icon")  or  AddCustomLabel({Text, Color, Icon, ImageSource})
			local function MakeColoredLabel(Config, DefaultColor, DefaultIcon, DefaultSource)
				local Accent = Config.Color or DefaultColor
				local White = Color3.fromRGB(255, 255, 255)
				local Main = ThemeColor("Main")
				local GFrom, GTo, GRot = ThemeGradient()
				local LabelFrame = SetChildren(SetProps(MakeElement("RoundFrame", White, 0, 10), {
					Size = UDim2.new(1, 0, 0, 34),
					BackgroundTransparency = 0,
					Parent = ItemParent
				}), {
					Create("UIGradient", {
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, GFrom:Lerp(Accent, 0.45)),
							ColorSequenceKeypoint.new(1, GTo:Lerp(Accent, 0.12))
						}),
						Rotation = GRot
					}),
					SetChildren(MakeElement("Stroke", White, 1), {
						Create("UIGradient", {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Accent:Lerp(White, 0.2)),
								ColorSequenceKeypoint.new(1, Accent:Lerp(Main, 0.6))
							}),
							Rotation = 10
						})
					}),
					MakeElement("Padding", 7, 12, 10, 7),
					SetProps(MakeElement("Image", Config.Icon or DefaultIcon, Config.Icon and Config.ImageSource or DefaultSource), {
						Name = "Icon",
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 0, 0.5, 0),
						Size = UDim2.new(0, 18, 0, 18),
						ImageColor3 = Accent:Lerp(White, 0.5)
					}),
					SetProps(MakeElement("Label", Config.Text, 14), {
						Name = "Content",
						Position = UDim2.new(0, 28, 0, 0),
						Size = UDim2.new(1, -28, 0, 16),
						AutomaticSize = Enum.AutomaticSize.Y,
						FontFace = Fonts.Body,
						TextColor3 = White,
						TextWrapped = true
					})
				})
				SmartFit(LabelFrame, LabelFrame.Content, 14, 34, 14)
				-- follows theme changes too (the gradient is rebuilt from the active theme)
				table.insert(Lunarion.ThemeListeners, function()
					if not LabelFrame.Parent then
						return
					end
					local F, T, R = ThemeGradient()
					local Body = LabelFrame:FindFirstChildOfClass("UIGradient")
					local Rim = LabelFrame:FindFirstChildOfClass("UIStroke")
					if Body then
						Body.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, F:Lerp(Accent, 0.45)), ColorSequenceKeypoint.new(1, T:Lerp(Accent, 0.12))})
						Body.Rotation = R
					end
					Rim = Rim and Rim:FindFirstChildOfClass("UIGradient")
					if Rim then
						Rim.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Accent:Lerp(White, 0.2)), ColorSequenceKeypoint.new(1, Accent:Lerp(ThemeColor("Main"), 0.6))})
					end
				end)
				local LabelFunction = {}
				function LabelFunction:Set(ToChange)
					LabelFrame.Content.Text = tostring(ToChange)
				end
				return LabelFunction
			end
			local function LabelConfig(Arg, Color, Icon)
				if type(Arg) == "table" then
					return {Text = tostring(Arg.Text or Arg.Name or Arg.Content or "Label"), Color = Arg.Color, Icon = Arg.Icon, ImageSource = Arg.ImageSource}
				end
				return {Text = tostring(Arg or "Label"), Color = Color, Icon = Icon}
			end
			function ElementFunction:AddWarningLabel(Arg)
				return MakeColoredLabel(LabelConfig(Arg), Color3.fromRGB(239, 68, 68), "triangle-alert")
			end
			function ElementFunction:AddApproveLabel(Arg)
				return MakeColoredLabel(LabelConfig(Arg), Color3.fromRGB(34, 197, 94), "circle-check")
			end
			function ElementFunction:AddCustomLabel(Arg, Color, Icon)
				return MakeColoredLabel(LabelConfig(Arg, Color, Icon), Color3.fromRGB(168, 85, 247), "sparkles")
			end
			function ElementFunction:AddParagraph(Text, Content)
				Text = Text or "Text"
				Content = Content or "Content"

				-- smart paragraph: title and body both wrap, the card grows/shrinks with whatever text you give it
				local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
					Size = UDim2.new(1, 0, 0, 30),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					MakeElement("Padding", 10, 12, 12, 10),
					Create("UISizeConstraint", {MinSize = Vector2.new(0, 30)}),
					Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)}),
					AddThemeObject(SetProps(MakeElement("Label", Text, 14), {
						Size = UDim2.new(1, 0, 0, 15),
						AutomaticSize = Enum.AutomaticSize.Y,
						LayoutOrder = 1,
						FontFace = Fonts.Title,
						TextWrapped = true,
						Name = "Title"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Label", "", 13), {
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						LayoutOrder = 2,
						FontFace = Fonts.Body,
						Name = "Content",
						TextWrapped = true
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")

				local function SyncParagraph()
					ParagraphFrame.Content.Visible = ParagraphFrame.Content.Text ~= ""
					ParagraphFrame.Title.Visible = ParagraphFrame.Title.Text ~= ""
				end
				AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), SyncParagraph)

				ParagraphFrame.Content.Text = Content
				SyncParagraph()

				local ParagraphFunction = {}
				function ParagraphFunction:Set(ToChange)
					ParagraphFrame.Content.Text = ToChange
				end
				function ParagraphFunction:SetTitle(ToChange)
					ParagraphFrame.Title.Text = ToChange
					SyncParagraph()
				end
				return ParagraphFunction
			end    
			function ElementFunction:AddButton(ButtonConfig)
				ButtonConfig = ButtonConfig or {}
				ButtonConfig.Name = ButtonConfig.Name or "Button"
				ButtonConfig.Callback = ButtonConfig.Callback or function() end
				ButtonConfig.Icon = ButtonConfig.Icon or "mouse-pointer-click"

				local Button = {}

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 3
				})

				local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
					Size = UDim2.new(1, 0, 0, 36),
					ClipsDescendants = true,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 15), {
						Size = UDim2.new(1, -48, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						FontFace = Fonts.Body,
						Name = "Content"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Image", ButtonConfig.Icon, ButtonConfig.ImageSource), {
						Size = UDim2.new(0, 18, 0, 18),
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(1, -12, 0.5, 0),
						Name = "Ico"
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					Click
				}), "Second")

				local ButtonStroke = ButtonFrame:FindFirstChildOfClass("UIStroke")
				local ButtonScale = Create("UIScale", {Scale = 1, Parent = ButtonFrame})

				-- soft "liquid" ripple that spreads out from where the button was pressed
				local function Ripple(X)
					local Wave = Create("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0, X - ButtonFrame.AbsolutePosition.X, 0.5, 0),
						Size = UDim2.new(0, 0, 0, 0),
						BackgroundColor3 = ThemeColor("Accent"),
						BackgroundTransparency = 0.72,
						BorderSizePixel = 0,
						ZIndex = 0,
						Parent = ButtonFrame
					}, {
						Create("UICorner", {CornerRadius = UDim.new(1, 0)})
					})
					local Diameter = ButtonFrame.AbsoluteSize.X * 2.2
					Tw(Wave, 0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
						Size = UDim2.new(0, Diameter, 0, Diameter),
						BackgroundTransparency = 1
					})
					task.delay(0.65, function()
						Wave:Destroy()
					end)
				end

				AddConnection(Click.MouseEnter, function()
					Tw(ButtonFrame, 0.25, nil, nil, {BackgroundColor3 = Shift(ThemeColor("Second"), 6)})
					Tw(ButtonStroke, 0.25, nil, nil, {Color = Shift(ThemeColor("Stroke"), 30)})
				end)

				AddConnection(Click.MouseLeave, function()
					Tw(ButtonFrame, 0.25, nil, nil, {BackgroundColor3 = ThemeColor("Second")})
					Tw(ButtonStroke, 0.25, nil, nil, {Color = ThemeColor("Stroke")})
					Tw(ButtonScale, 0.25, nil, nil, {Scale = 1})
				end)

				AddConnection(Click.MouseButton1Down, function(X)
					Tw(ButtonFrame, 0.12, nil, nil, {BackgroundColor3 = Shift(ThemeColor("Second"), 12)})
					Tw(ButtonScale, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Scale = 0.985})
					Ripple(X)
				end)

				AddConnection(Click.MouseButton1Up, function()
					Tw(ButtonFrame, 0.25, nil, nil, {BackgroundColor3 = Shift(ThemeColor("Second"), 6)})
					Tw(ButtonScale, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Scale = 1})
				end)

				AddConnection(Click.MouseButton1Click, function()
					task.spawn(RunCallback, ButtonFrame, ButtonConfig.Callback)
				end)

				function Button:Set(ButtonText)
					ButtonFrame.Content.Text = ButtonText
				end

				return Button
			end
			function ElementFunction:AddToggle(ToggleConfig)
				ToggleConfig = ToggleConfig or {}
				ToggleConfig.Name = ToggleConfig.Name or "Toggle"
				ToggleConfig.Default = ToggleConfig.Default or false
				ToggleConfig.Callback = ToggleConfig.Callback or function() end
				ToggleConfig.Flag = ToggleConfig.Flag or nil
				if ToggleConfig.Save == nil then ToggleConfig.Save = ToggleConfig.Flag ~= nil end
				-- ToggleConfig.Color is optional: when it is left out the toggle follows the theme's Accent color

				local Toggle = {Value = ToggleConfig.Default, Save = ToggleConfig.Save, Type = "Toggle"}

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 3
				})

				local KnobOff, KnobOn, KnobStretch, KnobSize = 4, 26, 24, 14
				local KnobToken = 0
				local Knob = Create("Frame", {
					Name = "Knob",
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, KnobOff, 0.5, 0),
					Size = UDim2.new(0, KnobSize, 0, KnobSize),
					BackgroundColor3 = ThemeColor("TextDark"),
					BorderSizePixel = 0
				}, {
					Create("UICorner", {CornerRadius = UDim.new(1, 0)})
				})

				local TrackStroke = Create("UIStroke", {
					Name = "TrackStroke",
					Thickness = 1.2,
					Color = ThemeColor("TextDark")
				})

				local Track = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 1, 0), {
					Name = "Track",
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -12, 0.5, 0),
					Size = UDim2.new(0, 44, 0, 22),
					BackgroundTransparency = 1
				}), {
					TrackStroke,
					Knob
				})

				local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 15), {
						Size = UDim2.new(1, -70, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						FontFace = Fonts.Body,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					Track,
					Click
				}), "Second")

				-- the knob stretches into a short pill while it slides, then settles back into a circle
				local function MoveKnob(On, Animate)
					KnobToken = KnobToken + 1
					local Token = KnobToken
					local Target = On and KnobOn or KnobOff
					if not Animate then
						Knob.Size = UDim2.new(0, KnobSize, 0, KnobSize)
						Knob.Position = UDim2.new(0, Target, 0.5, 0)
						return
					end
					local Left = Knob.Position.X.Offset
					-- phase 1: grow toward the destination (the leading edge moves, the trailing edge stays)
					local GrowLeft = On and Left or math.min(Left, KnobOn + KnobSize - KnobStretch)
					Tw(Knob, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
						Size = UDim2.new(0, KnobStretch, 0, KnobSize - 2),
						Position = UDim2.new(0, GrowLeft, 0.5, 0)
					})
					task.delay(0.12, function()
						if Token ~= KnobToken or not Knob.Parent then
							return
						end
						-- phase 2: slide and shrink back to a circle
						Tw(Knob, 0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
							Size = UDim2.new(0, KnobSize, 0, KnobSize),
							Position = UDim2.new(0, Target, 0.5, 0)
						})
					end)
				end

				local function Refresh(Animate, Moved)
					local On = Toggle.Value
					local Accent = ToggleConfig.Color or ThemeColor("Accent")
					local Off = ThemeColor("TextDark")
					local Time = Animate and 0.3 or 0
					Track.BackgroundColor3 = Accent -- flat fill, no gradient
					Tw(Track, Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {BackgroundTransparency = On and 0 or 1})
					Tw(TrackStroke, Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Color = On and Accent or Off})
					Tw(Knob, Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
						BackgroundColor3 = On and Color3.fromRGB(255, 255, 255) or Off
					})
					if Moved ~= false then
						MoveKnob(On, Animate)
					end
				end

				function Toggle:Set(Value)
					Toggle.Value = Value and true or false
					Refresh(true)
					RunCallback(ToggleFrame, ToggleConfig.Callback, Toggle.Value)
				end

				Refresh(false)
				Toggle:Set(Toggle.Value)
				table.insert(Lunarion.ThemeListeners, function()
					Refresh(true, false)
				end)

				AddConnection(Click.MouseEnter, function()
					Tw(ToggleFrame, 0.25, nil, nil, {BackgroundColor3 = Shift(ThemeColor("Second"), 6)})
				end)

				AddConnection(Click.MouseLeave, function()
					Tw(ToggleFrame, 0.25, nil, nil, {BackgroundColor3 = ThemeColor("Second")})
				end)

				AddConnection(Click.MouseButton1Down, function()
					Tw(ToggleFrame, 0.12, nil, nil, {BackgroundColor3 = Shift(ThemeColor("Second"), 12)})
				end)

				AddConnection(Click.MouseButton1Up, function()
					Tw(ToggleFrame, 0.25, nil, nil, {BackgroundColor3 = Shift(ThemeColor("Second"), 6)})
				end)

				AddConnection(Click.MouseButton1Click, function()
					Toggle:Set(not Toggle.Value)
					AutoSave()
				end)

				if ToggleConfig.Flag then
					Lunarion.Flags[ToggleConfig.Flag] = Toggle
					ApplySaved(ToggleConfig.Flag, Toggle)
				end
				return Toggle
			end
			function ElementFunction:AddSlider(SliderConfig)
				SliderConfig = SliderConfig or {}
				SliderConfig.Name = SliderConfig.Name or "Slider"
				SliderConfig.Min = SliderConfig.Min or 0
				SliderConfig.Max = SliderConfig.Max or 100
				SliderConfig.Increment = SliderConfig.Increment or 1
				SliderConfig.Default = SliderConfig.Default or 50
				SliderConfig.Callback = SliderConfig.Callback or function() end
				SliderConfig.ValueName = SliderConfig.ValueName or ""
				SliderConfig.Flag = SliderConfig.Flag or nil
				if SliderConfig.Save == nil then
					SliderConfig.Save = SliderConfig.Flag ~= nil
				end
				-- SliderConfig.Color is optional: leave it out and the fill follows the theme's Accent
			
				local Slider = {Value = SliderConfig.Default, Save = SliderConfig.Save, Type = "Slider"}
				local Range = math.max(SliderConfig.Max - SliderConfig.Min, 1e-9)
				local Dragging, ActiveInput, LastValue = false, nil, nil
				local Scroller = ItemParent:IsA("ScrollingFrame") and ItemParent or ItemParent:FindFirstAncestorWhichIsA("ScrollingFrame")
			
				local function FillColor()
					return SliderConfig.Color or ThemeColor("Accent")
				end
			
				local Fill = SetChildren(SetProps(MakeElement("RoundFrame", FillColor(), 1, 0), {
					Name = "Progress",
					Size = UDim2.new(0, 0, 1, 0)
				}), {
					Create("UISizeConstraint", {MinSize = Vector2.new(6, 0)})
				})
			
				local Track = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 1, 0), {
					Name = "Track",
					Size = UDim2.new(1, -24, 0, 6),
					Position = UDim2.new(0, 12, 0, 35)
				}), {
					Fill
				}), "Divider")
			
				local ValueLabel = AddThemeObject(SetProps(MakeElement("Label", "", 13), {
					Name = "Value",
					Size = UDim2.new(0, 110, 0, 14),
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, -12, 0, 10),
					FontFace = Fonts.Body,
					TextXAlignment = Enum.TextXAlignment.Right
				}), "TextDark")
			
				local Title = AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 15), {
					Name = "Content",
					Size = UDim2.new(1, -130, 0, 14),
					Position = UDim2.new(0, 12, 0, 10),
					FontFace = Fonts.Body
				}), "Text")
			
				-- the whole card is the touch target, not just the thin bar
				local Interact = SetProps(MakeElement("Button"), {
					Name = "Interact",
					Size = UDim2.new(1, 0, 1, 0)
				})
			
				local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(1, 0, 0, 52),
					Parent = ItemParent
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					Title,
					ValueLabel,
					Track,
					Interact
				}), "Second")
			
				table.insert(Lunarion.ThemeListeners, function()
					if SliderConfig.Color == nil then
						Tw(Fill, 0.35, nil, nil, {BackgroundColor3 = FillColor()})
					end
				end)
			
				local function Apply(Value, Force)
					local Snapped = SliderConfig.Min + math.floor((Value - SliderConfig.Min) / SliderConfig.Increment + 0.5) * SliderConfig.Increment
					Snapped = math.clamp(tonumber(string.format("%.6f", Snapped)), SliderConfig.Min, SliderConfig.Max)
					if not Force and Snapped == LastValue then
						return
					end
					LastValue = Snapped
					Slider.Value = Snapped
					Tw(Fill, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
						Size = UDim2.new((Snapped - SliderConfig.Min) / Range, 0, 1, 0)
					})
					ValueLabel.Text = tostring(Snapped) .. (SliderConfig.ValueName ~= "" and (" " .. SliderConfig.ValueName) or "")
					RunCallback(SliderFrame, SliderConfig.Callback, Snapped)
				end
			
				local function FromX(X)
					local Alpha = math.clamp((X - Track.AbsolutePosition.X) / math.max(Track.AbsoluteSize.X, 1), 0, 1)
					Apply(SliderConfig.Min + (SliderConfig.Max - SliderConfig.Min) * Alpha, false)
				end
			
				local function EndDrag()
					if not Dragging then
						return
					end
					Dragging, ActiveInput = false, nil
					if Scroller then
						Scroller.ScrollingEnabled = true
					end
					AutoSave()
				end
			
				AddConnection(Interact.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
						Dragging, ActiveInput = true, Input
						if Scroller then
							Scroller.ScrollingEnabled = false -- so dragging a slider on a phone does not scroll the tab
						end
						Input.Changed:Connect(function()
							if Input.UserInputState == Enum.UserInputState.End and ActiveInput == Input then
								EndDrag()
							end
						end)
						FromX(Input.Position.X)
					end
				end)
			
				AddConnection(UserInputService.InputChanged, function(Input)
					if Dragging and (Input == ActiveInput or Input.UserInputType == Enum.UserInputType.MouseMovement) then
						FromX(Input.Position.X)
					end
				end)
			
				AddConnection(UserInputService.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input == ActiveInput then
						EndDrag()
					end
				end)
			
				AddConnection(Interact.MouseEnter, function()
					Tw(SliderFrame, 0.25, nil, nil, {BackgroundColor3 = Shift(ThemeColor("Second"), 6)})
				end)
			
				AddConnection(Interact.MouseLeave, function()
					Tw(SliderFrame, 0.25, nil, nil, {BackgroundColor3 = ThemeColor("Second")})
				end)
			
				function Slider:Set(Value)
					Apply(Value, true)
				end
			
				Apply(Slider.Value, true)
				if SliderConfig.Flag then
					Lunarion.Flags[SliderConfig.Flag] = Slider
					ApplySaved(SliderConfig.Flag, Slider)
				end
				return Slider
			end  
			-- DROPDOWN (v2) ---------------------------------------------------------------------------------------
			-- Inline card that grows open. Options: Name, Options, Default, Callback(value), Flag, Save,
			-- Multi (pick several, value is a table), Search (true/false, defaults to on for 7+ options),
			-- Placeholder (text while nothing is picked), MaxRows (visible rows before it scrolls, default 6),
			-- CloseOnSelect (single mode closes after a pick, default true).
			-- API: :Set(value) :Get() :Refresh(options, clear) :Open() :Close() :Toggle() ; .Value holds the selection.
			function ElementFunction:AddDropdown(DropdownConfig)
				if type(DropdownConfig) == "string" then
					DropdownConfig = {Name = DropdownConfig}
				end
				DropdownConfig = DropdownConfig or {}
				DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
				DropdownConfig.Callback = DropdownConfig.Callback or function() end
				DropdownConfig.Placeholder = DropdownConfig.Placeholder or "Select..."
				if DropdownConfig.Save == nil then DropdownConfig.Save = DropdownConfig.Flag ~= nil end
				if DropdownConfig.CloseOnSelect == nil then DropdownConfig.CloseOnSelect = true end

				local Multi = DropdownConfig.Multi == true
				local HeaderH, RowH, RowGap = 38, 28, 2
				local MaxRows = math.max(1, DropdownConfig.MaxRows or 6)
				local Dropdown = {Options = {}, Buttons = {}, Toggled = false, Type = "Dropdown", Save = DropdownConfig.Save, Multi = Multi}
				local Picked = {}
				local Query = ""
				local HasSearch = false
				local Rows = {}
				local Token = 0

				local function Lower(Text) return string.lower(tostring(Text)) end
				local function Clean(Option) return tostring(Option) end

				-- selection helpers -------------------------------------------------------------------------
				local function BuildValue()
					if Multi then
						local Out = {}
						for _, Option in ipairs(Dropdown.Options) do
							if Picked[Option] then table.insert(Out, Option) end
						end
						Dropdown.Value = Out
					else
						Dropdown.Value = Dropdown.Value or "..."
					end
				end
				local function ValueText()
					if Multi then
						local List = Dropdown.Value
						if #List == 0 then return DropdownConfig.Placeholder end
						if #List <= 2 then return table.concat(List, ", ") end
						return #List .. " selected"
					end
					if Dropdown.Value == "..." or Dropdown.Value == nil then return DropdownConfig.Placeholder end
					return tostring(Dropdown.Value)
				end

				-- header ------------------------------------------------------------------------------------
				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0), ZIndex = 3})
				local Chevron = AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
					Size = UDim2.new(0, 18, 0, 18),
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -10, 0.5, 0),
					Name = "Ico"
				}), "TextDark")
				local Title = AddThemeObject(SetProps(MakeElement("Label", DropdownConfig.Name, 15), {
					Size = UDim2.new(0.5, -12, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					FontFace = Fonts.Body,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Name = "Content"
				}), "Text")
				local ValueLabel = AddThemeObject(SetProps(MakeElement("Label", "", 13), {
					Size = UDim2.new(0.5, -40, 1, 0),
					Position = UDim2.new(0.5, 0, 0, 0),
					FontFace = Fonts.Body,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Name = "Selected"
				}), "TextDark")
				local Divider = AddThemeObject(SetProps(MakeElement("Frame"), {
					Size = UDim2.new(1, -16, 0, 1),
					Position = UDim2.new(0, 8, 1, -1),
					BackgroundTransparency = 1,
					Name = "Line"
				}), "Stroke")
				local Header = SetProps(SetChildren(MakeElement("TFrame"), {Title, ValueLabel, Chevron, Divider, Click}), {
					Size = UDim2.new(1, 0, 0, HeaderH),
					Name = "F"
				})

				-- body: optional search + scrolling list ---------------------------------------------------------
				local SearchBox = AddThemeObject(Create("TextBox", {
					Name = "Search",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -20, 1, 0),
					Position = UDim2.new(0, 10, 0, 0),
					Text = "",
					PlaceholderText = "Search...",
					PlaceholderColor3 = ThemeColor("TextDark"),
					FontFace = Fonts.Body,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					ClearTextOnFocus = false
				}), "Text")
				local SearchFrame = AddThemeObject(Create("Frame", {
					Name = "SearchField",
					Position = UDim2.new(0, 8, 0, HeaderH + 6),
					Size = UDim2.new(1, -16, 0, 26),
					BorderSizePixel = 0,
					Visible = false
				}, {
					Create("UICorner", {CornerRadius = UDim.new(0, 7)}),
					SearchBox
				}), "Main")

				local ListLayout = Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, RowGap)})
				local List = Create("ScrollingFrame", {
					Name = "List",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 8, 0, HeaderH + 6),
					Size = UDim2.new(1, -16, 0, 0),
					CanvasSize = UDim2.new(0, 0, 0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ScrollBarThickness = 2,
					ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150),
					ScrollBarImageTransparency = 0.4,
					ScrollingDirection = Enum.ScrollingDirection.Y
				}, {ListLayout})
				local Empty = AddThemeObject(Create("TextLabel", {
					Name = "Empty",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, RowH),
					Text = "Nothing found",
					FontFace = Fonts.Body,
					TextSize = 13,
					Visible = false,
					LayoutOrder = 1e6
				}), "TextDark")
				Empty.Parent = List

				local DropdownFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
					Size = UDim2.new(1, 0, 0, HeaderH),
					Parent = ItemParent,
					ClipsDescendants = true
				}), {
					Header,
					SearchFrame,
					List,
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					MakeElement("Corner")
				}), "Second")

				-- sizing ------------------------------------------------------------------------------------
				local function VisibleCount()
					local Count = 0
					for _, Row in ipairs(Rows) do
						if Row.Button.Visible then Count = Count + 1 end
					end
					return Count
				end
				local function ListHeight()
					local Count = math.max(VisibleCount(), 1)
					local Shown = math.min(Count, MaxRows)
					return Shown * RowH + (Shown - 1) * RowGap
				end
				local function Layout(Animate)
					local ListY = HeaderH + 6 + (HasSearch and 32 or 0)
					SearchFrame.Visible = HasSearch
					List.Position = UDim2.new(0, 8, 0, ListY)
					local H = ListHeight()
					List.Size = UDim2.new(1, -16, 0, H)
					Empty.Visible = VisibleCount() == 0
					if Dropdown.Toggled then
						local Goal = UDim2.new(1, 0, 0, ListY + H + 8)
						if Animate then
							Tw(DropdownFrame, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = Goal})
						else
							DropdownFrame.Size = Goal
						end
					end
				end

				-- rows ------------------------------------------------------------------------------------------
				local function PaintRow(Row, Animate)
					local On = Picked[Row.Option] == true
					local Time = Animate and 0.18 or 0
					Tw(Row.Button, Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
						BackgroundTransparency = On and 0.55 or 1,
						BackgroundColor3 = ThemeColor("Stroke")
					})
					Tw(Row.Title, Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
						TextTransparency = On and 0 or 0.35,
						TextColor3 = ThemeColor("Text")
					})
					Tw(Row.Bar, Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
						BackgroundTransparency = On and 0 or 1,
						Size = UDim2.new(0, 3, 0, On and 14 or 4),
						BackgroundColor3 = ThemeColor("Accent")
					})
					if Row.Box then
						Tw(Row.Box, Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundColor3 = On and ThemeColor("Accent") or ThemeColor("Main")})
						Tw(Row.BoxStroke, Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Color = On and ThemeColor("Accent") or ThemeColor("TextDark")})
						Tw(Row.Dot, Time, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Size = On and UDim2.new(0, 6, 0, 6) or UDim2.new(0, 0, 0, 0)})
					end
				end
				local function PaintAll(Animate)
					for _, Row in ipairs(Rows) do PaintRow(Row, Animate) end
					ValueLabel.Text = ValueText()
				end

				local function Choose(Option)
					if Multi then
						Picked[Option] = not Picked[Option] or nil
						BuildValue()
						PaintAll(true)
						RunCallback(DropdownFrame, DropdownConfig.Callback, Dropdown.Value)
					else
						Picked = {[Option] = true}
						Dropdown.Value = Option
						PaintAll(true)
						RunCallback(DropdownFrame, DropdownConfig.Callback, Dropdown.Value)
						if DropdownConfig.CloseOnSelect then
							Dropdown:Close()
						end
					end
					AutoSave()
				end

				local function MakeRow(Option, Index)
					local Title = AddThemeObject(Create("TextLabel", {
						Name = "Title",
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 14, 0, 0),
						Size = UDim2.new(1, Multi and -44 or -22, 1, 0),
						Text = Clean(Option),
						FontFace = Fonts.Body,
						TextSize = 13,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextTransparency = 0.35
					}), "Text")
					local Bar = Create("Frame", {
						Name = "Bar",
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 3, 0.5, 0),
						Size = UDim2.new(0, 3, 0, 4),
						BackgroundColor3 = ThemeColor("Accent"),
						BackgroundTransparency = 1,
						BorderSizePixel = 0
					}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
					local Button = Create("TextButton", {
						Name = "Option",
						Size = UDim2.new(1, 0, 0, RowH),
						BackgroundColor3 = ThemeColor("Stroke"),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						AutoButtonColor = false,
						Text = "",
						LayoutOrder = Index,
						Parent = List
					}, {Create("UICorner", {CornerRadius = UDim.new(0, 7)}), Bar, Title})
					local Row = {Option = Option, Button = Button, Title = Title, Bar = Bar}
					if Multi then
						local Dot = Create("Frame", {
							AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
							Size = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0
						}, {Create("UICorner", {CornerRadius = UDim.new(0, 2)})})
						local BoxStroke = Create("UIStroke", {Thickness = 1.2, Color = ThemeColor("TextDark")})
						local Box = Create("Frame", {
							Name = "Box", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
							Size = UDim2.new(0, 14, 0, 14), BackgroundColor3 = ThemeColor("Main"), BorderSizePixel = 0, Parent = Button
						}, {Create("UICorner", {CornerRadius = UDim.new(0, 4)}), BoxStroke, Dot})
						Row.Box, Row.BoxStroke, Row.Dot = Box, BoxStroke, Dot
					end
					AddConnection(Button.MouseEnter, function()
						if not Picked[Option] then Tw(Button, 0.15, nil, nil, {BackgroundTransparency = 0.8}) end
					end)
					AddConnection(Button.MouseLeave, function()
						if not Picked[Option] then Tw(Button, 0.2, nil, nil, {BackgroundTransparency = 1}) end
					end)
					AddConnection(Button.MouseButton1Click, function() Choose(Option) end)
					Dropdown.Buttons[Option] = Button
					return Row
				end

				local function Rebuild()
					for _, Row in ipairs(Rows) do Row.Button:Destroy() end
					table.clear(Rows)
					table.clear(Dropdown.Buttons)
					for Index, Option in ipairs(Dropdown.Options) do
						table.insert(Rows, MakeRow(Option, Index))
					end
					if DropdownConfig.Search ~= nil then
						HasSearch = DropdownConfig.Search
					else
						HasSearch = #Dropdown.Options >= 7
					end
					PaintAll(false)
					Layout(false)
				end

				local function ApplyFilter()
					Query = Lower(SearchBox.Text)
					for _, Row in ipairs(Rows) do
						Row.Button.Visible = Query == "" or string.find(Lower(Row.Option), Query, 1, true) ~= nil
					end
					List.CanvasPosition = Vector2.new(0, 0)
					Layout(true)
				end
				AddConnection(SearchBox:GetPropertyChangedSignal("Text"), ApplyFilter)

				-- public API --------------------------------------------------------------------------------------
				function Dropdown:Open()
					if Dropdown.Toggled then return end
					Dropdown.Toggled = true
					Divider.BackgroundTransparency = 0.4
					Tw(Chevron, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {Rotation = 180})
					Layout(true)
					if HasSearch then
						task.delay(0.3, function()
							if Dropdown.Toggled and SearchBox.Parent and not UserInputService.TouchEnabled then SearchBox:CaptureFocus() end
						end)
					end
				end
				function Dropdown:Close()
					if not Dropdown.Toggled then return end
					Dropdown.Toggled = false
					SearchBox:ReleaseFocus()
					Tw(Chevron, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Rotation = 0})
					Tw(Divider, 0.2, nil, nil, {BackgroundTransparency = 1})
					Tw(DropdownFrame, 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = UDim2.new(1, 0, 0, HeaderH)})
					task.delay(0.3, function()
						if not Dropdown.Toggled and SearchBox.Text ~= "" then SearchBox.Text = "" end
					end)
				end
				function Dropdown:Toggle()
					if Dropdown.Toggled then Dropdown:Close() else Dropdown:Open() end
				end
				function Dropdown:Get()
					return Dropdown.Value
				end
				function Dropdown:Set(Value)
					if Multi then
						local Wanted = {}
						if type(Value) == "table" then
							for _, Option in ipairs(Value) do Wanted[Option] = true end
						elseif Value ~= nil then
							Wanted[Value] = true
						end
						Picked = {}
						for _, Option in ipairs(Dropdown.Options) do
							if Wanted[Option] then Picked[Option] = true end
						end
						BuildValue()
						PaintAll(true)
						return RunCallback(DropdownFrame, DropdownConfig.Callback, Dropdown.Value)
					end
					if not table.find(Dropdown.Options, Value) then
						Dropdown.Value = "..."
						Picked = {}
						PaintAll(true)
						return
					end
					Picked = {[Value] = true}
					Dropdown.Value = Value
					PaintAll(true)
					return RunCallback(DropdownFrame, DropdownConfig.Callback, Dropdown.Value)
				end
				function Dropdown:Refresh(Options, Delete)
					Options = Options or Dropdown.Options
					if Delete == false then
						-- keep what exists, add anything new
						local Merged = table.clone(Dropdown.Options)
						for _, Option in ipairs(Options) do
							if not table.find(Merged, Option) then table.insert(Merged, Option) end
						end
						Options = Merged
					end
					Dropdown.Options = table.clone(Options)
					for Option in pairs(Picked) do
						if not table.find(Dropdown.Options, Option) then Picked[Option] = nil end
					end
					if not Multi and Dropdown.Value ~= "..." and not table.find(Dropdown.Options, Dropdown.Value) then
						Dropdown.Value = "..."
					end
					BuildValue()
					Rebuild()
					ApplyFilter()
				end

				AddConnection(Click.MouseButton1Click, function() Dropdown:Toggle() end)
				AddConnection(Click.MouseEnter, function()
					Tw(DropdownFrame, 0.25, nil, nil, {BackgroundColor3 = Shift(ThemeColor("Second"), 6)})
				end)
				AddConnection(Click.MouseLeave, function()
					Tw(DropdownFrame, 0.25, nil, nil, {BackgroundColor3 = ThemeColor("Second")})
				end)
				table.insert(Lunarion.ThemeListeners, function()
					if DropdownFrame.Parent then PaintAll(true) end
				end)

				-- initial state
				Dropdown.Options = table.clone(DropdownConfig.Options or {})
				if Multi then
					local Start = DropdownConfig.Default
					if type(Start) ~= "table" then Start = Start and {Start} or {} end
					for _, Option in ipairs(Start) do
						if table.find(Dropdown.Options, Option) then Picked[Option] = true end
					end
				elseif DropdownConfig.Default and table.find(Dropdown.Options, DropdownConfig.Default) then
					Dropdown.Value = DropdownConfig.Default
					Picked[Dropdown.Value] = true
				else
					Dropdown.Value = "..."
				end
				BuildValue()
				Rebuild()
				if Multi then
					RunCallback(DropdownFrame, DropdownConfig.Callback, Dropdown.Value)
				elseif Dropdown.Value ~= "..." then
					RunCallback(DropdownFrame, DropdownConfig.Callback, Dropdown.Value)
				end

				if DropdownConfig.Flag then
					Lunarion.Flags[DropdownConfig.Flag] = Dropdown
					ApplySaved(DropdownConfig.Flag, Dropdown)
				end
				return Dropdown
			end
			-- INPUT ---------------------------------------------------------------------------------------------
			-- A small recessed field on the right of the card. It rests as a compact chip and GROWS as you type
			-- (the label makes room by truncating), then settles back when it is emptied or loses focus.
			-- Focusing draws a soft accent ring and an underline that grows out from the middle; committing flashes it.
			-- Options: Name, Description, Default, Placeholder, Callback(text), Live (callback while typing),
			-- Numeric (also accepts simple maths like 2*8), Min, Max, MaxLength, ClearOnFinish (old: TextDisappear),
			-- Trim (default true), Flag, Save.
			function ElementFunction:AddInput(InputConfig)
				if type(InputConfig) == "string" then
					InputConfig = {Name = InputConfig}
				end
				InputConfig = InputConfig or {}
				InputConfig.Name = InputConfig.Name or "Input"
				InputConfig.Placeholder = InputConfig.Placeholder or InputConfig.PlaceholderText or "Type..."
				InputConfig.Callback = InputConfig.Callback or function() end
				if InputConfig.ClearOnFinish == nil then
					InputConfig.ClearOnFinish = InputConfig.TextDisappear or false
				end
				if InputConfig.Trim == nil then InputConfig.Trim = true end
				if InputConfig.Save == nil then InputConfig.Save = InputConfig.Flag ~= nil end
				local Default = InputConfig.Default ~= nil and tostring(InputConfig.Default) or ""
				local HasDescription = type(InputConfig.Description) == "string" and InputConfig.Description ~= ""
				local White = Color3.fromRGB(255, 255, 255)
				local FieldH = 24
				local RestW = 72 -- compact chip width

				local Input = {Value = Default, Save = InputConfig.Save, Type = "Input"}
				if InputConfig.Numeric then
					Input.Value = tonumber(Default) or 0
				end

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 2
				})

				local FieldStroke = Create("UIStroke", {
					Color = ThemeColor("Accent"),
					Thickness = 1,
					Transparency = 1,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				})
				local Underline = Create("Frame", {
					Name = "Underline",
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.new(0.5, 0, 1, -1),
					Size = UDim2.new(0, 0, 0, 2),
					BackgroundColor3 = ThemeColor("Accent"),
					BorderSizePixel = 0,
					ZIndex = 6
				}, {
					Create("UICorner", {CornerRadius = UDim.new(1, 0)})
				})
				local Box = Create("TextBox", {
					Name = "Box",
					Size = UDim2.new(1, -16, 1, 0),
					Position = UDim2.new(0, 8, 0, 0),
					BackgroundTransparency = 1,
					Text = Default,
					PlaceholderText = InputConfig.Placeholder,
					PlaceholderColor3 = ThemeColor("TextDark"),
					TextColor3 = ThemeColor("Text"),
					FontFace = Fonts.Body,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					ClearTextOnFocus = false,
					ClipsDescendants = true,
					ZIndex = 5
				})
				local Field = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", White, 0, 8), {
					Name = "Field",
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -10, 0.5, 0),
					Size = UDim2.new(0, RestW, 0, FieldH),
					ClipsDescendants = true,
					ZIndex = 4
				}), {
					FieldStroke,
					Box,
					Underline
				}), "Main")

				local Children = {
					AddThemeObject(SetProps(MakeElement("Label", InputConfig.Name, 15), {
						Size = UDim2.new(1, -(RestW + 34), 0, HasDescription and 18 or 38),
						Position = UDim2.new(0, 12, 0, HasDescription and 7 or 0),
						FontFace = Fonts.Body,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextYAlignment = Enum.TextYAlignment.Center,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					Field,
					Click
				}
				if HasDescription then
					table.insert(Children, AddThemeObject(SetProps(MakeElement("Label", InputConfig.Description, 11), {
						Size = UDim2.new(1, -(RestW + 34), 0, 14),
						Position = UDim2.new(0, 12, 0, 26),
						FontFace = Fonts.Thin,
						TextTruncate = Enum.TextTruncate.AtEnd,
						Name = "Description"
					}), "TextDark"))
				end

				local InputFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", White, 0, 10), {
					Size = UDim2.new(1, 0, 0, HasDescription and 50 or 38),
					Parent = ItemParent
				}), Children), "Second")

				local Focused = false
				local CurrentW = RestW

				-- how wide the chip should be: as wide as its text (or placeholder), never wider than the room the label leaves
				local function TargetWidth()
					local Text = Box.Text
					local Sample = Text ~= "" and Text or (Focused and "" or InputConfig.Placeholder)
					local Wide = math.ceil(MeasureText(Sample == "" and "MMMMMM" or Sample, 12, Fonts.Body, Vector2.new(1000, 100)).X) + 24
					local Floor = Focused and 104 or RestW
					if Text == "" and not Focused then Floor = RestW end
					local Room = math.max(Floor, InputFrame.AbsoluteSize.X - 12 - 90 - 10)
					if Text == "" then
						return math.clamp(Floor, RestW, Room)
					end
					return math.clamp(Wide, Floor, Room)
				end

				local function Fit(Animate)
					local Width = TargetWidth()
					if Width == CurrentW and Animate ~= "force" then return end
					CurrentW = Width
					local Time = Animate and 0.28 or 0
					Tw(Field, Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = UDim2.new(0, Width, 0, FieldH)})
					local Shrink = UDim2.new(1, -(Width + 34), 0, HasDescription and 18 or 38)
					Tw(InputFrame.Content, Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = Shrink})
					local Desc = InputFrame:FindFirstChild("Description")
					if Desc then
						Tw(Desc, Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = UDim2.new(1, -(Width + 34), 0, 14)})
					end
				end

				AddConnection(Click.MouseEnter, function()
					Tw(InputFrame, 0.25, nil, nil, {BackgroundColor3 = Shift(ThemeColor("Second"), 5)})
				end)
				AddConnection(Click.MouseLeave, function()
					Tw(InputFrame, 0.25, nil, nil, {BackgroundColor3 = ThemeColor("Second")})
				end)
				AddConnection(Click.MouseButton1Click, function()
					Box:CaptureFocus()
				end)

				AddConnection(Box.Focused, function()
					Focused = true
					Tw(FieldStroke, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Transparency = 0.55, Color = ThemeColor("Accent")})
					Tw(Underline, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = UDim2.new(1, -16, 0, 2), BackgroundColor3 = ThemeColor("Accent")})
					Tw(Field, 0.25, nil, nil, {BackgroundColor3 = Shift(ThemeColor("Main"), 8)})
					Fit(true)
				end)

				-- tiny safe calculator for Numeric fields ("2*8", "(3+4)/2"); anything else is rejected
				local function Evaluate(Text)
					local Plain = tonumber(Text)
					if Plain then return Plain end
					if not string.match(Text, "^[%d%.%+%-%*/%%%^%(%)%s]+$") then return nil end
					local Chunk = loadstring and loadstring("return " .. Text)
					if not Chunk then return nil end
					local Ok, Result = pcall(Chunk)
					if Ok and type(Result) == "number" and Result == Result and math.abs(Result) ~= math.huge then
						return Result
					end
					return nil
				end

				local function Push(Text, Silent)
					local Value = Text
					if InputConfig.Trim and not InputConfig.Numeric then
						Value = string.gsub(Value, "^%s+", "")
						Value = string.gsub(Value, "%s+$", "")
					end
					if InputConfig.Numeric then
						Value = Evaluate(Text)
						if Value == nil then
							Value = Input.Value
						end
						if InputConfig.Min then Value = math.max(InputConfig.Min, Value) end
						if InputConfig.Max then Value = math.min(InputConfig.Max, Value) end
					end
					Input.Value = Value
					if not Silent then
						RunCallback(InputFrame, InputConfig.Callback, Value)
					end
					return Value
				end

				AddConnection(Box:GetPropertyChangedSignal("Text"), function()
					local Text = Box.Text
					if InputConfig.Numeric then
						local Filtered = string.gsub(Text, "[^%d%.%-%+%*/%%%^%(%)%s]", "")
						if Filtered ~= Text then
							Box.Text = Filtered
							return
						end
					end
					if InputConfig.MaxLength and #Text > InputConfig.MaxLength then
						Box.Text = string.sub(Text, 1, InputConfig.MaxLength)
						return
					end
					Fit(true) -- the chip grows / shrinks with every character
					if InputConfig.Live and Focused then
						Push(Text)
					end
				end)

				AddConnection(Box.FocusLost, function()
					Focused = false
					Tw(FieldStroke, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Transparency = 1})
					Tw(Field, 0.3, nil, nil, {BackgroundColor3 = ThemeColor("Main")})
					local Value = Push(Box.Text)
					if InputConfig.Numeric then
						Box.Text = tostring(Value)
					elseif InputConfig.Trim then
						Box.Text = tostring(Value)
					end
					AutoSave()
					Underline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					Tw(Underline, 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In, {Size = UDim2.new(0, 0, 0, 2)})
					if InputConfig.ClearOnFinish then
						Box.Text = ""
					end
					Fit(true)
				end)

				function Input:Set(Text, Silent)
					Text = Text == nil and "" or tostring(Text)
					if InputConfig.MaxLength then
						Text = string.sub(Text, 1, InputConfig.MaxLength)
					end
					Box.Text = Text
					local Value = Push(Text, Silent)
					if InputConfig.Numeric then
						Box.Text = tostring(Value)
					end
					Fit(true)
				end
				function Input:Get()
					return Input.Value
				end
				function Input:SetPlaceholder(Text)
					Box.PlaceholderText = tostring(Text)
				end
				function Input:SetName(Text)
					InputFrame.Content.Text = tostring(Text)
				end
				function Input:Focus()
					Box:CaptureFocus()
				end

				-- first fit once the card has a real width; re-fit whenever the window is resized
				task.defer(function()
					if InputFrame.Parent then Fit("force") end
				end)
				AddConnection(InputFrame:GetPropertyChangedSignal("AbsoluteSize"), function()
					Fit(false)
				end)

				table.insert(Lunarion.ThemeListeners, function()
					if Box.Parent then
						Box.PlaceholderColor3 = ThemeColor("TextDark")
						FieldStroke.Color = ThemeColor("Accent")
						if not Focused then Underline.BackgroundColor3 = ThemeColor("Accent") end
					end
				end)

				if InputConfig.Flag then
					Lunarion.Flags[InputConfig.Flag] = Input
					ApplySaved(InputConfig.Flag, Input)
				end
				return Input
			end

			-- BIND ----------------------------------------------------------------------------------------------
			-- A keycap on the right of the card. Click to listen (the cap glows and pulses), press any key or mouse
			-- button to bind it, Esc cancels, Backspace / Delete clears. Options: Name, Default, Hold (or
			-- Mode = "Hold"), Callback, OnChange(keyName), AllowMouse (default true), Flag, Save.
			function ElementFunction:AddBind(BindConfig)
				if type(BindConfig) == "string" then
					BindConfig = {Name = BindConfig}
				end
				BindConfig = BindConfig or {}
				BindConfig.Name = BindConfig.Name or "Bind"
				BindConfig.Default = BindConfig.Default or Enum.KeyCode.Unknown
				if BindConfig.Hold == nil then BindConfig.Hold = BindConfig.Mode == "Hold" end
				BindConfig.Callback = BindConfig.Callback or function() end
				if BindConfig.Save == nil then BindConfig.Save = BindConfig.Flag ~= nil end
				local White = Color3.fromRGB(255, 255, 255)

				local Bind = {Value = "None", Binding = false, Type = "Bind", Save = BindConfig.Save}
				local Others = WindowBinds
				table.insert(Others, {Bind = Bind, Name = BindConfig.Name})
				local Holding = false
				local ListenToken = 0

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 2
				})

				local CapStroke = Create("UIStroke", {
					Color = ThemeColor("Accent"),
					Thickness = 1.2,
					Transparency = 1,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				})
				local Lip = Create("Frame", {
					Name = "Lip",
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.new(0.5, 0, 1, -1),
					Size = UDim2.new(1, -14, 0, 2),
					BackgroundColor3 = ThemeColor("Stroke"),
					BorderSizePixel = 0,
					ZIndex = 5
				}, {
					Create("UICorner", {CornerRadius = UDim.new(1, 0)})
				})
				local KeyLabel = Create("TextLabel", {
					Name = "Value",
					Size = UDim2.new(1, 0, 1, -2),
					BackgroundTransparency = 1,
					Text = "None",
					TextColor3 = ThemeColor("TextDark"),
					FontFace = Fonts.Body,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Center,
					ZIndex = 5
				})
				local Cap = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", White, 0, 8), {
					Name = "Cap",
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -10, 0.5, 0),
					Size = UDim2.new(0, 48, 0, 26),
					ClipsDescendants = true,
					ZIndex = 4
				}), {
					CapStroke,
					Lip,
					KeyLabel
				}), "Main")

				local BindFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", White, 0, 10), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 15), {
						Size = UDim2.new(1, -110, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						FontFace = Fonts.Body,
						TextTruncate = Enum.TextTruncate.AtEnd,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					Cap,
					Click
				}), "Second")

				local function Refresh(Animate)
					local Bound = Bind.Value ~= "None"
					local Text = Bind.Binding and "Press a key" or PrettyKey(Bind.Value)
					KeyLabel.Text = Text
					local Width = math.max(48, math.ceil(MeasureText(Text, 12, Fonts.Body, Vector2.new(1000, 100)).X) + 26)
					local Time = Animate and 0.3 or 0
					Tw(Cap, Time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {Size = UDim2.new(0, Width, 0, 26)})
					Tw(KeyLabel, Time, nil, nil, {TextColor3 = (Bound or Bind.Binding) and ThemeColor("Text") or ThemeColor("TextDark")})
					Tw(Lip, Time, nil, nil, {BackgroundColor3 = (Bound or Bind.Binding) and ThemeColor("Accent") or ThemeColor("Stroke")})
				end

				local function SetListening(On)
					On = On and true or false
					if Bind.Binding == On then return end
					Bind.Binding = On
					ListenToken = ListenToken + 1
					local Token = ListenToken
					Refresh(true)
					if On then
						CapStroke.Color = ThemeColor("Accent")
						Tw(CapStroke, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Transparency = 0.3})
						task.spawn(function()
							local Dim = true
							while Bind.Binding and Token == ListenToken and Cap.Parent do
								Tw(CapStroke, 0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, {Transparency = Dim and 0.8 or 0.25})
								Dim = not Dim
								task.wait(0.6)
							end
						end)
					else
						Tw(CapStroke, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Transparency = 1})
					end
				end

				function Bind:Set(Key, Silent)
					local Name = Bind.Value
					if typeof(Key) == "EnumItem" then
						Name = Key.Name
					elseif type(Key) == "string" and Key ~= "" then
						Name = Key
					end
					if Name == "Unknown" then Name = "None" end
					-- smart: warn when another bind in this window already uses the key
					if Name ~= "None" and not Silent then
						for _, Other in ipairs(WindowBinds) do
							if Other.Bind ~= Bind and Other.Bind.Value == Name then
								Lunarion:MakeNotification({
									Name = "Key already in use",
									Content = PrettyKey(Name) .. " is also the key for \"" .. tostring(Other.Name) .. "\".",
									Icon = "triangle-alert",
									ImageSource = "Lucide",
									Duration = 4
								})
								break
							end
						end
					end
					Bind.Value = Name
					local WasListening = Bind.Binding
					Bind.Binding = false
					ListenToken = ListenToken + 1
					if WasListening then
						Tw(CapStroke, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {Transparency = 1})
					end
					Refresh(true)
					if not Silent and type(BindConfig.OnChange) == "function" then
						task.spawn(BindConfig.OnChange, Bind.Value)
					end
				end
				function Bind:Get()
					return Bind.Value
				end
				function Bind:Clear()
					Bind:Set("None")
				end

				AddConnection(Click.MouseEnter, function()
					Tw(BindFrame, 0.25, nil, nil, {BackgroundColor3 = Shift(ThemeColor("Second"), 5)})
				end)
				AddConnection(Click.MouseLeave, function()
					Tw(BindFrame, 0.25, nil, nil, {BackgroundColor3 = ThemeColor("Second")})
				end)
				AddConnection(Click.MouseButton1Down, function()
					Tw(Cap, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundColor3 = Shift(ThemeColor("Main"), 8)})
				end)
				AddConnection(Click.MouseButton1Up, function()
					Tw(Cap, 0.25, nil, nil, {BackgroundColor3 = ThemeColor("Main")})
				end)
				AddConnection(Click.MouseButton1Click, function()
					SetListening(not Bind.Binding)
				end)

				AddConnection(UserInputService.InputBegan, function(Key, Processed)
					local IsMouse = CheckKey(WhitelistedMouse, Key.UserInputType)
					if Bind.Binding then
						local Name
						if Key.UserInputType == Enum.UserInputType.Keyboard then
							if Key.KeyCode == Enum.KeyCode.Escape then
								SetListening(false)
								return
							elseif Key.KeyCode == Enum.KeyCode.Backspace or Key.KeyCode == Enum.KeyCode.Delete then
								Bind:Set("None")
								AutoSave()
								return
							elseif not CheckKey(BlacklistedKeys, Key.KeyCode) then
								Name = Key.KeyCode.Name
							end
						elseif IsMouse and BindConfig.AllowMouse ~= false and not Processed then
							Name = Key.UserInputType.Name
						end
						if Name then
							Bind:Set(Name)
							AutoSave()
						end
						return
					end
					if Bind.Value == "None" or UserInputService:GetFocusedTextBox() then return end
					-- clicking any interface with a mouse bind must not fire it
					if Processed and IsMouse then return end
					if Key.KeyCode.Name == Bind.Value or Key.UserInputType.Name == Bind.Value then
						if BindConfig.Hold then
							Holding = true
							task.spawn(RunCallback, BindFrame, BindConfig.Callback, true)
						else
							task.spawn(RunCallback, BindFrame, BindConfig.Callback)
						end
					end
				end)

				AddConnection(UserInputService.InputEnded, function(Key)
					if BindConfig.Hold and Holding and (Key.KeyCode.Name == Bind.Value or Key.UserInputType.Name == Bind.Value) then
						Holding = false
						task.spawn(RunCallback, BindFrame, BindConfig.Callback, false)
					end
				end)

				table.insert(Lunarion.ThemeListeners, function()
					if Cap.Parent then
						CapStroke.Color = ThemeColor("Accent")
						Refresh(false)
					end
				end)

				Bind:Set(BindConfig.Default, true)
				if BindConfig.Flag then
					Lunarion.Flags[BindConfig.Flag] = Bind
					ApplySaved(BindConfig.Flag, Bind)
				end
				return Bind
			end

			function ElementFunction:AddColorpicker(ColorpickerConfig)
				ColorpickerConfig = ColorpickerConfig or {}
				ColorpickerConfig.Name = ColorpickerConfig.Name or "Colorpicker"
				ColorpickerConfig.Default = ColorpickerConfig.Default or Color3.fromRGB(255, 255, 255)
				ColorpickerConfig.Callback = ColorpickerConfig.Callback or function() end
				ColorpickerConfig.Flag = ColorpickerConfig.Flag or nil
				if ColorpickerConfig.Save == nil then ColorpickerConfig.Save = ColorpickerConfig.Flag ~= nil end

				local ColorH, ColorS, ColorV = Color3.toHSV(ColorpickerConfig.Default)
				local Colorpicker = {Value = ColorpickerConfig.Default, Toggled = false, Type = "Colorpicker", Save = ColorpickerConfig.Save}

				local ClosedHeight, OpenHeight = 38, 216

				-- closed state: a small chip that shows the current color and its hex code
				local ChipText = Create("TextLabel", {
					Name = "Hex",
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					FontFace = Fonts.Body,
					TextSize = 11,
					Text = "#FFFFFF",
					TextColor3 = Color3.fromRGB(20, 20, 20)
				})

				local Chip = SetChildren(SetProps(MakeElement("RoundFrame", Colorpicker.Value, 0, 5), {
					Name = "Chip",
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -12, 0.5, 0),
					Size = UDim2.new(0, 68, 0, 22)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					ChipText
				})

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 3
				})

				local Header = SetChildren(SetProps(MakeElement("TFrame"), {
					Size = UDim2.new(1, 0, 0, ClosedHeight),
					Name = "Header"
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ColorpickerConfig.Name, 15), {
						Size = UDim2.new(1, -90, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						FontFace = Fonts.Body,
						Name = "Content"
					}), "Text"),
					Chip,
					Click
				})

				local Divider = AddThemeObject(SetProps(MakeElement("Frame"), {
					Size = UDim2.new(1, -24, 0, 1),
					Position = UDim2.new(0, 12, 0, ClosedHeight),
					BackgroundTransparency = 1,
					Name = "Line"
				}), "Stroke")

				-- open state: saturation/value square, hue slider, R G B and hex inputs
				local SVKnob = Create("ImageLabel", {
					Size = UDim2.new(0, 18, 0, 18),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000"
				})

				local SVBox = Create("ImageLabel", {
					Name = "SV",
					Size = UDim2.new(1, 0, 0, 96),
					Image = "rbxassetid://4155801252",
					BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1),
					BorderSizePixel = 0
				}, {
					Create("UICorner", {CornerRadius = UDim.new(0, 5)}),
					SVKnob
				})

				local HueKnob = Create("Frame", {
					Size = UDim2.new(0, 16, 0, 16),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(ColorH, 0, 0.5, 0),
					BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1),
					BorderSizePixel = 0,
					ZIndex = 2
				}, {
					Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
					Create("UIStroke", {Color = Color3.fromRGB(255, 255, 255), Thickness = 2})
				})

				local HueBar = Create("Frame", {
					Name = "Hue",
					Position = UDim2.new(0, 0, 0, 106),
					Size = UDim2.new(1, 0, 0, 14),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0
				}, {
					Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
					Create("UIGradient", {
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
							ColorSequenceKeypoint.new(1 / 6, Color3.fromRGB(255, 255, 0)),
							ColorSequenceKeypoint.new(2 / 6, Color3.fromRGB(0, 255, 0)),
							ColorSequenceKeypoint.new(3 / 6, Color3.fromRGB(0, 255, 255)),
							ColorSequenceKeypoint.new(4 / 6, Color3.fromRGB(0, 0, 255)),
							ColorSequenceKeypoint.new(5 / 6, Color3.fromRGB(255, 0, 255)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
						})
					}),
					HueKnob
				})

				local function MakeInput(Placeholder, Width, Order)
					local Box = AddThemeObject(Create("TextBox", {
						Size = UDim2.new(1, -8, 1, 0),
						Position = UDim2.new(0, 4, 0, 0),
						BackgroundTransparency = 1,
						FontFace = Fonts.Body,
						TextSize = 12,
						Text = "",
						PlaceholderText = Placeholder,
						PlaceholderColor3 = Color3.fromRGB(140, 140, 140),
						ClearTextOnFocus = false,
						TextXAlignment = Enum.TextXAlignment.Center
					}), "Text")
					local Holder = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
						Size = Width,
						LayoutOrder = Order,
						Name = Placeholder
					}), {
						AddThemeObject(MakeElement("Stroke"), "Stroke"),
						Box
					}), "Main")
					return Holder, Box
				end

				local RHolder, RBox = MakeInput("R", UDim2.new(0.2, -5, 1, 0), 1)
				local GHolder, GBox = MakeInput("G", UDim2.new(0.2, -5, 1, 0), 2)
				local BHolder, BBox = MakeInput("B", UDim2.new(0.2, -5, 1, 0), 3)
				local HexHolder, HexBox = MakeInput("HEX", UDim2.new(0.4, -3, 1, 0), 4)

				local Inputs = SetChildren(SetProps(MakeElement("TFrame"), {
					Position = UDim2.new(0, 0, 0, 130),
					Size = UDim2.new(1, 0, 0, 26),
					Name = "Inputs"
				}), {
					SetProps(MakeElement("List", 0, 6), {
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center
					}),
					RHolder,
					GHolder,
					BHolder,
					HexHolder
				})

				local Body = SetChildren(SetProps(MakeElement("TFrame"), {
					Position = UDim2.new(0, 12, 0, 48),
					Size = UDim2.new(1, -24, 0, 156),
					Name = "Body"
				}), {
					SVBox,
					HueBar,
					Inputs
				})

				local ColorpickerFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
					Size = UDim2.new(1, 0, 0, ClosedHeight),
					ClipsDescendants = true,
					Parent = ItemParent
				}), {
					Header,
					Divider,
					Body,
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")

				local function ToHex(Color)
					return string.format("#%02X%02X%02X", math.floor(Color.R * 255 + 0.5), math.floor(Color.G * 255 + 0.5), math.floor(Color.B * 255 + 0.5))
				end

				local function Refresh(Fire)
					local Color = Color3.fromHSV(ColorH, ColorS, ColorV)
					Colorpicker.Value = Color
					SVBox.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
					SVKnob.Position = UDim2.new(ColorS, 0, 1 - ColorV, 0)
					HueKnob.Position = UDim2.new(ColorH, 0, 0.5, 0)
					HueKnob.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
					Chip.BackgroundColor3 = Color
					ChipText.Text = ToHex(Color)
					local Luminance = Color.R * 0.3 + Color.G * 0.59 + Color.B * 0.11
					ChipText.TextColor3 = Luminance > 0.55 and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(245, 245, 245)
					RBox.Text = tostring(math.floor(Color.R * 255 + 0.5))
					GBox.Text = tostring(math.floor(Color.G * 255 + 0.5))
					BBox.Text = tostring(math.floor(Color.B * 255 + 0.5))
					HexBox.Text = ToHex(Color)
					if Fire then
						RunCallback(nil, ColorpickerConfig.Callback, Color)
					end
				end

				local function SetFromColor(Color)
					local H, S, V = Color3.toHSV(Color)
					if S > 0 and V > 0 then
						ColorH = H -- keep the hue when the color is a gray, so the slider does not jump
					end
					ColorS, ColorV = S, V
				end

				-- dragging (mouse and touch)
				local Dragging
				local Scroller = ItemParent:IsA("ScrollingFrame") and ItemParent or ItemParent:FindFirstAncestorWhichIsA("ScrollingFrame")

				local function PointerPosition(Input)
					if Input.UserInputType == Enum.UserInputType.Touch then
						return Vector2.new(Input.Position.X, Input.Position.Y)
					end
					return Vector2.new(Mouse.X, Mouse.Y)
				end

				local function DragTo(Input)
					local Point = PointerPosition(Input)
					if Dragging == "SV" then
						ColorS = math.clamp((Point.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
						ColorV = 1 - math.clamp((Point.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
					elseif Dragging == "Hue" then
						ColorH = math.clamp((Point.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
					end
					Refresh(true)
				end

				local function BeginDrag(Kind)
					return function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
							Dragging = Kind
							if Scroller then
								Scroller.ScrollingEnabled = false
							end
							DragTo(Input)
						end
					end
				end

				AddConnection(SVBox.InputBegan, BeginDrag("SV"))
				AddConnection(HueBar.InputBegan, BeginDrag("Hue"))

				AddConnection(UserInputService.InputChanged, function(Input)
					if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
						DragTo(Input)
					end
				end)

				AddConnection(UserInputService.InputEnded, function(Input)
					if Dragging and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
						Dragging = nil
						if Scroller then
							Scroller.ScrollingEnabled = true
						end
						AutoSave()
					end
				end)

				-- typed values
				local function CommitChannel(Channel, Box)
					local Number = tonumber(Box.Text)
					if not Number then
						Refresh(false)
						return
					end
					Number = math.clamp(math.floor(Number + 0.5), 0, 255)
					local Current = Colorpicker.Value
					local R, G, B = math.floor(Current.R * 255 + 0.5), math.floor(Current.G * 255 + 0.5), math.floor(Current.B * 255 + 0.5)
					if Channel == 1 then
						R = Number
					elseif Channel == 2 then
						G = Number
					else
						B = Number
					end
					SetFromColor(Color3.fromRGB(R, G, B))
					Refresh(true)
					AutoSave()
				end

				AddConnection(RBox.FocusLost, function()
					CommitChannel(1, RBox)
				end)
				AddConnection(GBox.FocusLost, function()
					CommitChannel(2, GBox)
				end)
				AddConnection(BBox.FocusLost, function()
					CommitChannel(3, BBox)
				end)
				AddConnection(HexBox.FocusLost, function()
					local R, G, B = string.match(HexBox.Text, "^#?(%x%x)(%x%x)(%x%x)$")
					if R then
						SetFromColor(Color3.fromRGB(tonumber(R, 16), tonumber(G, 16), tonumber(B, 16)))
						Refresh(true)
						AutoSave()
					else
						Refresh(false)
					end
				end)

				-- open / close
				AddConnection(Click.MouseEnter, function()
					Tw(ColorpickerFrame, 0.25, nil, nil, {BackgroundColor3 = Shift(ThemeColor("Second"), 6)})
				end)

				AddConnection(Click.MouseLeave, function()
					Tw(ColorpickerFrame, 0.25, nil, nil, {BackgroundColor3 = ThemeColor("Second")})
				end)

				AddConnection(Click.MouseButton1Click, function()
					Colorpicker.Toggled = not Colorpicker.Toggled
					Tw(ColorpickerFrame, 0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
						Size = UDim2.new(1, 0, 0, Colorpicker.Toggled and OpenHeight or ClosedHeight)
					})
					Tw(Divider, 0.3, nil, nil, {BackgroundTransparency = Colorpicker.Toggled and 0 or 1})
				end)

				function Colorpicker:Set(Value)
					SetFromColor(Value)
					Refresh(true)
				end

				Colorpicker:Set(Colorpicker.Value)
				if ColorpickerConfig.Flag then
					Lunarion.Flags[ColorpickerConfig.Flag] = Colorpicker
					ApplySaved(ColorpickerConfig.Flag, Colorpicker)
				end
				return Colorpicker
			end
			-- New names (the Add* names). Old Add* names still work below.
			ElementFunction.Text = ElementFunction.AddLabel
			ElementFunction.Warn = ElementFunction.AddWarningLabel
			ElementFunction.Approve = ElementFunction.AddApproveLabel
			ElementFunction.Note = ElementFunction.AddCustomLabel
			ElementFunction.AddTextbox = ElementFunction.AddInput
			ElementFunction.TextBox = ElementFunction.AddInput
			ElementFunction.AddKeybind = ElementFunction.AddBind
			ElementFunction.Keybind = ElementFunction.AddBind
			ElementFunction.Paragraph = ElementFunction.AddParagraph
			ElementFunction.Button = ElementFunction.AddButton
			ElementFunction.Switch = ElementFunction.AddToggle
			ElementFunction.Slider = ElementFunction.AddSlider
			ElementFunction.Select = ElementFunction.AddDropdown
			ElementFunction.Hotkey = ElementFunction.AddBind
			ElementFunction.Input = ElementFunction.AddInput
			ElementFunction.ColorPick = ElementFunction.AddColorpicker
			ElementFunction.Colorpicker = ElementFunction.AddColorpicker
			ElementFunction.ColorPicker = ElementFunction.AddColorpicker
			ElementFunction.AddColorPicker = ElementFunction.AddColorpicker

			for SearchFnName, SearchFn in pairs(ElementFunction) do
				ElementFunction[SearchFnName] = function(SearchSelf, SearchConfig, ...)
					local SearchResult = SearchFn(SearchSelf, SearchConfig, ...)
					local SearchName
					if type(SearchConfig) == "table" then
						SearchName = SearchConfig.Name or SearchConfig.Text or SearchConfig.Title
					elseif type(SearchConfig) == "string" then
						SearchName = SearchConfig
					end
					if SearchName and SearchName ~= "" then
						local SearchChildren = ItemParent:GetChildren()
						local SearchTarget = SearchChildren[#SearchChildren]
						if SearchTarget and SearchTarget:IsA("GuiObject") then
							RegisterSearchable(tostring(SearchName), TabFrame, Container, SearchTarget)
						end
					end
					return SearchResult
				end
			end
			return ElementFunction   
		end	

		local ElementFunction = {}

		function ElementFunction:AddSection(SectionConfig)
			SectionConfig.Name = SectionConfig.Name or "Section"

			local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 0, 26),
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 14), {
					Size = UDim2.new(1, -12, 0, 16),
					Position = UDim2.new(0, 0, 0, 3),
					FontFace = Fonts.Title
				}), "TextDark"),
				SetChildren(SetProps(MakeElement("TFrame"), {
					AnchorPoint = Vector2.new(0, 0),
					Size = UDim2.new(1, 0, 1, -24),
					Position = UDim2.new(0, 0, 0, 23),
					Name = "Holder"
				}), {
					MakeElement("List", 0, 6)
				}),
			})

			AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				SectionFrame.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
				SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
			end)

			RegisterSearchable(tostring(SectionConfig.Name), TabFrame, Container, SectionFrame)

			local SectionFunction = {}
			for i, v in next, GetElements(SectionFrame.Holder) do
				SectionFunction[i] = v 
			end
			return SectionFunction
		end	

		for i, v in next, GetElements(Container) do
			ElementFunction[i] = v 
		end
		ElementFunction.Group = ElementFunction.AddSection -- new name for AddSection
		ElementFunction.Container = Container

		if TabConfig.PremiumOnly then
			for i, v in next, ElementFunction do
				ElementFunction[i] = function() end
			end    
			Container:FindFirstChild("UIListLayout"):Destroy()
			Container:FindFirstChild("UIPadding"):Destroy()
			SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 1, 0),
				Parent = ItemParent
			}), {
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://3610239960"), {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, 15, 0, 15),
					ImageTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Unauthorised Access", 14), {
					Size = UDim2.new(1, -38, 0, 14),
					Position = UDim2.new(0, 38, 0, 18),
					TextTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4483345875"), {
					Size = UDim2.new(0, 56, 0, 56),
					Position = UDim2.new(0, 84, 0, 110),
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Premium Features", 14), {
					Size = UDim2.new(1, -150, 0, 14),
					Position = UDim2.new(0, 150, 0, 112),
					FontFace = Fonts.Title
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "This part of the script is locked to Sirius Premium users. Purchase Premium in the Discord server (sirius.menu/discord)", 12), {
					Size = UDim2.new(1, -200, 0, 14),
					Position = UDim2.new(0, 150, 0, 138),
					TextWrapped = true,
					TextTransparency = 0.4
				}), "Text")
			})
		end
		return ElementFunction   
	end  
	
	-- Homeboard: dashboard (player, executor, discord, friends, server), Lunarion styled.
	-- Window config: Homeboard = true | false | { Name, Icon, ImageSource, Discord, Executors, ShowFriends, ShowServer }
	function TabFunction:MakeHomeboard(HB)
		if HB == nil or HB == true then
			HB = {}
		end
		if type(HB) ~= "table" then
			return
		end

		local Players = game:GetService("Players")
		local Stats = game:GetService("Stats")

		TabFunction:MakeTab({
			Name = HB.Name or "Homeboard",
			Icon = HB.Icon or "layout-dashboard",
			ImageSource = HB.ImageSource,
			Custom = function(Container)
				local Order = 0
				local function NextOrder()
					Order = Order + 1
					return Order
				end

				-- names can contain < > & which RichText would swallow
				local function Esc(Text)
					return (tostring(Text):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
				end

				-- every section is isolated: if one fails, the rest of the Homeboard still builds
				local function Safe(Label, Fn)
					local Ok, Err = pcall(Fn)
					if not Ok then
						warn("Lunarion | Homeboard (" .. Label .. "): " .. tostring(Err))
					end
				end

				local function Card(Parent, Height)
					return AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 8), {
						Size = UDim2.new(1, 0, 0, Height),
						BackgroundTransparency = 0.2,
						Parent = Parent
					}), {
						AddThemeObject(MakeElement("Stroke"), "Stroke")
					}), "Second")
				end

				local function Header(Text)
					return AddThemeObject(SetProps(MakeElement("Label", Text, 13), {
						Size = UDim2.new(1, 0, 0, 20),
						FontFace = Fonts.Body,
						LayoutOrder = NextOrder(),
						Parent = Container
					}), "TextDark")
				end

				local function Grid(Parent)
					local Holder = SetChildren(SetProps(MakeElement("TFrame"), {
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						LayoutOrder = NextOrder(),
						Parent = Parent
					}), {
						Create("UIGridLayout", {
							CellPadding = UDim2.new(0, 8, 0, 8),
							CellSize = UDim2.new(0.5, -4, 0, 54),
							SortOrder = Enum.SortOrder.LayoutOrder
						})
					})
					local function Fit()
						local Wide = Holder.AbsoluteSize.X >= 340
						Holder.UIGridLayout.CellSize = Wide and UDim2.new(0.5, -4, 0, 54) or UDim2.new(1, 0, 0, 54)
					end
					AddConnection(Holder:GetPropertyChangedSignal("AbsoluteSize"), Fit)
					Fit()
					return Holder
				end

				local function Stat(Parent, Order, IconName, Title, Value)
					local Frame = Card(Parent, 54)
					Frame.LayoutOrder = Order
					AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 8), {
						Size = UDim2.new(0, 32, 0, 32),
						Position = UDim2.new(0, 11, 0.5, -16),
						BackgroundTransparency = 0.85,
						Parent = Frame
					}), {
						AddThemeObject(SetProps(MakeElement("Image", IconName), {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.new(0.5, 0, 0.5, 0),
							Size = UDim2.new(0, 18, 0, 18)
						}), "Accent")
					}), "Accent")
					local TitleLabel = AddThemeObject(SetProps(MakeElement("Label", Esc(Title), 11), {
						Position = UDim2.new(0, 55, 0, 9),
						Size = UDim2.new(1, -65, 0, 14),
						FontFace = Fonts.Thin,
						TextTruncate = Enum.TextTruncate.AtEnd,
						Parent = Frame
					}), "TextDark")
					local ValueLabel = AddThemeObject(SetProps(MakeElement("Label", Esc(Value), 15), {
						Position = UDim2.new(0, 55, 0, 24),
						Size = UDim2.new(1, -65, 0, 20),
						FontFace = Fonts.Body,
						TextTruncate = Enum.TextTruncate.AtEnd,
						Parent = Frame
					}), "Text")
					return {Frame = Frame, Title = TitleLabel, Value = ValueLabel}
				end

				-- Player card: "Hello, <DisplayName>" -----------------------------------------------------
				if HB.ShowProfile ~= false then
				Safe("player", function()
					local Head = Card(Container, 68)
					Head.LayoutOrder = NextOrder()
					Head.ClipsDescendants = true
					-- ONE gradient, clipped to the card's own rounded shape (before, a square glow layer stacked on the
					-- card and poked out of its corners, which read as overlapping gradients)
					local Glow = AddThemeObject(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 8), {
						Size = UDim2.new(1, 0, 1, 0),
						ZIndex = 1,
						Parent = Head
					}), "Accent")
					Create("UIGradient", {
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0.84),
							NumberSequenceKeypoint.new(0.6, 1),
							NumberSequenceKeypoint.new(1, 1)
						}),
						Parent = Glow
					})
					SetChildren(SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"), {
						Size = UDim2.new(0, 44, 0, 44),
						Position = UDim2.new(0, 12, 0.5, -22),
						ZIndex = 2,
						Parent = Head
					}), {
						MakeElement("Corner", 1),
						AddThemeObject(MakeElement("Stroke", nil, 1.5), "Accent")
					})
					AddThemeObject(SetProps(MakeElement("Label", "Hello, " .. Esc(LocalPlayer.DisplayName), 17), {
						Position = UDim2.new(0, 68, 0, 13),
						Size = UDim2.new(1, -80, 0, 22),
						FontFace = Fonts.Title,
						TextTruncate = Enum.TextTruncate.AtEnd,
						ZIndex = 2,
						Parent = Head
					}), "Text")
					AddThemeObject(SetProps(MakeElement("Label", "@" .. Esc(LocalPlayer.Name) .. "  ·  " .. Esc(WindowConfig.Name), 12), {
						Position = UDim2.new(0, 68, 0, 37),
						Size = UDim2.new(1, -80, 0, 16),
						FontFace = Fonts.Thin,
						TextTruncate = Enum.TextTruncate.AtEnd,
						ZIndex = 2,
						Parent = Head
					}), "TextDark")
				end)
				end

				-- Executor + Discord (both cards are always shown) -----------------------------------------
				Safe("executor / discord", function()
					local Top = Grid(Container)

					local Executor = "Unknown"
					pcall(function()
						Executor = tostring((identifyexecutor and identifyexecutor()) or "Unknown")
					end)
					local ExecStatus = "Detected"
					if type(HB.Executors) == "table" and #HB.Executors > 0 then
						ExecStatus = "Not officially supported"
						for _, Supported in ipairs(HB.Executors) do
							if string.lower(tostring(Supported)) == string.lower(Executor) then
								ExecStatus = "Supported"
								break
							end
						end
					end
					Stat(Top, 1, "computer", "Executor  ·  " .. ExecStatus, Executor)

					local Invite = HB.Discord
					local HasInvite = type(Invite) == "string" and Invite ~= ""
					local Code, Link
					if HasInvite then
						Code = string.match(Invite, "discord%.gg/([%w%-_]+)") or string.match(Invite, "discord%.com/invite/([%w%-_]+)") or Invite
						Link = "https://discord.gg/" .. Code
					end
					local DiscordCard = Stat(Top, 2, "forum", "Discord", HasInvite and "Tap to copy invite" or "No invite set")
					local DiscordClick = SetProps(MakeElement("Button"), {
						Size = UDim2.new(1, 0, 1, 0),
						ZIndex = 5,
						Parent = DiscordCard.Frame
					})
					AddConnection(DiscordClick.MouseEnter, function()
						Tw(DiscordCard.Frame, 0.25, nil, nil, {BackgroundTransparency = 0.15})
					end)
					AddConnection(DiscordClick.MouseLeave, function()
						Tw(DiscordCard.Frame, 0.25, nil, nil, {BackgroundTransparency = 0.35})
					end)
					AddConnection(DiscordClick.MouseButton1Click, function()
						if not HasInvite then
							Lunarion:MakeNotification({
								Name = "Discord",
								Content = "No Discord invite was set for this hub.",
								Icon = "message-square",
								ImageSource = nil,
								Type = "warning",
								Duration = 3
							})
							return
						end
						pcall(function()
							setclipboard(Link)
						end)
						local Request = (syn and syn.request) or (http and http.request) or http_request or request
						if Request then
							task.spawn(pcall, function()
								Request({
									Url = "http://127.0.0.1:6463/rpc?v=1",
									Method = "POST",
									Headers = {["Content-Type"] = "application/json", Origin = "https://discord.com"},
									Body = HttpService:JSONEncode({
										cmd = "INVITE_BROWSER",
										nonce = HttpService:GenerateGUID(false),
										args = {code = Code}
									})
								})
							end)
						end
						Lunarion:MakeNotification({
							Name = "Discord",
							Content = "Invite link copied to your clipboard.",
							Icon = "message-square",
							ImageSource = nil,
							Type = "success",
							Duration = 3
						})
					end)
				end)

				-- Friends -----------------------------------------------------------------------------
				local FriendStats
				if HB.ShowFriends ~= false then
					Safe("friends", function()
						Header("Friends")
						local Friends = Grid(Container)
						FriendStats = {
							All = Stat(Friends, 1, "group", "All", "…"),
							Online = Stat(Friends, 2, "wifi", "Online", "…"),
							InGame = Stat(Friends, 3, "sports_esports", "In this server", "…"),
							Offline = Stat(Friends, 4, "visibility_off", "Offline", "…")
						}
					end)
				end

				-- Server ------------------------------------------------------------------------------
				local ServerStats
				if HB.ShowServer ~= false then
					Safe("server", function()
						Header("Server")
						local Server = Grid(Container)
						ServerStats = {
							Players = Stat(Server, 1, "people", "Players", "…"),
							Max = Stat(Server, 2, "groups", "Max players", "…"),
							Ping = Stat(Server, 3, "network_check", "Latency", "…"),
							Fps = Stat(Server, 4, "speed", "FPS", "…"),
							Time = Stat(Server, 5, "schedule", "Server time", "…"),
							Region = Stat(Server, 6, "public", "Region", "…")
						}
						task.spawn(function()
							local Ok, Region = pcall(function()
								return game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(LocalPlayer)
							end)
							ServerStats.Region.Value.Text = Ok and Esc(Region) or "Unknown"
						end)
					end)
				end

				-- live updates (only while the Homeboard is on screen) ----------------------------------
				local Fps = 60
				AddConnection(RunService.Heartbeat, function(Delta)
					Fps = Fps + ((1 / math.max(Delta, 0.001)) - Fps) * 0.05
				end)

				local LastFriends, FetchingFriends = -math.huge, false
				local function FetchFriends()
					local Total, InServer = 0, 0
					local Pages = Players:GetFriendsAsync(LocalPlayer.UserId)
					while true do
						for _, Friend in ipairs(Pages:GetCurrentPage()) do
							Total = Total + 1
							if Players:FindFirstChild(Friend.Username) then
								InServer = InServer + 1
							end
						end
						if Pages.IsFinished then
							break
						end
						Pages:AdvanceToNextPageAsync()
					end
					local Online = 0
					pcall(function()
						Online = #LocalPlayer:GetFriendsOnline(200)
					end)
					FriendStats.All.Value.Text = Total .. " friends"
					FriendStats.Online.Value.Text = Online .. " friends"
					FriendStats.InGame.Value.Text = InServer .. " friends"
					FriendStats.Offline.Value.Text = math.max(Total - Online, 0) .. " friends"
				end

				local function Update()
					if ServerStats then
						ServerStats.Players.Value.Text = tostring(#Players:GetPlayers())
						ServerStats.Max.Value.Text = tostring(Players.MaxPlayers)
						local Ping = "N/A"
						pcall(function()
							Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms"
						end)
						ServerStats.Ping.Value.Text = Ping
						ServerStats.Fps.Value.Text = math.floor(Fps + 0.5) .. " fps"
						local Seconds = math.floor(time())
						ServerStats.Time.Value.Text = string.format("%02d:%02d:%02d", math.floor(Seconds / 3600), math.floor(Seconds / 60) % 60, Seconds % 60)
					end
					if FriendStats and not FetchingFriends and os.clock() - LastFriends > 60 then
						FetchingFriends = true
						task.spawn(function()
							pcall(FetchFriends)
							LastFriends = os.clock()
							FetchingFriends = false
						end)
					end
				end

				task.spawn(function()
					while Lunarion:IsRunning() and Container.Parent do
						if Container.Visible and MainWindow.Visible then
							pcall(Update)
						end
						task.wait(1)
					end
				end)
			end
		})
	end

	if WindowConfig.Homeboard ~= false then
		TabFunction:MakeHomeboard(WindowConfig.Homeboard)
	end

	-- New names for the Window object (the Make*/Toggle* names).
	-- The old MakeTab / MakeTabSection / MakeHomeboard / ToggleInterface names still work below.
	TabFunction.Page = TabFunction.MakeTab
	-- Settings page ---------------------------------------------------------------------------------------
	local SettingsTab, SettingsReturn
	local function Resolve(Value)
		if type(Value) == "function" then
			local Ok, Result = pcall(Value)
			return Ok and Result or nil
		end
		return Value
	end
	local function BuildSettings()
		SettingsTab = TabFunction:MakeTab({Name = "Settings", Icon = "settings", Hidden = true})
		local Sections = {}
		for _, Row in ipairs(Lunarion.SettingRows) do
			local Name = Row.Section or "General"
			if not Sections[Name] then
				Sections[Name] = SettingsTab:AddSection({Name = Name})
			end
			local Holder = Sections[Name]
			if Row.Type == "Dropdown" then
				Holder:AddDropdown({Name = Row.Name, Options = Resolve(Row.Options) or {}, Default = Resolve(Row.Default), Callback = Row.Callback or function() end})
			elseif Row.Type == "Button" then
				Holder:AddButton({Name = Row.Name, Icon = Row.Icon, Callback = Row.Callback or function() end})
			else
				Holder:AddToggle({Name = Row.Name, Default = Resolve(Row.Default) and true or false, Callback = Row.Callback or function() end})
			end
		end
	end
	OpenSettingsPage = function()
		if Minimized or Animating or MinimizeBusy then
			return
		end
		if not SettingsTab then
			BuildSettings()
		end
		local Container = SettingsTab.Container
		local Activate = TabActivators[Container]
		if not Activate then
			return
		end
		if ActiveContainer == Container then
			-- second press: go back to where you were
			local Back = SettingsReturn and TabActivators[SettingsReturn]
			if Back then Back() end
		else
			SettingsReturn = ActiveContainer
			Activate()
		end
	end

	TabFunction.Divider = TabFunction.MakeTabSection
	TabFunction.Dashboard = TabFunction.MakeHomeboard
	TabFunction.Flip = TabFunction.ToggleInterface

	return TabFunction
end   

function Lunarion:Destroy()
	Root:Destroy()
end

-- New names for the library itself (the Make*/Get*/Set* names).
-- The old names (MakeWindow, MakeNotification, SetTheme, Init, SaveConfig, Destroy, ...) still work.
Lunarion.Spawn = Lunarion.MakeWindow
Lunarion.Alert = Lunarion.MakeNotification
Lunarion.DefineTheme = Lunarion.AddTheme
Lunarion.UseTheme = Lunarion.SetTheme
Lunarion.CurrentTheme = Lunarion.GetTheme
Lunarion.ListThemes = Lunarion.GetThemes
Lunarion.EnableTelemetry = Lunarion.EnableAnalytics
Lunarion.LogEvent = Lunarion.TrackEvent
Lunarion.TelemetryData = Lunarion.GetAnalytics
Lunarion.ResetTelemetry = Lunarion.ClearAnalytics
Lunarion.ExportTelemetry = Lunarion.ExportAnalytics
Lunarion.Boot = Lunarion.Init
Lunarion.Persist = Lunarion.SaveConfig
Lunarion.Gate = Lunarion.MakeKeySystem
Lunarion.Alive = Lunarion.IsRunning
Lunarion.Teardown = Lunarion.Destroy

-- Locked public table: callers get the API through a proxy, the internals (Flags, Connections, Elements,
-- Analytics, ...) are not reachable through it, API functions cannot be overwritten and the metatable is sealed.
local Public = {}
for _, Name in ipairs({"MakeWindow", "MakeNotification", "MakeKeySystem", "AddTheme", "SetTheme", "GetTheme", "GetThemes",
	"EnableAnalytics", "TrackEvent", "GetAnalytics", "ClearAnalytics", "ExportAnalytics", "Init", "SaveConfig", "Destroy", "IsRunning",
	"Spawn", "Alert", "DefineTheme", "UseTheme", "CurrentTheme", "ListThemes", "EnableTelemetry", "LogEvent", "TelemetryData",
	"ResetTelemetry", "ExportTelemetry", "Boot", "Persist", "Gate", "Alive", "Teardown"}) do
	Public[Name] = Lunarion[Name]
end
local Readable = {Name = Lunarion.Name, Version = Lunarion.Version, Platform = Lunarion.Platform}
return setmetatable({}, {
	__index = function(_, Key)
		local Api = Public[Key]
		if Api ~= nil then
			return Api
		end
		return Readable[Key]
	end,
	__newindex = function() end,
	__metatable = "locked",
	__tostring = function() return "Lunarion" end
})
