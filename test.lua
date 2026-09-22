local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("FishCatcherGui")

if oldGui then
	oldGui:Destroy()
end

local assets = ReplicatedStorage:WaitForChild("A__Assets")
local fishFolder = assets:WaitForChild("Fish")
local treasureFolder = assets:WaitForChild("Treasure")

local shared = ReplicatedStorage:WaitForChild("Shared")
local template = shared:WaitForChild("Data"):WaitForChild("Template")

local fishDataModule = template:WaitForChild("Fish")
local treasureDataModule = template:WaitForChild("Treasures")

local packages = ReplicatedStorage:WaitForChild("Packages")
local knitIndex = packages:WaitForChild("_Index")
local knit = knitIndex:WaitForChild("sleitnick_knit@1.7.0")
local knitServices = knit:WaitForChild("knit"):WaitForChild("Services")

local fishService = knitServices:WaitForChild("FishService")
local treasureService = knitServices:WaitForChild("TreasureService")

local addToInventoryRF = fishService
	:WaitForChild("RF")
	:WaitForChild("AddToInventory")

local treasureAddToInventoryRF = treasureService
	:WaitForChild("RF")
	:WaitForChild("AddToInventory")

local THEME = {
	Background = Color3.fromRGB(13, 15, 22),
	Sidebar = Color3.fromRGB(16, 18, 27),
	Panel = Color3.fromRGB(18, 20, 30),
	Card = Color3.fromRGB(27, 30, 42),
	CardHover = Color3.fromRGB(35, 39, 54),
	CardSelected = Color3.fromRGB(39, 44, 62),

	Accent = Color3.fromRGB(0, 185, 255),
	AccentDark = Color3.fromRGB(0, 130, 190),

	Text = Color3.fromRGB(245, 247, 255),
	TextMuted = Color3.fromRGB(130, 136, 153),
	Border = Color3.fromRGB(35, 39, 53),

	Common = Color3.fromRGB(170, 175, 185),
	Rare = Color3.fromRGB(65, 225, 120),
	SuperRare = Color3.fromRGB(70, 190, 255),
	Mythical = Color3.fromRGB(245, 105, 190),
	Legendary = Color3.fromRGB(255, 195, 65),
	NeverSeen = Color3.fromRGB(255, 85, 85),
	Arcana = Color3.fromRGB(90, 195, 120),
	Eternal = Color3.fromRGB(75, 145, 160),
	Apex = Color3.fromRGB(175, 55, 255),
	Unknown = Color3.fromRGB(90, 95, 110)
}

local FONT_REGULAR = Enum.Font.Gotham
local FONT_BOLD = Enum.Font.GothamBold

local RARITY_ORDER = {
	Common = 1,
	Rare = 2,
	SuperRare = 3,
	Mythical = 4,
	Legendary = 5,
	NeverSeen = 6,
	Arcana = 7,
	Eternal = 8,
	Apex = 9
}

local RARITY_DISPLAY = {
	Common = "COMMON",
	Rare = "RARE",
	SuperRare = "SUPER RARE",
	Mythical = "MYTHICAL",
	Legendary = "LEGENDARY",
	NeverSeen = "NEVER SEEN",
	Arcana = "ARCANA",
	Eternal = "ETERNAL",
	Apex = "APEX",
	Unknown = "UNKNOWN"
}

local normalSize = UDim2.new(0, 900, 0, 560)
local minimizedSize = UDim2.new(0, 300, 0, 68)

local currentTab = "Fish"
local isMinimized = false
local dragging = false
local dragStart
local startPosition

local pages = {}
local tabs = {}

local gui = Instance.new("ScreenGui")
gui.Name = "FishCatcherGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = normalSize
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = THEME.Background
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 16)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = THEME.Border
frameStroke.Thickness = 1.5
frameStroke.Parent = frame

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 68)
header.BackgroundTransparency = 1
header.Parent = frame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(0, 350, 0, 30)
title.Position = UDim2.new(0, 25, 0, 10)
title.BackgroundTransparency = 1
title.Text = "🐟  LEVEL1 HUB"
title.TextColor3 = THEME.Text
title.Font = FONT_BOLD
title.TextSize = 21
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Size = UDim2.new(0, 400, 0, 18)
subtitle.Position = UDim2.new(0, 27, 0, 38)
subtitle.BackgroundTransparency = 1
subtitle.Text = "BECOME A DEEP SEA EXPLORER"
subtitle.TextColor3 = THEME.TextMuted
subtitle.Font = FONT_REGULAR
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local dragArea = Instance.new("TextButton")
dragArea.Name = "DragArea"
dragArea.Size = UDim2.new(1, -135, 1, 0)
dragArea.Position = UDim2.new(0, 0, 0, 0)
dragArea.BackgroundTransparency = 1
dragArea.BorderSizePixel = 0
dragArea.Text = ""
dragArea.AutoButtonColor = false
dragArea.ZIndex = 3
dragArea.Parent = header

title.ZIndex = 2
subtitle.ZIndex = 2

local minimize = Instance.new("TextButton")
minimize.Name = "Minimize"
minimize.Size = UDim2.new(0, 34, 0, 34)
minimize.Position = UDim2.new(1, -88, 0, 17)
minimize.BackgroundColor3 = THEME.Card
minimize.BorderSizePixel = 0
minimize.Text = "—"
minimize.TextColor3 = THEME.TextMuted
minimize.Font = FONT_BOLD
minimize.TextSize = 18
minimize.AutoButtonColor = false
minimize.ZIndex = 5
minimize.Parent = frame

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 9)
minimizeCorner.Parent = minimize

local close = Instance.new("TextButton")
close.Name = "Close"
close.Size = UDim2.new(0, 34, 0, 34)
close.Position = UDim2.new(1, -48, 0, 17)
close.BackgroundColor3 = THEME.Card
close.BorderSizePixel = 0
close.Text = "X"
close.TextColor3 = THEME.TextMuted
close.Font = FONT_BOLD
close.TextSize = 13
close.AutoButtonColor = false
close.ZIndex = 5
close.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 9)
closeCorner.Parent = close

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, -40, 0, 42)
tabBar.Position = UDim2.new(0, 20, 0, 68)
tabBar.BackgroundColor3 = THEME.Panel
tabBar.BorderSizePixel = 0
tabBar.Parent = frame

local tabBarCorner = Instance.new("UICorner")
tabBarCorner.CornerRadius = UDim.new(0, 10)
tabBarCorner.Parent = tabBar

local tabBarStroke = Instance.new("UIStroke")
tabBarStroke.Color = THEME.Border
tabBarStroke.Thickness = 1
tabBarStroke.Parent = tabBar

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingLeft = UDim.new(0, 5)
tabPadding.PaddingRight = UDim.new(0, 5)
tabPadding.PaddingTop = UDim.new(0, 5)
tabPadding.PaddingBottom = UDim.new(0, 5)
tabPadding.Parent = tabBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 5)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabBar

local function createTab(name, order)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(0, 120, 1, -10)
	button.BackgroundColor3 = THEME.Card
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.Text = string.upper(name)
	button.TextColor3 = THEME.TextMuted
	button.Font = FONT_BOLD
	button.TextSize = 10
	button.AutoButtonColor = false
	button.LayoutOrder = order
	button.Parent = tabBar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = button

	tabs[name] = button
end

createTab("Fish", 1)
createTab("Treasure", 2)
createTab("Teleport", 3)

local fishPage = Instance.new("Frame")
fishPage.Name = "FishPage"
fishPage.Size = UDim2.new(1, -40, 1, -130)
fishPage.Position = UDim2.new(0, 20, 0, 120)
fishPage.BackgroundTransparency = 1
fishPage.BorderSizePixel = 0
fishPage.Visible = true
fishPage.Parent = frame

pages.Fish = fishPage

local treasurePage = Instance.new("Frame")
treasurePage.Name = "TreasurePage"
treasurePage.Size = UDim2.new(1, -40, 1, -130)
treasurePage.Position = UDim2.new(0, 20, 0, 120)
treasurePage.BackgroundTransparency = 1
treasurePage.BorderSizePixel = 0
treasurePage.Visible = false
treasurePage.Parent = frame

pages.Treasure = treasurePage

local teleportPage = Instance.new("Frame")
teleportPage.Name = "TeleportPage"
teleportPage.Size = UDim2.new(1, -40, 1, -130)
teleportPage.Position = UDim2.new(0, 20, 0, 120)
teleportPage.BackgroundTransparency = 1
teleportPage.BorderSizePixel = 0
teleportPage.Visible = false
teleportPage.Parent = frame

pages.Teleport = teleportPage

local function switchTab(name)
	if not pages[name] then
		return
	end

	currentTab = name

	for tabName, button in pairs(tabs) do
		if tabName == name then
			button.BackgroundTransparency = 0
			button.BackgroundColor3 = THEME.CardSelected
			button.TextColor3 = THEME.Accent
		else
			button.BackgroundTransparency = 1
			button.TextColor3 = THEME.TextMuted
		end
	end

	for pageName, page in pairs(pages) do
		page.Visible = pageName == name
	end
end

for name, button in pairs(tabs) do
	button.MouseButton1Click:Connect(function()
		if not isMinimized then
			switchTab(name)
		end
	end)

	button.MouseEnter:Connect(function()
		if currentTab ~= name and not isMinimized then
			TweenService:Create(button, TweenInfo.new(0.12), {
				BackgroundTransparency = 0,
				BackgroundColor3 = THEME.CardHover,
				TextColor3 = THEME.Text
			}):Play()
		end
	end)

	button.MouseLeave:Connect(function()
		if currentTab ~= name then
			TweenService:Create(button, TweenInfo.new(0.12), {
				BackgroundTransparency = 1,
				TextColor3 = THEME.TextMuted
			}):Play()
		end
	end)
end

dragArea.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = frame.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local delta = input.Position - dragStart

		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = false
	end
end)

minimize.MouseEnter:Connect(function()
	TweenService:Create(minimize, TweenInfo.new(0.12), {
		BackgroundColor3 = THEME.CardHover,
		TextColor3 = THEME.Text
	}):Play()
end)

minimize.MouseLeave:Connect(function()
	TweenService:Create(minimize, TweenInfo.new(0.12), {
		BackgroundColor3 = THEME.Card,
		TextColor3 = THEME.TextMuted
	}):Play()
end)

close.MouseEnter:Connect(function()
	TweenService:Create(close, TweenInfo.new(0.12), {
		BackgroundColor3 = Color3.fromRGB(220, 65, 75),
		TextColor3 = Color3.new(1, 1, 1)
	}):Play()
end)

close.MouseLeave:Connect(function()
	TweenService:Create(close, TweenInfo.new(0.12), {
		BackgroundColor3 = THEME.Card,
		TextColor3 = THEME.TextMuted
	}):Play()
end)

minimize.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized

	if isMinimized then
		minimize.Text = "+"
		tabBar.Visible = false

		for _, page in pairs(pages) do
			page.Visible = false
		end

		TweenService:Create(
			frame,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = minimizedSize
			}
		):Play()
	else
		minimize.Text = "—"
		tabBar.Visible = true

		TweenService:Create(
			frame,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = normalSize
			}
		):Play()

		task.delay(0.3, function()
			if frame.Parent and not isMinimized then
				switchTab(currentTab)
			end
		end)
	end
end)

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

switchTab("Fish")
