-- Variáveis
local flying = false
local speed = 50  -- Velocidade inicial
local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local flightDirection = Vector3.new(0, 0, 0)
local currentVelocity = Vector3.new(0, 0, 0)
local bodyVelocity, bodyGyro
local isKeyPressed = {}  -- Armazenar o estado das teclas pressionadas

-- Função para configurar voo ao reaparecer
local function setupCharacter(character)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bodyVelocity.P = 1250
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bodyGyro.P = 3000
    
    if flying then
        bodyVelocity.Parent = humanoidRootPart
        bodyGyro.Parent = humanoidRootPart
        humanoid.PlatformStand = true
    end
end

-- Configurar evento de reaparecimento
player.CharacterAdded:Connect(setupCharacter)
if player.Character then
    setupCharacter(player.Character)
end

-- Alternar voo
local function toggleFly()
    flying = not flying
    local character = player.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoidRootPart or not humanoid then return end
    
    if flying then
        print("Voo ativado")
        bodyVelocity.Parent = humanoidRootPart
        bodyGyro.Parent = humanoidRootPart
        humanoid.PlatformStand = true
    else
        print("Voo desativado")
        bodyVelocity.Parent = nil
        bodyGyro.Parent = nil
        humanoid.PlatformStand = false
        flightDirection = Vector3.new(0, 0, 0)
        currentVelocity = Vector3.new(0, 0, 0)
    end
end

-- Ajustar velocidade
local function adjustSpeed(change)
    speed = speed + change
    print("Velocidade atual: " .. speed)
end

-- Detectar entrada de teclas
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Ativa o voo ao pressionar a tecla V
    if input.KeyCode == Enum.KeyCode.V then
        toggleFly()
    elseif flying then
        -- Se o voo estiver ativado e a tecla V não foi pressionada, registra os movimentos
        if not isKeyPressed[input.KeyCode] then
            isKeyPressed[input.KeyCode] = true
            
            if input.KeyCode == Enum.KeyCode.W then flightDirection = flightDirection + Vector3.new(0, 0, -1)
            elseif input.KeyCode == Enum.KeyCode.S then flightDirection = flightDirection + Vector3.new(0, 0, 1)
            elseif input.KeyCode == Enum.KeyCode.A then flightDirection = flightDirection + Vector3.new(-1, 0, 0)
            elseif input.KeyCode == Enum.KeyCode.D then flightDirection = flightDirection + Vector3.new(1, 0, 0)
            elseif input.KeyCode == Enum.KeyCode.Z then adjustSpeed(-20)
            elseif input.KeyCode == Enum.KeyCode.X then adjustSpeed(20) end
        end
    end
end)

-- Detectar a saída de teclas (quando a tecla é solta)
userInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Se o voo estiver ativado, registra o "fim" do movimento
    if flying then
        if isKeyPressed[input.KeyCode] then
            isKeyPressed[input.KeyCode] = nil

            if input.KeyCode == Enum.KeyCode.W then flightDirection = flightDirection - Vector3.new(0, 0, -1)
            elseif input.KeyCode == Enum.KeyCode.S then flightDirection = flightDirection - Vector3.new(0, 0, 1)
            elseif input.KeyCode == Enum.KeyCode.A then flightDirection = flightDirection - Vector3.new(-1, 0, 0)
            elseif input.KeyCode == Enum.KeyCode.D then flightDirection = flightDirection - Vector3.new(1, 0, 0) end
        end
    end
end)

-- Atualizar posição e rotação no voo
runService.Heartbeat:Connect(function()
    local character = player.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    if flying then
        local cameraCFrame = camera.CFrame
        local moveDirection = cameraCFrame:VectorToWorldSpace(flightDirection)
        local targetVelocity = moveDirection.Unit * speed
        if flightDirection.Magnitude == 0 then
            targetVelocity = Vector3.new(0, 0, 0)
        end
        currentVelocity = currentVelocity:Lerp(targetVelocity, 0.1)
        bodyVelocity.Velocity = currentVelocity
        bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + camera.CFrame.LookVector * Vector3.new(1, 0, 1))
    else
        -- Se o voo não estiver ativado, o personagem não vai se mover.
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end
end)
