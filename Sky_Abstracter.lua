-- ABSTRACTER REALISM V4 (Cosmetic, Local Only)

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "ARV4_UI"

------------------------------------------------
-- SKIES
------------------------------------------------
local Skies = {
	Default = "rbxassetid://90988519",
	Space = "rbxassetid://15983996673",
	Galaxy = "rbxassetid://8202961731",
	Storm = "rbxassetid://4607457995",
	Vaporwave = "rbxassetid://95200634"
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

ApplySky(Skies.Default)

------------------------------------------------
-- POST-PROCESSING (FPS STYLE)
------------------------------------------------
local cc = Instance.new("ColorCorrectionEffect", Lighting)
cc.Contrast = 0.2
cc.Saturation = 0.1
cc.TintColor = Color3.fromRGB(255,255,255)

local bloom = Instance.new("BloomEffect", Lighting)
bloom.Intensity = 1.5
bloom.Size = 24

local dof = Instance.new("DepthOfFieldEffect", Lighting)
dof.FocusDistance = 40
dof.InFocusRadius = 20
dof.FarIntensity = 0.5
dof.NearIntensity = 0.2

local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0

local lastCF = camera.CFrame
RunService.RenderStepped:Connect(function(dt)
	local speed = (camera.CFrame.Position - lastCF.Position).Magnitude/dt
	blur.Size = math.clamp(speed*0.4,0,20)
	lastCF = camera.CFrame
end)

------------------------------------------------
-- LIGHTNING STORMS
------------------------------------------------
task.spawn(function()
	while true do
		task.wait(math.random(8,20))
		local old = Lighting.Brightness
		Lighting.Brightness = 8
		task.wait(0.1)
		Lighting.Brightness = old
	end
end)

------------------------------------------------
-- VOLUMETRIC FOG/CLOUDS
------------------------------------------------
Lighting.FogColor = Color3.fromRGB(170,170,180)
Lighting.FogStart = 100
Lighting.FogEnd = 700

local clouds = Instance.new("ParticleEmitter")
clouds.Texture = "rbxassetid://114191997" -- fake cloud particle
clouds.Rate = 50
clouds.Lifetime = NumberRange.new(20)
clouds.Size = NumberSequence.new(50)
clouds.Speed = NumberRange.new(0)
clouds.Parent = workspace.Terrain -- particle system as fake volumetric cloud

------------------------------------------------
-- LOCAL RAIN
------------------------------------------------
local rainPart = Instance.new("Part")
rainPart.Anchored = true
rainPart.Transparency = 1
rainPart.CanCollide = false
rainPart.Size = Vector3.new(1,1,1)
rainPart.Parent = workspace

local rain = Instance.new("ParticleEmitter")
rain.Texture = "rbxassetid://241837157"
rain.Rate = 600
rain.Lifetime = NumberRange.new(1)
rain.Speed = NumberRange.new(90)
rain.Parent = rainPart

RunService.RenderStepped:Connect(function()
	rainPart.Position = camera.CFrame.Position + Vector3.new(0,20,0)
end)

------------------------------------------------
-- WEAPON FX
------------------------------------------------
local rainbowMode = false

local function ApplyWeaponFX(tool)
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 1
	highlight.OutlineColor = Color3.fromRGB(0,200,255)
	highlight.Parent = tool

	local pulse = 0
	RunService.RenderStepped:Connect(function(dt)
		pulse += dt*3
		highlight.OutlineTransparency = 0.4 + math.sin(pulse)*0.2
		if rainbowMode then
			highlight.OutlineColor = Color3.fromHSV(tick()%5/5,1,1)
		end
	end)

	for _,part in pairs(tool:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Material = Enum.Material.Neon
			part.Reflectance = 0.2
			local light = Instance.new("PointLight")
			light.Brightness = 2
			light.Range = 10
			light.Parent = part
		end
	end
end

local function MonitorChar(char)
	char.ChildAdded:Connect(function(v)
		if v:IsA("Tool") then
			ApplyWeaponFX(v)
		end
	end)
end

if player.Character then MonitorChar(player.Character) end
player.CharacterAdded:Connect(MonitorChar)

------------------------------------------------
-- CINEMATIC CAMERA SWAY + RECOIL
------------------------------------------------
local sway = 0
local recoil = 0
RunService.RenderStepped:Connect(function(dt)
	if sway < 0 then sway = 0 end
	local cf = camera.CFrame
	local angle = math.rad(math.sin(tick()*1.5)*0.2)
	camera.CFrame = cf * CFrame.Angles(angle,0,0)
	if recoil > 0 then
		camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(math.random(-recoil,recoil)/10), math.rad(math.random(-recoil,recoil)/10),0)
		recoil *= 0.85
	end
end)

------------------------------------------------
-- DRAGGABLE TAB UI
------------------------------------------------
local tabs = {"Skies","Weather","Weapons","PostProcessing"}
local currentTab = "Skies"

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,300,0,300)
frame.Position = UDim2.new(0,50,0,50)
frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
frame.Parent = gui

local dragging = false
local dragInput
local dragStart
local startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

frame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInput.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

------------------------------------------------
-- UI BUTTONS
------------------------------------------------
local y = 10
for name,id in pairs(Skies) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1,-20,0,30)
	btn.Position = UDim2.new(0,10,0,y)
	btn.Text = name
	btn.Parent = frame
	btn.MouseButton1Click:Connect(function()
		ApplySky(id)
	end)
	y += 35
end

-- Rainbow weapon toggle
local rainbowBtn = Instance.new("TextButton")
rainbowBtn.Size = UDim2.new(1,-20,0,30)
rainbowBtn.Position = UDim2.new(0,10,0,y)
rainbowBtn.Text = "Rainbow Weapons"
rainbowBtn.Parent = frame
rainbowBtn.MouseButton1Click:Connect(function()
	rainbowMode = not rainbowMode
end)
