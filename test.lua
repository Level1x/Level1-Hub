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


























local fishPage = pages.Fish

local FishData = require(fishDataModule)

local FishIndex = {}
local FishEntries = {}
local FishCards = {}

local selectedFish = nil
local selectedRarity = "All"
local searchText = ""

local function getFishData(name)
	if type(FishData) == "table" then
		return FishData[name]
	end

	return nil
end

local function getFishRarity(name)
	local data = getFishData(name)

	if type(data) == "table" then
		return data.Rarity
			or data.rarity
			or data.Tier
			or data.tier
			or "Unknown"
	end

	local object = FishIndex[name]

	if object then
		return object:GetAttribute("Rarity") or "Unknown"
	end

	return "Unknown"
end

local function getFishName(name)
	local data = getFishData(name)

	if type(data) == "table" then
		return data.DisplayName
			or data.displayName
			or data.Name
			or data.name
			or name
	end

	return name
end

for _, object in ipairs(fishFolder:GetChildren()) do
	FishIndex[object.Name] = object
end

for name in pairs(FishIndex) do
	table.insert(FishEntries, name)
end

table.sort(FishEntries, function(a, b)
	local rarityA = getFishRarity(a)
	local rarityB = getFishRarity(b)

	local orderA = RARITY_ORDER[rarityA] or 999
	local orderB = RARITY_ORDER[rarityB] or 999

	if orderA == orderB then
		return string.lower(getFishName(a)) < string.lower(getFishName(b))
	end

	return orderA < orderB
end)

local function createCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

local function createStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness or 1
	stroke.Parent = parent
	return stroke
end

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 165, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = THEME.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = fishPage

createCorner(sidebar, 12)
createStroke(sidebar, THEME.Border, 1)

local rarityTitle = Instance.new("TextLabel")
rarityTitle.Name = "RarityTitle"
rarityTitle.Size = UDim2.new(1, -20, 0, 25)
rarityTitle.Position = UDim2.new(0, 10, 0, 12)
rarityTitle.BackgroundTransparency = 1
rarityTitle.Text = "RARITY"
rarityTitle.TextColor3 = THEME.TextMuted
rarityTitle.Font = FONT_BOLD
rarityTitle.TextSize = 11
rarityTitle.TextXAlignment = Enum.TextXAlignment.Left
rarityTitle.Parent = sidebar

local rarityContainer = Instance.new("Frame")
rarityContainer.Name = "RarityContainer"
rarityContainer.Size = UDim2.new(1, -20, 1, -50)
rarityContainer.Position = UDim2.new(0, 10, 0, 42)
rarityContainer.BackgroundTransparency = 1
rarityContainer.Parent = sidebar

local rarityLayout = Instance.new("UIListLayout")
rarityLayout.Padding = UDim.new(0, 5)
rarityLayout.SortOrder = Enum.SortOrder.LayoutOrder
rarityLayout.Parent = rarityContainer

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(0, 475, 1, 0)
content.Position = UDim2.new(0, 175, 0, 0)
content.BackgroundTransparency = 1
content.Parent = fishPage

local searchFrame = Instance.new("Frame")
searchFrame.Name = "SearchFrame"
searchFrame.Size = UDim2.new(1, 0, 0, 42)
searchFrame.BackgroundColor3 = THEME.Panel
searchFrame.BorderSizePixel = 0
searchFrame.Parent = content

createCorner(searchFrame, 10)
createStroke(searchFrame, THEME.Border, 1)

local searchIcon = Instance.new("TextLabel")
searchIcon.Name = "Icon"
searchIcon.Size = UDim2.new(0, 30, 1, 0)
searchIcon.Position = UDim2.new(0, 10, 0, 0)
searchIcon.BackgroundTransparency = 1
searchIcon.Text = "⌕"
searchIcon.TextColor3 = THEME.TextMuted
searchIcon.Font = FONT_BOLD
searchIcon.TextSize = 20
searchIcon.Parent = searchFrame

local search = Instance.new("TextBox")
search.Name = "Search"
search.Size = UDim2.new(1, -50, 1, 0)
search.Position = UDim2.new(0, 45, 0, 0)
search.BackgroundTransparency = 1
search.BorderSizePixel = 0
search.Text = ""
search.PlaceholderText = "Search Fish . . ."
search.PlaceholderColor3 = THEME.TextMuted
search.TextColor3 = THEME.Text
search.Font = FONT_REGULAR
search.TextSize = 12
search.ClearTextOnFocus = false
search.TextXAlignment = Enum.TextXAlignment.Left
search.Parent = searchFrame

local list = Instance.new("ScrollingFrame")
list.Name = "FishList"
list.Size = UDim2.new(1, 0, 1, -55)
list.Position = UDim2.new(0, 0, 0, 55)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.ScrollBarImageColor3 = THEME.Accent
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = content

local grid = Instance.new("UIGridLayout")
grid.Name = "Grid"
grid.CellSize = UDim2.new(0, 148, 0, 112)
grid.CellPadding = UDim2.new(0, 8, 0, 8)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = list

local previewPanel = Instance.new("Frame")
previewPanel.Name = "PreviewPanel"
previewPanel.Size = UDim2.new(0, 190, 1, 0)
previewPanel.Position = UDim2.new(1, -190, 0, 0)
previewPanel.BackgroundColor3 = THEME.Sidebar
previewPanel.BorderSizePixel = 0
previewPanel.Parent = fishPage

createCorner(previewPanel, 12)
createStroke(previewPanel, THEME.Border, 1)

local previewHeader = Instance.new("TextLabel")
previewHeader.Name = "Header"
previewHeader.Size = UDim2.new(1, -20, 0, 20)
previewHeader.Position = UDim2.new(0, 10, 0, 12)
previewHeader.BackgroundTransparency = 1
previewHeader.Text = "SPECIMEN PREVIEW"
previewHeader.TextColor3 = THEME.TextMuted
previewHeader.Font = FONT_BOLD
previewHeader.TextSize = 9
previewHeader.TextXAlignment = Enum.TextXAlignment.Left
previewHeader.Parent = previewPanel

local previewViewport = Instance.new("ViewportFrame")
previewViewport.Name = "Viewport"
previewViewport.Size = UDim2.new(1, -20, 0, 205)
previewViewport.Position = UDim2.new(0, 10, 0, 42)
previewViewport.BackgroundColor3 = Color3.fromRGB(10, 12, 17)
previewViewport.BorderSizePixel = 0
previewViewport.Ambient = Color3.fromRGB(200, 200, 200)
previewViewport.LightColor = Color3.fromRGB(255, 255, 255)
previewViewport.LightDirection = Vector3.new(-1, -1, -1)
previewViewport.Parent = previewPanel

createCorner(previewViewport, 10)

local previewTitle = Instance.new("TextLabel")
previewTitle.Name = "Title"
previewTitle.Size = UDim2.new(1, -20, 0, 40)
previewTitle.Position = UDim2.new(0, 10, 0, 258)
previewTitle.BackgroundTransparency = 1
previewTitle.Text = "NO FISH SELECTED"
previewTitle.TextColor3 = THEME.Text
previewTitle.Font = FONT_BOLD
previewTitle.TextSize = 14
previewTitle.TextWrapped = true
previewTitle.Parent = previewPanel

local previewRarity = Instance.new("TextLabel")
previewRarity.Name = "Rarity"
previewRarity.Size = UDim2.new(1, -20, 0, 22)
previewRarity.Position = UDim2.new(0, 10, 0, 300)
previewRarity.BackgroundTransparency = 1
previewRarity.Text = "SELECT A FISH"
previewRarity.TextColor3 = THEME.TextMuted
previewRarity.Font = FONT_BOLD
previewRarity.TextSize = 9
previewRarity.Parent = previewPanel

local addButton = Instance.new("TextButton")
addButton.Name = "AddToInventory"
addButton.Size = UDim2.new(1, -20, 0, 40)
addButton.Position = UDim2.new(0, 10, 1, -50)
addButton.BackgroundColor3 = THEME.Accent
addButton.BorderSizePixel = 0
addButton.Text = "ADD TO INVENTORY"
addButton.TextColor3 = Color3.new(1, 1, 1)
addButton.Font = FONT_BOLD
addButton.TextSize = 9
addButton.AutoButtonColor = false
addButton.Parent = previewPanel

createCorner(addButton, 9)

local rarityButtons = {}

local function createRarityButton(name, order, text, textColor)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(1, 0, 0, 31)
	button.BackgroundColor3 = THEME.Card
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = textColor
	button.Font = FONT_BOLD
	button.TextSize = 9
	button.AutoButtonColor = false
	button.LayoutOrder = order
	button.Parent = rarityContainer

	createCorner(button, 7)

	rarityButtons[name] = button

	button.MouseEnter:Connect(function()
		if selectedRarity ~= name then
			TweenService:Create(button, TweenInfo.new(0.12), {
				BackgroundTransparency = 0,
				BackgroundColor3 = THEME.CardHover
			}):Play()
		end
	end)

	button.MouseLeave:Connect(function()
		if selectedRarity ~= name then
			TweenService:Create(button, TweenInfo.new(0.12), {
				BackgroundTransparency = 1
			}):Play()
		end
	end)

	return button
end

createRarityButton(
	"All",
	0,
	"ALL",
	THEME.Text
)

for rarity, order in pairs(RARITY_ORDER) do
	createRarityButton(
		rarity,
		order,
		RARITY_DISPLAY[rarity] or string.upper(rarity),
		THEME[rarity] or THEME.Unknown
	)
end

local function updateRarityButtons()
	for name, button in pairs(rarityButtons) do
		if name == selectedRarity then
			button.BackgroundTransparency = 0
			button.BackgroundColor3 = THEME.CardSelected

			if name == "All" then
				button.TextColor3 = THEME.Accent
			else
				button.TextColor3 = THEME[name] or THEME.Unknown
			end
		else
			button.BackgroundTransparency = 1

			if name == "All" then
				button.TextColor3 = THEME.TextMuted
			else
				button.TextColor3 = THEME[name] or THEME.Unknown
			end
		end
	end
end

local viewportCamera
local viewportWorld
local viewportModel
local viewportPivot
local viewportRotation = 0
local viewportDragging = false
local viewportLastX = 0

local function clearViewport()
	for _, child in ipairs(previewViewport:GetChildren()) do
		child:Destroy()
	end

	viewportCamera = nil
	viewportWorld = nil
	viewportModel = nil
	viewportPivot = nil
	viewportRotation = 0
end

local function setupViewport(name)
	clearViewport()

	local source = FishIndex[name]

	if not source then
		return
	end

	local clone

	pcall(function()
		clone = source:Clone()
	end)

	if not clone then
		return
	end

	local world = Instance.new("WorldModel")
	world.Parent = previewViewport

	clone.Parent = world

	local camera = Instance.new("Camera")
	camera.Parent = previewViewport
	previewViewport.CurrentCamera = camera

	local pivot
	local size

	pcall(function()
		pivot, size = clone:GetBoundingBox()
	end)

	if not pivot or not size then
		pivot = clone:GetPivot()
		size = Vector3.new(5, 5, 5)
	end

	local maxSize = math.max(size.X, size.Y, size.Z)
	local distance = math.max(maxSize * 2.4, 6)

	camera.CFrame = CFrame.lookAt(
		pivot.Position + Vector3.new(distance, distance * 0.35, distance),
		pivot.Position
	)

	viewportCamera = camera
	viewportWorld = world
	viewportModel = clone
	viewportPivot = clone:GetPivot()
	viewportRotation = 0
end

local function selectFish(name)
	selectedFish = name

	if not name then
		previewTitle.Text = "NO FISH SELECTED"
		previewRarity.Text = "SELECT A FISH"
		previewRarity.TextColor3 = THEME.TextMuted
		clearViewport()
		return
	end

	local displayName = getFishName(name)
	local rarity = getFishRarity(name)

	previewTitle.Text = displayName
	previewRarity.Text = RARITY_DISPLAY[rarity] or string.upper(rarity)
	previewRarity.TextColor3 = THEME[rarity] or THEME.Unknown

	setupViewport(name)
end

local function clearCards()
	for _, card in ipairs(FishCards) do
		if card and card.Parent then
			card:Destroy()
		end
	end

	table.clear(FishCards)
end

local function createFishCard(name, rarity, order)
	local card = Instance.new("TextButton")
	card.Name = name
	card.Size = UDim2.new(0, 148, 0, 112)
	card.BackgroundColor3 = THEME.Card
	card.BorderSizePixel = 0
	card.Text = ""
	card.AutoButtonColor = false
	card.LayoutOrder = order
	card.Parent = list

	createCorner(card, 10)

	local stroke = createStroke(card, THEME.Border, 1)

	local fishViewport = Instance.new("ViewportFrame")
	fishViewport.Name = "Viewport"
	fishViewport.Size = UDim2.new(1, -12, 0, 64)
	fishViewport.Position = UDim2.new(0, 6, 0, 6)
	fishViewport.BackgroundColor3 = Color3.fromRGB(10, 12, 17)
	fishViewport.BorderSizePixel = 0
	fishViewport.Ambient = Color3.fromRGB(200, 200, 200)
	fishViewport.LightColor = Color3.fromRGB(255, 255, 255)
	fishViewport.LightDirection = Vector3.new(-1, -1, -1)
	fishViewport.Parent = card

	createCorner(fishViewport, 7)

	local source = FishIndex[name]

	if source then
		local clone

		pcall(function()
			clone = source:Clone()
		end)

		if clone then
			local world = Instance.new("WorldModel")
			world.Parent = fishViewport
			clone.Parent = world

			local camera = Instance.new("Camera")
			camera.Parent = fishViewport
			fishViewport.CurrentCamera = camera

			local pivot
			local size

			pcall(function()
				pivot, size = clone:GetBoundingBox()
			end)

			if pivot and size then
				local maxSize = math.max(size.X, size.Y, size.Z)
				local distance = math.max(maxSize * 2.1, 5)

				camera.CFrame = CFrame.lookAt(
					pivot.Position + Vector3.new(distance, distance * 0.3, distance),
					pivot.Position
				)
			end
		end
	end

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.Size = UDim2.new(1, -12, 0, 22)
	nameLabel.Position = UDim2.new(0, 6, 0, 74)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = getFishName(name)
	nameLabel.TextColor3 = THEME.Text
	nameLabel.Font = FONT_BOLD
	nameLabel.TextSize = 9
	nameLabel.TextWrapped = true
	nameLabel.Parent = card

	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "Rarity"
	rarityLabel.Size = UDim2.new(1, -12, 0, 12)
	rarityLabel.Position = UDim2.new(0, 6, 1, -15)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text = RARITY_DISPLAY[rarity] or string.upper(rarity)
	rarityLabel.TextColor3 = THEME[rarity] or THEME.Unknown
	rarityLabel.Font = FONT_BOLD
	rarityLabel.TextSize = 7
	rarityLabel.Parent = card

	card.MouseEnter:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.12), {
			BackgroundColor3 = THEME.CardHover
		}):Play()

		TweenService:Create(stroke, TweenInfo.new(0.12), {
			Color = THEME[rarity] or THEME.Unknown
		}):Play()
	end)

	card.MouseLeave:Connect(function()
		local selected = selectedFish == name

		TweenService:Create(card, TweenInfo.new(0.12), {
			BackgroundColor3 = selected and THEME.CardSelected or THEME.Card
		}):Play()

		TweenService:Create(stroke, TweenInfo.new(0.12), {
			Color = selected and (THEME[rarity] or THEME.Unknown) or THEME.Border
		}):Play()
	end)

	card.MouseButton1Click:Connect(function()
		for _, other in ipairs(FishCards) do
			if other ~= card then
				other.BackgroundColor3 = THEME.Card

				local otherStroke = other:FindFirstChildOfClass("UIStroke")

				if otherStroke then
					otherStroke.Color = THEME.Border
				end
			end
		end

		card.BackgroundColor3 = THEME.CardSelected
		stroke.Color = THEME[rarity] or THEME.Unknown

		selectFish(name)
	end)

	table.insert(FishCards, card)
end

local function rebuildFishList()
	clearCards()

	local query = string.lower(searchText)
	local order = 0

	for _, name in ipairs(FishEntries) do
		local displayName = getFishName(name)
		local rarity = getFishRarity(name)

		local rarityMatch =
			selectedRarity == "All"
			or rarity == selectedRarity

		local searchMatch =
			query == ""
			or string.find(string.lower(name), query, 1, true)
			or string.find(string.lower(displayName), query, 1, true)

		if rarityMatch and searchMatch then
			order += 1
			createFishCard(name, rarity, order)
		end
	end

	task.defer(function()
		list.CanvasSize = UDim2.new(
			0,
			0,
			0,
			grid.AbsoluteContentSize.Y + 10
		)
	end)
end

for rarity, button in pairs(rarityButtons) do
	button.MouseButton1Click:Connect(function()
		selectedRarity = rarity
		updateRarityButtons()
		rebuildFishList()
	end)
end

search:GetPropertyChangedSignal("Text"):Connect(function()
	searchText = search.Text or ""
	rebuildFishList()
end)

grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	list.CanvasSize = UDim2.new(
		0,
		0,
		0,
		grid.AbsoluteContentSize.Y + 10
	)
end)

previewViewport.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		viewportDragging = true
		viewportLastX = input.Position.X
	end
end)

UIS.InputChanged:Connect(function(input)
	if not viewportDragging or not viewportModel or not viewportPivot then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local delta = input.Position.X - viewportLastX
		viewportLastX = input.Position.X

		viewportRotation += delta * 0.01

		viewportModel:PivotTo(
			viewportPivot * CFrame.Angles(0, viewportRotation, 0)
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		viewportDragging = false
	end
end)

addButton.MouseEnter:Connect(function()
	TweenService:Create(addButton, TweenInfo.new(0.12), {
		BackgroundColor3 = THEME.AccentDark
	}):Play()
end)

addButton.MouseLeave:Connect(function()
	TweenService:Create(addButton, TweenInfo.new(0.12), {
		BackgroundColor3 = THEME.Accent
	}):Play()
end)

addButton.MouseButton1Click:Connect(function()
	if not selectedFish then
		return
	end

	pcall(function()
		addToInventoryRF:InvokeServer(selectedFish)
	end)
end)

updateRarityButtons()
rebuildFishList()
selectFish(nil)
