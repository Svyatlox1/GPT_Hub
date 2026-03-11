--[[
    GPT Hub - Ultimate Version
    Включает функции для Escape Tsunami for Braintrot
    Автор: Твой ник
    ВНИМАНИЕ: Использование читов может привести к бану!
]]

-- Дождёмся полной загрузки игры
repeat wait() until game:IsLoaded()

-- Переменные окружения (можно менять через загрузчик)
local AUTOLOAD = getgenv().AUTOLOAD or "Tsunami"  -- автостарт режима

-- Сервисы Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Защита от повторного запуска
if _G.GPT_Hub_Loaded then return end
_G.GPT_Hub_Loaded = true

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local TabTsunami = Instance.new("TextButton")
local TabAI = Instance.new("TextButton")
local CloseBtn = Instance.new("TextButton")
local MinimizeBtn = Instance.new("TextButton")
local ContentFrame = Instance.new("Frame")

-- Настройка GUI
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true

-- Заголовок
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "GPT Hub 2.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20

-- Кнопка закрытия
CloseBtn.Parent = MainFrame
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Кнопка свернуть
MinimizeBtn.Parent = MainFrame
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
MinimizeBtn.Position = UDim2.new(1, -60, 0, 0)
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Text = "_"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.MouseButton1Click:Connect(function()
    ContentFrame.Visible = not ContentFrame.Visible
    MainFrame.Size = ContentFrame.Visible and UDim2.new(0, 500, 0, 400) or UDim2.new(0, 500, 0, 30)
end)

-- Вкладки
TabTsunami.Parent = MainFrame
TabTsunami.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TabTsunami.Position = UDim2.new(0, 10, 0, 35)
TabTsunami.Size = UDim2.new(0, 120, 0, 30)
TabTsunami.Font = Enum.Font.Gotham
TabTsunami.Text = "Tsunami"
TabTsunami.TextColor3 = Color3.fromRGB(255, 255, 255)

TabAI.Parent = MainFrame
TabAI.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TabAI.Position = UDim2.new(0, 140, 0, 35)
TabAI.Size = UDim2.new(0, 120, 0, 30)
TabAI.Font = Enum.Font.Gotham
TabAI.Text = "AI Create"
TabAI.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Контейнер для контента
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ContentFrame.Position = UDim2.new(0, 10, 0, 70)
ContentFrame.Size = UDim2.new(1, -20, 1, -80)

-- Функции для вкладок
local function ClearContent()
    for _, child in ipairs(ContentFrame:GetChildren()) do
        child:Destroy()
    end
end

-- ВКЛАДКА TSUNAMI ==========================================
local function CreateTsunamiTab()
    ClearContent()
    
    -- Заголовок
    local label = Instance.new("TextLabel")
    label.Parent = ContentFrame
    label.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    label.Size = UDim2.new(1, 0, 0, 30)
    label.Font = Enum.Font.GothamBold
    label.Text = "Escape Tsunami for Braintrot"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    -- Кнопка "Взлететь"
    local flyBtn = Instance.new("TextButton")
    flyBtn.Parent = ContentFrame
    flyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    flyBtn.Position = UDim2.new(0, 10, 0, 40)
    flyBtn.Size = UDim2.new(0, 150, 0, 30)
    flyBtn.Font = Enum.Font.Gotham
    flyBtn.Text = "Взлететь вверх"
    flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Velocity = Vector3.new(0, 150, 0)
        end
    end)
    
    -- Кнопка "Телепорт на крышу"
    local roofBtn = Instance.new("TextButton")
    roofBtn.Parent = ContentFrame
    roofBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    roofBtn.Position = UDim2.new(0, 170, 0, 40)
    roofBtn.Size = UDim2.new(0, 150, 0, 30)
    roofBtn.Font = Enum.Font.Gotham
    roofBtn.Text = "На крышу"
    roofBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    roofBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            -- Ищем высокую точку (пример: координаты выше)
            char.HumanoidRootPart.CFrame = CFrame.new(0, 500, 0)  -- подбери под игру
        end
    end)
    
    -- Кнопка "Суперскорость"
    local speedBtn = Instance.new("TextButton")
    speedBtn.Parent = ContentFrame
    speedBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    speedBtn.Position = UDim2.new(0, 10, 0, 80)
    speedBtn.Size = UDim2.new(0, 150, 0, 30)
    speedBtn.Font = Enum.Font.Gotham
    speedBtn.Text = "Суперскорость"
    speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 100
        end
    end)
    
    -- Кнопка "Бесконечные прыжки"
    local jumpBtn = Instance.new("TextButton")
    jumpBtn.Parent = ContentFrame
    jumpBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 200)
    jumpBtn.Position = UDim2.new(0, 170, 0, 80)
    jumpBtn.Size = UDim2.new(0, 150, 0, 30)
    jumpBtn.Font = Enum.Font.Gotham
    jumpBtn.Text = "Бесконечные прыжки"
    jumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpBtn.MouseButton1Click:Connect(function()
        LocalPlayer.Character.Humanoid.UseJumpPower = true
        LocalPlayer.Character.Humanoid.JumpPower = 150
    end)
    
    -- Чекбокс ESP (показывает игроков сквозь стены)
    local espEnabled = false
    local espBtn = Instance.new("TextButton")
    espBtn.Parent = ContentFrame
    espBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    espBtn.Position = UDim2.new(0, 10, 0, 120)
    espBtn.Size = UDim2.new(0, 310, 0, 30)
    espBtn.Font = Enum.Font.Gotham
    espBtn.Text = "ESP: ВЫКЛ"
    espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local espConnection
    espBtn.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        espBtn.Text = espEnabled and "ESP: ВКЛ" or "ESP: ВЫКЛ"
        if espEnabled then
            -- Простейший ESP через Highlight
            espConnection = RunService.RenderStepped:Connect(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local highlight = player.Character:FindFirstChildOfClass("Highlight")
                        if not highlight then
                            highlight = Instance.new("Highlight")
                            highlight.Parent = player.Character
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        end
                    end
                end
            end)
        else
            if espConnection then espConnection:Disconnect() end
            -- Убираем хайлайты
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    local highlight = player.Character:FindFirstChildOfClass("Highlight")
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end)
    
    -- Кнопка "Отключить всё"
    local resetBtn = Instance.new("TextButton")
    resetBtn.Parent = ContentFrame
    resetBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    resetBtn.Position = UDim2.new(0, 10, 0, 160)
    resetBtn.Size = UDim2.new(0, 310, 0, 30)
    resetBtn.Font = Enum.Font.Gotham
    resetBtn.Text = "Сброс настроек персонажа"
    resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
            char.Humanoid.JumpPower = 50
        end
        if espEnabled then
            espEnabled = false
            espBtn.Text = "ESP: ВЫКЛ"
            if espConnection then espConnection:Disconnect() end
        end
    end)
end

-- ВКЛАДКА AI CREATE ========================================
local function CreateAITab()
    ClearContent()
    
    -- Поле ввода
    local inputBox = Instance.new("TextBox")
    inputBox.Parent = ContentFrame
    inputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    inputBox.Position = UDim2.new(0, 10, 0, 10)
    inputBox.Size = UDim2.new(1, -20, 0, 80)
    inputBox.Font = Enum.Font.Gotham
    inputBox.PlaceholderText = "Опиши функцию, например: сделать телепорт к игроку"
    inputBox.Text = ""
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.TextWrapped = true
    inputBox.ClearTextOnFocus = false
    
    -- Кнопка генерации
    local generateBtn = Instance.new("TextButton")
    generateBtn.Parent = ContentFrame
    generateBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    generateBtn.Position = UDim2.new(0, 10, 0, 100)
    generateBtn.Size = UDim2.new(1, -20, 0, 30)
    generateBtn.Font = Enum.Font.Gotham
    generateBtn.Text = "Сгенерировать и выполнить"
    generateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    -- Поле вывода
    local outputBox = Instance.new("TextLabel")
    outputBox.Parent = ContentFrame
    outputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    outputBox.Position = UDim2.new(0, 10, 0, 140)
    outputBox.Size = UDim2.new(1, -20, 1, -150)
    outputBox.Font = Enum.Font.Code
    outputBox.Text = "Здесь появится сгенерированный код"
    outputBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    outputBox.TextWrapped = true
    outputBox.TextXAlignment = Enum.TextXAlignment.Left
    outputBox.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Обработка нажатия
    generateBtn.MouseButton1Click:Connect(function()
        local prompt = inputBox.Text
        if prompt == "" then
            outputBox.Text = "Введи описание!"
            return
        end
        
        outputBox.Text = "Генерирую..."
        
        -- Простая имитация ИИ (можно заменить на реальный API)
        local generatedCode
        local lowerPrompt = prompt:lower()
        
        if lowerPrompt:find("телепорт") and lowerPrompt:find("игрок") then
            generatedCode = [[
local player = game.Players.LocalPlayer
local target = game.Players:FindFirstChild("ИмяИгрока")
if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
    player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
end
]]
        elseif lowerPrompt:find("полет") then
            generatedCode = [[
local player = game.Players.LocalPlayer
local char = player.Character
if char and char:FindFirstChild("Humanoid") then
    char.Humanoid:ChangeState(Enum.HumanoidStateType.Flying)
end
]]
        elseif lowerPrompt:find("бессмертие") then
            generatedCode = [[
local player = game.Players.LocalPlayer
player.Character.Humanoid.MaxHealth = math.huge
player.Character.Humanoid.Health = math.huge
]]
        elseif lowerPrompt:find("скорость") then
            generatedCode = [[
game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 150
]]
        else
            generatedCode = "-- Не удалось распознать запрос. Попробуй точнее."
        end
        
        outputBox.Text = "Сгенерированный код:\n" .. generatedCode
        
        -- Безопасное выполнение
        local success, err = pcall(function()
            loadstring(generatedCode)()
        end)
        if not success then
            outputBox.Text = outputBox.Text .. "\n\nОшибка выполнения: " .. err
        else
            outputBox.Text = outputBox.Text .. "\n\nКод выполнен!"
        end
    end)
end

-- Переключение вкладок
TabTsunami.MouseButton1Click:Connect(CreateTsunamiTab)
TabAI.MouseButton1Click:Connect(CreateAITab)

-- Автозагрузка
if AUTOLOAD == "Tsunami" then
    CreateTsunamiTab()
else
    CreateTsunamiTab()  -- по умолчанию
end

print("GPT Hub загружен! Версия 1.0")
