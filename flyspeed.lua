-- Menu GUI
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- Criação da interface
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "FlySpeedMenu"

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

-- Funções de Voo
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

		bodyVelocity.Velocity = move.Unit * speed
		bodyGyro.CFrame = workspace.CurrentCamera.CFrame
	end)
end

function stopFlying()
	runService:UnbindFromRenderStep("FlyControl")
	if bodyVelocity then bodyVelocity:Destroy() end
	if bodyGyro then bodyGyro:Destroy() end
end

-- Botões
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
