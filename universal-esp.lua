local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Universal ESP",
    LoadingTitle = "Loading ESP",
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

-- Settings
local ESPSettings = {
    Enabled = false,
    TeamCheck = true,
    MaxDistance = 800,          -- new: prevents drawing super far players
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

    local HealthOutline = Drawing.new("Line")  -- black outline
    HealthOutline.Thickness = 5
    HealthOutline.Color = Color3.new(0, 0, 0)
    HealthOutline.Transparency = ESPSettings.Transparency

    local HealthBar = Drawing.new("Line")      -- colored bar
    HealthBar.Thickness = 3
    HealthBar.Transparency = ESPSettings.Transparency

    ESPObjects[plr] = {
        Box = Box,
        Tracer = Tracer,
        Name = NameTag,
        HealthOutline = HealthOutline,
        Health = HealthBar
    }

    -- Cleanup
    plr.AncestryChanged:Connect(function()
        if not plr.Parent then
            for _, obj in pairs(ESPObjects[plr] or {}) do
                pcall(function() obj:Remove() end)
            end
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

        -- Distance check
        local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
            and (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or 0
        
        if distance > ESPSettings.MaxDistance then
            for _, obj in pairs(drawings) do obj.Visible = false end
            continue
        end

        -- Box size
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))
        local legPos  = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0))
        local boxHeight = math.abs(headPos.Y - legPos.Y)
        local boxWidth  = boxHeight * 0.55

        local boxPos = Vector2.new(rootPos.X - boxWidth/2, rootPos.Y - boxHeight/2)

        -- Box
        drawings.Box.Size = Vector2.new(boxWidth, boxHeight)
        drawings.Box.Position = boxPos
        drawings.Box.Color = ESPSettings.BoxColor
        drawings.Box.Visible = ESPSettings.Boxes
        drawings.Box.Thickness = ESPSettings.Thickness

        -- Name + Distance
        drawings.Name.Text = string.format("%s [%.0f]", plr.Name, distance)
        drawings.Name.Position = Vector2.new(rootPos.X, boxPos.Y - ESPSettings.TextSize - 4)
        drawings.Name.Color = ESPSettings.TextColor
        drawings.Name.Size = ESPSettings.TextSize
        drawings.Name.Visible = ESPSettings.Names

        -- Health Bar + Outline
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

        -- Tracer
        local tracerFrom
        if ESPSettings.TracerOrigin == "Bottom" then
            tracerFrom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        elseif ESPSettings.TracerOrigin == "Top" then
            tracerFrom = Vector2.new(Camera.ViewportSize.X / 2, 0)
        else -- Mouse
            local success, mousePos = pcall(function()
                return UserInputService:GetMouseLocation()
            end)
            tracerFrom = success and mousePos or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        end

        drawings.Tracer.From = tracerFrom
        drawings.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
        drawings.Tracer.Color = ESPSettings.TracerColor
        drawings.Tracer.Thickness = ESPSettings.Thickness
        drawings.Tracer.Visible = ESPSettings.Tracers
    end
end

-- Initialize
for _, plr in ipairs(Players:GetPlayers()) do
    task.spawn(CreateESP, plr)
    if plr.Character then task.wait(0.1) CreateESP(plr) end
    plr.CharacterAdded:Connect(function() task.wait(0.3) CreateESP(plr) end)
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function() task.wait(0.3) CreateESP(plr) end)
end)

RunService.RenderStepped:Connect(UpdateESP)

-- ==================== UI ====================
local ESPTab = Window:CreateTab("ESP Controls", 4483362458)

ESPTab:CreateSection("Toggles")
ESPTab:CreateToggle({Name = "ESP Enabled", CurrentValue = false, Flag = "Enabled", Callback = function(v) ESPSettings.Enabled = v end})
ESPTab:CreateToggle({Name = "Team Check", CurrentValue = true, Flag = "TeamCheck", Callback = function(v) ESPSettings.TeamCheck = v end})
ESPTab:CreateToggle({Name = "Boxes", CurrentValue = true, Callback = function(v) ESPSettings.Boxes = v end})
ESPTab:CreateToggle({Name = "Names + Distance", CurrentValue = true, Callback = function(v) ESPSettings.Names = v end})
ESPTab:CreateToggle({Name = "Health Bars", CurrentValue = true, Callback = function(v) ESPSettings.Health = v end})
ESPTab:CreateToggle({Name = "Tracers", CurrentValue = true, Callback = function(v) ESPSettings.Tracers = v end})

ESPTab:CreateDropdown({
    Name = "Tracer Origin",
    Options = {"Bottom", "Top", "Mouse"},
    CurrentOption = "Bottom",
    Callback = function(opt) ESPSettings.TracerOrigin = opt[1] or opt end
})

ESPTab:CreateSection("Customization")
ESPTab:CreateColorPicker({Name = "Box Color", Color = Color3.fromRGB(220,50,50), Callback = function(c) ESPSettings.BoxColor = c end})
ESPTab:CreateColorPicker({Name = "Tracer Color", Color = Color3.fromRGB(50,220,50), Callback = function(c) ESPSettings.TracerColor = c end})
ESPTab:CreateColorPicker({Name = "Text Color", Color = Color3.fromRGB(255,255,255), Callback = function(c) ESPSettings.TextColor = c end})

ESPTab:CreateSlider({
    Name = "Line Thickness",
    Range = {1, 5},
    Increment = 0.5,
    CurrentValue = 1.5,
    Callback = function(v)
        ESPSettings.Thickness = v
        for _, drawings in pairs(ESPObjects) do
            if drawings.Box then drawings.Box.Thickness = v end
            if drawings.Tracer then drawings.Tracer.Thickness = v end
        end
    end
})

ESPTab:CreateSlider({
    Name = "Max Distance (studs)",
    Range = {100, 2000},
    Increment = 50,
    CurrentValue = 800,
    Callback = function(v) ESPSettings.MaxDistance = v end
})

Rayfield:Notify({
    Title = "✅ ESP Fully Fixed & Loaded!",
    Content = "All bugs fixed • Health bar corrected • Mouse safe • Enjoy!",
    Duration = 8,
    Image = 4483362458,
})

print("✅ Clean Polished ESP - Fully Fixed & Improved!")