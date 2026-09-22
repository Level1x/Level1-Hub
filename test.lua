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

local fishDataModule = ReplicatedStorage
	:WaitForChild("Shared")
	:WaitForChild("Data")
	:WaitForChild("Template")
	:WaitForChild("Fish")

local treasureDataModule = ReplicatedStorage
	:WaitForChild("Shared")
	:WaitForChild("Data")
	:WaitForChild("Template")
	:WaitForChild("Treasures")

local fishRemote = ReplicatedStorage
	:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_knit@1.7.0")
	:WaitForChild("knit")
	:WaitForChild("Services")
	:WaitForChild("FishService")
	:WaitForChild("RF")
	:WaitForChild("AddToInventory")

local treasureRemote = ReplicatedStorage
	:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_knit@1.7.0")
	:WaitForChild("knit")
	:WaitForChild("Services")
	:WaitForChild("TreasureService")
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

local rarityColors = {
	Common = THEME.Common,
	Rare = THEME.Rare,
	["Super Rare"] = THEME.SuperRare,
	Mythical = THEME.Mythical,
	Legendary = THEME.Legendary,
	["Never Seen"] = THEME.NeverSeen,
	Arcana = THEME.Arcana,
	Eternal = THEME.Eternal,
	Apex = THEME.Apex
}

local rarityOrder = {
	Common = 1,
	Rare = 2,
	["Super Rare"] = 3,
	Mythical = 4,
	Legendary = 5,
	["Never Seen"] = 6,
	Arcana = 7,
	Eternal = 8,
	Apex = 9
}

local rarityDisplayOrder = {
	"Common",
	"Rare",
	"Super Rare",
	"Mythical",
	"Legendary",
	"Never Seen",
	"Arcana",
	"Eternal",
	"Apex"
}

local function loadData(module)
	local success, result = pcall(require, module)

	if success and type(result) == "table" then
		return result
	end

	return {}
end

local fishIndex = loadData(fishDataModule)
local treasureIndex = loadData(treasureDataModule)

local fishList = {}
local treasureList = {}

for name, data in pairs(fishIndex) do
	if type(data) == "table" then
		table.insert(fishList, {
			Name = name,
			Rarity = data.Rarity or data.rarity or "Unknown",
			Data = data
		})
	end
end

for name, data in pairs(treasureIndex) do
	if type(data) == "table" then
		table.insert(treasureList, {
			Name = name,
			Rarity = data.Rarity or data.rarity or "Unknown",
			Data = data
		})
	end
end

table.sort(fishList, function(a, b)
	local rarityA = rarityOrder[a.Rarity] or 999
	local rarityB = rarityOrder[b.Rarity] or 999

	if rarityA == rarityB then
		return a.Name < b.Name
	end

	return rarityA < rarityB
end)

table.sort(treasureList, function(a, b)
	local rarityA = rarityOrder[a.Rarity] or 999
	local rarityB = rarityOrder[b.Rarity] or 999

	if rarityA == rarityB then
		return a.Name < b.Name
	end

	return rarityA < rarityB
end)

local gui = Instance.new("ScreenGui")
gui.Name = "FishCatcherGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.new(0, 900, 0, 560)
frame.Position = UDim2.new(0.5, 450, 0.5, -280)
frame.AnchorPoint = Vector2.new(1, 0)
frame.BackgroundColor3 = THEME.Background
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = THEME.Border
frameStroke.Thickness = 1
frameStroke.Parent = frame

local normalSize = UDim2.new(0, 900, 0, 560)
local minimizedSize = UDim2.new(0, 300, 0, 68)
local isMinimized = false

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 68)
header.BackgroundColor3 = THEME.Sidebar
header.BorderSizePixel = 0
header.Parent = frame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 14)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 20)
headerFix.Position = UDim2.new(0, 0, 1, -20)
headerFix.BackgroundColor3 = THEME.Sidebar
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 300, 0, 30)
title.Position = UDim2.new(0, 20, 0, 9)
title.BackgroundTransparency = 1
title.Text = "🐟  LEVEL1 HUB"
title.TextColor3 = THEME.Text
title.TextSize = 20
title.Font = FONT_BOLD
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local gameTitle = Instance.new("TextLabel")
gameTitle.Size = UDim2.new(0, 300, 0, 18)
gameTitle.Position = UDim2.new(0, 22, 0, 39)
gameTitle.BackgroundTransparency = 1
gameTitle.Text = "BECOME A DEEP SEA EXPLORER"
gameTitle.TextColor3 = THEME.TextMuted
gameTitle.TextSize = 9
gameTitle.Font = FONT_BOLD
gameTitle.TextXAlignment = Enum.TextXAlignment.Left
gameTitle.Parent = header

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 32, 0, 32)
minimizeButton.Position = UDim2.new(1, -76, 0, 18)
minimizeButton.BackgroundColor3 = THEME.Card
minimizeButton.BorderSizePixel = 0
minimizeButton.AutoButtonColor = false
minimizeButton.Text = "—"
minimizeButton.TextColor3 = THEME.Text
minimizeButton.TextSize = 18
minimizeButton.Font = FONT_BOLD
minimizeButton.Parent = header

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 8)
minimizeCorner.Parent = minimizeButton

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 32, 0, 32)
closeButton.Position = UDim2.new(1, -38, 0, 18)
closeButton.BackgroundColor3 = THEME.Card
closeButton.BorderSizePixel = 0
closeButton.AutoButtonColor = false
closeButton.Text = "×"
closeButton.TextColor3 = THEME.Text
closeButton.TextSize = 20
closeButton.Font = FONT_BOLD
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, -40, 0, 42)
tabBar.Position = UDim2.new(0, 20, 0, 78)
tabBar.BackgroundTransparency = 1
tabBar.Parent = frame

local tabs = {}
local pages = {}
local currentTab = "Fish"

local tabNames = {
	"Fish",
	"Treasure",
	"Teleport"
}

for index, name in ipairs(tabNames) do
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 115, 0, 36)
	button.Position = UDim2.new(0, (index - 1) * 125, 0, 3)
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Text = name
	button.TextColor3 = name == "Fish" and THEME.Accent or THEME.TextMuted
	button.TextSize = 12
	button.Font = FONT_BOLD
	button.Parent = tabBar

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = button

	tabs[name] = button
end

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 165, 1, -130)
sidebar.Position = UDim2.new(0, 20, 0, 120)
sidebar.BackgroundColor3 = THEME.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = frame

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 10)
sidebarCorner.Parent = sidebar

local sidebarStroke = Instance.new("UIStroke")
sidebarStroke.Color = THEME.Border
sidebarStroke.Thickness = 1
sidebarStroke.Parent = sidebar

local sidebarTitle = Instance.new("TextLabel")
sidebarTitle.Size = UDim2.new(1, -20, 0, 30)
sidebarTitle.Position = UDim2.new(0, 10, 0, 10)
sidebarTitle.BackgroundTransparency = 1
sidebarTitle.Text = "FISH"
sidebarTitle.TextColor3 = THEME.TextMuted
sidebarTitle.TextSize = 12
sidebarTitle.Font = FONT_BOLD
sidebarTitle.TextXAlignment = Enum.TextXAlignment.Left
sidebarTitle.Parent = sidebar

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 0, 36)
searchBox.Position = UDim2.new(0, 10, 0, 48)
searchBox.BackgroundColor3 = THEME.Card
searchBox.BorderSizePixel = 0
searchBox.PlaceholderText = "Search fish..."
searchBox.PlaceholderColor3 = THEME.TextMuted
searchBox.Text = ""
searchBox.TextColor3 = THEME.Text
searchBox.TextSize = 12
searchBox.Font = FONT_REGULAR
searchBox.ClearTextOnFocus = false
searchBox.Parent = sidebar

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = searchBox

local searchStroke = Instance.new("UIStroke")
searchStroke.Color = THEME.Border
searchStroke.Thickness = 1
searchStroke.Parent = searchBox

local categoryList = Instance.new("ScrollingFrame")
categoryList.Size = UDim2.new(1, -20, 1, -105)
categoryList.Position = UDim2.new(0, 10, 0, 95)
categoryList.BackgroundTransparency = 1
categoryList.BorderSizePixel = 0
categoryList.ScrollBarThickness = 3
categoryList.ScrollBarImageColor3 = THEME.Accent
categoryList.CanvasSize = UDim2.new(0, 0, 0, 0)
categoryList.AutomaticCanvasSize = Enum.AutomaticSize.Y
categoryList.Parent = sidebar

local categoryLayout = Instance.new("UIListLayout")
categoryLayout.Padding = UDim.new(0, 6)
categoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
categoryLayout.Parent = categoryList

local content = Instance.new("Frame")
content.Size = UDim2.new(0, 470, 1, -130)
content.Position = UDim2.new(0, 195, 0, 120)
content.BackgroundColor3 = THEME.Panel
content.BorderSizePixel = 0
content.Parent = frame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 10)
contentCorner.Parent = content

local contentStroke = Instance.new("UIStroke")
contentStroke.Color = THEME.Border
contentStroke.Thickness = 1
contentStroke.Parent = content

local contentTitle = Instance.new("TextLabel")
contentTitle.Size = UDim2.new(1, -30, 0, 34)
contentTitle.Position = UDim2.new(0, 15, 0, 12)
contentTitle.BackgroundTransparency = 1
contentTitle.Text = "Fish Collection"
contentTitle.TextColor3 = THEME.Text
contentTitle.TextSize = 16
contentTitle.Font = FONT_BOLD
contentTitle.TextXAlignment = Enum.TextXAlignment.Left
contentTitle.Parent = content

local fishGrid = Instance.new("ScrollingFrame")
fishGrid.Size = UDim2.new(1, -30, 1, -65)
fishGrid.Position = UDim2.new(0, 15, 0, 52)
fishGrid.BackgroundTransparency = 1
fishGrid.BorderSizePixel = 0
fishGrid.ScrollBarThickness = 4
fishGrid.ScrollBarImageColor3 = THEME.Accent
fishGrid.CanvasSize = UDim2.new(0, 0, 0, 0)
fishGrid.AutomaticCanvasSize = Enum.AutomaticSize.Y
fishGrid.Parent = content

local fishGridLayout = Instance.new("UIGridLayout")
fishGridLayout.CellSize = UDim2.new(0, 138, 0, 165)
fishGridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
fishGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
fishGridLayout.Parent = fishGrid

local previewPanel = Instance.new("Frame")
previewPanel.Size = UDim2.new(0, 195, 1, -130)
previewPanel.Position = UDim2.new(1, -215, 0, 120)
previewPanel.BackgroundColor3 = THEME.Panel
previewPanel.BorderSizePixel = 0
previewPanel.Parent = frame

local previewCorner = Instance.new("UICorner")
previewCorner.CornerRadius = UDim.new(0, 10)
previewCorner.Parent = previewPanel

local previewStroke = Instance.new("UIStroke")
previewStroke.Color = THEME.Border
previewStroke.Thickness = 1
previewStroke.Parent = previewPanel

local previewTitle = Instance.new("TextLabel")
previewTitle.Size = UDim2.new(1, -20, 0, 32)
previewTitle.Position = UDim2.new(0, 10, 0, 10)
previewTitle.BackgroundTransparency = 1
previewTitle.Text = "FISH PREVIEW"
previewTitle.TextColor3 = THEME.TextMuted
previewTitle.TextSize = 11
previewTitle.Font = FONT_BOLD
previewTitle.TextXAlignment = Enum.TextXAlignment.Left
previewTitle.Parent = previewPanel

local viewport = Instance.new("ViewportFrame")
viewport.Size = UDim2.new(1, -20, 0, 170)
viewport.Position = UDim2.new(0, 10, 0, 48)
viewport.BackgroundColor3 = THEME.Card
viewport.BorderSizePixel = 0
viewport.Parent = previewPanel

local viewportCorner = Instance.new("UICorner")
viewportCorner.CornerRadius = UDim.new(0, 8)
viewportCorner.Parent = viewport

local viewportStroke = Instance.new("UIStroke")
viewportStroke.Color = THEME.Border
viewportStroke.Thickness = 1
viewportStroke.Parent = viewport

local viewportCamera = Instance.new("Camera")
viewportCamera.Parent = viewport
viewport.CurrentCamera = viewportCamera

local previewName = Instance.new("TextLabel")
previewName.Size = UDim2.new(1, -20, 0, 35)
previewName.Position = UDim2.new(0, 10, 0, 228)
previewName.BackgroundTransparency = 1
previewName.Text = "Select a fish"
previewName.TextColor3 = THEME.Text
previewName.TextSize = 14
previewName.Font = FONT_BOLD
previewName.TextWrapped = true
previewName.Parent = previewPanel

local previewRarity = Instance.new("TextLabel")
previewRarity.Size = UDim2.new(1, -20, 0, 24)
previewRarity.Position = UDim2.new(0, 10, 0, 265)
previewRarity.BackgroundTransparency = 1
previewRarity.Text = ""
previewRarity.TextColor3 = THEME.TextMuted
previewRarity.TextSize = 12
previewRarity.Font = FONT_BOLD
previewRarity.Parent = previewPanel

local previewWorld
local previewClone
local previewBasePivot

local function setPreviewRotation()
	if previewClone and previewBasePivot then
		previewClone:PivotTo(
			previewBasePivot
				* CFrame.Angles(0, math.rad(25), 0)
		)
	end
end

local treasureSidebar
local treasureContent
local treasurePreviewPanel
local teleportPage

local dragArea = header

local dragging = false
local dragStart
local startPosition

dragArea.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = frame.Position
	end
end)

dragArea.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local delta = input.Position - dragStart

	frame.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end)

local function setMinimizedState(state)
	isMinimized = state

	if isMinimized then
		TweenService:Create(
			frame,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Size = minimizedSize}
		):Play()

		tabBar.Visible = false
		sidebar.Visible = false
		content.Visible = false
		previewPanel.Visible = false

		if treasureSidebar then
			treasureSidebar.Visible = false
		end

		if treasureContent then
			treasureContent.Visible = false
		end

		if treasurePreviewPanel then
			treasurePreviewPanel.Visible = false
		end

		if teleportPage then
			teleportPage.Visible = false
		end

		minimizeButton.Text = "+"
	else
		TweenService:Create(
			frame,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Size = normalSize}
		):Play()

		tabBar.Visible = true
		minimizeButton.Text = "—"

		if currentTab == "Fish" then
			sidebar.Visible = true
			content.Visible = true
			previewPanel.Visible = true
		elseif currentTab == "Treasure" then
			if treasureSidebar then
				treasureSidebar.Visible = true
			end

			if treasureContent then
				treasureContent.Visible = true
			end

			if treasurePreviewPanel then
				treasurePreviewPanel.Visible = true
			end
		elseif currentTab == "Teleport" then
			if teleportPage then
				teleportPage.Visible = true
			end
		end
	end
end

minimizeButton.MouseEnter:Connect(function()
	minimizeButton.BackgroundColor3 = THEME.CardHover
end)

minimizeButton.MouseLeave:Connect(function()
	minimizeButton.BackgroundColor3 = THEME.Card
end)

minimizeButton.MouseButton1Click:Connect(function()
	setMinimizedState(not isMinimized)
end)

closeButton.MouseEnter:Connect(function()
	closeButton.BackgroundColor3 = THEME.CardHover
end)

closeButton.MouseLeave:Connect(function()
	closeButton.BackgroundColor3 = THEME.Card
end)

closeButton.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

local function switchTab(name)
	if not tabs[name] then
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

	sidebar.Visible = name == "Fish"
	content.Visible = name == "Fish"
	previewPanel.Visible = name == "Fish"

	if treasureSidebar then
		treasureSidebar.Visible = name == "Treasure"
	end

	if treasureContent then
		treasureContent.Visible = name == "Treasure"
	end

	if treasurePreviewPanel then
		treasurePreviewPanel.Visible = name == "Treasure"
	end

	if teleportPage then
		teleportPage.Visible = name == "Teleport"
	end
end


local function updatePreview(fishName, rarity)
	viewport:ClearAllChildren()

	previewWorld = nil
	previewClone = nil
	previewBasePivot = nil
	viewportCamera = nil
	previewRotation = 0
	previewDragging = false

	local targetFish = fishFolder:FindFirstChild(fishName)

	if not targetFish then
		previewTitle.Text = "NO FISH SELECTED"
		previewRarity.Text = "SELECT A FISH"
		previewRarity.TextColor3 = THEME.TextMuted
		return
	end

	previewWorld = Instance.new("WorldModel")
	previewWorld.Name = "PreviewWorld"
	previewWorld.Parent = viewport

	local success, clone = pcall(function()
		return targetFish:Clone()
	end)

	if not success or not clone then
		previewTitle.Text = "PREVIEW ERROR"
		previewRarity.Text = "CLONE FAILED"
		previewRarity.TextColor3 = Color3.fromRGB(255, 85, 85)
		return
	end

	clone.Parent = previewWorld
	previewClone = clone

	preparePreviewObject(clone)

	local centeredCF, centeredSize = centerPreviewObject(clone)

	if not centeredCF or not centeredSize then
		previewTitle.Text = "PREVIEW ERROR"
		previewRarity.Text = "INVALID MODEL"
		previewRarity.TextColor3 = Color3.fromRGB(255, 85, 85)
		return
	end

	local maxSize = math.max(
		centeredSize.X,
		centeredSize.Y,
		centeredSize.Z
	)

	if maxSize <= 0 or maxSize ~= maxSize then
		maxSize = 4
	end

	local camera = Instance.new("Camera")
	camera.Name = "PreviewCamera"
	camera.FieldOfView = 35
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	viewportCamera = camera

	local cameraDistance = math.max(maxSize * 2.25, 4)

	camera.CFrame = CFrame.lookAt(
		Vector3.new(
			0,
			maxSize * 0.04,
			cameraDistance
		),
		Vector3.new(0, 0, 0)
	)

	local sideRotation = CFrame.Angles(0, math.rad(90), 0)

	if clone:IsA("Model") then
		previewBasePivot = clone:GetPivot() * sideRotation
	elseif clone:IsA("BasePart") then
		previewBasePivot = clone.CFrame * sideRotation
	end

	setPreviewRotation()

	local rarityColor = getRarityColor(rarity)

	previewTitle.Text = string.upper(fishName)

	previewRarity.Text =
		RARITY_DISPLAY[rarity]
		or string.upper(rarity)

	previewRarity.TextColor3 = rarityColor
end

viewport.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		previewDragging = true
		previewLastX = input.Position.X
	end
end)

UIS.InputChanged:Connect(function(input)
	if not previewDragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local currentX = input.Position.X
		local delta = currentX - previewLastX

		previewLastX = currentX
		previewRotation += delta * 0.6

		if previewRotation > 360 then
			previewRotation -= 360
		elseif previewRotation < -360 then
			previewRotation += 360
		end

		setPreviewRotation()
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		previewDragging = false
	end
end)

local fishButtons = {}

local selectedFish = nil
local selectedButton = nil
local selectedStroke = nil
local selectedRarity = nil

local catchButton
local catchButtonStroke

local function createFishCard(data)
	local fish = data.Object
	local name = data.Name
	local rarity = data.Rarity
	local rarityColor = getRarityColor(rarity)

	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = ""
	button.AutoButtonColor = false
	button.BackgroundColor3 = THEME.Card
	button.BorderSizePixel = 0
	button.LayoutOrder = data.Order
	button.Parent = list

	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)

	local stroke = Instance.new("UIStroke", button)
	stroke.Color = THEME.Border
	stroke.Thickness = 1

	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 7, 0, 7)
	dot.Position = UDim2.new(0, 9, 0, 9)
	dot.BackgroundColor3 = rarityColor
	dot.BorderSizePixel = 0
	dot.Parent = button

	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.new(1, -25, 0, 16)
	rarityLabel.Position = UDim2.new(0, 21, 0, 5)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text =
		RARITY_DISPLAY[rarity]
		or string.upper(rarity)
	rarityLabel.TextColor3 = rarityColor
	rarityLabel.Font = FONT_BOLD
	rarityLabel.TextSize = 7
	rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
	rarityLabel.Parent = button

	local miniViewport = Instance.new("ViewportFrame")
	miniViewport.Size = UDim2.new(1, -10, 0, 67)
	miniViewport.Position = UDim2.new(0, 5, 0, 25)
	miniViewport.BackgroundTransparency = 1
	miniViewport.BorderSizePixel = 0
	miniViewport.Ambient = Color3.fromRGB(200, 200, 200)
	miniViewport.LightColor = Color3.fromRGB(255, 255, 255)
	miniViewport.LightDirection = Vector3.new(-1, -1, -1)
	miniViewport.Parent = button

	Instance.new("UICorner", miniViewport).CornerRadius = UDim.new(0, 6)

	local miniWorld = Instance.new("WorldModel")
	miniWorld.Parent = miniViewport

	local cloneSuccess, miniClone = pcall(function()
		return fish:Clone()
	end)

	if cloneSuccess and miniClone then
		miniClone.Parent = miniWorld

		preparePreviewObject(miniClone)

		local miniCF, miniSize = centerPreviewObject(miniClone)

		if miniCF and miniSize then
			local miniRotation =
				CFrame.Angles(0, math.rad(180), 0)

			if miniClone:IsA("Model") then
				miniClone:PivotTo(
					miniRotation * miniClone:GetPivot()
				)
			elseif miniClone:IsA("BasePart") then
				miniClone.CFrame =
					miniRotation * miniClone.CFrame
			end

			local miniCamera = Instance.new("Camera")
			miniCamera.FieldOfView = 38
			miniCamera.Parent = miniViewport
			miniViewport.CurrentCamera = miniCamera

			local miniMax =
				math.max(
					miniSize.X,
					miniSize.Y,
					miniSize.Z
				)

			local distance =
				math.max(
					miniMax * 2.4,
					2.5
				)

			miniCamera.CFrame = CFrame.lookAt(
				Vector3.new(
					0,
					miniMax * 0.03,
					distance
				),
				Vector3.new(0, 0, 0)
			)
		end
	end

	local fishName = Instance.new("TextLabel")
	fishName.Size = UDim2.new(1, -12, 0, 25)
	fishName.Position = UDim2.new(0, 6, 1, -31)
	fishName.BackgroundTransparency = 1
	fishName.Text = name
	fishName.TextColor3 = THEME.Text
	fishName.Font = FONT_REGULAR
	fishName.TextSize = 10
	fishName.TextTruncate = Enum.TextTruncate.AtEnd
	fishName.Parent = button

	local rarityBar = Instance.new("Frame")
	rarityBar.Size = UDim2.new(1, 0, 0, 3)
	rarityBar.Position = UDim2.new(0, 0, 1, -3)
	rarityBar.BackgroundColor3 = rarityColor
	rarityBar.BorderSizePixel = 0
	rarityBar.Parent = button

	Instance.new("UICorner", rarityBar).CornerRadius = UDim.new(0, 2)

	button.MouseEnter:Connect(function()
		if selectedButton ~= button then
			TweenService:Create(
				button,
				TweenInfo.new(0.15),
				{
					BackgroundColor3 = THEME.CardHover
				}
			):Play()
		end

		TweenService:Create(
			stroke,
			TweenInfo.new(0.15),
			{
				Color = rarityColor
			}
		):Play()
	end)

	button.MouseLeave:Connect(function()
		if selectedButton ~= button then
			TweenService:Create(
				button,
				TweenInfo.new(0.15),
				{
					BackgroundColor3 = THEME.Card
				}
			):Play()

			TweenService:Create(
				stroke,
				TweenInfo.new(0.15),
				{
					Color = THEME.Border
				}
			):Play()
		end
	end)

	button.MouseButton1Click:Connect(function()
		if selectedButton and selectedButton ~= button then
			selectedButton.BackgroundColor3 = THEME.Card

			if selectedStroke then
				selectedStroke.Color = THEME.Border
			end
		end

		selectedButton = button
		selectedStroke = stroke
		selectedFish = name
		selectedRarity = rarity

		button.BackgroundColor3 = THEME.CardSelected
		stroke.Color = rarityColor

		catchButton.BackgroundColor3 = THEME.Accent
		catchButton.TextColor3 = Color3.fromRGB(5, 15, 20)
		catchButtonStroke.Color = THEME.Accent

		updatePreview(name, rarity)
	end)

	fishButtons[name] = {
		Button = button,
		Rarity = rarity,
		Data = data
	}
end

for _, data in ipairs(fishList) do
	createFishCard(data)
end

local function updateCanvas()
	list.CanvasSize = UDim2.new(
		0,
		0,
		0,
		grid.AbsoluteContentSize.Y + 10
	)
end

grid:GetPropertyChangedSignal(
	"AbsoluteContentSize"
):Connect(updateCanvas)

task.defer(updateCanvas)

local categories = {
	"Common",
	"Rare",
	"SuperRare",
	"Mythical",
	"Legendary",
	"NeverSeen",
	"Arcana",
	"Eternal",
	"Apex",
}

local currentCategory = nil
local categoryButtons = {}

local function filterFish()
	local searchText =
		string.lower(search.Text or "")

	if currentCategory == nil then
		grid.SortOrder = Enum.SortOrder.LayoutOrder
	else
		grid.SortOrder = Enum.SortOrder.Name
	end

	for name, item in pairs(fishButtons) do
		local searchMatch =
			searchText == ""
			or string.find(
				string.lower(name),
				searchText,
				1,
				true
			)

		local categoryMatch =
			currentCategory == nil
			or item.Rarity == currentCategory

		item.Button.Visible =
			searchMatch and categoryMatch
	end

	task.defer(updateCanvas)
end

local function updateCategoryVisuals()
	for category, button in pairs(categoryButtons) do
		local isSelected =
			category == currentCategory

		if isSelected then
			button.BackgroundTransparency = 0
			button.BackgroundColor3 =
				THEME.CardSelected
			button.TextColor3 =
				getRarityColor(category)
		else
			button.BackgroundTransparency = 1
			button.BackgroundColor3 = THEME.Card
			button.TextColor3 = THEME.TextMuted
		end

		local accent =
			button:FindFirstChild("SelectedAccent")

		if accent then
			accent.Visible = true
			accent.BackgroundColor3 =
				getRarityColor(category)
		end
	end
end

for index, category in ipairs(categories) do
	local categoryButton =
		Instance.new("TextButton")

	categoryButton.Name = category
	categoryButton.Size =
		UDim2.new(1, 0, 0, 36)

	categoryButton.BackgroundColor3 =
		THEME.Card

	categoryButton.BackgroundTransparency = 1
	categoryButton.BorderSizePixel = 0

	categoryButton.Text =
		RARITY_DISPLAY[category]
		or string.upper(category)

	categoryButton.TextColor3 =
		THEME.TextMuted

	categoryButton.Font = FONT_BOLD
	categoryButton.TextSize = 9
	categoryButton.LayoutOrder = index
	categoryButton.AutoButtonColor = false
	categoryButton.Parent = categoryContainer

	Instance.new(
		"UICorner",
		categoryButton
	).CornerRadius = UDim.new(0, 8)

	categoryButtons[category] =
		categoryButton

	local accent = Instance.new("Frame")
	accent.Name = "SelectedAccent"
	accent.Size =
		UDim2.new(0, 3, 1, -10)

	accent.Position =
		UDim2.new(0, 5, 0, 5)

	accent.BackgroundColor3 =
		getRarityColor(category)

	accent.BorderSizePixel = 0
	accent.Visible = true
	accent.Parent = categoryButton

	Instance.new(
		"UICorner",
		accent
	).CornerRadius = UDim.new(0, 2)

	categoryButton.MouseEnter:Connect(function()
		if currentCategory ~= category then
			TweenService:Create(
				categoryButton,
				TweenInfo.new(0.12),
				{
					BackgroundTransparency = 0,
					BackgroundColor3 =
						THEME.CardHover
				}
			):Play()
		end
	end)

	categoryButton.MouseLeave:Connect(function()
		if currentCategory ~= category then
			TweenService:Create(
				categoryButton,
				TweenInfo.new(0.12),
				{
					BackgroundTransparency = 1
				}
			):Play()
		end
	end)

	categoryButton.MouseButton1Click:Connect(function()
		if currentCategory == category then
			currentCategory = nil
		else
			currentCategory = category
		end

		updateCategoryVisuals()
		filterFish()
	end)
end

updateCategoryVisuals()

search:GetPropertyChangedSignal("Text"):Connect(function()
	filterFish()
end)

catchButton = Instance.new("TextButton")
catchButton.Size =
	UDim2.new(1, -35, 0, 45)

catchButton.Position =
	UDim2.new(0, 17, 1, -60)

catchButton.Text = "CATCH FISH"
catchButton.BackgroundColor3 = THEME.Card
catchButton.TextColor3 = THEME.TextMuted
catchButton.Font = FONT_BOLD
catchButton.TextSize = 12
catchButton.BorderSizePixel = 0
catchButton.AutoButtonColor = false
catchButton.Parent = previewPanel

Instance.new(
	"UICorner",
	catchButton
).CornerRadius = UDim.new(0, 9)

catchButtonStroke =
	Instance.new("UIStroke", catchButton)

catchButtonStroke.Color = THEME.Border
catchButtonStroke.Thickness = 1

catchButton.MouseEnter:Connect(function()
	if selectedFish then
		TweenService:Create(
			catchButton,
			TweenInfo.new(0.15),
			{
				BackgroundColor3 = THEME.Accent
			}
		):Play()

		TweenService:Create(
			catchButtonStroke,
			TweenInfo.new(0.15),
			{
				Color = THEME.Accent
			}
		):Play()

		catchButton.TextColor3 =
			Color3.fromRGB(5, 15, 20)
	end
end)

catchButton.MouseLeave:Connect(function()
	if selectedFish then
		TweenService:Create(
			catchButton,
			TweenInfo.new(0.15),
			{
				BackgroundColor3 =
					THEME.AccentDark
			}
		):Play()

		catchButton.TextColor3 =
			Color3.new(1, 1, 1)
	else
		TweenService:Create(
			catchButton,
			TweenInfo.new(0.15),
			{
				BackgroundColor3 = THEME.Card
			}
		):Play()

		catchButton.TextColor3 =
			THEME.TextMuted
	end
end)

catchButton.MouseButton1Down:Connect(function()
	if selectedFish then
		catchButton:TweenSize(
			UDim2.new(1, -39, 0, 41),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.08,
			true
		)
	end
end)

catchButton.MouseButton1Up:Connect(function()
	catchButton:TweenSize(
		UDim2.new(1, -35, 0, 45),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad,
		0.08,
		true
	)
end)

catchButton.MouseButton1Click:Connect(function()
	if not selectedFish then
		warn("Pilih ikan dulu!")
		return
	end

	local fishName = selectedFish

	catchButton.Text = "CATCHING..."
	catchButton.Active = false

	local success, result = pcall(function()
		return addToInventoryRF:InvokeServer(
			fishName,
			"Catch"
		)
	end)

	if success then
		catchButton.Text = "✓ CAUGHT!"
		catchButton.BackgroundColor3 =
			Color3.fromRGB(50, 190, 110)

		catchButton.TextColor3 =
			Color3.new(1, 1, 1)

		task.delay(0.8, function()
			if catchButton.Parent then
				catchButton.Text = "CATCH FISH"
				catchButton.BackgroundColor3 =
					THEME.Accent

				catchButton.TextColor3 =
					Color3.fromRGB(5, 15, 20)

				catchButton.Active = true
			end
		end)
	else
		warn(
			"[Level1 Hub] AddToInventory failed:",
			result
		)

		catchButton.Text = "FAILED"
		catchButton.BackgroundColor3 =
			Color3.fromRGB(210, 65, 75)

		catchButton.TextColor3 =
			Color3.new(1, 1, 1)

		task.delay(1, function()
			if catchButton.Parent then
				catchButton.Text = "CATCH FISH"
				catchButton.BackgroundColor3 =
					THEME.Accent

				catchButton.TextColor3 =
					Color3.fromRGB(5, 15, 20)

				catchButton.Active = true
			end
		end)
	end
end)

catchButton.BackgroundColor3 = THEME.Card
catchButton.TextColor3 = THEME.TextMuted
catchButton.Active = true


treasureSidebar = Instance.new("Frame")
treasureSidebar.Size = UDim2.new(0, 165, 1, -130)
treasureSidebar.Position = UDim2.new(0, 20, 0, 120)
treasureSidebar.BackgroundColor3 = THEME.Sidebar
treasureSidebar.BorderSizePixel = 0
treasureSidebar.Visible = false
treasureSidebar.Parent = frame

local treasureSidebarCorner = Instance.new("UICorner")
treasureSidebarCorner.CornerRadius = UDim.new(0, 10)
treasureSidebarCorner.Parent = treasureSidebar

local treasureSidebarStroke = Instance.new("UIStroke")
treasureSidebarStroke.Color = THEME.Border
treasureSidebarStroke.Thickness = 1
treasureSidebarStroke.Parent = treasureSidebar

local treasureSidebarTitle = Instance.new("TextLabel")
treasureSidebarTitle.Size = UDim2.new(1, -20, 0, 30)
treasureSidebarTitle.Position = UDim2.new(0, 10, 0, 10)
treasureSidebarTitle.BackgroundTransparency = 1
treasureSidebarTitle.Text = "TREASURE"
treasureSidebarTitle.TextColor3 = THEME.TextMuted
treasureSidebarTitle.TextSize = 12
treasureSidebarTitle.Font = FONT_BOLD
treasureSidebarTitle.TextXAlignment = Enum.TextXAlignment.Left
treasureSidebarTitle.Parent = treasureSidebar

local treasureSearchBox = Instance.new("TextBox")
treasureSearchBox.Size = UDim2.new(1, -20, 0, 36)
treasureSearchBox.Position = UDim2.new(0, 10, 0, 48)
treasureSearchBox.BackgroundColor3 = THEME.Card
treasureSearchBox.BorderSizePixel = 0
treasureSearchBox.PlaceholderText = "Search treasure..."
treasureSearchBox.PlaceholderColor3 = THEME.TextMuted
treasureSearchBox.Text = ""
treasureSearchBox.TextColor3 = THEME.Text
treasureSearchBox.TextSize = 12
treasureSearchBox.Font = FONT_REGULAR
treasureSearchBox.ClearTextOnFocus = false
treasureSearchBox.Parent = treasureSidebar

local treasureSearchCorner = Instance.new("UICorner")
treasureSearchCorner.CornerRadius = UDim.new(0, 8)
treasureSearchCorner.Parent = treasureSearchBox

local treasureSearchStroke = Instance.new("UIStroke")
treasureSearchStroke.Color = THEME.Border
treasureSearchStroke.Thickness = 1
treasureSearchStroke.Parent = treasureSearchBox

local treasureCategoryList = Instance.new("ScrollingFrame")
treasureCategoryList.Size = UDim2.new(1, -20, 1, -105)
treasureCategoryList.Position = UDim2.new(0, 10, 0, 95)
treasureCategoryList.BackgroundTransparency = 1
treasureCategoryList.BorderSizePixel = 0
treasureCategoryList.ScrollBarThickness = 3
treasureCategoryList.ScrollBarImageColor3 = THEME.Accent
treasureCategoryList.CanvasSize = UDim2.new(0, 0, 0, 0)
treasureCategoryList.AutomaticCanvasSize = Enum.AutomaticSize.Y
treasureCategoryList.Parent = treasureSidebar

local treasureCategoryLayout = Instance.new("UIListLayout")
treasureCategoryLayout.Padding = UDim.new(0, 6)
treasureCategoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
treasureCategoryLayout.Parent = treasureCategoryList

treasureContent = Instance.new("Frame")
treasureContent.Size = UDim2.new(0, 470, 1, -130)
treasureContent.Position = UDim2.new(0, 195, 0, 120)
treasureContent.BackgroundColor3 = THEME.Panel
treasureContent.BorderSizePixel = 0
treasureContent.Visible = false
treasureContent.Parent = frame

local treasureContentCorner = Instance.new("UICorner")
treasureContentCorner.CornerRadius = UDim.new(0, 10)
treasureContentCorner.Parent = treasureContent

local treasureContentStroke = Instance.new("UIStroke")
treasureContentStroke.Color = THEME.Border
treasureContentStroke.Thickness = 1
treasureContentStroke.Parent = treasureContent

local treasureContentTitle = Instance.new("TextLabel")
treasureContentTitle.Size = UDim2.new(1, -30, 0, 34)
treasureContentTitle.Position = UDim2.new(0, 15, 0, 12)
treasureContentTitle.BackgroundTransparency = 1
treasureContentTitle.Text = "Treasure Collection"
treasureContentTitle.TextColor3 = THEME.Text
treasureContentTitle.TextSize = 16
treasureContentTitle.Font = FONT_BOLD
treasureContentTitle.TextXAlignment = Enum.TextXAlignment.Left
treasureContentTitle.Parent = treasureContent

local treasureGrid = Instance.new("ScrollingFrame")
treasureGrid.Size = UDim2.new(1, -30, 1, -65)
treasureGrid.Position = UDim2.new(0, 15, 0, 52)
treasureGrid.BackgroundTransparency = 1
treasureGrid.BorderSizePixel = 0
treasureGrid.ScrollBarThickness = 4
treasureGrid.ScrollBarImageColor3 = THEME.Accent
treasureGrid.CanvasSize = UDim2.new(0, 0, 0, 0)
treasureGrid.AutomaticCanvasSize = Enum.AutomaticSize.Y
treasureGrid.Parent = treasureContent

local treasureGridLayout = Instance.new("UIGridLayout")
treasureGridLayout.CellSize = UDim2.new(0, 138, 0, 165)
treasureGridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
treasureGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
treasureGridLayout.Parent = treasureGrid

local treasurePreviewPanel = Instance.new("Frame")
treasurePreviewPanel.Size = UDim2.new(0, 195, 1, -130)
treasurePreviewPanel.Position = UDim2.new(1, -215, 0, 120)
treasurePreviewPanel.BackgroundColor3 = THEME.Panel
treasurePreviewPanel.BorderSizePixel = 0
treasurePreviewPanel.Visible = false
treasurePreviewPanel.Parent = frame

local treasurePreviewCorner = Instance.new("UICorner")
treasurePreviewCorner.CornerRadius = UDim.new(0, 10)
treasurePreviewCorner.Parent = treasurePreviewPanel

local treasurePreviewStroke = Instance.new("UIStroke")
treasurePreviewStroke.Color = THEME.Border
treasurePreviewStroke.Thickness = 1
treasurePreviewStroke.Parent = treasurePreviewPanel

local treasurePreviewTitle = Instance.new("TextLabel")
treasurePreviewTitle.Size = UDim2.new(1, -20, 0, 32)
treasurePreviewTitle.Position = UDim2.new(0, 10, 0, 10)
treasurePreviewTitle.BackgroundTransparency = 1
treasurePreviewTitle.Text = "TREASURE PREVIEW"
treasurePreviewTitle.TextColor3 = THEME.TextMuted
treasurePreviewTitle.TextSize = 11
treasurePreviewTitle.Font = FONT_BOLD
treasurePreviewTitle.TextXAlignment = Enum.TextXAlignment.Left
treasurePreviewTitle.Parent = treasurePreviewPanel

local treasurePreviewViewport = Instance.new("ViewportFrame")
treasurePreviewViewport.Size = UDim2.new(1, -20, 0, 170)
treasurePreviewViewport.Position = UDim2.new(0, 10, 0, 48)
treasurePreviewViewport.BackgroundColor3 = THEME.Card
treasurePreviewViewport.BorderSizePixel = 0
treasurePreviewViewport.Parent = treasurePreviewPanel

local treasurePreviewViewportCorner = Instance.new("UICorner")
treasurePreviewViewportCorner.CornerRadius = UDim.new(0, 8)
treasurePreviewViewportCorner.Parent = treasurePreviewViewport

local treasurePreviewCamera = Instance.new("Camera")
treasurePreviewCamera.Parent = treasurePreviewViewport
treasurePreviewViewport.CurrentCamera = treasurePreviewCamera

local treasurePreviewName = Instance.new("TextLabel")
treasurePreviewName.Size = UDim2.new(1, -20, 0, 35)
treasurePreviewName.Position = UDim2.new(0, 10, 0, 228)
treasurePreviewName.BackgroundTransparency = 1
treasurePreviewName.Text = "Select a treasure"
treasurePreviewName.TextColor3 = THEME.Text
treasurePreviewName.TextSize = 14
treasurePreviewName.Font = FONT_BOLD
treasurePreviewName.TextWrapped = true
treasurePreviewName.Parent = treasurePreviewPanel

local treasurePreviewRarity = Instance.new("TextLabel")
treasurePreviewRarity.Size = UDim2.new(1, -20, 0, 24)
treasurePreviewRarity.Position = UDim2.new(0, 10, 0, 265)
treasurePreviewRarity.BackgroundTransparency = 1
treasurePreviewRarity.Text = ""
treasurePreviewRarity.TextColor3 = THEME.TextMuted
treasurePreviewRarity.TextSize = 12
treasurePreviewRarity.Font = FONT_BOLD
treasurePreviewRarity.Parent = treasurePreviewPanel

local treasureButtons = {}
local selectedTreasure = nil
local treasureCurrentCategory = "All"

local function getTreasureRarityColor(rarity)
	return rarityColors[rarity] or THEME.Unknown
end

local function updateTreasurePreview(treasureName, rarity)
	treasurePreviewName.Text = treasureName or "Select a treasure"
	treasurePreviewRarity.Text = rarity or ""
	treasurePreviewRarity.TextColor3 = getTreasureRarityColor(rarity)

	for _, child in ipairs(treasurePreviewViewport:GetChildren()) do
		if child:IsA("Model") or child:IsA("BasePart") then
			child:Destroy()
		end
	end

	if not treasureName then
		return
	end

	local source = treasureFolder:FindFirstChild(treasureName)

	if not source then
		return
	end

	local clone = source:Clone()
	clone.Parent = treasurePreviewViewport

	local model = clone

	if clone:IsA("BasePart") then
		local modelWrapper = Instance.new("Model")
		modelWrapper.Parent = treasurePreviewViewport
		clone.Parent = modelWrapper
		model = modelWrapper
	end

	if not model:IsA("Model") then
		return
	end

	local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")

	if not primaryPart then
		return
	end

	model.PrimaryPart = primaryPart
	model:PivotTo(CFrame.new(0, 0, 0))

	local _, size = model:GetBoundingBox()
	local maxSize = math.max(size.X, size.Y, size.Z)

	treasurePreviewCamera.CFrame = CFrame.new(
		0,
		size.Y * 0.25,
		math.max(maxSize * 2.5, 5)
	) * CFrame.Angles(
		math.rad(-8),
		0,
		0
	)
end

local function createTreasureCard(data)
	local card = Instance.new("TextButton")
	card.Size = UDim2.new(0, 138, 0, 165)
	card.BackgroundColor3 = THEME.Card
	card.BorderSizePixel = 0
	card.AutoButtonColor = false
	card.Text = ""
	card.Parent = treasureGrid

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 9)
	cardCorner.Parent = card

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = THEME.Border
	cardStroke.Thickness = 1
	cardStroke.Parent = card

	local viewport = Instance.new("ViewportFrame")
	viewport.Size = UDim2.new(1, -12, 0, 100)
	viewport.Position = UDim2.new(0, 6, 0, 6)
	viewport.BackgroundColor3 = THEME.Panel
	viewport.BorderSizePixel = 0
	viewport.Parent = card

	local viewportCorner = Instance.new("UICorner")
	viewportCorner.CornerRadius = UDim.new(0, 7)
	viewportCorner.Parent = viewport

	local camera = Instance.new("Camera")
	camera.Parent = viewport
	viewport.CurrentCamera = camera

	local source = treasureFolder:FindFirstChild(data.Name)

	if source then
		local clone = source:Clone()
		clone.Parent = viewport

		local model = clone

		if clone:IsA("BasePart") then
			local wrapper = Instance.new("Model")
			wrapper.Parent = viewport
			clone.Parent = wrapper
			model = wrapper
		end

		if model:IsA("Model") then
			local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")

			if primaryPart then
				model.PrimaryPart = primaryPart
				model:PivotTo(CFrame.new(0, 0, 0))

				local _, size = model:GetBoundingBox()
				local maxSize = math.max(size.X, size.Y, size.Z)

				camera.CFrame = CFrame.new(
					0,
					size.Y * 0.2,
					math.max(maxSize * 2.2, 4)
				) * CFrame.Angles(
					math.rad(-8),
					0,
					0
				)
			end
		end
	end

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -12, 0, 28)
	nameLabel.Position = UDim2.new(0, 6, 0, 108)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = data.Name
	nameLabel.TextColor3 = THEME.Text
	nameLabel.TextSize = 11
	nameLabel.Font = FONT_BOLD
	nameLabel.TextWrapped = true
	nameLabel.Parent = card

	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.new(1, -12, 0, 20)
	rarityLabel.Position = UDim2.new(0, 6, 0, 138)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text = data.Rarity or "Unknown"
	rarityLabel.TextColor3 = getTreasureRarityColor(data.Rarity)
	rarityLabel.TextSize = 10
	rarityLabel.Font = FONT_BOLD
	rarityLabel.Parent = card

	treasureButtons[data.Name] = card

	card.MouseEnter:Connect(function()
		if selectedTreasure ~= data.Name then
			card.BackgroundColor3 = THEME.CardHover
		end
	end)

	card.MouseLeave:Connect(function()
		if selectedTreasure ~= data.Name then
			card.BackgroundColor3 = THEME.Card
		end
	end)

	card.MouseButton1Click:Connect(function()
		selectedTreasure = data.Name

		for _, button in pairs(treasureButtons) do
			button.BackgroundColor3 = THEME.Card
		end

		card.BackgroundColor3 = THEME.CardSelected

		updateTreasurePreview(data.Name, data.Rarity)
	end)

	return card
end

for _, data in ipairs(treasureList) do
	createTreasureCard(data)
end

local treasureCategories = {
	"All",
	"Common",
	"Rare",
	"Super Rare",
	"Mythical",
	"Legendary",
	"Never Seen",
	"Arcana",
	"Eternal",
	"Apex"
}

local function filterTreasure()
	local search = string.lower(treasureSearchBox.Text)

	for _, data in ipairs(treasureList) do
		local card = treasureButtons[data.Name]

		if card then
			local matchesSearch = search == ""
				or string.find(string.lower(data.Name), search, 1, true)

			local matchesCategory = treasureCurrentCategory == "All"
				or data.Rarity == treasureCurrentCategory

			card.Visible = matchesSearch and matchesCategory
		end
	end
end

local treasureCategoryButtons = {}

local function updateTreasureCategoryVisuals()
	for category, button in pairs(treasureCategoryButtons) do
		if category == treasureCurrentCategory then
			button.BackgroundColor3 = THEME.CardSelected
			button.TextColor3 = THEME.Accent
		else
			button.BackgroundColor3 = THEME.Card
			button.TextColor3 = THEME.TextMuted
		end
	end
end

for index, category in ipairs(treasureCategories) do
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -4, 0, 32)
	button.BackgroundColor3 = THEME.Card
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Text = category
	button.TextColor3 = THEME.TextMuted
	button.TextSize = 11
	button.Font = FONT_BOLD
	button.LayoutOrder = index
	button.Parent = treasureCategoryList

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 7)
	buttonCorner.Parent = button

	treasureCategoryButtons[category] = button

	button.MouseEnter:Connect(function()
		if category ~= treasureCurrentCategory then
			button.BackgroundColor3 = THEME.CardHover
		end
	end)

	button.MouseLeave:Connect(function()
		if category ~= treasureCurrentCategory then
			button.BackgroundColor3 = THEME.Card
		end
	end)

	button.MouseButton1Click:Connect(function()
		treasureCurrentCategory = category
		updateTreasureCategoryVisuals()
		filterTreasure()
	end)
end

treasureSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	filterTreasure()
end)

updateTreasureCategoryVisuals()
filterTreasure()
