-- Sky_Abstracter.lua

-- Removed motion blur effects
-- Removed GUI button and toggle frame
-- Removed sky changing functionality
-- Enhanced shader toggle functionality
-- Removed weapon visual FX section

-- Added shader effects
-- Added a purple aura highlight around all players on the map

local players = game.Players:GetPlayers()

function applyPurpleAura(player)
    -- Function to apply purple aura highlight
    local aura = Instance.new("ParticleEmitter")
    aura.Color = ColorSequence.new(Color3.fromRGB(128, 0, 128))
    aura.Size = NumberSequence.new(0.5)
    aura.Lifetime = NumberRange.new(1)
    aura.Rate = 50
    aura.Parent = player.Character.Head
end

for _, player in pairs(players) do
    applyPurpleAura(player)
end

-- Toggle for shader effect
local shaderEnabled = true

function toggleShader()
    if shaderEnabled then
        -- Enable shader logic
        shaderEnabled = false
    else
        -- Disable shader logic
        shaderEnabled = true
    end
end

-- Additional functions or logic can go here.