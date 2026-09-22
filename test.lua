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

local fishList = {}
local treasureList = {}

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
title.ZIndex = 2
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
gameTitle.ZIndex = 2
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

local sidebar
local content
local previewPanel

local treasureSidebar
local treasureContent
local treasurePreviewPanel

local teleportPage

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

	if sidebar then
		sidebar.Visible = name == "Fish"
	end

	if content then
		content.Visible = name == "Fish"
	end

	if previewPanel then
		previewPanel.Visible = name == "Fish"
	end

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

for name, button in pairs(tabs) do
	button.MouseButton1Click:Connect(function()
		switchTab(name)
	end)
end

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

		if sidebar then
			sidebar.Visible = false
		end

		if content then
			content.Visible = false
		end

		if previewPanel then
			previewPanel.Visible = false
		end

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

loadFishIndex()

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

table.clear(fishList)

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

sidebar = Instance.new("Frame")
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

content = Instance.new("Frame")
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

previewPanel = Instance.new("Frame")
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
	categoryButton.Text =
		RARITY_DISPLAY[category]
		or string.upper(category)
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
