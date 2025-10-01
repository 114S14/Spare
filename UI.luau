--[=[
	User Interface Library
	Made by Late, Modified for Text GUI like VAPE V4
	Modified to add ActiveTabLabel in top-right corner
	Modified to add ActiveComponentsLabel below tabs
]=]

--// Connections
local GetService = game.GetService
local Connect = game.Loaded.Connect
local Wait = game.Loaded.Wait
local Clone = game.Clone 
local Destroy = game.Destroy 

if not game:IsLoaded() then
	local Loaded = game.Loaded
	Loaded.Wait(Loaded);
end

--// Important 
local Setup = {
	Keybind = Enum.KeyCode.LeftControl,
	Transparency = 0.2,
	ThemeMode = "Dark",
	Size = nil,
}

local Theme = {
	Primary = Color3.fromRGB(30, 30, 30),
	Secondary = Color3.fromRGB(35, 35, 35),
	Component = Color3.fromRGB(40, 40, 40),
	Interactables = Color3.fromRGB(45, 45, 45),
	Tab = Color3.fromRGB(200, 200, 200),
	Title = Color3.fromRGB(240, 240, 240),
	Description = Color3.fromRGB(200, 200, 200),
	Shadow = Color3.fromRGB(0, 0, 0),
	Outline = Color3.fromRGB(40, 40, 40),
	Icon = Color3.fromRGB(220, 220, 220),
}

--// Services & Functions
local Type, Blur = nil
local LocalPlayer = GetService(game, "Players").LocalPlayer
local Services = {
	Insert = GetService(game, "InsertService"),
	Tween = GetService(game, "TweenService"),
	Run = GetService(game, "RunService"),
	Input = GetService(game, "UserInputService"),
}

local Player = {
	Mouse = LocalPlayer:GetMouse(),
	GUI = LocalPlayer.PlayerGui,
}

local Tween = function(Object: Instance, Speed: number, Properties: {}, Info: { EasingStyle: Enum?, EasingDirection: Enum? })
	local Style, Direction = Info and Info.EasingStyle or Enum.EasingStyle.Sine, Info and Info.EasingDirection or Enum.EasingDirection.Out
	return Services.Tween:Create(Object, TweenInfo.new(Speed, Style, Direction), Properties):Play()
end

local SetProperty = function(Object: Instance, Properties: {})
	for Index, Property in next, Properties do
		Object[Index] = Property
	end
	return Object
end

local Multiply = function(Value, Amount)
	return UDim2.new(
		Value.X.Scale * Amount,
		Value.X.Offset * Amount,
		Value.Y.Scale * Amount,
		Value.Y.Offset * Amount
	)
end

local Color = function(Color, Factor, Mode)
	Mode = Mode or Setup.ThemeMode
	if Mode == "Light" then
		return Color3.fromRGB((Color.R * 255) - Factor, (Color.G * 255) - Factor, (Color.B * 255) - Factor)
	else
		return Color3.fromRGB((Color.R * 255) + Factor, (Color.G * 255) + Factor, (Color.B * 255) + Factor)
	end
end

local Drag = function(Canvas)
	if Canvas then
		local Dragging, DragInput, Start, StartPosition
		Connect(Canvas.InputBegan, function(Input)
			if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not Type then
				Dragging = true
				Start = Input.Position
				StartPosition = Canvas.Position
				Connect(Input.Changed, function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		Connect(Canvas.InputChanged, function(Input)
			if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and not Type then
				DragInput = Input
			end
		end)
		Connect(Services.Input.InputChanged, function(Input)
			if Input == DragInput and Dragging and not Type then
				local delta = Input.Position - Start
				Canvas.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
			end
		end)
	end
end

local Resizing = { 
	TopLeft = { X = Vector2.new(-1, 0), Y = Vector2.new(0, -1) },
	TopRight = { X = Vector2.new(1, 0), Y = Vector2.new(0, -1) },
	BottomLeft = { X = Vector2.new(-1, 0), Y = Vector2.new(0, 1) },
	BottomRight = { X = Vector2.new(1, 0), Y = Vector2.new(0, 1) },
}

local Resizeable = function(Tab, Minimum, Maximum)
	task.spawn(function()
		local MousePos, Size, UIPos
		if Tab and Tab:FindFirstChild("Resize") then
			local Positions = Tab:FindFirstChild("Resize")
			for Index, Types in next, Positions:GetChildren() do
				Connect(Types.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = Types
						MousePos = Vector2.new(Player.Mouse.X, Player.Mouse.Y)
						Size = Tab.AbsoluteSize
						UIPos = Tab.Position
					end
				end)
				Connect(Types.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = nil
					end
				end)
			end
		else
			warn("Resize child not found in Tab")
		end

		local Resize = function(Delta)
			if Type and MousePos and Size and UIPos and Tab:FindFirstChild("Resize")[Type.Name] == Type then
				local Mode = Resizing[Type.Name]
				local NewSize = Vector2.new(Size.X + Delta.X * Mode.X.X, Size.Y + Delta.Y * Mode.Y.Y)
				NewSize = Vector2.new(math.clamp(NewSize.X, Minimum.X, Maximum.X), math.clamp(NewSize.Y, Minimum.Y, Maximum.Y))
				local AnchorOffset = Vector2.new(Tab.AnchorPoint.X * Size.X, Tab.AnchorPoint.Y * Size.Y)
				local NewAnchorOffset = Vector2.new(Tab.AnchorPoint.X * NewSize.X, Tab.AnchorPoint.Y * NewSize.Y)
				local DeltaAnchorOffset = NewAnchorOffset - AnchorOffset
				Tab.Size = UDim2.new(0, NewSize.X, 0, NewSize.Y)
				Tab.Position = UDim2.new(
					UIPos.X.Scale, 
					UIPos.X.Offset + DeltaAnchorOffset.X * Mode.X.X,
					UIPos.Y.Scale,
					UIPos.Y.Offset + DeltaAnchorOffset.Y * Mode.Y.Y
				)
			end
		end

		Connect(Player.Mouse.Move, function()
			if Type then
				Resize(Vector2.new(Player.Mouse.X, Player.Mouse.Y) - MousePos)
			end
		end)
	end)
end

--// Setup [UI]
local success, Screen = pcall(function()
	return Services.Insert:LoadLocalAsset("rbxassetid://18490507748")
end)
if not success then
	warn("Failed to load UI asset: " .. Screen)
	Screen = script.Parent
end

local success, Blur = pcall(function()
	if identifyexecutor then
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/lates-lib/main/Assets/Blur.lua"))()
	else
		return require(script.Blur)
	end
end)
if not success then
	warn("Failed to load Blur: " .. Blur)
	Blur = nil
end

Screen.Main.Visible = false

xpcall(function()
	Screen.Parent = game.CoreGui
end, function() 
	Screen.Parent = Player.GUI
end)

--// Tables for Data
local Animations = {}
local Blurs = {}
local Components = Screen:FindFirstChild("Components")
local Library = {}
local StoredInfo = {
	Sections = {},
	Tabs = {},
	ActiveComponents = {}, -- [新增] 存储当前选项卡的活跃组件
	CurrentTab = nil, -- [新增] 跟踪当前选项卡
}

--// Animations [Window]
function Animations:Open(Window: CanvasGroup, Transparency: number, UseCurrentSize: boolean)
	local Original = UseCurrentSize and Window.Size or Setup.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")

	SetProperty(Shadow, { Transparency = 1 })
	SetProperty(Window, { Size = Multiplied, GroupTransparency = 1, Visible = true })
	Tween(Shadow, .25, { Transparency = 0.5 })
	Tween(Window, .25, { Size = Original, GroupTransparency = Transparency or 0 })
end

function Animations:Close(Window: CanvasGroup)
	local Original = Window.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")

	SetProperty(Window, { Size = Original })
	Tween(Shadow, .25, { Transparency = 1 })
	Tween(Window, .25, { Size = Multiplied, GroupTransparency = 1 })
	task.wait(.25)
	Window.Size = Original
	Window.Visible = false
end

function Animations:Component(Component: any, Custom: boolean)	
	Connect(Component.InputBegan, function() 
		if Custom then
			Tween(Component, .25, { Transparency = .85 })
			local Image = Component:FindFirstChild("Icon")
			if Image then
				Tween(Image, .25, { ImageTransparency = .85 })
			end
		else
			Tween(Component, .25, { BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode) })
		end
	end)
	Connect(Component.InputEnded, function() 
		if Custom then
			Tween(Component, .25, { Transparency = 1 })
			local Image = Component:FindFirstChild("Icon")
			if Image then
				Tween(Image, .25, { ImageTransparency = Setup.Transparency })
			end
		else
			Tween(Component, .25, { BackgroundColor3 = Theme.Component })
		end
	end)
end

--// Library [Window]
function Library:CreateWindow(Settings: { Title: string, Size: UDim2, Transparency: number, MinimizeKeybind: Enum.KeyCode?, Blurring: boolean, Theme: string, FloatingIcon: string? })
	local Window = Clone(Screen:WaitForChild("Main"))
	local Sidebar = Window:FindFirstChild("Sidebar")
	local Holder = Window:FindFirstChild("Main")
	local BG = Window:FindFirstChild("BackgroundShadow")
	local Tab = Sidebar:FindFirstChild("Tab")

	local Options = {}
	local Examples = {}
	local Opened = true
	local BlurEnabled = false
	local Connections = {}
	local IsToggling = false
	local IsDragging = false
	local DragStarted = 0
	local ActiveTabLabel = nil
	local ActiveComponentsLabel = nil -- [新增] 活跃组件标签

	for Index, Example in next, Window:GetDescendants() do
		if Example.Name:find("Example") and not Examples[Example.Name] then
			Examples[Example.Name] = Example
		end
	end

	--// 检查 Sidebar.Top 是否存在
	local SidebarTop = Sidebar:FindFirstChild("Top")
	if not SidebarTop then
		warn("Sidebar.Top not found! Creating new Top frame.")
		SidebarTop = Instance.new("Frame")
		SidebarTop.Name = "Top"
		SidebarTop.Parent = Sidebar
		SidebarTop.BackgroundTransparency = 1
		SidebarTop.Size = UDim2.new(1, 0, 0, 50)
		SidebarTop.Position = UDim2.new(0, 0, 0, 0)
	end
	print("Sidebar.Top exists: ", SidebarTop ~= nil)

	--// 添加标题栏
	local TitleBar = Instance.new("TextLabel")
	TitleBar.Name = "TitleBar"
	TitleBar.Parent = SidebarTop
	TitleBar.Size = UDim2.new(0.5, 0, 0, 30)
	TitleBar.Position = UDim2.new(0, 10, 0, 5)
	TitleBar.BackgroundTransparency = 1
	TitleBar.Text = Settings.Title
	TitleBar.TextColor3 = Theme.Title
	TitleBar.TextSize = 16
	TitleBar.Font = Enum.Font.SourceSansBold
	TitleBar.TextXAlignment = Enum.TextXAlignment.Left
	TitleBar.TextYAlignment = Enum.TextYAlignment.Center
	TitleBar.ZIndex = 5

	--// 删除原有按钮
	local Buttons = SidebarTop:FindFirstChild("Buttons")
	if Buttons then
		for _, Button in pairs(Buttons:GetChildren()) do
			if Button:IsA("TextButton") then
				Button:Destroy()
			end
		end
	end

	--// 添加右上角的 ActiveTabLabel
	ActiveTabLabel = Instance.new("TextLabel")
	ActiveTabLabel.Name = "ActiveTabLabel"
	ActiveTabLabel.Parent = Screen
	ActiveTabLabel.Size = UDim2.new(0, 200, 0, 30)
	ActiveTabLabel.Position = UDim2.new(1, -220, 0, 10)
	ActiveTabLabel.BackgroundTransparency = 1
	ActiveTabLabel.Text = "No Tab Selected"
	ActiveTabLabel.TextColor3 = Theme.Title
	ActiveTabLabel.TextSize = 16
	ActiveTabLabel.Font = Enum.Font.SourceSansBold
	ActiveTabLabel.TextTransparency = Setup.Transparency
	ActiveTabLabel.TextXAlignment = Enum.TextXAlignment.Right
	ActiveTabLabel.TextYAlignment = Enum.TextYAlignment.Center
	ActiveTabLabel.ZIndex = 10
	ActiveTabLabel.Visible = true
	print("ActiveTabLabel created: ", ActiveTabLabel ~= nil)

	--// [新增] 添加选项卡下方的 ActiveComponentsLabel
	ActiveComponentsLabel = Instance.new("TextLabel")
	ActiveComponentsLabel.Name = "ActiveComponentsLabel"
	ActiveComponentsLabel.Parent = Window
	ActiveComponentsLabel.Size = UDim2.new(1, -20, 0, 30)
	ActiveComponentsLabel.Position = UDim2.new(0, 10, 0, SidebarTop.Size.Y.Offset + Tab.Size.Y.Offset + 10)
	ActiveComponentsLabel.BackgroundTransparency = 1
	ActiveComponentsLabel.Text = ""
	ActiveComponentsLabel.TextColor3 = Theme.Title
	ActiveComponentsLabel.TextSize = 14
	ActiveComponentsLabel.Font = Enum.Font.SourceSans
	ActiveComponentsLabel.TextTransparency = Setup.Transparency
	ActiveComponentsLabel.TextXAlignment = Enum.TextXAlignment.Left
	ActiveComponentsLabel.TextYAlignment = Enum.TextYAlignment.Center
	ActiveComponentsLabel.ZIndex = 5
	ActiveComponentsLabel.Visible = true
	print("ActiveComponentsLabel created: ", ActiveComponentsLabel ~= nil)

	--// UI Blur & More
	Drag(Window)
	Resizeable(Window, Vector2.new(411, 271), Vector2.new(9e9, 9e9))
	Setup.Transparency = Settings.Transparency or 0
	Setup.Size = Settings.Size
	Setup.ThemeMode = Settings.Theme or "Dark"

	if Settings.Blurring and Blur then
		Blurs[Settings.Title] = Blur.new(Window, 5)
		BlurEnabled = true
	end

	if Settings.MinimizeKeybind then
		Setup.Keybind = Settings.MinimizeKeybind
	end

	--// 创建浮动按钮
	local FloatingButton = Instance.new("TextButton")
	FloatingButton.Name = "ToggleUIFloatingButton"
	FloatingButton.Parent = Screen
	FloatingButton.BackgroundColor3 = Theme.Interactables
	FloatingButton.Size = UDim2.new(0, 50, 0, 50)
	FloatingButton.Position = UDim2.new(1, -70, 1, -70)
	FloatingButton.Text = ""
	FloatingButton.BackgroundTransparency = Setup.Transparency
	FloatingButton.AutoButtonColor = false
	FloatingButton.ZIndex = 10
	FloatingButton.Visible = true
	local FloatIcon = Instance.new("ImageLabel")
	FloatIcon.Name = "Icon"
	FloatIcon.Parent = FloatingButton
	FloatIcon.Size = UDim2.new(0, 32, 0, 32)
	FloatIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	FloatIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	FloatIcon.BackgroundTransparency = 1
	FloatIcon.Image = Settings.FloatingIcon or "rbxasset://textures/ui/GuiImagePlaceholder.png"
	FloatIcon.ImageColor3 = Theme.Title
	FloatIcon.ImageTransparency = Setup.Transparency
	FloatIcon.ZIndex = 11
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 12)
	Corner.Parent = FloatingButton
	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Theme.Outline
	Stroke.Transparency = Setup.Transparency
	Stroke.Parent = FloatingButton

	print("FloatingButton created: ", FloatingButton ~= nil)
	print("FloatIcon.Image: ", FloatIcon.Image)
	print("FloatIcon.ImageTransparency: ", FloatIcon.ImageTransparency)

	--// 使浮动按钮可拖动
	local function MakeDraggable(Button)
		local Dragging, DragInput, Start, StartPosition
		local ScreenSize = game:GetService("GuiService"):GetScreenResolution()

		local DragConnection1 = Connect(Button.InputBegan, function(Input)
			if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not Type then
				print("开始拖动 FloatingButton")
				IsDragging = true
				Dragging = true
				DragStarted = tick()
				Start = Input.Position
				StartPosition = Button.Position
			end
		end)

		local DragConnection2 = Connect(Button.InputChanged, function(Input)
			if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and not Type then
				DragInput = Input
			end
		end)

		local DragConnection3 = Connect(Services.Input.InputChanged, function(Input)
			if Input == DragInput and Dragging and not Type then
				local delta = Input.Position - Start
				local newX = math.clamp(StartPosition.X.Offset + delta.X, 0, ScreenSize.X - Button.AbsoluteSize.X)
				local newY = math.clamp(StartPosition.Y.Offset + delta.Y, 0, ScreenSize.Y - Button.AbsoluteSize.Y)
				Button.Position = UDim2.new(0, newX, 0, newY)
			end
		end)

		local DragConnection4 = Connect(Services.Input.InputEnded, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Dragging = false
				IsDragging = false
				print("拖动结束，持续时间：" .. tostring(tick() - DragStarted))
			end
		end)

		table.insert(Connections, DragConnection1)
		table.insert(Connections, DragConnection2)
		table.insert(Connections, DragConnection3)
		table.insert(Connections, DragConnection4)
	end

	MakeDraggable(FloatingButton)

	--// 切换 UI
	local ToggleUI = function()
		if IsToggling then
			print("切换被阻止：正在处理")
			return
		end
		IsToggling = true
		print("触发 ToggleUI，当前状态：" .. tostring(Opened))

		if Opened then
			if BlurEnabled then
				local blur = Blurs[Settings.Title]
				if blur and blur.root then
					blur.root.Parent = nil
				end
			end
			Opened = false
			Animations:Close(Window)
			task.wait(0.3)
			Window.Visible = false
			Tween(FloatingButton, 0.25, { Size = UDim2.new(0, 40, 0, 40), BackgroundTransparency = 0.5 })
			Tween(FloatIcon, 0.25, { ImageTransparency = 0.5 })
			Tween(Stroke, 0.25, { Transparency = 0.5 })
			Tween(ActiveTabLabel, 0.25, { TextTransparency = 1 })
			Tween(ActiveComponentsLabel, 0.25, { TextTransparency = 1 }) -- [新增]
		else
			Window.Visible = true
			Animations:Open(Window, Setup.Transparency)
			Opened = true
			if BlurEnabled then
				local blur = Blurs[Settings.Title]
				if blur and not blur.root.Parent then
					blur.root.Parent = workspace.CurrentCamera
				end
			end
			Tween(FloatingButton, 0.25, { Size = UDim2.new(0, 50, 0, 50), BackgroundTransparency = Setup.Transparency })
			Tween(FloatIcon, 0.25, { ImageTransparency = Setup.Transparency })
			Tween(Stroke, 0.25, { Transparency = Setup.Transparency })
			Tween(ActiveTabLabel, 0.25, { TextTransparency = Setup.Transparency })
			Tween(ActiveComponentsLabel, 0.25, { TextTransparency = Setup.Transparency }) -- [新增]
		end

		task.spawn(function()
			task.wait(0.4)
			IsToggling = false
			print("ToggleUI 完成，IsToggling 重置")
		end)
	end

	--// 绑定浮动按钮交互
	local lastClickTime = 0
	local clickDelay = 0.4
	local isProcessingTouch = false

	local FloatClickConnection = Connect(FloatingButton.InputBegan, function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not IsDragging then
			local currentTime = tick()
			if currentTime - lastClickTime > clickDelay then
				lastClickTime = currentTime
				print("点击 FloatingButton，触发切换")
				ToggleUI()
			end
		end
	end)
	table.insert(Connections, FloatClickConnection)

	local FloatTouchConnection = Connect(Services.Input.InputEnded, function(Input)
		if Input.UserInputType == Enum.UserInputType.Touch and not Type and not isProcessingTouch then
			local currentTime = tick()
			if currentTime - DragStarted < 0.1 and currentTime - lastClickTime > clickDelay then
				isProcessingTouch = true
				local TouchPos = Input.Position
				local ButtonPos = FloatingButton.AbsolutePosition
				local ButtonSize = FloatingButton.AbsoluteSize
				if TouchPos.X >= ButtonPos.X and TouchPos.X <= ButtonPos.X + ButtonSize.X and
				   TouchPos.Y >= ButtonPos.Y and TouchPos.Y <= ButtonPos.Y + ButtonSize.Y then
					lastClickTime = currentTime
					print("触摸 FloatingButton，触发切换")
					ToggleUI()
				end
				task.wait(0.4)
				isProcessingTouch = false
			end
		end
	end)
	table.insert(Connections, FloatTouchConnection)
	Animations:Component(FloatingButton, true)

	local KeybindConnection = Services.Input.InputBegan:Connect(function(Input, Focused) 
		if Input.KeyCode == Setup.Keybind and not Focused then
			print("快捷键触发切换")
			ToggleUI()
		end
	end)
	table.insert(Connections, KeybindConnection)

	--// [新增] 更新 ActiveComponentsLabel 的函数
	local function UpdateActiveComponentsLabel()
		local components = {}
		for name, data in pairs(StoredInfo.ActiveComponents) do
			if data.type == "Slider" then
				table.insert(components, name .. ": " .. data.value)
			else
				table.insert(components, name)
			end
		end
		ActiveComponentsLabel.Text = table.concat(components, ", ")
	end

	--// Tab Functions
	function Options:SetTab(Name: string)
		StoredInfo.CurrentTab = Name -- [新增] 更新当前选项卡
		StoredInfo.ActiveComponents = {} -- [新增] 清空当前选项卡的活跃组件
		UpdateActiveComponentsLabel() -- [新增] 更新标签

		for Index, Button in next, Tab:GetChildren() do
			if Button:IsA("TextButton") then
				local Opened, SameName = Button.Value, (Button.Name == Name)
				local Padding = Button:FindFirstChildOfClass("UIPadding")
				if SameName and not Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 25) })
					Tween(Button, .25, { BackgroundTransparency = 0.9, Size = UDim2.new(1, -15, 0, 30) })
					SetProperty(Opened, { Value = true })
				elseif not SameName and Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 20) })
					Tween(Button, .25, { BackgroundTransparency = 1, Size = UDim2.new(1, -44, 0, 30) })
					SetProperty(Opened, { Value = false })
				end
			end
		end

		for Index, Main in next, Holder:GetChildren() do
			if Main:IsA("CanvasGroup") then
				local Opened, SameName = Main.Value, (Main.Name == Name)
				local Scroll = Main:FindFirstChild("ScrollingFrame")
				if SameName and not Opened.Value then
					Opened.Value = true
					Main.Visible = true
					Tween(Main, .3, { GroupTransparency = 0 })
					Tween(Scroll["UIPadding"], .3, { PaddingTop = UDim.new(0, 5) })
					ActiveTabLabel.Text = Name
				elseif not SameName and Opened.Value then
					Opened.Value = false
					Tween(Main, .15, { GroupTransparency = 1 })
					Tween(Scroll["UIPadding"], .15, { PaddingTop = UDim.new(0, 15) })	
					task.delay(.2, function()
						Main.Visible = false
					end)
				end
			end
		end
	end

	function Options:AddTabSection(Settings: { Name: string, Order: number })
		local Example = Examples["SectionExample"]
		local Section = Clone(Example)
		StoredInfo.Sections[Settings.Name] = Settings.Order
		SetProperty(Section, { 
			Parent = Example.Parent,
			Text = Settings.Name,
			Name = Settings.Name,
			LayoutOrder = Settings.Order,
			Visible = true
		})
	end

	function Options:AddTab(Settings: { Title: string, Icon: string, Section: string? })
		if StoredInfo.Tabs[Settings.Title] then 
			warn("[UI LIB]: 标签 '" .. Settings.Title .. "' 已存在")
			return nil
		end 

		local Example, MainExample = Examples["TabButtonExample"], Examples["MainExample"]
		local Section = StoredInfo.Sections[Settings.Section]
		local Main = Clone(MainExample)
		local Tab = Clone(Example)

		if not Settings.Icon then
			Destroy(Tab["ICO"])
		else
			SetProperty(Tab["ICO"], { Image = Settings.Icon })
		end

		StoredInfo.Tabs[Settings.Title] = { Tab }
		SetProperty(Tab["TextLabel"], { Text = Settings.Title })
		SetProperty(Main, { Parent = MainExample.Parent, Name = Settings.Title })
		SetProperty(Tab, { 
			Parent = Example.Parent,
			LayoutOrder = Section or #StoredInfo.Sections + 1,
			Name = Settings.Title,
			Visible = true
		})

		local TabConnection = Tab.MouseButton1Click:Connect(function()
			Options:SetTab(Tab.Name)
		end)
		table.insert(Connections, TabConnection)

		if not next(StoredInfo.Tabs) then
			ActiveTabLabel.Text = Settings.Title
		end

		return Main.ScrollingFrame
	end
	
	function Options:Notify(Settings: { Title: string, Description: string, Duration: number }) 
		local Notification = Clone(Components["Notification"])
		local Title, Description = Options:GetLabels(Notification)
		local Timer = Notification["Timer"]
		
		SetProperty(Title, { Text = Settings.Title })
		SetProperty(Description, { Text = Settings.Description })
		SetProperty(Notification, { Parent = Screen["Frame"] })
		
		task.spawn(function() 
			local Duration = Settings.Duration or 2
			Animations:Open(Notification, Setup.Transparency, true)
			Tween(Timer, Duration, { Size = UDim2.new(0, 0, 0, 4) })
			task.wait(Duration)
			Animations:Close(Notification)
			task.wait(1)
			Notification:Destroy()
		end)
	end

	function Options:GetLabels(Component)
		local Labels = Component:FindFirstChild("Labels")
		return Labels.Title, Labels.Description
	end

	function Options:AddSection(Settings: { Name: string, Tab: Instance }) 
		local Section = Clone(Components["Section"])
		SetProperty(Section, {
			Text = Settings.Name,
			Parent = Settings.Tab,
			Visible = true,
		})
	end
	
	function Options:AddButton(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Button = Clone(Components["Button"])
		local Title, Description = Options:GetLabels(Button)

		local ButtonConnection = Connect(Button.MouseButton1Click, function()
			if StoredInfo.CurrentTab == Button.Parent.Parent.Parent.Name then -- 确保在当前选项卡
				StoredInfo.ActiveComponents[Settings.Title] = { type = "Button" }
				UpdateActiveComponentsLabel()
				task.spawn(function()
					task.wait(0.5)
					StoredInfo.ActiveComponents[Settings.Title] = nil
					UpdateActiveComponentsLabel()
				end)
			end
			Settings.Callback()
		end)
		Animations:Component(Button)
		SetProperty(Title, { Text = Settings.Title })
		SetProperty(Description, { Text = Settings.Description })
		SetProperty(Button, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
		table.insert(Connections, ButtonConnection)
	end

	function Options:AddInput(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Input = Clone(Components["Input"])
		local Title, Description = Options:GetLabels(Input)
		local TextBox = Input["Main"]["Input"]

		local InputClickConnection = Connect(Input.MouseButton1Click, function() 
			TextBox:CaptureFocus()
		end)
		local InputFocusConnection = Connect(TextBox.FocusLost, function() 
			Settings.Callback(TextBox.Text)
		end)

		Animations:Component(Input)
		SetProperty(Title, { Text = Settings.Title })
		SetProperty(Description, { Text = Settings.Description })
		SetProperty(Input, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
		table.insert(Connections, InputClickConnection)
		table.insert(Connections, InputFocusConnection)
	end

	function Options:AddToggle(Settings: { Title: string, Description: string, Default: boolean, Tab: Instance, Callback: any }) 
		local Toggle = Clone(Components["Toggle"])
		local Title, Description = Options:GetLabels(Toggle)
		local On = Toggle["Value"]
		local Main = Toggle["Main"]
		local Circle = Main["Circle"]
		
		local Set = function(Value)
			if Value then
				Tween(Main, .2, { BackgroundColor3 = Color3.fromRGB(153, 155, 255) })
				Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) })
				if StoredInfo.CurrentTab == Toggle.Parent.Parent.Parent.Name then
					StoredInfo.ActiveComponents[Settings.Title] = { type = "Toggle" }
					UpdateActiveComponentsLabel()
				end
			else
				Tween(Main, .2, { BackgroundColor3 = Theme.Interactables })
				Tween(Circle, .2, { BackgroundColor3 = Theme.Primary, Position = UDim2.new(0, 3, 0.5, 0) })
				StoredInfo.ActiveComponents[Settings.Title] = nil
				UpdateActiveComponentsLabel()
			end
			On.Value = Value
		end 

		local ToggleConnection = Connect(Toggle.MouseButton1Click, function()
			local Value = not On.Value
			Set(Value)
			Settings.Callback(Value)
		end)

		Animations:Component(Toggle)
		Set(Settings.Default)
		SetProperty(Title, { Text = Settings.Title })
		SetProperty(Description, { Text = Settings.Description })
		SetProperty(Toggle, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
		table.insert(Connections, ToggleConnection)
	end
	
	function Options:AddKeybind(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Dropdown = Clone(Components["Keybind"])
		local Title, Description = Options:GetLabels(Dropdown)
		local Bind = Dropdown["Main"].Options
		
		local Mouse = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3 }
		local Types = { 
			["Mouse"] = "Enum.UserInputType.MouseButton", 
			["Key"] = "Enum.KeyCode." 
		}
		
		local KeybindConnection = Connect(Dropdown.MouseButton1Click, function()
			local Detect, Finished
			SetProperty(Bind, { Text = "..." })
			Detect = Connect(game.UserInputService.InputBegan, function(Key, Focused) 
				local InputType = Key.UserInputType
				if not Finished and not Focused then
					Finished = true
					if table.find(Mouse, InputType) then
						Settings.Callback(Key)
						SetProperty(Bind, { Text = tostring(InputType):gsub(Types.Mouse, "MB") })
					elseif InputType == Enum.UserInputType.Keyboard then
						Settings.Callback(Key)
						SetProperty(Bind, { Text = tostring(Key.KeyCode):gsub(Types.Key, "") })
					end
				end 
			end)
			table.insert(Connections, Detect)
		end)

		Animations:Component(Dropdown)
		SetProperty(Title, { Text = Settings.Title })
		SetProperty(Description, { Text = Settings.Description })
		SetProperty(Dropdown, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
		table.insert(Connections, KeybindConnection)
	end

	function Options:AddDropdown(Settings: { Title: string, Description: string, Options: {}, Tab: Instance, Callback: any }) 
		local Dropdown = Clone(Components["Dropdown"])
		local Title, Description = Options:GetLabels(Dropdown)
		local Text = Dropdown["Main"].Options

		local DropdownConnection = Connect(Dropdown.MouseButton1Click, function()
			local Example = Clone(Examples["DropdownExample"])
			local Buttons = Example["Top"]["Buttons"]

			Tween(BG, .25, { BackgroundTransparency = 0.6 })
			SetProperty(Example, { Parent = Window })
			Animations:Open(Example, 0, true)

			for Index, Button in next, Buttons:GetChildren() do
				if Button:IsA("TextButton") then
					Animations:Component(Button, true)
					local ButtonConnection = Connect(Button.MouseButton1Click, function()
						Tween(BG, .25, { BackgroundTransparency = 1 })
						Animations:Close(Example)
						task.wait(2)
						Destroy(Example)
					end)
					table.insert(Connections, ButtonConnection)
				end
			end

			for Index, Option in next, Settings.Options do
				local Button = Clone(Examples["DropdownButtonExample"])
				local Title, Description = Options:GetLabels(Button)
				local Selected = Button["Value"]

				Animations:Component(Button)
				SetProperty(Title, { Text = Index })
				SetProperty(Button, { Parent = Example.ScrollingFrame, Visible = true })
				Destroy(Description)

				local OptionConnection = Connect(Button.MouseButton1Click, function() 
					local NewValue = not Selected.Value 
					if NewValue then
						Tween(Button, .25, { BackgroundColor3 = Theme.Interactables })
						Settings.Callback(Option)
						Text.Text = Index
						for _, Others in next, Example:GetChildren() do
							if Others:IsA("TextButton") and Others ~= Button then
								Others.BackgroundColor3 = Theme.Component
							end
						end
					else
						Tween(Button, .25, { BackgroundColor3 = Theme.Component })
					end
					Selected.Value = NewValue
					Tween(BG, .25, { BackgroundTransparency = 1 })
					Animations:Close(Example)
					task.wait(2)
					Destroy(Example)
				end)
				table.insert(Connections, OptionConnection)
			end
		end)

		Animations:Component(Dropdown)
		SetProperty(Title, { Text = Settings.Title })
		SetProperty(Description, { Text = Settings.Description })
		SetProperty(Dropdown, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
		table.insert(Connections, DropdownConnection)
	end

	function Options:AddSlider(Settings: { Title: string, Description: string, MaxValue: number, AllowDecimals: boolean, DecimalAmount: number, Tab: Instance, Callback: any }) 
		local Slider = Clone(Components["Slider"])
		local Title, Description = Options:GetLabels(Slider)
		local Main = Slider["Slider"]
		local Amount = Main["Main"].Input
		local Slide = Main["Slide"]
		local Fire = Slide["Fire"]
		local Fill = Slide["Highlight"]
		local Circle = Fill["Circle"]

		-- [新增] 为滑块添加值标签
		local SliderValueLabel = Instance.new("TextLabel")
		SliderValueLabel.Name = "SliderValueLabel"
		SliderValueLabel.Parent = Slider
		SliderValueLabel.Size = UDim2.new(0, 50, 0, 20)
		SliderValueLabel.Position = UDim2.new(1, 10, 0.5, 0)
		SliderValueLabel.BackgroundTransparency = 1
		SliderValueLabel.Text = "0"
		SliderValueLabel.TextColor3 = Theme.Title
		SliderValueLabel.TextSize = 12
		SliderValueLabel.Font = Enum.Font.SourceSans
		SliderValueLabel.TextTransparency = Setup.Transparency
		SliderValueLabel.TextXAlignment = Enum.TextXAlignment.Left
		SliderValueLabel.ZIndex = 5
		SliderValueLabel.Visible = true

		local Active = false
		local Value = 0
		
		local SetNumber = function(Number)
			if Settings.AllowDecimals then
				local Power = 10 ^ (Settings.DecimalAmount or 2)
				Number = math.floor(Number * Power + 0.5) / Power
			else
				Number = math.round(Number)
			end
			return Number
		end

		local Update = function(Number)
			local Scale = (Player.Mouse.X - Slide.AbsolutePosition.X) / Slide.AbsoluteSize.X			
			Scale = (Scale > 1 and 1) or (Scale < 0 and 0) or Scale
			if Number then
				Number = (Number > Settings.MaxValue and Settings.MaxValue) or (Number < 0 and 0) or Number
			end
			Value = SetNumber(Number or (Scale * Settings.MaxValue))
			Amount.Text = Value
			Fill.Size = UDim2.fromScale((Number and Number / Settings.MaxValue) or Scale, 1)
			SliderValueLabel.Text = tostring(Value) -- [新增] 更新滑块值标签
			if StoredInfo.CurrentTab == Slider.Parent.Parent.Parent.Name then
				StoredInfo.ActiveComponents[Settings.Title] = { type = "Slider", value = Value } -- [新增] 更新活跃组件
				UpdateActiveComponentsLabel()
			end
			Settings.Callback(Value)
		end

		local Activate = function()
			Active = true
			repeat task.wait()
				Update()
			until not Active
		end
		
		local AmountConnection = Connect(Amount.FocusLost, function() 
			Update(tonumber(Amount.Text) or 0)
		end)
		local FireConnection = Connect(Fire.MouseButton1Down, Activate)
		local EndConnection = Connect(Services.Input.InputEnded, function(Input) 
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Active = false
			end
		end)

		Fill.Size = UDim2.fromScale(Value, 1)
		Animations:Component(Slider)
		SetProperty(Title, { Text = Settings.Title })
		SetProperty(Description, { Text = Settings.Description })
		SetProperty(Slider, {
			Name = Settings.Title,
			Parent = Settings.Tab,
			Visible = true,
		})
		table.insert(Connections, AmountConnection)
		table.insert(Connections, FireConnection)
		table.insert(Connections, EndConnection)
	end

	function Options:AddParagraph(Settings: { Title: string, Description: string, Tab: Instance }) 
		local Paragraph = Clone(Components["Paragraph"])
		local Title, Description = Options:GetLabels(Paragraph)
		SetProperty(Title, { Text = Settings.Title })
		SetProperty(Description, { Text = Settings.Description })
		SetProperty(Paragraph, { Parent = Settings.Tab, Visible = true })
	end

	local Themes = {
		Names = {	
			["Paragraph"] = function(Label)
				if Label:IsA("TextButton") then
					Label.BackgroundColor3 = Color(Theme.Component, 5, "Dark")
				end
			end,
			["Title"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				end
			end,
			["Description"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Description
				end
			end,
			["Section"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				end
			end,
			["Options"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
				end
			end,
			["Notification"] = function(Label)
				if Label:IsA("CanvasGroup") then
					Label.BackgroundColor3 = Theme.Primary
					Label.UIStroke.Color = Theme.Outline
				end
			end,
			["TextLabel"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent:FindFirstChild("List") then
					Label.TextColor3 = Theme.Tab
				end
			end,
			["Main"] = function(Label)
				if Label:IsA("Frame") then
					if Label.Parent == Window then
						Label.BackgroundColor3 = Theme.Secondary
					elseif Label.Parent:FindFirstChild("Value") then
						local Toggle = Label.Parent.Value 
						local Circle = Label:FindFirstChild("Circle")
						if not Toggle.Value then
							Label.BackgroundColor3 = Theme.Interactables
							Label.Circle.BackgroundColor3 = Theme.Primary
						end
					else
						Label.BackgroundColor3 = Theme.Interactables
					end
				elseif Label:FindFirstChild("Padding") then
					Label.TextColor3 = Theme.Title
				end
			end,
			["Amount"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Interactables
				end
			end,
			["Slide"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Interactables
				end
			end,
			["Input"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				elseif Label:FindFirstChild("Labels") then
					Label.BackgroundColor3 = Theme.Component
				elseif Label:IsA("TextBox") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
				end
			end,
			["Outline"] = function(Stroke)
				if Stroke:IsA("UIStroke") then
					Stroke.Color = Theme.Outline
					Stroke.Transparency = Setup.Transparency
				end
			end,
			["DropdownExample"] = function(Label)
				Label.BackgroundColor3 = Theme.Secondary
			end,
			["Underline"] = function(Label)
				if Label:IsA("Frame") then
					Label.BackgroundColor3 = Theme.Outline
				end
			end,
			["TitleBar"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
				end
			end,
			["ToggleUIFloatingButton"] = function(Button)
				if Button:IsA("TextButton") then
					Button.BackgroundColor3 = Theme.Interactables
					local Icon = Button:FindFirstChild("Icon")
					if Icon then
						Icon.ImageColor3 = Theme.Title
						Icon.ImageTransparency = Setup.Transparency
					end
				end
			end,
			["ActiveTabLabel"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
					Label.TextTransparency = Setup.Transparency
				end
			end,
			["ActiveComponentsLabel"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
					Label.TextTransparency = Setup.Transparency
				end
			end,
			["SliderValueLabel"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
					Label.TextTransparency = Setup.Transparency
				end
			end,
		},
		Classes = {
			["ImageLabel"] = function(Label)
				if Label.Image ~= "rbxassetid://6644618143" then
					Label.ImageColor3 = Theme.Icon
				end
			end,
			["TextLabel"] = function(Label)
				if Label:FindFirstChild("Padding") then
					Label.TextColor3 = Theme.Title
				end
			end,
			["TextButton"] = function(Label)
				if Label:FindFirstChild("Labels") then
					Label.BackgroundColor3 = Theme.Component
				end
			end,
			["ScrollingFrame"] = function(Label)
				Label.ScrollBarImageColor3 = Theme.Component
			end,
		},
	}

	function Options:SetTheme(Info)
		Theme = Info or Theme
		Window.BackgroundColor3 = Theme.Primary
		Holder.BackgroundColor3 = Theme.Secondary
		Window.UIStroke.Color = Theme.Shadow

		for Index, Descendant in next, Screen:GetDescendants() do
			local Name, Class = Themes.Names[Descendant.Name], Themes.Classes[Descendant.ClassName]
			if Name then
				Name(Descendant)
			elseif Class then
				Class(Descendant)
			end
		end
	end

	function Options:SetSetting(Setting, Value)
		if Setting == "Size" then
			Window.Size = Value
			Setup.Size = Value
		elseif Setting == "Transparency" then
			Window.GroupTransparency = Value
			Setup.Transparency = Value
			for Index, Notification in next, Screen:GetDescendants() do
				if Notification:IsA("CanvasGroup") and Notification.Name == "Notification" then
					Notification.GroupTransparency = Value
				end
			end
			FloatingButton.BackgroundTransparency = Value
			FloatIcon.ImageTransparency = Value
			Stroke.Transparency = Value
			if ActiveTabLabel then
				ActiveTabLabel.TextTransparency = Value
			end
			if ActiveComponentsLabel then
				ActiveComponentsLabel.TextTransparency = Value
			end
			-- [新增] 更新滑块值标签的透明度
			for _, descendant in pairs(Screen:GetDescendants()) do
				if descendant.Name == "SliderValueLabel" and descendant:IsA("TextLabel") then
					descendant.TextTransparency = Value
				end
			end
		elseif Setting == "Blur" then
			local AlreadyBlurred, Root = Blurs[Settings.Title]
			if AlreadyBlurred then
				Root = Blurs[Settings.Title]["root"]
			end
			if Value and Blur then
				BlurEnabled = true
				if not AlreadyBlurred or not Root then
					Blurs[Settings.Title] = Blur.new(Window, 5)
				elseif Root and not Root.Parent then
					Root.Parent = workspace.CurrentCamera
				end
			elseif not Value and (AlreadyBlurred and Root and Root.Parent) then
				Root.Parent = nil
				BlurEnabled = false
			end
		elseif Setting == "Theme" and typeof(Value) == "table" then
			Options:SetTheme(Value)
		elseif Setting == "Keybind" then
			Setup.Keybind = Value
		else
			warn("Tried to change a setting that doesn't exist or isn't available to change.")
		end
	end

	function Options:Destroy()
		for _, Connection in ipairs(Connections) do
			pcall(function() Connection:Disconnect() end)
		end
		Connections = {}
		if Blurs[Settings.Title] then
			Blurs[Settings.Title].root.Parent = nil
			Blurs[Settings.Title] = nil
		end
		for _, descendant in pairs(Screen:GetDescendants()) do
			pcall(function() descendant:Destroy() end)
		end
		Screen:Destroy()
		FloatingButton:Destroy()
		if ActiveTabLabel then
			ActiveTabLabel:Destroy()
		end
		if ActiveComponentsLabel then
			ActiveComponentsLabel:Destroy()
		end
	end

	SetProperty(Window, { Size = Settings.Size, Visible = true, Parent = Screen })
	Animations:Open(Window, Settings.Transparency or 0)

	return Options
end

return Library
