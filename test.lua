--==================================================
-- PART 1 : CORE / MAIN UI
--==================================================

--==================================================
-- SERVICES
--==================================================

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

--==================================================
-- CORE VARIABLES
--==================================================

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

--==================================================
-- THEME
--==================================================

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

--==================================================
-- MAIN WINDOW
--==================================================

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

--==================================================
-- HEADER
--==================================================

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

--==================================================
-- WINDOW CONTROLS
--==================================================

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

--==================================================
-- TAB SYSTEM
--==================================================

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

--==================================================
-- PAGE REFERENCES
--==================================================

local sidebar
local content
local previewPanel

local treasureSidebar
local treasureContent
local treasurePreviewPanel

local teleportPage

--==================================================
-- TAB SWITCHING
--==================================================

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

--==================================================
-- WINDOW DRAG
--==================================================

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

--==================================================
-- WINDOW MINIMIZE / RESTORE
--==================================================

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

--==================================================
-- WINDOW CLOSE
--==================================================

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

--==================================================
-- PART 1 END
--==================================================
