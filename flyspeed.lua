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
introFrame.Position = UDim2.new(0.5, -200, 0, -120) -- começa fora da tela
introFrame.BackgroundColor3 = Color3.fromRGB(128, 0, 255) -- roxo
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

-- Aguarda a intro e remove
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

--== Botões principais ==--
local flyButton = Instance.new("TextButton", screenGui)
flyButton.Position = UDim2.new(0.05, 0, 0.1, 0)
flyButton.Size = UDim2.new(0, 120, 0, 40)
flyButton.Text = "Ativar Voo"
flyButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
flyButton.TextColor3 = Color3.new(1,1,1)

local speedButton = Instance.new("TextButton", screenGui)
speedButton.Position = UDim2.new(0.05, 0, 0.18, 0)
speedButton.Size = UDim2.new(0, 120, 0, 40)
speedButton.Text = "Vel: 16"
speedButton.BackgroundColor3 = Color3.fromRGB(60, 179, 113)
speedButton.TextColor3 = Color3.new(1,1,1)

--== Voo ==--
local flying = false
local speed = 16
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

speedButton.MouseButton1Click:Connect(function()
	speed = speed + 10
	if speed > 100 then speed = 16 end
	speedButton.Text = "Vel: " .. speed
end)
