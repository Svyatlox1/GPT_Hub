--[[
    Dead Rails Auto Farm Bonds
    Версия: 2.0
    Автоматический сбор бондов на всех локациях
]]

-- Настройки (можешь менять)
local Cooldown = 0.1 -- скорость сбора (меньше = быстрее)
local AutoTeleport = true -- авто-телепорт к бондам
local ShowStats = true -- показывать статистику

-- ID игры Dead Rails
local LOBBY_ID = 116495829188952
local GAME_ID = 70876832253163

-- Сервисы
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Переменные для статистики
local BondCount = 0
local TrackCount = 1
local TrackPassed = false
local FoundLobby = false
local Farming = true
local StatsGui = nil

-- Создаем GUI для статистики (если включено)
if ShowStats then
    StatsGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local Label = Instance.new("TextLabel")
    
    StatsGui.Parent = game.CoreGui
    StatsGui.Name = "DeadRailsStats"
    
    Frame.Parent = StatsGui
    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BackgroundTransparency = 0.5
    Frame.Position = UDim2.new(0, 10, 0, 10)
    Frame.Size = UDim2.new(0, 200, 0, 100)
    Frame.Active = true
    Frame.Draggable = true
    
    Label.Parent = Frame
    Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = "Dead Rails Farm\nБондов: 0\nТреков: 1"
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.TextWrapped = true
end

-- Функция обновления статистики
local function UpdateStats()
    if StatsGui and StatsGui:FindFirstChild("Frame") then
        local Label = StatsGui.Frame:FindFirstChildOfClass("TextLabel")
        if Label then
            Label.Text = string.format("Dead Rails Farm\nБондов: %d\nТреков: %d", BondCount, TrackCount)
        end
    end
end

-- Функция безопасного получения HRP
local function GetHRP()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart
    end
    return nil
end

-- Главная логика в зависимости от места
if game.PlaceId == LOBBY_ID then
    -- Мы в лобби - ищем игру
    print("🔍 Поиск лобби для фарма...")
    
    local CreateParty = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CreatePartyClient")
    
    while Farming and task.wait(Cooldown) do
        if not FoundLobby then
            for _, zone in pairs(Workspace.TeleportZones:GetChildren()) do
                if zone.Name == "TeleportZone" and zone:FindFirstChild("BillboardGui") then
                    local stateLabel = zone.BillboardGui:FindFirstChild("StateLabel")
                    if stateLabel and stateLabel.Text == "Waiting for players..." then
                        print("✅ Лобби найдено! Телепортируюсь...")
                        
                        local hrp = GetHRP()
                        if hrp then
                            hrp.CFrame = zone.ZoneContainer.CFrame
                            FoundLobby = true
                            task.wait(1)
                            CreateParty:FireServer({["maxPlayers"] = 1})
                            print("🚀 Создаю игру...")
                        end
                    end
                end
            end
        end
    end
    
elseif game.PlaceId == GAME_ID then
    -- Мы в игре - собираем бонды
    print("💰 Начинаю сбор бондов...")
    
    local StartingTrack = Workspace.RailSegments:FindFirstChild("RailSegment")
    local CollectBond = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ActivateObjectClient")
    local Items = Workspace.RuntimeItems
    
    -- Ждем появления персонажа
    repeat task.wait() until LocalPlayer.Character
    
    local hrp = GetHRP()
    if hrp then
        hrp.Anchored = true -- фиксируем чтобы не упасть
    end
    
    while Farming and task.wait(Cooldown) do
        -- Перемещаемся на новый трек
        if not TrackPassed then
            print(string.format("🚂 Перемещаюсь на трек %d", TrackCount))
            TrackPassed = true
        end
        
        -- Телепортируемся выше текущего трека
        hrp = GetHRP()
        if hrp and StartingTrack and StartingTrack:FindFirstChild("Guide") then
            hrp.CFrame = StartingTrack.Guide.CFrame + Vector3.new(0, 250, 0)
        end
        
        -- Переходим на следующий трек если есть
        if StartingTrack and StartingTrack:FindFirstChild("NextTrack") and StartingTrack.NextTrack.Value ~= nil then
            StartingTrack = StartingTrack.NextTrack.Value
            TrackCount = TrackCount + 1
        else
            -- Треки кончились - возвращаемся в лобби
            print("🏁 Все треки пройдены! Возвращаюсь в лобби...")
            TeleportService:Teleport(LOBBY_ID, LocalPlayer)
            break
        end
        
        -- Собираем бонды на текущем треке
        repeat
            for _, item in pairs(Items:GetChildren()) do
                if item.Name == "Bond" or item.Name == "BondCalculated" then
                    -- Телепортируем бонд к игроку
                    if AutoTeleport and item:FindFirstChild("Part") then
                        spawn(function()
                            pcall(function()
                                item.Part.CFrame = hrp.CFrame
                            end)
                        end)
                    end
                    
                    -- Активируем сбор бонда
                    spawn(function()
                        pcall(function()
                            CollectBond:FireServer(item)
                        end)
                    end)
                    
                    -- Обновляем статистику
                    if item.Name == "Bond" then
                        BondCount = BondCount + 1
                        print(string.format("💰 Собрано бондов: %d", BondCount))
                        UpdateStats()
                        item.Name = "BondCalculated"
                    end
                end
            end
            task.wait()
        until Items:FindFirstChild("Bond") == nil
        
        TrackPassed = false
        UpdateStats()
    end
end

-- Функция остановки фарма
function StopFarming()
    Farming = false
    local hrp = GetHRP()
    if hrp then
        hrp.Anchored = false
    end
    if StatsGui then
        StatsGui:Destroy()
    end
    print("⛔ Фарм остановлен")
end

-- Добавляем горячую клавишу для остановки (F6)
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F6 then
        StopFarming()
    end
end)

print("✅ Dead Rails Auto Farm Bonds загружен!")
print("📊 Статистика в левом верхнем углу")
print("🛑 Нажми F6 для остановки")
