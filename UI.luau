--[=[
]=]

--// Connections
local GetService = game.GetService
local Connect = game.Loaded.Connect
local Wait = game.Loaded.Wait
local Clone = game.Clone 
local Destroy = game.Destroy 

if not game:IsLoaded() then
	local Loaded = game.Loaded
	Loaded.Wait(Loaded)
end

--// Important 
local Setup = {
	Keybind = Enum.KeyCode.LeftControl,
	Transparency = 0.2,
	ThemeMode = "Dark",
	Size = nil,
	ShowFeatureStatus = true, -- 控制功能状态显示的开关
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
	warn("Failed to load UI asset, creating basic ScreenGui")
	Screen = Instance.new("ScreenGui")
	Screen.Name = "UILibrary"
end

local success, Blur = pcall(function()
	if identifyexecutor then
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/lates-lib/main/Assets/Blur.lua"))()
	else
		return require(script.Blur)
	end
end)
if not success then
	warn("Failed to load Blur")
	Blur = nil
end

Screen.Main = Screen:FindFirstChild("Main") or Instance.new("CanvasGroup", Screen)
Screen.Main.Name = "Main"
Screen.Main.Visible = false

xpcall(function()
	Screen.Parent = game.CoreGui
end, function() 
	Screen.Parent = Player.GUI
end)

--// Tables for Data
local Animations = {}
local Blurs = {}
local Components = Screen:FindFirstChild("Components") or Instance.new("Folder", Screen)
Components.Name = "Components"
local Library = {}
local StoredInfo = {
	Sections = {},
	Tabs = {},
	ActiveFeatures = {}, -- 存储当前激活的功能
	FeatureStatusContainer = nil, -- 功能状态容器
}

--// 默认 Toggle 模板（如果缺失则创建）
local function CreateDefaultToggleTemplate()
	local Toggle = Instance.new("TextButton")
	Toggle.Name = "Toggle"
	Toggle.Size = UDim2.new(1, 0, 0, 50)
	Toggle.BackgroundColor3 = Theme.Component
	Toggle.BackgroundTransparency = Setup.Transparency
	Toggle.BorderSizePixel = 0
	Toggle.AutoButtonColor = false

	local Labels = Instance.new("Frame")
	Labels.Name = "Labels"
	Labels.Size = UDim2.new(0.8, 0, 1, 0)
	Labels.BackgroundTransparency = 1
	Labels.Parent = Toggle

	local Title = Instance.new("TextLabel")
	Title.Name = "Title"
	Title.Size = UDim2.new(1, 0, 0, 20)
	Title.Position = UDim2.new(0, 5, 0, 5)
	Title.BackgroundTransparency = 1
	Title.TextColor3 = Theme.Title
	Title.TextSize = 16
	Title.Font = Enum.Font.SourceSansBold
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Labels

	local Description = Instance.new("TextLabel")
	Description.Name = "Description"
	Description.Size = UDim2.new(1, 0, 0, 20)
	Description.Position = UDim2.new(0, 5, 0, 25)
	Description.BackgroundTransparency = 1
	Description.TextColor3 = Theme.Description
	Description.TextSize = 14
	Description.Font = Enum.Font.SourceSans
	Description.TextXAlignment = Enum.TextXAlignment.Left
	Description.Parent = Labels

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 40, 0, 20)
	Main.Position = UDim2.new(1, -45, 0.5, -10)
	Main.BackgroundColor3 = Theme.Interactables
	Main.BorderSizePixel = 0
	Main.Parent = Toggle

	local Circle = Instance.new("Frame")
	Circle.Name = "Circle"
	Circle.Size = UDim2.new(0, 14, 0, 14)
	Circle.Position = UDim2.new(0, 3, 0.5, -7)
	Circle.BackgroundColor3 = Theme.Primary
	Circle.BorderSizePixel = 0
	Circle.Parent = Main
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 7)
	Corner.Parent = Circle

	local Value = Instance.new("BoolValue")
	Value.Name = "Value"
	Value.Value = false
	Value.Parent = Toggle

	Toggle.Parent = Components
	print("Created default Toggle template")
	return Toggle
end

if not Components:FindFirstChild("Toggle") then
	CreateDefaultToggleTemplate()
end

--// Animations [Window]
function Animations:Open(Window: CanvasGroup, Transparency: number, UseCurrentSize: boolean)
	local Original = UseCurrentSize and Window.Size or Setup.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")

	if Shadow then
		SetProperty(Shadow, { Transparency = 1 })
	end
	SetProperty(Window, { Size = Multiplied, GroupTransparency = 1, Visible = true })
	if Shadow then
		Tween(Shadow, .25, { Transparency = 0.5 })
	end
	Tween(Window, .25, { Size = Original, GroupTransparency = Transparency or 0 })
end

function Animations:Close(Window: CanvasGroup)
	local Original = Window.Size
	local Multiplied = Multiply(Original, 1.1)
	local Shadow = Window:FindFirstChildOfClass("UIStroke")

	SetProperty(Window, { Size = Original })
	if Shadow then
		Tween(Shadow, .25, { Transparency = 1 })
	end
	Tween(Window, .25, { Size = Multiplied, GroupTransparency = 1 })
	task.wait(.25)
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

--// 功能状态显示功能（从 APbeGUI 集成）
function Library:CreateFeatureStatusContainer()
	if StoredInfo.FeatureStatusContainer then
		StoredInfo.FeatureStatusContainer:Destroy()
	end

	local Container = Instance.new("Frame")
	Container.Name = "FeatureStatusContainer"
	Container.Size = UDim2.new(0, 150, 0, 0)
	Container.Position = UDim2.new(1, -170, 0, 20)
	Container.BackgroundTransparency = 1
	Container.BorderSizePixel = 0
	Container.ClipsDescendants = false
	Container.Visible = Setup.ShowFeatureStatus
	Container.Parent = Screen

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ListLayout.FillDirection = Enum.FillDirection.Vertical
	ListLayout.Padding = UDim.new(0, 5)
	ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	ListLayout.Parent = Container

	local function UpdateCorners()
		local children = Container:GetChildren()
		local statusItems = {}
		for _, child in ipairs(children) do
			if child:IsA("TextLabel") then
				table.insert(statusItems, child)
			end
		end

		for _, item in ipairs(statusItems) do
			local corner = item:FindFirstChildOfClass("UICorner")
			if corner then
				corner:Destroy()
			end
		end

		if #statusItems > 0 then
			local lastItem = statusItems[#statusItems]
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 6)
			corner.Parent = lastItem
		end
	end

	Connect(Container.ChildAdded, UpdateCorners)
	Connect(Container.ChildRemoved, UpdateCorners)

	StoredInfo.FeatureStatusContainer = Container
	return Container
end

function Library:AddFeatureStatus(featureName: string)
	if not Setup.ShowFeatureStatus or not StoredInfo.FeatureStatusContainer or StoredInfo.ActiveFeatures[featureName] then
		return nil
	end

	local statusText = Instance.new("TextLabel")
	statusText.Name = "Status_" .. featureName
	statusText.Size = UDim2.new(0, 150, 0, 18)
	statusText.BackgroundColor3 = Theme.Component
	statusText.BackgroundTransparency = Setup.Transparency
	statusText.BorderSizePixel = 0
	statusText.Text = featureName
	statusText.TextColor3 = Theme.Title
	statusText.TextSize = 16
	statusText.Font = Enum.Font.SourceSansBold
	statusText.TextXAlignment = Enum.TextXAlignment.Right
	statusText.TextStrokeTransparency = 0.5
	statusText.TextStrokeColor3 = Theme.Shadow
	statusText.Parent = StoredInfo.FeatureStatusContainer

	statusText.Position = UDim2.new(0, 200, 0, 0)
	Tween(statusText, 0.6, { Position = UDim2.new(0, 0, 0, 0) }, { EasingStyle = Enum.EasingStyle.Back, EasingDirection = Enum.EasingDirection.Out })

	StoredInfo.ActiveFeatures[featureName] = true
	Library:UpdateFeatureStatusContainerSize()

	Library:Notify({
		Title = featureName,
		Description = "功能已开启",
		Duration = 2
	})

	return statusText
end

function Library:RemoveFeatureStatus(featureName: string)
	if not StoredInfo.FeatureStatusContainer then
		return
	end

	local statusText = StoredInfo.FeatureStatusContainer:FindFirstChild("Status_" .. featureName)
	if statusText then
		Tween(statusText, 0.4, {
			Position = UDim2.new(0, 200, 0, 0),
			TextTransparency = 1,
			TextStrokeTransparency = 1,
			BackgroundTransparency = 1
		}, { EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.In })
		task.delay(0.4, function()
			statusText:Destroy()
			StoredInfo.ActiveFeatures[featureName] = nil
			Library:UpdateFeatureStatusContainerSize()
			Library:Notify({
				Title = featureName,
				Description = "功能已关闭",
				Duration = 2
			})
		end)
	end
end

function Library:UpdateFeatureStatusContainerSize()
	if not StoredInfo.FeatureStatusContainer then
		return
	end

	local childCount = #StoredInfo.FeatureStatusContainer:GetChildren() - 1
	local newHeight = math.max(0, childCount * 23 - 5)

	Tween(StoredInfo.FeatureStatusContainer, 0.3, {
		Size = UDim2.new(0, 150, 0, newHeight)
	}, { EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.Out })
end

function Library:ToggleFeatureStatusDisplay(enabled: boolean)
	Setup.ShowFeatureStatus = enabled

	if not StoredInfo.FeatureStatusContainer then
		Library:CreateFeatureStatusContainer()
	end

	local container = StoredInfo.FeatureStatusContainer
	container.Visible = enabled

	if enabled then
		for featureName, _ in pairs(StoredInfo.ActiveFeatures) do
			if not container:FindFirstChild("Status_" .. featureName) then
				Library:AddFeatureStatus(featureName)
			end
		end
	end

	Library:UpdateFeatureStatusContainerSize()
end

--// Library [Window]
function Library:CreateWindow(Settings: { Title: string, Size: UDim2, Transparency: number, MinimizeKeybind: Enum.KeyCode?, Blurring: boolean, Theme: string, FloatingIcon: string? })
	local Window = Instance.new("CanvasGroup")
	Window.Name = "Main"
	Window.Size = Settings.Size or UDim2.new(0, 400, 0, 300)
	Window.Position = UDim2.new(0.5, -200, 0.5, -150)
	Window.BackgroundColor3 = Theme.Primary
	Window.GroupTransparency = Settings.Transparency or 0
	Window.Parent = Screen
	Window.Visible = false

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Theme.Shadow
	Stroke.Thickness = 1
	Stroke.Parent = Window

	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 150, 1, 0)
	Sidebar.BackgroundColor3 = Theme.Secondary
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Window

	local Holder = Instance.new("Frame")
	Holder.Name = "Main"
	Holder.Size = UDim2.new(1, -150, 1, 0)
	Holder.Position = UDim2.new(0, 150, 0, 0)
	Holder.BackgroundColor3 = Theme.Secondary
	Holder.BorderSizePixel = 0
	Holder.Parent = Window

	local BG = Instance.new("Frame")
	BG.Name = "BackgroundShadow"
	BG.Size = UDim2.new(1, 0, 1, 0)
	BG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	BG.BackgroundTransparency = 1
	BG.Parent = Window

	local Tab = Instance.new("Frame")
	Tab.Name = "Tab"
	Tab.Size = UDim2.new(1, 0, 1, -50)
	Tab.Position = UDim2.new(0, 0, 0, 50)
	Tab.BackgroundTransparency = 1
	Tab.Parent = Sidebar

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ListLayout.FillDirection = Enum.FillDirection.Vertical
	ListLayout.Padding = UDim.new(0, 5)
	ListLayout.Parent = Tab

	local Options = {}
	local Examples = {}
	local Opened = true
	local BlurEnabled = false
	local Connections = {}
	local IsToggling = false
	local IsDragging = false
	local DragStarted = 0

	-- 初始化功能状态容器
	Library:CreateFeatureStatusContainer()

	-- Sidebar Top
	local SidebarTop = Instance.new("Frame")
	SidebarTop.Name = "Top"
	SidebarTop.Size = UDim2.new(1, 0, 0, 50)
	SidebarTop.BackgroundTransparency = 1
	SidebarTop.Parent = Sidebar

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

	-- UI Blur & More
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

	-- 浮动按钮
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
	Stroke.Thickness = 1
	Stroke.Transparency = Setup.Transparency
	Stroke.Parent = FloatingButton

	local function MakeDraggable(Button)
		local Dragging, DragInput, Start, StartPosition
		local ScreenSize = game:GetService("GuiService"):GetScreenResolution()

		local DragConnection1 = Connect(Button.InputBegan, function(Input)
			if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not Type then
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
			end
		end)

		table.insert(Connections, DragConnection1)
		table.insert(Connections, DragConnection2)
		table.insert(Connections, DragConnection3)
		table.insert(Connections, DragConnection4)
	end

	MakeDraggable(FloatingButton)

	local ToggleUI = function()
		if IsToggling then
			return
		end
		IsToggling = true

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
		end

		task.spawn(function()
			task.wait(0.4)
			IsToggling = false
		end)
	end

	local lastClickTime = 0
	local clickDelay = 0.4
	local isProcessingTouch = false

	local FloatClickConnection = Connect(FloatingButton.InputBegan, function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not IsDragging then
			local currentTime = tick()
			if currentTime - lastClickTime > clickDelay then
				lastClickTime = currentTime
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
			ToggleUI()
		end
	end)
	table.insert(Connections, KeybindConnection)

	-- Tab Functions
	function Options:SetTab(Name: string)
		print("切换到 Tab: " .. Name)
		for _, Button in ipairs(Tab:GetChildren()) do
			if Button:IsA("TextButton") then
				local Opened = Button:FindFirstChild("Value")
				local SameName = (Button.Name == Name)
				local Padding = Button:FindFirstChildOfClass("UIPadding")
				if SameName and Opened and not Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 25) })
					Tween(Button, .25, { BackgroundTransparency = 0.9, Size = UDim2.new(1, -15, 0, 30) })
					Opened.Value = true
				elseif not SameName and Opened and Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 20) })
					Tween(Button, .25, { BackgroundTransparency = 1, Size = UDim2.new(1, -44, 0, 30) })
					Opened.Value = false
				end
			end
		end

		for _, Main in ipairs(Holder:GetChildren()) do
			if Main:IsA("CanvasGroup") then
				local Opened = Main:FindFirstChild("Value")
				local SameName = (Main.Name == Name)
				local Scroll = Main:FindFirstChild("ScrollingFrame")
				if SameName and Opened and not Opened.Value then
					Opened.Value = true
					Main.Visible = true
					Tween(Main, .3, { GroupTransparency = 0 })
					if Scroll and Scroll:FindFirstChild("UIPadding") then
						Tween(Scroll.UIPadding, .3, { PaddingTop = UDim.new(0, 5) })
					end
				elseif not SameName and Opened and Opened.Value then
					Opened.Value = false
					Tween(Main, .15, { GroupTransparency = 1 })
					if Scroll and Scroll:FindFirstChild("UIPadding") then
						Tween(Scroll.UIPadding, .15, { PaddingTop = UDim.new(0, 15) })
					end
					task.delay(.2, function()
						Main.Visible = false
					end)
				end
			end
		end
	end

	function Options:AddTabSection(Settings: { Name: string, Order: number })
		local Section = Instance.new("TextLabel")
		Section.Name = Settings.Name
		Section.Size = UDim2.new(1, 0, 0, 30)
		Section.BackgroundTransparency = 1
		Section.Text = Settings.Name
		Section.TextColor3 = Theme.Title
		Section.TextSize = 16
		Section.Font = Enum.Font.SourceSansBold
		Section.TextXAlignment = Enum.TextXAlignment.Left
		Section.LayoutOrder = Settings.Order
		Section.Parent = Tab
		Section.Visible = true
		StoredInfo.Sections[Settings.Name] = Settings.Order
		print("添加 Tab 部分: " .. Settings.Name .. ", Order: " .. Settings.Order)
	end

	function Options:AddTab(Settings: { Title: string, Icon: string, Section: string? })
		if StoredInfo.Tabs[Settings.Title] then 
			warn("[UI LIB]: 标签 '" .. Settings.Title .. "' 已存在")
			return nil
		end 

		local TabButton = Instance.new("TextButton")
		TabButton.Name = Settings.Title
		TabButton.Size = UDim2.new(1, -44, 0, 30)
		TabButton.BackgroundColor3 = Theme.Component
		TabButton.BackgroundTransparency = 1
		TabButton.Text = ""
		TabButton.AutoButtonColor = false
		TabButton.LayoutOrder = StoredInfo.Sections[Settings.Section] or (#StoredInfo.Sections + 1)
		TabButton.Parent = Tab
		TabButton.Visible = true

		local TextLabel = Instance.new("TextLabel")
		TextLabel.Name = "TextLabel"
		TextLabel.Size = UDim2.new(1, -20, 1, 0)
		TextLabel.Position = UDim2.new(0, 20, 0, 0)
		TextLabel.BackgroundTransparency = 1
		TextLabel.Text = Settings.Title
		TextLabel.TextColor3 = Theme.Title
		TextLabel.TextSize = 14
		TextLabel.Font = Enum.Font.SourceSans
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel.Parent = TabButton

		local Value = Instance.new("BoolValue")
		Value.Name = "Value"
		Value.Value = false
		Value.Parent = TabButton

		local Padding = Instance.new("UIPadding")
		Padding.PaddingLeft = UDim.new(0, 20)
		Padding.Parent = TabButton

		if Settings.Icon then
			local ICO = Instance.new("ImageLabel")
			ICO.Name = "ICO"
			ICO.Size = UDim2.new(0, 20, 0, 20)
			ICO.Position = UDim2.new(0, 0, 0.5, -10)
			ICO.BackgroundTransparency = 1
			ICO.Image = Settings.Icon
			ICO.ImageColor3 = Theme.Icon
			ICO.Parent = TabButton
		end

		local Main = Instance.new("CanvasGroup")
		Main.Name = Settings.Title
		Main.Size = UDim2.new(1, 0, 1, 0)
		Main.BackgroundColor3 = Theme.Secondary
		Main.GroupTransparency = 1
		Main.Visible = false
		Main.Parent = Holder

		local Scroll = Instance.new("ScrollingFrame")
		Scroll.Name = "ScrollingFrame"
		Scroll.Size = UDim2.new(1, -10, 1, -10)
		Scroll.Position = UDim2.new(0, 5, 0, 5)
		Scroll.BackgroundTransparency = 1
		Scroll.ScrollBarThickness = 4
		Scroll.ScrollBarImageColor3 = Theme.Component
		Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		Scroll.Parent = Main

		local ScrollListLayout = Instance.new("UIListLayout")
		ScrollListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ScrollListLayout.Padding = UDim.new(0, 5)
		ScrollListLayout.Parent = Scroll

		local ScrollPadding = Instance.new("UIPadding")
		ScrollPadding.Name = "UIPadding"
		ScrollPadding.PaddingTop = UDim.new(0, 15)
		ScrollPadding.Parent = Scroll

		local MainValue = Instance.new("BoolValue")
		MainValue.Name = "Value"
		MainValue.Value = false
		MainValue.Parent = Main

		StoredInfo.Tabs[Settings.Title] = { TabButton }
		local TabConnection = TabButton.MouseButton1Click:Connect(function()
			Options:SetTab(Settings.Title)
		end)
		table.insert(Connections, TabConnection)
		print("添加 Tab: " .. Settings.Title .. ", Section: " .. (Settings.Section or "无"))

		-- 默认切换到第一个 Tab
		if #StoredInfo.Tabs == 1 then
			task.wait(0.1)
			Options:SetTab(Settings.Title)
		end

		return Scroll
	end

	-- 其他组件方法（Notify, AddSection, AddButton, AddInput, AddToggle, etc.）保持与之前相同，这里省略以节省空间
	-- ... (请从之前的代码复制 AddNotify, AddSection, AddButton, AddInput, AddToggle, AddKeybind, AddDropdown, AddSlider, AddParagraph, SetTheme, SetSetting, Destroy 方法)

	-- 示例：添加一个简单的 Notify 方法（如果缺失）
	function Options:Notify(Settings: { Title: string, Description: string, Duration: number }) 
		local Notification = Instance.new("CanvasGroup")
		Notification.Name = "Notification"
		Notification.Size = UDim2.new(0, 200, 0, 60)
		Notification.Position = UDim2.new(1, -220, 0, 20)
		Notification.BackgroundColor3 = Theme.Primary
		Notification.GroupTransparency = Setup.Transparency
		Notification.Parent = Screen

		local Title = Instance.new("TextLabel")
		Title.Name = "Title"
		Title.Size = UDim2.new(1, -10, 0.5, 0)
		Title.Position = UDim2.new(0, 5, 0, 5)
		Title.BackgroundTransparency = 1
		Title.Text = Settings.Title
		Title.TextColor3 = Theme.Title
		Title.TextSize = 16
		Title.Font = Enum.Font.SourceSansBold
		Title.Parent = Notification

		local Description = Instance.new("TextLabel")
		Description.Name = "Description"
		Description.Size = UDim2.new(1, -10, 0.5, 0)
		Description.Position = UDim2.new(0, 5, 0.5, 0)
		Description.BackgroundTransparency = 1
		Description.Text = Settings.Description
		Description.TextColor3 = Theme.Description
		Description.TextSize = 14
		Description.Font = Enum.Font.SourceSans
		Description.Parent = Notification

		task.spawn(function() 
			local Duration = Settings.Duration or 2
			Notification.Position = UDim2.new(1, -220, 0, -70)
			Tween(Notification, 0.3, { Position = UDim2.new(1, -220, 0, 20) })
			task.wait(Duration)
			Tween(Notification, 0.3, { Position = UDim2.new(1, -220, 0, -70) })
			task.wait(0.3)
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

		local ButtonConnection = Connect(Button.MouseButton1Click, Settings.Callback)
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
			else
				Tween(Main, .2, { BackgroundColor3 = Theme.Interactables })
				Tween(Circle, .2, { BackgroundColor3 = Theme.Primary, Position = UDim2.new(0, 3, 0.5, 0) })
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
	end

	SetProperty(Window, { Size = Settings.Size, Visible = true, Parent = Screen })
	Animations:Open(Window, Settings.Transparency or 0)

	return Options
end

return Library
