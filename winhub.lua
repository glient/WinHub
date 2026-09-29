--[[
    ⚡ Win Hub v13.0 — Atmospheric Edition
    Universal + MM2 | Key System + Glassmorphism UI
    Ключи: t.me/keyhubwin
--]]

if _G.WinHubV13 then return end
_G.WinHubV13 = true

-- ============ 🔑 KEY SYSTEM ============
local SECRET = "WIN" .. "HUB" .. "_X9" .. "K2_" .. "2025"
local KEY_FILE = "winhub_v13_key.txt"
local TG_LINK = "t.me/keyhubwin"
local TG_FULL = "https://" .. TG_LINK

-- DJB2 hash
local function djb2(str)
    local h = 5381
    for i = 1, #str do
        h = (h * 33 + str:byte(i)) % 4294967296
    end
    return h
end

local function hashToHex(h)
    return string.format("%08X", h)
end

local function toBase36(n)
    local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local res = ""
    n = math.floor(n)
    if n == 0 then return "0" end
    while n > 0 do
        local d = n % 36
        res = digits:sub(d + 1, d + 1) .. res
        n = math.floor(n / 36)
    end
    return res
end

local function fromBase36(str)
    local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local val = 0
    str = str:upper()
    for i = 1, #str do
        local c = str:sub(i, i)
        local d = digits:find(c, 1, true)
        if not d then return nil end
        val = val * 36 + (d - 1)
    end
    return val
end

local function ValidateKey(key, playerName)
    if not key or key == "" then return false, "Пустой ключ" end
    local parts = {}
    for p in key:gmatch("[^-]+") do
        table.insert(parts, p)
    end
    if #parts ~= 4 then return false, "Неверный формат" end
    if parts[1] ~= "WH" then return false, "Не тот префикс" end

    local nickHex = parts[2]
    local timeCode = parts[3]
    local signCode = parts[4]

    local expectedHex = hashToHex(djb2(playerName:lower()))
    if nickHex ~= expectedHex then
        return false, "Ключ не для этого ника"
    end

    local expireAt = fromBase36(timeCode)
    if not expireAt then return false, "Битое время" end
    if expireAt < os.time() then
        return false, "Ключ истёк"
    end

    local expectedSign = toBase36(djb2(nickHex .. timeCode .. SECRET))
    expectedSign = expectedSign:sub(1, 6)
    if signCode:upper() ~= expectedSign then
        return false, "Подпись неверна"
    end

    return true, "OK"
end

local function HasValidSavedKey(playerName)
    if not (isfile and readfile) then return false end
    local ok, content = pcall(function()
        if isfile(KEY_FILE) then return readfile(KEY_FILE) end
    end)
    if ok and content and content ~= "" then
        local clean = tostring(content):gsub("%s", "")
        local valid = ValidateKey(clean, playerName)
        return valid
    end
    return false
end

local function SaveValidKey(key)
    if writefile then
        pcall(function() writefile(KEY_FILE, key) end)
    end
end

-- ============ СЕРВИСЫ ============
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local SGService = game:GetService("StarterGui")

local LP = Players.LocalPlayer
local Cam = Workspace.CurrentCamera
local IsMM2 = game.PlaceId == 142823291
-- ============ КЛЮЧ-ЭКРАН ============
local function ShowKeyUI(onSuccess)
    local KS = Instance.new("ScreenGui")
    KS.Name = "WinHubKeyScreen"
    KS.IgnoreGuiInset = true
    KS.ResetOnSpawn = false
    KS.Parent = game.CoreGui

    local BGFrame = Instance.new("Frame")
    BGFrame.Size = UDim2.new(1, 0, 1, 0)
    BGFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
    BGFrame.BorderSizePixel = 0
    BGFrame.Parent = KS

    -- Плавающие свечения
    local G1 = Instance.new("Frame", BGFrame)
    G1.Size = UDim2.new(0, 400, 0, 400)
    G1.Position = UDim2.new(0.1, -200, 0.2, -200)
    G1.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
    G1.BackgroundTransparency = 0.85
    G1.BorderSizePixel = 0
    Instance.new("UICorner", G1).CornerRadius = UDim.new(1, 0)

    local G2 = Instance.new("Frame", BGFrame)
    G2.Size = UDim2.new(0, 400, 0, 400)
    G2.Position = UDim2.new(0.9, -200, 0.8, -200)
    G2.BackgroundColor3 = Color3.fromRGB(255, 90, 180)
    G2.BackgroundTransparency = 0.85
    G2.BorderSizePixel = 0
    Instance.new("UICorner", G2).CornerRadius = UDim.new(1, 0)

    -- Анимация
    task.spawn(function()
        while BGFrame.Parent do
            Tween:Create(G1, TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0.3, -200, 0.4, -200)
            }):Play()
            Tween:Create(G2, TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0.7, -200, 0.6, -200)
            }):Play()
            task.wait(6)
            Tween:Create(G1, TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0.1, -200, 0.2, -200)
            }):Play()
            Tween:Create(G2, TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(0.9, -200, 0.8, -200)
            }):Play()
            task.wait(6)
        end
    end)

    local Panel = Instance.new("Frame")
    Panel.Size = UDim2.new(0, 340, 0, 380)
    Panel.Position = UDim2.new(0.5, -170, 0.5, -190)
    Panel.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
    Panel.BackgroundTransparency = 0.1
    Panel.BorderSizePixel = 0
    Panel.Parent = KS
    Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 20)

    local PStroke = Instance.new("UIStroke", Panel)
    PStroke.Color = Color3.fromRGB(140, 100, 255)
    PStroke.Thickness = 2
    PStroke.Transparency = 0.3

    local PGrad = Instance.new("UIGradient", Panel)
    PGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 15, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 22)),
    })
    PGrad.Rotation = 135

    local Logo = Instance.new("TextLabel")
    Logo.Size = UDim2.new(1, 0, 0, 50)
    Logo.Position = UDim2.new(0, 0, 0, 15)
    Logo.BackgroundTransparency = 1
    Logo.Text = "⚡"
    Logo.TextSize = 40
    Logo.Font = Enum.Font.GothamBold
    Logo.TextColor3 = Color3.fromRGB(140, 100, 255)
    Logo.Parent = Panel

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0, 67)
    Title.BackgroundTransparency = 1
    Title.Text = "WIN HUB"
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Color3.fromRGB(240, 240, 250)
    Title.Parent = Panel

    local NickLbl = Instance.new("TextLabel")
    NickLbl.Size = UDim2.new(1, 0, 0, 18)
    NickLbl.Position = UDim2.new(0, 0, 0, 95)
    NickLbl.BackgroundTransparency = 1
    NickLbl.Text = "👤 " .. LP.Name
    NickLbl.TextSize = 11
    NickLbl.Font = Enum.Font.GothamMedium
    NickLbl.TextColor3 = Color3.fromRGB(140, 100, 255)
    NickLbl.Parent = Panel

    local TgBtn = Instance.new("TextButton")
    TgBtn.Size = UDim2.new(1, -60, 0, 44)
    TgBtn.Position = UDim2.new(0, 30, 0, 122)
    TgBtn.BackgroundColor3 = Color3.fromRGB(40, 130, 200)
    TgBtn.Text = "📱 Получить ключ в Telegram"
    TgBtn.TextColor3 = Color3.new(1, 1, 1)
    TgBtn.Font = Enum.Font.GothamBold
    TgBtn.TextSize = 13
    TgBtn.AutoButtonColor = false
    TgBtn.BorderSizePixel = 0
    TgBtn.Parent = Panel
    Instance.new("UICorner", TgBtn).CornerRadius = UDim.new(0, 12)

    local LinkLbl = Instance.new("TextLabel")
    LinkLbl.Size = UDim2.new(1, 0, 0, 16)
    LinkLbl.Position = UDim2.new(0, 0, 0, 170)
    LinkLbl.BackgroundTransparency = 1
    LinkLbl.Text = TG_LINK
    LinkLbl.TextSize = 10
    LinkLbl.Font = Enum.Font.Gotham
    LinkLbl.TextColor3 = Color3.fromRGB(100, 160, 220)
    LinkLbl.Parent = Panel

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -60, 0, 46)
    Box.Position = UDim2.new(0, 30, 0, 195)
    Box.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
    Box.PlaceholderText = "Вставь ключ сюда..."
    Box.Text = ""
    Box.TextColor3 = Color3.fromRGB(240, 240, 250)
    Box.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    Box.Font = Enum.Font.GothamMedium
    Box.TextSize = 13
    Box.BorderSizePixel = 0
    Box.ClearTextOnFocus = false
    Box.Parent = Panel
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 12)

    local BStroke = Instance.new("UIStroke", Box)
    BStroke.Color = Color3.fromRGB(140, 100, 255)
    BStroke.Thickness = 1
    BStroke.Transparency = 0.5

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -60, 0, 46)
    Btn.Position = UDim2.new(0, 30, 0, 253)
    Btn.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
    Btn.Text = "ВОЙТИ"
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.AutoButtonColor = false
    Btn.BorderSizePixel = 0
    Btn.Parent = Panel
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 12)

    local BGrad = Instance.new("UIGradient", Btn)
    BGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 100, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 90, 180)),
    })

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, 0, 0, 20)
    Status.Position = UDim2.new(0, 0, 0, 308)
    Status.BackgroundTransparency = 1
    Status.Text = ""
    Status.TextSize = 11
    Status.Font = Enum.Font.GothamMedium
    Status.TextColor3 = Color3.fromRGB(240, 80, 90)
    Status.Parent = Panel

    local Hint = Instance.new("TextLabel")
    Hint.Size = UDim2.new(1, 0, 0, 20)
    Hint.Position = UDim2.new(0, 0, 0, 332)
    Hint.BackgroundTransparency = 1
    Hint.Text = "Ключ выдаётся бесплатно в Telegram"
    Hint.TextSize = 10
    Hint.Font = Enum.Font.Gotham
    Hint.TextColor3 = Color3.fromRGB(100, 100, 120)
    Hint.Parent = Panel

    TgBtn.MouseEnter:Connect(function()
        Tween:Create(TgBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 150, 220)}):Play()
    end)
    TgBtn.MouseLeave:Connect(function()
        Tween:Create(TgBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 130, 200)}):Play()
    end)

    TgBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            pcall(function() setclipboard(TG_FULL) end)
        end
        local opened = false
        pcall(function()
            if shell and shell.open then
                shell.open(TG_FULL)
                opened = true
            end
        end)
        if not opened then
            Status.Text = "✓ Ссылка скопирована"
            Status.TextColor3 = Color3.fromRGB(70, 220, 130)
            LinkLbl.Text = "🔗 вставь в браузер: " .. TG_LINK
            task.delay(3, function()
                if Status.Parent then
                    Status.Text = ""
                    LinkLbl.Text = TG_LINK
                end
            end)
        end
    end)

    LinkLbl.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if setclipboard then
                pcall(function() setclipboard(TG_FULL) end)
            end
            Status.Text = "✓ Ссылка скопирована"
            Status.TextColor3 = Color3.fromRGB(70, 220, 130)
            task.delay(2, function()
                if Status.Parent then Status.Text = "" end
            end)
        end
    end)

    Btn.MouseEnter:Connect(function()
        Tween:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(160, 120, 255)}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        Tween:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(140, 100, 255)}):Play()
    end)

    local function TryKey()
        local input = Box.Text
        if not input or input == "" then
            Status.Text = "⚠️ Введи ключ"
            Status.TextColor3 = Color3.fromRGB(240, 80, 90)
            return
        end
        local clean = input:gsub("%s", "")
        local ok, msg = ValidateKey(clean, LP.Name)
        if ok then
            SaveValidKey(clean)
            Status.Text = "✓ Ключ принят!"
            Status.TextColor3 = Color3.fromRGB(70, 220, 130)
            task.wait(0.6)
            KS:Destroy()
            onSuccess()
        else
            Status.Text = "✗ " .. msg
            Status.TextColor3 = Color3.fromRGB(240, 80, 90)
            Box.Text = ""
        end
    end

    Btn.MouseButton1Click:Connect(TryKey)
    Box.FocusLost:Connect(function(enter)
        if enter then TryKey() end
    end)
end
-- ============ ГЛАВНЫЙ ХАБ ============
local function LoadHub()
    local Palette = {
        A1 = Color3.fromRGB(140, 100, 255),
        A2 = Color3.fromRGB(255, 90, 180),
        A3 = Color3.fromRGB(70, 180, 255),
        BG1 = Color3.fromRGB(10, 10, 20),
        BG2 = Color3.fromRGB(18, 15, 35),
        BG3 = Color3.fromRGB(25, 20, 45),
        Text = Color3.fromRGB(240, 240, 250),
        Sub = Color3.fromRGB(160, 160, 190),
        Green = Color3.fromRGB(70, 220, 130),
        Red = Color3.fromRGB(240, 80, 90),
        Yellow = Color3.fromRGB(255, 200, 60),
    }

    local function Notify(t, txt, dur)
        pcall(function()
            SGService:SetCore("SendNotification", {
                Title = "⚡ " .. tostring(t),
                Text = tostring(txt or ""),
                Duration = dur or 3
            })
        end)
    end

    local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WinHubV13"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

    -- Плавающие кнопки Fly
    local FlyUp = Instance.new("TextButton")
    FlyUp.Size = UDim2.new(0, 44, 0, 44)
    FlyUp.Position = UDim2.new(1, -110, 0.62, 0)
    FlyUp.BackgroundColor3 = Palette.A1
    FlyUp.BackgroundTransparency = 0.15
    FlyUp.Text = "▲"
    FlyUp.TextColor3 = Color3.new(1,1,1)
    FlyUp.Font = Enum.Font.GothamBold
    FlyUp.TextSize = 20
    FlyUp.AutoButtonColor = false
    FlyUp.BorderSizePixel = 0
    FlyUp.Visible = false
    FlyUp.ZIndex = 100
    FlyUp.Parent = ScreenGui
    Instance.new("UICorner", FlyUp).CornerRadius = UDim.new(1, 0)

    local FlyDown = Instance.new("TextButton")
    FlyDown.Size = UDim2.new(0, 44, 0, 44)
    FlyDown.Position = UDim2.new(1, -110, 0.79, 0)
    FlyDown.BackgroundColor3 = Palette.A1
    FlyDown.BackgroundTransparency = 0.15
    FlyDown.Text = "▼"
    FlyDown.TextColor3 = Color3.new(1,1,1)
    FlyDown.Font = Enum.Font.GothamBold
    FlyDown.TextSize = 20
    FlyDown.AutoButtonColor = false
    FlyDown.BorderSizePixel = 0
    FlyDown.Visible = false
    FlyDown.ZIndex = 100
    FlyDown.Parent = ScreenGui
    Instance.new("UICorner", FlyDown).CornerRadius = UDim.new(1, 0)

    local fUp, fDown = false, false
    FlyUp.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then fUp = true end
    end)
    FlyUp.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then fUp = false end
    end)
    FlyDown.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then fDown = true end
    end)
    FlyDown.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then fDown = false end
    end)

    -- FreeCam кнопки
    local FreeCamButtons = Instance.new("Frame")
    FreeCamButtons.Size = UDim2.new(0, 160, 0, 160)
    FreeCamButtons.Position = UDim2.new(1, -180, 1, -180)
    FreeCamButtons.BackgroundTransparency = 1
    FreeCamButtons.Visible = false
    FreeCamButtons.ZIndex = 100
    FreeCamButtons.Parent = ScreenGui

    local function MakeCamBtn(text, pos)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 48, 0, 48)
        b.Position = pos
        b.BackgroundColor3 = Palette.A1
        b.BackgroundTransparency = 0.25
        b.Text = text
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 20
        b.AutoButtonColor = false
        b.BorderSizePixel = 0
        b.Parent = FreeCamButtons
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
        local p = false
        b.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then p = true end
        end)
        b.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then p = false end
        end)
        return function() return p end
    end

    local CamW = MakeCamBtn("▲", UDim2.new(0, 56, 0, 0))
    local CamS = MakeCamBtn("▼", UDim2.new(0, 56, 0, 112))
    local CamA = MakeCamBtn("◀", UDim2.new(0, 0, 0, 56))
    local CamD = MakeCamBtn("▶", UDim2.new(0, 112, 0, 56))
  -- Главное окно
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 500, 0, 400)
Main.Position = UDim2.new(0.5, -250, 0.5, -200)
Main.BackgroundColor3 = Palette.BG2
Main.BackgroundTransparency = 0.15
Main.BorderSizePixel = 0
Main.Visible = true
Main.Active = true
Main.ClipsDescendants = true
Main.ZIndex = 10
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 20)

local MainGlow = Instance.new("UIStroke", Main)
MainGlow.Color = Palette.A1
MainGlow.Thickness = 2
MainGlow.Transparency = 0.2

local MainGrad = Instance.new("UIGradient", Main)
MainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 20, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 30)),
})
MainGrad.Rotation = 135

task.spawn(function()
    while Main.Parent do
        Tween:Create(MainGlow, TweenInfo.new(2, Enum.EasingStyle.Sine), {Transparency = 0.55}):Play()
        task.wait(2)
        Tween:Create(MainGlow, TweenInfo.new(2, Enum.EasingStyle.Sine), {Transparency = 0.15}):Play()
        task.wait(2)
    end
end)

-- Заголовок
local Title = Instance.new("Frame")
Title.Size = UDim2.new(1, 0, 0, 52)
Title.BackgroundColor3 = Palette.A1
Title.BackgroundTransparency = 0.9
Title.BorderSizePixel = 0
Title.ZIndex = 15
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 20)

local TMask = Instance.new("Frame")
TMask.Size = UDim2.new(1, 0, 0, 20)
TMask.Position = UDim2.new(0, 0, 1, -20)
TMask.BackgroundColor3 = Palette.BG2
TMask.BackgroundTransparency = 0.15
TMask.BorderSizePixel = 0
TMask.ZIndex = 15
TMask.Parent = Title

local Logo = Instance.new("Frame")
Logo.Size = UDim2.new(0, 36, 0, 36)
Logo.Position = UDim2.new(0, 14, 0, 8)
Logo.BackgroundColor3 = Palette.A1
Logo.BorderSizePixel = 0
Logo.ZIndex = 20
Logo.Parent = Title
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 10)

local LogoGrad = Instance.new("UIGradient", Logo)
LogoGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Palette.A1),
    ColorSequenceKeypoint.new(0.5, Palette.A2),
    ColorSequenceKeypoint.new(1, Palette.A3),
})
LogoGrad.Rotation = 45

local LogoIcon = Instance.new("TextLabel")
LogoIcon.Size = UDim2.new(1, 0, 1, 0)
LogoIcon.BackgroundTransparency = 1
LogoIcon.Text = "⚡"
LogoIcon.TextColor3 = Color3.new(1,1,1)
LogoIcon.TextSize = 20
LogoIcon.Font = Enum.Font.GothamBold
LogoIcon.ZIndex = 21
LogoIcon.Parent = Logo

task.spawn(function()
    while Logo.Parent do
        Tween:Create(Logo, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
            Size = UDim2.new(0, 40, 0, 40),
            Position = UDim2.new(0, 12, 0, 6),
        }):Play()
        task.wait(1.5)
        Tween:Create(Logo, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
            Size = UDim2.new(0, 36, 0, 36),
            Position = UDim2.new(0, 14, 0, 8),
        }):Play()
        task.wait(1.5)
    end
end)

local TitleTxt = Instance.new("TextLabel")
TitleTxt.Size = UDim2.new(1, -140, 1, 0)
TitleTxt.Position = UDim2.new(0, 58, 0, 0)
TitleTxt.BackgroundTransparency = 1
TitleTxt.Text = "WIN HUB v13" .. (IsMM2 and "  •  MM2" or "")
TitleTxt.TextColor3 = Palette.Text
TitleTxt.Font = Enum.Font.GothamBold
TitleTxt.TextSize = 15
TitleTxt.TextXAlignment = Enum.TextXAlignment.Left
TitleTxt.ZIndex = 20
TitleTxt.Parent = Title

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 11)
MinBtn.BackgroundColor3 = Palette.BG3
MinBtn.BackgroundTransparency = 0.3
MinBtn.Text = "—"
MinBtn.TextColor3 = Palette.Text
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.AutoButtonColor = false
MinBtn.BorderSizePixel = 0
MinBtn.ZIndex = 20
MinBtn.Parent = Title
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -36, 0, 11)
CloseBtn.BackgroundColor3 = Palette.Red
CloseBtn.BackgroundTransparency = 0.1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.AutoButtonColor = false
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 20
CloseBtn.Parent = Title
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -66)
Sidebar.Position = UDim2.new(0, 8, 0, 58)
Sidebar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Sidebar.BackgroundTransparency = 0.94
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 12
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 14)

local SideStroke = Instance.new("UIStroke", Sidebar)
SideStroke.Color = Palette.A1
SideStroke.Thickness = 1
SideStroke.Transparency = 0.7

local SL = Instance.new("UIListLayout", Sidebar)
SL.Padding = UDim.new(0, 5)
SL.SortOrder = Enum.SortOrder.LayoutOrder
local SP = Instance.new("UIPadding", Sidebar)
SP.PaddingTop = UDim.new(0, 10)
SP.PaddingLeft = UDim.new(0, 8)
SP.PaddingRight = UDim.new(0, 8)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -150, 1, -66)
Content.Position = UDim2.new(0, 142, 0, 58)
Content.BackgroundTransparency = 1
Content.ZIndex = 12
Content.Parent = Main

-- ============ КОМПОНЕНТЫ ============
local tabs, activeTab = {}, nil

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Palette.BG3
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. icon .. "  " .. name
    btn.TextColor3 = Palette.Sub
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ZIndex = 13
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local scr = Instance.new("ScrollingFrame")
    scr.Size = UDim2.new(1, 0, 1, 0)
    scr.BackgroundTransparency = 1
    scr.BorderSizePixel = 0
    scr.ScrollBarThickness = 3
    scr.ScrollBarImageColor3 = Palette.A1
    scr.CanvasSize = UDim2.new(0, 0, 0, 0)
    scr.Visible = false
    scr.ZIndex = 13
    scr.Parent = Content

    local list = Instance.new("UIListLayout", scr)
    list.Padding = UDim.new(0, 6)
    local pad = Instance.new("UIPadding", scr)
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingTop = UDim.new(0, 2)

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scr.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
    end)

    local t = {Btn = btn, Scroll = scr, Name = name}
    tabs[name] = t

    btn.MouseEnter:Connect(function()
        if activeTab ~= t then
            Tween:Create(btn, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.85, BackgroundColor3 = Palette.A1
            }):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= t then
            Tween:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function()
        if activeTab == t then return end
        if activeTab then
            activeTab.Scroll.Visible = false
            Tween:Create(activeTab.Btn, TweenInfo.new(0.25), {
                BackgroundTransparency = 1, TextColor3 = Palette.Sub
            }):Play()
        end
        activeTab = t
        t.Scroll.Visible = true
        Tween:Create(t.Btn, TweenInfo.new(0.25), {
            BackgroundTransparency = 0.15, TextColor3 = Color3.new(1,1,1)
        }):Play()
    end)
    return t
end

local function Section(parent, text)
    local s = Instance.new("TextLabel")
    s.Size = UDim2.new(1, 0, 0, 22)
    s.BackgroundTransparency = 1
    s.Text = "  ◆ " .. text
    s.TextColor3 = Palette.A2
    s.Font = Enum.Font.GothamBold
    s.TextSize = 11
    s.TextXAlignment = Enum.TextXAlignment.Left
    s.ZIndex = 13
    s.Parent = parent
end

local function CreateToggle(parent, text, def, cb)
    local state = def or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Palette.BG3
    btn.BackgroundTransparency = 0.3
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ZIndex = 13
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    local st = Instance.new("UIStroke", btn)
    st.Color = Palette.A1; st.Thickness = 1; st.Transparency = 0.6

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -55, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Palette.Text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 14
    lbl.Parent = btn

    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 36, 0, 20)
    ind.Position = UDim2.new(1, -48, 0.5, -10)
    ind.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    ind.BorderSizePixel = 0
    ind.ZIndex = 14
    ind.Parent = btn
    Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)

    local circ = Instance.new("Frame")
    circ.Size = UDim2.new(0, 16, 0, 16)
    circ.Position = UDim2.new(0, 2, 0.5, -8)
    circ.BackgroundColor3 = Color3.fromRGB(200, 200, 215)
    circ.BorderSizePixel = 0
    circ.ZIndex = 15
    circ.Parent = ind
    Instance.new("UICorner", circ).CornerRadius = UDim.new(1, 0)

    local function upd()
        if state then
            Tween:Create(ind, TweenInfo.new(0.25), {BackgroundColor3 = Palette.Green}):Play()
            Tween:Create(circ, TweenInfo.new(0.25), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
            Tween:Create(st, TweenInfo.new(0.25), {Color = Palette.Green, Transparency = 0.15}):Play()
        else
            Tween:Create(ind, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(55, 55, 75)}):Play()
            Tween:Create(circ, TweenInfo.new(0.25), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
            Tween:Create(st, TweenInfo.new(0.25), {Color = Palette.A1, Transparency = 0.6}):Play()
        end
    end
    upd()

    btn.MouseEnter:Connect(function()
        Tween:Create(btn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.15, BackgroundColor3 = Palette.A1
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        Tween:Create(btn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.3, BackgroundColor3 = Palette.BG3
        }):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        state = not state; upd(); pcall(cb, state)
    end)
    return {Set = function(v) state = v; upd() end}
end

local function CreateButton(parent, text, cb, col)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 42)
    b.BackgroundColor3 = Palette.BG3
    b.BackgroundTransparency = 0.3
    b.Text = "  " .. text
    b.TextColor3 = Palette.Text
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.ZIndex = 13
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)

    local s = Instance.new("UIStroke", b)
    s.Color = col or Palette.A1; s.Thickness = 1; s.Transparency = 0.6

    b.MouseEnter:Connect(function()
        Tween:Create(b, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.05, BackgroundColor3 = col or Palette.A1
        }):Play()
        Tween:Create(s, TweenInfo.new(0.2), {Transparency = 0}):Play()
    end)
    b.MouseLeave:Connect(function()
        Tween:Create(b, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.3, BackgroundColor3 = Palette.BG3
        }):Play()
        Tween:Create(s, TweenInfo.new(0.2), {Transparency = 0.6}):Play()
    end)
    b.MouseButton1Click:Connect(function() pcall(cb) end)
    return b
end

local function CreateSlider(parent, text, min, max, def, cb)
    local sld = Instance.new("Frame")
    sld.Size = UDim2.new(1, 0, 0, 50)
    sld.BackgroundColor3 = Palette.BG3
    sld.BackgroundTransparency = 0.3
    sld.BorderSizePixel = 0
    sld.ZIndex = 13
    sld.Parent = parent
    Instance.new("UICorner", sld).CornerRadius = UDim.new(0, 12)

    local st = Instance.new("UIStroke", sld)
    st.Color = Palette.A1; st.Thickness = 1; st.Transparency = 0.6

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 22)
    lbl.Position = UDim2.new(0, 14, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. def
    lbl.TextColor3 = Palette.Text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 14
    lbl.Parent = sld

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -28, 0, 6)
    bar.Position = UDim2.new(0, 14, 0, 32)
    bar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    bar.BorderSizePixel = 0
    bar.ZIndex = 14
    bar.Parent = sld
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Palette.A1
    fill.BorderSizePixel = 0
    fill.ZIndex = 15
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local fg = Instance.new("UIGradient", fill)
    fg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Palette.A1),
        ColorSequenceKeypoint.new(1, Palette.A2),
    })

    local click = Instance.new("TextButton")
    click.Size = UDim2.new(1, 0, 1, 0)
    click.BackgroundTransparency = 1
    click.Text = ""
    click.ZIndex = 16
    click.Parent = bar

    local dragging = false
    local function upd(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * pos)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        lbl.Text = text .. ": " .. v
        pcall(cb, v)
    end
    click.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; upd(i)
        end
    end)
    click.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            upd(i)
        end
    end)
end

-- Вкладки
local Tabs = {
    Main = CreateTab("Main", "🏠"),
    Move = CreateTab("Move", "🏃"),
    Visual = CreateTab("Visual", "🎨"),
    Misc = CreateTab("Misc", "⚙️"),
}
local RolesTab, DefenseTab = nil, nil
if IsMM2 then
    RolesTab = CreateTab("Roles", "🎭")
    DefenseTab = CreateTab("Defense", "🛡️")
end

local S = {
    Fly=false, Noclip=false, InfJump=false,
    ESP=false, Fullbright=false, LowEnd=false,
    FreeCam=false, Xray=false, AntiFling=false,
    AutoDodge=false, Spectate=false,
}
local SpdVal, JumpVal = 80, 50
local FreeCamSpeed = 60
local DodgeRange = 15

-- MAIN
Section(Tabs.Main.Scroll, "БЫСТРОЕ")
CreateButton(Tabs.Main.Scroll, "⚡ Low-End Mode (макс FPS)", function()
    S.LowEnd = not S.LowEnd
    pcall(function()
        Lighting.GlobalShadows = not S.LowEnd
        Lighting.Brightness = S.LowEnd and 1 or 2
        Lighting.FogEnd = S.LowEnd and 100000 or 1000
        for _, e in pairs(Lighting:GetChildren()) do
            if e:IsA("PostEffect") then e.Enabled = not S.LowEnd end
        end
        for _, o in pairs(Workspace:GetDescendants()) do
            if o:IsA("ParticleEmitter") or o:IsA("Fire") or o:IsA("Smoke") then
                o.Enabled = not S.LowEnd
            end
        end
    end)
end, Palette.Green)

CreateToggle(Tabs.Main.Scroll, "💡 Fullbright", false, function(s)
    S.Fullbright = s
    if s then
        Lighting.Brightness = 5
        Lighting.ClockTime = 12
        Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 2
        Lighting.GlobalShadows = true
    end
end)

CreateButton(Tabs.Main.Scroll, "🌐 Server Hop", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

-- MOVE
Section(Tabs.Move.Scroll, "ПОЛЁТ")
CreateToggle(Tabs.Move.Scroll, "🕊️ Fly", false, function(s)
    S.Fly = s
    local ch = LP.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if s and hrp and hum then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "V13Fly"; bv.MaxForce = Vector3.new(4000,4000,4000); bv.Velocity = Vector3.zero
        bv.Parent = hrp
        local bg = Instance.new("BodyGyro")
        bg.Name = "V13Gyro"; bg.MaxTorque = Vector3.new(4000,4000,4000); bg.P = 1000
        bg.Parent = hrp
        hum.PlatformStand = true
        FlyUp.Visible = true
        FlyDown.Visible = true
    elseif hrp then
        local bv = hrp:FindFirstChild("V13Fly"); if bv then bv:Destroy() end
        local bg = hrp:FindFirstChild("V13Gyro"); if bg then bg:Destroy() end
        if hum then hum.PlatformStand = false end
        FlyUp.Visible = false
        FlyDown.Visible = false
    end
end)

CreateToggle(Tabs.Move.Scroll, "👻 Noclip", false, function(s) S.Noclip = s end)
CreateToggle(Tabs.Move.Scroll, "♾️ Inf Jump", false, function(s) S.InfJump = s end)

Section(Tabs.Move.Scroll, "СКОРОСТЬ")
CreateSlider(Tabs.Move.Scroll, "Speed", 16, 300, 80, function(v)
    SpdVal = v
    if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = v
    end
end)
CreateSlider(Tabs.Move.Scroll, "Jump Power", 50, 500, 50, function(v)
    JumpVal = v
    if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character.Humanoid.UseJumpPower = true
        LP.Character.Humanoid.JumpPower = v
    end
end)

Section(Tabs.Move.Scroll, "КАМЕРА")
CreateToggle(Tabs.Move.Scroll, "🎥 Free Camera", false, function(s)
    S.FreeCam = s
    if s then
        if LP.Character then
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                Cam.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 5, 10), hrp.Position)
            end
        end
        Cam.CameraType = Enum.CameraType.Scriptable
        FreeCamButtons.Visible = true
        Notify("Free Cam", "Свайп — поворот. Кнопки — движение", 4)
    else
        Cam.CameraType = Enum.CameraType.Custom
        if LP.Character then
            local hum = LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then Cam.CameraSubject = hum end
        end
        FreeCamButtons.Visible = false
    end
end)

CreateButton(Tabs.Move.Scroll, "↩️ Вернуть камеру к себе", function()
    S.FreeCam = false
    Cam.CameraType = Enum.CameraType.Custom
    if LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then Cam.CameraSubject = hum end
    end
    FreeCamButtons.Visible = false
end)
-- VISUAL
Section(Tabs.Visual.Scroll, "ОСВЕЩЕНИЕ")
CreateSlider(Tabs.Visual.Scroll, "Яркость", 0, 10, 2, function(v) Lighting.Brightness = v end)
CreateSlider(Tabs.Visual.Scroll, "Время", 0, 24, 14, function(v) Lighting.ClockTime = v end)

Section(Tabs.Visual.Scroll, "МИР")
CreateToggle(Tabs.Visual.Scroll, "🔍 Xray", false, function(s)
    S.Xray = s
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart"
            and not (part.Parent and part.Parent:FindFirstChildOfClass("Humanoid")) then
            if s then
                if part.LocalTransparencyModifier == 0 then
                    part.LocalTransparencyModifier = 0.85
                end
            else
                part.LocalTransparencyModifier = 0
            end
        end
    end
end)

-- MISC
Section(Tabs.Misc.Scroll, "ЗАЩИТА")
CreateToggle(Tabs.Misc.Scroll, "🛡️ Anti-Fling", false, function(s)
    S.AntiFling = s
    if LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if s then
                hrp.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            else
                hrp.CustomPhysicalProperties = nil
            end
        end
    end
end)

Section(Tabs.Misc.Scroll, "СЛУЖЕБНОЕ")
CreateButton(Tabs.Misc.Scroll, "❌ Удалить Win Hub", function()
    ScreenGui:Destroy()
    _G.WinHubV13 = false
end, Palette.Red)

-- ROLES (MM2)
local ESP = {active={}, pool={}}

local function GetRole(p)
    if not p or not p.Character then return "?" end
    local ch, bp = p.Character, p:FindFirstChild("Backpack")
    local function has(c, n)
        if not c then return false end
        for _, x in pairs(n) do if c:FindFirstChild(x) then return true end end
        return false
    end
    if has(ch, {"Knife"}) or has(bp, {"Knife"}) then return "M" end
    if has(ch, {"Gun","Revolver"}) or has(bp, {"Gun","Revolver"}) then return "S" end
    return "I"
end

local function GetM()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and GetRole(p) == "M" then return p end
    end
end

local function RC(r)
    if r == "M" then return Color3.fromRGB(255,30,30)
    elseif r == "S" then return Color3.fromRGB(30,130,255)
    else return Color3.fromRGB(30,220,30) end
end
local function RO(r)
    if r == "M" then return Color3.fromRGB(140,0,0)
    elseif r == "S" then return Color3.fromRGB(0,60,160)
    else return Color3.fromRGB(0,120,0) end
end

local function RefreshESP()
    for _, h in pairs(ESP.active) do h.Parent = nil; table.insert(ESP.pool, h) end
    ESP.active = {}
    if S.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local h = table.remove(ESP.pool) or Instance.new("Highlight")
                h.FillColor = RC(GetRole(p))
                h.OutlineColor = RO(GetRole(p))
                h.Parent = p.Character
                ESP.active[p] = h
            end
        end
    end
end

local GunESPActive = false
local function RefreshGunESP()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local n = obj.Name:lower()
            if (n == "gun" or n == "revolver" or n:find("gun")) then
                if GunESPActive then
                    if not obj:FindFirstChild("WinGunHL") then
                        local h = Instance.new("Highlight")
                        h.Name = "WinGunHL"
                        h.FillColor = Color3.fromRGB(255, 220, 60)
                        h.OutlineColor = Color3.fromRGB(200, 150, 0)
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Parent = obj
                    end
                else
                    local h = obj:FindFirstChild("WinGunHL")
                    if h then h:Destroy() end
                end
            end
        end
    end
end

if IsMM2 then
    Section(RolesTab.Scroll, "ESP")

    CreateToggle(RolesTab.Scroll, "👁️ Player ESP (роли)", false, function(s)
        S.ESP = s
        RefreshESP()
    end)

    CreateToggle(RolesTab.Scroll, "🔫 Gun ESP", false, function(s)
        GunESPActive = s
        RefreshGunESP()
    end)

    CreateButton(RolesTab.Scroll, "🔄 Refresh", function()
        RefreshESP(); RefreshGunESP()
    end)

    Section(RolesTab.Scroll, "ТЕЛЕПОРТ")

    CreateButton(RolesTab.Scroll, "🔫 ТП к пушке (с возвратом)", function()
        if not LP.Character then return end
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                if n == "gun" or n == "revolver" then
                    local lastPos = hrp.CFrame
                    hrp.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                    Notify("TP", "К пушке. Через 1 сек — назад", 2)
                    task.wait(1)
                    if lastPos and hrp and hrp.Parent then
                        hrp.CFrame = lastPos
                    end
                    return
                end
            end
        end
        Notify("TP", "Пушка не найдена", 2)
    end)

    CreateButton(RolesTab.Scroll, "📍 TP к Murderer", function()
        local m = GetM()
        if m and m.Character and LP.Character then
            local tHrp = m.Character:FindFirstChild("HumanoidRootPart")
            local mHrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if tHrp and mHrp then
                mHrp.CFrame = tHrp.CFrame * CFrame.new(0,0,3)
            end
        end
    end)

    Section(DefenseTab.Scroll, "СЛЕЖКА")

    local spectateConn = nil
    local spectateTarget = nil

    local function StopSpectate()
        if spectateConn then
            spectateConn:Disconnect()
            spectateConn = nil
        end
        spectateTarget = nil
        if not S.FreeCam then
            Cam.CameraType = Enum.CameraType.Custom
            if LP.Character then
                local hum = LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then Cam.CameraSubject = hum end
            end
        end
    end

    CreateToggle(DefenseTab.Scroll, "🎥 Слежка за Murderer", false, function(s)
        S.Spectate = s
        if s then
            local m = GetM()
            if not m or not m.Character then
                Notify("Слежка", "Murderer не найден", 3)
                return
            end
            if S.FreeCam then
                S.FreeCam = false
                FreeCamButtons.Visible = false
            end
            spectateTarget = m
            Cam.CameraType = Enum.CameraType.Custom
            spectateConn = RunService.RenderStepped:Connect(function()
                if not spectateTarget or not spectateTarget.Character then
                    StopSpectate()
                    return
                end
                local hum = spectateTarget.Character:FindFirstChildOfClass("Humanoid")
                if hum then Cam.CameraSubject = hum end
            end)
            Notify("Слежка", "Смотрим за: " .. m.Name, 3)
        else
            StopSpectate()
        end
    end)

    CreateButton(DefenseTab.Scroll, "🛑 Остановить слежку", function()
        StopSpectate()
    end)

    Section(DefenseTab.Scroll, "ПРОТИВОДЕЙСТВИЕ")

    CreateButton(DefenseTab.Scroll, "⚡ TP-Flee (убежать)", function()
        if not LP.Character then return end
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _ = 1, 20 do
            local pos = hrp.Position + Vector3.new(
                math.random(-300, 300),
                math.random(20, 80),
                math.random(-300, 300)
            )
            local ray = Workspace:Raycast(pos, Vector3.new(0, -500, 0))
            if ray then
                hrp.CFrame = CFrame.new(ray.Position + Vector3.new(0, 5, 0))
                Notify("TP-Flee", "Убежал!", 2)
                return
            end
        end
        Notify("TP-Flee", "Не нашёл точку", 2)
    end, Palette.Yellow)

    CreateButton(DefenseTab.Scroll, "🌪️ Fling Murderer", function()
        local m = GetM()
        if not (m and m.Character and LP.Character) then return end
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        local tHrp = m.Character:FindFirstChild("HumanoidRootPart")
        if not (hrp and hum and tHrp) then return end
        local orig = hrp.CFrame
        local spin = Instance.new("BodyAngularVelocity")
        spin.AngularVelocity = Vector3.new(0, 100000, 0)
        spin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        spin.P = 100000
        spin.Parent = hrp
        hum.PlatformStand = true
        hrp.CanCollide = false
        task.wait(0.08)
        for _ = 1, 3 do
            if tHrp.Parent then hrp.CFrame = tHrp.CFrame end
            task.wait(0.05)
        end
        task.wait(0.15)
        spin:Destroy()
        hum.PlatformStand = false
        hrp.CanCollide = true
        hrp.CFrame = orig
        Notify("Fling", m.Name, 2)
    end, Palette.Red)

    Section(DefenseTab.Scroll, "АВТО-УКЛОНЕНИЕ")

    CreateToggle(DefenseTab.Scroll, "🛡️ Auto-Dodge (от ножей)", false, function(s)
        S.AutoDodge = s
        Notify("Auto-Dodge", s and "Включен" or "Выключен", 2)
    end)

    CreateSlider(DefenseTab.Scroll, "Dodge Range", 5, 40, 15, function(v)
        DodgeRange = v
    end)
  end
    -- Свайп для поворота FreeCam
    local camTouch = nil
    local lastTouchPos = nil

    UIS.TouchStarted:Connect(function(input)
        if not S.FreeCam then return end
        local pos = input.Position
        local gui = ScreenGui:GetGuiObjectsAtPosition(pos.X, pos.Y)
        for _, obj in pairs(gui) do
            if obj:IsA("GuiButton") then return end
        end
        camTouch = input
        lastTouchPos = pos
    end)

    UIS.TouchMoved:Connect(function(input)
        if not S.FreeCam or input ~= camTouch then return end
        local delta = input.Position - lastTouchPos
        lastTouchPos = input.Position
        local sens = 0.008
        Cam.CFrame = Cam.CFrame * CFrame.Angles(0, math.rad(-delta.X * sens * 60), 0)
            * CFrame.Angles(math.rad(-delta.Y * sens * 60), 0, 0)
    end)

    UIS.TouchEnded:Connect(function(input)
        if input == camTouch then camTouch = nil end
    end)

    -- INFO PANEL
    local InfoPanel = Instance.new("Frame")
    InfoPanel.Size = UDim2.new(0, 145, 0, 68)
    InfoPanel.Position = UDim2.new(1, -155, 0, 60)
    InfoPanel.BackgroundColor3 = Palette.BG2
    InfoPanel.BackgroundTransparency = 0.25
    InfoPanel.BorderSizePixel = 0
    InfoPanel.ZIndex = 5
    InfoPanel.Parent = ScreenGui
    Instance.new("UICorner", InfoPanel).CornerRadius = UDim.new(0, 12)

    local IPS = Instance.new("UIStroke", InfoPanel)
    IPS.Color = Palette.A1; IPS.Thickness = 1; IPS.Transparency = 0.5

    local InfoText = Instance.new("TextLabel")
    InfoText.Size = UDim2.new(1, -12, 1, -8)
    InfoText.Position = UDim2.new(0, 6, 0, 4)
    InfoText.BackgroundTransparency = 1
    InfoText.Text = ""
    InfoText.TextColor3 = Palette.Text
    InfoText.Font = Enum.Font.Gotham
    InfoText.TextSize = 11
    InfoText.TextXAlignment = Enum.TextXAlignment.Left
    InfoText.TextYAlignment = Enum.TextYAlignment.Top
    InfoText.RichText = true
    InfoText.ZIndex = 6
    InfoText.Parent = InfoPanel

    local fpsCount, fpsLast, fpsValue = 0, tick(), 60
    RunService.RenderStepped:Connect(function()
        fpsCount = fpsCount + 1
        if tick() - fpsLast >= 1 then
            fpsValue = fpsCount; fpsCount = 0; fpsLast = tick()
        end
    end)

    task.spawn(function()
        while task.wait(1) do
            if not InfoPanel.Parent then break end
            local fps = math.floor(fpsValue)
            local fpsColor = fps > 50 and "rgb(70,220,130)" or fps > 30 and "rgb(255,200,60)" or "rgb(240,80,90)"
            local ping = math.floor(LP:GetNetworkPing() * 1000)
            local plrs = #Players:GetPlayers()
            local txt = string.format('<font color="%s">FPS: %d</font>\nPing: %dms\nPlayers: %d', fpsColor, fps, ping, plrs)
            if IsMM2 then
                local r = GetRole(LP)
                local rn = r == "M" and "🔪 Murderer" or r == "S" and "🔫 Sheriff" or "👤 Innocent"
                txt = txt .. "\nRole: " .. rn
            end
            InfoText.Text = txt
        end
    end)

    -- ЦИКЛЫ
    local function throttle(hz)
        local last = 0
        return function()
            if tick() - last >= 1/hz then
                last = tick()
                return true
            end
        end
    end
    local t20, t5 = throttle(20), throttle(5)

    RunService.Heartbeat:Connect(function()
        if t20() and S.ESP then
            for p, h in pairs(ESP.active) do
                if p.Character and h then
                    local r = GetRole(p)
                    h.FillColor = RC(r)
                    h.OutlineColor = RO(r)
                end
            end
        end

        if t5() and IsMM2 and GunESPActive then
            RefreshGunESP()
        end

        if S.AutoDodge and LP.Character then
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in pairs(Workspace:GetChildren()) do
                    if obj:IsA("BasePart") and obj.Name:lower() == "knife" then
                        local dist = (obj.Position - hrp.Position).Magnitude
                        if dist < DodgeRange and dist > 1 then
                            local vel = obj.AssemblyLinearVelocity
                            if vel.Magnitude > 20 then
                                local toUs = (hrp.Position - obj.Position).Unit
                                if toUs:Dot(vel.Unit) > 0.5 then
                                    local side = Vector3.new(-toUs.Z, 0, toUs.X).Unit
                                    hrp.CFrame = CFrame.new(hrp.Position + side * 12, hrp.Position + toUs)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    RunService.RenderStepped:Connect(function()
        if S.Fly and LP.Character then
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local bv = hrp:FindFirstChild("V13Fly")
            local bg = hrp:FindFirstChild("V13Gyro")
            if not (bv and bg) then return end
            local move = Vector3.zero
            local hum = LP.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.MoveDirection.Magnitude > 0.1 then
                move = hum.MoveDirection * 60
            end
            if fUp then move = move + Vector3.new(0, 60, 0) end
            if fDown then move = move - Vector3.new(0, 60, 0) end
            bv.Velocity = move
            bg.CFrame = Cam.CFrame
        end

        if S.FreeCam then
            local move = Vector3.zero
            if CamW() then move = move + Cam.CFrame.LookVector end
            if CamS() then move = move - Cam.CFrame.LookVector end
            if CamA() then move = move - Cam.CFrame.RightVector end
            if CamD() then move = move + Cam.CFrame.RightVector end
            if move.Magnitude > 0 then
                Cam.CFrame = Cam.CFrame + move * (FreeCamSpeed / 60)
            end
        end
    end)

    RunService.Stepped:Connect(function()
        if S.Noclip and LP.Character then
            for _, p in pairs(LP.Character:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
            end
        end
    end)

    UIS.JumpRequest:Connect(function()
        if S.InfJump and LP.Character then
            local hum = LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)

    -- ПЕРЕТАСКИВАНИЕ
    local drag, dStart, sPos
    Title.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; dStart = i.Position; sPos = Main.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dStart
            Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)

    -- СВОРАЧИВАНИЕ
    local minned = false
    local origSize = Main.Size
    MinBtn.MouseButton1Click:Connect(function()
        minned = not minned
        if minned then
            Sidebar.Visible = false
            Content.Visible = false
            Tween:Create(Main, TweenInfo.new(0.25), {Size = UDim2.new(0, 200, 0, 52)}):Play()
            MinBtn.Text = "▢"
        else
            Sidebar.Visible = true
            Content.Visible = true
            Tween:Create(Main, TweenInfo.new(0.25), {Size = origSize}):Play()
            MinBtn.Text = "—"
        end
    end)

    MinBtn.MouseEnter:Connect(function()
        Tween:Create(MinBtn, TweenInfo.new(0.15), {BackgroundColor3 = Palette.A1}):Play()
    end)
    MinBtn.MouseLeave:Connect(function()
        Tween:Create(MinBtn, TweenInfo.new(0.15), {BackgroundColor3 = Palette.BG3}):Play()
    end)

    -- ПЛАВАЮЩАЯ КНОПКА
    local Tog = Instance.new("TextButton")
    Tog.Size = UDim2.new(0, 52, 0, 52)
    Tog.Position = UDim2.new(1, -68, 0, 100)
    Tog.BackgroundColor3 = Palette.A1
    Tog.BackgroundTransparency = 0.3
    Tog.Text = "⚡"
    Tog.TextColor3 = Color3.new(1,1,1)
    Tog.TextSize = 24
    Tog.Font = Enum.Font.GothamBold
    Tog.BorderSizePixel = 0
    Tog.ZIndex = 100
    Tog.Parent = ScreenGui
    Instance.new("UICorner", Tog).CornerRadius = UDim.new(1, 0)

    local TG = Instance.new("UIGradient", Tog)
    TG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Palette.A1),
        ColorSequenceKeypoint.new(1, Palette.A2),
    })
    TG.Rotation = 45

    local TGS = Instance.new("UIStroke", Tog)
    TGS.Color = Palette.A2
    TGS.Thickness = 1.5
    TGS.Transparency = 0.4

    -- Пульсация кнопки
    task.spawn(function()
        while Tog.Parent do
            Tween:Create(TGS, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {Transparency = 0.7}):Play()
            task.wait(1.5)
            Tween:Create(TGS, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {Transparency = 0.2}):Play()
            task.wait(1.5)
        end
    end)

    local tbDrag, tbStart, tbPos, tbMoved = false, nil, nil, false
    Tog.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            tbDrag = true; tbMoved = false; tbStart = i.Position; tbPos = Tog.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if tbDrag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = i.Position - tbStart
            if math.abs(d.X) > 8 or math.abs(d.Y) > 8 then tbMoved = true end
            Tog.Position = UDim2.new(tbPos.X.Scale, tbPos.X.Offset + d.X, tbPos.Y.Scale, tbPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            tbDrag = false
        end
    end)

    local lastTap = 0
    Tog.MouseButton1Click:Connect(function()
        if tbMoved then return end
        if tick() - lastTap < 0.6 then
            Main.Visible = true
            Main.Position = UDim2.new(0.5, -250, 0.5, -200)
            Tog.Visible = false
            lastTap = 0
        else
            lastTap = tick()
            Tween:Create(Tog, TweenInfo.new(0.1), {BackgroundTransparency = 0.05}):Play()
            task.wait(0.15)
            Tween:Create(Tog, TweenInfo.new(0.3), {BackgroundTransparency = 0.3}):Play()
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Main.Visible = false
        Tog.Visible = true
        Tween:Create(Tog, TweenInfo.new(0.3), {Position = UDim2.new(1, -68, 0, 100)}):Play()
    end)

    -- Старт
    activeTab = Tabs.Main
    Tabs.Main.Scroll.Visible = true
    Tabs.Main.Btn.BackgroundTransparency = 0.15
    Tabs.Main.Btn.TextColor3 = Color3.new(1,1,1)

    Notify("Win Hub v13", "Двойной тап по ⚡ для открытия", 4)
end

-- ============ ЗАПУСК ============
if HasValidSavedKey(LP.Name) then
    LoadHub()
else
    ShowKeyUI(LoadHub)
end