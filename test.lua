-- LEVEL1 HUB | CORE / MAIN UI > FISH > TREASURE > TELEPORT > GAME PASS

-- ============================================================================
-- PART 1 : CORE / MAIN UI
-- ============================================================================


-- ============================================================================
-- Services
-- ============================================================================

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")


-- ============================================================================
-- Core Variables
-- ============================================================================

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("FishCatcherGui")

if oldGui then
	oldGui:Destroy()
end

local normalSize = UDim2.new(0, 900, 0, 560)
local minimizedSize = UDim2.new(0, 300, 0, 68)
local isMinimized = false
local tabs = {}
local pages = {}
local currentTab = "Fish"
local switchTab
local tabBar
local pageReferences = {}

-- ============================================================================
-- Theme
-- ============================================================================

local THEME = {
	Background = Color3.fromRGB(8, 17, 29),
	Sidebar = Color3.fromRGB(12, 26, 40),
	Panel = Color3.fromRGB(10, 23, 36),

	Card = Color3.fromRGB(18, 36, 52),
	CardHover = Color3.fromRGB(25, 51, 68),
	CardSelected = Color3.fromRGB(22, 62, 78),

	Accent = Color3.fromRGB(85, 225, 219),
	AccentDark = Color3.fromRGB(29, 151, 167),
	ActionText = Color3.fromRGB(2, 14, 22),
	ActionTextMuted = Color3.fromRGB(176, 184, 188),

	Text = Color3.fromRGB(235, 246, 251),
	TextMuted = Color3.fromRGB(151, 176, 191),

	Border = Color3.fromRGB(35, 62, 79),

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

-- Presentation helpers: appearance and motion only.
local function addSurfaceGradient(target, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Name = "SurfaceGradient"
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(192, 215, 235)),
    })
    gradient.Rotation = rotation or 90
    gradient.Parent = target
end

local function bindPressFeedback(button)
    local scale = Instance.new("UIScale")
    scale.Name = "PressScale"
    scale.Parent = button
    local activeTween
    local function animate(value)
        if activeTween then activeTween:Cancel() end
        activeTween = TweenService:Create(scale,
            TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Scale = value})
        activeTween:Play()
    end
    button.MouseButton1Down:Connect(function() animate(0.975) end)
    button.MouseButton1Up:Connect(function() animate(1) end)
    button.MouseLeave:Connect(function() animate(1) end)
end

local function bindSearchFocus(textBox, stroke)
    local focusTween
    local function animate(color, thickness)
        if focusTween then focusTween:Cancel() end
        focusTween = TweenService:Create(stroke, TweenInfo.new(0.18), {
            Color = color, Thickness = thickness,
        })
        focusTween:Play()
    end
    textBox.Focused:Connect(function() animate(THEME.Accent, 1.5) end)
    textBox.FocusLost:Connect(function() animate(THEME.Border, 1) end)
end

local pagePositions = {}
local pageTweens = {}
local function presentPage(element, visible)
    local restingPosition = pagePositions[element] or element.Position
    pagePositions[element] = restingPosition
    if pageTweens[element] then
        pageTweens[element]:Cancel()
        pageTweens[element] = nil
    end
    local entering = visible and not element.Visible
    element.Visible = visible
    element.Position = restingPosition
    if entering then
        element.Position = restingPosition + UDim2.fromOffset(0, 8)
        local tween = TweenService:Create(element,
            TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {Position = restingPosition})
        pageTweens[element] = tween
        tween:Play()
    end
end

local function getRarityColor(rarity)
	return THEME[rarity] or THEME.Unknown
end


-- ============================================================================
-- Main Window
-- ============================================================================

local gui = Instance.new("ScreenGui")
gui.Name = "FishCatcherGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.new(0, 0, 0, 0)
-- Keep the top-right corner fixed while the window opens, minimizes, and expands.
frame.Position = UDim2.new(0.5, 450, 0.5, -280)
frame.AnchorPoint = Vector2.new(1, 0)
frame.BackgroundColor3 = THEME.Background
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 20)

local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Color = THEME.Border
frameStroke.Thickness = 1
addSurfaceGradient(frame, 35)


TweenService:Create(
	frame,
	TweenInfo.new(0.38, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	{
		Size = normalSize
	}
):Play()


-- ============================================================================
-- Header | Title, Minimize Button, Close Button
-- ============================================================================

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 68)
header.BackgroundTransparency = 1
header.Parent = frame

local brandMark = Instance.new("Frame")
brandMark.Name = "BrandMark"
brandMark.Size = UDim2.fromOffset(10, 24)
brandMark.Position = UDim2.fromOffset(24, 20)
brandMark.BackgroundColor3 = THEME.Accent
brandMark.BorderSizePixel = 0
brandMark.Parent = header
Instance.new("UICorner", brandMark).CornerRadius = UDim.new(1, 0)
addSurfaceGradient(brandMark, 90)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 165, 0, 30)
title.AnchorPoint = Vector2.new(0, 0.5)
title.Position = UDim2.new(0, 46, 0, 25)
title.BackgroundTransparency = 1
title.Text = "LEVEL1 HUB"
title.TextColor3 = THEME.Text
title.Font = FONT_BOLD
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local gameTitle = Instance.new("TextLabel")
gameTitle.Size = UDim2.new(0, 400, 0, 18)
gameTitle.Position = UDim2.new(0, 46, 0, 38)
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
close.Text = "×"
close.BackgroundColor3 = THEME.Card
close.TextColor3 = THEME.TextMuted
close.Font = FONT_BOLD
close.TextSize = 20
close.BorderSizePixel = 0
close.AutoButtonColor = false
close.ZIndex = 5
close.Parent = frame

Instance.new("UICorner", close).CornerRadius = UDim.new(0, 10)
bindPressFeedback(close)
bindPressFeedback(minimize)

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


-- ============================================================================
-- Window Controls | Drag, Minimize, Restore / Expand, Close / Destroy
-- ============================================================================

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

	-- Use the label's center as the reference so the minimized title is truly centered.
	TweenService:Create(title, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = isMinimized and UDim2.new(0, 46, 0, 34) or UDim2.new(0, 46, 0, 25)
	}):Play()

	if isMinimized then
		minimize.Text = "+"

		gameTitle.Visible = false
		tabBar.Visible = false
        for _, elements in pairs(pageReferences) do
            for _, element in ipairs(elements) do
                presentPage(element, false)
            end
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


-- ============================================================================
-- Tab Bar | Fish, Treasure, Teleport, Game Pass
-- ============================================================================

tabBar = Instance.new("Frame")
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


local function createTab(name, order)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(0.25, -9, 1, 0)
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
    bindPressFeedback(button)

    local indicator = Instance.new("Frame")
    indicator.Name = "ActiveIndicator"
    indicator.AnchorPoint = Vector2.new(0.5, 1)
    indicator.Position = UDim2.new(0.5, 0, 1, -2)
    indicator.Size = UDim2.new(0, 0, 0, 2)
    indicator.BackgroundColor3 = THEME.Accent
    indicator.BorderSizePixel = 0
    indicator.Parent = button
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

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
createTab("Game Pass", 4)


-- ============================================================================
-- Page References
-- ============================================================================

-- Each feature registers its own panels after constructing its UI.
local function registerPage(name, elements)
    pageReferences[name] = elements
    for _, element in ipairs(elements) do
        presentPage(element, not isMinimized and currentTab == name)
    end
end

-- ============================================================================
-- Tab Switching
-- ============================================================================

switchTab = function(name)
    if not tabs[name] then
        return
    end

    currentTab = name
    for tabName, button in pairs(tabs) do
        local selected = tabName == name
        TweenService:Create(button, TweenInfo.new(0.18), {
            BackgroundTransparency = selected and 0 or 1,
            BackgroundColor3 = selected and THEME.CardSelected or THEME.Card,
            TextColor3 = selected and THEME.Accent or THEME.TextMuted,
        }):Play()
        local indicator = button:FindFirstChild("ActiveIndicator")
        if indicator then
            TweenService:Create(indicator, TweenInfo.new(0.22, Enum.EasingStyle.Quart), {
                Size = UDim2.new(selected and 0.55 or 0, 0, 0, 2),
            }):Play()
        end
    end

    for pageName, elements in pairs(pageReferences) do
        for _, element in ipairs(elements) do
            presentPage(element, not isMinimized and pageName == name)
        end
    end
end
for name, button in pairs(tabs) do
	button.MouseButton1Click:Connect(function()
		switchTab(name)
	end)
end

switchTab("Fish")


-- ============================================================================
-- Shared UI Helpers | 3D Preview
-- ============================================================================

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

-- Some fish contain large invisible root parts or hitboxes. GetBoundingBox includes
-- those parts, so the visible mesh becomes extremely small in a card preview.
local function getVisibleModelBounds(object)
	local minimum = Vector3.new(math.huge, math.huge, math.huge)
	local maximum = Vector3.new(-math.huge, -math.huge, -math.huge)
	local foundVisiblePart = false

	local function includePart(part)
		if part.Transparency >= 0.98 then
			return
		end

		foundVisiblePart = true
		local halfSize = part.Size * 0.5

		for x = -1, 1, 2 do
			for y = -1, 1, 2 do
				for z = -1, 1, 2 do
					local corner = part.CFrame * Vector3.new(
						halfSize.X * x,
						halfSize.Y * y,
						halfSize.Z * z
					)

					minimum = Vector3.new(
						math.min(minimum.X, corner.X),
						math.min(minimum.Y, corner.Y),
						math.min(minimum.Z, corner.Z)
					)
					maximum = Vector3.new(
						math.max(maximum.X, corner.X),
						math.max(maximum.Y, corner.Y),
						math.max(maximum.Z, corner.Z)
					)
				end
			end
		end
	end

	if object:IsA("BasePart") then
		includePart(object)
	else
		for _, descendant in ipairs(object:GetDescendants()) do
			if descendant:IsA("BasePart") then
				includePart(descendant)
			end
		end
	end

	if not foundVisiblePart then
		return getModelBounds(object)
	end

	local size = maximum - minimum
	return CFrame.new((minimum + maximum) * 0.5), size
end

local function centerVisiblePreviewObject(object)
	local cf = getVisibleModelBounds(object)

	if not cf then
		return nil, nil
	end

	local center = cf.Position

	if object:IsA("Model") then
		local pivot = object:GetPivot()
		object:PivotTo(CFrame.new(pivot.Position - center) * pivot.Rotation)
	elseif object:IsA("BasePart") then
		local rotation = object.CFrame - object.CFrame.Position
		object.CFrame = CFrame.new(-center) * rotation
	end

	return getVisibleModelBounds(object)
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


-- ============================================================================
-- PART 2 : FISH
-- ============================================================================


-- ============================================================================
-- Fish Data
-- ============================================================================

local fishFolder = ReplicatedStorage
	:WaitForChild("A__Assets")
	:WaitForChild("Fish")

local fishDataModule = ReplicatedStorage
	:WaitForChild("Shared")
	:WaitForChild("Data")
	:WaitForChild("Template")
	:WaitForChild("Fish")

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

local FishIndex = {}
local viewportCamera
local previewWorld
local previewClone
local previewBasePivot

local previewYaw = 0
local previewPitch = 0
local previewDragging = false
local previewLastPosition = Vector2.zero

local fishButtons = {}

local selectedFish = nil
local selectedButton = nil
local selectedStroke = nil
local selectedRarity = nil

local catchButton
local catchButtonStroke

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

local updatePreview

-- ============================================================================
-- Fish Functions
-- ============================================================================

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

loadFishIndex()
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


-- ============================================================================
-- Fish UI
-- ============================================================================

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 165, 1, -130)
sidebar.Position = UDim2.new(0, 20, 0, 120)
sidebar.BackgroundColor3 = THEME.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = frame

Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)
addSurfaceGradient(sidebar, 80)

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
search.PlaceholderText = "Search fish by name..."
search.BackgroundTransparency = 1
search.TextColor3 = THEME.Text
search.PlaceholderColor3 = THEME.TextMuted
search.Font = FONT_REGULAR
search.TextSize = 13
search.ClearTextOnFocus = false
search.TextXAlignment = Enum.TextXAlignment.Left
search.Parent = searchFrame
bindSearchFocus(search, searchStroke)

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
grid.CellSize = UDim2.new(0, 125, 0, 140)
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
addSurfaceGradient(previewPanel, 80)

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
viewport.Size = UDim2.new(1, -35, 0, 244)
viewport.Position = UDim2.new(0, 17, 0, 108)
viewport.BackgroundColor3 = Color3.fromRGB(7, 20, 32)
viewport.BorderSizePixel = 0
viewport.Ambient = Color3.fromRGB(200, 200, 200)
viewport.LightColor = Color3.fromRGB(255, 255, 255)
viewport.LightDirection = Vector3.new(-1, -1, -1)
viewport.Parent = previewPanel

Instance.new("UICorner", viewport).CornerRadius = UDim.new(0, 12)

catchButton = Instance.new("TextButton")
catchButton.Size = UDim2.new(1, -35, 0, 45)
catchButton.Position = UDim2.new(0, 17, 1, -60)
catchButton.Text = "CATCH FISH"
catchButton.BackgroundColor3 = THEME.Card
catchButton.TextColor3 = THEME.ActionTextMuted
catchButton.Font = FONT_BOLD
catchButton.TextSize = 12
catchButton.TextStrokeTransparency = 1
catchButton.BorderSizePixel = 0
catchButton.AutoButtonColor = false
catchButton.Parent = previewPanel

Instance.new("UICorner", catchButton).CornerRadius = UDim.new(0, 9)

catchButtonStroke = Instance.new("UIStroke", catchButton)
catchButtonStroke.Color = THEME.Border
catchButtonStroke.Thickness = 1
catchButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
catchButtonStroke.Enabled = false

catchButton.BackgroundColor3 = THEME.Card
catchButton.TextColor3 = THEME.ActionTextMuted
catchButton.Active = true

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
	addSurfaceGradient(button, 65)
	bindPressFeedback(button)

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
	rarityLabel.TextSize = 8
	rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
	rarityLabel.Parent = button

	local miniViewport = Instance.new("ViewportFrame")
	miniViewport.Size = UDim2.new(1, -10, 0, 80)
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

		-- Ignore invisible hitboxes when centering and fitting fish cards.
		local miniCF, miniSize = centerVisiblePreviewObject(miniClone)

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

			-- Fit every fish to the existing viewport. The old fixed minimum
			-- distance made physically small fish appear tiny in their cards.
			local miniMax = math.max(miniSize.X, miniSize.Y, miniSize.Z)
			local viewportAspect = 115 / 80
			local halfFovTangent = math.tan(math.rad(miniCamera.FieldOfView * 0.5))
			local distanceForHeight = miniSize.Y / (2 * halfFovTangent)
			local distanceForWidth = miniSize.X / (2 * halfFovTangent * viewportAspect)
			local distance =
				math.max(distanceForHeight, distanceForWidth) * 1.12
				+ miniSize.Z * 0.5

			distance = math.max(distance, miniMax * 0.65, 0.05)

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
	fishName.TextSize = 11
	fishName.TextTruncate = Enum.TextTruncate.AtEnd
	fishName.Parent = button

	local rarityBar = Instance.new("Frame")
	rarityBar.Size = UDim2.new(1, -20, 0, 2)
	rarityBar.Position = UDim2.new(0, 10, 1, -5)
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
		catchButton.TextColor3 = THEME.ActionText
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


-- ============================================================================
-- Fish Search / Fish Filter
-- ============================================================================

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
	categoryButton.TextSize = 10
	categoryButton.LayoutOrder = index
	categoryButton.AutoButtonColor = false
	categoryButton.Parent = categoryContainer
	bindPressFeedback(categoryButton)

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


-- ============================================================================
-- Fish Preview
-- ============================================================================

local function setPreviewRotation()
	if not previewClone or not previewBasePivot then
		return
	end

	-- Apply both axes around the visible model center, which is placed at origin.
	-- Vertical drag direction is intentionally reversed for the model preview.
	local rotation = CFrame.Angles(
		math.rad(previewPitch),
		math.rad(previewYaw),
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

updatePreview = function(fishName, rarity)
	viewport:ClearAllChildren()

	previewWorld = nil
	previewClone = nil
	previewBasePivot = nil
	viewportCamera = nil
	previewYaw = 0
	previewPitch = 0
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

	-- Center the visible fish, ignoring invisible roots and hitboxes.
	local centeredCF, centeredSize = centerVisiblePreviewObject(clone)

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
		previewBasePivot = sideRotation * clone:GetPivot()
	elseif clone:IsA("BasePart") then
		previewBasePivot = sideRotation * clone.CFrame
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
		previewLastPosition = Vector2.new(input.Position.X, input.Position.Y)
	end
end)

UIS.InputChanged:Connect(function(input)
	if not previewDragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local currentPosition = Vector2.new(input.Position.X, input.Position.Y)
		local delta = currentPosition - previewLastPosition

		previewLastPosition = currentPosition
		previewYaw = (previewYaw + delta.X * 0.6) % 360
		previewPitch = (previewPitch + delta.Y * 0.6) % 360

		setPreviewRotation()
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		previewDragging = false
	end
end)


-- ============================================================================
-- Fish Remote
-- ============================================================================

local addToInventoryRF = ReplicatedStorage
	:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_knit@1.7.0")
	:WaitForChild("knit")
	:WaitForChild("Services")
	:WaitForChild("FishService")
	:WaitForChild("RF")
	:WaitForChild("AddToInventory")

catchButton.MouseEnter:Connect(function()
	if selectedFish then
		TweenService:Create(catchButton, TweenInfo.new(0.15), {
			BackgroundColor3 = THEME.Accent
		}):Play()

		TweenService:Create(catchButtonStroke, TweenInfo.new(0.15), {
			Color = THEME.Accent
		}):Play()

		catchButton.TextColor3 = THEME.ActionText
	end
end)

catchButton.MouseLeave:Connect(function()
	if selectedFish then
		TweenService:Create(catchButton, TweenInfo.new(0.15), {
			BackgroundColor3 = THEME.Accent
		}):Play()

		catchButton.TextColor3 = THEME.ActionText
	else
		TweenService:Create(catchButton, TweenInfo.new(0.15), {
			BackgroundColor3 = THEME.Card
		}):Play()

		catchButton.TextColor3 = THEME.ActionTextMuted
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
				catchButton.TextColor3 = THEME.ActionText
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
				catchButton.TextColor3 = THEME.ActionText
				catchButton.Active = true
			end
		end)
	end
end)

registerPage("Fish", {sidebar, content, previewPanel})
task.defer(function()
    updateCanvas()
    filterFish()
end)

-- ============================================================================
-- PART 3 : TREASURE
-- ============================================================================


-- ============================================================================
-- Treasure Data
-- ============================================================================

local treasureFolder = ReplicatedStorage
	:WaitForChild("A__Assets")
	:WaitForChild("Treasure")

local treasureDataModule = ReplicatedStorage
	:WaitForChild("Shared")
	:WaitForChild("Data")
	:WaitForChild("Template")
	:WaitForChild("Treasures")

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

local TreasureIndex = {}

local treasureViewportCamera
local treasurePreviewWorld
local treasurePreviewClone
local treasurePreviewBasePivot
local treasurePreviewRotation = 0
local treasurePreviewDragging = false
local treasurePreviewLastX = 0

local selectedTreasure = nil
local selectedTreasureButton = nil
local selectedTreasureStroke = nil
local selectedTreasureRarity = nil

local collectTreasureButton
local collectTreasureButtonStroke

local treasureButtons = {}

local treasureCategories = {
	"Common",
	"Rare",
	"SuperRare",
	"Mythical",
	"Legendary",
}

local currentTreasureCategory = nil
local treasureCategoryButtons = {}

local updateTreasurePreview

-- ============================================================================
-- Treasure Functions
-- ============================================================================

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

loadTreasureIndex()

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


-- ============================================================================
-- Treasure UI
-- ============================================================================

local treasureSidebar = Instance.new("Frame")
treasureSidebar.Size = UDim2.new(0, 165, 1, -130)
treasureSidebar.Position = UDim2.new(0, 20, 0, 120)
treasureSidebar.BackgroundColor3 = THEME.Sidebar
treasureSidebar.BorderSizePixel = 0
treasureSidebar.Visible = false
treasureSidebar.Parent = frame

Instance.new("UICorner", treasureSidebar).CornerRadius = UDim.new(0, 12)
addSurfaceGradient(treasureSidebar, 80)

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
treasureSearch.PlaceholderText = "Search treasure by name..."
treasureSearch.BackgroundTransparency = 1
treasureSearch.TextColor3 = THEME.Text
treasureSearch.PlaceholderColor3 = THEME.TextMuted
treasureSearch.Font = FONT_REGULAR
treasureSearch.TextSize = 13
treasureSearch.ClearTextOnFocus = false
treasureSearch.TextXAlignment = Enum.TextXAlignment.Left
treasureSearch.Parent = treasureSearchFrame
bindSearchFocus(treasureSearch, treasureSearchStroke)

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
treasureGrid.CellSize = UDim2.new(0, 125, 0, 140)
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
addSurfaceGradient(treasurePreviewPanel, 80)

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
treasureViewport.Size = UDim2.new(1, -35, 0, 244)
treasureViewport.Position = UDim2.new(0, 17, 0, 108)
treasureViewport.BackgroundColor3 = Color3.fromRGB(7, 20, 32)
treasureViewport.BorderSizePixel = 0
treasureViewport.Ambient = Color3.fromRGB(200, 200, 200)
treasureViewport.LightColor = Color3.fromRGB(255, 255, 255)
treasureViewport.LightDirection = Vector3.new(-1, -1, -1)
treasureViewport.Parent = treasurePreviewPanel

Instance.new("UICorner", treasureViewport).CornerRadius = UDim.new(0, 12)

collectTreasureButton = Instance.new("TextButton")
collectTreasureButton.Size = UDim2.new(1, -35, 0, 45)
collectTreasureButton.Position = UDim2.new(0, 17, 1, -60)
collectTreasureButton.Text = "COLLECT TREASURE"
collectTreasureButton.BackgroundColor3 = THEME.Card
collectTreasureButton.TextColor3 = THEME.ActionTextMuted
collectTreasureButton.Font = FONT_BOLD
collectTreasureButton.TextSize = 12
collectTreasureButton.TextStrokeTransparency = 1
collectTreasureButton.BorderSizePixel = 0
collectTreasureButton.AutoButtonColor = false
collectTreasureButton.Parent = treasurePreviewPanel

Instance.new("UICorner", collectTreasureButton).CornerRadius = UDim.new(0, 9)

collectTreasureButtonStroke = Instance.new("UIStroke", collectTreasureButton)
collectTreasureButtonStroke.Color = THEME.Border
collectTreasureButtonStroke.Thickness = 1
collectTreasureButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
collectTreasureButtonStroke.Enabled = false

collectTreasureButton.BackgroundColor3 = THEME.Card
collectTreasureButton.TextColor3 = THEME.ActionTextMuted
collectTreasureButton.Active = true

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
	addSurfaceGradient(button, 65)
	bindPressFeedback(button)

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
	miniViewport.Size = UDim2.new(1, -10, 0, 80)
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
	treasureNameLabel.TextSize = 11
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
		collectTreasureButton.TextColor3 = THEME.ActionText
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


-- ============================================================================
-- Treasure Search / Treasure Filter
-- ============================================================================

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
	categoryButton.TextSize = 10
	categoryButton.LayoutOrder = index
	categoryButton.AutoButtonColor = false
	categoryButton.Parent = treasureCategoryContainer
	bindPressFeedback(categoryButton)

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


-- ============================================================================
-- Treasure Preview
-- ============================================================================

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

updateTreasurePreview = function(treasureName, rarity)
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


-- ============================================================================
-- Treasure Remote
-- ============================================================================

local treasureAddToInventoryRF = ReplicatedStorage
	:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("sleitnick_knit@1.7.0")
	:WaitForChild("knit")
	:WaitForChild("Services")
	:WaitForChild("TreasureService")
	:WaitForChild("RF")
	:WaitForChild("AddToInventory")

collectTreasureButton.MouseEnter:Connect(function()
	if selectedTreasure then
		TweenService:Create(collectTreasureButton, TweenInfo.new(0.15), {
			BackgroundColor3 = THEME.Accent
		}):Play()

		TweenService:Create(collectTreasureButtonStroke, TweenInfo.new(0.15), {
			Color = THEME.Accent
		}):Play()

		collectTreasureButton.TextColor3 = THEME.ActionText
	end
end)

collectTreasureButton.MouseLeave:Connect(function()
	if selectedTreasure then
		TweenService:Create(collectTreasureButton, TweenInfo.new(0.15), {
			BackgroundColor3 = THEME.Accent
		}):Play()

		collectTreasureButton.TextColor3 = THEME.ActionText
	else
		TweenService:Create(collectTreasureButton, TweenInfo.new(0.15), {
			BackgroundColor3 = THEME.Card
		}):Play()

		collectTreasureButton.TextColor3 = THEME.ActionTextMuted
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
				collectTreasureButton.TextColor3 = THEME.ActionText
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
				collectTreasureButton.TextColor3 = THEME.ActionText
				collectTreasureButton.Active = true
			end
		end)
	end
end)

registerPage("Treasure", {treasureSidebar, treasureContent, treasurePreviewPanel})
task.defer(function()
    updateTreasureCanvas()
    filterTreasure()
end)

-- ============================================================================
-- PART 4 : TELEPORT
-- ============================================================================


-- ============================================================================
-- Teleport Data
-- ============================================================================

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


-- ============================================================================
-- Teleport Functions
-- ============================================================================

local function teleportTo(position)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if root then
		root.CFrame = CFrame.new(position)
	end
end


-- ============================================================================
-- Teleport UI
-- ============================================================================

local teleportPage = Instance.new("Frame")
teleportPage.Name = "TeleportPage"
teleportPage.Size = UDim2.new(1, -40, 1, -130)
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
addSurfaceGradient(teleportPanel, 80)

local teleportStroke = Instance.new("UIStroke", teleportPanel)
teleportStroke.Color = THEME.Border
teleportStroke.Thickness = 1

local teleportTitle = Instance.new("TextLabel")
teleportTitle.Size = UDim2.new(1, -30, 0, 30)
teleportTitle.Position = UDim2.new(0, 15, 0, 15)
teleportTitle.BackgroundTransparency = 1
teleportTitle.Text = "DESTINATIONS"
teleportTitle.TextColor3 = THEME.Text
teleportTitle.Font = FONT_BOLD
teleportTitle.TextSize = 16
teleportTitle.TextXAlignment = Enum.TextXAlignment.Left
teleportTitle.Parent = teleportPanel

local teleportInfo = Instance.new("TextLabel")
teleportInfo.Size = UDim2.new(1, -30, 0, 25)
teleportInfo.Position = UDim2.new(0, 15, 0, 43)
teleportInfo.BackgroundTransparency = 1
teleportInfo.Text = "Choose an area, then select where you want to go"
teleportInfo.TextColor3 = THEME.TextMuted
teleportInfo.Font = FONT_REGULAR
teleportInfo.TextSize = 11
teleportInfo.TextXAlignment = Enum.TextXAlignment.Left
teleportInfo.Parent = teleportPanel

local zoneGrid = Instance.new("Frame")
zoneGrid.Name = "ZoneGrid"
zoneGrid.Size = UDim2.new(1, -30, 1, -88)
zoneGrid.Position = UDim2.new(0, 15, 0, 73)
zoneGrid.BackgroundTransparency = 1
zoneGrid.Parent = teleportPanel

local zoneGridLayout = Instance.new("UIGridLayout")
zoneGridLayout.CellSize = UDim2.new(1 / 3, -8, 1, 0)
zoneGridLayout.CellPadding = UDim2.new(0, 12, 0, 0)
zoneGridLayout.FillDirection = Enum.FillDirection.Horizontal
zoneGridLayout.FillDirectionMaxCells = 3
zoneGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
zoneGridLayout.Parent = zoneGrid

local function createZoneCard(zone, zoneOrder)
	local card = Instance.new("Frame")
	card.Name = zone.Name .. "Card"
	card.LayoutOrder = zoneOrder
	card.BackgroundColor3 = Color3.fromRGB(14, 31, 46)
	card.BorderSizePixel = 0
	card.Parent = zoneGrid

	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

	local cardStroke = Instance.new("UIStroke", card)
	cardStroke.Color = THEME.Border
	cardStroke.Thickness = 1

	local zoneTitle = Instance.new("TextLabel")
	zoneTitle.Size = UDim2.new(1, -28, 0, 28)
	zoneTitle.Position = UDim2.fromOffset(14, 13)
	zoneTitle.BackgroundTransparency = 1
	zoneTitle.Text = string.upper(zone.Name)
	zoneTitle.TextColor3 = THEME.Text
	zoneTitle.Font = FONT_BOLD
	zoneTitle.TextSize = 11
	zoneTitle.TextTruncate = Enum.TextTruncate.AtEnd
	zoneTitle.TextXAlignment = Enum.TextXAlignment.Left
	zoneTitle.Parent = card

	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(1, -28, 0, 1)
	divider.Position = UDim2.fromOffset(14, 51)
	divider.BackgroundColor3 = THEME.Border
	divider.BackgroundTransparency = 0.25
	divider.BorderSizePixel = 0
	divider.Parent = card

	local locationList = Instance.new("ScrollingFrame")
	locationList.Name = "Locations"
	locationList.Size = UDim2.new(1, -28, 1, -68)
	locationList.Position = UDim2.fromOffset(14, 61)
	locationList.BackgroundTransparency = 1
	locationList.BorderSizePixel = 0
	locationList.CanvasSize = UDim2.new(0, 0, 0, 0)
	locationList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	locationList.ScrollBarThickness = 2
	locationList.ScrollBarImageColor3 = Color3.fromRGB(88, 123, 140)
	locationList.ScrollBarImageTransparency = 0.25
	locationList.Parent = card

	local locationLayout = Instance.new("UIListLayout")
	locationLayout.Padding = UDim.new(0, 7)
	locationLayout.SortOrder = Enum.SortOrder.LayoutOrder
	locationLayout.Parent = locationList

	return locationList
end

local function createTeleportButton(parent, name, position, order)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(1, 0, 0, 45)
	button.LayoutOrder = order
	button.BackgroundColor3 = THEME.Card
	button.BorderSizePixel = 0
	button.Text = name
	button.TextColor3 = THEME.Text
	button.Font = FONT_REGULAR
	button.TextSize = 11
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.TextWrapped = true
	button.AutoButtonColor = false
	button.Parent = parent
	bindPressFeedback(button)

	local textPadding = Instance.new("UIPadding")
	textPadding.PaddingLeft = UDim.new(0, 14)
	textPadding.PaddingRight = UDim.new(0, 10)
	textPadding.Parent = button

	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

	local stroke = Instance.new("UIStroke", button)
	stroke.Color = THEME.Border
	stroke.Thickness = 1

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), {
			BackgroundColor3 = THEME.CardHover,
			TextColor3 = THEME.Text
		}):Play()

		TweenService:Create(stroke, TweenInfo.new(0.12), {
			Color = Color3.fromRGB(73, 112, 130)
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), {
			BackgroundColor3 = THEME.Card,
			TextColor3 = THEME.Text
		}):Play()

		TweenService:Create(stroke, TweenInfo.new(0.12), {
			Color = THEME.Border
		}):Play()
	end)

	button.MouseButton1Click:Connect(function()
		teleportTo(position)
	end)

	return button
end

for zoneOrder, zone in ipairs(teleportZones) do
	local locationList = createZoneCard(zone, zoneOrder)

	for locationOrder, location in ipairs(zone.Locations) do
		createTeleportButton(
			locationList,
			location[1],
			location[2],
			locationOrder
		)
	end
end

registerPage("Teleport", {teleportPage})

-- ============================================================================
-- PART 5 : GAME PASS
-- ============================================================================

local MarketplaceService = game:GetService("MarketplaceService")

local gamePassItems = {
	{Name = "+1000 Money", Id = 3304032773},
	{Name = "+10K Money", Id = 3304032980},
	{Name = "+100K Money", Id = 3304033107},
	{Name = "+1M Money", Id = 3304033285},

	{Name = "+100 Gems", Id = 3304033536},
	{Name = "+500 Gems", Id = 3304033742},
	{Name = "+1000 Gems", Id = 3304033861},
	{Name = "+10K Gems", Id = 3304033993},
}

local gamePassPage = Instance.new("Frame")
gamePassPage.Name = "GamePassPage"
gamePassPage.Size = UDim2.new(1, -40, 1, -130)
gamePassPage.Position = UDim2.new(0, 20, 0, 120)
gamePassPage.BackgroundTransparency = 1
gamePassPage.Visible = false
gamePassPage.Parent = frame

pages["Game Pass"] = gamePassPage

local gamePassPanel = Instance.new("Frame")
gamePassPanel.Size = UDim2.new(1, 0, 1, 0)
gamePassPanel.BackgroundColor3 = THEME.Sidebar
gamePassPanel.BorderSizePixel = 0
gamePassPanel.Parent = gamePassPage

Instance.new("UICorner", gamePassPanel).CornerRadius = UDim.new(0, 12)
addSurfaceGradient(gamePassPanel, 80)

local gamePassStroke = Instance.new("UIStroke", gamePassPanel)
gamePassStroke.Color = THEME.Border
gamePassStroke.Thickness = 1

local gamePassTitle = Instance.new("TextLabel")
gamePassTitle.Size = UDim2.new(1, -30, 0, 30)
gamePassTitle.Position = UDim2.fromOffset(15, 15)
gamePassTitle.BackgroundTransparency = 1
gamePassTitle.Text = "GAME PASS"
gamePassTitle.TextColor3 = THEME.Text
gamePassTitle.Font = FONT_BOLD
gamePassTitle.TextSize = 16
gamePassTitle.TextXAlignment = Enum.TextXAlignment.Left
gamePassTitle.Parent = gamePassPanel

local gamePassInfo = Instance.new("TextLabel")
gamePassInfo.Size = UDim2.new(1, -30, 0, 24)
gamePassInfo.Position = UDim2.fromOffset(15, 43)
gamePassInfo.BackgroundTransparency = 1
gamePassInfo.Text = "Money & Gems"
gamePassInfo.TextColor3 = THEME.TextMuted
gamePassInfo.Font = FONT_REGULAR
gamePassInfo.TextSize = 11
gamePassInfo.TextXAlignment = Enum.TextXAlignment.Left
gamePassInfo.Parent = gamePassPanel

local gamePassList = Instance.new("ScrollingFrame")
gamePassList.Name = "GamePassList"
gamePassList.Size = UDim2.new(1, -30, 1, -88)
gamePassList.Position = UDim2.fromOffset(15, 73)
gamePassList.BackgroundTransparency = 1
gamePassList.BorderSizePixel = 0
gamePassList.CanvasSize = UDim2.new(0, 0, 0, 0)
gamePassList.AutomaticCanvasSize = Enum.AutomaticSize.Y
gamePassList.ScrollBarThickness = 2
gamePassList.ScrollBarImageColor3 = Color3.fromRGB(88, 123, 140)
gamePassList.Parent = gamePassPanel

local gamePassLayout = Instance.new("UIListLayout")
gamePassLayout.Padding = UDim.new(0, 8)
gamePassLayout.SortOrder = Enum.SortOrder.LayoutOrder
gamePassLayout.Parent = gamePassList

local function promptGamePassProduct(id)
	local success, err = pcall(function()
		MarketplaceService:PromptProductPurchase(player, id)
	end)
	if not success then
		warn("[Level1 Hub] Product purchase prompt failed:", err)
	end
	return success
end

local function createGamePassButton(item, order)
	local button = Instance.new("TextButton")
	button.Name = "GamePass_" .. tostring(item.Id)
	button.Size = UDim2.new(1, 0, 0, 48)
	button.LayoutOrder = order
	button.BackgroundColor3 = THEME.Card
	button.BorderSizePixel = 0
	button.Text = ""
	button.AutoButtonColor = false
	button.Parent = gamePassList

	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)

	local stroke = Instance.new("UIStroke", button)
	stroke.Color = THEME.Border
	stroke.Thickness = 1

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -110, 1, 0)
	nameLabel.Position = UDim2.fromOffset(18, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = string.upper(item.Name)
	nameLabel.TextColor3 = THEME.Text
	nameLabel.Font = FONT_BOLD
	nameLabel.TextSize = 13
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = button

	local buyButton = Instance.new("TextButton")
	buyButton.AnchorPoint = Vector2.new(1, 0.5)
	buyButton.Size = UDim2.fromOffset(70, 30)
	buyButton.Position = UDim2.new(1, -10, 0.5, 0)
	buyButton.BackgroundColor3 = Color3.fromRGB(77, 190, 112)
	buyButton.BorderSizePixel = 0
	buyButton.Text = "BUY"
	buyButton.TextColor3 = THEME.ActionText
	buyButton.Font = FONT_BOLD
	buyButton.TextSize = 10
	buyButton.AutoButtonColor = false
	buyButton.Parent = button

	Instance.new("UICorner", buyButton).CornerRadius = UDim.new(0, 8)

	buyButton.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), {
			BackgroundColor3 = THEME.CardHover
		}):Play()

		TweenService:Create(stroke, TweenInfo.new(0.12), {
			Color = Color3.fromRGB(77, 225, 132)
		}):Play()
	end)

	buyButton.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), {
			BackgroundColor3 = THEME.Card
		}):Play()

		TweenService:Create(stroke, TweenInfo.new(0.12), {
			Color = THEME.Border
		}):Play()
	end)

	buyButton.MouseButton1Click:Connect(function()
		buyButton.Text = "..."
		local success = promptGamePassProduct(item.Id)
		if buyButton.Parent then
			buyButton.Text = success and "BUY" or "ERROR"
		end
	end)
end

for order, item in ipairs(gamePassItems) do
	createGamePassButton(item, order)
end

registerPage("Game Pass", {gamePassPage})
