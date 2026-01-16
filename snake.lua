---@diagnostic disable: undefined-global

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

-- Config
local BlockSpeed = 50      -- velocidade que os blocos se movem
local SpinSpeed = 30       -- rotação devagar
local PullDistance = 2     -- distância mínima para parar de girar
local SnakeSpacing = 2     -- distância entre cada bloco na cobra

local Blocks = {}
local Active = false

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "BlockSnakeGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 80)
Frame.Position = UDim2.new(0.05,0,0.3,0)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundColor3 = Color3.fromRGB(35,35,35)
Title.Text = "Block Snake"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16

local Button = Instance.new("TextButton", Frame)
Button.Size = UDim2.new(0.9,0,0,35)
Button.Position = UDim2.new(0.05,0,0,40)
Button.Text = "Toggle Snake"
Button.BackgroundColor3 = Color3.fromRGB(60,120,60)
Button.TextColor3 = Color3.new(1,1,1)

Button.MouseButton1Click:Connect(function()
    Active = not Active
    Button.Text = Active and "Snake ON" or "Snake OFF"
end)

-- Detecta blocos soltos
local function UpdateBlocks()
    Blocks = {}
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Anchored then
            table.insert(Blocks, part)
        end
    end
end

spawn(function()
    while true do
        UpdateBlocks()
        wait(2)
    end
end)

-- Função para pegar a posição do mouse no mundo
local function GetMousePos()
    local Mouse = LocalPlayer:GetMouse()
    local UnitRay = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
    return UnitRay.Origin + UnitRay.Direction * 50 -- 50 studs à frente
end

-- Movimento tipo cobra
RunService.RenderStepped:Connect(function(dt)
    if Active then
        local targetPos = GetMousePos()
        local lastPos = targetPos

        for i, block in ipairs(Blocks) do
            if block and block.Parent then
                local dir = (lastPos - block.Position)
                local distance = dir.Magnitude
                if distance > PullDistance then
                    block.Velocity = dir.Unit * BlockSpeed
                else
                    -- girar devagar ao redor do último alvo
                    local angle = math.rad(SpinSpeed * dt)
                    local offset = block.Position - lastPos
                    local x = offset.X * math.cos(angle) - offset.Z * math.sin(angle)
                    local z = offset.X * math.sin(angle) + offset.Z * math.cos(angle)
                    block.CFrame = CFrame.new(lastPos + Vector3.new(x, offset.Y, z))
                    block.Velocity = Vector3.new(0,0,0)
                end
                -- Mantém distância tipo cobra
                lastPos = block.Position - (dir.Unit * SnakeSpacing)
            end
        end
    end
end)
