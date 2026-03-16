-- ABSTRACTOR REALISM – GUI-Free, No Motion Blur, Full Visual Effects
-- Local Only, Cosmetic

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

------------------------------------------------
-- SKY OPTIONS (applied automatically)
------------------------------------------------
local Skies = {
	Default = "rbxassetid://90988519",
	Space = "rbxassetid://15983996673",
	Galaxy = "rbxassetid://8202961731",
	Storm = "rbxassetid://4607457995",
	Vaporwave = "rbxassetid://95200634",
	Sunset = "rbxassetid://12345678",
	Night = "rbxassetid://23456789",
	Cloudy = "rbxassetid://34567890"
}

local CurrentSky
local function ApplySky(id)
	if Lighting:FindFirstChild("AR_Sky") then
		Lighting.AR_Sky:Destroy()
	end
	local sky = Instance.new("Sky")
	sky.Name = "AR_Sky"
	sky.SkyboxBk = id
	sky.SkyboxFt = id
	sky.SkyboxLf = id
	sky.SkyboxRt = id
	sky.SkyboxUp = id
	sky.SkyboxDn = id
	sky.Parent = Lighting
	CurrentSky = sky
end

-- Automatically set default sky
ApplySky(Skies.Default)

------------------------------------------------
-- POST-PROCESSING (FPS style)
------------------------------------------------
local cc = Instance.new("ColorCorrectionEffect", Lighting)
cc.Contrast = 0.2
cc.Saturation = 0.1
cc.TintColor = Color3.fromRGB(255,255,255)

local bloom = Instance.new("BloomEffect", Lighting)
bloom.Intensity = 1.5
bloom.Size = 24

local dof =
