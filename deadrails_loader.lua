--[[
    Dead Rails Auto Farm Bonds (автоопределение)
    Версия 3.0 — не требует PlaceId, работает по структуре игры
]]

-- Настройки (можешь менять)
local Cooldown = 0.1          -- скорость сбора (меньше = быстрее)
local AutoTeleport = true     -- телепортировать бонды к себе
local ShowUI = true           -- показывать информационное окно

-- Сервисы
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Переменные
local Farming = true
local BondCount = 0
local TrackCount = 1
local StatsGui = nil
local StatusLabel = nil

-- Создаём GUI для информации (если включено)
if ShowUI then
    StatsGui = Instance.new("ScreenGui")
    StatsGui.Parent = game.CoreGui
    StatsGui.Name = "DeadRailsFarmUI"
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = StatsGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.02, 0, 0.02, 0)
    mainFrame.Size = UDim2.new(0, 250, 0, 130)
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Font = Enum.Font.GothamBold
    title.Text = "Dead Rails Farm"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    
    StatusLabel = Instance.new("TextLabel")
    StatusLabel.Parent = mainFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 5, 0, 35)
    StatusLabel.Size = UDim2.new(1, -10, 0, 60)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "Определение режима..."
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.TextSize = 14
    StatusLabel.TextWrapped = true
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = mainFrame
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    closeBtn.Position = UDim2.new(1, -25, 0, 5)
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.MouseButton1Click:Connect(function()
        StatsGui:Destroy()
    end)
end

-- Функция обновления статуса в GUI
local function SetStatus(text)
    if StatusLabel then
        StatusLabel.Text = text
    end
    print("[Dead Rails] " .. text)  -- на случай если консоль всё же видна
end

-- Функция безопасного получения HRP
local function GetHRP()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart
    end
    return nil
end

-- Функция остановки фарма
local function StopFarming()
    Farming = false
    local hrp = GetHRP()
    if hrp then
        hrp.Anchored = false
    end
    if StatsGui then
        StatsGui:Destroy()
    end
    SetStatus("Фарм остановлен")
end

-- Горячая клавиша F6 для остановки
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F6 then
        StopFarming()
    end
end)

-- АВТООПРЕДЕЛЕНИЕ РЕЖИМА
local function DetermineMode()
    -- Проверяем, есть ли характерные объекты лобби
    if Workspace:FindFirstChild("TeleportZones") then
        -- Дополнительно можно проверить наличие зоны с BillboardGui
        for _, zone in pairs(Workspace.TeleportZones:GetChildren()) do
            if zone.Name == "TeleportZone" and zone:FindFirstChild("BillboardGui") then
                SetStatus("Режим: ЛОББИ (начинаю поиск игры...)")
                return "LOBBY"
            end
        end
    end
    
    -- Проверяем, есть ли характерные объекты игры
    if Workspace:FindFirstChild("RailSegments") and Workspace:FindFirstChild("RuntimeItems") then
        SetStatus("Режим: ИГРА (начинаю сбор бондов...)")
        return "GAME"
    end
    
    return "UNKNOWN"
end

-- ГЛАВНАЯ ЛОГИКА
local mode = DetermineMode()
SetStatus("Режим: " .. mode)

if mode == "LOBBY" then
    -- ========== КОД ДЛЯ ЛОББИ ==========
    local CreateParty = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CreatePartyClient")
    local FoundLobby = false
    
    while Farming and task.wait(Cooldown) do
        if not FoundLobby then
            for _, zone in pairs(Workspace.TeleportZones:GetChildren()) do
                if zone.Name == "TeleportZone" and zone:FindFirstChild("BillboardGui") then
                    local stateLabel = zone.BillboardGui:FindFirstChild("StateLabel")
                    if stateLabel and stateLabel.Text == "Waiting for players..." then
                        SetStatus("Лобби найдено, телепортируюсь...")
                        local hrp = GetHRP()
                        if hrp then
                            hrp.CFrame = zone.ZoneContainer.CFrame
                            FoundLobby = true
                            task.wait(1)
                            CreateParty:FireServer({["maxPlayers"] = 1})
                            SetStatus("Создаю игру...")
                        end
                    end
                end
            end
        end
    end

elseif mode == "GAME" then
    -- ========== КОД ДЛЯ ИГРЫ ==========
    local StartingTrack = Workspace.RailSegments:FindFirstChild("RailSegment")
    local CollectBond = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ActivateObjectClient")
    local Items = Workspace.RuntimeItems
    local TrackPassed = false

    -- Ждём персонажа
    repeat task.wait() until LocalPlayer.Character
    local hrp = GetHRP()
    if hrp then
        hrp.Anchored = true
    end

    SetStatus("Начинаю фарм. Трек 1")

    while Farming and task.wait(Cooldown) do
        -- Перемещение на новый трек
        if not TrackPassed then
            SetStatus(string.format("Перемещаюсь на трек %d", TrackCount))
            TrackPassed = true
        end

        hrp = GetHRP()
        if hrp and StartingTrack and StartingTrack:FindFirstChild("Guide") then
            hrp.CFrame = StartingTrack.Guide.CFrame + Vector3.new(0, 250, 0)
        end

        -- Переход на следующий трек
        if StartingTrack and StartingTrack:FindFirstChild("NextTrack") and StartingTrack.NextTrack.Value ~= nil then
            StartingTrack = StartingTrack.NextTrack.Value
            TrackCount = TrackCount + 1
            SetStatus("Трек " .. TrackCount)
        else
            SetStatus("Все треки пройдены! Возврат в лобби...")
            TeleportService:Teleport(game.PlaceId, LocalPlayer)  -- можно заменить на ID лобби, если знаешь
            break
        end

        -- Сбор бондов на текущем треке
        repeat
            for _, item in pairs(Items:GetChildren()) do
                if item.Name == "Bond" or item.Name == "BondCalculated" then
                    -- Телепорт бонда к игроку
                    if AutoTeleport and item:FindFirstChild("Part") then
                        spawn(function()
                            pcall(function()
                                item.Part.CFrame = hrp.CFrame
                            end)
                        end)
                    end
                    -- Активация сбора
                    spawn(function()
                        pcall(function()
                            CollectBond:FireServer(item)
                        end)
                    end)
                    -- Подсчёт
                    if item.Name == "Bond" then
                        BondCount = BondCount + 1
                        SetStatus(string.format("Собрано бондов: %d | Трек: %d", BondCount, TrackCount))
                        item.Name = "BondCalculated"
                    end
                end
            end
            task.wait()
        until Items:FindFirstChild("Bond") == nil

        TrackPassed = false
    end

else
    SetStatus("Это не Dead Rails (или структура изменилась). Скрипт не будет работать.")
    task.wait(5)
    if StatsGui then StatsGui:Destroy() end
end

-- Завершающее сообщение, если цикл вышел
SetStatus("Фарм завершён")
