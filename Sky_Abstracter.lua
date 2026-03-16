-- ABSTRACTOR REALISM – ULTIMATE VFX MOD
-- Local only, cosmetic

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

------------------------------------------------
-- TOGGLE GUI BUTTON
------------------------------------------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "AR_Ultimate_GUI"

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 200, 0, 40)
toggleButton.Position = UDim2.new(0, 50, 0, 50)
toggleButton.Text = "Toggle Abstracter Realism"
toggleButton.BackgroundColor3 = Color3.fromRGB(40,40,45)
toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
toggleButton.Parent = gui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 400)
mainFrame.Position = UDim2.new(0, 50, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,35)
mainFrame.Visible = false
mainFrame.Parent = gui

toggleButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- Draggable UI
local dragging = false
local dragInput
local dragStart
local startPos
mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)
mainFrame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
UserInput.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

------------------------------------------------
-- SKY OPTIONS
------------------------------------------------
local Skies = {
	Default = "rbxassetid://90988519",
	Space = "rbxassetid://15983996673",
	Galaxy = "rbxassetid://8202961731",
	Storm = "rbxassetid://4607457995",
	Vaporwave = "rbxassetid://95200634",
	Sunset = "rbxassetid://12345678", -- example
	Night = "rbxassetid://23456789", -- example
	Cloudy = "rbxassetid://34567890" -- example
}
local CurrentSky
local function ApplySky(id)
	if Lighting:FindFirstChild("AR_Sky") then Lighting.AR_Sky:Destroy() end
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

-- Sky buttons in UI
local y = 10
for name,id in pairs(Skies) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1,-20,0,30)
	btn.Position = UDim2.new(0,10,0,y)
	btn.Text = name
	btn.Parent = mainFrame
	btn.MouseButton1Click:Connect(function()
		ApplySky(id)
	end)
	y += 35
end

------------------------------------------------
-- SHADER TOGGLE
------------------------------------------------
local darkShader = false
local shaderBtn = Instance.new("TextButton")
shaderBtn.Size = UDim2.new(1,-20,0,30)
shaderBtn.Position = UDim2.new(0,10,0,y)
shaderBtn.Text = "Toggle Dark/Regular Shader"
shaderBtn.Parent = mainFrame
shaderBtn.MouseButton1Click:Connect(function()
	darkShader = not darkShader
	if darkShader then
		Lighting.Ambient = Color3.fromRGB(40,40,50)
	else
		Lighting.Ambient = Color3.fromRGB(170,170,170)
	end
end)
y += 35

------------------------------------------------
-- POST-PROCESSING
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
	blur.Size = math.clamp(speed*0.5,0,20)
	lastCF = camera.CFrame
end)

------------------------------------------------
-- LOCAL WEATHER
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

Lighting.FogColor = Color3.fromRGB(170,170,180)
Lighting.FogStart = 100
Lighting.FogEnd = 700

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
-- WEAPON VISUAL FX
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
		if v:IsA("Tool") then ApplyWeaponFX(v) end
	end)
end

if player.Character then MonitorChar(player.Character) end
player.CharacterAdded:Connect(MonitorChar)

-- Rainbow toggle button
local rainbowBtn = Instance.new("TextButton")
rainbowBtn.Size = UDim2.new(1,-20,0,30)
rainbowBtn.Position = UDim2.new(0,10,0,y)
rainbowBtn.Text = "Rainbow Weapons"
rainbowBtn.Parent = mainFrame
rainbowBtn.MouseButton1Click:Connect(function()
	rainbowMode = not rainbowMode
end)
y += 35

------------------------------------------------
-- CINEMATIC CAMERA + SWAY + RECOIL
------------------------------------------------
local sway = 0
local recoil = 0
RunService.RenderStepped:Connect(function(dt)
	local cf = camera.CFrame
	local angle = math.rad(math.sin(tick()*1.5)*0.2)
	camera.CFrame = cf * CFrame.Angles(angle,0,0)
	if recoil > 0 then
		camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(math.random(-recoil,recoil)/10), math.rad(math.random(-recoil,recoil)/10),0)
		recoil *= 0.85
	end
end)
