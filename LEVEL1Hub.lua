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

local fishFolder = ReplicatedStorage
	:WaitForChild("A__Assets")
	:WaitForChild("Fish")

local treasureFolder = ReplicatedStorage
	:WaitForChild("A__Assets")
	:WaitForChild("Treasure")

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

local addToInventoryRF = ReplicatedStorage
	:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_knit@1.7.0")
	:WaitForChild("knit")
	:WaitForChild("Services")
	:WaitForChild("FishService")
	:WaitForChild("RF")
	:WaitForChild("AddToInventory")

local treasureAddToInventoryRF = ReplicatedStorage
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

	Unknown = Color3.fromRGB(90, 95, 110),
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
	Apex = 9,
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
	Unknown = "UNKNOWN",
}

local TREASURE_RARITY_DISPLAY = {
	Common = "COMMON",
	Rare = "RARE",
	SuperRare = "SUPER RARE",
	Mythical = "MYTHICAL",
	Legendary = "LEGENDARY",
	NeverSeen = "NEVER SEEN",
	Arcana = "ARCANA",
	Eternal = "ETERNAL",
	Apex = "APEX",
	Unknown = "UNKNOWN",
}

local FishIndex = {}
local TreasureIndex = {}

local function loadFishIndex()
	table.clear(FishIndex)

	local success, data = pcall(function()
		return require(fishDataModule)
	end)

	if not success then
		warn("[Level1 Hub] Cannot require Fish Index:", data)
		return
	end

	if type(data) ~= "table" then
		warn("[Level1 Hub] Fish Index is not a table.")
		return
	end

	for fishName, fishInfo in pairs(data) do
		if type(fishInfo) == "table" and fishInfo.Rarity then
			FishIndex[tostring(fishName)] = tostring(fishInfo.Rarity)
		end
	end
end

local function loadTreasureIndex()
	table.clear(TreasureIndex)

	local success, data = pcall(function()
		return require(treasureDataModule)
	end)

	if not success then
		warn("[Level1 Hub] Cannot require Treasure Index:", data)
		return
	end

	if type(data) ~= "table" then
		warn("[Level1 Hub] Treasure Index is not a table.")
		return
	end

	for treasureName, treasureInfo in pairs(data) do
		if type(treasureInfo) == "table" and treasureInfo.Rarity then
			TreasureIndex[tostring(treasureName)] = tostring(treasureInfo.Rarity)
		end
	end
end

loadFishIndex()
loadTreasureIndex()

local function getFishRarity(fishObject)
	local fishName

	if typeof(fishObject) == "Instance" then
		fishName = fishObject.Name
	else
		fishName = tostring(fishObject)
	end

	if FishIndex[fishName] then
		return FishIndex[fishName]
	end

	if typeof(fishObject) == "Instance" then
		local rarity = fishObject:GetAttribute("Rarity")

		if rarity then
			return tostring(rarity)
		end
	end

	return "Unknown"
end

local function getTreasureRarity(treasureObject)
	local treasureName

	if typeof(treasureObject) == "Instance" then
		treasureName = treasureObject.Name
	else
		treasureName = tostring(treasureObject)
	end

	if TreasureIndex[treasureName] then
		return TreasureIndex[treasureName]
	end

	if typeof(treasureObject) == "Instance" then
		local rarity = treasureObject:GetAttribute("Rarity")

		if rarity then
			return tostring(rarity)
		end
	end

	return "Unknown"
end

local function getRarityColor(rarity)
	return THEME[rarity] or THEME.Unknown
end

local fishList = {}

for _, fish in ipairs(fishFolder:GetChildren()) do
	if fish:IsA("Model") or fish:IsA("BasePart") then
		local rarity = getFishRarity(fish)

		table.insert(fishList, {
			Object = fish,
			Name = fish.Name,
			Rarity = rarity,
			Order = RARITY_ORDER[rarity] or 999,
		})
	end
end

table.sort(fishList, function(a, b)
	if a.Order ~= b.Order then
		return a.Order < b.Order
	end

	return string.lower(a.Name) < string.lower(b.Name)
end)

for index, data in ipairs(fishList) do
	data.Order = index
end

local treasureList = {}

for _, treasure in ipairs(treasureFolder:GetChildren()) do
	if treasure:IsA("Model") or treasure:IsA("BasePart") then
		local rarity = getTreasureRarity(treasure)

		table.insert(treasureList, {
			Object = treasure,
			Name = treasure.Name,
			Rarity = rarity,
			Order = RARITY_ORDER[rarity] or 999,
		})
	end
end

table.sort(treasureList, function(a, b)
	if a.Order ~= b.Order then
		return a.Order < b.Order
	end

	return string.lower(a.Name) < string.lower(b.Name)
end)

for index, data in ipairs(treasureList) do
	data.Order = index
end

local gui = Instance.new("ScreenGui")
gui.Name = "FishCatcherGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.new(0, 0, 0, 0)
frame.Position = UDim2.new(0.5, 450, 0.5, -280)
frame.AnchorPoint = Vector2.new(1, 0)
frame.BackgroundColor3 = THEME.Background
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Color = THEME.Border
frameStroke.Thickness = 1.5

local normalSize = UDim2.new(0, 900, 0, 560)
local minimizedSize = UDim2.new(0, 300, 0, 68)
local isMinimized = false

TweenService:Create(
	frame,
	TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	{
		Size = normalSize
	}
):Play()

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 68)
header.BackgroundTransparency = 1
header.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 300, 0, 30)
title.Position = UDim2.new(0, 25, 0, 10)
title.BackgroundTransparency = 1
title.Text = "🐟  LEVEL1 HUB"
title.TextColor3 = THEME.Text
title.Font = FONT_BOLD
title.TextSize = 21
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local gameTitle = Instance.new("TextLabel")
gameTitle.Size = UDim2.new(0, 400, 0, 18)
gameTitle.Position = UDim2.new(0, 27, 0, 38)
gameTitle.BackgroundTransparency = 1
gameTitle.Text = "BECOME A DEEP SEA EXPLORER"
gameTitle.TextColor3 = THEME.TextMuted
gameTitle.Font = FONT_REGULAR
gameTitle.TextSize = 10
gameTitle.TextXAlignment = Enum.TextXAlignment.Left
gameTitle.Parent = header

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 34, 0, 34)
minimize.Position = UDim2.new(1, -88, 0, 16)
minimize.Text = "—"
minimize.BackgroundColor3 = THEME.Card
minimize.TextColor3 = THEME.TextMuted
minimize.Font = FONT_BOLD
minimize.TextSize = 18
minimize.BorderSizePixel = 0
minimize.AutoButtonColor = false
minimize.ZIndex = 5
minimize.Parent = frame

Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 9)

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 34, 0, 34)
close.Position = UDim2.new(1, -48, 0, 16)
close.Text = "X"
close.BackgroundColor3 = THEME.Card
close.TextColor3 = THEME.TextMuted
close.Font = FONT_BOLD
close.TextSize = 13
close.BorderSizePixel = 0
close.AutoButtonColor = false
close.ZIndex = 5
close.Parent = frame

Instance.new("UICorner", close).CornerRadius = UDim.new(0, 9)

minimize.MouseEnter:Connect(function()
	TweenService:Create(minimize, TweenInfo.new(0.15), {
		BackgroundColor3 = THEME.CardHover,
		TextColor3 = THEME.Text
	}):Play()
end)

minimize.MouseLeave:Connect(function()
	TweenService:Create(minimize, TweenInfo.new(0.15), {
		BackgroundColor3 = THEME.Card,
		TextColor3 = THEME.TextMuted
	}):Play()
end)

close.MouseEnter:Connect(function()
	TweenService:Create(close, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(220, 65, 75),
		TextColor3 = Color3.new(1, 1, 1)
	}):Play()
end)

close.MouseLeave:Connect(function()
	TweenService:Create(close, TweenInfo.new(0.15), {
		BackgroundColor3 = THEME.Card,
		TextColor3 = THEME.TextMuted
	}):Play()
end)

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, -40, 0, 42)
tabBar.Position = UDim2.new(0, 20, 0, 68)
tabBar.BackgroundColor3 = THEME.Panel
tabBar.BorderSizePixel = 0
tabBar.Parent = frame

Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 10)

local tabStroke = Instance.new("UIStroke", tabBar)
tabStroke.Color = THEME.Border
tabStroke.Thickness = 1

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 5)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabBar

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingLeft = UDim.new(0, 5)
tabPadding.PaddingRight = UDim.new(0, 5)
tabPadding.PaddingTop = UDim.new(0, 5)
tabPadding.PaddingBottom = UDim.new(0, 5)
tabPadding.Parent = tabBar

local tabs = {}
local pages = {}
local currentTab = "Fish"

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

	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)

	tabs[name] = button

	button.MouseEnter:Connect(function()
		if currentTab ~= name then
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

	return button
end

createTab("Fish", 1)
createTab("Treasure", 2)
createTab("Teleport", 3)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 165, 1, -130)
sidebar.Position = UDim2.new(0, 20, 0, 120)
sidebar.BackgroundColor3 = THEME.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = frame

Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)

local sideStroke = Instance.new("UIStroke", sidebar)
sideStroke.Color = THEME.Border
sideStroke.Thickness = 1

local sideTitle = Instance.new("TextLabel")
sideTitle.Size = UDim2.new(1, -20, 0, 25)
sideTitle.Position = UDim2.new(0, 10, 0, 12)
sideTitle.BackgroundTransparency = 1
sideTitle.Text = "RARITY"
sideTitle.TextColor3 = THEME.TextMuted
sideTitle.Font = FONT_BOLD
sideTitle.TextSize = 11
sideTitle.TextXAlignment = Enum.TextXAlignment.Left
sideTitle.Parent = sidebar

local categoryContainer = Instance.new("Frame")
categoryContainer.Name = "CategoryContainer"
categoryContainer.Size = UDim2.new(1, -20, 1, -48)
categoryContainer.Position = UDim2.new(0, 10, 0, 40)
categoryContainer.BackgroundTransparency = 1
categoryContainer.Parent = sidebar

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 5)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.VerticalAlignment = Enum.VerticalAlignment.Top
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Parent = categoryContainer

local content = Instance.new("Frame")
content.Name = "FishPage"
content.Size = UDim2.new(0, 400, 1, -130)
content.Position = UDim2.new(0, 200, 0, 120)
content.BackgroundTransparency = 1
content.Parent = frame

pages.Fish = content

local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(1, 0, 0, 42)
searchFrame.BackgroundColor3 = THEME.Panel
searchFrame.BorderSizePixel = 0
searchFrame.Parent = content

Instance.new("UICorner", searchFrame).CornerRadius = UDim.new(0, 10)

local searchStroke = Instance.new("UIStroke", searchFrame)
searchStroke.Color = THEME.Border

local search = Instance.new("TextBox")
search.Size = UDim2.new(1, -20, 1, 0)
search.Position = UDim2.new(0, 10, 0, 0)
search.Text = ""
search.PlaceholderText = "Search Fish . . ."
search.BackgroundTransparency = 1
search.TextColor3 = THEME.Text
search.PlaceholderColor3 = THEME.TextMuted
search.Font = FONT_REGULAR
search.TextSize = 13
search.ClearTextOnFocus = false
search.TextXAlignment = Enum.TextXAlignment.Left
search.Parent = searchFrame

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, 0, 1, -55)
list.Position = UDim2.new(0, 0, 0, 55)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.ScrollBarImageColor3 = THEME.Accent
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = content

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0, 125, 0, 125)
grid.CellPadding = UDim2.new(0, 9, 0, 9)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = list

local previewPanel = Instance.new("Frame")
previewPanel.Size = UDim2.new(0, 275, 1, -130)
previewPanel.Position = UDim2.new(1, -295, 0, 120)
previewPanel.BackgroundColor3 = THEME.Sidebar
previewPanel.BorderSizePixel = 0
previewPanel.Parent = frame

Instance.new("UICorner", previewPanel).CornerRadius = UDim.new(0, 12)

local previewStroke = Instance.new("UIStroke", previewPanel)
previewStroke.Color = THEME.Border
previewStroke.Thickness = 1

local previewHeader = Instance.new("TextLabel")
previewHeader.Size = UDim2.new(1, -25, 0, 20)
previewHeader.Position = UDim2.new(0, 13, 0, 13)
previewHeader.BackgroundTransparency = 1
previewHeader.Text = "SPECIMEN PREVIEW"
previewHeader.TextColor3 = THEME.TextMuted
previewHeader.Font = FONT_BOLD
previewHeader.TextSize = 10
previewHeader.TextXAlignment = Enum.TextXAlignment.Left
previewHeader.Parent = previewPanel

local previewTitle = Instance.new("TextLabel")
previewTitle.Size = UDim2.new(1, -20, 0, 42)
previewTitle.Position = UDim2.new(0, 10, 0, 38)
previewTitle.BackgroundTransparency = 1
previewTitle.Text = "NO FISH SELECTED"
previewTitle.TextColor3 = THEME.Text
previewTitle.Font = FONT_BOLD
previewTitle.TextSize = 15
previewTitle.TextWrapped = true
previewTitle.Parent = previewPanel

local previewRarity = Instance.new("TextLabel")
previewRarity.Size = UDim2.new(1, -20, 0, 22)
previewRarity.Position = UDim2.new(0, 10, 0, 80)
previewRarity.BackgroundTransparency = 1
previewRarity.Text = "SELECT A FISH"
previewRarity.TextColor3 = THEME.TextMuted
previewRarity.Font = FONT_BOLD
previewRarity.TextSize = 10
previewRarity.Parent = previewPanel

local viewport = Instance.new("ViewportFrame")
viewport.Size = UDim2.new(1, -35, 0, 285)
viewport.Position = UDim2.new(0, 17, 0, 108)
viewport.BackgroundColor3 = Color3.fromRGB(10, 12, 17)
viewport.BorderSizePixel = 0
viewport.Ambient = Color3.fromRGB(200, 200, 200)
viewport.LightColor = Color3.fromRGB(255, 255, 255)
viewport.LightDirection = Vector3.new(-1, -1, -1)
viewport.Parent = previewPanel

Instance.new("UICorner", viewport).CornerRadius = UDim.new(0, 12)

local viewportCamera
local previewWorld
local previewClone
local previewBasePivot

local previewRotation = 0
local previewDragging = false
local previewLastX = 0

local function getModelBounds(object)
	if object:IsA("Model") then
		return object:GetBoundingBox()
	elseif object:IsA("BasePart") then
		return object.CFrame, object.Size
	end

	return nil, nil
end

local function centerPreviewObject(object)
	local cf, size = getModelBounds(object)

	if not cf then
		return nil, nil
	end

	local center = cf.Position

	if object:IsA("Model") then
		local pivot = object:GetPivot()

		local newPivot =
			CFrame.new(pivot.Position - center)
			* pivot.Rotation

		object:PivotTo(newPivot)
	elseif object:IsA("BasePart") then
		local rotation = object.CFrame - object.CFrame.Position

		object.CFrame =
			CFrame.new(-center)
			* rotation
	end

	local newCF, newSize = getModelBounds(object)

	return newCF, newSize
end

local function preparePreviewObject(object)
	if object:IsA("BasePart") then
		object.Anchored = true
		object.CanCollide = false
		object.CanTouch = false
		object.CanQuery = false
		object.CastShadow = true
	end

	for _, descendant in ipairs(object:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.CastShadow = true
		elseif descendant:IsA("Script")
			or descendant:IsA("LocalScript")
			or descendant:IsA("ModuleScript") then
			descendant:Destroy()
		end
	end
end

local function setPreviewRotation()
	if not previewClone or not previewBasePivot then
		return
	end

	local rotation =
		CFrame.Angles(
			0,
			math.rad(previewRotation),
			0
		)

	local pivot =
		rotation
		* previewBasePivot

	if previewClone:IsA("Model") then
		previewClone:PivotTo(pivot)
	elseif previewClone:IsA("BasePart") then
		previewClone.CFrame = pivot
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

	local cameraDistance =
		math.max(maxSize * 2.25, 4)

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
	rarityLabel.Text = RARITY_DISPLAY[rarity] or string.upper(rarity)
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
			local miniRotation = CFrame.Angles(0, math.rad(180), 0)

			if miniClone:IsA("Model") then
				miniClone:PivotTo(miniRotation * miniClone:GetPivot())
			elseif miniClone:IsA("BasePart") then
				miniClone.CFrame = miniRotation * miniClone.CFrame
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
				Vector3.new(0, miniMax * 0.03, distance),
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
			TweenService:Create(button, TweenInfo.new(0.15), {
				BackgroundColor3 = THEME.CardHover
			}):Play()
		end

		TweenService:Create(stroke, TweenInfo.new(0.15), {
			Color = rarityColor
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		if selectedButton ~= button then
			TweenService:Create(button, TweenInfo.new(0.15), {
				BackgroundColor3 = THEME.Card
			}):Play()

			TweenService:Create(stroke, TweenInfo.new(0.15), {
				Color = THEME.Border
			}):Play()
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

grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

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
	local searchText = string.lower(search.Text or "")

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
		local isSelected = category == currentCategory

		if isSelected then
			button.BackgroundTransparency = 0
			button.BackgroundColor3 = THEME.CardSelected
			button.TextColor3 = getRarityColor(category)
		else
			button.BackgroundTransparency = 1
			button.BackgroundColor3 = THEME.Card
			button.TextColor3 = THEME.TextMuted
		end

		local accent = button:FindFirstChild("SelectedAccent")

		if accent then
			accent.Visible = true
			accent.BackgroundColor3 = getRarityColor(category)
		end
	end
end

for index, category in ipairs(categories) do
	local categoryButton = Instance.new("TextButton")
	categoryButton.Name = category
	categoryButton.Size = UDim2.new(1, 0, 0, 36)
	categoryButton.BackgroundColor3 = THEME.Card
	categoryButton.BackgroundTransparency = 1
	categoryButton.BorderSizePixel = 0
	categoryButton.Text = RARITY_DISPLAY[category] or string.upper(category)
	categoryButton.TextColor3 = THEME.TextMuted
	categoryButton.Font = FONT_BOLD
	categoryButton.TextSize = 9
	categoryButton.LayoutOrder = index
	categoryButton.AutoButtonColor = false
	categoryButton.Parent = categoryContainer

	Instance.new("UICorner", categoryButton).CornerRadius = UDim.new(0, 8)

	categoryButtons[category] = categoryButton

	local accent = Instance.new("Frame")
	accent.Name = "SelectedAccent"
	accent.Size = UDim2.new(0, 3, 1, -10)
	accent.Position = UDim2.new(0, 5, 0, 5)
	accent.BackgroundColor3 = getRarityColor(category)
	accent.BorderSizePixel = 0
	accent.Visible = true
	accent.Parent = categoryButton

	Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

	categoryButton.MouseEnter:Connect(function()
		if currentCategory ~= category then
			TweenService:Create(categoryButton, TweenInfo.new(0.12), {
				BackgroundTransparency = 0,
				BackgroundColor3 = THEME.CardHover
			}):Play()
		end
	end)

	categoryButton.MouseLeave:Connect(function()
		if currentCategory ~= category then
			TweenService:Create(categoryButton, TweenInfo.new(0.12), {
				BackgroundTransparency = 1
			}):Play()
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
catchButton.Size = UDim2.new(1, -35, 0, 45)
catchButton.Position = UDim2.new(0, 17, 1, -60)
catchButton.Text = "CATCH FISH"
catchButton.BackgroundColor3 = THEME.Card
catchButton.TextColor3 = THEME.TextMuted
catchButton.Font = FONT_BOLD
catchButton.TextSize = 12
catchButton.BorderSizePixel = 0
catchButton.AutoButtonColor = false
catchButton.Parent = previewPanel

Instance.new("UICorner", catchButton).CornerRadius = UDim.new(0, 9)

catchButtonStroke = Instance.new("UIStroke", catchButton)
catchButtonStroke.Color = THEME.Border
catchButtonStroke.Thickness = 1

catchButton.MouseEnter:Connect(function()
	if selectedFish then
		TweenService:Create(catchButton, TweenInfo.new(0.15), {
			BackgroundColor3 = THEME.Accent
		}):Play()

		TweenService:Create(catchButtonStroke, TweenInfo.new(0.15), {
			Color = THEME.Accent
		}):Play()

		catchButton.TextColor3 = Color3.fromRGB(5, 15, 20)
	end
end)

catchButton.MouseLeave:Connect(function()
	if selectedFish then
		TweenService:Create(catchButton, TweenInfo.new(0.15), {
			BackgroundColor3 = THEME.AccentDark
		}):Play()

		catchButton.TextColor3 = Color3.new(1, 1, 1)
	else
		TweenService:Create(catchButton, TweenInfo.new(0.15), {
			BackgroundColor3 = THEME.Card
		}):Play()

		catchButton.TextColor3 = THEME.TextMuted
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
		catchButton.BackgroundColor3 = Color3.fromRGB(50, 190, 110)
		catchButton.TextColor3 = Color3.new(1, 1, 1)

		task.delay(0.8, function()
			if catchButton.Parent then
				catchButton.Text = "CATCH FISH"
				catchButton.BackgroundColor3 = THEME.Accent
				catchButton.TextColor3 = Color3.fromRGB(5, 15, 20)
				catchButton.Active = true
			end
		end)
	else
		warn("[Level1 Hub] AddToInventory failed:", result)

		catchButton.Text = "FAILED"
		catchButton.BackgroundColor3 = Color3.fromRGB(210, 65, 75)
		catchButton.TextColor3 = Color3.new(1, 1, 1)

		task.delay(1, function()
			if catchButton.Parent then
				catchButton.Text = "CATCH FISH"
				catchButton.BackgroundColor3 = THEME.Accent
				catchButton.TextColor3 = Color3.fromRGB(5, 15, 20)
				catchButton.Active = true
			end
		end)
	end
end)

catchButton.BackgroundColor3 = THEME.Card
catchButton.TextColor3 = THEME.TextMuted
catchButton.Active = true

local treasureSidebar = Instance.new("Frame")
treasureSidebar.Size = UDim2.new(0, 165, 1, -130)
treasureSidebar.Position = UDim2.new(0, 20, 0, 120)
treasureSidebar.BackgroundColor3 = THEME.Sidebar
treasureSidebar.BorderSizePixel = 0
treasureSidebar.Visible = false
treasureSidebar.Parent = frame

Instance.new("UICorner", treasureSidebar).CornerRadius = UDim.new(0, 12)

local treasureSideStroke = Instance.new("UIStroke", treasureSidebar)
treasureSideStroke.Color = THEME.Border
treasureSideStroke.Thickness = 1

local treasureSideTitle = Instance.new("TextLabel")
treasureSideTitle.Size = UDim2.new(1, -20, 0, 25)
treasureSideTitle.Position = UDim2.new(0, 10, 0, 12)
treasureSideTitle.BackgroundTransparency = 1
treasureSideTitle.Text = "RARITY"
treasureSideTitle.TextColor3 = THEME.TextMuted
treasureSideTitle.Font = FONT_BOLD
treasureSideTitle.TextSize = 11
treasureSideTitle.TextXAlignment = Enum.TextXAlignment.Left
treasureSideTitle.Parent = treasureSidebar

local treasureCategoryContainer = Instance.new("Frame")
treasureCategoryContainer.Name = "CategoryContainer"
treasureCategoryContainer.Size = UDim2.new(1, -20, 1, -48)
treasureCategoryContainer.Position = UDim2.new(0, 10, 0, 40)
treasureCategoryContainer.BackgroundTransparency = 1
treasureCategoryContainer.Parent = treasureSidebar

local treasureSideLayout = Instance.new("UIListLayout")
treasureSideLayout.Padding = UDim.new(0, 5)
treasureSideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
treasureSideLayout.VerticalAlignment = Enum.VerticalAlignment.Top
treasureSideLayout.SortOrder = Enum.SortOrder.LayoutOrder
treasureSideLayout.Parent = treasureCategoryContainer

local treasureContent = Instance.new("Frame")
treasureContent.Name = "TreasurePage"
treasureContent.Size = UDim2.new(0, 400, 1, -130)
treasureContent.Position = UDim2.new(0, 200, 0, 120)
treasureContent.BackgroundTransparency = 1
treasureContent.Visible = false
treasureContent.Parent = frame

pages.Treasure = treasureContent

local treasureSearchFrame = Instance.new("Frame")
treasureSearchFrame.Size = UDim2.new(1, 0, 0, 42)
treasureSearchFrame.Position = UDim2.new(0, 0, 0, 0)
treasureSearchFrame.BackgroundColor3 = THEME.Panel
treasureSearchFrame.BorderSizePixel = 0
treasureSearchFrame.Parent = treasureContent

Instance.new("UICorner", treasureSearchFrame).CornerRadius = UDim.new(0, 10)

local treasureSearchStroke = Instance.new("UIStroke", treasureSearchFrame)
treasureSearchStroke.Color = THEME.Border
treasureSearchStroke.Thickness = 1

local treasureSearch = Instance.new("TextBox")
treasureSearch.Size = UDim2.new(1, -20, 1, 0)
treasureSearch.Position = UDim2.new(0, 10, 0, 0)
treasureSearch.Text = ""
treasureSearch.PlaceholderText = "Search Treasure . . ."
treasureSearch.BackgroundTransparency = 1
treasureSearch.TextColor3 = THEME.Text
treasureSearch.PlaceholderColor3 = THEME.TextMuted
treasureSearch.Font = FONT_REGULAR
treasureSearch.TextSize = 13
treasureSearch.ClearTextOnFocus = false
treasureSearch.TextXAlignment = Enum.TextXAlignment.Left
treasureSearch.Parent = treasureSearchFrame

local treasureListFrame = Instance.new("ScrollingFrame")
treasureListFrame.Size = UDim2.new(1, 0, 1, -55)
treasureListFrame.Position = UDim2.new(0, 0, 0, 55)
treasureListFrame.BackgroundTransparency = 1
treasureListFrame.BorderSizePixel = 0
treasureListFrame.ScrollBarThickness = 3
treasureListFrame.ScrollBarImageColor3 = THEME.Accent
treasureListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
treasureListFrame.Parent = treasureContent

local treasureGrid = Instance.new("UIGridLayout")
treasureGrid.CellSize = UDim2.new(0, 125, 0, 125)
treasureGrid.CellPadding = UDim2.new(0, 9, 0, 9)
treasureGrid.SortOrder = Enum.SortOrder.LayoutOrder
treasureGrid.Parent = treasureListFrame

local treasurePreviewPanel = Instance.new("Frame")
treasurePreviewPanel.Size = UDim2.new(0, 275, 1, -130)
treasurePreviewPanel.Position = UDim2.new(1, -295, 0, 120)
treasurePreviewPanel.BackgroundColor3 = THEME.Sidebar
treasurePreviewPanel.BorderSizePixel = 0
treasurePreviewPanel.Visible = false
treasurePreviewPanel.Parent = frame

Instance.new("UICorner", treasurePreviewPanel).CornerRadius = UDim.new(0, 12)

local treasurePreviewStroke = Instance.new("UIStroke", treasurePreviewPanel)
treasurePreviewStroke.Color = THEME.Border
treasurePreviewStroke.Thickness = 1

local treasurePreviewHeader = Instance.new("TextLabel")
treasurePreviewHeader.Size = UDim2.new(1, -25, 0, 20)
treasurePreviewHeader.Position = UDim2.new(0, 13, 0, 13)
treasurePreviewHeader.BackgroundTransparency = 1
treasurePreviewHeader.Text = "TREASURE PREVIEW"
treasurePreviewHeader.TextColor3 = THEME.TextMuted
treasurePreviewHeader.Font = FONT_BOLD
treasurePreviewHeader.TextSize = 10
treasurePreviewHeader.TextXAlignment = Enum.TextXAlignment.Left
treasurePreviewHeader.Parent = treasurePreviewPanel

local treasurePreviewTitle = Instance.new("TextLabel")
treasurePreviewTitle.Size = UDim2.new(1, -20, 0, 42)
treasurePreviewTitle.Position = UDim2.new(0, 10, 0, 38)
treasurePreviewTitle.BackgroundTransparency = 1
treasurePreviewTitle.Text = "NO TREASURE SELECTED"
treasurePreviewTitle.TextColor3 = THEME.Text
treasurePreviewTitle.Font = FONT_BOLD
treasurePreviewTitle.TextSize = 15
treasurePreviewTitle.TextWrapped = true
treasurePreviewTitle.Parent = treasurePreviewPanel

local treasurePreviewInfo = Instance.new("TextLabel")
treasurePreviewInfo.Size = UDim2.new(1, -20, 0, 22)
treasurePreviewInfo.Position = UDim2.new(0, 10, 0, 80)
treasurePreviewInfo.BackgroundTransparency = 1
treasurePreviewInfo.Text = "SELECT A TREASURE"
treasurePreviewInfo.TextColor3 = THEME.TextMuted
treasurePreviewInfo.Font = FONT_BOLD
treasurePreviewInfo.TextSize = 10
treasurePreviewInfo.Parent = treasurePreviewPanel

local treasureViewport = Instance.new("ViewportFrame")
treasureViewport.Size = UDim2.new(1, -35, 0, 285)
treasureViewport.Position = UDim2.new(0, 17, 0, 108)
treasureViewport.BackgroundColor3 = Color3.fromRGB(10, 12, 17)
treasureViewport.BorderSizePixel = 0
treasureViewport.Ambient = Color3.fromRGB(200, 200, 200)
treasureViewport.LightColor = Color3.fromRGB(255, 255, 255)
treasureViewport.LightDirection = Vector3.new(-1, -1, -1)
treasureViewport.Parent = treasurePreviewPanel

Instance.new("UICorner", treasureViewport).CornerRadius = UDim.new(0, 12)

local treasureViewportCamera
local treasurePreviewWorld
local treasurePreviewClone
local treasurePreviewBasePivot
local treasurePreviewRotation = 0
local treasurePreviewDragging = false
local treasurePreviewLastX = 0

local function setTreasurePreviewRotation()
	if not treasurePreviewClone or not treasurePreviewBasePivot then
		return
	end

	local rotation = CFrame.Angles(
		0,
		math.rad(treasurePreviewRotation),
		0
	)

	local pivot = rotation * treasurePreviewBasePivot

	if treasurePreviewClone:IsA("Model") then
		treasurePreviewClone:PivotTo(pivot)
	elseif treasurePreviewClone:IsA("BasePart") then
		treasurePreviewClone.CFrame = pivot
	end
end

local function updateTreasurePreview(treasureName, rarity)
	treasureViewport:ClearAllChildren()

	treasurePreviewWorld = nil
	treasurePreviewClone = nil
	treasurePreviewBasePivot = nil
	treasureViewportCamera = nil
	treasurePreviewRotation = 0
	treasurePreviewDragging = false

	local targetTreasure = treasureFolder:FindFirstChild(treasureName)

	if not targetTreasure then
		treasurePreviewTitle.Text = "NO TREASURE SELECTED"
		treasurePreviewInfo.Text = "SELECT A TREASURE"
		treasurePreviewInfo.TextColor3 = THEME.TextMuted
		return
	end

	treasurePreviewWorld = Instance.new("WorldModel")
	treasurePreviewWorld.Name = "TreasurePreviewWorld"
	treasurePreviewWorld.Parent = treasureViewport

	local success, clone = pcall(function()
		return targetTreasure:Clone()
	end)

	if not success or not clone then
		treasurePreviewTitle.Text = "PREVIEW ERROR"
		treasurePreviewInfo.Text = "CLONE FAILED"
		treasurePreviewInfo.TextColor3 = Color3.fromRGB(255, 85, 85)
		return
	end

	clone.Parent = treasurePreviewWorld
	treasurePreviewClone = clone

	preparePreviewObject(clone)

	local centeredCF, centeredSize = centerPreviewObject(clone)

	if not centeredCF or not centeredSize then
		treasurePreviewTitle.Text = "PREVIEW ERROR"
		treasurePreviewInfo.Text = "INVALID MODEL"
		treasurePreviewInfo.TextColor3 = Color3.fromRGB(255, 85, 85)
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
	camera.Name = "TreasurePreviewCamera"
	camera.FieldOfView = 35
	camera.Parent = treasureViewport

	treasureViewport.CurrentCamera = camera
	treasureViewportCamera = camera

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
		treasurePreviewBasePivot = clone:GetPivot() * sideRotation
	elseif clone:IsA("BasePart") then
		treasurePreviewBasePivot = clone.CFrame * sideRotation
	end

	setTreasurePreviewRotation()

	local treasureRarity = rarity or getTreasureRarity(treasureName)
	local rarityColor = getRarityColor(treasureRarity)

	treasurePreviewTitle.Text = string.upper(treasureName)
	treasurePreviewInfo.Text =
		TREASURE_RARITY_DISPLAY[treasureRarity]
		or string.upper(treasureRarity)
	treasurePreviewInfo.TextColor3 = rarityColor
end

treasureViewport.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		treasurePreviewDragging = true
		treasurePreviewLastX = input.Position.X
	end
end)

UIS.InputChanged:Connect(function(input)
	if not treasurePreviewDragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local currentX = input.Position.X
		local delta = currentX - treasurePreviewLastX

		treasurePreviewLastX = currentX
		treasurePreviewRotation += delta * 0.6

		if treasurePreviewRotation > 360 then
			treasurePreviewRotation -= 360
		elseif treasurePreviewRotation < -360 then
			treasurePreviewRotation += 360
		end

		setTreasurePreviewRotation()
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		treasurePreviewDragging = false
	end
end)

local selectedTreasure = nil
local selectedTreasureButton = nil
local selectedTreasureStroke = nil
local selectedTreasureRarity = nil

local collectTreasureButton
local collectTreasureButtonStroke

local treasureButtons = {}

local function createTreasureCard(data)
	local treasure = data.Object
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
	button:SetAttribute("Rarity", rarity)
	button.Parent = treasureListFrame

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

	local treasureLabel = Instance.new("TextLabel")
	treasureLabel.Size = UDim2.new(1, -25, 0, 16)
	treasureLabel.Position = UDim2.new(0, 21, 0, 5)
	treasureLabel.BackgroundTransparency = 1
	treasureLabel.Text = TREASURE_RARITY_DISPLAY[rarity] or string.upper(rarity)
	treasureLabel.TextColor3 = rarityColor
	treasureLabel.Font = FONT_BOLD
	treasureLabel.TextSize = 7
	treasureLabel.TextXAlignment = Enum.TextXAlignment.Left
	treasureLabel.Parent = button

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
		return treasure:Clone()
	end)

	if cloneSuccess and miniClone then
		miniClone.Parent = miniWorld

		preparePreviewObject(miniClone)

		local miniCF, miniSize = centerPreviewObject(miniClone)

		if miniCF and miniSize then
			local miniRotation = CFrame.Angles(0, math.rad(180), 0)

			if miniClone:IsA("Model") then
				miniClone:PivotTo(miniRotation * miniClone:GetPivot())
			elseif miniClone:IsA("BasePart") then
				miniClone.CFrame = miniRotation * miniClone.CFrame
			end

			local miniCamera = Instance.new("Camera")
			miniCamera.FieldOfView = 38
			miniCamera.Parent = miniViewport
			miniViewport.CurrentCamera = miniCamera

			local miniMax = math.max(
				miniSize.X,
				miniSize.Y,
				miniSize.Z
			)

			local distance = math.max(
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

	local treasureNameLabel = Instance.new("TextLabel")
	treasureNameLabel.Size = UDim2.new(1, -12, 0, 25)
	treasureNameLabel.Position = UDim2.new(0, 6, 1, -31)
	treasureNameLabel.BackgroundTransparency = 1
	treasureNameLabel.Text = name
	treasureNameLabel.TextColor3 = THEME.Text
	treasureNameLabel.Font = FONT_REGULAR
	treasureNameLabel.TextSize = 10
	treasureNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	treasureNameLabel.Parent = button

	local accentBar = Instance.new("Frame")
	accentBar.Size = UDim2.new(1, 0, 0, 3)
	accentBar.Position = UDim2.new(0, 0, 1, -3)
	accentBar.BackgroundColor3 = rarityColor
	accentBar.BorderSizePixel = 0
	accentBar.Parent = button

	Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 2)

	button.MouseEnter:Connect(function()
		if selectedTreasureButton ~= button then
			TweenService:Create(button, TweenInfo.new(0.15), {
				BackgroundColor3 = THEME.CardHover
			}):Play()
		end

		TweenService:Create(stroke, TweenInfo.new(0.15), {
			Color = rarityColor
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		if selectedTreasureButton ~= button then
			TweenService:Create(button, TweenInfo.new(0.15), {
				BackgroundColor3 = THEME.Card
			}):Play()

			TweenService:Create(stroke, TweenInfo.new(0.15), {
				Color = THEME.Border
			}):Play()
		end
	end)

	button.MouseButton1Click:Connect(function()
		if selectedTreasureButton and selectedTreasureButton ~= button then
			selectedTreasureButton.BackgroundColor3 = THEME.Card

			if selectedTreasureStroke then
				selectedTreasureStroke.Color = THEME.Border
			end
		end

		selectedTreasureButton = button
		selectedTreasureStroke = stroke
		selectedTreasure = name
		selectedTreasureRarity = rarity

		button.BackgroundColor3 = THEME.CardSelected
		stroke.Color = rarityColor

		collectTreasureButton.BackgroundColor3 = THEME.Accent
		collectTreasureButton.TextColor3 = Color3.fromRGB(5, 15, 20)
		collectTreasureButtonStroke.Color = THEME.Accent

		updateTreasurePreview(name, rarity)
	end)

	treasureButtons[name] = {
		Button = button,
		Rarity = rarity,
		Data = data
	}
end

for _, data in ipairs(treasureList) do
	createTreasureCard(data)
end

local function updateTreasureCanvas()
	treasureListFrame.CanvasSize = UDim2.new(
		0,
		0,
		0,
		treasureGrid.AbsoluteContentSize.Y + 10
	)
end

treasureGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTreasureCanvas)

task.defer(updateTreasureCanvas)

local treasureCategories = {
	"Common",
	"Rare",
	"SuperRare",
	"Mythical",
	"Legendary",
}

local currentTreasureCategory = nil
local treasureCategoryButtons = {}

local function filterTreasure()
	local searchText = string.lower(treasureSearch.Text or "")

	if currentTreasureCategory == nil then
		treasureGrid.SortOrder = Enum.SortOrder.LayoutOrder
	else
		treasureGrid.SortOrder = Enum.SortOrder.Name
	end

	for name, item in pairs(treasureButtons) do
		local searchMatch =
			searchText == ""
			or string.find(
				string.lower(name),
				searchText,
				1,
				true
			)

		local categoryMatch =
			currentTreasureCategory == nil
			or item.Rarity == currentTreasureCategory

		item.Button.Visible =
			searchMatch and categoryMatch
	end

	task.defer(updateTreasureCanvas)
end

local function updateTreasureCategoryVisuals()
	for category, button in pairs(treasureCategoryButtons) do
		local isSelected = category == currentTreasureCategory

		if isSelected then
			button.BackgroundTransparency = 0
			button.BackgroundColor3 = THEME.CardSelected
			button.TextColor3 = getRarityColor(category)
		else
			button.BackgroundTransparency = 1
			button.BackgroundColor3 = THEME.Card
			button.TextColor3 = THEME.TextMuted
		end

		local accent = button:FindFirstChild("SelectedAccent")

		if accent then
			accent.Visible = true
			accent.BackgroundColor3 = getRarityColor(category)
		end
	end
end

for index, category in ipairs(treasureCategories) do
	local categoryButton = Instance.new("TextButton")
	categoryButton.Name = category
	categoryButton.Size = UDim2.new(1, 0, 0, 36)
	categoryButton.BackgroundColor3 = THEME.Card
	categoryButton.BackgroundTransparency = 1
	categoryButton.BorderSizePixel = 0
	categoryButton.Text = TREASURE_RARITY_DISPLAY[category] or string.upper(category)
	categoryButton.TextColor3 = THEME.TextMuted
	categoryButton.Font = FONT_BOLD
	categoryButton.TextSize = 9
	categoryButton.LayoutOrder = index
	categoryButton.AutoButtonColor = false
	categoryButton.Parent = treasureCategoryContainer

	Instance.new("UICorner", categoryButton).CornerRadius = UDim.new(0, 8)

	treasureCategoryButtons[category] = categoryButton

	local accent = Instance.new("Frame")
	accent.Name = "SelectedAccent"
	accent.Size = UDim2.new(0, 3, 1, -10)
	accent.Position = UDim2.new(0, 5, 0, 5)
	accent.BackgroundColor3 = getRarityColor(category)
	accent.BorderSizePixel = 0
	accent.Visible = true
	accent.Parent = categoryButton

	Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)

	categoryButton.MouseEnter:Connect(function()
		if currentTreasureCategory ~= category then
			TweenService:Create(categoryButton, TweenInfo.new(0.12), {
				BackgroundTransparency = 0,
				BackgroundColor3 = THEME.CardHover
			}):Play()
		end
	end)

	categoryButton.MouseLeave:Connect(function()
		if currentTreasureCategory ~= category then
			TweenService:Create(categoryButton, TweenInfo.new(0.12), {
				BackgroundTransparency = 1
			}):Play()
		end
	end)

	categoryButton.MouseButton1Click:Connect(function()
		if currentTreasureCategory == category then
			currentTreasureCategory = nil
		else
			currentTreasureCategory = category
		end

		updateTreasureCategoryVisuals()
		filterTreasure()
	end)
end

updateTreasureCategoryVisuals()

treasureSearch:GetPropertyChangedSignal("Text"):Connect(function()
	filterTreasure()
end)

collectTreasureButton = Instance.new("TextButton")
collectTreasureButton.Size = UDim2.new(1, -35, 0, 45)
collectTreasureButton.Position = UDim2.new(0, 17, 1, -60)
collectTreasureButton.Text = "COLLECT TREASURE"
collectTreasureButton.BackgroundColor3 = THEME.Card
collectTreasureButton.TextColor3 = THEME.TextMuted
collectTreasureButton.Font = FONT_BOLD
collectTreasureButton.TextSize = 12
collectTreasureButton.BorderSizePixel = 0
collectTreasureButton.AutoButtonColor = false
collectTreasureButton.Parent = treasurePreviewPanel

Instance.new("UICorner", collectTreasureButton).CornerRadius = UDim.new(0, 9)

collectTreasureButtonStroke = Instance.new("UIStroke", collectTreasureButton)
collectTreasureButtonStroke.Color = THEME.Border
collectTreasureButtonStroke.Thickness = 1

collectTreasureButton.MouseEnter:Connect(function()
	if selectedTreasure then
		TweenService:Create(collectTreasureButton, TweenInfo.new(0.15), {
			BackgroundColor3 = THEME.Accent
		}):Play()

		TweenService:Create(collectTreasureButtonStroke, TweenInfo.new(0.15), {
			Color = THEME.Accent
		}):Play()

		collectTreasureButton.TextColor3 = Color3.fromRGB(5, 15, 20)
	end
end)

collectTreasureButton.MouseLeave:Connect(function()
	if selectedTreasure then
		TweenService:Create(collectTreasureButton, TweenInfo.new(0.15), {
			BackgroundColor3 = THEME.AccentDark
		}):Play()

		collectTreasureButton.TextColor3 = Color3.new(1, 1, 1)
	else
		TweenService:Create(collectTreasureButton, TweenInfo.new(0.15), {
			BackgroundColor3 = THEME.Card
		}):Play()

		collectTreasureButton.TextColor3 = THEME.TextMuted
	end
end)

collectTreasureButton.MouseButton1Down:Connect(function()
	if selectedTreasure then
		collectTreasureButton:TweenSize(
			UDim2.new(1, -39, 0, 41),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.08,
			true
		)
	end
end)

collectTreasureButton.MouseButton1Up:Connect(function()
	collectTreasureButton:TweenSize(
		UDim2.new(1, -35, 0, 45),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad,
		0.08,
		true
	)
end)

collectTreasureButton.MouseButton1Click:Connect(function()
	if not selectedTreasure then
		warn("Pilih treasure dulu!")
		return
	end

	local treasureName = selectedTreasure

	collectTreasureButton.Text = "COLLECTING..."
	collectTreasureButton.Active = false

	local success, result = pcall(function()
		return treasureAddToInventoryRF:InvokeServer(
			treasureName,
			"Default"
		)
	end)

	if success then
		collectTreasureButton.Text = "✓ COLLECTED!"
		collectTreasureButton.BackgroundColor3 = Color3.fromRGB(50, 190, 110)
		collectTreasureButton.TextColor3 = Color3.new(1, 1, 1)

		task.delay(0.8, function()
			if collectTreasureButton.Parent then
				collectTreasureButton.Text = "COLLECT TREASURE"
				collectTreasureButton.BackgroundColor3 = THEME.Accent
				collectTreasureButton.TextColor3 = Color3.fromRGB(5, 15, 20)
				collectTreasureButton.Active = true
			end
		end)
	else
		warn("[Level1 Hub] Treasure AddToInventory failed:", result)

		collectTreasureButton.Text = "FAILED"
		collectTreasureButton.BackgroundColor3 = Color3.fromRGB(210, 65, 75)
		collectTreasureButton.TextColor3 = Color3.new(1, 1, 1)

		task.delay(1, function()
			if collectTreasureButton.Parent then
				collectTreasureButton.Text = "COLLECT TREASURE"
				collectTreasureButton.BackgroundColor3 = THEME.Accent
				collectTreasureButton.TextColor3 = Color3.fromRGB(5, 15, 20)
				collectTreasureButton.Active = true
			end
		end)
	end
end)

collectTreasureButton.BackgroundColor3 = THEME.Card
collectTreasureButton.TextColor3 = THEME.TextMuted
collectTreasureButton.Active = true

local teleportLocations = {
	{"[Spawn Vehicles] Dock's", Vector3.new(-41.66991, 237.69075, 771.37616)},
	{"[Market Place] Mr.Detok", Vector3.new(27.79836, 239.60448, 832.53687)},
	{"[Gear Shop] Mr.Wiwok", Vector3.new(-36.18216, 237.68404, 838.65741)},
	{"[Gear Shop] Unc.Nathan Lee", Vector3.new(220.21776, 242.70007, -1214.91553)},
	{"[Enchantment Store] Eldrin Stone Seller",Vector3.new(974.72198, 263.96902, -1013.63672)},
	{"[Enchantment] Skull Witch",Vector3.new(961.12146, 239.28392, 617.71057)},
	{"Fisher Man", Vector3.new(-9.16492, 237.69075, 791.66632)},
	{"Mr.Trappy", Vector3.new(-406.91226, 236.77856, 87.26193)},
	{"White Beard",Vector3.new(-811.07007, 240.93538, 104.42932)},
	{"Captain Samoodra",Vector3.new(473.40494, 233.29327, -762.24146)},
	
	{"[Spawn Vehicles] Frostfire Isies",Vector3.new(12.74754, 243.60753, -943.30499)},
	{"[Market Place] Tog the Tough",Vector3.new(20.00410, 243.02095, -916.92664)},
	{"Elle The Pirate", Vector3.new(-19.74297, 243.04610, -910.01215)},
	
}

local function teleportTo(position)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if root then
		root.CFrame = CFrame.new(position)
	end
end

local teleportPage = Instance.new("Frame")
teleportPage.Name = "TeleportPage"
teleportPage.Size = UDim2.new(0, 860, 1, -130)
teleportPage.Position = UDim2.new(0, 20, 0, 120)
teleportPage.BackgroundTransparency = 1
teleportPage.Visible = false
teleportPage.Parent = frame

pages.Teleport = teleportPage

local teleportPanel = Instance.new("Frame")
teleportPanel.Size = UDim2.new(1, 0, 1, 0)
teleportPanel.BackgroundColor3 = THEME.Sidebar
teleportPanel.BorderSizePixel = 0
teleportPanel.Parent = teleportPage

Instance.new("UICorner", teleportPanel).CornerRadius = UDim.new(0, 12)

local teleportStroke = Instance.new("UIStroke", teleportPanel)
teleportStroke.Color = THEME.Border
teleportStroke.Thickness = 1

local teleportTitle = Instance.new("TextLabel")
teleportTitle.Size = UDim2.new(1, -30, 0, 30)
teleportTitle.Position = UDim2.new(0, 15, 0, 15)
teleportTitle.BackgroundTransparency = 1
teleportTitle.Text = "TELEPORT"
teleportTitle.TextColor3 = THEME.Text
teleportTitle.Font = FONT_BOLD
teleportTitle.TextSize = 15
teleportTitle.TextXAlignment = Enum.TextXAlignment.Left
teleportTitle.Parent = teleportPanel

local teleportInfo = Instance.new("TextLabel")
teleportInfo.Size = UDim2.new(1, -30, 0, 25)
teleportInfo.Position = UDim2.new(0, 15, 0, 48)
teleportInfo.BackgroundTransparency = 1
teleportInfo.Text = "Select a location"
teleportInfo.TextColor3 = THEME.TextMuted
teleportInfo.Font = FONT_REGULAR
teleportInfo.TextSize = 11
teleportInfo.TextXAlignment = Enum.TextXAlignment.Left
teleportInfo.Parent = teleportPanel

local teleportList = Instance.new("ScrollingFrame")
teleportList.Size = UDim2.new(1, -30, 1, -95)
teleportList.Position = UDim2.new(0, 15, 0, 82)
teleportList.BackgroundTransparency = 1
teleportList.BorderSizePixel = 0
teleportList.ScrollBarThickness = 3
teleportList.ScrollBarImageColor3 = THEME.Accent
teleportList.CanvasSize = UDim2.new(0, 0, 0, 0)
teleportList.Parent = teleportPanel

local teleportGrid = Instance.new("UIGridLayout")
teleportGrid.CellSize = UDim2.new(0, 260, 0, 55)
teleportGrid.CellPadding = UDim2.new(0, 10, 0, 10)
teleportGrid.SortOrder = Enum.SortOrder.LayoutOrder
teleportGrid.Parent = teleportList

local function createTeleportButton(name, position, order)
	local button = Instance.new("TextButton")
	button.Name = name
	button.LayoutOrder = order
	button.BackgroundColor3 = THEME.Card
	button.BorderSizePixel = 0
	button.Text = name
	button.TextColor3 = THEME.Text
	button.Font = FONT_BOLD
	button.TextSize = 11
	button.TextWrapped = true
	button.AutoButtonColor = false
	button.Parent = teleportList

	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 9)

	local stroke = Instance.new("UIStroke", button)
	stroke.Color = THEME.Border
	stroke.Thickness = 1

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), {
			BackgroundColor3 = THEME.CardHover,
			TextColor3 = THEME.Accent
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), {
			BackgroundColor3 = THEME.Card,
			TextColor3 = THEME.Text
		}):Play()
	end)

	button.MouseButton1Click:Connect(function()
		teleportTo(position)
	end)
end

for index, location in ipairs(teleportLocations) do
	createTeleportButton(location[1], location[2], index)
end

local function updateTeleportCanvas()
	teleportList.CanvasSize = UDim2.new(
		0,
		0,
		0,
		teleportGrid.AbsoluteContentSize.Y + 10
	)
end

teleportGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTeleportCanvas)
updateTeleportCanvas()

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
	previewPanel.Visible = name == "Fish"

	treasureSidebar.Visible = name == "Treasure"
	treasureContent.Visible = name == "Treasure"
	treasurePreviewPanel.Visible = name == "Treasure"

	teleportPage.Visible = name == "Teleport"
end

for name, button in pairs(tabs) do
	button.MouseButton1Click:Connect(function()
		switchTab(name)
	end)
end

switchTab("Fish")

local dragging = false
local dragStart
local startPos

local dragArea = Instance.new("TextButton")
dragArea.Name = "DragArea"
dragArea.Size = UDim2.new(1, -135, 1, 0)
dragArea.Position = UDim2.new(0, 0, 0, 0)
dragArea.BackgroundTransparency = 1
dragArea.BorderSizePixel = 0
dragArea.Text = ""
dragArea.AutoButtonColor = false
dragArea.ZIndex = 1
dragArea.Parent = header

title.ZIndex = 2
gameTitle.ZIndex = 2

dragArea.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = frame.Position
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
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = false
	end
end)

minimize.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized

	if isMinimized then
		minimize.Text = "+"

		gameTitle.Visible = false
		tabBar.Visible = false
		sidebar.Visible = false
		content.Visible = false
		previewPanel.Visible = false
		treasureSidebar.Visible = false
		treasureContent.Visible = false
		treasurePreviewPanel.Visible = false
		teleportPage.Visible = false

		TweenService:Create(
			frame,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = minimizedSize
			}
		):Play()
	else
		minimize.Text = "—"

		gameTitle.Visible = true
		tabBar.Visible = true

		switchTab(currentTab)

		TweenService:Create(
			frame,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = normalSize
			}
		):Play()
	end
end)

close.MouseButton1Click:Connect(function()
	local tween = TweenService:Create(
		frame,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad),
		{
			Size = UDim2.new(0, 0, 0, 0)
		}
	)

	tween:Play()
	tween.Completed:Wait()

	gui:Destroy()
end)

task.defer(function()
	task.wait(0.1)
	updateCanvas()
	filterFish()
	updateTreasureCanvas()
	filterTreasure()
end)
