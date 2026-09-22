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

local teleportLayout = Instance.new("UIListLayout")
teleportLayout.Padding = UDim.new(0, 8)
teleportLayout.SortOrder = Enum.SortOrder.LayoutOrder
teleportLayout.Parent = teleportList

local function createTeleportZoneTitle(name, order)
	local label = Instance.new("TextLabel")
	label.Name = name .. "Title"
	label.Size = UDim2.new(1, -4, 0, 30)
	label.LayoutOrder = order
	label.BackgroundTransparency = 1
	label.Text = string.upper(name)
	label.TextColor3 = THEME.Accent
	label.Font = FONT_BOLD
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = teleportList

	return label
end

local function createTeleportButton(name, position, order)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(1, -4, 0, 48)
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

		TweenService:Create(stroke, TweenInfo.new(0.12), {
			Color = THEME.Accent
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

local teleportOrder = 0

for _, zone in ipairs(teleportZones) do
	teleportOrder += 1
	createTeleportZoneTitle(zone.Name, teleportOrder)

	for _, location in ipairs(zone.Locations) do
		teleportOrder += 1
		createTeleportButton(
			location[1],
			location[2],
			teleportOrder
		)
	end
end

local function updateTeleportCanvas()
	teleportList.CanvasSize = UDim2.new(
		0,
		0,
		0,
		teleportLayout.AbsoluteContentSize.Y + 10
	)
end

teleportLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTeleportCanvas)

task.defer(updateTeleportCanvas)
