--[[
    99 Nights in the Forest - Ultimate Farm Script
    Версия: 1.0
    Автофарм ресурсов, убийство врагов, сбор сундуков
    ВНИМАНИЕ: Использование на свой страх и риск!
]]

-- Настройки (можешь менять)
local Settings = {
    AutoFarm = true,           -- автосбор ресурсов
    AutoKill = true,           -- автоатака врагов
    AutoLoot = true,           -- автоподбор лута
    ESP = true,                -- показывать объекты сквозь стены
    FarmRadius = 50,           -- радиус сбора
    KillRadius = 30,           -- радиус атаки
    WalkSpeed = 24,            -- скорость бега
    JumpPower = 70,            -- сила прыжка
    ShowStats = true           -- показывать статистику
}

-- Сервисы
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- GUI для статистики
if Settings.ShowStats then
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = "NinetyNineStats"
    
    local Frame = Instance.new("Frame")
    Frame.Parent = ScreenGui
    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BackgroundTransparency = 0.3
    Frame.Position = UDim2.new(0.02, 0, 0.02, 0)
    Frame.Size = UDim2.new(0, 200, 0, 100)
    Frame.Active = true
    Frame.Draggable = true
    
    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = "99 Nights Farm\nСтатус: Работает\nГемов: 0"
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.TextWrapped = true
end

-- Функция получения персонажа
local function GetChar()
    return LocalPlayer.Character
end

-- Функция получения корневой части
local function GetHRP()
    local char = GetChar()
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart
    end
    return nil
end

-- Установка скорости
if Settings.WalkSpeed > 16 then
    game:GetService("RunService").Stepped:Connect(function()
        local char = GetChar()
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = Settings.WalkSpeed
            char.Humanoid.JumpPower = Settings.JumpPower
        end
    end)
end

-- ESP (подсветка объектов)
if Settings.ESP then
    local function CreateHighlight(obj, color)
        if obj:FindFirstChildOfClass("Highlight") then return end
        local highlight = Instance.new("Highlight")
        highlight.Parent = obj
        highlight.FillColor = color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
    end
    
    -- Подсвечиваем ресурсы, врагов, сундуки
    RunService.Heartbeat:Connect(function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.PrimaryPart then
                if obj.Name:match("Chest") or obj.Name:match("сундук") then
                    CreateHighlight(obj, Color3.fromRGB(255, 215, 0)) -- золотой
                elseif obj:FindFirstChild("Humanoid") and obj ~= GetChar() then
                    CreateHighlight(obj, Color3.fromRGB(255, 0, 0)) -- красный для врагов
                elseif obj.Name:match("Berry") or obj.Name:match("ягода") or obj.Name:match("Wood") then
                    CreateHighlight(obj, Color3.fromRGB(0, 255, 0)) -- зеленый для ресурсов
                end
            end
        end
    end)
end

-- Автоатака врагов
if Settings.AutoKill then
    RunService.Heartbeat:Connect(function()
        local hrp = GetHRP()
        if not hrp then return end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= GetChar() then
                local targetHRP = obj:FindFirstChild("HumanoidRootPart")
                if targetHRP and (targetHRP.Position - hrp.Position).Magnitude < Settings.KillRadius then
                    -- Имитация атаки (нажатие кнопки мыши)
                    mouse1press()
                    wait(0.1)
                    mouse1release()
                end
            end
        end
    end)
end

-- Автосбор ресурсов
if Settings.AutoFarm then
    RunService.Heartbeat:Connect(function()
        local hrp = GetHRP()
        if not hrp then return end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.PrimaryPart then
                local isResource = obj.Name:match("Berry") or obj.Name:match("Wood") or 
                                  obj.Name:match("Stone") or obj.Name:match("Herb") or
                                  obj.Name:match("Chest") or obj.Name:match("Loot")
                
                if isResource and (obj.PrimaryPart.Position - hrp.Position).Magnitude < Settings.FarmRadius then
                    hrp.CFrame = obj.PrimaryPart.CFrame * CFrame.new(0, 2, 2)
                    wait(0.3)
                    -- Попытка собрать (клик)
                    mouse1press()
                    wait(0.1)
                    mouse1release()
                end
            end
        end
    end)
end

-- Автоподбор лута
if Settings.AutoLoot then
    RunService.Heartbeat:Connect(function()
        local hrp = GetHRP()
        if not hrp then return end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:match("Loot") or obj.Name:match("Drop") then
                if obj.PrimaryPart and (obj.PrimaryPart.Position - hrp.Position).Magnitude < 15 then
                    hrp.CFrame = obj.PrimaryPart.CFrame
                    wait(0.2)
                end
            end
        end
    end)
end

-- Горячая клавиша для остановки (F6)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F6 then
        Settings.AutoFarm = false
        Settings.AutoKill = false
        Settings.AutoLoot = false
        print("Скрипт остановлен")
    end
end)

print("✅ 99 Nights Script загружен!")
print("🛑 Нажми F6 для остановки")
