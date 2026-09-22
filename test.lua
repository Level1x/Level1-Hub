local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("FishCatcherGui")
if oldGui then
	oldGui:Destroy()
end

local Assets = ReplicatedStorage:WaitForChild("A__Assets")
local FishAssets = Assets:WaitForChild("Fish")
local TreasureAssets = Assets:WaitForChild("Treasure")

local FishData = require(
	ReplicatedStorage
		:WaitForChild("Shared")
		:WaitForChild("Data")
		:WaitForChild("Template")
		:WaitForChild("Fish")
)

local TreasureData = require(
	ReplicatedStorage
		:WaitForChild("Shared")
		:WaitForChild("Data")
		:WaitForChild("Template")
		:WaitForChild("Treasures")
)

local FishRemote = ReplicatedStorage
	:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_knit@1.7.0")
	:WaitForChild("knit")
	:WaitForChild("Services")
	:WaitForChild("FishService")
	:WaitForChild("RF")
	:WaitForChild("AddToInventory")

local TreasureRemote = ReplicatedStorage
	:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_knit@1.7.0")
	:WaitForChild("knit")
	:WaitForChild("Services")
	:WaitForChild("TreasureService")
	:WaitForChild("RF")
	:WaitForChild("AddToInventory")

local THEME = {
	Background = Color3.fromRGB(7, 14, 20),
	Sidebar = Color3.fromRGB(10, 21, 29),
	Panel = Color3.fromRGB(12, 25, 34),
	Card = Color3.fromRGB(16, 32, 42),
	CardHover = Color3.fromRGB(21, 43, 55),
	Border = Color3.fromRGB(32, 57, 68),
	Accent = Color3.fromRGB(52, 211, 153),
	Text = Color3.fromRGB(235, 248, 245),
	TextMuted = Color3.fromRGB(139, 164, 170),
	Danger = Color3.fromRGB(248, 113, 113)
}

local FONT_BOLD = Enum.Font.GothamBold
local FONT_REGULAR = Enum.Font.Gotham

local gui = Instance.new("ScreenGui")
gui.Name = "FishCatcherGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.new(0, 900, 0, 560)
frame.Position = UDim2.new(0.5, -450, 0.5, -280)
frame.BackgroundColor3 = THEME.Background
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local mainStroke = Instance.new("UIStroke", frame)
mainStroke.Color = THEME.Border
mainStroke.Thickness = 1

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 75)
header.BackgroundColor3 = THEME.Sidebar
header.BorderSizePixel = 0
header.Parent = frame

local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(1, -40, 0, 30)
headerTitle.Position = UDim2.new(0, 20, 0, 12)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "LEVEL1 HUB"
headerTitle.TextColor3 = THEME.Text
headerTitle.Font = FONT_BOLD
headerTitle.TextSize = 20
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Parent = header

local headerSub = Instance.new("TextLabel")
headerSub.Size = UDim2.new(1, -40, 0, 20)
headerSub.Position = UDim2.new(0, 20, 0, 42)
headerSub.BackgroundTransparency = 1
headerSub.Text = "BECOME A DEEP SEA EXPLORER"
headerSub.TextColor3 = THEME.TextMuted
headerSub.Font = FONT_REGULAR
headerSub.TextSize = 10
headerSub.TextXAlignment = Enum.TextXAlignment.Left
headerSub.Parent = header

local tabs = Instance.new("Frame")
tabs.Name = "Tabs"
tabs.Size = UDim2.new(0, 300, 0, 40)
tabs.Position = UDim2.new(1, -320, 0, 18)
tabs.BackgroundTransparency = 1
tabs.Parent = header

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = tabs

local pages = {}

local function createTab(name)
	local button = Instance.new("TextButton")
	button.Name = name .. "Tab"
	button.Size = UDim2.new(0, 90, 0, 34)
	button.BackgroundColor3 = THEME.Card
	button.BorderSizePixel = 0
	button.Text = name
	button.TextColor3 = THEME.TextMuted
	button.Font = FONT_BOLD
	button.TextSize = 11
	button.AutoButtonColor = false
	button.Parent = tabs

	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

	local stroke = Instance.new("UIStroke", button)
	stroke.Color = THEME.Border
	stroke.Thickness = 1

	return button
end

local fishTab = createTab("Fish")
local treasureTab = createTab("Treasure")
local teleportTab = createTab("Teleport")

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, 0, 1, -75)
content.Position = UDim2.new(0, 0, 0, 75)
content.BackgroundTransparency = 1
content.Parent = frame

local function tween(object, properties, duration)
	return TweenService:Create(
		object,
		TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		properties
	)
end

local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPosition = frame.Position
	end
end)

header.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart

		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

local function setTabStyle(button, active)
	if active then
		tween(button, {
			BackgroundColor3 = THEME.Accent,
			TextColor3 = Color3.fromRGB(5, 15, 20)
		}):Play()
	else
		tween(button, {
			BackgroundColor3 = THEME.Card,
			TextColor3 = THEME.TextMuted
		}):Play()
	end
end


local fishPage = Instance.new("Frame")
fishPage.Name = "FishPage"
fishPage.Size = UDim2.new(1, 0, 1, 0)
fishPage.BackgroundTransparency = 1
fishPage.Visible = true
fishPage.Parent = content

pages.Fish = fishPage

local fishSidebar = Instance.new("Frame")
fishSidebar.Name = "Sidebar"
fishSidebar.Size = UDim2.new(0, 170, 1, -20)
fishSidebar.Position = UDim2.new(0, 10, 0, 10)
fishSidebar.BackgroundColor3 = THEME.Sidebar
fishSidebar.BorderSizePixel = 0
fishSidebar.Parent = fishPage

Instance.new("UICorner", fishSidebar).CornerRadius = UDim.new(0, 10)

local fishSidebarStroke = Instance.new("UIStroke", fishSidebar)
fishSidebarStroke.Color = THEME.Border
fishSidebarStroke.Thickness = 1

local fishSidebarTitle = Instance.new("TextLabel")
fishSidebarTitle.Size = UDim2.new(1, -24, 0, 30)
fishSidebarTitle.Position = UDim2.new(0, 12, 0, 12)
fishSidebarTitle.BackgroundTransparency = 1
fishSidebarTitle.Text = "FISH"
fishSidebarTitle.TextColor3 = THEME.Text
fishSidebarTitle.Font = FONT_BOLD
fishSidebarTitle.TextSize = 13
fishSidebarTitle.TextXAlignment = Enum.TextXAlignment.Left
fishSidebarTitle.Parent = fishSidebar

local fishRarityList = Instance.new("ScrollingFrame")
fishRarityList.Size = UDim2.new(1, -20, 1, -55)
fishRarityList.Position = UDim2.new(0, 10, 0, 50)
fishRarityList.BackgroundTransparency = 1
fishRarityList.BorderSizePixel = 0
fishRarityList.ScrollBarThickness = 3
fishRarityList.ScrollBarImageColor3 = THEME.Accent
fishRarityList.CanvasSize = UDim2.new(0, 0, 0, 0)
fishRarityList.Parent = fishSidebar

local fishRarityLayout = Instance.new("UIListLayout")
fishRarityLayout.Padding = UDim.new(0, 5)
fishRarityLayout.SortOrder = Enum.SortOrder.LayoutOrder
fishRarityLayout.Parent = fishRarityList

local fishContent = Instance.new("Frame")
fishContent.Name = "Content"
fishContent.Size = UDim2.new(1, -390, 1, -20)
fishContent.Position = UDim2.new(0, 190, 0, 10)
fishContent.BackgroundColor3 = THEME.Sidebar
fishContent.BorderSizePixel = 0
fishContent.Parent = fishPage

Instance.new("UICorner", fishContent).CornerRadius = UDim.new(0, 10)

local fishContentStroke = Instance.new("UIStroke", fishContent)
fishContentStroke.Color = THEME.Border
fishContentStroke.Thickness = 1

local fishSearch = Instance.new("TextBox")
fishSearch.Size = UDim2.new(1, -24, 0, 38)
fishSearch.Position = UDim2.new(0, 12, 0, 12)
fishSearch.BackgroundColor3 = THEME.Card
fishSearch.BorderSizePixel = 0
fishSearch.PlaceholderText = "Search fish..."
fishSearch.PlaceholderColor3 = THEME.TextMuted
fishSearch.Text = ""
fishSearch.TextColor3 = THEME.Text
fishSearch.Font = FONT_REGULAR
fishSearch.TextSize = 11
fishSearch.ClearTextOnFocus = false
fishSearch.Parent = fishContent

Instance.new("UICorner", fishSearch).CornerRadius = UDim.new(0, 8)

local fishSearchStroke = Instance.new("UIStroke", fishSearch)
fishSearchStroke.Color = THEME.Border
fishSearchStroke.Thickness = 1

local fishGrid = Instance.new("ScrollingFrame")
fishGrid.Name = "Grid"
fishGrid.Size = UDim2.new(1, -24, 1, -62)
fishGrid.Position = UDim2.new(0, 12, 0, 55)
fishGrid.BackgroundTransparency = 1
fishGrid.BorderSizePixel = 0
fishGrid.ScrollBarThickness = 4
fishGrid.ScrollBarImageColor3 = THEME.Accent
fishGrid.CanvasSize = UDim2.new(0, 0, 0, 0)
fishGrid.Parent = fishContent

local fishGridLayout = Instance.new("UIGridLayout")
fishGridLayout.CellSize = UDim2.new(0, 135, 0, 125)
fishGridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
fishGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
fishGridLayout.Parent = fishGrid

local fishPreviewPanel = Instance.new("Frame")
fishPreviewPanel.Name = "Preview"
fishPreviewPanel.Size = UDim2.new(0, 190, 1, -20)
fishPreviewPanel.Position = UDim2.new(1, -200, 0, 10)
fishPreviewPanel.BackgroundColor3 = THEME.Sidebar
fishPreviewPanel.BorderSizePixel = 0
fishPreviewPanel.Parent = fishPage

Instance.new("UICorner", fishPreviewPanel).CornerRadius = UDim.new(0, 10)

local fishPreviewStroke = Instance.new("UIStroke", fishPreviewPanel)
fishPreviewStroke.Color = THEME.Border
fishPreviewStroke.Thickness = 1

local fishPreviewTitle = Instance.new("TextLabel")
fishPreviewTitle.Size = UDim2.new(1, -20, 0, 30)
fishPreviewTitle.Position = UDim2.new(0, 10, 0, 10)
fishPreviewTitle.BackgroundTransparency = 1
fishPreviewTitle.Text = "PREVIEW"
fishPreviewTitle.TextColor3 = THEME.Text
fishPreviewTitle.Font = FONT_BOLD
fishPreviewTitle.TextSize = 12
fishPreviewTitle.TextXAlignment = Enum.TextXAlignment.Left
fishPreviewTitle.Parent = fishPreviewPanel

local fishViewport = Instance.new("ViewportFrame")
fishViewport.Size = UDim2.new(1, -20, 0, 190)
fishViewport.Position = UDim2.new(0, 10, 0, 48)
fishViewport.BackgroundColor3 = THEME.Card
fishViewport.BorderSizePixel = 0
fishViewport.Ambient = Color3.fromRGB(200, 200, 200)
fishViewport.LightColor = Color3.fromRGB(255, 255, 255)
fishViewport.Parent = fishPreviewPanel

Instance.new("UICorner", fishViewport).CornerRadius = UDim.new(0, 8)

local fishPreviewName = Instance.new("TextLabel")
fishPreviewName.Size = UDim2.new(1, -20, 0, 35)
fishPreviewName.Position = UDim2.new(0, 10, 0, 250)
fishPreviewName.BackgroundTransparency = 1
fishPreviewName.Text = "Select a fish"
fishPreviewName.TextColor3 = THEME.Text
fishPreviewName.Font = FONT_BOLD
fishPreviewName.TextSize = 12
fishPreviewName.TextWrapped = true
fishPreviewName.Parent = fishPreviewPanel

local fishPreviewRarity = Instance.new("TextLabel")
fishPreviewRarity.Size = UDim2.new(1, -20, 0, 25)
fishPreviewRarity.Position = UDim2.new(0, 10, 0, 285)
fishPreviewRarity.BackgroundTransparency = 1
fishPreviewRarity.Text = ""
fishPreviewRarity.TextColor3 = THEME.TextMuted
fishPreviewRarity.Font = FONT_REGULAR
fishPreviewRarity.TextSize = 10
fishPreviewRarity.Parent = fishPreviewPanel

local fishAction = Instance.new("TextButton")
fishAction.Size = UDim2.new(1, -20, 0, 42)
fishAction.Position = UDim2.new(0, 10, 1, -52)
fishAction.BackgroundColor3 = THEME.Accent
fishAction.BorderSizePixel = 0
fishAction.Text = "ADD TO INVENTORY"
fishAction.TextColor3 = Color3.fromRGB(5, 15, 20)
fishAction.Font = FONT_BOLD
fishAction.TextSize = 10
fishAction.AutoButtonColor = false
fishAction.Parent = fishPreviewPanel

Instance.new("UICorner", fishAction).CornerRadius = UDim.new(0, 8)

local selectedFish = nil
local selectedFishButton = nil
local selectedFishRarity = "All"

local function getValue(data, key, fallback)
	if type(data) == "table" then
		if data[key] ~= nil then
			return data[key]
		end
	end

	return fallback
end

local function getFishName(data, fallback)
	if type(data) == "string" then
		return data
	end

	if type(data) == "table" then
		return data.Name or data.name or data.DisplayName or data.displayName or fallback
	end

	return fallback
end

local function getFishRarity(data)
	if type(data) == "table" then
		return data.Rarity or data.rarity or data.RarityName or data.rarityName or "Common"
	end

	return "Common"
end

local function clearViewport()
	for _, child in ipairs(fishViewport:GetChildren()) do
		child:Destroy()
	end
end

local function showFishPreview(fishName)
	selectedFish = fishName

	clearViewport()

	fishPreviewName.Text = fishName

	local fishInfo = FishData[fishName]
	local rarity = getFishRarity(fishInfo)

	fishPreviewRarity.Text = tostring(rarity)

	local asset = FishAssets:FindFirstChild(fishName)

	if not asset then
		return
	end

	local clone = asset:Clone()

	if clone:IsA("Model") then
		clone.Parent = fishViewport

		local camera = Instance.new("Camera")
		camera.Parent = fishViewport
		fishViewport.CurrentCamera = camera

		local primary = clone.PrimaryPart

		if not primary then
			primary = clone:FindFirstChildWhichIsA("BasePart", true)
		end

		if primary then
			clone.PrimaryPart = primary
			clone:PivotTo(CFrame.new(0, 0, 0))

			local size = clone:GetExtentsSize()
			local distance = math.max(size.X, size.Y, size.Z) * 2.2

			camera.CFrame = CFrame.new(
				0,
				size.Y * 0.15,
				distance
			) * CFrame.Angles(
				math.rad(-5),
				math.rad(180),
				0
			)
		end
	elseif clone:IsA("BasePart") then
		clone.Parent = fishViewport

		local camera = Instance.new("Camera")
		camera.Parent = fishViewport
		fishViewport.CurrentCamera = camera

		local size = clone.Size
		local distance = math.max(size.X, size.Y, size.Z) * 3

		camera.CFrame = CFrame.new(0, 0, distance)
	end
end

local function createFishButton(fishName, rarity, order)
	local button = Instance.new("TextButton")
	button.Name = fishName:gsub("%s+", "")
	button.Size = UDim2.new(0, 135, 0, 125)
	button.BackgroundColor3 = THEME.Card
	button.BorderSizePixel = 0
	button.Text = ""
	button.AutoButtonColor = false
	button.LayoutOrder = order
	button.Parent = fishGrid

	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

	local stroke = Instance.new("UIStroke", button)
	stroke.Color = THEME.Border
	stroke.Thickness = 1

	local viewport = Instance.new("ViewportFrame")
	viewport.Size = UDim2.new(1, -10, 0, 78)
	viewport.Position = UDim2.new(0, 5, 0, 5)
	viewport.BackgroundColor3 = THEME.Panel
	viewport.BorderSizePixel = 0
	viewport.Ambient = Color3.fromRGB(200, 200, 200)
	viewport.LightColor = Color3.fromRGB(255, 255, 255)
	viewport.Parent = button

	Instance.new("UICorner", viewport).CornerRadius = UDim.new(0, 6)

	local asset = FishAssets:FindFirstChild(fishName)

	if asset then
		local clone = asset:Clone()

		if clone:IsA("Model") then
			clone.Parent = viewport

			local camera = Instance.new("Camera")
			camera.Parent = viewport
			viewport.CurrentCamera = camera

			local primary = clone.PrimaryPart

			if not primary then
				primary = clone:FindFirstChildWhichIsA("BasePart", true)
			end

			if primary then
				clone.PrimaryPart = primary
				clone:PivotTo(CFrame.new(0, 0, 0))

				local size = clone:GetExtentsSize()
				local distance = math.max(size.X, size.Y, size.Z) * 2

				camera.CFrame = CFrame.new(0, 0, distance)
			end
		elseif clone:IsA("BasePart") then
			clone.Parent = viewport

			local camera = Instance.new("Camera")
			camera.Parent = viewport
			viewport.CurrentCamera = camera

			local distance = math.max(
				clone.Size.X,
				clone.Size.Y,
				clone.Size.Z
			) * 3

			camera.CFrame = CFrame.new(0, 0, distance)
		end
	end

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -10, 0, 22)
	nameLabel.Position = UDim2.new(0, 5, 0, 86)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = fishName
	nameLabel.TextColor3 = THEME.Text
	nameLabel.Font = FONT_BOLD
	nameLabel.TextSize = 9
	nameLabel.TextWrapped = true
	nameLabel.Parent = button

	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.new(1, -10, 0, 14)
	rarityLabel.Position = UDim2.new(0, 5, 1, -17)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text = tostring(rarity)
	rarityLabel.TextColor3 = THEME.TextMuted
	rarityLabel.Font = FONT_REGULAR
	rarityLabel.TextSize = 8
	rarityLabel.Parent = button

	button.MouseEnter:Connect(function()
		tween(button, {
			BackgroundColor3 = THEME.CardHover
		}):Play()

		tween(stroke, {
			Color = THEME.Accent
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		if selectedFishButton ~= button then
			tween(button, {
				BackgroundColor3 = THEME.Card
			}):Play()

			tween(stroke, {
				Color = THEME.Border
			}):Play()
		end
	end)

	button.MouseButton1Click:Connect(function()
		if selectedFishButton then
			tween(selectedFishButton, {
				BackgroundColor3 = THEME.Card
			}):Play()
		end

		selectedFishButton = button

		tween(button, {
			BackgroundColor3 = THEME.CardHover
		}):Play()

		showFishPreview(fishName)
	end)
end

local fishRarities = {}

for fishName, data in pairs(FishData) do
	local rarity = getFishRarity(data)

	if not fishRarities[rarity] then
		fishRarities[rarity] = true
	end
end

local rarityNames = {"All"}

for rarity in pairs(fishRarities) do
	table.insert(rarityNames, tostring(rarity))
end

table.sort(rarityNames, function(a, b)
	if a == "All" then
		return true
	end

	if b == "All" then
		return false
	end

	return a < b
end)

local function refreshFish()
	for _, child in ipairs(fishGrid:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local searchText = string.lower(fishSearch.Text)
	local order = 0

	for fishName, data in pairs(FishData) do
		local name = getFishName(data, tostring(fishName))
		local rarity = tostring(getFishRarity(data))

		local rarityMatch = selectedFishRarity == "All"
			or rarity == selectedFishRarity

		local searchMatch = searchText == ""
			or string.find(string.lower(name), searchText, 1, true)

		if rarityMatch and searchMatch then
			order += 1
			createFishButton(name, rarity, order)
		end
	end

	task.defer(function()
		fishGrid.CanvasSize = UDim2.new(
			0,
			0,
			0,
			fishGridLayout.AbsoluteContentSize.Y + 15
		)
	end)
end

for index, rarity in ipairs(rarityNames) do
	local button = Instance.new("TextButton")
	button.Name = rarity:gsub("%s+", "")
	button.Size = UDim2.new(1, -4, 0, 34)
	button.BackgroundColor3 = rarity == "All" and THEME.Accent or THEME.Card
	button.BorderSizePixel = 0
	button.Text = rarity
	button.TextColor3 = rarity == "All"
		and Color3.fromRGB(5, 15, 20)
		or THEME.TextMuted
	button.Font = FONT_BOLD
	button.TextSize = 10
	button.AutoButtonColor = false
	button.LayoutOrder = index
	button.Parent = fishRarityList

	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)

	local stroke = Instance.new("UIStroke", button)
	stroke.Color = THEME.Border
	stroke.Thickness = 1

	button.MouseEnter:Connect(function()
		if selectedFishRarity ~= rarity then
			tween(button, {
				BackgroundColor3 = THEME.CardHover
			}):Play()
		end
	end)

	button.MouseLeave:Connect(function()
		if selectedFishRarity ~= rarity then
			tween(button, {
				BackgroundColor3 = THEME.Card
			}):Play()
		end
	end)

	button.MouseButton1Click:Connect(function()
		selectedFishRarity = rarity

		for _, child in ipairs(fishRarityList:GetChildren()) do
			if child:IsA("TextButton") then
				local active = child.Text == selectedFishRarity

				tween(child, {
					BackgroundColor3 = active
						and THEME.Accent
						or THEME.Card,
					TextColor3 = active
						and Color3.fromRGB(5, 15, 20)
						or THEME.TextMuted
				}):Play()
			end
		end

		refreshFish()
	end)
end

fishSearch:GetPropertyChangedSignal("Text"):Connect(function()
	refreshFish()
end)

fishGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	fishGrid.CanvasSize = UDim2.new(
		0,
		0,
		0,
		fishGridLayout.AbsoluteContentSize.Y + 15
	)
end)

fishRarityLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	fishRarityList.CanvasSize = UDim2.new(
		0,
		0,
		0,
		fishRarityLayout.AbsoluteContentSize.Y + 15
	)
end)

fishAction.MouseEnter:Connect(function()
	tween(fishAction, {
		BackgroundColor3 = THEME.CardHover
	}):Play()
end)

fishAction.MouseLeave:Connect(function()
	tween(fishAction, {
		BackgroundColor3 = THEME.Accent
	}):Play()
end)

fishAction.MouseButton1Click:Connect(function()
	if not selectedFish then
		return
	end

	local success = pcall(function()
		FishRemote:InvokeServer(selectedFish)
	end)

	if success then
		tween(fishAction, {
			BackgroundColor3 = Color3.fromRGB(74, 222, 128)
		}):Play()

		task.delay(0.25, function()
			if fishAction and fishAction.Parent then
				tween(fishAction, {
					BackgroundColor3 = THEME.Accent
				}):Play()
			end
		end)
	end
end)

refreshFish()



local treasurePage = Instance.new("Frame")
treasurePage.Name = "TreasurePage"
treasurePage.Size = UDim2.new(1, 0, 1, 0)
treasurePage.BackgroundTransparency = 1
treasurePage.Visible = false
treasurePage.Parent = content

pages.Treasure = treasurePage

local treasureSidebar = Instance.new("Frame")
treasureSidebar.Name = "Sidebar"
treasureSidebar.Size = UDim2.new(0, 170, 1, -20)
treasureSidebar.Position = UDim2.new(0, 10, 0, 10)
treasureSidebar.BackgroundColor3 = THEME.Sidebar
treasureSidebar.BorderSizePixel = 0
treasureSidebar.Parent = treasurePage

Instance.new("UICorner", treasureSidebar).CornerRadius = UDim.new(0, 10)

local treasureSidebarStroke = Instance.new("UIStroke", treasureSidebar)
treasureSidebarStroke.Color = THEME.Border
treasureSidebarStroke.Thickness = 1

local treasureSidebarTitle = Instance.new("TextLabel")
treasureSidebarTitle.Size = UDim2.new(1, -24, 0, 30)
treasureSidebarTitle.Position = UDim2.new(0, 12, 0, 12)
treasureSidebarTitle.BackgroundTransparency = 1
treasureSidebarTitle.Text = "TREASURE"
treasureSidebarTitle.TextColor3 = THEME.Text
treasureSidebarTitle.Font = FONT_BOLD
treasureSidebarTitle.TextSize = 13
treasureSidebarTitle.TextXAlignment = Enum.TextXAlignment.Left
treasureSidebarTitle.Parent = treasureSidebar

local treasureRarityList = Instance.new("ScrollingFrame")
treasureRarityList.Size = UDim2.new(1, -20, 1, -55)
treasureRarityList.Position = UDim2.new(0, 10, 0, 50)
treasureRarityList.BackgroundTransparency = 1
treasureRarityList.BorderSizePixel = 0
treasureRarityList.ScrollBarThickness = 3
treasureRarityList.ScrollBarImageColor3 = THEME.Accent
treasureRarityList.CanvasSize = UDim2.new(0, 0, 0, 0)
treasureRarityList.Parent = treasureSidebar

local treasureRarityLayout = Instance.new("UIListLayout")
treasureRarityLayout.Padding = UDim.new(0, 5)
treasureRarityLayout.SortOrder = Enum.SortOrder.LayoutOrder
treasureRarityLayout.Parent = treasureRarityList

local treasureContent = Instance.new("Frame")
treasureContent.Name = "Content"
treasureContent.Size = UDim2.new(1, -390, 1, -20)
treasureContent.Position = UDim2.new(0, 190, 0, 10)
treasureContent.BackgroundColor3 = THEME.Sidebar
treasureContent.BorderSizePixel = 0
treasureContent.Parent = treasurePage

Instance.new("UICorner", treasureContent).CornerRadius = UDim.new(0, 10)

local treasureContentStroke = Instance.new("UIStroke", treasureContent)
treasureContentStroke.Color = THEME.Border
treasureContentStroke.Thickness = 1

local treasureSearch = Instance.new("TextBox")
treasureSearch.Size = UDim2.new(1, -24, 0, 38)
treasureSearch.Position = UDim2.new(0, 12, 0, 12)
treasureSearch.BackgroundColor3 = THEME.Card
treasureSearch.BorderSizePixel = 0
treasureSearch.PlaceholderText = "Search treasure..."
treasureSearch.PlaceholderColor3 = THEME.TextMuted
treasureSearch.Text = ""
treasureSearch.TextColor3 = THEME.Text
treasureSearch.Font = FONT_REGULAR
treasureSearch.TextSize = 11
treasureSearch.ClearTextOnFocus = false
treasureSearch.Parent = treasureContent

Instance.new("UICorner", treasureSearch).CornerRadius = UDim.new(0, 8)

local treasureSearchStroke = Instance.new("UIStroke", treasureSearch)
treasureSearchStroke.Color = THEME.Border
treasureSearchStroke.Thickness = 1

local treasureGrid = Instance.new("ScrollingFrame")
treasureGrid.Name = "Grid"
treasureGrid.Size = UDim2.new(1, -24, 1, -62)
treasureGrid.Position = UDim2.new(0, 12, 0, 55)
treasureGrid.BackgroundTransparency = 1
treasureGrid.BorderSizePixel = 0
treasureGrid.ScrollBarThickness = 4
treasureGrid.ScrollBarImageColor3 = THEME.Accent
treasureGrid.CanvasSize = UDim2.new(0, 0, 0, 0)
treasureGrid.Parent = treasureContent

local treasureGridLayout = Instance.new("UIGridLayout")
treasureGridLayout.CellSize = UDim2.new(0, 135, 0, 125)
treasureGridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
treasureGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
treasureGridLayout.Parent = treasureGrid

local treasurePreviewPanel = Instance.new("Frame")
treasurePreviewPanel.Name = "Preview"
treasurePreviewPanel.Size = UDim2.new(0, 190, 1, -20)
treasurePreviewPanel.Position = UDim2.new(1, -200, 0, 10)
treasurePreviewPanel.BackgroundColor3 = THEME.Sidebar
treasurePreviewPanel.BorderSizePixel = 0
treasurePreviewPanel.Parent = treasurePage

Instance.new("UICorner", treasurePreviewPanel).CornerRadius = UDim.new(0, 10)

local treasurePreviewStroke = Instance.new("UIStroke", treasurePreviewPanel)
treasurePreviewStroke.Color = THEME.Border
treasurePreviewStroke.Thickness = 1

local treasurePreviewTitle = Instance.new("TextLabel")
treasurePreviewTitle.Size = UDim2.new(1, -20, 0, 30)
treasurePreviewTitle.Position = UDim2.new(0, 10, 0, 10)
treasurePreviewTitle.BackgroundTransparency = 1
treasurePreviewTitle.Text = "PREVIEW"
treasurePreviewTitle.TextColor3 = THEME.Text
treasurePreviewTitle.Font = FONT_BOLD
treasurePreviewTitle.TextSize = 12
treasurePreviewTitle.TextXAlignment = Enum.TextXAlignment.Left
treasurePreviewTitle.Parent = treasurePreviewPanel

local treasureViewport = Instance.new("ViewportFrame")
treasureViewport.Size = UDim2.new(1, -20, 0, 190)
treasureViewport.Position = UDim2.new(0, 10, 0, 48)
treasureViewport.BackgroundColor3 = THEME.Card
treasureViewport.BorderSizePixel = 0
treasureViewport.Ambient = Color3.fromRGB(200, 200, 200)
treasureViewport.LightColor = Color3.fromRGB(255, 255, 255)
treasureViewport.Parent = treasurePreviewPanel

Instance.new("UICorner", treasureViewport).CornerRadius = UDim.new(0, 8)

local treasurePreviewName = Instance.new("TextLabel")
treasurePreviewName.Size = UDim2.new(1, -20, 0, 35)
treasurePreviewName.Position = UDim2.new(0, 10, 0, 250)
treasurePreviewName.BackgroundTransparency = 1
treasurePreviewName.Text = "Select a treasure"
treasurePreviewName.TextColor3 = THEME.Text
treasurePreviewName.Font = FONT_BOLD
treasurePreviewName.TextSize = 12
treasurePreviewName.TextWrapped = true
treasurePreviewName.Parent = treasurePreviewPanel

local treasurePreviewRarity = Instance.new("TextLabel")
treasurePreviewRarity.Size = UDim2.new(1, -20, 0, 25)
treasurePreviewRarity.Position = UDim2.new(0, 10, 0, 285)
treasurePreviewRarity.BackgroundTransparency = 1
treasurePreviewRarity.Text = ""
treasurePreviewRarity.TextColor3 = THEME.TextMuted
treasurePreviewRarity.Font = FONT_REGULAR
treasurePreviewRarity.TextSize = 10
treasurePreviewRarity.Parent = treasurePreviewPanel

local treasureAction = Instance.new("TextButton")
treasureAction.Size = UDim2.new(1, -20, 0, 42)
treasureAction.Position = UDim2.new(0, 10, 1, -52)
treasureAction.BackgroundColor3 = THEME.Accent
treasureAction.BorderSizePixel = 0
treasureAction.Text = "ADD TO INVENTORY"
treasureAction.TextColor3 = Color3.fromRGB(5, 15, 20)
treasureAction.Font = FONT_BOLD
treasureAction.TextSize = 10
treasureAction.AutoButtonColor = false
treasureAction.Parent = treasurePreviewPanel

Instance.new("UICorner", treasureAction).CornerRadius = UDim.new(0, 8)

local selectedTreasure = nil
local selectedTreasureButton = nil
local selectedTreasureRarity = "All"

local function getTreasureName(data, fallback)
	if type(data) == "string" then
		return data
	end

	if type(data) == "table" then
		return data.Name
			or data.name
			or data.DisplayName
			or data.displayName
			or fallback
	end

	return fallback
end

local function getTreasureRarity(data)
	if type(data) == "table" then
		return data.Rarity
			or data.rarity
			or data.RarityName
			or data.rarityName
			or "Common"
	end

	return "Common"
end

local function clearTreasureViewport()
	for _, child in ipairs(treasureViewport:GetChildren()) do
		child:Destroy()
	end
end

local function showTreasurePreview(treasureName)
	selectedTreasure = treasureName

	clearTreasureViewport()

	treasurePreviewName.Text = treasureName

	local treasureInfo = TreasureData[treasureName]
	local rarity = getTreasureRarity(treasureInfo)

	treasurePreviewRarity.Text = tostring(rarity)

	local asset = TreasureAssets:FindFirstChild(treasureName)

	if not asset then
		return
	end

	local clone = asset:Clone()

	if clone:IsA("Model") then
		clone.Parent = treasureViewport

		local camera = Instance.new("Camera")
		camera.Parent = treasureViewport
		treasureViewport.CurrentCamera = camera

		local primary = clone.PrimaryPart

		if not primary then
			primary = clone:FindFirstChildWhichIsA("BasePart", true)
		end

		if primary then
			clone.PrimaryPart = primary
			clone:PivotTo(CFrame.new(0, 0, 0))

			local size = clone:GetExtentsSize()
			local distance = math.max(size.X, size.Y, size.Z) * 2.2

			camera.CFrame = CFrame.new(
				0,
				size.Y * 0.15,
				distance
			)
		end
	elseif clone:IsA("BasePart") then
		clone.Parent = treasureViewport

		local camera = Instance.new("Camera")
		camera.Parent = treasureViewport
		treasureViewport.CurrentCamera = camera

		local distance = math.max(
			clone.Size.X,
			clone.Size.Y,
			clone.Size.Z
		) * 3

		camera.CFrame = CFrame.new(0, 0, distance)
	end
end

local function createTreasureButton(treasureName, rarity, order)
	local button = Instance.new("TextButton")
	button.Name = treasureName:gsub("%s+", "")
	button.Size = UDim2.new(0, 135, 0, 125)
	button.BackgroundColor3 = THEME.Card
	button.BorderSizePixel = 0
	button.Text = ""
	button.AutoButtonColor = false
	button.LayoutOrder = order
	button.Parent = treasureGrid

	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

	local stroke = Instance.new("UIStroke", button)
	stroke.Color = THEME.Border
	stroke.Thickness = 1

	local viewport = Instance.new("ViewportFrame")
	viewport.Size = UDim2.new(1, -10, 0, 78)
	viewport.Position = UDim2.new(0, 5, 0, 5)
	viewport.BackgroundColor3 = THEME.Panel
	viewport.BorderSizePixel = 0
	viewport.Ambient = Color3.fromRGB(200, 200, 200)
	viewport.LightColor = Color3.fromRGB(255, 255, 255)
	viewport.Parent = button

	Instance.new("UICorner", viewport).CornerRadius = UDim.new(0, 6)

	local asset = TreasureAssets:FindFirstChild(treasureName)

	if asset then
		local clone = asset:Clone()

		if clone:IsA("Model") then
			clone.Parent = viewport

			local camera = Instance.new("Camera")
			camera.Parent = viewport
			viewport.CurrentCamera = camera

			local primary = clone.PrimaryPart

			if not primary then
				primary = clone:FindFirstChildWhichIsA("BasePart", true)
			end

			if primary then
				clone.PrimaryPart = primary
				clone:PivotTo(CFrame.new(0, 0, 0))

				local size = clone:GetExtentsSize()
				local distance = math.max(size.X, size.Y, size.Z) * 2

				camera.CFrame = CFrame.new(0, 0, distance)
			end
		elseif clone:IsA("BasePart") then
			clone.Parent = viewport

			local camera = Instance.new("Camera")
			camera.Parent = viewport
			viewport.CurrentCamera = camera

			local distance = math.max(
				clone.Size.X,
				clone.Size.Y,
				clone.Size.Z
			) * 3

			camera.CFrame = CFrame.new(0, 0, distance)
		end
	end

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -10, 0, 22)
	nameLabel.Position = UDim2.new(0, 5, 0, 86)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = treasureName
	nameLabel.TextColor3 = THEME.Text
	nameLabel.Font = FONT_BOLD
	nameLabel.TextSize = 9
	nameLabel.TextWrapped = true
	nameLabel.Parent = button

	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.new(1, -10, 0, 14)
	rarityLabel.Position = UDim2.new(0, 5, 1, -17)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text = tostring(rarity)
	rarityLabel.TextColor3 = THEME.TextMuted
	rarityLabel.Font = FONT_REGULAR
	rarityLabel.TextSize = 8
	rarityLabel.Parent = button

	button.MouseEnter:Connect(function()
		tween(button, {
			BackgroundColor3 = THEME.CardHover
		}):Play()

		tween(stroke, {
			Color = THEME.Accent
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		if selectedTreasureButton ~= button then
			tween(button, {
				BackgroundColor3 = THEME.Card
			}):Play()

			tween(stroke, {
				Color = THEME.Border
			}):Play()
		end
	end)

	button.MouseButton1Click:Connect(function()
		if selectedTreasureButton then
			tween(selectedTreasureButton, {
				BackgroundColor3 = THEME.Card
			}):Play()
		end

		selectedTreasureButton = button

		tween(button, {
			BackgroundColor3 = THEME.CardHover
		}):Play()

		showTreasurePreview(treasureName)
	end)
end

local treasureRarities = {}

for treasureName, data in pairs(TreasureData) do
	local rarity = getTreasureRarity(data)

	if not treasureRarities[rarity] then
		treasureRarities[rarity] = true
	end
end

local treasureRarityNames = {"All"}

for rarity in pairs(treasureRarities) do
	table.insert(treasureRarityNames, tostring(rarity))
end

table.sort(treasureRarityNames, function(a, b)
	if a == "All" then
		return true
	end

	if b == "All" then
		return false
	end

	return a < b
end)

local function refreshTreasure()
	for _, child in ipairs(treasureGrid:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local searchText = string.lower(treasureSearch.Text)
	local order = 0

	for treasureName, data in pairs(TreasureData) do
		local name = getTreasureName(data, tostring(treasureName))
		local rarity = tostring(getTreasureRarity(data))

		local rarityMatch = selectedTreasureRarity == "All"
			or rarity == selectedTreasureRarity

		local searchMatch = searchText == ""
			or string.find(string.lower(name), searchText, 1, true)

		if rarityMatch and searchMatch then
			order += 1
			createTreasureButton(name, rarity, order)
		end
	end

	task.defer(function()
		treasureGrid.CanvasSize = UDim2.new(
			0,
			0,
			0,
			treasureGridLayout.AbsoluteContentSize.Y + 15
		)
	end)
end

for index, rarity in ipairs(treasureRarityNames) do
	local button = Instance.new("TextButton")
	button.Name = rarity:gsub("%s+", "")
	button.Size = UDim2.new(1, -4, 0, 34)
	button.BackgroundColor3 = rarity == "All" and THEME.Accent or THEME.Card
	button.BorderSizePixel = 0
	button.Text = rarity
	button.TextColor3 = rarity == "All"
		and Color3.fromRGB(5, 15, 20)
		or THEME.TextMuted
	button.Font = FONT_BOLD
	button.TextSize = 10
	button.AutoButtonColor = false
	button.LayoutOrder = index
	button.Parent = treasureRarityList

	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)

	local stroke = Instance.new("UIStroke", button)
	stroke.Color = THEME.Border
	stroke.Thickness = 1

	button.MouseEnter:Connect(function()
		if selectedTreasureRarity ~= rarity then
			tween(button, {
				BackgroundColor3 = THEME.CardHover
			}):Play()
		end
	end)

	button.MouseLeave:Connect(function()
		if selectedTreasureRarity ~= rarity then
			tween(button, {
				BackgroundColor3 = THEME.Card
			}):Play()
		end
	end)

	button.MouseButton1Click:Connect(function()
		selectedTreasureRarity = rarity

		for _, child in ipairs(treasureRarityList:GetChildren()) do
			if child:IsA("TextButton") then
				local active = child.Text == selectedTreasureRarity

				tween(child, {
					BackgroundColor3 = active
						and THEME.Accent
						or THEME.Card,
					TextColor3 = active
						and Color3.fromRGB(5, 15, 20)
						or THEME.TextMuted
				}):Play()
			end
		end

		refreshTreasure()
	end)
end

treasureSearch:GetPropertyChangedSignal("Text"):Connect(function()
	refreshTreasure()
end)

treasureGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	treasureGrid.CanvasSize = UDim2.new(
		0,
		0,
		0,
		treasureGridLayout.AbsoluteContentSize.Y + 15
	)
end)

treasureRarityLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	treasureRarityList.CanvasSize = UDim2.new(
		0,
		0,
		0,
		treasureRarityLayout.AbsoluteContentSize.Y + 15
	)
end)

treasureAction.MouseEnter:Connect(function()
	tween(treasureAction, {
		BackgroundColor3 = THEME.CardHover
	}):Play()
end)

treasureAction.MouseLeave:Connect(function()
	tween(treasureAction, {
		BackgroundColor3 = THEME.Accent
	}):Play()
end)

treasureAction.MouseButton1Click:Connect(function()
	if not selectedTreasure then
		return
	end

	local success = pcall(function()
		TreasureRemote:InvokeServer(selectedTreasure)
	end)

	if success then
		tween(treasureAction, {
			BackgroundColor3 = Color3.fromRGB(74, 222, 128)
		}):Play()

		task.delay(0.25, function()
			if treasureAction and treasureAction.Parent then
				tween(treasureAction, {
					BackgroundColor3 = THEME.Accent
				}):Play()
			end
		end)
	end
end)

refreshTreasure()



local teleportZones = {
	{
		Name = "Dok's",
		Locations = {
			{"[Spawn Vehicles]", Vector3.new(-41.66991, 237.69075, 771.37616)},
			{"[Market Place]", Vector3.new(27.79836, 239.60448, 832.53687)},
			{"[Gear Shop] Mr.Wiwok", Vector3.new(-36.18216, 237.68404, 838.65741)},
			{"[Skill Upgrade]", Vector3.new(-40.92221, 237.69075, 794.19263)},
			{"Fisher Man", Vector3.new(-9.16492, 237.69075, 791.66632)}
		}
	},
	{
		Name = "Ocean",
		Locations = {
			{"[Enchantment]", Vector3.new(961.12146, 239.28392, 617.71057)},
			{"Mr.Trappy", Vector3.new(-406.91226, 236.77856, 87.26193)},
			{"White Beard", Vector3.new(-811.07007, 240.93538, 104.42932)},
			{"Captain Samoodra", Vector3.new(473.40494, 233.29327, -762.24146)},
			{"Dove The Diver", Vector3.new(277.70627, 238.83917, -346.61185)}
		}
	},
	{
		Name = "Frostfire Isies",
		Locations = {
			{"[Spawn Vehicles]", Vector3.new(12.74754, 243.60753, -943.30499)},
			{"[Market Place]", Vector3.new(20.00410, 243.02095, -916.92664)},
			{"[Gear Shop] Unc.Nathan", Vector3.new(220.21776, 242.70007, -1214.91553)},
			{"[Enchantment Store]", Vector3.new(974.72198, 263.96902, -1013.63672)},
			{"Elle The Pirate", Vector3.new(-19.74297, 243.04610, -910.01215)}
		}
	}
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
teleportPage.Size = UDim2.new(1, 0, 1, 0)
teleportPage.BackgroundTransparency = 1
teleportPage.Visible = false
teleportPage.Parent = content

pages.Teleport = teleportPage

local teleportScroll = Instance.new("ScrollingFrame")
teleportScroll.Name = "Scroll"
teleportScroll.Size = UDim2.new(1, -20, 1, -20)
teleportScroll.Position = UDim2.new(0, 10, 0, 10)
teleportScroll.BackgroundTransparency = 1
teleportScroll.BorderSizePixel = 0
teleportScroll.ScrollBarThickness = 5
teleportScroll.ScrollBarImageColor3 = THEME.Accent
teleportScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
teleportScroll.Parent = teleportPage

local teleportLayout = Instance.new("UIListLayout")
teleportLayout.Padding = UDim.new(0, 12)
teleportLayout.SortOrder = Enum.SortOrder.LayoutOrder
teleportLayout.Parent = teleportScroll

local teleportPadding = Instance.new("UIPadding")
teleportPadding.PaddingTop = UDim.new(0, 4)
teleportPadding.PaddingBottom = UDim.new(0, 12)
teleportPadding.Parent = teleportScroll

local function createTeleportButton(parent, locationName, position)
	local button = Instance.new("TextButton")
	button.Name = locationName:gsub("[^%w]", "")
	button.Size = UDim2.new(0, 0, 0, 44)
	button.BackgroundColor3 = THEME.Card
	button.BorderSizePixel = 0
	button.Text = locationName
	button.TextColor3 = THEME.Text
	button.Font = FONT_BOLD
	button.TextSize = 9
	button.TextWrapped = true
	button.AutoButtonColor = false
	button.Parent = parent

	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

	local stroke = Instance.new("UIStroke", button)
	stroke.Color = THEME.Border
	stroke.Thickness = 1

	button.MouseEnter:Connect(function()
		tween(button, {
			BackgroundColor3 = THEME.CardHover
		}):Play()

		tween(stroke, {
			Color = THEME.Accent
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		tween(button, {
			BackgroundColor3 = THEME.Card
		}):Play()

		tween(stroke, {
			Color = THEME.Border
		}):Play()
	end)

	button.MouseButton1Click:Connect(function()
		teleportTo(position)

		tween(button, {
			BackgroundColor3 = THEME.Accent
		}):Play()

		task.delay(0.2, function()
			if button and button.Parent then
				tween(button, {
					BackgroundColor3 = THEME.Card
				}):Play()
			end
		end)
	end)

	return button
end

for zoneIndex, zone in ipairs(teleportZones) do
	local section = Instance.new("Frame")
	section.Name = zone.Name:gsub("[^%w]", "")
	section.Size = UDim2.new(1, -8, 0, 0)
	section.BackgroundColor3 = THEME.Sidebar
	section.BorderSizePixel = 0
	section.LayoutOrder = zoneIndex
	section.Parent = teleportScroll

	Instance.new("UICorner", section).CornerRadius = UDim.new(0, 10)

	local sectionStroke = Instance.new("UIStroke", section)
	sectionStroke.Color = THEME.Border
	sectionStroke.Thickness = 1

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -24, 0, 32)
	title.Position = UDim2.new(0, 12, 0, 8)
	title.BackgroundTransparency = 1
	title.Text = string.upper(zone.Name)
	title.TextColor3 = THEME.Accent
	title.Font = FONT_BOLD
	title.TextSize = 12
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = section

	local grid = Instance.new("Frame")
	grid.Name = "Grid"
	grid.Size = UDim2.new(1, -24, 0, 0)
	grid.Position = UDim2.new(0, 12, 0, 48)
	grid.BackgroundTransparency = 1
	grid.Parent = section

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0.333333, -7, 0, 44)
	gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
	gridLayout.FillDirection = Enum.FillDirection.Horizontal
	gridLayout.FillDirectionMaxCells = 3
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = grid

	for locationIndex, location in ipairs(zone.Locations) do
		local button = createTeleportButton(
			grid,
			location[1],
			location[2]
		)

		button.LayoutOrder = locationIndex
	end

	local rows = math.ceil(#zone.Locations / 3)
	local gridHeight = rows * 44 + math.max(rows - 1, 0) * 8
	local sectionHeight = 48 + gridHeight + 12

	grid.Size = UDim2.new(1, -24, 0, gridHeight)
	section.Size = UDim2.new(1, -8, 0, sectionHeight)
end

local function updateTeleportCanvas()
	teleportScroll.CanvasSize = UDim2.new(
		0,
		0,
		0,
		teleportLayout.AbsoluteContentSize.Y + 20
	)
end

teleportLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTeleportCanvas)

task.defer(updateTeleportCanvas)

local function switchTab(name)
	for pageName, page in pairs(pages) do
		page.Visible = pageName == name
	end

	setTabStyle(fishTab, name == "Fish")
	setTabStyle(treasureTab, name == "Treasure")
	setTabStyle(teleportTab, name == "Teleport")
end

fishTab.MouseButton1Click:Connect(function()
	switchTab("Fish")
end)

treasureTab.MouseButton1Click:Connect(function()
	switchTab("Treasure")
end)

teleportTab.MouseButton1Click:Connect(function()
	switchTab("Teleport")
end)

switchTab("Fish")
