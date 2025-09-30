--[[
	User Interface Library
	Made by Late (Fixed for UI Bugs - Text Garbling & Background Glitch)
]]

--// Connections
local GetService = game.GetService
local Connect = game.Loaded.Connect
local Wait = game.Loaded.Wait
local Clone = game.Clone 
local Destroy = game.Destroy 

if (not game:IsLoaded()) then
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

local Theme = { --// (Dark Theme) - Increased contrast for text
	Primary = Color3.fromRGB(30, 30, 30),
	Secondary = Color3.fromRGB(35, 35, 35),
	Component = Color3.fromRGB(40, 40, 40),
	Interactables = Color3.fromRGB(45, 45, 45),
	Tab = Color3.fromRGB(255, 255, 255), -- 修改：纯白，提高对比度
	Title = Color3.fromRGB(255, 255, 255), -- 修改：纯白，避免乱码
	Description = Color3.fromRGB(200, 200, 200),
	Shadow = Color3.fromRGB(0, 0, 0),
	Outline = Color3.fromRGB(40, 40, 40),
	Icon = Color3.fromRGB(220, 220, 220),
}

--// Services & Functions
local Type, Blur = nil
local LocalPlayer = GetService(game, "Players").LocalPlayer;
local Services = {
	Insert = GetService(game, "InsertService");
	Tween = GetService(game, "TweenService");
	Run = GetService(game, "RunService");
	Input = GetService(game, "UserInputService");
}

local Player = {
	Mouse = LocalPlayer:GetMouse();
	GUI = LocalPlayer.PlayerGui;
}

local Tween = function(Object : Instance, Speed : number, Properties : {},  Info : { EasingStyle: Enum?, EasingDirection: Enum? })
	local Style, Direction
	if Info then
		Style, Direction = Info["EasingStyle"], Info["EasingDirection"]
	else
		Style, Direction = Enum.EasingStyle.Sine, Enum.EasingDirection.Out
	end
	return Services.Tween:Create(Object, TweenInfo.new(Speed, Style, Direction), Properties):Play()
end

local SetProperty = function(Object: Instance, Properties: {})
	for Index, Property in next, Properties do
		Object[Index] = (Property);
	end
	return Object
end

local Multiply = function(Value, Amount)
	local New = {
		Value.X.Scale * Amount;
		Value.X.Offset * Amount;
		Value.Y.Scale * Amount;
		Value.Y.Offset * Amount;
	}
	return UDim2.new(unpack(New))
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
		local Dragging;
		local DragInput;
		local Start;
		local StartPosition;

		local function Update(input)
			local delta = input.Position - Start
			Canvas.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
		end

		Connect(Canvas.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Type then
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
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch and not Type then
				DragInput = Input
			end
		end)

		Connect(Services.Input.InputChanged, function(Input)
			if Input == DragInput and Dragging and not Type then
				Update(Input)
			end
		end)
	end
end

Resizing = { 
	TopLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, -1)};
	TopRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, -1)};
	BottomLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, 1)};
	BottomRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, 1)};
}

Resizeable = function(Tab, Minimum, Maximum)
	task.spawn(function()
		local MousePos, Size, UIPos = nil, nil, nil
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
				local NewPosition = UDim2.new(
					UIPos.X.Scale, 
					UIPos.X.Offset + DeltaAnchorOffset.X * Mode.X.X,
					UIPos.Y.Scale,
					UIPos.Y.Offset + DeltaAnchorOffset.Y * Mode.Y.Y
				)
				Tab.Position = NewPosition
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
if (identifyexecutor) then
	Screen = Services.Insert:LoadLocalAsset("rbxassetid://18490507748");
	pcall(function() -- 修改：添加错误处理，避免 Blur 加载失败
		Blur = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/lates-lib/main/Assets/Blur.lua"))();
	end)
else
	Screen = (script.Parent);
	pcall(function() -- 修改：添加错误处理
		Blur = require(script.Blur)
	end)
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
local Components = (Screen:FindFirstChild("Components"));
local Library = {};
local StoredInfo = {
	["Sections"] = {};
	["Tabs"] = {}
};

--// Animations [Window]
function Animations:Open(Window: CanvasGroup, Transparency: number, UseCurrentSize: boolean)
	local Original = (UseCurrentSize and Window.Size) or Setup.Size
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
			Tween(Component, .25, { ImageTransparency = .85 }); -- 修改：针对 ImageButton
		else
			Tween(Component, .25, { BackgroundColor3 = Color(Theme.Component, 5, Setup.ThemeMode) });
		end
	end)
	Connect(Component.InputEnded, function() 
		if Custom then
			Tween(Component, .25, { ImageTransparency = 0 });
		else
			Tween(Component, .25, { BackgroundColor3 = Theme.Component });
		end
	end)
end

--// Library [Window]
function Library:CreateWindow(Settings: { Title: string, Size: UDim2, Transparency: number, MinimizeKeybind: Enum.KeyCode?, Blurring: boolean, Theme: string })
	local Window = Clone(Screen:WaitForChild("Main"));
	local Sidebar = Window:FindFirstChild("Sidebar");
	local Holder = Window:FindFirstChild("Main");
	local BG = Window:FindFirstChild("BackgroundShadow");
	local Tab = Sidebar:FindFirstChild("Tab");

	local Options = {};
	local Examples = {};
	local Opened = true;
	local Maximized = false;
	local BlurEnabled = false;
	local Connections = {};
	local IsToggling = false;
	local FloatButtonVisible = true;

	for Index, Example in next, Window:GetDescendants() do
		if Example.Name:find("Example") and not Examples[Example.Name] then
			Examples[Example.Name] = Example
		end
	end

	--// UI Blur & More
	Drag(Window);
	Resizeable(Window, Vector2.new(411, 271), Vector2.new(9e9, 9e9));
	Setup.Transparency = Settings.Transparency or 0
	Setup.Size = Settings.Size
	Setup.ThemeMode = Settings.Theme or "Dark"

	-- 修改：默认禁用 Blurring 以避免背景 glitch，允许手动启用
	if Settings.Blurring then
		pcall(function()
			Blurs[Settings.Title] = Blur.new(Window, 5)
			BlurEnabled = true
		end)
	end

	if Settings.MinimizeKeybind then
		Setup.Keybind = Settings.MinimizeKeybind
	end

	-- 修改：创建标题栏（移到最左边）
	local TitleBar = Instance.new("Frame")
	TitleBar.Name = "TitleBar"
	TitleBar.Parent = Window
	TitleBar.BackgroundColor3 = Theme.Primary
	TitleBar.Size = UDim2.new(0, 150, 0, 30)
	TitleBar.Position = UDim2.new(0, 0, 0, 0)
	TitleBar.ZIndex = 5
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Parent = TitleBar
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Size = UDim2.new(1, -80, 1, 0)
	TitleLabel.Position = UDim2.new(0, 10, 0, 0)
	TitleLabel.Text = Settings.Title
	TitleLabel.TextColor3 = Theme.Title
	TitleLabel.TextScaled = true
	TitleLabel.Font = Enum.Font.Gotham -- 修改：使用可靠字体，避免乱码
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left -- 修改：左对齐，提高可读性
	local TitlePadding = Instance.new("UIPadding")
	TitlePadding.Parent = TitleLabel
	TitlePadding.PaddingLeft = UDim.new(0, 10)
	TitlePadding.PaddingRight = UDim.new(0, 10)

	-- 修改：创建关闭按钮（移到右侧）
	local CloseButton = Instance.new("ImageButton")
	CloseButton.Name = "CloseButton"
	CloseButton.Parent = Window
	CloseButton.BackgroundTransparency = 1
	CloseButton.Size = UDim2.new(0, 30, 0, 30)
	CloseButton.Position = UDim2.new(1, -35, 0, 0)
	CloseButton.Image = "rbxassetid://6644618143"
	CloseButton.ImageColor3 = Theme.Icon
	CloseButton.ZIndex = 6
	CloseButton.AutoButtonColor = false

	-- 修改：创建缩小按钮（移到右侧）
	local MinimizeButton = Instance.new("ImageButton")
	MinimizeButton.Name = "MinimizeButton"
	MinimizeButton.Parent = Window
	MinimizeButton.BackgroundTransparency = 1
	MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
	MinimizeButton.Position = UDim2.new(1, -70, 0, 0)
	MinimizeButton.Image = "rbxassetid://6644618143"
	MinimizeButton.ImageColor3 = Theme.Icon
	MinimizeButton.ZIndex = 6
	MinimizeButton.AutoButtonColor = false

	-- 修改：调整布局以适应标题栏，并修复背景
	Holder.Position = UDim2.new(0, 150, 0, 0)
	Holder.Size = UDim2.new(1, -150, 1, 0)
	Holder.BackgroundColor3 = Theme.Secondary -- 修改：强制设置背景色，避免 glitch
	Sidebar.Position = UDim2.new(0, 0, 0, 30)
	Sidebar.Size = UDim2.new(0, 150, 1, -30)
	Sidebar.BackgroundColor3 = Theme.Primary -- 修改：强制设置侧边栏背景，避免乱码覆盖

	-- 创建浮动按钮（使用贴花）
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
	FloatIcon.Size = UDim2.new(0.6, 0, 0.6, 0)
	FloatIcon.Position = UDim2.new(0.2, 0, 0.2, 0)
	FloatIcon.BackgroundTransparency = 1
	FloatIcon.Image = "rbxassetid://6644618143"
	FloatIcon.ImageColor3 = Theme.Icon
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
		local function Update(input)
			local delta = input.Position - Start
			local newX = math.clamp(StartPosition.X.Offset + delta.X, 0, ScreenSize.X - Button.AbsoluteSize.X)
			local newY = math.clamp(StartPosition.Y.Offset + delta.Y, 0, ScreenSize.Y - Button.AbsoluteSize.Y)
			Button.Position = UDim2.new(0, newX, 0, newY)
		end
		local DragConnection1 = Connect(Button.InputBegan, function(Input)
			if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not Type then
				Dragging = true
				Start = Input.Position
				StartPosition = Button.Position
				local DragConnection2 = Connect(Input.Changed, function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
				table.insert(Connections, DragConnection2)
			end
		end)
		local DragConnection3 = Connect(Button.InputChanged, function(Input)
			if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) and not Type then
				DragInput = Input
			end
		end)
		local DragConnection4 = Connect(Services.Input.InputChanged, function(Input)
			if Input == DragInput and Dragging then
				Update(Input)
			end
		end)
		table.insert(Connections, DragConnection1)
		table.insert(Connections, DragConnection3)
		table.insert(Connections, DragConnection4)
	end

	MakeDraggable(FloatingButton)

	local ToggleUI = function()
		if IsToggling then return end
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
			task.wait(0.25)
			Window.Visible = false
			Tween(FloatingButton, 0.25, { Size = UDim2.new(0, 40, 0, 40), BackgroundTransparency = 0.5 })
			Tween(Stroke, 0.25, { Transparency = 0.5 })
			Tween(FloatIcon, 0.25, { ImageTransparency = 0.5 })
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
			Tween(Stroke, 0.25, { Transparency = Setup.Transparency })
			Tween(FloatIcon, 0.25, { ImageTransparency = 0 })
		end
		task.spawn(function()
			task.wait(0.3)
			IsToggling = false
		end)
	end

	local ToggleFloatButton = function()
		FloatButtonVisible = not FloatButtonVisible
		if FloatButtonVisible then
			FloatingButton.Visible = true
			Tween(FloatingButton, 0.25, { Size = UDim2.new(0, 50, 0, 50), BackgroundTransparency = Setup.Transparency })
			Tween(Stroke, 0.25, { Transparency = Setup.Transparency })
			Tween(FloatIcon, 0.25, { ImageTransparency = 0 })
		else
			Tween(FloatingButton, 0.25, { Size = UDim2.new(0, 40, 0, 40), BackgroundTransparency = 0.5 })
			Tween(Stroke, 0.25, { Transparency = 0.5 })
			Tween(FloatIcon, 0.25, { ImageTransparency = 0.5 })
			task.wait(0.25)
			FloatingButton.Visible = false
		end
	end

	local CloseConnection = Connect(CloseButton.MouseButton1Click, ToggleUI)
	local MinimizeConnection = Connect(MinimizeButton.MouseButton1Click, ToggleFloatButton)
	table.insert(Connections, CloseConnection)
	table.insert(Connections, MinimizeConnection)
	Animations:Component(CloseButton, true)
	Animations:Component(MinimizeButton, true)

	local lastClickTime = 0
	local clickDelay = 0.2
	local FloatClickConnection = Connect(FloatingButton.InputBegan, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			local currentTime = tick()
			if currentTime - lastClickTime > clickDelay then
				lastClickTime = currentTime
				ToggleUI()
			end
		end
	end)
	local FloatTouchConnection = Connect(Services.Input.InputEnded, function(Input)
		if Input.UserInputType == Enum.UserInputType.Touch and not Type then
			local TouchPos = Input.Position
			local ButtonPos = FloatingButton.AbsolutePosition
			local ButtonSize = FloatingButton.AbsoluteSize
			if TouchPos.X >= ButtonPos.X and TouchPos.X <= ButtonPos.X + ButtonSize.X and
			   TouchPos.Y >= ButtonPos.Y and TouchPos.Y <= ButtonPos.Y + ButtonSize.Y then
				local currentTime = tick()
				if currentTime - lastClickTime > clickDelay then
					lastClickTime = currentTime
					ToggleUI()
				end
			end
		end
	end)
	table.insert(Connections, FloatClickConnection)
	table.insert(Connections, FloatTouchConnection)
	Animations:Component(FloatingButton, true)

	for Index, Button in next, Sidebar.Top.Buttons:GetChildren() do
		if Button:IsA("TextButton") and Button.Name ~= "Close" then
			local Name = Button.Name
			Animations:Component(Button, true)
			local ButtonConnection = Connect(Button.MouseButton1Click, function() 
				if Name == "Minimize" then
					ToggleUI()
				elseif Name == "Maximize" then
					if Maximized then
						Maximized = false
						Tween(Window, .15, { Size = Setup.Size });
					else
						Maximized = true
						Tween(Window, .15, { Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.5, 0.5 )});
					end
				end
			end)
			table.insert(Connections, ButtonConnection)
		end
	end

	local KeybindConnection = Services.Input.InputBegan:Connect(function(Input, Focused) 
		if Input.KeyCode == Setup.Keybind and not Focused then
			ToggleUI()
		end
	end)
	table.insert(Connections, KeybindConnection)

	--// Tab Functions (修复：强制更新侧边栏文本颜色和字体)
	function Options:SetTab(Name: string)
		for Index, Button in next, Tab:GetChildren() do
			if Button:IsA("TextButton") then
				local Opened, SameName = Button.Value, (Button.Name == Name);
				local Padding = Button:FindFirstChildOfClass("UIPadding");
				local TextLabel = Button:FindFirstChild("TextLabel") -- 修改：强制更新文本
				if TextLabel then
					TextLabel.Font = Enum.Font.Gotham -- 修改：使用可靠字体
					TextLabel.TextColor3 = Theme.Tab -- 修改：强制纯白
				end
				if SameName and not Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 25) });
					Tween(Button, .25, { BackgroundTransparency = 0.9, Size = UDim2.new(1, -15, 0, 30) });
					SetProperty(Opened, { Value = true });
				elseif not SameName and Opened.Value then
					Tween(Padding, .25, { PaddingLeft = UDim.new(0, 20) });
					Tween(Button, .25, { BackgroundTransparency = 1, Size = UDim2.new(1, -44, 0, 30) });
					SetProperty(Opened, { Value = false });
				end
			end
		end
		for Index, Main in next, Holder:GetChildren() do
			if Main:IsA("CanvasGroup") then
				local Opened, SameName = Main.Value, (Main.Name == Name);
				local Scroll = Main:FindFirstChild("ScrollingFrame");
				if SameName and not Opened.Value then
					Opened.Value = true
					Main.Visible = true
					Main.BackgroundColor3 = Theme.Secondary -- 修改：强制背景色
					Tween(Main, .3, { GroupTransparency = 0 });
					Tween(Scroll["UIPadding"], .3, { PaddingTop = UDim.new(0, 5) });
				elseif not SameName and Opened.Value then
					Opened.Value = false
					Tween(Main, .15, { GroupTransparency = 1 });
					Tween(Scroll["UIPadding"], .15, { PaddingTop = UDim.new(0, 15) });	
					task.delay(.2, function()
						Main.Visible = false
					end)
				end
			end
		end
	end

	function Options:AddTabSection(Settings: { Name: string, Order: number })
		local Example = Examples["SectionExample"];
		local Section = Clone(Example);
		StoredInfo["Sections"][Settings.Name] = (Settings.Order);
		SetProperty(Section, { 
			Parent = Example.Parent,
			Text = Settings.Name,
			Name = Settings.Name,
			LayoutOrder = Settings.Order,
			Visible = true
		});
		local TextLabel = Section:FindFirstChild("TextLabel") -- 修改：修复文本
		if TextLabel then
			TextLabel.Font = Enum.Font.Gotham
			TextLabel.TextColor3 = Theme.Title
		end
	end

	function Options:AddTab(Settings: { Title: string, Icon: string, Section: string? })
		if StoredInfo["Tabs"][Settings.Title] then 
			error("[UI LIB]: A tab with the same name has already been created") 
		end 
		local Example, MainExample = Examples["TabButtonExample"], Examples["MainExample"];
		local Section = StoredInfo["Sections"][Settings.Section];
		local Main = Clone(MainExample);
		local Tab = Clone(Example);
		if not Settings.Icon then
			Destroy(Tab["ICO"]);
		else
			SetProperty(Tab["ICO"], { Image = Settings.Icon });
		end
		StoredInfo["Tabs"][Settings.Title] = { Tab }
		SetProperty(Tab["TextLabel"], { Text = Settings.Title });
		SetProperty(Main, { 
			Parent = MainExample.Parent,
			Name = Settings.Title,
			BackgroundColor3 = Theme.Secondary -- 修改：强制背景
		});
		SetProperty(Tab, { 
			Parent = Example.Parent,
			LayoutOrder = Section or #StoredInfo["Sections"] + 1,
			Name = Settings.Title;
			Visible = true;
		});
		local TabText = Tab:FindFirstChild("TextLabel") -- 修改：修复标签文本
		if TabText then
			TabText.Font = Enum.Font.Gotham
			TabText.TextColor3 = Theme.Tab
		end
		local TabConnection = Tab.MouseButton1Click:Connect(function()
			Options:SetTab(Tab.Name);
		end)
		table.insert(Connections, TabConnection)
		return Main.ScrollingFrame
	end
	
	function Options:Notify(Settings: { Title: string, Description: string, Duration: number }) 
		local Notification = Clone(Components["Notification"]);
		local Title, Description = Options:GetLabels(Notification);
		local Timer = Notification["Timer"];
		SetProperty(Title, { Text = Settings.Title });
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Notification, { Parent = Screen["Frame"] })
		task.spawn(function() 
			local Duration = Settings.Duration or 2
			local Wait = task.wait;
			Animations:Open(Notification, Setup.Transparency, true); 
			Tween(Timer, Duration, { Size = UDim2.new(0, 0, 0, 4) });
			Wait(Duration);
			Animations:Close(Notification);
			Wait(1);
			Notification:Destroy();
		end)
	end

	function Options:GetLabels(Component)
		local Labels = Component:FindFirstChild("Labels")
		return Labels.Title, Labels.Description
	end

	function Options:AddSection(Settings: { Name: string, Tab: Instance }) 
		local Section = Clone(Components["Section"]);
		SetProperty(Section, { Text = Settings.Name, Parent = Settings.Tab, Visible = true })
		local TextLabel = Section:FindFirstChild("TextLabel") -- 修改：修复分区文本
		if TextLabel then
			TextLabel.Font = Enum.Font.Gotham
			TextLabel.TextColor3 = Theme.Title
		end
	end
	
	function Options:AddButton(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Button = Clone(Components["Button"]);
		local Title, Description = Options:GetLabels(Button);
		local ButtonConnection = Connect(Button.MouseButton1Click, Settings.Callback)
		Animations:Component(Button)
		SetProperty(Title, { Text = Settings.Title, Font = Enum.Font.Gotham }); -- 修改：字体修复
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Button, { Name = Settings.Title, Parent = Settings.Tab, Visible = true })
		table.insert(Connections, ButtonConnection)
	end

	function Options:AddInput(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Input = Clone(Components["Input"]);
		local Title, Description = Options:GetLabels(Input);
		local TextBox = Input["Main"]["Input"];
		local InputClickConnection = Connect(Input.MouseButton1Click, function() 
			TextBox:CaptureFocus()
		end)
		local InputFocusConnection = Connect(TextBox.FocusLost, function() 
			Settings.Callback(TextBox.Text)
		end)
		Animations:Component(Input)
		SetProperty(Title, { Text = Settings.Title, Font = Enum.Font.Gotham }); -- 修改：字体修复
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Input, { Name = Settings.Title, Parent = Settings.Tab, Visible = true })
		table.insert(Connections, InputClickConnection)
		table.insert(Connections, InputFocusConnection)
	end

	function Options:AddToggle(Settings: { Title: string, Description: string, Default: boolean, Tab: Instance, Callback: any }) 
		local Toggle = Clone(Components["Toggle"]);
		local Title, Description = Options:GetLabels(Toggle);
		local On = Toggle["Value"];
		local Main = Toggle["Main"];
		local Circle = Main["Circle"];
		local Set = function(Value)
			if Value then
				Tween(Main, .2, { BackgroundColor3 = Color3.fromRGB(153, 155, 255) });
				Tween(Circle, .2, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) });
			else
				Tween(Main, .2, { BackgroundColor3 = Theme.Interactables });
				Tween(Circle, .2, { BackgroundColor3 = Theme.Primary, Position = UDim2.new(0, 3, 0.5, 0) });
			end
			On.Value = Value
		end 
		local ToggleConnection = Connect(Toggle.MouseButton1Click, function()
			local Value = not On.Value
			Set(Value)
			Settings.Callback(Value)
		end)
		Animations:Component(Toggle);
		Set(Settings.Default);
		SetProperty(Title, { Text = Settings.Title, Font = Enum.Font.Gotham }); -- 修改：字体修复
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Toggle, { Name = Settings.Title, Parent = Settings.Tab, Visible = true })
		table.insert(Connections, ToggleConnection)
	end
	
	function Options:AddKeybind(Settings: { Title: string, Description: string, Tab: Instance, Callback: any }) 
		local Dropdown = Clone(Components["Keybind"]);
		local Title, Description = Options:GetLabels(Dropdown);
		local Bind = Dropdown["Main"].Options;
		local Mouse = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3 }; 
		local Types = { ["Mouse"] = "Enum.UserInputType.MouseButton", ["Key"] = "Enum.KeyCode." }
		local KeybindConnection = Connect(Dropdown.MouseButton1Click, function()
			local Time = tick();
			local Detect, Finished
			SetProperty(Bind, { Text = "..." });
			Detect = Connect(game.UserInputService.InputBegan, function(Key, Focused) 
				local InputType = (Key.UserInputType);
				if not Finished and not Focused then
					Finished = (true)
					if table.find(Mouse, InputType) then
						Settings.Callback(Key);
						SetProperty(Bind, { Text = tostring(InputType):gsub(Types.Mouse, "MB") })
					elseif InputType == Enum.UserInputType.Keyboard then
						Settings.Callback(Key);
						SetProperty(Bind, { Text = tostring(Key.KeyCode):gsub(Types.Key, "") })
					end
				end 
			end)
			table.insert(Connections, Detect)
		end)
		Animations:Component(Dropdown);
		SetProperty(Title, { Text = Settings.Title, Font = Enum.Font.Gotham }); -- 修改：字体修复
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Dropdown, { Name = Settings.Title, Parent = Settings.Tab, Visible = true })
		table.insert(Connections, KeybindConnection)
	end

	function Options:AddDropdown(Settings: { Title: string, Description: string, Options: {}, Tab: Instance, Callback: any }) 
		local Dropdown = Clone(Components["Dropdown"]);
		local Title, Description = Options:GetLabels(Dropdown);
		local Text = Dropdown["Main"].Options;
		local DropdownConnection = Connect(Dropdown.MouseButton1Click, function()
			local Example = Clone(Examples["DropdownExample"]);
			local Buttons = Example["Top"]["Buttons"];
			Tween(BG, .25, { BackgroundTransparency = 0.6 });
			SetProperty(Example, { Parent = Window, BackgroundColor3 = Theme.Secondary }); -- 修改：强制背景
			Animations:Open(Example, 0, true)
			for Index, Button in next, Buttons:GetChildren() do
				if Button:IsA("TextButton") then
					Animations:Component(Button, true)
					local ButtonConnection = Connect(Button.MouseButton1Click, function()
						Tween(BG, .25, { BackgroundTransparency = 1 });
						Animations:Close(Example);
						task.wait(2)
						Destroy(Example);
					end)
					table.insert(Connections, ButtonConnection)
				end
			end
			for Index, Option in next, Settings.Options do
				local Button = Clone(Examples["DropdownButtonExample"]);
				local Title, Description = Options:GetLabels(Button);
				local Selected = Button["Value"];
				Animations:Component(Button);
				SetProperty(Title, { Text = Index, Font = Enum.Font.Gotham }); -- 修改：字体修复
				SetProperty(Button, { Parent = Example.ScrollingFrame, Visible = true });
				Destroy(Description);
				local OptionConnection = Connect(Button.MouseButton1Click, function() 
					local NewValue = not Selected.Value 
					if NewValue then
						Tween(Button, .25, { BackgroundColor3 = Theme.Interactables });
						Settings.Callback(Option)
						Text.Text = Index
						for _, Others in next, Example:GetChildren() do
							if Others:IsA("TextButton") and Others ~= Button then
								Others.BackgroundColor3 = Theme.Component
							end
						end
					else
						Tween(Button, .25, { BackgroundColor3 = Theme.Component });
					end
					Selected.Value = NewValue
					Tween(BG, .25, { BackgroundTransparency = 1 });
					Animations:Close(Example);
					task.wait(2)
					Destroy(Example);
				end)
				table.insert(Connections, OptionConnection)
			end
		end)
		Animations:Component(Dropdown);
		SetProperty(Title, { Text = Settings.Title, Font = Enum.Font.Gotham }); -- 修改：字体修复
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Dropdown, { Name = Settings.Title, Parent = Settings.Tab, Visible = true })
		table.insert(Connections, DropdownConnection)
	end

	function Options:AddSlider(Settings: { Title: string, Description: string, MaxValue: number, AllowDecimals: boolean, DecimalAmount: number, Tab: Instance, Callback: any }) 
		local Slider = Clone(Components["Slider"]);
		local Title, Description = Options:GetLabels(Slider);
		local Main = Slider["Slider"];
		local Amount = Main["Main"].Input;
		local Slide = Main["Slide"];
		local Fire = Slide["Fire"];
		local Fill = Slide["Highlight"];
		local Circle = Fill["Circle"];
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
		Fill.Size = UDim2.fromScale(Value, 1);
		Animations:Component(Slider);
		SetProperty(Title, { Text = Settings.Title, Font = Enum.Font.Gotham }); -- 修改：字体修复
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Slider, { Name = Settings.Title, Parent = Settings.Tab, Visible = true })
		table.insert(Connections, AmountConnection)
		table.insert(Connections, FireConnection)
		table.insert(Connections, EndConnection)
	end

	function Options:AddParagraph(Settings: { Title: string, Description: string, Tab: Instance }) 
		local Paragraph = Clone(Components["Paragraph"]);
		local Title, Description = Options:GetLabels(Paragraph);
		SetProperty(Title, { Text = Settings.Title, Font = Enum.Font.Gotham }); -- 修改：字体修复
		SetProperty(Description, { Text = Settings.Description });
		SetProperty(Paragraph, { Parent = Settings.Tab, Visible = true })
	end

	local Themes = {
		Names = {	
			["Paragraph"] = function(Label)
				if Label:IsA("TextButton") then
					Label.BackgroundColor3 = Color(Theme.Component, 5, "Dark");
				end
			end,
			["Title"] = function(Label)
				if Label:IsA("TextLabel") then
					Label.TextColor3 = Theme.Title
					Label.Font = Enum.Font.Gotham -- 修改：强制字体
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
					Label.Font = Enum.Font.Gotham -- 修改：强制字体
				end
			end,
			["Options"] = function(Label)
				if Label:IsA("TextLabel") and Label.Parent.Name == "Main" then
					Label.TextColor3 = Theme.Title
					Label.Font = Enum.Font.Gotham -- 修改：强制字体
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
					Label.Font = Enum.Font.Gotham -- 修改：强制字体
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
					Label.Font = Enum.Font.Gotham -- 修改：强制字体
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
		},
		Classes = {
			["ImageLabel"] = function(Label)
				Label.ImageColor3 = Theme.Icon
			end,
			["TextLabel"] = function(Label)
				if Label:FindFirstChild("Padding") then
					Label.TextColor3 = Theme.Title
					Label.Font = Enum.Font.Gotham -- 修改：强制字体
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
		Holder.BackgroundColor3 = Theme.Secondary -- 修改：强制更新背景
		Window.UIStroke.Color = Theme.Shadow
		TitleBar.BackgroundColor3 = Theme.Primary
		CloseButton.ImageColor3 = Theme.Icon
		MinimizeButton.ImageColor3 = Theme.Icon
		FloatingButton.BackgroundColor3 = Theme.Interactables
		FloatIcon.ImageColor3 = Theme.Icon
		-- 修改：强制更新侧边栏和标签
		for _, child in pairs(Sidebar:GetDescendants()) do
			if child:IsA("TextLabel") then
				child.TextColor3 = Theme.Tab
				child.Font = Enum.Font.Gotham
			elseif child:IsA("Frame") then
				child.BackgroundColor3 = Theme.Primary
			end
		end
		for Index, Descendant in next, Screen:GetDescendants() do
			local Name, Class = Themes.Names[Descendant.Name], Themes.Classes[Descendant.ClassName]
			if Name then
				Name(Descendant);
			elseif Class then
				Class(Descendant);
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
			Stroke.Transparency = Value
			FloatIcon.ImageTransparency = FloatButtonVisible and 0 or 0.5
		elseif Setting == "Blur" then
			local AlreadyBlurred, Root = Blurs[Settings.Title], nil
			if AlreadyBlurred then
				Root = Blurs[Settings.Title]["root"]
			end
			if Value then
				BlurEnabled = true
				pcall(function() -- 修改：安全启用 Blur
					if not AlreadyBlurred or not Root then
						Blurs[Settings.Title] = Blur.new(Window, 5)
					elseif Root and not Root.Parent then
						Root.Parent = workspace.CurrentCamera
					end
				end)
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
			Connection:Disconnect()
		end
		Connections = {}
		if Blurs[Settings.Title] then
			Blurs[Settings.Title].root.Parent = nil
			Blurs[Settings.Title] = nil
		end
		Window:Destroy()
		FloatingButton:Destroy()
	end

	SetProperty(Window, { Size = Settings.Size, Visible = true, Parent = Screen });
	Animations:Open(Window, Settings.Transparency or 0)
	return Options
end

return Library
