-- LocalScript inside your Tool
local tool = script.Parent
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Settings
local recoilAmount = 5
local glowBaseBrightness = 6
local glowRange = 15
local glowColor = Color3.fromRGB(200, 120, 255) -- photo-style purple/pink
local pulseSpeed = 6
local pulseAmount = 0.5

-- Add pulsing glow to parts
local function addGlow(part)
    if not part:FindFirstChild("CustomGlow") then
        local light = Instance.new("PointLight")
        light.Name = "CustomGlow"
        light.Color = glowColor
        light.Brightness = glowBaseBrightness
        light.Range = glowRange
        light.Shadows = true
        light.Parent = part
    end
end

for _, part in pairs(tool:GetDescendants()) do
    if part:IsA("BasePart") then
        addGlow(part)
    end
end

-- Fire effect
local function shoot()
    local barrel = tool:FindFirstChild("Handle") or tool.PrimaryPart
    if barrel then
        -- Heat-wave / smoke particle
        local heat = Instance.new("ParticleEmitter")
        heat.Texture = "rbxassetid://5411997957" -- small smoke/fire
        heat.Rate = 120
        heat.Lifetime = NumberRange.new(0.15, 0.25)
        heat.Speed = NumberRange.new(2,4)
        heat.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})
        heat.Rotation = NumberRange.new(0,360)
        heat.VelocitySpread = 180
        heat.LightEmission = 1
        heat.Parent = barrel
        delay(0.15, function() heat:Destroy() end)
    end

    -- Camera recoil (visual only)
    local recoilCFrame = CFrame.Angles(math.rad(-recoilAmount), 0, 0)
    camera.CFrame = camera.CFrame * recoilCFrame
end

tool.Activated:Connect(shoot)

-- Glow pulse
RunService.RenderStepped:Connect(function()
    local pulse = 1 + pulseAmount * math.sin(tick() * pulseSpeed)
    for _, part in pairs(tool:GetDescendants()) do
        if part:IsA("BasePart") and part:FindFirstChild("CustomGlow") then
            part.CustomGlow.Brightness = glowBaseBrightness * pulse
        end
    end
end)
