--[[
    99 Nights in the Forest - Auto Achievements
    Версия 1.0
    Автоматическое выполнение всех достижений (кроме 99 ночей)
    Автор: твой ник
]]

-- ========== НАСТРОЙКИ ==========
local Settings = {
    AutoStartGame = true,        -- автоматически начинать новую игру
    CheckInterval = 5,           -- проверка прогресса каждые 5 секунд
    FarmRadius = 30,             -- радиус сбора ресурсов
    WalkSpeed = 24,              -- скорость бега
    JumpPower = 70,               -- сила прыжка
    ShowUI = true                 -- показывать окно статуса
}

-- ========== СЕРВИСЫ ==========
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local BadgeService = game:GetService("BadgeService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ========== ПЕРЕМЕННЫЕ ==========
local CurrentPlan = {}            -- текущий список задач
local AchievementsDone = {}       -- уже выполненные достижения
local Farming = true
local StatsGui = nil
local StatusLabel = nil

-- ========== СПИСОК ВСЕХ ДОСТИЖЕНИЙ (ДОБАВЛЯЙ СВОИ) ==========
-- Формат: { id = "название", type = "ресурс/действие", target = количество }
-- type может быть: "wood", "stone", "berries", "kill", "craft", "build", "fuel"
local AchievementsList = {
    { id = "Дровосек", type = "wood", target = 50 },          -- нарубить 50 дерева
    { id = "Горняк", type = "stone", target = 30 },           -- добыть 30 камня
    { id = "Сладкоежка", type = "berries", target = 20 },      -- собрать 20 ягод
    { id = "Охотник", type = "kill", target = 10 },            -- убить 10 монстров
    { id = "Строитель", type = "build", target = 5 },          -- построить 5 сооружений
    { id = "Изобретатель", type = "craft", target = 3 },       -- создать 3 предмета
    { id = "Заправщик", type = "fuel", target = 15 },          -- собрать 15 топлива
    -- Добавь сюда другие достижения, которые есть в игре
}

-- ========== GUI ДЛЯ СТАТУСА ==========
if Settings.ShowUI then
    StatsGui = Instance.new("ScreenGui")
    StatsGui.Parent = game.CoreGui
    StatsGui.Name = "NinetyNineAchievements"

    local Frame = Instance.new("Frame")
    Frame.Parent = StatsGui
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BackgroundTransparency = 0.2
    Frame.Position = UDim2.new(0.02, 0, 0.02, 0)
    Frame.Size = UDim2.new(0, 300, 0, 150)
    Frame.Active = true
    Frame.Draggable = true

    local Title = Instance.new("TextLabel")
    Title.Parent = Frame
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "99 Nights - Achievements"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16

    StatusLabel = Instance.new("TextLabel")
    StatusLabel.Parent = Frame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 5, 0, 35)
    StatusLabel.Size = UDim2.new(1, -10, 1, -40)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "Инициализация..."
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.TextSize = 14
    StatusLabel.TextWrapped = true
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = Frame
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    CloseBtn.Position = UDim2.new(1, -25, 0, 5)
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 14
    CloseBtn.MouseButton1Click:Connect(function()
        StatsGui:Destroy()
    end)
end

-- Функция обновления статуса
local function SetStatus(text)
    if StatusLabel then
        StatusLabel.Text = text
    end
    print("[Achievements] " .. text)
end

-- ========== ПОЛУЧЕНИЕ ВЫПОЛНЕННЫХ ДОСТИЖЕНИЙ ==========
local function GetCompletedAchievements()
    local completed = {}
    -- Пробуем получить бейджи (если достижения реализованы как бейджи)
    pcall(function()
        local badges = BadgeService:GetAwardedBadgesAsync(LocalPlayer.UserId)
        for _, badge in ipairs(badges) do
            completed[badge.Name] = true
        end
    end)
    
    -- Если бейджей нет, ищем другие индикаторы (например, в leaderstats)
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        for _, stat in ipairs(leaderstats:GetChildren()) do
            if stat:IsA("IntValue") and stat.Name:match("achieve") then
                -- Допустим, значение 1 означает выполнение
                if stat.Value >= 1 then
                    completed[stat.Name] = true
                end
            end
        end
    end
    
    return completed
end

-- ========== ПРОВЕРКА, КАКИЕ ДОСТИЖЕНИЯ ЕЩЁ НУЖНО СДЕЛАТЬ ==========
local function GetPendingAchievements()
    local completed = GetCompletedAchievements()
    local pending = {}
    for _, ach in ipairs(AchievementsList) do
        if not completed[ach.id] then
            table.insert(pending, ach)
        end
    end
    return pending
end

-- ========== СОСТАВЛЕНИЕ ПЛАНА ДЕЙСТВИЙ ==========
local function MakePlan()
    local pending = GetPendingAchievements()
    local plan = {}
    for _, ach in ipairs(pending) do
        -- В зависимости от типа достижения добавляем соответствующую задачу
        local task = {
            type = ach.type,
            target = ach.target,
            current = 0,          -- будет обновляться
            description = ach.id
        }
        table.insert(plan, task)
    end
    return plan
end

-- ========== ФУНКЦИИ ДЛЯ ВЫПОЛНЕНИЯ ЗАДАЧ ==========

-- Получить корневую часть персонажа
local function GetHRP()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart
    end
    return nil
end

-- Телепорт к ближайшему объекту по имени
local function TeleportToNearest(namePattern)
    local hrp = GetHRP()
    if not hrp then return end
    local nearest = nil
    local minDist = math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.PrimaryPart and obj.Name:match(namePattern) then
            local dist = (obj.PrimaryPart.Position - hrp.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = obj
            end
        end
    end
    if nearest and nearest.PrimaryPart then
        hrp.CFrame = nearest.PrimaryPart.CFrame * CFrame.new(0, 2, 3)
        return true
    end
    return false
end

-- Сбор ресурса (дерево, камень, ягоды и т.п.)
local function CollectResource(resourceType)
    local pattern
    if resourceType == "wood" then
        pattern = "Tree"
    elseif resourceType == "stone" then
        pattern = "Rock"
    elseif resourceType == "berries" then
        pattern = "Berry"
    elseif resourceType == "fuel" then
        pattern = "Fuel"
    else
        return false
    end
    
    if TeleportToNearest(pattern) then
        wait(0.5)
        -- Имитация удара/сбора (нажатие мыши)
        mouse1press()
        wait(0.2)
        mouse1release()
        return true
    end
    return false
end

-- Охота на монстров
local function HuntMonsters()
    local hrp = GetHRP()
    if not hrp then return false end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= LocalPlayer.Character then
            local targetHRP = obj:FindFirstChild("HumanoidRootPart")
            if targetHRP and (targetHRP.Position - hrp.Position).Magnitude < Settings.FarmRadius then
                hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 5)
                wait(0.3)
                -- Атака
                mouse1press()
                wait(0.2)
                mouse1release()
                return true
            end
        end
    end
    return false
end

-- Строительство (если есть возможность)
local function BuildSomething()
    -- В зависимости от игры, здесь может быть код для автоматического строительства
    -- Например, открыть инвентарь, выбрать постройку и разместить
    SetStatus("Пытаюсь построить...")
    -- Заглушка
    return false
end

-- Крафт предметов
local function CraftSomething()
    -- Заглушка для крафта
    SetStatus("Пытаюсь скрафтить...")
    return false
end

-- ========== ГЛАВНЫЙ ЦИКЛ ВЫПОЛНЕНИЯ ==========
local function MainLoop()
    SetStatus("Получаю список достижений...")
    CurrentPlan = MakePlan()
    
    if #CurrentPlan == 0 then
        SetStatus("Все достижения уже выполнены! Скрипт завершён.")
        Farming = false
        return
    end
    
    SetStatus("Нужно выполнить " .. #CurrentPlan .. " достижений")
    
    -- Основной цикл фарма
    while Farming do
        -- Обновляем план (вдруг какие-то достижения уже сделаны)
        CurrentPlan = MakePlan()
        if #CurrentPlan == 0 then
            SetStatus("Все достижения выполнены! Ура!")
            break
        end
        
        -- Берём первую задачу из плана
        local task = CurrentPlan[1]
        SetStatus("Выполняю: " .. task.description .. " (" .. task.type .. ")")
        
        -- Выполняем действие в зависимости от типа
        local success = false
        if task.type == "wood" or task.type == "stone" or task.type == "berries" or task.type == "fuel" then
            success = CollectResource(task.type)
        elseif task.type == "kill" then
            success = HuntMonsters()
        elseif task.type == "build" then
            success = BuildSomething()
        elseif task.type == "craft" then
            success = CraftSomething()
        end
        
        -- Если не удалось найти объект для сбора, идём дальше (может, их пока нет)
        if not success then
            SetStatus("Не могу найти объект для " .. task.type .. ", жду...")
            wait(2)
        end
        
        wait(Settings.CheckInterval)
    end
    
    SetStatus("Фарм завершён")
end

-- ========== ЗАПУСК В ЛОББИ ИЛИ В ИГРЕ ==========
-- Проверяем, находимся ли мы в игре (по наличию характерных объектов)
local function IsInGame()
    return Workspace:FindFirstChild("Trees") ~= nil or Workspace:FindFirstChild("Resources") ~= nil
end

-- Запуск новой игры (если в лобби)
local function StartNewGame()
    SetStatus("В лобби, ищу кнопку старта...")
    -- Ищем GUI с кнопкой Play/Start
    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, btn in ipairs(gui:GetDescendants()) do
                if btn:IsA("TextButton") and (btn.Text:match("Play") or btn.Text:match("Start") or btn.Text:match("Играть")) then
                    btn:Click()
                    SetStatus("Запускаю игру...")
                    wait(3)
                    return true
                end
            end
        end
    end
    return false
end

-- Главная функция
local function Initialize()
    SetStatus("Скрипт загружен. Определяю местоположение...")
    
    -- Если в лобби и нужно автостартовать
    if not IsInGame() and Settings.AutoStartGame then
        StartNewGame()
        -- Ждём загрузки игры
        repeat wait(1) until IsInGame()
    end
    
    -- Ждём появления персонажа
    repeat wait(1) until LocalPlayer.Character
    
    -- Устанавливаем скорость
    LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
    LocalPlayer.Character.Humanoid.JumpPower = Settings.JumpPower
    
    -- Запускаем основной цикл
    MainLoop()
end

-- Запуск с защитой от ошибок
pcall(Initialize)

-- Остановка по F6
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F6 then
        Farming = false
        SetStatus("Остановлено пользователем")
    end
end)

print("✅ 99 Nights Achievements Loaded")
print("🛑 Нажми F6 для остановки")
