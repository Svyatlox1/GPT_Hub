--[[
    Dead Rails Auto Farm Bonds (с экранной отладкой для Velocity)
]]

-- Создаём GUI прямо сейчас, чтобы видеть информацию до любой логики
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.CoreGui
screenGui.Name = "DebugInfo"

local frame = Instance.new("Frame")
frame.Parent = screenGui
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.Position = UDim2.new(0.35, 0, 0.4, 0)
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Active = true
frame.Draggable = true

local label = Instance.new("TextLabel")
label.Parent = frame
label.BackgroundTransparency = 1
label.Size = UDim2.new(1, 0, 1, 0)
label.Font = Enum.Font.GothamBold
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextSize = 18
label.TextWrapped = true
label.Text = "Получаем информацию..."

-- Получаем текущий PlaceId
local currentPlaceId = game.PlaceId

-- Обновляем текст в GUI
label.Text = "🔍 ТЕКУЩИЙ PlaceId:\n" .. currentPlaceId .. "\n\nЕсли это Dead Rails, скопируй число\nи отправь разработчику."

-- Добавляем кнопку для закрытия окна
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = frame
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Теперь можно добавить и остальную логику, но пока просто показываем ID
-- Чтобы скрипт не завершался сразу, ждём
task.wait(5)

-- Если хочешь, чтобы скрипт дальше пытался работать (с текущими ID), 
-- раскомментируй следующие строки (убери --)

--[[
local LOBBY_ID = 116495829188952  -- ← замени на число, которое увидишь
local GAME_ID = 70876832253163     -- ← замени на число, которое увидишь

if currentPlaceId == LOBBY_ID then
    -- вставь код лобби
elseif currentPlaceId == GAME_ID then
    -- вставь код игры
else
    label.Text = label.Text .. "\n\nЭто не лобби и не игра с этими ID."
end
--]]
