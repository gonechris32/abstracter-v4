    -- LocalScript for Rivals VFX
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- SETTINGS
local glowBaseBrightness = 6
local glowRange = 15
local pulseSpeed = 6
local pulseAmount = 0.5
local auraColor = Color3.fromRGB(200, 120, 255) -- purple-pink

local recoilAmount = 5

-- Function to add glow to a part
local function addGlow(part)
    if not part:FindFirstChild("CustomGlow") then
        local light = Instance.new("PointLight")
        light.Name = "CustomGlow"
        light.Color = auraColor
        light.Brightness = glowBaseBrightness
        light.Range = glowRange
        light.Shadows = true
        light.Parent = part
    end
end

-- Function to add aura effect (SurfaceLight sphere) around part
local function addAura(part)
    if not part:FindFirstChild("Aura") then
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.Sphere
        mesh.Scale = Vector3.new(2,2,2)
        mesh.Parent = part

        local aura = Instance.new("PointLight")
        aura.Name = "Aura"
        aura.Color = auraColor
        aura.Brightness = glowBaseBrightness * 0.7
        aura.Range = glowRange * 2
        aura.Parent = part
    end
end

-- Apply glow & aura to a player's character
local function applyToCharacter(char)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            addGlow(part)
            addAura(part)
        end
    end
end

-- Apply to all players
for _, plr in pairs(game.Players:GetPlayers()) do
    if plr.Character then
        applyToCharacter(plr.Character)
    end
end

-- Apply when a new player joins
game.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        applyToCharacter(char)
    end)
end)

-- Apply to your character when it loads
player.CharacterAdded:Connect(function(char)
    applyToCharacter(char)
end)
if player.Character then
    applyToCharacter(player.Character)
end

-- Camera recoil + gun heat-wave
local function onFire()
    local char = player.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local barrel = tool:FindFirstChild("Handle") or tool.PrimaryPart
    if not barrel then return end

    -- Heat-wave particle
    local heat = Instance.new("ParticleEmitter")
    heat.Texture = "rbxassetid://5411997957"
    heat.Rate = 120
    heat.Lifetime = NumberRange.new(0.15,0.25)
    heat.Speed = NumberRange.new(2,4)
    heat.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})
    heat.Rotation = NumberRange.new(0,360)
    heat.VelocitySpread = 180
    heat.LightEmission = 1
    heat.Parent = barrel
    delay(0.15, function() heat:Destroy() end)

    -- Camera visual recoil
    camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(-recoilAmount),0,0)
end

player:GetMouse().Button1Down:Connect(onFire)

-- Pulsing glow/aura
RunService.RenderStepped:Connect(function()
    local pulse = 1 + pulseAmount * math.sin(tick() * pulseSpeed)
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr.Character then
            for _, part in pairs(plr.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part:FindFirstChild("CustomGlow") then
                        part.CustomGlow.Brightness = glowBaseBrightness * pulse
                    end
                    if part:FindFirstChild("Aura") then
                        part.Aura.Brightness = glowBaseBrightness * 0.7 * pulse
                    end
                end
            end
        end
    end
end)
