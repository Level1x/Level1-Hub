--========================================================
-- LEVEL1 HUB
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--========================================================
-- COLORS
--========================================================

local Colors = {
    Background = Color3.fromRGB(12, 10, 16),
    Sidebar = Color3.fromRGB(18, 15, 24),
    Content = Color3.fromRGB(14, 12, 19),

    Purple = Color3.fromRGB(145, 70, 255),
    PurpleDark = Color3.fromRGB(75, 35, 125),

    Text = Color3.fromRGB(240, 235, 245),
    Muted = Color3.fromRGB(145, 137, 155),

    Green = Color3.fromRGB(70, 220, 120),
    Yellow = Color3.fromRGB(240, 190, 60),
    Red = Color3.fromRGB(240, 70, 80),
}

--========================================================
-- DEFAULT
--========================================================

local DefaultWalkSpeed = 16
local DefaultJumpPower = 50
local DefaultGravity = 196.2
local DefaultFlySpeed = 100

--========================================================
-- CONFIG
--========================================================

local Config = {
    ESPPlayer = false,
    ESPHitBox = false,
    ShowName = false,
    ShowHealth = false,
    ESPDistance = 100,

    WalkSpeedEnabled = false,
    WalkSpeed = DefaultWalkSpeed,

    SwimSpeedEnabled = false,
    SwimSpeed = DefaultSwimSpeed,

    JumpPowerEnabled = false,
    JumpPower = DefaultJumpPower,

    NoClip = false,

    Fly = false,
    FlySpeed = DefaultFlySpeed,

    GravityEnabled = false,
    Gravity = DefaultGravity,

    AntiKnockback = false,
    AntiRagdoll = false,

    ScaleUp = 0,
}

--========================================================
-- CHARACTER
--========================================================

local Character
local Humanoid
local RootPart

local CharacterBaseScale = 1

local NoClipConnection
local FlyConnection
local AntiKnockbackConnection
local AntiRagdollConnection

local FlyAttachment
local FlyVelocity
local FlyOrientation

--========================================================
-- ESP
--========================================================

local ESPData = {}

--========================================================
-- UI
--========================================================

local ToggleSetters = {}
local SliderSetters = {}

local CurrentTab = "Main"

--========================================================
-- CHARACTER SETUP
--========================================================

local function SetCharacter(character)
    Character = character

    Humanoid =
        character:WaitForChild(
            "Humanoid",
            10
        )

    RootPart =
        character:WaitForChild(
            "HumanoidRootPart",
            10
        )

    if Character then
        local success, scale = false, nil

        if typeof(Character.GetScale) == "function" then
            success, scale =
                pcall(function()
                    return Character:GetScale()
                end)
        end

        if success
            and typeof(scale) == "number"
            and scale > 0 then

            CharacterBaseScale = scale
        else
            CharacterBaseScale = 1
        end
    end
end

--========================================================
-- SCALE
--========================================================

local function GetScaleMultiplier()
    local value =
        math.clamp(
            Config.ScaleUp,
            -1,
            10
        )

    if value < 0 then
        return math.max(
            0.1,
            1 + value
        )
    end

    return 1 + value
end

local function ApplyScale()
    if not Character
        or not Character.Parent then
        return
    end

    if typeof(Character.ScaleTo) ~= "function" then
        return
    end

    pcall(function()
        Character:ScaleTo(
            CharacterBaseScale
            * GetScaleMultiplier()
        )
    end)
end

--========================================================
-- WALK SPEED
--========================================================

local function ApplyWalkSpeed()
    if not Humanoid then
        return
    end

    if Config.WalkSpeedEnabled then
        Humanoid.WalkSpeed =
            math.clamp(
                Config.WalkSpeed,
                16,
                1000
            )
    else
        Humanoid.WalkSpeed =
            DefaultWalkSpeed
    end
end


--========================================================
-- SWIM SPEED
--========================================================

local function ApplySwimSpeed()
    if not Humanoid then
        return
    end

    if not Config.SwimSpeedEnabled then
        ApplyWalkSpeed()
        return
    end

    if Humanoid:GetState() ==
        Enum.HumanoidStateType.Swimming then

        Humanoid.WalkSpeed =
            math.clamp(
                Config.SwimSpeed,
                16,
                1000
            )
    else
        ApplyWalkSpeed()
    end
end

--========================================================
-- JUMP POWER
--========================================================

local function ApplyJumpPower()
    if not Humanoid then
        return
    end

    Humanoid.UseJumpPower = true

    if Config.JumpPowerEnabled then
        Humanoid.JumpPower =
            math.clamp(
                Config.JumpPower,
                50,
                1000
            )
    else
        Humanoid.JumpPower =
            DefaultJumpPower
    end
end

--========================================================
-- GRAVITY
--========================================================

local function ApplyGravity()
    if Config.GravityEnabled then
        workspace.Gravity =
            math.clamp(
                Config.Gravity,
                0,
                1000
            )
    else
        workspace.Gravity =
            DefaultGravity
    end
end

--========================================================
-- NO CLIP
--========================================================

local function StopNoClip()
    if NoClipConnection then
        pcall(function()
            NoClipConnection:Disconnect()
        end)

        NoClipConnection = nil
    end

    if not Character then
        return
    end

    for _, object in ipairs(
        Character:GetDescendants()
    ) do
        if object:IsA("BasePart") then
            object.CanCollide = true
        end
    end
end

local function StartNoClip()
    StopNoClip()

    NoClipConnection =
        RunService.Stepped:Connect(
            function()
                if not Config.NoClip then
                    return
                end

                if not Character then
                    return
                end

                for _, object in ipairs(
                    Character:GetDescendants()
                ) do
                    if object:IsA("BasePart") then
                        object.CanCollide = false
                    end
                end
            end
        )
end

--========================================================
-- ANTI KNOCKBACK
--========================================================

local function StopAntiKnockback()
    if AntiKnockbackConnection then
        pcall(function()
            AntiKnockbackConnection:Disconnect()
        end)

        AntiKnockbackConnection = nil
    end
end

local function StartAntiKnockback()
    StopAntiKnockback()

    AntiKnockbackConnection =
        RunService.Heartbeat:Connect(
            function()
                if not Config.AntiKnockback then
                    return
                end

                if not RootPart
                    or not RootPart.Parent then
                    return
                end

                local velocity =
                    RootPart.AssemblyLinearVelocity

                local horizontal =
                    Vector3.new(
                        velocity.X,
                        0,
                        velocity.Z
                    )

                local moving =
                    Humanoid
                    and Humanoid.MoveDirection.Magnitude
                        > 0.05

                if horizontal.Magnitude > 60
                    and not moving then

                    RootPart.AssemblyLinearVelocity =
                        Vector3.new(
                            0,
                            velocity.Y,
                            0
                        )
                end
            end
        )
end

--========================================================
-- ANTI RAGDOLL
--========================================================

local function StopAntiRagdoll()
    if AntiRagdollConnection then
        pcall(function()
            AntiRagdollConnection:Disconnect()
        end)

        AntiRagdollConnection = nil
    end

    if not Humanoid then
        return
    end

    pcall(function()
        Humanoid:SetStateEnabled(
            Enum.HumanoidStateType.FallingDown,
            true
        )

        Humanoid:SetStateEnabled(
            Enum.HumanoidStateType.Ragdoll,
            true
        )

        Humanoid:SetStateEnabled(
            Enum.HumanoidStateType.Physics,
            true
        )

        Humanoid.AutoRotate = true
    end)
end

local function StartAntiRagdoll()
    StopAntiRagdoll()

    if not Humanoid then
        return
    end

    pcall(function()
        Humanoid:SetStateEnabled(
            Enum.HumanoidStateType.FallingDown,
            false
        )

        Humanoid:SetStateEnabled(
            Enum.HumanoidStateType.Ragdoll,
            false
        )

        Humanoid:SetStateEnabled(
            Enum.HumanoidStateType.Physics,
            false
        )
    end)

    AntiRagdollConnection =
        RunService.Heartbeat:Connect(
            function()
                if not Config.AntiRagdoll then
                    return
                end

                if not Humanoid
                    or not RootPart then
                    return
                end

                if not Config.Fly then
                    pcall(function()
                        Humanoid.AutoRotate = true

                        local state =
                            Humanoid:GetState()

                        if state ==
                            Enum.HumanoidStateType.FallingDown
                            or state ==
                                Enum.HumanoidStateType.Ragdoll
                            or state ==
                                Enum.HumanoidStateType.Physics then

                            Humanoid:ChangeState(
                                Enum.HumanoidStateType.GettingUp
                            )
                        end
                    end)
                end

                if RootPart.Parent then
                    RootPart.AssemblyAngularVelocity =
                        Vector3.zero
                end
            end
        )
end

--========================================================
-- FLY
--========================================================

local function StopFly()
    if FlyConnection then
        pcall(function()
            FlyConnection:Disconnect()
        end)

        FlyConnection = nil
    end

    if FlyVelocity then
        pcall(function()
            FlyVelocity:Destroy()
        end)

        FlyVelocity = nil
    end

    if FlyOrientation then
        pcall(function()
            FlyOrientation:Destroy()
        end)

        FlyOrientation = nil
    end

    if FlyAttachment then
        pcall(function()
            FlyAttachment:Destroy()
        end)

        FlyAttachment = nil
    end

    if RootPart
        and RootPart.Parent then

        pcall(function()
            RootPart.AssemblyLinearVelocity =
                Vector3.zero

            RootPart.AssemblyAngularVelocity =
                Vector3.zero
        end)
    end

    if Humanoid then
        pcall(function()
            Humanoid.PlatformStand = false
            Humanoid.AutoRotate = true
        end)
    end
end

local function StartFly()
    StopFly()

    if not RootPart
        or not Humanoid
        or not RootPart.Parent then
        return
    end

    local attachment =
        Instance.new("Attachment")

    attachment.Name =
        "LEVEL1_FlyAttachment"

    attachment.Parent =
        RootPart

    local velocity =
        Instance.new("LinearVelocity")

    velocity.Name =
        "LEVEL1_FlyVelocity"

    velocity.Attachment0 =
        attachment

    velocity.RelativeTo =
        Enum.ActuatorRelativeTo.World

    velocity.MaxForce =
        math.huge

    velocity.VectorVelocity =
        Vector3.zero

    velocity.Parent =
        RootPart

    local orientation =
        Instance.new("AlignOrientation")

    orientation.Name =
        "LEVEL1_FlyOrientation"

    orientation.Mode =
        Enum.OrientationAlignmentMode.OneAttachment

    orientation.Attachment0 =
        attachment

    orientation.RigidityEnabled =
        true

    orientation.MaxTorque =
        math.huge

    orientation.Responsiveness =
        200

    orientation.Parent =
        RootPart

    FlyAttachment = attachment
    FlyVelocity = velocity
    FlyOrientation = orientation

    Humanoid.PlatformStand = false
    Humanoid.AutoRotate = false

    FlyConnection =
        RunService.RenderStepped:Connect(
            function()
                if not Config.Fly then
                    return
                end

                if not RootPart
                    or not RootPart.Parent then
                    return
                end

                if not velocity
                    or not velocity.Parent then
                    return
                end

                if not orientation
                    or not orientation.Parent then
                    return
                end

                local camera =
                    workspace.CurrentCamera

                if not camera then
                    return
                end

                local lookVector =
                    camera.CFrame.LookVector

                local forward =
                    Vector3.new(
                        lookVector.X,
                        0,
                        lookVector.Z
                    )

                if forward.Magnitude <= 0 then
                    return
                end

                forward = forward.Unit

                local rightVector =
                    camera.CFrame.RightVector

                local right =
                    Vector3.new(
                        rightVector.X,
                        0,
                        rightVector.Z
                    )

                if right.Magnitude <= 0 then
                    return
                end

                right = right.Unit

                local direction =
                    Vector3.zero

                local pressingW =
                    UserInputService:IsKeyDown(
                        Enum.KeyCode.W
                    )

                local pressingS =
                    UserInputService:IsKeyDown(
                        Enum.KeyCode.S
                    )

                local pressingA =
                    UserInputService:IsKeyDown(
                        Enum.KeyCode.A
                    )

                local pressingD =
                    UserInputService:IsKeyDown(
                        Enum.KeyCode.D
                    )

                if pressingW then
                    direction += forward
                end

                if pressingS then
                    direction -= forward
                end

                if pressingA then
                    direction -= right
                end

                if pressingD then
                    direction += right
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.Space
                ) then
                    direction += Vector3.yAxis
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.LeftControl
                ) then
                    direction -= Vector3.yAxis
                end

                if direction.Magnitude > 0 then
                    direction =
                        direction.Unit
                        * math.clamp(
                            Config.FlySpeed,
                            1,
                            1000
                        )
                end

                velocity.VectorVelocity =
                    direction

                local pitch = 0
                local roll = 0

                if pressingW and not pressingS then
                    pitch = math.rad(-35)
                elseif pressingS and not pressingW then
                    pitch = math.rad(35)
                end

                if pressingA and not pressingD then
                    roll = math.rad(35)
                elseif pressingD and not pressingA then
                    roll = math.rad(-35)
                end

                local baseCFrame =
                    CFrame.lookAt(
                        Vector3.zero,
                        forward,
                        Vector3.yAxis
                    )

                orientation.CFrame =
                    baseCFrame
                    * CFrame.Angles(
                        pitch,
                        0,
                        roll
                    )
            end
        )
end

--========================================================
-- ESP VALIDATION
--========================================================

local function IsCharacterValid(character)
    if not character
        or not character.Parent then
        return false
    end

    return
        character:FindFirstChildOfClass(
            "Humanoid"
        ) ~= nil
        and character:FindFirstChild(
            "HumanoidRootPart"
        ) ~= nil
end

local function IsInRange(player)
    local character =
        player.Character

    if not IsCharacterValid(character) then
        return false
    end

    if not RootPart
        or not RootPart.Parent then
        return false
    end

    local root =
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not root then
        return false
    end

    return (
        root.Position - RootPart.Position
    ).Magnitude <= Config.ESPDistance
end

--========================================================
-- ESP WALL CHECK
--========================================================

local function IsBehindObstacle(character)
    local camera =
        workspace.CurrentCamera

    if not camera
        or not character then
        return false
    end

    local target =
        character:FindFirstChild("Head")
        or character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not target then
        return false
    end

    local origin =
        camera.CFrame.Position

    local direction =
        target.Position - origin

    if direction.Magnitude <= 0 then
        return false
    end

    local params =
        RaycastParams.new()

    params.FilterType =
        Enum.RaycastFilterType.Exclude

    params.FilterDescendantsInstances = {
        LocalPlayer.Character,
        character,
    }

    params.IgnoreWater = true

    return workspace:Raycast(
        origin,
        direction,
        params
    ) ~= nil
end

--========================================================
-- ESP HITBOX
--========================================================

local function CreateHitBox(character)
    if not IsCharacterValid(character) then
        return nil
    end

    local root =
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not root then
        return nil
    end

    local folder =
        Instance.new("Folder")

    folder.Name =
        "LEVEL1_HitBox"

    folder.Parent =
        root

    local lines = {}

    for i = 1, 12 do
        local line =
            Instance.new(
                "BoxHandleAdornment"
            )

        line.Name =
            "Line_" .. i

        line.Adornee =
            root

        line.Color3 =
            Colors.Purple

        line.Transparency =
            0

        line.AlwaysOnTop =
            true

        line.ZIndex =
            10

        line.Visible =
            false

        line.Parent =
            folder

        lines[i] =
            line
    end

    return {
        Folder = folder,
        Lines = lines,
    }
end

--========================================================
-- ESP INFO
--========================================================

local function GetHealthColor(ratio)
    ratio =
        math.clamp(
            ratio,
            0,
            1
        )

    if ratio > 0.6 then
        return Colors.Green
    elseif ratio > 0.3 then
        return Colors.Yellow
    else
        return Colors.Red
    end
end

local function CreateInfo(
    player,
    character,
    head,
    root
)
    local billboard =
        Instance.new("BillboardGui")

    billboard.Name =
        "LEVEL1_Info"

    billboard.Adornee =
        head or root

    billboard.Size =
        UDim2.fromOffset(
            220,
            110
        )

    billboard.StudsOffset =
        Vector3.new(
            0,
            2.4,
            0
        )

    billboard.AlwaysOnTop = true

    billboard.MaxDistance =
        Config.ESPDistance

    billboard.Parent =
        head or root

    local nameLabel =
        Instance.new("TextLabel")

    nameLabel.Name = "Name"

    nameLabel.Size =
        UDim2.new(
            1,
            0,
            0,
            24
        )

    nameLabel.Position =
        UDim2.fromOffset(0, 0)

    nameLabel.BackgroundTransparency =
        1

    nameLabel.TextColor3 =
        Colors.Text

    nameLabel.TextStrokeColor3 =
        Color3.new(0, 0, 0)

    nameLabel.TextStrokeTransparency =
        0

    nameLabel.TextSize = 14

    nameLabel.Font =
        Enum.Font.FredokaOne

    nameLabel.TextXAlignment =
        Enum.TextXAlignment.Center

    nameLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    nameLabel.Text =
        player.DisplayName

    nameLabel.Visible =
        Config.ShowName

    nameLabel.Parent =
        billboard

    local usernameLabel =
        Instance.new("TextLabel")

    usernameLabel.Name =
        "Username"

    usernameLabel.Size =
        UDim2.new(
            1,
            0,
            0,
            20
        )

    usernameLabel.Position =
        UDim2.fromOffset(0, 23)

    usernameLabel.BackgroundTransparency =
        1

    usernameLabel.TextColor3 =
        Colors.Muted

    usernameLabel.TextStrokeColor3 =
        Color3.new(0, 0, 0)

    usernameLabel.TextStrokeTransparency =
        0

    usernameLabel.TextSize = 12

    usernameLabel.Font =
        Enum.Font.FredokaOne

    usernameLabel.TextXAlignment =
        Enum.TextXAlignment.Center

    usernameLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    usernameLabel.Text =
        "@" .. player.Name

    usernameLabel.Visible =
        Config.ShowName

    usernameLabel.Parent =
        billboard

    local healthLabel =
        Instance.new("TextLabel")

    healthLabel.Name =
        "Health"

    healthLabel.Size =
        UDim2.new(
            1,
            0,
            0,
            20
        )

    healthLabel.Position =
        UDim2.fromOffset(0, 45)

    healthLabel.BackgroundTransparency =
        1

    healthLabel.TextColor3 =
        Colors.Green

    healthLabel.TextStrokeColor3 =
        Color3.new(0, 0, 0)

    healthLabel.TextStrokeTransparency =
        0

    healthLabel.TextSize = 12

    healthLabel.Font =
        Enum.Font.FredokaOne

    healthLabel.TextXAlignment =
        Enum.TextXAlignment.Center

    healthLabel.TextYAlignment =
        Enum.TextYAlignment.Center

    healthLabel.Visible =
        Config.ShowHealth

    healthLabel.Parent =
        billboard

    local healthBack =
        Instance.new("Frame")

    healthBack.Name =
        "HealthBar"

    healthBack.AnchorPoint =
        Vector2.new(
            0,
            0.5
        )

    healthBack.Position =
        UDim2.new(
            0,
            -16,
            0.5,
            10
        )

    healthBack.Size =
        UDim2.fromOffset(
            8,
            60
        )

    healthBack.BackgroundColor3 =
        Color3.fromRGB(
            35,
            30,
            42
        )

    healthBack.BorderSizePixel = 0

    healthBack.Visible =
        Config.ShowHealth

    healthBack.Parent =
        billboard

    local healthCorner =
        Instance.new("UICorner")

    healthCorner.CornerRadius =
        UDim.new(0, 3)

    healthCorner.Parent =
        healthBack

    local healthFill =
        Instance.new("Frame")

    healthFill.Name =
        "Fill"

    healthFill.AnchorPoint =
        Vector2.new(
            0,
            1
        )

    healthFill.Position =
        UDim2.new(
            0,
            0,
            1,
            0
        )

    healthFill.Size =
        UDim2.new(
            1,
            0,
            1,
            0
        )

    healthFill.BackgroundColor3 =
        Colors.Green

    healthFill.BorderSizePixel = 0

    healthFill.Parent =
        healthBack

    local fillCorner =
        Instance.new("UICorner")

    fillCorner.CornerRadius =
        UDim.new(0, 3)

    fillCorner.Parent =
        healthFill

    return {
        Billboard = billboard,
        NameLabel = nameLabel,
        UsernameLabel = usernameLabel,
        HealthLabel = healthLabel,
        HealthBar = healthBack,
        HealthFill = healthFill,
    }
end

--========================================================
-- ESP REMOVE
--========================================================

local function RemoveESP(player)
    local data =
        ESPData[player]

    if not data then
        return
    end

    if data.HitBox
        and data.HitBox.Folder then

        pcall(function()
            data.HitBox.Folder:Destroy()
        end)
    end

    for _, object in pairs(data) do
        if typeof(object) == "Instance" then
            pcall(function()
                object:Destroy()
            end)
        end
    end

    ESPData[player] = nil
end

--========================================================
-- ESP CREATE
--========================================================

local function CreateESP(player)
    if player == LocalPlayer then
        return
    end

    local character =
        player.Character

    if not IsCharacterValid(character) then
        return
    end

    RemoveESP(player)

    local root =
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    local head =
        character:FindFirstChild("Head")

    local humanoid =
        character:FindFirstChildOfClass(
            "Humanoid"
        )

    if not root
        or not humanoid then
        return
    end

    local data = {}

    if Config.ESPPlayer then
        local highlight =
            Instance.new("Highlight")

        highlight.Name =
            "LEVEL1_ESP"

        highlight.Adornee =
            character

        highlight.FillColor =
            Colors.Purple

        highlight.FillTransparency =
            0.8

        highlight.OutlineColor =
            Colors.Purple

        highlight.OutlineTransparency =
            0

        highlight.DepthMode =
            Enum.HighlightDepthMode.AlwaysOnTop

        highlight.Enabled = false

        highlight.Parent =
            character

        data.Highlight =
            highlight
    end

    if Config.ESPHitBox then
        local hitBox =
            CreateHitBox(character)

        if hitBox then
            data.HitBox =
                hitBox
        end
    end

    if Config.ShowName
        or Config.ShowHealth then

        local info =
            CreateInfo(
                player,
                character,
                head,
                root
            )

        for key, value in pairs(info) do
            data[key] = value
        end
    end

    ESPData[player] =
        data
end

--========================================================
-- ESP HITBOX UPDATE
--========================================================

local function UpdateHitBox(
    data,
    character
)
    if not data
        or not data.Lines
        or not character
        or not character.Parent then

        return
    end

    local root =
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not root then
        return
    end

    local boxCFrame, boxSize =
        character:GetBoundingBox()

    local relativeCFrame =
        root.CFrame:ToObjectSpace(
            boxCFrame
        )

    local x =
        boxSize.X / 2

    local y =
        boxSize.Y / 2

    local z =
        boxSize.Z / 2

    local thickness =
        0.05

    local function SetLine(
        index,
        position,
        size
    )
        local line =
            data.Lines[index]

        if not line then
            return
        end

        line.Adornee =
            root

        line.CFrame =
            relativeCFrame
            * CFrame.new(
                position
            )

        line.Size =
            size

        line.Color3 =
            Colors.Purple

        line.Transparency =
            0

        line.AlwaysOnTop =
            true

        line.ZIndex =
            10

        line.Visible =
            Config.ESPHitBox
    end

    SetLine(
        1,
        Vector3.new(0, -y, -z),
        Vector3.new(
            boxSize.X,
            thickness,
            thickness
        )
    )

    SetLine(
        2,
        Vector3.new(0, -y, z),
        Vector3.new(
            boxSize.X,
            thickness,
            thickness
        )
    )

    SetLine(
        3,
        Vector3.new(-x, -y, 0),
        Vector3.new(
            thickness,
            thickness,
            boxSize.Z
        )
    )

    SetLine(
        4,
        Vector3.new(x, -y, 0),
        Vector3.new(
            thickness,
            thickness,
            boxSize.Z
        )
    )

    SetLine(
        5,
        Vector3.new(0, y, -z),
        Vector3.new(
            boxSize.X,
            thickness,
            thickness
        )
    )

    SetLine(
        6,
        Vector3.new(0, y, z),
        Vector3.new(
            boxSize.X,
            thickness,
            thickness
        )
    )

    SetLine(
        7,
        Vector3.new(-x, y, 0),
        Vector3.new(
            thickness,
            thickness,
            boxSize.Z
        )
    )

    SetLine(
        8,
        Vector3.new(x, y, 0),
        Vector3.new(
            thickness,
            thickness,
            boxSize.Z
        )
    )

    SetLine(
        9,
        Vector3.new(-x, 0, -z),
        Vector3.new(
            thickness,
            boxSize.Y,
            thickness
        )
    )

    SetLine(
        10,
        Vector3.new(x, 0, -z),
        Vector3.new(
            thickness,
            boxSize.Y,
            thickness
        )
    )

    SetLine(
        11,
        Vector3.new(-x, 0, z),
        Vector3.new(
            thickness,
            boxSize.Y,
            thickness
        )
    )

    SetLine(
        12,
        Vector3.new(x, 0, z),
        Vector3.new(
            thickness,
            boxSize.Y,
            thickness
        )
    )
end

--========================================================
-- ESP INFO UPDATE
--========================================================

local function UpdateInfo(
    data,
    character
)
    if not data
        or not character then
        return
    end

    if not data.Billboard then
        return
    end

    data.Billboard.Enabled =
        Config.ShowName
        or Config.ShowHealth

    data.Billboard.MaxDistance =
        Config.ESPDistance

    data.NameLabel.Visible =
        Config.ShowName

    data.UsernameLabel.Visible =
        Config.ShowName

    data.HealthLabel.Visible =
        Config.ShowHealth

    data.HealthBar.Visible =
        Config.ShowHealth

    local humanoid =
        character:FindFirstChildOfClass(
            "Humanoid"
        )

    if not humanoid then
        return
    end

    local health =
        math.floor(
            humanoid.Health + 0.5
        )

    local maxHealth =
        math.max(
            1,
            math.floor(
                humanoid.MaxHealth + 0.5
            )
        )

    local ratio =
        math.clamp(
            humanoid.Health
            / math.max(
                humanoid.MaxHealth,
                1
            ),
            0,
            1
        )

    data.HealthLabel.Text =
        "HP: "
        .. health
        .. " / "
        .. maxHealth

    local healthColor =
        GetHealthColor(ratio)

    data.HealthLabel.TextColor3 =
        healthColor

    data.HealthFill.Size =
        UDim2.new(
            1,
            0,
            ratio,
            0
        )

    data.HealthFill.BackgroundColor3 =
        healthColor

    local camera =
        workspace.CurrentCamera

    if camera then
        local boxCFrame, boxSize =
            character:GetBoundingBox()

        local topWorld =
            boxCFrame.Position
            + boxCFrame.UpVector
            * (boxSize.Y / 2)

        local bottomWorld =
            boxCFrame.Position
            - boxCFrame.UpVector
            * (boxSize.Y / 2)

        local top =
            camera:WorldToViewportPoint(
                topWorld
            )

        local bottom =
            camera:WorldToViewportPoint(
                bottomWorld
            )

        local pixelHeight =
            math.clamp(
                math.abs(
                    bottom.Y - top.Y
                ),
                35,
                350
            )

        data.HealthBar.Size =
            UDim2.fromOffset(
                8,
                pixelHeight
            )
    end
end

--========================================================
-- ESP UPDATE
--========================================================

local function UpdateESP()
    for _, player in ipairs(
        Players:GetPlayers()
    ) do
        if player ~= LocalPlayer then
            local character =
                player.Character

            if IsCharacterValid(character)
                and IsInRange(player) then

                if not ESPData[player] then
                    CreateESP(player)
                end

                local data =
                    ESPData[player]

                if not data then
                    continue
                end

                if Config.ESPPlayer then
                    if not data.Highlight then
                        CreateESP(player)

                        data =
                            ESPData[player]
                    end

                    if data
                        and data.Highlight then

                        data.Highlight.Enabled =
                            IsBehindObstacle(
                                character
                            )
                    end
                elseif data.Highlight then
                    data.Highlight.Enabled =
                        false
                end

                if Config.ESPHitBox then
                    if not data.HitBox then
                        CreateESP(player)

                        data =
                            ESPData[player]
                    end

                    if data
                        and data.HitBox then

                        UpdateHitBox(
                            data.HitBox,
                            character
                        )
                    end
                elseif data.HitBox then
                    for _, line in ipairs(
                        data.HitBox.Lines
                    ) do
                        line.Visible = false
                    end
                end

                if Config.ShowName
                    or Config.ShowHealth then

                    if not data.Billboard then
                        CreateESP(player)

                        data =
                            ESPData[player]
                    end

                    if data then
                        UpdateInfo(
                            data,
                            character
                        )
                    end
                elseif data.Billboard then
                    data.Billboard.Enabled =
                        false
                end

            else
                if ESPData[player] then
                    RemoveESP(player)
                end
            end
        end
    end
end

local function RefreshAllESP()
    for _, player in ipairs(
        Players:GetPlayers()
    ) do
        if player ~= LocalPlayer then
            RemoveESP(player)

            if IsInRange(player) then
                CreateESP(player)
            end
        end
    end
end

--========================================================
-- GUI
--========================================================

local ScreenGui =
    Instance.new("ScreenGui")

ScreenGui.Name =
    "LEVEL1_HUB"

ScreenGui.ResetOnSpawn =
    false

ScreenGui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

ScreenGui.Parent =
    LocalPlayer:WaitForChild(
        "PlayerGui"
    )

local Main =
    Instance.new("Frame")

Main.Name = "Main"

Main.Size =
    UDim2.fromOffset(
        720,
        470
    )

Main.Position =
    UDim2.new(
        0.5,
        -360,
        0.5,
        -235
    )

Main.BackgroundColor3 =
    Colors.Background

Main.BorderSizePixel = 0

Main.Parent =
    ScreenGui

local MainCorner =
    Instance.new("UICorner")

MainCorner.CornerRadius =
    UDim.new(0, 10)

MainCorner.Parent =
    Main

local MainStroke =
    Instance.new("UIStroke")

MainStroke.Color =
    Colors.PurpleDark

MainStroke.Transparency =
    0.25

MainStroke.Thickness = 1

MainStroke.Parent =
    Main

--========================================================
-- TOP BAR
--========================================================

local TopBar =
    Instance.new("Frame")

TopBar.Size =
    UDim2.new(
        1,
        0,
        0,
        52
    )

TopBar.BackgroundTransparency =
    1

TopBar.Parent =
    Main

local Title =
    Instance.new("TextLabel")

Title.Size =
    UDim2.new(
        1,
        -110,
        1,
        0
    )

Title.Position =
    UDim2.fromOffset(
        20,
        0
    )

Title.BackgroundTransparency =
    1

Title.Text =
    "LEVEL1 HUB"

Title.TextColor3 =
    Colors.Text

Title.TextSize = 20

Title.Font =
    Enum.Font.GothamBold

Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.Parent =
    TopBar

local Minimize =
    Instance.new("TextButton")

Minimize.Size =
    UDim2.fromOffset(
        36,
        32
    )

Minimize.Position =
    UDim2.new(
        1,
        -82,
        0,
        10
    )

Minimize.BackgroundColor3 =
    Colors.Sidebar

Minimize.Text = "—"

Minimize.TextColor3 =
    Colors.Text

Minimize.TextSize = 18

Minimize.Font =
    Enum.Font.GothamBold

Minimize.AutoButtonColor =
    false

Minimize.Parent =
    TopBar

local MinCorner =
    Instance.new("UICorner")

MinCorner.CornerRadius =
    UDim.new(0, 6)

MinCorner.Parent =
    Minimize

local Close =
    Instance.new("TextButton")

Close.Size =
    UDim2.fromOffset(
        36,
        32
    )

Close.Position =
    UDim2.new(
        1,
        -40,
        0,
        10
    )

Close.BackgroundColor3 =
    Colors.Sidebar

Close.Text = "×"

Close.TextColor3 =
    Colors.Text

Close.TextSize = 20

Close.Font =
    Enum.Font.GothamBold

Close.AutoButtonColor =
    false

Close.Parent =
    TopBar

local CloseCorner =
    Instance.new("UICorner")

CloseCorner.CornerRadius =
    UDim.new(0, 6)

CloseCorner.Parent =
    Close

--========================================================
-- SIDEBAR
--========================================================

local Sidebar =
    Instance.new("Frame")

Sidebar.Size =
    UDim2.new(
        0,
        160,
        1,
        -52
    )

Sidebar.Position =
    UDim2.fromOffset(
        0,
        52
    )

Sidebar.BackgroundColor3 =
    Colors.Sidebar

Sidebar.BorderSizePixel = 0

Sidebar.Parent =
    Main

local SidebarCorner =
    Instance.new("UICorner")

SidebarCorner.CornerRadius =
    UDim.new(0, 10)

SidebarCorner.Parent =
    Sidebar

local SidebarPadding =
    Instance.new("UIPadding")

SidebarPadding.PaddingTop =
    UDim.new(0, 12)

SidebarPadding.PaddingLeft =
    UDim.new(0, 10)

SidebarPadding.PaddingRight =
    UDim.new(0, 10)

SidebarPadding.Parent =
    Sidebar

local SidebarLayout =
    Instance.new("UIListLayout")

SidebarLayout.Padding =
    UDim.new(0, 7)

SidebarLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

SidebarLayout.Parent =
    Sidebar

--========================================================
-- CONTENT
--========================================================

local Content =
    Instance.new("Frame")

Content.Size =
    UDim2.new(
        1,
        -160,
        1,
        -52
    )

Content.Position =
    UDim2.fromOffset(
        160,
        52
    )

Content.BackgroundColor3 =
    Colors.Content

Content.BorderSizePixel = 0

Content.Parent =
    Main

local ContentPadding =
    Instance.new("UIPadding")

ContentPadding.PaddingTop =
    UDim.new(0, 16)

ContentPadding.PaddingLeft =
    UDim.new(0, 18)

ContentPadding.PaddingRight =
    UDim.new(0, 18)

ContentPadding.PaddingBottom =
    UDim.new(0, 16)

ContentPadding.Parent =
    Content

--========================================================
-- TAB SYSTEM
--========================================================

local TabButtons = {}
local TabFrames = {}

local function CreateTabButton(
    name,
    order
)
    local button =
        Instance.new("TextButton")

    button.Name =
        name

    button.Size =
        UDim2.new(
            1,
            0,
            0,
            40
        )

    button.BackgroundColor3 =
        Colors.Sidebar

    button.Text =
        name

    button.TextColor3 =
        Colors.Muted

    button.TextSize = 13

    button.Font =
        Enum.Font.GothamMedium

    button.TextXAlignment =
        Enum.TextXAlignment.Left

    button.AutoButtonColor =
        false

    button.LayoutOrder =
        order

    button.Parent =
        Sidebar

    local padding =
        Instance.new("UIPadding")

    padding.PaddingLeft =
        UDim.new(0, 14)

    padding.Parent =
        button

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 7)

    corner.Parent =
        button

    TabButtons[name] =
        button

    return button
end

local function CreateTabFrame(name)
    local frame =
        Instance.new("ScrollingFrame")

    frame.Name =
        name

    frame.Size =
        UDim2.fromScale(
            1,
            1
        )

    frame.BackgroundTransparency =
        1

    frame.BorderSizePixel = 0

    frame.ScrollBarThickness = 3

    frame.ScrollBarImageColor3 =
        Colors.Purple

    frame.CanvasSize =
        UDim2.new()

    frame.AutomaticCanvasSize =
        Enum.AutomaticSize.Y

    frame.Visible = false

    frame.Parent =
        Content

    local padding =
        Instance.new("UIPadding")

    padding.PaddingBottom =
        UDim.new(0, 15)

    padding.Parent =
        frame

    local layout =
        Instance.new("UIListLayout")

    layout.Padding =
        UDim.new(0, 9)

    layout.SortOrder =
        Enum.SortOrder.LayoutOrder

    layout.Parent =
        frame

    TabFrames[name] =
        frame

    return frame
end

local MainTabButton =
    CreateTabButton(
        "Main",
        1
    )

local ESPTabButton =
    CreateTabButton(
        "ESP",
        2
    )

local PlayerTabButton =
    CreateTabButton(
        "Player",
        3
    )

local SettingsTabButton =
    CreateTabButton(
        "Settings",
        4
    )

local MainTab =
    CreateTabFrame(
        "Main"
    )

local ESPTab =
    CreateTabFrame(
        "ESP"
    )

local PlayerTab =
    CreateTabFrame(
        "Player"
    )

local SettingsTab =
    CreateTabFrame(
        "Settings"
    )

--========================================================
-- TAB SWITCH
--========================================================

local function SelectTab(name)
    CurrentTab = name

    for tabName, button in pairs(
        TabButtons
    ) do
        if tabName == name then
            button.BackgroundColor3 =
                Colors.PurpleDark

            button.TextColor3 =
                Colors.Text
        else
            button.BackgroundColor3 =
                Colors.Sidebar

            button.TextColor3 =
                Colors.Muted
        end
    end

    for tabName, frame in pairs(
        TabFrames
    ) do
        frame.Visible =
            tabName == name
    end
end

MainTabButton.MouseButton1Click:Connect(
    function()
        SelectTab("Main")
    end
)

ESPTabButton.MouseButton1Click:Connect(
    function()
        SelectTab("ESP")
    end
)

PlayerTabButton.MouseButton1Click:Connect(
    function()
        SelectTab("Player")
    end
)

SettingsTabButton.MouseButton1Click:Connect(
    function()
        SelectTab("Settings")
    end
)

--========================================================
-- UI HELPERS
--========================================================

local function CreateSectionTitle(
    parent,
    text
)
    local label =
        Instance.new("TextLabel")

    label.Size =
        UDim2.new(
            1,
            0,
            0,
            28
        )

    label.BackgroundTransparency =
        1

    label.Text =
        text

    label.TextColor3 =
        Colors.Text

    label.TextSize = 14

    label.Font =
        Enum.Font.GothamBold

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.Parent =
        parent

    return label
end

--========================================================
-- TOGGLE
--========================================================

local function CreateToggle(
    parent,
    text,
    default,
    callback
)
    local holder =
        Instance.new("Frame")

    holder.Size =
        UDim2.new(
            1,
            0,
            0,
            42
        )

    holder.BackgroundColor3 =
        Colors.Sidebar

    holder.BorderSizePixel = 0

    holder.Parent =
        parent

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 7)

    corner.Parent =
        holder

    local label =
        Instance.new("TextLabel")

    label.Size =
        UDim2.new(
            1,
            -65,
            1,
            0
        )

    label.Position =
        UDim2.fromOffset(
            13,
            0
        )

    label.BackgroundTransparency =
        1

    label.Text =
        text

    label.TextColor3 =
        Colors.Text

    label.TextSize = 12

    label.Font =
        Enum.Font.GothamMedium

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.Parent =
        holder

    local button =
        Instance.new("TextButton")

    button.Size =
        UDim2.fromOffset(
            42,
            22
        )

    button.Position =
        UDim2.new(
            1,
            -53,
            0.5,
            -11
        )

    button.BackgroundColor3 =
        Colors.PurpleDark

    button.Text = ""

    button.AutoButtonColor =
        false

    button.Parent =
        holder

    local buttonCorner =
        Instance.new("UICorner")

    buttonCorner.CornerRadius =
        UDim.new(1, 0)

    buttonCorner.Parent =
        button

    local knob =
        Instance.new("Frame")

    knob.Size =
        UDim2.fromOffset(
            16,
            16
        )

    knob.Position =
        UDim2.fromOffset(
            3,
            3
        )

    knob.BackgroundColor3 =
        Colors.Muted

    knob.BorderSizePixel = 0

    knob.Parent =
        button

    local knobCorner =
        Instance.new("UICorner")

    knobCorner.CornerRadius =
        UDim.new(1, 0)

    knobCorner.Parent =
        knob

    local state =
        default

    local function UpdateUI()
        if state then
            button.BackgroundColor3 =
                Colors.Purple

            knob.BackgroundColor3 =
                Colors.Text

            knob.Position =
                UDim2.new(
                    1,
                    -19,
                    0,
                    3
                )
        else
            button.BackgroundColor3 =
                Colors.PurpleDark

            knob.BackgroundColor3 =
                Colors.Muted

            knob.Position =
                UDim2.fromOffset(
                    3,
                    3
                )
        end
    end

    local function Update()
        UpdateUI()
        callback(state)
    end

    button.MouseButton1Click:Connect(
        function()
            state = not state
            Update()
        end
    )

    ToggleSetters[text] =
        function(value)
            state = value == true
            UpdateUI()
        end

    UpdateUI()

    return holder
end

--========================================================
-- TRACKBAR
--========================================================

local function CreateSlider(
    parent,
    text,
    min,
    max,
    default,
    callback
)
    local holder =
        Instance.new("Frame")

    holder.Size =
        UDim2.new(
            1,
            0,
            0,
            68
        )

    holder.BackgroundColor3 =
        Colors.Sidebar

    holder.BorderSizePixel = 0

    holder.Parent =
        parent

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 7)

    corner.Parent =
        holder

    local label =
        Instance.new("TextLabel")

    label.Size =
        UDim2.new(
            1,
            -80,
            0,
            28
        )

    label.Position =
        UDim2.fromOffset(
            13,
            3
        )

    label.BackgroundTransparency =
        1

    label.Text =
        text

    label.TextColor3 =
        Colors.Text

    label.TextSize = 12

    label.Font =
        Enum.Font.GothamMedium

    label.TextXAlignment =
        Enum.TextXAlignment.Left

    label.Parent =
        holder

    local valueLabel =
        Instance.new("TextLabel")

    valueLabel.Size =
        UDim2.fromOffset(
            60,
            28
        )

    valueLabel.Position =
        UDim2.new(
            1,
            -70,
            0,
            3
        )

    valueLabel.BackgroundTransparency =
        1

    valueLabel.TextColor3 =
        Colors.Muted

    valueLabel.TextSize = 11

    valueLabel.Font =
        Enum.Font.GothamMedium

    valueLabel.TextXAlignment =
        Enum.TextXAlignment.Right

    valueLabel.Parent =
        holder

    local bar =
        Instance.new("Frame")

    bar.Name =
        "Trackbar"

    bar.Size =
        UDim2.new(
            1,
            -30,
            0,
            6
        )

    bar.Position =
        UDim2.new(
            0,
            15,
            0,
            46
        )

    bar.BackgroundColor3 =
        Colors.PurpleDark

    bar.BorderSizePixel = 0

    bar.Active = true

    bar.Parent =
        holder

    local barCorner =
        Instance.new("UICorner")

    barCorner.CornerRadius =
        UDim.new(1, 0)

    barCorner.Parent =
        bar

    local fill =
        Instance.new("Frame")

    fill.Name =
        "Fill"

    fill.Size =
        UDim2.new(
            0,
            0,
            1,
            0
        )

    fill.BackgroundColor3 =
        Colors.Purple

    fill.BorderSizePixel = 0

    fill.Active = false

    fill.Parent =
        bar

    local fillCorner =
        Instance.new("UICorner")

    fillCorner.CornerRadius =
        UDim.new(1, 0)

    fillCorner.Parent =
        fill

    local knob =
        Instance.new("TextButton")

    knob.Name =
        "Knob"

    knob.Size =
        UDim2.fromOffset(
            16,
            16
        )

    knob.AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        )

    knob.Position =
        UDim2.new(
            0,
            0,
            0.5,
            0
        )

    knob.BackgroundColor3 =
        Colors.Text

    knob.BorderSizePixel = 0

    knob.Text = ""

    knob.AutoButtonColor = false

    knob.ZIndex = 5

    knob.Parent =
        bar

    local knobCorner =
        Instance.new("UICorner")

    knobCorner.CornerRadius =
        UDim.new(1, 0)

    knobCorner.Parent =
        knob

    local value =
        math.clamp(
            default,
            min,
            max
        )

    local dragging = false

    local function UpdateUI()
        local range =
            max - min

        local ratio = 0

        if range > 0 then
            ratio =
                (value - min)
                / range
        end

        fill.Size =
            UDim2.new(
                ratio,
                0,
                1,
                0
            )

        knob.Position =
            UDim2.new(
                ratio,
                0,
                0.5,
                0
            )

        valueLabel.Text =
            tostring(value)
    end

    local function SetValue(
        newValue,
        fireCallback
    )
        if typeof(newValue) ~= "number"
            or newValue ~= newValue then
            newValue = min
        end

        value =
            math.clamp(
                math.round(newValue),
                min,
                max
            )

        UpdateUI()

        if fireCallback ~= false then
            callback(value)
        end
    end

    local function UpdateFromX(x)
        local left =
            bar.AbsolutePosition.X

        local width =
            bar.AbsoluteSize.X

        if width <= 0 then
            return
        end

        local ratio =
            math.clamp(
                (x - left) / width,
                0,
                1
            )

        local newValue =
            min
            + (
                max - min
            ) * ratio

        SetValue(newValue)
    end

    local function BeginDrag(input)
        dragging = true

        UpdateFromX(
            input.Position.X
        )
    end

    bar.InputBegan:Connect(
        function(input)
            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or input.UserInputType ==
                    Enum.UserInputType.Touch then

                BeginDrag(input)
            end
        end
    )

    knob.InputBegan:Connect(
        function(input)
            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or input.UserInputType ==
                    Enum.UserInputType.Touch then

                BeginDrag(input)
            end
        end
    )

    UserInputService.InputChanged:Connect(
        function(input)
            if not dragging then
                return
            end

            if input.UserInputType ==
                Enum.UserInputType.MouseMovement
                or input.UserInputType ==
                    Enum.UserInputType.Touch then

                UpdateFromX(
                    input.Position.X
                )
            end
        end
    )

    UserInputService.InputEnded:Connect(
        function(input)
            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or input.UserInputType ==
                    Enum.UserInputType.Touch then

                dragging = false
            end
        end
    )

    SliderSetters[text] =
        function(newValue)
            SetValue(newValue, false)
        end

    SetValue(value, false)

    return holder
end

--========================================================
-- MAIN TAB
--========================================================

CreateSectionTitle(
    MainTab,
    "LEVEL1 HUB"
)

local Welcome =
    Instance.new("TextLabel")

Welcome.Size =
    UDim2.new(
        1,
        0,
        0,
        100
    )

Welcome.BackgroundColor3 =
    Colors.Sidebar

Welcome.BorderSizePixel = 0

Welcome.Text =
    "LEVEL1 HUB\n\n"
    .. "Player Utility • ESP • Movement"

Welcome.TextColor3 =
    Colors.Text

Welcome.TextSize = 15

Welcome.Font =
    Enum.Font.GothamMedium

Welcome.TextXAlignment =
    Enum.TextXAlignment.Center

Welcome.TextYAlignment =
    Enum.TextYAlignment.Center

Welcome.Parent =
    MainTab

local WelcomeCorner =
    Instance.new("UICorner")

WelcomeCorner.CornerRadius =
    UDim.new(0, 8)

WelcomeCorner.Parent =
    Welcome

CreateSectionTitle(
    MainTab,
    "Current Status"
)

local Status =
    Instance.new("TextLabel")

Status.Size =
    UDim2.new(
        1,
        0,
        0,
        150
    )

Status.BackgroundColor3 =
    Colors.Sidebar

Status.BorderSizePixel = 0

Status.TextColor3 =
    Colors.Muted

Status.TextSize = 12

Status.Font =
    Enum.Font.GothamMedium

Status.TextXAlignment =
    Enum.TextXAlignment.Left

Status.TextYAlignment =
    Enum.TextYAlignment.Top

Status.TextWrapped = true

Status.Parent =
    MainTab

local StatusPadding =
    Instance.new("UIPadding")

StatusPadding.PaddingTop =
    UDim.new(0, 14)

StatusPadding.PaddingLeft =
    UDim.new(0, 14)

StatusPadding.PaddingRight =
    UDim.new(0, 14)

StatusPadding.Parent =
    Status

local StatusCorner =
    Instance.new("UICorner")

StatusCorner.CornerRadius =
    UDim.new(0, 8)

StatusCorner.Parent =
    Status

local function UpdateStatus()
    if not Status
        or not Status.Parent then
        return
    end

    Status.Text =
        "Walk Speed: "
        .. tostring(
            Config.WalkSpeedEnabled
        )
        .. "\n\n"

        .. "Jump Power: "
        .. tostring(
            Config.JumpPowerEnabled
        )
        .. "\n\n"

        .. "No Clip: "
        .. tostring(
            Config.NoClip
        )
        .. "\n\n"

        .. "Fly: "
        .. tostring(
            Config.Fly
        )
        .. "\n\n"

        .. "ESP Player: "
        .. tostring(
            Config.ESPPlayer
        )
        .. "\n\n"

        .. "ESP Hit Box: "
        .. tostring(
            Config.ESPHitBox
        )
end

--========================================================
-- PLAYER TAB
--========================================================

CreateSectionTitle(
    PlayerTab,
    "Movement"
)

CreateToggle(
    PlayerTab,
    "Walk Speed",
    Config.WalkSpeedEnabled,
    function(value)
        Config.WalkSpeedEnabled =
            value

        ApplyWalkSpeed()
        UpdateStatus()
    end
)

CreateSlider(
    PlayerTab,
    "Walk Speed Value",
    16,
    1000,
    Config.WalkSpeed,
    function(value)
        Config.WalkSpeed =
            value

        ApplyWalkSpeed()
        UpdateStatus()
    end
)

CreateToggle(
    PlayerTab,
    "Swim Speed",
    Config.SwimSpeedEnabled,
    function(value)
        Config.SwimSpeedEnabled = value

        ApplySwimSpeed()
        UpdateStatus()
    end
)

CreateSlider(
    PlayerTab,
    "Swim Speed Value",
    16,
    1000,
    Config.SwimSpeed,
    function(value)
        Config.SwimSpeed = value

        ApplySwimSpeed()
        UpdateStatus()
    end
)

RunService.Heartbeat:Connect(function()
    if not Humanoid then
        return
    end

    if not Config.SwimSpeedEnabled then
        return
    end

    if Humanoid:GetState() ==
        Enum.HumanoidStateType.Swimming then

        local speed =
            math.clamp(
                Config.SwimSpeed,
                16,
                1000
            )

        if Humanoid.WalkSpeed ~= speed then
            Humanoid.WalkSpeed = speed
        end
    end
end)

CreateToggle(
    PlayerTab,
    "Jump Power",
    Config.JumpPowerEnabled,
    function(value)
        Config.JumpPowerEnabled =
            value

        ApplyJumpPower()
        UpdateStatus()
    end
)

CreateSlider(
    PlayerTab,
    "Jump Power Value",
    50,
    1000,
    Config.JumpPower,
    function(value)
        Config.JumpPower =
            value

        ApplyJumpPower()
        UpdateStatus()
    end
)

CreateToggle(
    PlayerTab,
    "No Clip",
    Config.NoClip,
    function(value)
        Config.NoClip =
            value

        if value then
            StartNoClip()
        else
            StopNoClip()
        end

        UpdateStatus()
    end
)

CreateToggle(
    PlayerTab,
    "Fly",
    Config.Fly,
    function(value)
        Config.Fly =
            value

        if value then
            StartFly()
        else
            StopFly()
        end

        UpdateStatus()
    end
)

CreateSlider(
    PlayerTab,
    "Fly Speed",
    1,
    1000,
    Config.FlySpeed,
    function(value)
        Config.FlySpeed =
            value

        UpdateStatus()
    end
)

CreateSectionTitle(
    PlayerTab,
    "Physics"
)

CreateToggle(
    PlayerTab,
    "Gravity",
    Config.GravityEnabled,
    function(value)
        Config.GravityEnabled =
            value

        ApplyGravity()
        UpdateStatus()
    end
)

CreateSlider(
    PlayerTab,
    "Gravity Value",
    0,
    1000,
    Config.Gravity,
    function(value)
        Config.Gravity =
            value

        ApplyGravity()
        UpdateStatus()
    end
)

CreateToggle(
    PlayerTab,
    "Anti Knockback",
    Config.AntiKnockback,
    function(value)
        Config.AntiKnockback =
            value

        if value then
            StartAntiKnockback()
        else
            StopAntiKnockback()
        end

        UpdateStatus()
    end
)

CreateToggle(
    PlayerTab,
    "Anti Ragdoll",
    Config.AntiRagdoll,
    function(value)
        Config.AntiRagdoll =
            value

        if value then
            StartAntiRagdoll()
        else
            StopAntiRagdoll()
        end

        UpdateStatus()
    end
)

CreateSectionTitle(
    PlayerTab,
    "Character"
)

CreateSlider(
    PlayerTab,
    "Scale Up",
    -1,
    10,
    Config.ScaleUp,
    function(value)
        Config.ScaleUp =
            value

        ApplyScale()
    end
)

--========================================================
-- ESP TAB
--========================================================

CreateSectionTitle(
    ESPTab,
    "ESP Player"
)

CreateToggle(
    ESPTab,
    "ESP Player",
    Config.ESPPlayer,
    function(value)
        Config.ESPPlayer =
            value

        RefreshAllESP()
        UpdateStatus()
    end
)

CreateToggle(
    ESPTab,
    "ESP Player Hit Box",
    Config.ESPHitBox,
    function(value)
        Config.ESPHitBox =
            value

        RefreshAllESP()
        UpdateStatus()
    end
)

CreateSectionTitle(
    ESPTab,
    "Player Information"
)

CreateToggle(
    ESPTab,
    "Show Name",
    Config.ShowName,
    function(value)
        Config.ShowName =
            value

        RefreshAllESP()
    end
)

CreateToggle(
    ESPTab,
    "Show Health",
    Config.ShowHealth,
    function(value)
        Config.ShowHealth =
            value

        RefreshAllESP()
    end
)

CreateSlider(
    ESPTab,
    "ESP Distance",
    25,
    1000,
    Config.ESPDistance,
    function(value)
        Config.ESPDistance =
            value

        for _, data in pairs(
            ESPData
        ) do
            if data.Billboard then
                data.Billboard.MaxDistance =
                    value
            end
        end
    end
)

--========================================================
-- SETTINGS TAB
--========================================================

CreateSectionTitle(
    SettingsTab,
    "Interface"
)

local SettingsInfo =
    Instance.new("TextLabel")

SettingsInfo.Size =
    UDim2.new(
        1,
        0,
        0,
        110
    )

SettingsInfo.BackgroundColor3 =
    Colors.Sidebar

SettingsInfo.BorderSizePixel = 0

SettingsInfo.Text =
    "LEVEL1 HUB\n\n"
    .. "Dark Purple Interface\n"
    .. "ESP / Player Utility"

SettingsInfo.TextColor3 =
    Colors.Muted

SettingsInfo.TextSize = 12

SettingsInfo.Font =
    Enum.Font.GothamMedium

SettingsInfo.TextXAlignment =
    Enum.TextXAlignment.Center

SettingsInfo.TextYAlignment =
    Enum.TextYAlignment.Center

SettingsInfo.Parent =
    SettingsTab

local SettingsCorner =
    Instance.new("UICorner")

SettingsCorner.CornerRadius =
    UDim.new(0, 8)

SettingsCorner.Parent =
    SettingsInfo

--========================================================
-- DRAG
--========================================================

local dragging = false
local dragStart
local startPosition

TopBar.InputBegan:Connect(
    function(input)
        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
                Enum.UserInputType.Touch then

            dragging = true
            dragStart =
                input.Position

            startPosition =
                Main.Position
        end
    end
)

UserInputService.InputChanged:Connect(
    function(input)
        if not dragging then
            return
        end

        if input.UserInputType ==
            Enum.UserInputType.MouseMovement
            or input.UserInputType ==
                Enum.UserInputType.Touch then

            local delta =
                input.Position
                - dragStart

            Main.Position =
                UDim2.new(
                    startPosition.X.Scale,
                    startPosition.X.Offset
                        + delta.X,

                    startPosition.Y.Scale,
                    startPosition.Y.Offset
                        + delta.Y
                )
        end
    end
)

UserInputService.InputEnded:Connect(
    function(input)
        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
                Enum.UserInputType.Touch then

            dragging = false
        end
    end
)

--========================================================
-- MINIMIZE
--========================================================

local minimized = false

Minimize.MouseButton1Click:Connect(
    function()
        minimized =
            not minimized

        Sidebar.Visible =
            not minimized

        Content.Visible =
            not minimized

        if minimized then
            Main.Size =
                UDim2.fromOffset(
                    720,
                    52
                )
        else
            Main.Size =
                UDim2.fromOffset(
                    720,
                    470
                )
        end
    end
)

--========================================================
-- CLOSE
--========================================================

local function DestroyAllESP()
    for player in pairs(
        ESPData
    ) do
        RemoveESP(player)
    end
end

Close.MouseButton1Click:Connect(
    function()
        Config.WalkSpeedEnabled = false
        Config.JumpPowerEnabled = false
        Config.NoClip = false
        Config.Fly = false
        Config.GravityEnabled = false
        Config.AntiKnockback = false
        Config.AntiRagdoll = false
        Config.WalkSpeed = DefaultWalkSpeed
        Config.JumpPower = DefaultJumpPower
        Config.FlySpeed = DefaultFlySpeed
        Config.Gravity = DefaultGravity
        Config.ScaleUp = 0

        pcall(StopNoClip)
        pcall(StopFly)
        pcall(StopAntiKnockback)
        pcall(StopAntiRagdoll)

        pcall(function()
            workspace.Gravity =
                DefaultGravity
        end)

        if Humanoid then
            pcall(function()
                Humanoid.WalkSpeed =
                    DefaultWalkSpeed

                Humanoid.UseJumpPower =
                    true

                Humanoid.JumpPower =
                    DefaultJumpPower

                Humanoid.AutoRotate = true
                Humanoid.PlatformStand = false
            end)
        end

        pcall(DestroyAllESP)

        pcall(function()
            ScreenGui:Destroy()
        end)
    end
)

--========================================================
-- RESET ON DEATH
--========================================================

local function SafeCall(callback)
    if typeof(callback) ~= "function" then
        return
    end

    pcall(callback)
end

local function SafeToggleSet(name, value)
    local setter =
        ToggleSetters[name]

    if typeof(setter) ~= "function" then
        return
    end

    pcall(function()
        setter(value)
    end)
end

local function SafeSliderSet(name, value)
    local setter =
        SliderSetters[name]

    if typeof(setter) ~= "function" then
        return
    end

    pcall(function()
        setter(value)
    end)
end

local function ResetPlayerOnDeath()
    Config.WalkSpeedEnabled = false
    Config.JumpPowerEnabled = false
    Config.NoClip = false
    Config.Fly = false
    Config.GravityEnabled = false
    Config.AntiKnockback = false
    Config.AntiRagdoll = false

    Config.WalkSpeed = DefaultWalkSpeed
    Config.JumpPower = DefaultJumpPower
    Config.FlySpeed = DefaultFlySpeed
    Config.Gravity = DefaultGravity
    Config.ScaleUp = 0

    -- สำคัญ:
    -- ทุก function ที่อาจเกิดปัญหาตอนตัวละครกำลังถูกลบ
    -- จะถูกเรียกผ่าน SafeCall

    SafeCall(StopNoClip)
    SafeCall(StopFly)
    SafeCall(StopAntiKnockback)
    SafeCall(StopAntiRagdoll)

    SafeCall(function()
        workspace.Gravity =
            DefaultGravity
    end)

    if Humanoid then
        SafeCall(function()
            Humanoid.WalkSpeed =
                DefaultWalkSpeed

            Humanoid.UseJumpPower =
                true

            Humanoid.JumpPower =
                DefaultJumpPower

            Humanoid.AutoRotate =
                true

            Humanoid.PlatformStand =
                false
        end)
    end

    if Character
        and Character.Parent
        and typeof(Character.ScaleTo) == "function" then

        SafeCall(function()
            Character:ScaleTo(
                CharacterBaseScale
            )
        end)
    end

    SafeToggleSet(
        "Walk Speed",
        false
    )

    SafeToggleSet(
        "Jump Power",
        false
    )

    SafeToggleSet(
        "No Clip",
        false
    )

    SafeToggleSet(
        "Fly",
        false
    )

    SafeToggleSet(
        "Gravity",
        false
    )

    SafeToggleSet(
        "Anti Knockback",
        false
    )

    SafeToggleSet(
        "Anti Ragdoll",
        false
    )

    SafeSliderSet(
        "Walk Speed Value",
        DefaultWalkSpeed
    )

    SafeSliderSet(
        "Jump Power Value",
        DefaultJumpPower
    )

    SafeSliderSet(
        "Fly Speed",
        DefaultFlySpeed
    )

    SafeSliderSet(
        "Gravity Value",
        DefaultGravity
    )

    SafeSliderSet(
        "Scale Up",
        0
    )

    SafeCall(UpdateStatus)
end

local function ConnectDeathReset(character)
    if not character then
        return
    end

    local humanoid =
        character:FindFirstChildOfClass(
            "Humanoid"
        )

    if not humanoid then
        return
    end

    if typeof(humanoid.Died) ~= "RBXScriptSignal" then
        return
    end

    humanoid.Died:Connect(
        function()
            SafeCall(ResetPlayerOnDeath)
        end
    )
end

--========================================================
-- PLAYER EVENTS
--========================================================

LocalPlayer.CharacterAdded:Connect(
    function(character)
        SafeCall(DestroyAllESP)

        SetCharacter(character)

        ConnectDeathReset(character)

        task.wait(0.5)

        SafeCall(RefreshAllESP)
    end
)

if LocalPlayer.Character then
    SetCharacter(
        LocalPlayer.Character
    )

    ConnectDeathReset(
        LocalPlayer.Character
    )
end

--========================================================
-- TARGET PLAYER EVENTS
--========================================================

local function SetupPlayer(player)
    if player == LocalPlayer then
        return
    end

    player.CharacterAdded:Connect(
        function()
            RemoveESP(player)

            task.wait(0.2)

            if IsInRange(player) then
                CreateESP(player)
            end
        end
    )

    player.CharacterRemoving:Connect(
        function()
            RemoveESP(player)
        end
    )
end

for _, player in ipairs(
    Players:GetPlayers()
) do
    SetupPlayer(player)
end

Players.PlayerAdded:Connect(
    function(player)
        SetupPlayer(player)
    end
)

Players.PlayerRemoving:Connect(
    function(player)
        RemoveESP(player)
    end
)

--========================================================
-- RENDER LOOP
--========================================================

RunService.RenderStepped:Connect(
    function()
        if not ScreenGui.Parent then
            return
        end

        SafeCall(UpdateESP)
    end
)

--========================================================
-- INITIALIZE
--========================================================

SafeCall(UpdateStatus)

SelectTab("Main")

SafeCall(ApplyWalkSpeed)
SafeCall(ApplyJumpPower)
SafeCall(ApplyGravity)
