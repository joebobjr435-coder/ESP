local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Universal ESP + Cheats",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Key Protected",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "CleanESPConfig",
        FileName = "Settings"
    },
    KeySystem = true,
    KeySettings = {
        Title = "Universal Nigga ESP",
        Subtitle = "Enter Key",
        Note = "(DM drdouky for updates)",
        FileName = "Universal ESP",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"doukynigga123"},
    }
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==================== ESP (unchanged) ====================
local ESPSettings = {
    Enabled = false,
    TeamCheck = true,
    MaxDistance = 800,
    Boxes = true,
    Names = true,
    Health = true,
    Tracers = true,
    TracerOrigin = "Bottom",
    BoxColor = Color3.fromRGB(220, 50, 50),
    TracerColor = Color3.fromRGB(50, 220, 50),
    TextColor = Color3.fromRGB(255, 255, 255),
    Thickness = 1.5,
    Transparency = 1,
    TextSize = 14,
}

local ESPObjects = {}

local function CreateESP(plr)
    if plr == LocalPlayer then return end

    local Box = Drawing.new("Square")
    Box.Thickness = ESPSettings.Thickness
    Box.Filled = false
    Box.Transparency = ESPSettings.Transparency

    local Tracer = Drawing.new("Line")
    Tracer.Thickness = ESPSettings.Thickness
    Tracer.Transparency = ESPSettings.Transparency

    local NameTag = Drawing.new("Text")
    NameTag.Size = ESPSettings.TextSize
    NameTag.Center = true
    NameTag.Outline = true
    NameTag.Transparency = ESPSettings.Transparency

    local HealthOutline = Drawing.new("Line")
    HealthOutline.Thickness = 5
    HealthOutline.Color = Color3.new(0, 0, 0)
    HealthOutline.Transparency = ESPSettings.Transparency

    local HealthBar = Drawing.new("Line")
    HealthBar.Thickness = 3
    HealthBar.Transparency = ESPSettings.Transparency

    ESPObjects[plr] = {
        Box = Box, Tracer = Tracer, Name = NameTag,
        HealthOutline = HealthOutline, Health = HealthBar
    }

    plr.AncestryChanged:Connect(function()
        if not plr.Parent then
            for _, obj in pairs(ESPObjects[plr] or {}) do pcall(function() obj:Remove() end) end
            ESPObjects[plr] = nil
        end
    end)
end

local function UpdateESP()
    for plr, drawings in pairs(ESPObjects) do
        if not ESPSettings.Enabled or not plr or not plr.Character then
            for _, obj in pairs(drawings) do obj.Visible = false end
            continue
        end

        local char = plr.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local humanoid = char:FindFirstChildOfClass("Humanoid")

        if not root or not head or not humanoid or humanoid.Health <= 0 then
            for _, obj in pairs(drawings) do obj.Visible = false end
            continue
        end

        if ESPSettings.TeamCheck and plr.Team == LocalPlayer.Team then
            for _, obj in pairs(drawings) do obj.Visible = false end
            continue
        end

        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            for _, obj in pairs(drawings) do obj.Visible = false end
            continue
        end

        local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
            and (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or 0
        
        if distance > ESPSettings.MaxDistance then
            for _, obj in pairs(drawings) do obj.Visible = false end
            continue
        end

        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))
        local legPos  = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0))
        local boxHeight = math.abs(headPos.Y - legPos.Y)
        local boxWidth  = boxHeight * 0.55
        local boxPos = Vector2.new(rootPos.X - boxWidth/2, rootPos.Y - boxHeight/2)

        drawings.Box.Size = Vector2.new(boxWidth, boxHeight)
        drawings.Box.Position = boxPos
        drawings.Box.Color = ESPSettings.BoxColor
        drawings.Box.Visible = ESPSettings.Boxes
        drawings.Box.Thickness = ESPSettings.Thickness

        drawings.Name.Text = string.format("%s [%.0f]", plr.Name, distance)
        drawings.Name.Position = Vector2.new(rootPos.X, boxPos.Y - ESPSettings.TextSize - 4)
        drawings.Name.Color = ESPSettings.TextColor
        drawings.Name.Size = ESPSettings.TextSize
        drawings.Name.Visible = ESPSettings.Names

        local hp = humanoid.Health / humanoid.MaxHealth
        local bottomY = boxPos.Y + boxHeight
        local topY    = bottomY - (boxHeight * hp)

        drawings.HealthOutline.From = Vector2.new(boxPos.X - 7, bottomY)
        drawings.HealthOutline.To   = Vector2.new(boxPos.X - 7, boxPos.Y)
        drawings.HealthOutline.Visible = ESPSettings.Health

        drawings.Health.From = Vector2.new(boxPos.X - 6, bottomY)
        drawings.Health.To   = Vector2.new(boxPos.X - 6, topY)
        drawings.Health.Color = Color3.fromRGB(255 * (1 - hp), 255 * hp, 60)
        drawings.Health.Visible = ESPSettings.Health

        local tracerFrom
        if ESPSettings.TracerOrigin == "Bottom" then
            tracerFrom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        elseif ESPSettings.TracerOrigin == "Top" then
            tracerFrom = Vector2.new(Camera.ViewportSize.X / 2, 0)
        else
            local success, mousePos = pcall(function() return UserInputService:GetMouseLocation() end)
            tracerFrom = success and mousePos or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        end

        drawings.Tracer.From = tracerFrom
        drawings.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
        drawings.Tracer.Color = ESPSettings.TracerColor
        drawings.Tracer.Thickness = ESPSettings.Thickness
        drawings.Tracer.Visible = ESPSettings.Tracers
    end
end

-- Initialize ESP
for _, plr in ipairs(Players:GetPlayers()) do
    task.spawn(CreateESP, plr)
    plr.CharacterAdded:Connect(function() task.wait(0.3) CreateESP(plr) end)
end
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function() task.wait(0.3) CreateESP(plr) end)
end)
RunService.RenderStepped:Connect(UpdateESP)

-- ==================== CHEATS ====================

-- Aimbot (unchanged from previous version)
local AimbotSettings = {
    Enabled = false,
    TeamCheck = true,
    WallCheck = false,
    FOV = 90,
    Smoothness = 0.2,
    LockPart = "Head",
    Prediction = 0,
}

local aimbotConnection
local function StartAimbot()
    if aimbotConnection then return end
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not AimbotSettings.Enabled then return end
        local closest = nil
        local shortest = AimbotSettings.FOV

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer or not plr.Character then continue end
            local char = plr.Character
            local part = char:FindFirstChild(AimbotSettings.LockPart) or char:FindFirstChild("Head")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not part or not hum or hum.Health <= 0 then continue end

            if AimbotSettings.TeamCheck and plr.Team == LocalPlayer.Team then continue end

            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end

            local dist = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
            if dist < shortest then
                if AimbotSettings.WallCheck then
                    local params = RaycastParams.new()
                    params.FilterDescendantsInstances = {LocalPlayer.Character}
                    params.FilterType = Enum.RaycastFilterType.Blacklist
                    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * (part.Position - Camera.CFrame.Position).Magnitude, params)
                    if result and not result.Instance:IsDescendantOf(char) then continue end
                end
                shortest = dist
                closest = {Part = part, Char = char}
            end
        end

        if closest and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local part = closest.Part
            local root = closest.Char:FindFirstChild("HumanoidRootPart")
            local targetPos = part.Position
            
            if root and root.Velocity then
                targetPos = targetPos + (root.Velocity * AimbotSettings.Prediction)
            end

            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos):Lerp(Camera.CFrame, AimbotSettings.Smoothness)
        end
    end)
end

local function StopAimbot()
    if aimbotConnection then aimbotConnection:Disconnect() aimbotConnection = nil end
end

-- Speed, Fly, Noclip, Infinite Jump (unchanged from previous)
local SpeedSettings = {Enabled = false, Value = 50}
local originalWalkSpeed = 16

local function UpdateSpeed()
    if not LocalPlayer.Character then return end
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = SpeedSettings.Enabled and SpeedSettings.Value or originalWalkSpeed
    end
end

LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5) UpdateSpeed() end)

local Flying = false
local FlySpeed = 50
local flyConnection

local function StartFly()
    if Flying then return end
    Flying = true
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    hum.PlatformStand = true

    flyConnection = RunService.Heartbeat:Connect(function()
        if not Flying then return end
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0) end

        root.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * FlySpeed or Vector3.new(0, 0, 0)
    end)
end

local function StopFly()
    Flying = false
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local Noclip = false
local noclipConnection

local function ToggleNoclip()
    Noclip = not Noclip
    if Noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            if not Noclip then return end
            local char = LocalPlayer.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
    end
end

local InfiniteJump = false
UserInputService.JumpRequest:Connect(function()
    if InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ==================== LARGE HEAD HITBOX (New & Improved) ====================
local HitboxSettings = {
    Enabled = false,
    Size = 4.7,           -- default from your code
    Visuals = true,
}

local OriginalHeadProperties = {}  -- stores original size, color, material, transparency per player

local function ApplyHeadHitbox(plr)
    if plr == LocalPlayer or not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end

    -- Save original properties once
    if not OriginalHeadProperties[plr] then
        OriginalHeadProperties[plr] = {
            Size = head.Size,
            BrickColor = head.BrickColor,
            Material = head.Material,
            Transparency = head.Transparency
        }
    end

    if HitboxSettings.Enabled then
        head.Size = Vector3.new(HitboxSettings.Size, HitboxSettings.Size, HitboxSettings.Size)
        if HitboxSettings.Visuals then
            head.Material = Enum.Material.Neon
            head.BrickColor = BrickColor.new("Really red")
            head.Transparency = 0.7
        end
    else
        -- Restore original
        local orig = OriginalHeadProperties[plr]
        if orig then
            head.Size = orig.Size
            head.BrickColor = orig.BrickColor
            head.Material = orig.Material
            head.Transparency = orig.Transparency
        end
    end
end

local function UpdateAllHeadHitboxes()
    for _, plr in ipairs(Players:GetPlayers()) do
        ApplyHeadHitbox(plr)
    end
end

-- Handle existing + new players + respawns
for _, plr in ipairs(Players:GetPlayers()) do
    plr.CharacterAdded:Connect(function()
        task.wait(0.5)  -- give character time to load
        ApplyHeadHitbox(plr)
    end)
    if plr.Character then
        task.spawn(function() ApplyHeadHitbox(plr) end)
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        ApplyHeadHitbox(plr)
    end)
end)

-- Re-apply every frame when enabled (in case game resets properties)
RunService.Heartbeat:Connect(function()
    if HitboxSettings.Enabled then
        UpdateAllHeadHitboxes()
    end
end)

-- ==================== UI ====================
local ESPTab = Window:CreateTab("ESP Controls", 4483362458)

ESPTab:CreateSection("Toggles")
ESPTab:CreateToggle({Name = "ESP Enabled", CurrentValue = false, Flag = "Enabled", Callback = function(v) ESPSettings.Enabled = v end})
ESPTab:CreateToggle({Name = "Team Check", CurrentValue = true, Flag = "TeamCheck", Callback = function(v) ESPSettings.TeamCheck = v end})
ESPTab:CreateToggle({Name = "Boxes", CurrentValue = true, Callback = function(v) ESPSettings.Boxes = v end})
ESPTab:CreateToggle({Name = "Names + Distance", CurrentValue = true, Callback = function(v) ESPSettings.Names = v end})
ESPTab:CreateToggle({Name = "Health Bars", CurrentValue = true, Callback = function(v) ESPSettings.Health = v end})
ESPTab:CreateToggle({Name = "Tracers", CurrentValue = true, Callback = function(v) ESPSettings.Tracers = v end})

ESPTab:CreateDropdown({Name = "Tracer Origin", Options = {"Bottom", "Top", "Mouse"}, CurrentOption = "Bottom", Callback = function(opt) ESPSettings.TracerOrigin = opt[1] or opt end})

ESPTab:CreateSection("Customization")
ESPTab:CreateColorPicker({Name = "Box Color", Color = Color3.fromRGB(220,50,50), Callback = function(c) ESPSettings.BoxColor = c end})
ESPTab:CreateColorPicker({Name = "Tracer Color", Color = Color3.fromRGB(50,220,50), Callback = function(c) ESPSettings.TracerColor = c end})
ESPTab:CreateColorPicker({Name = "Text Color", Color = Color3.fromRGB(255,255,255), Callback = function(c) ESPSettings.TextColor = c end})

ESPTab:CreateSlider({Name = "Line Thickness", Range = {1, 5}, Increment = 0.5, CurrentValue = 1.5, Callback = function(v) ESPSettings.Thickness = v end})
ESPTab:CreateSlider({Name = "Max Distance (studs)", Range = {100, 2000}, Increment = 50, CurrentValue = 800, Callback = function(v) ESPSettings.MaxDistance = v end})

-- Cheats Tab
local CheatsTab = Window:CreateTab("Cheats", 4483362458)

CheatsTab:CreateSection("Aimbot")
CheatsTab:CreateToggle({Name = "Aimbot Enabled (Hold RMB)", CurrentValue = false, Callback = function(v) AimbotSettings.Enabled = v if v then StartAimbot() else StopAimbot() end end})
CheatsTab:CreateDropdown({Name = "Target Body Part", Options = {"Head", "HumanoidRootPart", "UpperTorso"}, CurrentOption = "Head", Callback = function(opt) AimbotSettings.LockPart = opt[1] or opt end})
CheatsTab:CreateToggle({Name = "Aimbot Team Check", CurrentValue = true, Callback = function(v) AimbotSettings.TeamCheck = v end})
CheatsTab:CreateToggle({Name = "Aimbot Wall Check", CurrentValue = false, Callback = function(v) AimbotSettings.WallCheck = v end})
CheatsTab:CreateSlider({Name = "Aimbot FOV", Range = {30, 300}, Increment = 5, CurrentValue = 90, Callback = function(v) AimbotSettings.FOV = v end})
CheatsTab:CreateSlider({Name = "Aimbot Smoothness", Range = {0.05, 1}, Increment = 0.05, CurrentValue = 0.2, Callback = function(v) AimbotSettings.Smoothness = v end})
CheatsTab:CreateSlider({Name = "Aimbot Prediction", Range = {0, 1}, Increment = 0.05, CurrentValue = 0, Callback = function(v) AimbotSettings.Prediction = v end})

CheatsTab:CreateSection("Movement")
CheatsTab:CreateToggle({Name = "Speed Hack", CurrentValue = false, Callback = function(v) SpeedSettings.Enabled = v UpdateSpeed() end})
CheatsTab:CreateSlider({Name = "WalkSpeed", Range = {16, 200}, Increment = 1, CurrentValue = 50, Callback = function(v) SpeedSettings.Value = v if SpeedSettings.Enabled then UpdateSpeed() end end})

CheatsTab:CreateToggle({Name = "Fly (Toggle)", CurrentValue = false, Callback = function(v) if v then StartFly() else StopFly() end end})
CheatsTab:CreateSlider({Name = "Fly Speed", Range = {20, 200}, Increment = 5, CurrentValue = 50, Callback = function(v) FlySpeed = v end})

CheatsTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) ToggleNoclip() end})
CheatsTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) InfiniteJump = v end})

-- New Hitbox Section
CheatsTab:CreateSection("Hitbox Expander")
CheatsTab:CreateToggle({
    Name = "Large Head Hitbox",
    CurrentValue = false,
    Callback = function(v)
        HitboxSettings.Enabled = v
        UpdateAllHeadHitboxes()
    end
})

CheatsTab:CreateSlider({
    Name = "Head Hitbox Size",
    Range = {1, 10},
    Increment = 0.1,
    CurrentValue = 4.7,
    Callback = function(v)
        HitboxSettings.Size = v
        if HitboxSettings.Enabled then
            UpdateAllHeadHitboxes()
        end
    end
})

CheatsTab:CreateToggle({
    Name = "Show Hitbox Visuals (Neon Red)",
    CurrentValue = true,
    Callback = function(v)
        HitboxSettings.Visuals = v
        if HitboxSettings.Enabled then
            UpdateAllHeadHitboxes()
        end
    end
})

Rayfield:Notify({
    Title = "✅ Updated with Large Head Hitbox!",
    Content = "Adjustable size + visuals + auto respawn support",
    Duration = 8,
    Image = 4483362458,
})

print("✅ Universal ESP + Cheats (with Large Head Hitbox)")
