-- Serviços
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- GUI principal
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "FlySpeedMenu"

--== Intro (animação inicial) ==--
local introFrame = Instance.new("Frame")
introFrame.Size = UDim2.new(0, 400, 0, 100)
introFrame.Position = UDim2.new(0.5, -200, 0, -120)
introFrame.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
introFrame.BackgroundTransparency = 0
introFrame.AnchorPoint = Vector2.new(0.5, 0)
introFrame.BorderSizePixel = 0
introFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 20)
corner.Parent = introFrame

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 1, 0)
textLabel.Position = UDim2.new(0, 0, 0, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = "Jhowll scripts"
textLabel.Font = Enum.Font.GothamBold
textLabel.TextSize = 36
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.TextStrokeTransparency = 0.5
textLabel.Parent = introFrame

local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local goal = {Position = UDim2.new(0.5, -200, 0.3, 0)}
TweenService:Create(introFrame, tweenInfo, goal):Play()

task.delay(3, function()
	local fadeOut = TweenService:Create(introFrame, TweenInfo.new(1), {BackgroundTransparency = 1})
	local textFade = TweenService:Create(textLabel, TweenInfo.new(1), {
		TextTransparency = 1,
		TextStrokeTransparency = 1
	})
	fadeOut:Play()
	textFade:Play()
	fadeOut.Completed:Wait()
	introFrame:Destroy()
end)

--== Botão de voo ==--
local flyButton = Instance.new("TextButton", screenGui)
flyButton.Position = UDim2.new(0.05, 0, 0.1, 0)
flyButton.Size = UDim2.new(0, 120, 0, 40)
flyButton.Text = "Ativar Voo"
flyButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
flyButton.TextColor3 = Color3.new(1,1,1)

--== Botão de andar mais rápido ==--
local speedButton = Instance.new("TextButton", screenGui)
speedButton.Position = UDim2.new(0.05, 0, 0.2, 0)
speedButton.Size = UDim2.new(0, 120, 0, 40)
speedButton.Text = "Aumentar Velocidade"
speedButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
speedButton.TextColor3 = Color3.new(1,1,1)

--== Slider de velocidade de voo ==--
local sliderFrame = Instance.new("Frame", screenGui)
sliderFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
sliderFrame.Size = UDim2.new(0, 200, 0, 40)
sliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
sliderFrame.BorderSizePixel = 0

local sliderBar = Instance.new("Frame", sliderFrame)
sliderBar.Position = UDim2.new(0, 10, 0.5, -5)
sliderBar.Size = UDim2.new(1, -20, 0, 10)
sliderBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
sliderBar.BorderSizePixel = 0

local fill = Instance.new("Frame", sliderBar)
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(60, 179, 113)
fill.BorderSizePixel = 0

local knob = Instance.new("Frame", sliderBar)
knob.Size = UDim2.new(0, 10, 0, 20)
knob.Position = UDim2.new(0, 0, 0.5, -10)
knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
knob.BorderSizePixel = 0
Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

local speedLabel = Instance.new("TextLabel", sliderFrame)
speedLabel.Position = UDim2.new(1, 5, 0, 0)
speedLabel.Size = UDim2.new(0, 60, 1, 0)
speedLabel.Text = "Vel: 50"
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.BackgroundTransparency = 1
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.Gotham

--== Voo ==--
local flying = false
local speed = 50
local flyVelocity = Vector3.new()
local bodyVelocity, bodyGyro

function startFlying()
	local root = character:WaitForChild("HumanoidRootPart")

	bodyVelocity = Instance.new("BodyVelocity", root)
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)

	bodyGyro = Instance.new("BodyGyro", root)
	bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	bodyGyro.CFrame = root.CFrame

	runService:BindToRenderStep("FlyControl", Enum.RenderPriority.Input.Value, function()
		local move = Vector3.zero
		if uis:IsKeyDown(Enum.KeyCode.W) then move += workspace.CurrentCamera.CFrame.LookVector end
		if uis:IsKeyDown(Enum.KeyCode.S) then move -= workspace.CurrentCamera.CFrame.LookVector end
		if uis:IsKeyDown(Enum.KeyCode.A) then move -= workspace.CurrentCamera.CFrame.RightVector end
		if uis:IsKeyDown(Enum.KeyCode.D) then move += workspace.CurrentCamera.CFrame.RightVector end
		if uis:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
		if uis:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

		bodyVelocity.Velocity = move.Magnitude > 0 and move.Unit * speed or Vector3.zero
		bodyGyro.CFrame = workspace.CurrentCamera.CFrame
	end)
end

function stopFlying()
	runService:UnbindFromRenderStep("FlyControl")
	if bodyVelocity then bodyVelocity:Destroy() end
	if bodyGyro then bodyGyro:Destroy() end
end

--== Ações dos botões ==--
flyButton.MouseButton1Click:Connect(function()
	flying = not flying
	if flying then
		startFlying()
		flyButton.Text = "Desativar Voo"
	else
		stopFlying()
		flyButton.Text = "Ativar Voo"
	end
end)

--== Lógica de aumentar velocidade de caminhada ==--
local walkingSpeed = 16
speedButton.MouseButton1Click:Connect(function()
	-- Aumenta a velocidade de caminhada do personagem
	walkingSpeed = walkingSpeed + 5
	if walkingSpeed > 50 then
		walkingSpeed = 50
	end
	humanoid.WalkSpeed = walkingSpeed
	speedLabel.Text = "Vel: " .. tostring(walkingSpeed)
end)

--== Slider Lógica de velocidade de voo ==--
local dragging = false
local minSpeed, maxSpeed = 50, 150  -- Velocidade de voo de 50 a 150

local function updateWalkSlider(inputX)
	local relativeX = math.clamp((inputX - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
	local newSpeed = math.floor(minSpeed + (maxSpeed - minSpeed) * relativeX)
	speed = newSpeed
	fill.Size = UDim2.new(relativeX, 0, 1, 0)
	knob.Position = UDim2.new(relativeX, -5, 0.5, -10
