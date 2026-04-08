--[[
    ██╗     ███████╗██╗███████╗██╗   ██╗██████╗ ███████╗ ██████╗  ██████╗
    ██║     ██╔════╝██║██╔════╝██║   ██║██╔══██╗██╔════╝██╔════╝ ██╔════╝
    ██║     █████╗  ██║███████╗██║   ██║██████╔╝█████╗  ██║  ███╗██║  ███╗
    ██║     ██╔══╝  ██║╚════██║██║   ██║██╔══██╗██╔══╝  ██║   ██║██║   ██║
    ███████╗███████╗██║███████║╚██████╔╝██║  ██║███████╗╚██████╔╝╚██████╔╝
    ╚══════╝╚══════╝╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝
    
    leisure.gg UI Library
    made by @x_vvw
    version 1.0.0
]]

if _G.LeisureLib then return _G.LeisureLib end

-- ════════════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════════════
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local CoreGui        = game:GetService("CoreGui")
local Lighting       = game:GetService("Lighting")
local Stats          = game:GetService("Stats")
local HttpService    = game:GetService("HttpService")
local LocalPlayer    = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════════
--  THEME
-- ════════════════════════════════════════════════════════════════════
local Theme = {
    Accent        = Color3.fromRGB(255, 100, 165),
    AccentDark    = Color3.fromRGB(180, 55, 110),
    AccentLight   = Color3.fromRGB(255, 170, 210),
    AccentGlow    = Color3.fromRGB(255, 80, 145),
    BgPrimary     = Color3.fromRGB(8,  5,  13),
    BgSecondary   = Color3.fromRGB(14, 9,  21),
    BgTertiary    = Color3.fromRGB(20, 13, 30),
    BgElement     = Color3.fromRGB(26, 17, 38),
    BgHover       = Color3.fromRGB(34, 22, 50),
    TextPrimary   = Color3.fromRGB(242, 235, 245),
    TextSecondary = Color3.fromRGB(170, 140, 175),
    TextMuted     = Color3.fromRGB(110, 85, 120),
    Border        = Color3.fromRGB(60,  35, 75),
    BorderGlow    = Color3.fromRGB(255, 100, 165),
    ToggleOn      = Color3.fromRGB(75, 215, 115),
    ToggleOff     = Color3.fromRGB(210, 60,  85),
    White         = Color3.fromRGB(255, 255, 255),
    Black         = Color3.fromRGB(0, 0, 0),
}

-- ════════════════════════════════════════════════════════════════════
--  UTILITY
-- ════════════════════════════════════════════════════════════════════
local Util = {}

function Util.tween(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quint
    dir   = dir   or Enum.EasingDirection.Out
    return TweenService:Create(obj, TweenInfo.new(t or 0.2, style, dir), props)
end

function Util.tweenPlay(obj, props, t, style, dir)
    local tw = Util.tween(obj, props, t, style, dir)
    tw:Play()
    return tw
end

function Util.corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

function Util.stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1.5
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

function Util.padding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.Parent = parent
    return p
end

function Util.listLayout(parent, dir, padding, halign, valign)
    local l = Instance.new("UIListLayout")
    l.FillDirection  = dir    or Enum.FillDirection.Vertical
    l.Padding        = UDim.new(0, padding or 0)
    l.HorizontalAlignment = halign or Enum.HorizontalAlignment.Left
    l.VerticalAlignment   = valign or Enum.VerticalAlignment.Top
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

function Util.autoCanvas(scrollFrame, layout)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
    end)
end

function Util.makeDraggable(frame, handle)
    local drag = false
    local dragStart, frameStart
    handle = handle or frame

    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            dragStart  = inp.Position
            frameStart = frame.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if drag and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            frame.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
            )
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════
--  ROOT SCREENGUI
-- ════════════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "LeisureGG"
ScreenGui.IgnoreGuiInset  = true
ScreenGui.DisplayOrder    = 999999
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Blur
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size   = 0
BlurEffect.Parent = Lighting

-- ════════════════════════════════════════════════════════════════════
--  BACKGROUND LAYER (particles + tint)  shown when UI open
-- ════════════════════════════════════════════════════════════════════
local BgLayer = Instance.new("Frame")
BgLayer.Name                  = "BgLayer"
BgLayer.BackgroundColor3      = Color3.fromRGB(255, 40, 100)
BgLayer.BackgroundTransparency = 0.91
BgLayer.Size                  = UDim2.new(1,0,1,0)
BgLayer.BorderSizePixel       = 0
BgLayer.Visible               = false
BgLayer.ZIndex                = 1
BgLayer.Parent                = ScreenGui

local ParticleCanvas = Instance.new("Frame")
ParticleCanvas.BackgroundTransparency = 1
ParticleCanvas.Size             = UDim2.new(1,0,1,0)
ParticleCanvas.BorderSizePixel  = 0
ParticleCanvas.ZIndex           = 2
ParticleCanvas.ClipsDescendants = true
ParticleCanvas.Parent           = BgLayer

-- Create particles
local Particles = {}
for i = 1, 32 do
    local f = Instance.new("Frame")
    local sz = math.random(4, 14)
    f.Size                  = UDim2.new(0, sz, 0, sz * math.random(10,22)/10)
    f.BackgroundColor3      = math.random(2)==1 and Color3.fromRGB(255, math.random(80,170), math.random(140,205)) or Color3.fromRGB(255,240,248)
    f.BackgroundTransparency = math.random(45,75)/100
    f.BorderSizePixel       = 0
    f.Position              = UDim2.new(math.random(0,100)/100, 0, math.random(-5,105)/100, 0)
    f.Rotation              = math.random(0,360)
    f.ZIndex                = 2
    f.Parent                = ParticleCanvas
    Util.corner(f, 3)
    Particles[i] = {
        frame  = f,
        posX   = math.random(0,100)/100,
        posY   = math.random(-5,105)/100,
        vx     = math.random(8,20)/100,    -- rightward drift
        vy     = math.random(-6,6)/100,    -- slight vertical drift
        rot    = math.random(-1,1)*math.random(5,15)/10,
    }
end

RunService.Heartbeat:Connect(function(dt)
    if not BgLayer.Visible then return end
    for _, p in ipairs(Particles) do
        p.posX = p.posX + p.vx * dt
        p.posY = p.posY + p.vy * dt
        if p.posX > 1.08 then p.posX = -0.08 p.posY = math.random(0,100)/100 end
        if p.posY < -0.08 then p.posY = 1.08 end
        if p.posY > 1.08  then p.posY = -0.08 end
        p.frame.Position = UDim2.new(p.posX, 0, p.posY, 0)
        p.frame.Rotation = p.frame.Rotation + p.rot * dt * 60
    end
end)

-- ════════════════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ════════════════════════════════════════════════════════════════════
local NotifHolder = Instance.new("Frame")
NotifHolder.BackgroundTransparency = 1
NotifHolder.Size           = UDim2.new(0, 300, 1, -20)
NotifHolder.Position       = UDim2.new(1, -310, 0, 10)
NotifHolder.BorderSizePixel = 0
NotifHolder.ZIndex         = 9999
NotifHolder.Parent         = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder           = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment   = Enum.VerticalAlignment.Bottom
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifLayout.Padding             = UDim.new(0, 6)
NotifLayout.Parent              = NotifHolder
Util.padding(NotifHolder, 0, 10, 0, 0)

local notifCounter = 0

local function Notify(title, message, duration, ntype)
    notifCounter += 1
    local order = notifCounter
    duration = duration or 3.5

    local glowColor = ntype == "error" and Color3.fromRGB(220,70,70)
                   or ntype == "success" and Color3.fromRGB(80,210,120)
                   or Theme.Accent

    local card = Instance.new("Frame")
    card.BackgroundColor3      = Color3.fromRGB(10, 6, 16)
    card.BackgroundTransparency = 0.05
    card.BorderSizePixel       = 0
    card.Size                  = UDim2.new(1, 0, 0, 62)
    card.LayoutOrder           = order
    card.ZIndex                = 9999
    card.ClipsDescendants      = false
    card.Parent                = NotifHolder
    Util.corner(card, 10)
    local st = Util.stroke(card, glowColor, 1.5, 0.1)

    -- Glow bar left
    local bar = Instance.new("Frame")
    bar.BackgroundColor3 = glowColor
    bar.BorderSizePixel  = 0
    bar.Size             = UDim2.new(0, 3, 1, -16)
    bar.Position         = UDim2.new(0, 7, 0, 8)
    bar.ZIndex           = 10000
    bar.Parent           = card
    Util.corner(bar, 3)

    -- Icon dot
    local dot = Instance.new("Frame")
    dot.BackgroundColor3 = glowColor
    dot.BorderSizePixel  = 0
    dot.Size             = UDim2.new(0, 6, 0, 6)
    dot.Position         = UDim2.new(0, 17, 0, 12)
    dot.ZIndex           = 10000
    dot.Parent           = card
    Util.corner(dot, 6)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Size          = UDim2.new(1, -32, 0, 20)
    titleLbl.Position      = UDim2.new(0, 29, 0, 8)
    titleLbl.Font          = Enum.Font.GothamBold
    titleLbl.Text          = title
    titleLbl.TextColor3    = Theme.TextPrimary
    titleLbl.TextSize      = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextTruncate  = Enum.TextTruncate.AtEnd
    titleLbl.ZIndex        = 10000
    titleLbl.Parent        = card

    local msgLbl = Instance.new("TextLabel")
    msgLbl.BackgroundTransparency = 1
    msgLbl.Size          = UDim2.new(1, -32, 0, 18)
    msgLbl.Position      = UDim2.new(0, 29, 0, 30)
    msgLbl.Font          = Enum.Font.Gotham
    msgLbl.Text          = message or ""
    msgLbl.TextColor3    = Theme.TextSecondary
    msgLbl.TextSize      = 11
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextTruncate  = Enum.TextTruncate.AtEnd
    msgLbl.ZIndex        = 10000
    msgLbl.Parent        = card

    -- Progress bar
    local progBg = Instance.new("Frame")
    progBg.BackgroundColor3      = Color3.fromRGB(30,18,42)
    progBg.BackgroundTransparency = 0.3
    progBg.BorderSizePixel       = 0
    progBg.Size                  = UDim2.new(1, -16, 0, 2)
    progBg.Position              = UDim2.new(0, 8, 1, -6)
    progBg.ZIndex                = 10000
    progBg.Parent                = card
    Util.corner(progBg, 2)

    local prog = Instance.new("Frame")
    prog.BackgroundColor3 = glowColor
    prog.BackgroundTransparency = 0.3
    prog.BorderSizePixel  = 0
    prog.Size             = UDim2.new(1, 0, 1, 0)
    prog.ZIndex           = 10001
    prog.Parent           = progBg
    Util.corner(prog, 2)

    -- Slide in from right
    card.Position = UDim2.new(0, 310, 0, 0)
    Util.tweenPlay(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Quint)
    Util.tweenPlay(prog, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        if card and card.Parent then
            Util.tweenPlay(card, {Position = UDim2.new(0, 310, 0, 0), BackgroundTransparency = 1}, 0.35, Enum.EasingStyle.Quint)
            task.wait(0.38)
            if card then card:Destroy() end
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════
--  LOADER SCREEN
-- ════════════════════════════════════════════════════════════════════
local function showLoader(callback)
    local loader = Instance.new("Frame")
    loader.BackgroundColor3      = Color3.fromRGB(4, 2, 8)
    loader.BackgroundTransparency = 0
    loader.Size                  = UDim2.new(1, 0, 1, 0)
    loader.ZIndex                = 50000
    loader.BorderSizePixel       = 0
    loader.Parent                = ScreenGui

    -- Subtle vignette
    local vig = Instance.new("ImageLabel")
    vig.BackgroundTransparency = 1
    vig.Size   = UDim2.new(1, 0, 1, 0)
    vig.Image  = "rbxassetid://2454009026"
    vig.ImageColor3 = Color3.fromRGB(0,0,0)
    vig.ImageTransparency = 0.4
    vig.ZIndex = 50001
    vig.Parent = loader

    -- Center container
    local center = Instance.new("Frame")
    center.BackgroundTransparency = 1
    center.Size     = UDim2.new(0, 260, 0, 220)
    center.Position = UDim2.new(0.5, -130, 0.5, -110)
    center.ZIndex   = 50002
    center.Parent   = loader

    -- Logo icon (big)
    local logoFrame = Instance.new("Frame")
    logoFrame.BackgroundColor3      = Theme.Accent
    logoFrame.BackgroundTransparency = 0.08
    logoFrame.Size                  = UDim2.new(0, 80, 0, 80)
    logoFrame.Position              = UDim2.new(0.5, -40, 0, 0)
    logoFrame.BorderSizePixel       = 0
    logoFrame.ZIndex                = 50003
    logoFrame.Parent                = center
    Util.corner(logoFrame, 20)
    Util.stroke(logoFrame, Theme.Accent, 2, 0.2)

    local logoImg = Instance.new("ImageLabel")
    logoImg.BackgroundTransparency = 1
    logoImg.Size   = UDim2.new(0, 50, 0, 50)
    logoImg.Position = UDim2.new(0.5, -25, 0.5, -25)
    logoImg.Image  = "rbxassetid://95448083455045"
    logoImg.ImageColor3 = Theme.White
    logoImg.ZIndex = 50004
    logoImg.Parent = logoFrame

    -- Spinning ring
    local spinRing = Instance.new("ImageLabel")
    spinRing.BackgroundTransparency = 1
    spinRing.Size      = UDim2.new(0, 100, 0, 100)
    spinRing.Position  = UDim2.new(0.5, -50, 0, -10)
    spinRing.Image     = "rbxassetid://4965945816"
    spinRing.ImageColor3 = Theme.Accent
    spinRing.ImageTransparency = 0.3
    spinRing.ZIndex    = 50002
    spinRing.Parent    = center

    -- Spin the ring
    local spinning = true
    local spinAngle = 0
    local spinConn
    spinConn = RunService.Heartbeat:Connect(function(dt)
        if not spinning then spinConn:Disconnect() return end
        spinAngle = (spinAngle + 120 * dt) % 360
        spinRing.Rotation = spinAngle
    end)

    -- leisure.gg title
    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Size          = UDim2.new(1, 0, 0, 36)
    titleLbl.Position      = UDim2.new(0, 0, 0, 98)
    titleLbl.Font          = Enum.Font.GothamBold
    titleLbl.Text          = "leisure.gg"
    titleLbl.TextColor3    = Theme.White
    titleLbl.TextSize      = 28
    titleLbl.TextXAlignment = Enum.TextXAlignment.Center
    titleLbl.ZIndex        = 50003
    titleLbl.Parent        = center

    -- Glowing accent under title
    local titleGlow = Instance.new("Frame")
    titleGlow.BackgroundColor3 = Theme.Accent
    titleGlow.BackgroundTransparency = 0.5
    titleGlow.BorderSizePixel = 0
    titleGlow.Size     = UDim2.new(0, 80, 0, 2)
    titleGlow.Position = UDim2.new(0.5, -40, 0, 138)
    titleGlow.ZIndex   = 50003
    titleGlow.Parent   = center
    Util.corner(titleGlow, 2)

    -- Subtitle
    local subLbl = Instance.new("TextLabel")
    subLbl.BackgroundTransparency = 1
    subLbl.Size          = UDim2.new(1, 0, 0, 18)
    subLbl.Position      = UDim2.new(0, 0, 0, 148)
    subLbl.Font          = Enum.Font.Gotham
    subLbl.Text          = "made by @x_vvw"
    subLbl.TextColor3    = Theme.TextMuted
    subLbl.TextSize      = 12
    subLbl.TextXAlignment = Enum.TextXAlignment.Center
    subLbl.ZIndex        = 50003
    subLbl.Parent        = center

    -- Loading bar
    local barBg = Instance.new("Frame")
    barBg.BackgroundColor3      = Color3.fromRGB(20, 12, 30)
    barBg.BackgroundTransparency = 0.2
    barBg.BorderSizePixel       = 0
    barBg.Size     = UDim2.new(0, 200, 0, 4)
    barBg.Position = UDim2.new(0.5, -100, 0, 180)
    barBg.ZIndex   = 50003
    barBg.Parent   = center
    Util.corner(barBg, 2)
    Util.stroke(barBg, Theme.Border, 1, 0.4)

    local barFill = Instance.new("Frame")
    barFill.BackgroundColor3 = Theme.Accent
    barFill.BorderSizePixel  = 0
    barFill.Size             = UDim2.new(0, 0, 1, 0)
    barFill.ZIndex           = 50004
    barFill.Parent           = barBg
    Util.corner(barFill, 2)

    -- Version label
    local verLbl = Instance.new("TextLabel")
    verLbl.BackgroundTransparency = 1
    verLbl.Size          = UDim2.new(0, 200, 0, 14)
    verLbl.Position      = UDim2.new(0.5, -100, 0, 196)
    verLbl.Font          = Enum.Font.Gotham
    verLbl.Text          = "v1.0.0  ·  initialising..."
    verLbl.TextColor3    = Theme.TextMuted
    verLbl.TextSize      = 10
    verLbl.TextXAlignment = Enum.TextXAlignment.Center
    verLbl.ZIndex        = 50003
    verLbl.Parent        = center

    -- Close/skip button
    local skipBtn = Instance.new("TextButton")
    skipBtn.BackgroundTransparency = 1
    skipBtn.Size          = UDim2.new(0, 28, 0, 28)
    skipBtn.Position      = UDim2.new(1, -38, 0, 10)
    skipBtn.Font          = Enum.Font.GothamBold
    skipBtn.Text          = "✕"
    skipBtn.TextColor3    = Theme.TextMuted
    skipBtn.TextSize      = 16
    skipBtn.ZIndex        = 50010
    skipBtn.Parent        = loader

    skipBtn.MouseEnter:Connect(function()
        Util.tweenPlay(skipBtn, {TextColor3 = Theme.White}, 0.15)
    end)
    skipBtn.MouseLeave:Connect(function()
        Util.tweenPlay(skipBtn, {TextColor3 = Theme.TextMuted}, 0.15)
    end)

    local skipped = false
    skipBtn.MouseButton1Click:Connect(function()
        if not skipped then
            skipped = true
            spinning = false
            loader:Destroy()
        end
    end)

    -- Animate loading bar over ~2.8 seconds
    local stages = {
        {t=0.0, text="initialising..."},
        {t=0.3, text="loading components..."},
        {t=0.6, text="building interface..."},
        {t=0.85, text="almost ready..."},
        {t=1.0, text="done."},
    }

    Util.tweenPlay(barFill, {Size = UDim2.new(1, 0, 1, 0)}, 2.8, Enum.EasingStyle.Quint)

    task.spawn(function()
        for _, s in ipairs(stages) do
            task.wait(s.t * 2.8)
            if not skipped then
                Util.tweenPlay(verLbl, {TextTransparency = 1}, 0.15)
                task.wait(0.15)
                verLbl.Text = "v1.0.0  ·  " .. s.text
                Util.tweenPlay(verLbl, {TextTransparency = 0}, 0.15)
            end
        end

        task.wait(0.5)
        if not skipped then
            spinning = false
            Util.tweenPlay(loader, {BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Quint)
            Util.tweenPlay(titleLbl, {TextTransparency = 1}, 0.4)
            Util.tweenPlay(subLbl, {TextTransparency = 1}, 0.4)
            Util.tweenPlay(logoFrame, {BackgroundTransparency = 1}, 0.4)
            Util.tweenPlay(logoImg, {ImageTransparency = 1}, 0.4)
            Util.tweenPlay(spinRing, {ImageTransparency = 1}, 0.4)
            Util.tweenPlay(barBg, {BackgroundTransparency = 1}, 0.4)
            Util.tweenPlay(barFill, {BackgroundTransparency = 1}, 0.4)
            task.wait(0.55)
            loader:Destroy()
        end

        if callback then callback() end
    end)
end

-- ════════════════════════════════════════════════════════════════════
--  KEY SYSTEM
-- ════════════════════════════════════════════════════════════════════
local VALID_KEY = "08042026"

local function showKeySystem(callback)
    local keyFrame = Instance.new("Frame")
    keyFrame.BackgroundColor3      = Color3.fromRGB(5, 3, 10)
    keyFrame.BackgroundTransparency = 0
    keyFrame.Size                  = UDim2.new(0, 380, 0, 280)
    keyFrame.Position              = UDim2.new(0.5, -190, 0.5, -140)
    keyFrame.BorderSizePixel       = 0
    keyFrame.ZIndex                = 40000
    keyFrame.Parent                = ScreenGui
    Util.corner(keyFrame, 14)
    Util.stroke(keyFrame, Theme.Accent, 2, 0.1)

    -- Glow corners
    for _, pos in ipairs({
        UDim2.new(0, -2, 0, -2), UDim2.new(1, -8, 0, -2),
        UDim2.new(0, -2, 1, -8), UDim2.new(1, -8, 1, -8),
    }) do
        local g = Instance.new("Frame")
        g.BackgroundColor3 = Theme.Accent
        g.BackgroundTransparency = 0.3
        g.BorderSizePixel = 0
        g.Size     = UDim2.new(0, 10, 0, 10)
        g.Position = pos
        g.ZIndex   = 40001
        g.Parent   = keyFrame
        Util.corner(g, 3)
    end

    -- Close button
    local closeKey = Instance.new("TextButton")
    closeKey.BackgroundTransparency = 1
    closeKey.Size     = UDim2.new(0, 30, 0, 30)
    closeKey.Position = UDim2.new(1, -38, 0, 8)
    closeKey.Font     = Enum.Font.GothamBold
    closeKey.Text     = "✕"
    closeKey.TextColor3 = Theme.TextSecondary
    closeKey.TextSize   = 16
    closeKey.ZIndex     = 40005
    closeKey.Parent     = keyFrame
    closeKey.MouseEnter:Connect(function() Util.tweenPlay(closeKey, {TextColor3 = Theme.White}, 0.15) end)
    closeKey.MouseLeave:Connect(function() Util.tweenPlay(closeKey, {TextColor3 = Theme.TextSecondary}, 0.15) end)
    closeKey.MouseButton1Click:Connect(function() keyFrame:Destroy() end)

    -- Logo small
    local kLogo = Instance.new("ImageLabel")
    kLogo.BackgroundTransparency = 1
    kLogo.Size     = UDim2.new(0, 32, 0, 32)
    kLogo.Position = UDim2.new(0.5, -16, 0, 28)
    kLogo.Image    = "rbxassetid://95448083455045"
    kLogo.ImageColor3 = Theme.Accent
    kLogo.ZIndex   = 40002
    kLogo.Parent   = keyFrame

    -- Title with typewriter effect
    local kTitle = Instance.new("TextLabel")
    kTitle.BackgroundTransparency = 1
    kTitle.Size          = UDim2.new(1, -20, 0, 36)
    kTitle.Position      = UDim2.new(0, 10, 0, 66)
    kTitle.Font          = Enum.Font.GothamBold
    kTitle.Text          = ""
    kTitle.TextColor3    = Theme.White
    kTitle.TextSize      = 26
    kTitle.TextXAlignment = Enum.TextXAlignment.Center
    kTitle.ZIndex        = 40002
    kTitle.Parent        = keyFrame

    local kGlow = Instance.new("Frame")
    kGlow.BackgroundColor3 = Theme.Accent
    kGlow.BackgroundTransparency = 0.55
    kGlow.BorderSizePixel = 0
    kGlow.Size     = UDim2.new(0, 60, 0, 2)
    kGlow.Position = UDim2.new(0.5, -30, 0, 106)
    kGlow.ZIndex   = 40002
    kGlow.Parent   = keyFrame
    Util.corner(kGlow, 2)

    local kSub = Instance.new("TextLabel")
    kSub.BackgroundTransparency = 1
    kSub.Size          = UDim2.new(1, -20, 0, 16)
    kSub.Position      = UDim2.new(0, 10, 0, 116)
    kSub.Font          = Enum.Font.Gotham
    kSub.Text          = "enter your key to continue"
    kSub.TextColor3    = Theme.TextMuted
    kSub.TextSize      = 12
    kSub.TextXAlignment = Enum.TextXAlignment.Center
    kSub.ZIndex        = 40002
    kSub.Parent        = keyFrame

    -- Key TextBox
    local boxFrame = Instance.new("Frame")
    boxFrame.BackgroundColor3      = Color3.fromRGB(12, 7, 20)
    boxFrame.BackgroundTransparency = 0.1
    boxFrame.BorderSizePixel       = 0
    boxFrame.Size     = UDim2.new(0, 280, 0, 40)
    boxFrame.Position = UDim2.new(0.5, -140, 0, 145)
    boxFrame.ZIndex   = 40003
    boxFrame.Parent   = keyFrame
    Util.corner(boxFrame, 8)
    Util.stroke(boxFrame, Theme.Border, 1.5, 0.3)

    local keyBox = Instance.new("TextBox")
    keyBox.BackgroundTransparency = 1
    keyBox.Size          = UDim2.new(1, -20, 1, 0)
    keyBox.Position      = UDim2.new(0, 10, 0, 0)
    keyBox.Font          = Enum.Font.Code
    keyBox.Text          = ""
    keyBox.PlaceholderText = "enter key..."
    keyBox.PlaceholderColor3 = Theme.TextMuted
    keyBox.TextColor3    = Theme.TextPrimary
    keyBox.TextSize      = 14
    keyBox.ClearTextOnFocus = false
    keyBox.ZIndex        = 40004
    keyBox.Parent        = boxFrame

    -- Status label
    local statusLbl = Instance.new("TextLabel")
    statusLbl.BackgroundTransparency = 1
    statusLbl.Size          = UDim2.new(1, -20, 0, 14)
    statusLbl.Position      = UDim2.new(0, 10, 0, 192)
    statusLbl.Font          = Enum.Font.Gotham
    statusLbl.Text          = ""
    statusLbl.TextColor3    = Theme.TextMuted
    statusLbl.TextSize      = 11
    statusLbl.TextXAlignment = Enum.TextXAlignment.Center
    statusLbl.ZIndex        = 40003
    statusLbl.Parent        = keyFrame

    -- Buttons row
    local btnRow = Instance.new("Frame")
    btnRow.BackgroundTransparency = 1
    btnRow.Size     = UDim2.new(0, 280, 0, 40)
    btnRow.Position = UDim2.new(0.5, -140, 0, 210)
    btnRow.ZIndex   = 40003
    btnRow.Parent   = keyFrame
    Util.listLayout(btnRow, Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Center)

    local function makeKeyBtn(txt, color, w)
        local b = Instance.new("TextButton")
        b.BackgroundColor3      = color
        b.BackgroundTransparency = 0.15
        b.BorderSizePixel       = 0
        b.Size   = UDim2.new(0, w or 130, 0, 38)
        b.Font   = Enum.Font.GothamBold
        b.Text   = txt
        b.TextColor3 = Theme.White
        b.TextSize   = 13
        b.ZIndex     = 40004
        b.Parent     = btnRow
        Util.corner(b, 8)
        Util.stroke(b, color, 1.5, 0.3)
        b.MouseEnter:Connect(function() Util.tweenPlay(b, {BackgroundTransparency = 0}, 0.15) end)
        b.MouseLeave:Connect(function() Util.tweenPlay(b, {BackgroundTransparency = 0.15}, 0.15) end)
        return b
    end

    local getKeyBtn   = makeKeyBtn("GET KEY",   Theme.AccentDark, 128)
    local checkKeyBtn = makeKeyBtn("CHECK KEY", Theme.Accent,     128)

    -- Credits bottom
    local credLbl = Instance.new("TextLabel")
    credLbl.BackgroundTransparency = 1
    credLbl.Size          = UDim2.new(1, 0, 0, 14)
    credLbl.Position      = UDim2.new(0, 0, 1, -18)
    credLbl.Font          = Enum.Font.Gotham
    credLbl.Text          = "made by @x_vvw  ·  leisure.gg"
    credLbl.TextColor3    = Theme.TextMuted
    credLbl.TextSize      = 10
    credLbl.TextXAlignment = Enum.TextXAlignment.Center
    credLbl.ZIndex        = 40002
    credLbl.Parent        = keyFrame

    -- Typewriter animation
    local fullText = "leisure.gg"
    task.spawn(function()
        while true do
            -- Type forward
            for i = 1, #fullText do
                kTitle.Text = string.sub(fullText, 1, i)
                task.wait(0.08)
            end
            task.wait(0.6)
            -- Type backward
            for i = #fullText, 0, -1 do
                kTitle.Text = string.sub(fullText, 1, i)
                task.wait(0.05)
            end
            task.wait(0.3)
        end
    end)

    -- Focus highlight on textbox
    keyBox:GetPropertyChangedSignal("Text"):Connect(function()
        Util.tweenPlay(boxFrame, {}, 0)
    end)
    keyBox.Focused:Connect(function()
        Util.tweenPlay(boxFrame, {BackgroundTransparency = 0}, 0.2)
        local st2 = boxFrame:FindFirstChildOfClass("UIStroke")
        if st2 then Util.tweenPlay(st2, {Transparency = 0, Color = Theme.Accent}, 0.2) end
    end)
    keyBox.FocusLost:Connect(function()
        Util.tweenPlay(boxFrame, {BackgroundTransparency = 0.1}, 0.2)
        local st2 = boxFrame:FindFirstChildOfClass("UIStroke")
        if st2 then Util.tweenPlay(st2, {Transparency = 0.3, Color = Theme.Border}, 0.2) end
    end)

    -- GET KEY copies to clipboard
    getKeyBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(VALID_KEY) end)
        statusLbl.Text      = "key copied to clipboard!"
        statusLbl.TextColor3 = Theme.AccentLight
        task.delay(2, function()
            statusLbl.Text = ""
        end)
    end)

    -- CHECK KEY
    checkKeyBtn.MouseButton1Click:Connect(function()
        local entered = keyBox.Text
        if entered == VALID_KEY then
            statusLbl.Text      = "✓ key accepted"
            statusLbl.TextColor3 = Color3.fromRGB(80, 215, 115)
            task.wait(0.6)
            -- Fade out key frame
            Util.tweenPlay(keyFrame, {BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Quint)
            for _, child in ipairs(keyFrame:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                    pcall(function() Util.tweenPlay(child, {TextTransparency = 1}, 0.4) end)
                elseif child:IsA("ImageLabel") then
                    pcall(function() Util.tweenPlay(child, {ImageTransparency = 1}, 0.4) end)
                elseif child:IsA("Frame") then
                    pcall(function() Util.tweenPlay(child, {BackgroundTransparency = 1}, 0.4) end)
                end
            end
            task.wait(0.55)
            keyFrame:Destroy()
            if callback then callback() end
        else
            statusLbl.Text      = "✗ invalid key"
            statusLbl.TextColor3 = Color3.fromRGB(210, 70, 70)
            Util.tweenPlay(boxFrame, {BackgroundColor3 = Color3.fromRGB(40, 10, 18)}, 0.15)
            task.wait(0.4)
            Util.tweenPlay(boxFrame, {BackgroundColor3 = Color3.fromRGB(12, 7, 20)}, 0.3)
            task.delay(2, function()
                statusLbl.Text = ""
            end)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════
--  MAIN UI BUILDER
-- ════════════════════════════════════════════════════════════════════
local Library = {}
Library.__index = Library

-- State
Library._windows  = {}
Library._toggleKeybind = Enum.KeyCode.RightControl
Library._uiVisible    = true
Library._configFolder = "LeisureGG"

function Library:SetToggleKeybind(keyCode)
    self._toggleKeybind = keyCode
end

function Library:ToggleUI()
    self._uiVisible = not self._uiVisible
    BgLayer.Visible = self._uiVisible and self._anyWindowOpen or false
    if not self._uiVisible then
        BlurEffect.Size = 0
        BgLayer.Visible = false
    end
    for _, win in ipairs(self._windows) do
        win.Frame.Visible = self._uiVisible and win._open
    end
    NotifHolder.Visible = self._uiVisible
end

-- Keybind listener
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Library._toggleKeybind then
        Library:ToggleUI()
        Notify(
            Library._uiVisible and "UI Shown" or "UI Hidden",
            Library._uiVisible and "press " .. Library._toggleKeybind.Name .. " to hide" or "press " .. Library._toggleKeybind.Name .. " to show",
            2
        )
    end
end)

-- ──────────────────────────────────────────
--  WINDOW
-- ──────────────────────────────────────────
function Library:CreateWindow(opts)
    opts = opts or {}
    local title  = opts.Title   or "leisure.gg"
    local size   = opts.Size    or {580, 400}
    local pos    = opts.Position

    local win = {}
    win._open   = true
    win._tabs   = {}
    win._activeTab = nil

    -- Outer frame
    local frame = Instance.new("Frame")
    frame.Name                  = "LeisureWindow"
    frame.BackgroundColor3      = Theme.BgPrimary
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel       = 0
    frame.Size                  = UDim2.new(0, size[1], 0, size[2])
    frame.Position              = pos or UDim2.new(0.5, -size[1]/2, 0.5, -size[2]/2)
    frame.ZIndex                = 100
    frame.ClipsDescendants      = false
    frame.Parent                = ScreenGui
    Util.corner(frame, 12)

    -- Glowing stroke
    local winStroke = Util.stroke(frame, Theme.Accent, 1.8, 0.1)
    win._stroke = winStroke

    -- Shadow (fake, slightly larger frame behind)
    local shadow = Instance.new("Frame")
    shadow.BackgroundColor3      = Color3.fromRGB(255, 80, 140)
    shadow.BackgroundTransparency = 0.88
    shadow.BorderSizePixel       = 0
    shadow.Size                  = UDim2.new(1, 12, 1, 12)
    shadow.Position              = UDim2.new(0, -6, 0, 6)
    shadow.ZIndex                = 99
    shadow.Parent                = frame
    Util.corner(shadow, 14)

    win.Frame  = frame
    win.Shadow = shadow
    Util.makeDraggable(frame, frame)

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.BackgroundColor3      = Theme.BgSecondary
    titleBar.BackgroundTransparency = 0
    titleBar.BorderSizePixel       = 0
    titleBar.Size                  = UDim2.new(1, 0, 0, 46)
    titleBar.ZIndex                = 102
    titleBar.Parent                = frame
    Util.corner(titleBar, 12)
    -- block bottom corners of titlebar
    local tbBottom = Instance.new("Frame")
    tbBottom.BackgroundColor3 = Theme.BgSecondary
    tbBottom.BackgroundTransparency = 0
    tbBottom.BorderSizePixel = 0
    tbBottom.Size     = UDim2.new(1, 0, 0.5, 0)
    tbBottom.Position = UDim2.new(0, 0, 0.5, 0)
    tbBottom.ZIndex   = 102
    tbBottom.Parent   = titleBar

    -- Logo
    local titleLogo = Instance.new("ImageLabel")
    titleLogo.BackgroundTransparency = 1
    titleLogo.Size     = UDim2.new(0, 22, 0, 22)
    titleLogo.Position = UDim2.new(0, 14, 0.5, -11)
    titleLogo.Image    = "rbxassetid://95448083455045"
    titleLogo.ImageColor3 = Theme.Accent
    titleLogo.ZIndex   = 103
    titleLogo.Parent   = titleBar

    -- Title text
    local titleTxt = Instance.new("TextLabel")
    titleTxt.BackgroundTransparency = 1
    titleTxt.Size          = UDim2.new(0, 160, 0, 24)
    titleTxt.Position      = UDim2.new(0, 42, 0.5, -12)
    titleTxt.Font          = Enum.Font.GothamBold
    titleTxt.Text          = title
    titleTxt.TextColor3    = Theme.TextPrimary
    titleTxt.TextSize      = 15
    titleTxt.TextXAlignment = Enum.TextXAlignment.Left
    titleTxt.ZIndex        = 103
    titleTxt.Parent        = titleBar

    -- Credits label
    local credTxt = Instance.new("TextLabel")
    credTxt.BackgroundTransparency = 1
    credTxt.Size          = UDim2.new(0, 100, 0, 14)
    credTxt.Position      = UDim2.new(0, 42, 0.5, 3)
    credTxt.Font          = Enum.Font.Gotham
    credTxt.Text          = "made by @x_vvw"
    credTxt.TextColor3    = Theme.TextMuted
    credTxt.TextSize      = 10
    credTxt.TextXAlignment = Enum.TextXAlignment.Left
    credTxt.ZIndex        = 103
    credTxt.Parent        = titleBar

    -- Close button in titlebar
    local closeWin = Instance.new("TextButton")
    closeWin.BackgroundColor3      = Color3.fromRGB(200, 55, 85)
    closeWin.BackgroundTransparency = 0.2
    closeWin.BorderSizePixel       = 0
    closeWin.Size     = UDim2.new(0, 28, 0, 28)
    closeWin.Position = UDim2.new(1, -38, 0.5, -14)
    closeWin.Font     = Enum.Font.GothamBold
    closeWin.Text     = "✕"
    closeWin.TextColor3 = Theme.White
    closeWin.TextSize   = 14
    closeWin.ZIndex     = 104
    closeWin.Parent     = titleBar
    Util.corner(closeWin, 7)
    closeWin.MouseEnter:Connect(function() Util.tweenPlay(closeWin, {BackgroundTransparency = 0}, 0.15) end)
    closeWin.MouseLeave:Connect(function() Util.tweenPlay(closeWin, {BackgroundTransparency = 0.2}, 0.15) end)
    closeWin.MouseButton1Click:Connect(function()
        win._open = false
        frame.Visible = false
        Library._anyWindowOpen = false
        BgLayer.Visible = false
        BlurEffect.Size = 0
        Notify("UI", "window closed  ·  " .. Library._toggleKeybind.Name .. " to reopen", 2)
    end)

    -- Minimise button
    local minWin = Instance.new("TextButton")
    minWin.BackgroundColor3      = Color3.fromRGB(200, 160, 30)
    minWin.BackgroundTransparency = 0.2
    minWin.BorderSizePixel       = 0
    minWin.Size     = UDim2.new(0, 28, 0, 28)
    minWin.Position = UDim2.new(1, -72, 0.5, -14)
    minWin.Font     = Enum.Font.GothamBold
    minWin.Text     = "–"
    minWin.TextColor3 = Theme.White
    minWin.TextSize   = 16
    minWin.ZIndex     = 104
    minWin.Parent     = titleBar
    Util.corner(minWin, 7)
    minWin.MouseEnter:Connect(function() Util.tweenPlay(minWin, {BackgroundTransparency = 0}, 0.15) end)
    minWin.MouseLeave:Connect(function() Util.tweenPlay(minWin, {BackgroundTransparency = 0.2}, 0.15) end)

    local minimised = false
    minWin.MouseButton1Click:Connect(function()
        minimised = not minimised
        if minimised then
            Util.tweenPlay(frame, {Size = UDim2.new(0, size[1], 0, 46)}, 0.3, Enum.EasingStyle.Quint)
        else
            Util.tweenPlay(frame, {Size = UDim2.new(0, size[1], 0, size[2])}, 0.3, Enum.EasingStyle.Quint)
        end
    end)

    -- ── BODY ──
    local body = Instance.new("Frame")
    body.BackgroundTransparency = 1
    body.BorderSizePixel        = 0
    body.Size                   = UDim2.new(1, 0, 1, -46)
    body.Position               = UDim2.new(0, 0, 0, 46)
    body.ZIndex                 = 102
    body.Parent                 = frame

    -- ── TAB BAR ──
    local tabBarFrame = Instance.new("Frame")
    tabBarFrame.BackgroundColor3      = Theme.BgSecondary
    tabBarFrame.BackgroundTransparency = 0
    tabBarFrame.BorderSizePixel       = 0
    tabBarFrame.Size                  = UDim2.new(0, 130, 1, 0)
    tabBarFrame.ZIndex                = 103
    tabBarFrame.Parent                = body
    -- block right corners
    local tbRight = Instance.new("Frame")
    tbRight.BackgroundColor3 = Theme.BgSecondary
    tbRight.BackgroundTransparency = 0
    tbRight.BorderSizePixel = 0
    tbRight.Size     = UDim2.new(0, 10, 1, 0)
    tbRight.Position = UDim2.new(1, -10, 0, 0)
    tbRight.ZIndex   = 103
    tbRight.Parent   = tabBarFrame

    local tabList = Instance.new("ScrollingFrame")
    tabList.BackgroundTransparency = 1
    tabList.BorderSizePixel        = 0
    tabList.Size                   = UDim2.new(1, 0, 1, -10)
    tabList.Position               = UDim2.new(0, 0, 0, 8)
    tabList.CanvasSize             = UDim2.new(0, 0, 0, 0)
    tabList.ScrollBarThickness     = 0
    tabList.ZIndex                 = 104
    tabList.Parent                 = tabBarFrame
    Util.listLayout(tabList, Enum.FillDirection.Vertical, 2)
    Util.padding(tabList, 2, 2, 8, 8)
    Util.autoCanvas(tabList, tabList:FindFirstChildOfClass("UIListLayout"))

    -- ── CONTENT AREA ──
    local contentArea = Instance.new("Frame")
    contentArea.BackgroundColor3      = Theme.BgPrimary
    contentArea.BackgroundTransparency = 0
    contentArea.BorderSizePixel       = 0
    contentArea.Size                  = UDim2.new(1, -130, 1, 0)
    contentArea.Position              = UDim2.new(0, 130, 0, 0)
    contentArea.ZIndex                = 102
    contentArea.ClipsDescendants      = true
    contentArea.Parent                = body

    -- Separator line
    local sep = Instance.new("Frame")
    sep.BackgroundColor3 = Theme.Border
    sep.BackgroundTransparency = 0.5
    sep.BorderSizePixel = 0
    sep.Size     = UDim2.new(0, 1, 1, 0)
    sep.ZIndex   = 104
    sep.Parent   = body

    win.TabList     = tabList
    win.ContentArea = contentArea
    win.TitleBar    = titleBar

    -- Open BgLayer + blur when window created
    Library._anyWindowOpen = true
    BgLayer.Visible = true
    Util.tweenPlay(BlurEffect, {Size = 16}, 0.4, Enum.EasingStyle.Quint)

    table.insert(Library._windows, win)

    -- ──────────────────────────────────────────
    --  TAB method
    -- ──────────────────────────────────────────
    function win:AddTab(tabName, tabIcon)
        local tab = {}
        tab._sections = {}

        -- Tab button
        local tabBtn = Instance.new("TextButton")
        tabBtn.BackgroundColor3      = Theme.BgTertiary
        tabBtn.BackgroundTransparency = 1
        tabBtn.BorderSizePixel       = 0
        tabBtn.Size     = UDim2.new(1, 0, 0, 36)
        tabBtn.Font     = Enum.Font.GothamSemibold
        tabBtn.Text     = (tabIcon and (tabIcon .. " ") or "") .. tabName
        tabBtn.TextColor3 = Theme.TextMuted
        tabBtn.TextSize   = 12
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.ZIndex     = 105
        tabBtn.Parent     = tabList
        Util.corner(tabBtn, 7)
        Util.padding(tabBtn, 0, 0, 10, 0)

        local tabIndicator = Instance.new("Frame")
        tabIndicator.BackgroundColor3 = Theme.Accent
        tabIndicator.BackgroundTransparency = 1
        tabIndicator.BorderSizePixel = 0
        tabIndicator.Size     = UDim2.new(0, 3, 0, 20)
        tabIndicator.Position = UDim2.new(0, 0, 0.5, -10)
        tabIndicator.ZIndex   = 106
        tabIndicator.Parent   = tabBtn
        Util.corner(tabIndicator, 2)

        -- Tab content scroll frame
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel        = 0
        tabContent.Size                   = UDim2.new(1, 0, 1, 0)
        tabContent.CanvasSize             = UDim2.new(0, 0, 0, 0)
        tabContent.ScrollBarThickness     = 3
        tabContent.ScrollBarImageColor3   = Theme.Accent
        tabContent.ScrollBarImageTransparency = 0.4
        tabContent.Visible                = false
        tabContent.ZIndex                 = 103
        tabContent.Parent                 = contentArea
        Util.padding(tabContent, 10, 10, 10, 10)

        local contentLayout = Util.listLayout(tabContent, Enum.FillDirection.Vertical, 6)
        Util.autoCanvas(tabContent, contentLayout)

        tab.Content = tabContent
        tab.Btn     = tabBtn
        tab.Indicator = tabIndicator

        local function activateTab()
            -- Deactivate all
            for _, t in ipairs(win._tabs) do
                t.Content.Visible = false
                Util.tweenPlay(t.Btn, {BackgroundTransparency = 1, TextColor3 = Theme.TextMuted}, 0.15)
                Util.tweenPlay(t.Indicator, {BackgroundTransparency = 1}, 0.15)
            end
            -- Activate this
            tabContent.Visible = true
            Util.tweenPlay(tabBtn, {BackgroundTransparency = 0.55, TextColor3 = Theme.TextPrimary}, 0.15)
            Util.tweenPlay(tabIndicator, {BackgroundTransparency = 0}, 0.15)
            win._activeTab = tab
        end

        tabBtn.MouseButton1Click:Connect(activateTab)
        tabBtn.MouseEnter:Connect(function()
            if win._activeTab ~= tab then
                Util.tweenPlay(tabBtn, {BackgroundTransparency = 0.75}, 0.1)
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if win._activeTab ~= tab then
                Util.tweenPlay(tabBtn, {BackgroundTransparency = 1}, 0.1)
            end
        end)

        table.insert(win._tabs, tab)
        if #win._tabs == 1 then activateTab() end

        -- ──────────────────────────────────────────
        --  SECTION method
        -- ──────────────────────────────────────────
        function tab:AddSection(sectionName)
            local section = {}

            local sFrame = Instance.new("Frame")
            sFrame.BackgroundColor3      = Theme.BgSecondary
            sFrame.BackgroundTransparency = 0
            sFrame.BorderSizePixel       = 0
            sFrame.Size                  = UDim2.new(1, 0, 0, 0)
            sFrame.AutomaticSize         = Enum.AutomaticSize.Y
            sFrame.ZIndex                = 104
            sFrame.Parent                = tabContent
            Util.corner(sFrame, 8)
            Util.stroke(sFrame, Theme.Border, 1, 0.55)

            -- Section header
            local sHeader = Instance.new("Frame")
            sHeader.BackgroundTransparency = 1
            sHeader.BorderSizePixel       = 0
            sHeader.Size                  = UDim2.new(1, 0, 0, 30)
            sHeader.ZIndex                = 105
            sHeader.Parent                = sFrame

            local sTitle = Instance.new("TextLabel")
            sTitle.BackgroundTransparency = 1
            sTitle.Size          = UDim2.new(1, -16, 1, 0)
            sTitle.Position      = UDim2.new(0, 10, 0, 0)
            sTitle.Font          = Enum.Font.GothamBold
            sTitle.Text          = sectionName
            sTitle.TextColor3    = Theme.Accent
            sTitle.TextSize      = 11
            sTitle.TextXAlignment = Enum.TextXAlignment.Left
            sTitle.ZIndex        = 106
            sTitle.Parent        = sHeader

            -- Divider under header
            local sDivider = Instance.new("Frame")
            sDivider.BackgroundColor3 = Theme.Accent
            sDivider.BackgroundTransparency = 0.7
            sDivider.BorderSizePixel = 0
            sDivider.Size     = UDim2.new(1, -20, 0, 1)
            sDivider.Position = UDim2.new(0, 10, 0, 29)
            sDivider.ZIndex   = 105
            sDivider.Parent   = sFrame

            -- Items container
            local itemsCont = Instance.new("Frame")
            itemsCont.BackgroundTransparency = 1
            itemsCont.BorderSizePixel        = 0
            itemsCont.Size                   = UDim2.new(1, 0, 0, 0)
            itemsCont.AutomaticSize          = Enum.AutomaticSize.Y
            itemsCont.Position               = UDim2.new(0, 0, 0, 32)
            itemsCont.ZIndex                 = 105
            itemsCont.Parent                 = sFrame
            Util.listLayout(itemsCont, Enum.FillDirection.Vertical, 2)
            Util.padding(itemsCont, 0, 8, 8, 8)

            section.Container = itemsCont

            -- ──────────────────────────────────────────
            --  TOGGLE
            -- ──────────────────────────────────────────
            function section:AddToggle(opts2)
                opts2 = opts2 or {}
                local lbl     = opts2.Label    or "Toggle"
                local default = opts2.Default  ~= nil and opts2.Default or false
                local tip     = opts2.Tooltip  or ""
                local cb      = opts2.Callback or function() end

                local toggled = default

                local row = Instance.new("Frame")
                row.BackgroundColor3      = Theme.BgElement
                row.BackgroundTransparency = 0.3
                row.BorderSizePixel       = 0
                row.Size                  = UDim2.new(1, 0, 0, 36)
                row.ZIndex                = 106
                row.Parent                = itemsCont
                Util.corner(row, 6)

                local rowLbl = Instance.new("TextLabel")
                rowLbl.BackgroundTransparency = 1
                rowLbl.Size          = UDim2.new(1, -68, 1, 0)
                rowLbl.Position      = UDim2.new(0, 10, 0, 0)
                rowLbl.Font          = Enum.Font.Gotham
                rowLbl.Text          = lbl
                rowLbl.TextColor3    = Theme.TextPrimary
                rowLbl.TextSize      = 13
                rowLbl.TextXAlignment = Enum.TextXAlignment.Left
                rowLbl.ZIndex        = 107
                rowLbl.Parent        = row

                -- Pill background
                local pill = Instance.new("Frame")
                pill.BackgroundColor3      = toggled and Theme.ToggleOn or Theme.ToggleOff
                pill.BackgroundTransparency = 0.1
                pill.BorderSizePixel       = 0
                pill.Size     = UDim2.new(0, 44, 0, 22)
                pill.Position = UDim2.new(1, -54, 0.5, -11)
                pill.ZIndex   = 107
                pill.Parent   = row
                Util.corner(pill, 11)

                local pillKnob = Instance.new("Frame")
                pillKnob.BackgroundColor3 = Theme.White
                pillKnob.BorderSizePixel  = 0
                pillKnob.Size             = UDim2.new(0, 16, 0, 16)
                pillKnob.Position         = toggled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                pillKnob.ZIndex           = 108
                pillKnob.Parent           = pill
                Util.corner(pillKnob, 8)

                local pillLbl = Instance.new("TextLabel")
                pillLbl.BackgroundTransparency = 1
                pillLbl.Size          = UDim2.new(1, 0, 1, 0)
                pillLbl.Font          = Enum.Font.GothamBold
                pillLbl.Text          = toggled and "ON" or "OFF"
                pillLbl.TextColor3    = Theme.White
                pillLbl.TextSize      = 9
                pillLbl.TextXAlignment = toggled and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
                pillLbl.ZIndex        = 108
                pillLbl.Parent        = pill
                Util.padding(pillLbl, 0, 0, 4, 4)

                local btn = Instance.new("TextButton")
                btn.BackgroundTransparency = 1
                btn.Size   = UDim2.new(1, 0, 1, 0)
                btn.Text   = ""
                btn.ZIndex = 109
                btn.Parent = row

                btn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    Util.tweenPlay(pill, {BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff}, 0.2)
                    Util.tweenPlay(pillKnob, {Position = toggled and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)}, 0.2, Enum.EasingStyle.Quint)
                    pillLbl.Text = toggled and "ON" or "OFF"
                    pillLbl.TextXAlignment = toggled and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
                    pcall(cb, toggled)
                    Notify(lbl, toggled and "enabled" or "disabled", 2)
                end)

                btn.MouseEnter:Connect(function() Util.tweenPlay(row, {BackgroundTransparency = 0.1}, 0.12) end)
                btn.MouseLeave:Connect(function() Util.tweenPlay(row, {BackgroundTransparency = 0.3}, 0.12) end)

                local obj = {}
                function obj:Set(val)
                    toggled = val
                    Util.tweenPlay(pill, {BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff}, 0.2)
                    Util.tweenPlay(pillKnob, {Position = toggled and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)}, 0.2)
                    pillLbl.Text = toggled and "ON" or "OFF"
                    pillLbl.TextXAlignment = toggled and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
                    pcall(cb, toggled)
                end
                function obj:Get() return toggled end
                return obj
            end

            -- ──────────────────────────────────────────
            --  SLIDER
            -- ──────────────────────────────────────────
            function section:AddSlider(opts2)
                opts2 = opts2 or {}
                local lbl      = opts2.Label    or "Slider"
                local min      = opts2.Min      or 0
                local max      = opts2.Max      or 100
                local default  = opts2.Default  or min
                local decimals = opts2.Decimals or 0
                local suffix   = opts2.Suffix   or ""
                local cb       = opts2.Callback or function() end

                local fmt = decimals > 0 and ("%." .. decimals .. "f") or "%d"
                local currentVal = default
                local dragging   = false

                local row = Instance.new("Frame")
                row.BackgroundColor3      = Theme.BgElement
                row.BackgroundTransparency = 0.3
                row.BorderSizePixel       = 0
                row.Size                  = UDim2.new(1, 0, 0, 52)
                row.ZIndex                = 106
                row.Parent                = itemsCont
                Util.corner(row, 6)

                local topRow = Instance.new("Frame")
                topRow.BackgroundTransparency = 1
                topRow.Size     = UDim2.new(1, 0, 0, 26)
                topRow.ZIndex   = 107
                topRow.Parent   = row

                local sLbl = Instance.new("TextLabel")
                sLbl.BackgroundTransparency = 1
                sLbl.Size          = UDim2.new(1, -80, 1, 0)
                sLbl.Position      = UDim2.new(0, 10, 0, 0)
                sLbl.Font          = Enum.Font.Gotham
                sLbl.Text          = lbl
                sLbl.TextColor3    = Theme.TextPrimary
                sLbl.TextSize      = 13
                sLbl.TextXAlignment = Enum.TextXAlignment.Left
                sLbl.ZIndex        = 108
                sLbl.Parent        = topRow

                -- Editable value box
                local valBox = Instance.new("TextBox")
                valBox.BackgroundColor3      = Theme.BgTertiary
                valBox.BackgroundTransparency = 0.2
                valBox.BorderSizePixel       = 0
                valBox.Size     = UDim2.new(0, 64, 0, 22)
                valBox.Position = UDim2.new(1, -74, 0.5, -11)
                valBox.Font     = Enum.Font.GothamBold
                valBox.Text     = string.format(fmt, currentVal) .. suffix
                valBox.TextColor3 = Theme.Accent
                valBox.TextSize   = 12
                valBox.TextXAlignment = Enum.TextXAlignment.Center
                valBox.ClearTextOnFocus = false
                valBox.ZIndex   = 108
                valBox.Parent   = topRow
                Util.corner(valBox, 5)
                Util.stroke(valBox, Theme.Border, 1, 0.5)

                -- Track
                local trackBg = Instance.new("Frame")
                trackBg.BackgroundColor3      = Theme.BgTertiary
                trackBg.BackgroundTransparency = 0
                trackBg.BorderSizePixel       = 0
                trackBg.Size     = UDim2.new(1, -20, 0, 5)
                trackBg.Position = UDim2.new(0, 10, 0, 36)
                trackBg.ZIndex   = 107
                trackBg.Parent   = row
                Util.corner(trackBg, 3)

                local pct0 = (currentVal - min) / (max - min)

                local trackFill = Instance.new("Frame")
                trackFill.BackgroundColor3 = Theme.Accent
                trackFill.BorderSizePixel  = 0
                trackFill.Size             = UDim2.new(pct0, 0, 1, 0)
                trackFill.ZIndex           = 108
                trackFill.Parent           = trackBg
                Util.corner(trackFill, 3)

                local knob = Instance.new("Frame")
                knob.BackgroundColor3 = Theme.White
                knob.BorderSizePixel  = 0
                knob.Size             = UDim2.new(0, 12, 0, 12)
                knob.Position         = UDim2.new(pct0, -6, 0.5, -6)
                knob.ZIndex           = 109
                knob.Parent           = trackBg
                Util.corner(knob, 6)
                Util.stroke(knob, Theme.Accent, 2, 0.3)

                local function applyVal(v, sendNotif)
                    v = math.clamp(v, min, max)
                    if decimals == 0 then v = math.floor(v + 0.5) end
                    currentVal = v
                    local p = (v - min) / (max - min)
                    Util.tweenPlay(trackFill, {Size = UDim2.new(p, 0, 1, 0)}, 0.08, Enum.EasingStyle.Linear)
                    knob.Position = UDim2.new(p, -6, 0.5, -6)
                    valBox.Text = string.format(fmt, v) .. suffix
                    pcall(cb, v)
                    if sendNotif then
                        Notify(lbl, "set to " .. string.format(fmt, v) .. suffix, 1.8)
                    end
                end

                local trackBtn = Instance.new("TextButton")
                trackBtn.BackgroundTransparency = 1
                trackBtn.Size     = UDim2.new(1, 0, 0, 24)
                trackBtn.Position = UDim2.new(0, 0, 0.5, -12)
                trackBtn.Text     = ""
                trackBtn.ZIndex   = 110
                trackBtn.Parent   = trackBg

                trackBtn.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        local rx = math.clamp((inp.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
                        applyVal(min + rx * (max - min), false)
                    end
                end)

                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
                        dragging = false
                        applyVal(currentVal, true) -- notif only on release
                    end
                end)

                UserInputService.InputChanged:Connect(function(inp)
                    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local rx = math.clamp((inp.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
                        applyVal(min + rx * (max - min), false)
                    end
                end)

                valBox.FocusLost:Connect(function()
                    local raw = valBox.Text:gsub(suffix, "")
                    local v = tonumber(raw)
                    if v then applyVal(v, true)
                    else valBox.Text = string.format(fmt, currentVal) .. suffix end
                end)

                row.MouseEnter:Connect(function() Util.tweenPlay(row, {BackgroundTransparency = 0.1}, 0.12) end)
                row.MouseLeave:Connect(function() Util.tweenPlay(row, {BackgroundTransparency = 0.3}, 0.12) end)

                local obj = {}
                function obj:Set(v) applyVal(v, false) end
                function obj:Get() return currentVal end
                return obj
            end

            -- ──────────────────────────────────────────
            --  BUTTON
            -- ──────────────────────────────────────────
            function section:AddButton(opts2)
                opts2 = opts2 or {}
                local lbl = opts2.Label    or "Button"
                local cb  = opts2.Callback or function() end
                local col = opts2.Color    or Theme.Accent

                local row = Instance.new("TextButton")
                row.BackgroundColor3      = col
                row.BackgroundTransparency = 0.2
                row.BorderSizePixel       = 0
                row.Size                  = UDim2.new(1, 0, 0, 34)
                row.Font                  = Enum.Font.GothamBold
                row.Text                  = lbl
                row.TextColor3            = Theme.White
                row.TextSize              = 13
                row.ZIndex                = 106
                row.Parent                = itemsCont
                Util.corner(row, 6)
                Util.stroke(row, col, 1.5, 0.5)

                row.MouseEnter:Connect(function()
                    Util.tweenPlay(row, {BackgroundTransparency = 0}, 0.15)
                    Util.tweenPlay(row:FindFirstChildOfClass("UIStroke"), {Transparency = 0}, 0.15)
                end)
                row.MouseLeave:Connect(function()
                    Util.tweenPlay(row, {BackgroundTransparency = 0.2}, 0.15)
                    Util.tweenPlay(row:FindFirstChildOfClass("UIStroke"), {Transparency = 0.5}, 0.15)
                end)
                row.MouseButton1Down:Connect(function()
                    Util.tweenPlay(row, {BackgroundTransparency = 0.35, Size = UDim2.new(0.99, 0, 0, 34)}, 0.1)
                end)
                row.MouseButton1Up:Connect(function()
                    Util.tweenPlay(row, {BackgroundTransparency = 0, Size = UDim2.new(1, 0, 0, 34)}, 0.1)
                end)
                row.MouseButton1Click:Connect(function() pcall(cb) end)
            end

            -- ──────────────────────────────────────────
            --  TEXTBOX
            -- ──────────────────────────────────────────
            function section:AddTextBox(opts2)
                opts2 = opts2 or {}
                local lbl     = opts2.Label       or "Input"
                local placeholder = opts2.Placeholder or "type here..."
                local default = opts2.Default     or ""
                local cb      = opts2.Callback    or function() end

                local row = Instance.new("Frame")
                row.BackgroundColor3      = Theme.BgElement
                row.BackgroundTransparency = 0.3
                row.BorderSizePixel       = 0
                row.Size                  = UDim2.new(1, 0, 0, 52)
                row.ZIndex                = 106
                row.Parent                = itemsCont
                Util.corner(row, 6)

                local lbLbl = Instance.new("TextLabel")
                lbLbl.BackgroundTransparency = 1
                lbLbl.Size          = UDim2.new(1, -16, 0, 18)
                lbLbl.Position      = UDim2.new(0, 10, 0, 6)
                lbLbl.Font          = Enum.Font.Gotham
                lbLbl.Text          = lbl
                lbLbl.TextColor3    = Theme.TextSecondary
                lbLbl.TextSize      = 11
                lbLbl.TextXAlignment = Enum.TextXAlignment.Left
                lbLbl.ZIndex        = 107
                lbLbl.Parent        = row

                local tbFrame = Instance.new("Frame")
                tbFrame.BackgroundColor3      = Theme.BgTertiary
                tbFrame.BackgroundTransparency = 0.1
                tbFrame.BorderSizePixel       = 0
                tbFrame.Size     = UDim2.new(1, -20, 0, 24)
                tbFrame.Position = UDim2.new(0, 10, 0, 24)
                tbFrame.ZIndex   = 107
                tbFrame.Parent   = row
                Util.corner(tbFrame, 5)
                local tbStroke = Util.stroke(tbFrame, Theme.Border, 1, 0.4)

                local tb = Instance.new("TextBox")
                tb.BackgroundTransparency = 1
                tb.Size          = UDim2.new(1, -10, 1, 0)
                tb.Position      = UDim2.new(0, 5, 0, 0)
                tb.Font          = Enum.Font.Gotham
                tb.Text          = default
                tb.PlaceholderText = placeholder
                tb.PlaceholderColor3 = Theme.TextMuted
                tb.TextColor3    = Theme.TextPrimary
                tb.TextSize      = 12
                tb.TextXAlignment = Enum.TextXAlignment.Left
                tb.ClearTextOnFocus = false
                tb.ZIndex        = 108
                tb.Parent        = tbFrame

                tb.Focused:Connect(function()
                    Util.tweenPlay(tbStroke, {Color = Theme.Accent, Transparency = 0}, 0.2)
                end)
                tb.FocusLost:Connect(function(enter)
                    Util.tweenPlay(tbStroke, {Color = Theme.Border, Transparency = 0.4}, 0.2)
                    if enter then pcall(cb, tb.Text) end
                end)

                row.MouseEnter:Connect(function() Util.tweenPlay(row, {BackgroundTransparency = 0.1}, 0.12) end)
                row.MouseLeave:Connect(function() Util.tweenPlay(row, {BackgroundTransparency = 0.3}, 0.12) end)

                local obj = {}
                function obj:Get() return tb.Text end
                function obj:Set(v) tb.Text = v end
                return obj
            end

            -- ──────────────────────────────────────────
            --  DROPDOWN
            -- ──────────────────────────────────────────
            function section:AddDropdown(opts2)
                opts2 = opts2 or {}
                local lbl     = opts2.Label    or "Dropdown"
                local items   = opts2.Items    or {}
                local default = opts2.Default  or items[1]
                local cb      = opts2.Callback or function() end

                local selected = default
                local isOpen   = false

                local row = Instance.new("Frame")
                row.BackgroundColor3      = Theme.BgElement
                row.BackgroundTransparency = 0.3
                row.BorderSizePixel       = 0
                row.Size                  = UDim2.new(1, 0, 0, 52)
                row.ZIndex                = 106
                row.ClipsDescendants      = false
                row.Parent                = itemsCont
                Util.corner(row, 6)

                local topHalf = Instance.new("Frame")
                topHalf.BackgroundTransparency = 1
                topHalf.Size     = UDim2.new(1, 0, 0, 52)
                topHalf.ZIndex   = 107
                topHalf.Parent   = row

                local ddLbl = Instance.new("TextLabel")
                ddLbl.BackgroundTransparency = 1
                ddLbl.Size          = UDim2.new(1, -16, 0, 18)
                ddLbl.Position      = UDim2.new(0, 10, 0, 6)
                ddLbl.Font          = Enum.Font.Gotham
                ddLbl.Text          = lbl
                ddLbl.TextColor3    = Theme.TextSecondary
                ddLbl.TextSize      = 11
                ddLbl.TextXAlignment = Enum.TextXAlignment.Left
                ddLbl.ZIndex        = 108
                ddLbl.Parent        = topHalf

                local selFrame = Instance.new("Frame")
                selFrame.BackgroundColor3      = Theme.BgTertiary
                selFrame.BackgroundTransparency = 0.1
                selFrame.BorderSizePixel       = 0
                selFrame.Size     = UDim2.new(1, -20, 0, 24)
                selFrame.Position = UDim2.new(0, 10, 0, 24)
                selFrame.ZIndex   = 108
                selFrame.ClipsDescendants = false
                selFrame.Parent   = topHalf
                Util.corner(selFrame, 5)
                Util.stroke(selFrame, Theme.Border, 1, 0.4)

                local selTxt = Instance.new("TextLabel")
                selTxt.BackgroundTransparency = 1
                selTxt.Size          = UDim2.new(1, -28, 1, 0)
                selTxt.Position      = UDim2.new(0, 8, 0, 0)
                selTxt.Font          = Enum.Font.Gotham
                selTxt.Text          = selected or "select..."
                selTxt.TextColor3    = Theme.TextPrimary
                selTxt.TextSize      = 12
                selTxt.TextXAlignment = Enum.TextXAlignment.Left
                selTxt.ZIndex        = 109
                selTxt.Parent        = selFrame

                local arrow = Instance.new("TextLabel")
                arrow.BackgroundTransparency = 1
                arrow.Size          = UDim2.new(0, 20, 1, 0)
                arrow.Position      = UDim2.new(1, -22, 0, 0)
                arrow.Font          = Enum.Font.GothamBold
                arrow.Text          = "▾"
                arrow.TextColor3    = Theme.Accent
                arrow.TextSize      = 12
                arrow.ZIndex        = 109
                arrow.Parent        = selFrame

                -- Dropdown list (overlays below)
                local ddList = Instance.new("Frame")
                ddList.BackgroundColor3      = Theme.BgSecondary
                ddList.BackgroundTransparency = 0
                ddList.BorderSizePixel       = 0
                ddList.Size     = UDim2.new(1, -20, 0, 0)
                ddList.Position = UDim2.new(0, 10, 1, 2)
                ddList.ZIndex   = 200
                ddList.ClipsDescendants = false
                ddList.Visible  = false
                ddList.Parent   = selFrame
                Util.corner(ddList, 5)
                Util.stroke(ddList, Theme.Border, 1, 0.3)

                local ddItemLayout = Util.listLayout(ddList, Enum.FillDirection.Vertical, 2)
                Util.padding(ddList, 4, 4, 4, 4)

                local function closeDropdown()
                    isOpen = false
                    arrow.Text = "▾"
                    ddList.Visible = false
                end

                local function openDropdown()
                    isOpen = true
                    arrow.Text = "▴"
                    ddList.Visible = true
                    -- Build items
                    for _, child in ipairs(ddList:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, item in ipairs(items) do
                        local ib = Instance.new("TextButton")
                        ib.BackgroundColor3      = item == selected and Theme.Accent or Theme.BgTertiary
                        ib.BackgroundTransparency = item == selected and 0.2 or 0.5
                        ib.BorderSizePixel       = 0
                        ib.Size   = UDim2.new(1, 0, 0, 26)
                        ib.Font   = Enum.Font.Gotham
                        ib.Text   = item
                        ib.TextColor3 = item == selected and Theme.White or Theme.TextPrimary
                        ib.TextSize   = 12
                        ib.ZIndex     = 201
                        ib.Parent     = ddList
                        Util.corner(ib, 4)
                        ib.MouseButton1Click:Connect(function()
                            selected = item
                            selTxt.Text = item
                            pcall(cb, item)
                            closeDropdown()
                            Notify(lbl, "selected: " .. item, 1.8)
                        end)
                        ib.MouseEnter:Connect(function() Util.tweenPlay(ib, {BackgroundTransparency = 0.2, BackgroundColor3 = Theme.Accent}, 0.1) end)
                        ib.MouseLeave:Connect(function()
                            Util.tweenPlay(ib, {
                                BackgroundTransparency = item == selected and 0.2 or 0.5,
                                BackgroundColor3 = item == selected and Theme.Accent or Theme.BgTertiary
                            }, 0.1)
                        end)
                    end
                    -- Size list
                    local h = #items * 28 + 8
                    ddList.Size = UDim2.new(1, -20, 0, math.min(h, 120))
                    if h > 120 then
                        local sv = Instance.new("ScrollingFrame")
                        -- keep simple, just clip
                        ddList.ClipsDescendants = true
                    end
                end

                local headerBtn = Instance.new("TextButton")
                headerBtn.BackgroundTransparency = 1
                headerBtn.Size   = UDim2.new(1, 0, 1, 0)
                headerBtn.Text   = ""
                headerBtn.ZIndex = 110
                headerBtn.Parent = selFrame
                headerBtn.MouseButton1Click:Connect(function()
                    if isOpen then closeDropdown() else openDropdown() end
                end)

                row.MouseEnter:Connect(function() Util.tweenPlay(row, {BackgroundTransparency = 0.1}, 0.12) end)
                row.MouseLeave:Connect(function() Util.tweenPlay(row, {BackgroundTransparency = 0.3}, 0.12) end)

                local obj = {}
                function obj:Get() return selected end
                function obj:Set(v) selected = v selTxt.Text = v end
                function obj:SetItems(newItems) items = newItems end
                return obj
            end

            -- ──────────────────────────────────────────
            --  KEYBIND
            -- ──────────────────────────────────────────
            function section:AddKeybind(opts2)
                opts2 = opts2 or {}
                local lbl     = opts2.Label    or "Keybind"
                local default = opts2.Default  or Enum.KeyCode.RightControl
                local cb      = opts2.Callback or function() end

                local currentKey = default
                local listening  = false

                local row = Instance.new("Frame")
                row.BackgroundColor3      = Theme.BgElement
                row.BackgroundTransparency = 0.3
                row.BorderSizePixel       = 0
                row.Size                  = UDim2.new(1, 0, 0, 36)
                row.ZIndex                = 106
                row.Parent                = itemsCont
                Util.corner(row, 6)

                local kLbl = Instance.new("TextLabel")
                kLbl.BackgroundTransparency = 1
                kLbl.Size          = UDim2.new(1, -100, 1, 0)
                kLbl.Position      = UDim2.new(0, 10, 0, 0)
                kLbl.Font          = Enum.Font.Gotham
                kLbl.Text          = lbl
                kLbl.TextColor3    = Theme.TextPrimary
                kLbl.TextSize      = 13
                kLbl.TextXAlignment = Enum.TextXAlignment.Left
                kLbl.ZIndex        = 107
                kLbl.Parent        = row

                local kBtn = Instance.new("TextButton")
                kBtn.BackgroundColor3      = Theme.BgTertiary
                kBtn.BackgroundTransparency = 0.2
                kBtn.BorderSizePixel       = 0
                kBtn.Size     = UDim2.new(0, 78, 0, 24)
                kBtn.Position = UDim2.new(1, -88, 0.5, -12)
                kBtn.Font     = Enum.Font.GothamBold
                kBtn.Text     = currentKey.Name
                kBtn.TextColor3 = Theme.Accent
                kBtn.TextSize   = 11
                kBtn.ZIndex     = 108
                kBtn.Parent     = row
                Util.corner(kBtn, 5)
                Util.stroke(kBtn, Theme.Border, 1, 0.4)

                kBtn.MouseButton1Click:Connect(function()
                    listening = true
                    kBtn.Text = "..."
                    kBtn.TextColor3 = Theme.AccentLight
                    Util.tweenPlay(kBtn:FindFirstChildOfClass("UIStroke"), {Color = Theme.Accent, Transparency = 0}, 0.15)
                end)

                UserInputService.InputBegan:Connect(function(inp, gp)
                    if not listening then return end
                    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    listening = false
                    currentKey = inp.KeyCode
                    kBtn.Text = currentKey.Name
                    kBtn.TextColor3 = Theme.Accent
                    Util.tweenPlay(kBtn:FindFirstChildOfClass("UIStroke"), {Color = Theme.Border, Transparency = 0.4}, 0.15)
                    pcall(cb, currentKey)
                    Notify(lbl, "bound to: " .. currentKey.Name, 1.8)
                end)

                row.MouseEnter:Connect(function() Util.tweenPlay(row, {BackgroundTransparency = 0.1}, 0.12) end)
                row.MouseLeave:Connect(function() Util.tweenPlay(row, {BackgroundTransparency = 0.3}, 0.12) end)

                local obj = {}
                function obj:Get() return currentKey end
                function obj:Set(k) currentKey = k kBtn.Text = k.Name end
                return obj
            end

            -- ──────────────────────────────────────────
            --  COLOUR PICKER
            -- ──────────────────────────────────────────
            function section:AddColorPicker(opts2)
                opts2 = opts2 or {}
                local lbl     = opts2.Label    or "Color"
                local default = opts2.Default  or Theme.Accent
                local cb      = opts2.Callback or function() end

                local currentColor = default
                local pickerOpen   = false

                local row = Instance.new("Frame")
                row.BackgroundColor3      = Theme.BgElement
                row.BackgroundTransparency = 0.3
                row.BorderSizePixel       = 0
                row.Size                  = UDim2.new(1, 0, 0, 36)
                row.ZIndex                = 106
                row.ClipsDescendants      = false
                row.Parent                = itemsCont
                Util.corner(row, 6)

                local cpLbl = Instance.new("TextLabel")
                cpLbl.BackgroundTransparency = 1
                cpLbl.Size          = UDim2.new(1, -80, 1, 0)
                cpLbl.Position      = UDim2.new(0, 10, 0, 0)
                cpLbl.Font          = Enum.Font.Gotham
                cpLbl.Text          = lbl
                cpLbl.TextColor3    = Theme.TextPrimary
                cpLbl.TextSize      = 13
                cpLbl.TextXAlignment = Enum.TextXAlignment.Left
                cpLbl.ZIndex        = 107
                cpLbl.Parent        = row

                local swatchFrame = Instance.new("Frame")
                swatchFrame.BackgroundColor3 = currentColor
                swatchFrame.BorderSizePixel  = 0
                swatchFrame.Size     = UDim2.new(0, 48, 0, 24)
                swatchFrame.Position = UDim2.new(1, -58, 0.5, -12)
                swatchFrame.ZIndex   = 107
                swatchFrame.Parent   = row
                Util.corner(swatchFrame, 5)
                Util.stroke(swatchFrame, Theme.Border, 1, 0.3)

                -- Full colour picker panel
                local picker = Instance.new("Frame")
                picker.BackgroundColor3      = Theme.BgSecondary
                picker.BackgroundTransparency = 0
                picker.BorderSizePixel       = 0
                picker.Size     = UDim2.new(0, 220, 0, 220)
                picker.Position = UDim2.new(1, 4, 0, 0)
                picker.ZIndex   = 300
                picker.Visible  = false
                picker.Parent   = row
                Util.corner(picker, 10)
                Util.stroke(picker, Theme.Border, 1.5, 0.2)

                -- H/S/V Sliders inside picker
                local pickerLayout = Util.listLayout(picker, Enum.FillDirection.Vertical, 6)
                Util.padding(picker, 10, 10, 10, 10)

                local hsvLabels = {"H", "S", "V"}
                local hsvMax    = {360, 100, 100}
                local hsv       = {currentColor:ToHSV()}
                hsv[1] = math.floor(hsv[1] * 360)
                hsv[2] = math.floor(hsv[2] * 100)
                hsv[3] = math.floor(hsv[3] * 100)

                local function rebuildColor()
                    currentColor = Color3.fromHSV(hsv[1]/360, hsv[2]/100, hsv[3]/100)
                    swatchFrame.BackgroundColor3 = currentColor
                    pcall(cb, currentColor)
                end

                for i, chName in ipairs(hsvLabels) do
                    local li = i
                    local hRow = Instance.new("Frame")
                    hRow.BackgroundTransparency = 1
                    hRow.BorderSizePixel = 0
                    hRow.Size   = UDim2.new(1, 0, 0, 44)
                    hRow.ZIndex = 301
                    hRow.Parent = picker

                    local hLblI = Instance.new("TextLabel")
                    hLblI.BackgroundTransparency = 1
                    hLblI.Size     = UDim2.new(0, 14, 0, 16)
                    hLblI.Position = UDim2.new(0, 0, 0, 4)
                    hLblI.Font     = Enum.Font.GothamBold
                    hLblI.Text     = chName
                    hLblI.TextColor3 = Theme.Accent
                    hLblI.TextSize   = 11
                    hLblI.ZIndex   = 302
                    hLblI.Parent   = hRow

                    local hTrackBg = Instance.new("Frame")
                    hTrackBg.BackgroundColor3      = Theme.BgTertiary
                    hTrackBg.BackgroundTransparency = 0
                    hTrackBg.BorderSizePixel       = 0
                    hTrackBg.Size     = UDim2.new(1, -50, 0, 5)
                    hTrackBg.Position = UDim2.new(0, 18, 0, 8)
                    hTrackBg.ZIndex   = 301
                    hTrackBg.Parent   = hRow
                    Util.corner(hTrackBg, 3)

                    local hFill = Instance.new("Frame")
                    hFill.BackgroundColor3 = Theme.Accent
                    hFill.BorderSizePixel  = 0
                    hFill.Size             = UDim2.new(hsv[li]/hsvMax[li], 0, 1, 0)
                    hFill.ZIndex           = 302
                    hFill.Parent           = hTrackBg
                    Util.corner(hFill, 3)

                    local hKnob = Instance.new("Frame")
                    hKnob.BackgroundColor3 = Theme.White
                    hKnob.BorderSizePixel  = 0
                    hKnob.Size             = UDim2.new(0, 11, 0, 11)
                    hKnob.Position         = UDim2.new(hsv[li]/hsvMax[li], -5, 0.5, -5)
                    hKnob.ZIndex           = 303
                    hKnob.Parent           = hTrackBg
                    Util.corner(hKnob, 6)

                    local hValLbl = Instance.new("TextLabel")
                    hValLbl.BackgroundTransparency = 1
                    hValLbl.Size     = UDim2.new(0, 28, 0, 16)
                    hValLbl.Position = UDim2.new(1, -28, 0, 4)
                    hValLbl.Font     = Enum.Font.GothamBold
                    hValLbl.Text     = tostring(hsv[li])
                    hValLbl.TextColor3 = Theme.TextPrimary
                    hValLbl.TextSize   = 10
                    hValLbl.TextXAlignment = Enum.TextXAlignment.Right
                    hValLbl.ZIndex   = 302
                    hValLbl.Parent   = hRow

                    local hDragging = false
                    local hBtn = Instance.new("TextButton")
                    hBtn.BackgroundTransparency = 1
                    hBtn.Size     = UDim2.new(1, 0, 0, 20)
                    hBtn.Position = UDim2.new(0, 0, 0.5, -10)
                    hBtn.Text     = ""
                    hBtn.ZIndex   = 304
                    hBtn.Parent   = hTrackBg

                    local function updateH(pos)
                        local rx = math.clamp((pos.X - hTrackBg.AbsolutePosition.X) / hTrackBg.AbsoluteSize.X, 0, 1)
                        hsv[li] = math.floor(rx * hsvMax[li] + 0.5)
                        hFill.Size     = UDim2.new(rx, 0, 1, 0)
                        hKnob.Position = UDim2.new(rx, -5, 0.5, -5)
                        hValLbl.Text   = tostring(hsv[li])
                        rebuildColor()
                    end

                    hBtn.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                            hDragging = true updateH(inp.Position)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then hDragging = false end
                    end)
                    UserInputService.InputChanged:Connect(function(inp)
                        if hDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then updateH(inp.Position) end
                    end)
                end

                -- Hex input
                local hexFrame = Instance.new("Frame")
                hexFrame.BackgroundColor3      = Theme.BgTertiary
                hexFrame.BackgroundTransparency = 0.2
                hexFrame.BorderSizePixel       = 0
                hexFrame.Size     = UDim2.new(1, 0, 0, 26)
                hexFrame.ZIndex   = 301
                hexFrame.Parent   = picker
                Util.corner(hexFrame, 5)
                Util.stroke(hexFrame, Theme.Border, 1, 0.4)

                local hexPre = Instance.new("TextLabel")
                hexPre.BackgroundTransparency = 1
                hexPre.Size     = UDim2.new(0, 16, 1, 0)
                hexPre.Font     = Enum.Font.GothamBold
                hexPre.Text     = "#"
                hexPre.TextColor3 = Theme.Accent
                hexPre.TextSize   = 12
                hexPre.ZIndex     = 302
                hexPre.Parent     = hexFrame
                Util.padding(hexPre, 0, 0, 4, 0)

                local function colorToHex(c)
                    return string.format("%02X%02X%02X",
                        math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
                end

                local hexBox = Instance.new("TextBox")
                hexBox.BackgroundTransparency = 1
                hexBox.Size          = UDim2.new(1, -20, 1, 0)
                hexBox.Position      = UDim2.new(0, 16, 0, 0)
                hexBox.Font          = Enum.Font.Code
                hexBox.Text          = colorToHex(currentColor)
                hexBox.TextColor3    = Theme.TextPrimary
                hexBox.TextSize      = 12
                hexBox.ClearTextOnFocus = false
                hexBox.ZIndex        = 302
                hexBox.Parent        = hexFrame

                hexBox.FocusLost:Connect(function()
                    local hex = hexBox.Text:gsub("#","")
                    if #hex == 6 then
                        local r = tonumber(hex:sub(1,2), 16)
                        local g = tonumber(hex:sub(3,4), 16)
                        local b = tonumber(hex:sub(5,6), 16)
                        if r and g and b then
                            currentColor = Color3.fromRGB(r,g,b)
                            swatchFrame.BackgroundColor3 = currentColor
                            local nh = {currentColor:ToHSV()}
                            hsv[1] = math.floor(nh[1]*360)
                            hsv[2] = math.floor(nh[2]*100)
                            hsv[3] = math.floor(nh[3]*100)
                            pcall(cb, currentColor)
                        end
                    end
                    hexBox.Text = colorToHex(currentColor)
                end)

                local swatchBtn = Instance.new("TextButton")
                swatchBtn.BackgroundTransparency = 1
                swatchBtn.Size   = UDim2.new(1, 0, 1, 0)
                swatchBtn.Text   = ""
                swatchBtn.ZIndex = 108
                swatchBtn.Parent = swatchFrame

                swatchBtn.MouseButton1Click:Connect(function()
                    pickerOpen = not pickerOpen
                    picker.Visible = pickerOpen
                    if pickerOpen then
                        hexBox.Text = colorToHex(currentColor)
                    end
                end)

                -- Close picker when clicking elsewhere
                UserInputService.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 and pickerOpen then
                        local mp = UserInputService:GetMouseLocation()
                        local ap = picker.AbsolutePosition
                        local as = picker.AbsoluteSize
                        if mp.X < ap.X or mp.X > ap.X + as.X or mp.Y < ap.Y or mp.Y > ap.Y + as.Y then
                            pickerOpen = false
                            picker.Visible = false
                        end
                    end
                end)

                row.MouseEnter:Connect(function() Util.tweenPlay(row, {BackgroundTransparency = 0.1}, 0.12) end)
                row.MouseLeave:Connect(function() Util.tweenPlay(row, {BackgroundTransparency = 0.3}, 0.12) end)

                local obj = {}
                function obj:Get() return currentColor end
                function obj:Set(c)
                    currentColor = c
                    swatchFrame.BackgroundColor3 = c
                    local nh = {c:ToHSV()}
                    hsv[1] = math.floor(nh[1]*360)
                    hsv[2] = math.floor(nh[2]*100)
                    hsv[3] = math.floor(nh[3]*100)
                end
                return obj
            end

            -- ──────────────────────────────────────────
            --  LABEL
            -- ──────────────────────────────────────────
            function section:AddLabel(text)
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Size          = UDim2.new(1, -20, 0, 22)
                lbl.Font          = Enum.Font.Gotham
                lbl.Text          = text
                lbl.TextColor3    = Theme.TextSecondary
                lbl.TextSize      = 12
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.TextWrapped   = true
                lbl.ZIndex        = 107
                lbl.Parent        = itemsCont
                Util.padding(lbl, 0, 0, 10, 0)

                local obj = {}
                function obj:Set(t) lbl.Text = t end
                return obj
            end

            -- ──────────────────────────────────────────
            --  DIVIDER
            -- ──────────────────────────────────────────
            function section:AddDivider(labelText)
                local dFrame = Instance.new("Frame")
                dFrame.BackgroundTransparency = 1
                dFrame.BorderSizePixel        = 0
                dFrame.Size                   = UDim2.new(1, 0, 0, 18)
                dFrame.ZIndex                 = 107
                dFrame.Parent                 = itemsCont

                local dLine = Instance.new("Frame")
                dLine.BackgroundColor3      = Theme.Border
                dLine.BackgroundTransparency = 0.3
                dLine.BorderSizePixel       = 0
                dLine.Size     = UDim2.new(1, -20, 0, 1)
                dLine.Position = UDim2.new(0, 10, 0.5, 0)
                dLine.ZIndex   = 108
                dLine.Parent   = dFrame
                Util.corner(dLine, 1)

                if labelText then
                    dLine.Size     = UDim2.new(0.4, 0, 0, 1)
                    dLine.Position = UDim2.new(0, 10, 0.5, 0)

                    local dLine2 = Instance.new("Frame")
                    dLine2.BackgroundColor3      = Theme.Border
                    dLine2.BackgroundTransparency = 0.3
                    dLine2.BorderSizePixel       = 0
                    dLine2.Size     = UDim2.new(0.35, 0, 0, 1)
                    dLine2.Position = UDim2.new(0.65, -10, 0.5, 0)
                    dLine2.ZIndex   = 108
                    dLine2.Parent   = dFrame
                    Util.corner(dLine2, 1)

                    local dLbl = Instance.new("TextLabel")
                    dLbl.BackgroundTransparency = 1
                    dLbl.Size          = UDim2.new(0.2, 0, 1, 0)
                    dLbl.Position      = UDim2.new(0.4, 0, 0, 0)
                    dLbl.Font          = Enum.Font.Gotham
                    dLbl.Text          = labelText
                    dLbl.TextColor3    = Theme.TextMuted
                    dLbl.TextSize      = 10
                    dLbl.TextXAlignment = Enum.TextXAlignment.Center
                    dLbl.ZIndex        = 109
                    dLbl.Parent        = dFrame
                end
            end

            table.insert(tab._sections, section)
            return section
        end -- AddSection

        return tab
    end -- AddTab

    -- ──────────────────────────────────────────
    --  PLAYER LIST PANEL
    -- ──────────────────────────────────────────
    function win:AddPlayerList()
        -- Side panel on the right
        local plPanel = Instance.new("Frame")
        plPanel.BackgroundColor3      = Theme.BgSecondary
        plPanel.BackgroundTransparency = 0
        plPanel.BorderSizePixel       = 0
        plPanel.Size                  = UDim2.new(0, 160, 1, -46)
        plPanel.Position              = UDim2.new(1, -160, 0, 46)
        plPanel.ZIndex                = 102
        plPanel.Parent                = frame

        -- Adjust contentArea width
        contentArea.Size = UDim2.new(1, -290, 1, 0)

        Util.corner(plPanel, 0)
        -- Round only bottom-right
        local plStroke = Instance.new("Frame")
        plStroke.BackgroundColor3 = Theme.Border
        plStroke.BackgroundTransparency = 0.4
        plStroke.BorderSizePixel = 0
        plStroke.Size     = UDim2.new(0, 1, 1, 0)
        plStroke.ZIndex   = 103
        plStroke.Parent   = plPanel

        local plTitle = Instance.new("TextLabel")
        plTitle.BackgroundTransparency = 1
        plTitle.Size          = UDim2.new(1, 0, 0, 30)
        plTitle.Position      = UDim2.new(0, 0, 0, 0)
        plTitle.Font          = Enum.Font.GothamBold
        plTitle.Text          = "PLAYERS"
        plTitle.TextColor3    = Theme.Accent
        plTitle.TextSize      = 11
        plTitle.TextXAlignment = Enum.TextXAlignment.Center
        plTitle.ZIndex        = 104
        plTitle.Parent        = plPanel

        local plSep = Instance.new("Frame")
        plSep.BackgroundColor3 = Theme.Accent
        plSep.BackgroundTransparency = 0.6
        plSep.BorderSizePixel = 0
        plSep.Size     = UDim2.new(1, -20, 0, 1)
        plSep.Position = UDim2.new(0, 10, 0, 30)
        plSep.ZIndex   = 104
        plSep.Parent   = plPanel

        -- Count label
        local plCount = Instance.new("TextLabel")
        plCount.BackgroundTransparency = 1
        plCount.Size          = UDim2.new(1, 0, 0, 18)
        plCount.Position      = UDim2.new(0, 0, 0, 32)
        plCount.Font          = Enum.Font.Gotham
        plCount.Text          = "0 players"
        plCount.TextColor3    = Theme.TextMuted
        plCount.TextSize      = 10
        plCount.TextXAlignment = Enum.TextXAlignment.Center
        plCount.ZIndex        = 104
        plCount.Parent        = plPanel

        local plScroll = Instance.new("ScrollingFrame")
        plScroll.BackgroundTransparency = 1
        plScroll.BorderSizePixel        = 0
        plScroll.Size                   = UDim2.new(1, 0, 1, -52)
        plScroll.Position               = UDim2.new(0, 0, 0, 52)
        plScroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
        plScroll.ScrollBarThickness     = 2
        plScroll.ScrollBarImageColor3   = Theme.Accent
        plScroll.ScrollBarImageTransparency = 0.5
        plScroll.ZIndex                 = 104
        plScroll.Parent                 = plPanel
        Util.padding(plScroll, 2, 2, 4, 4)

        local plLayout = Util.listLayout(plScroll, Enum.FillDirection.Vertical, 3)
        Util.autoCanvas(plScroll, plLayout)

        local playerCards = {}

        local function getTeamColor(player)
            local ok, team = pcall(function() return player.Team end)
            if ok and team then return team.TeamColor.Color end
            return Theme.TextMuted
        end

        local function addPlayerCard(player)
            if playerCards[player] then return end

            local pCard = Instance.new("Frame")
            pCard.BackgroundColor3      = Theme.BgElement
            pCard.BackgroundTransparency = 0.3
            pCard.BorderSizePixel       = 0
            pCard.Size                  = UDim2.new(1, 0, 0, 34)
            pCard.ZIndex                = 105
            pCard.Parent                = plScroll
            Util.corner(pCard, 5)

            -- Avatar thumb
            local thumb = Instance.new("ImageLabel")
            thumb.BackgroundColor3      = Theme.BgTertiary
            thumb.BackgroundTransparency = 0
            thumb.BorderSizePixel       = 0
            thumb.Size     = UDim2.new(0, 24, 0, 24)
            thumb.Position = UDim2.new(0, 4, 0.5, -12)
            thumb.Image    = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=48&height=48&format=png"
            thumb.ZIndex   = 106
            thumb.Parent   = pCard
            Util.corner(thumb, 12)

            local nameL = Instance.new("TextLabel")
            nameL.BackgroundTransparency = 1
            nameL.Size          = UDim2.new(1, -34, 0, 16)
            nameL.Position      = UDim2.new(0, 32, 0, 5)
            nameL.Font          = Enum.Font.GothamBold
            nameL.Text          = player.DisplayName
            nameL.TextColor3    = player == LocalPlayer and Theme.Accent or Theme.TextPrimary
            nameL.TextSize      = 10
            nameL.TextTruncate  = Enum.TextTruncate.AtEnd
            nameL.TextXAlignment = Enum.TextXAlignment.Left
            nameL.ZIndex        = 106
            nameL.Parent        = pCard

            local nameL2 = Instance.new("TextLabel")
            nameL2.BackgroundTransparency = 1
            nameL2.Size          = UDim2.new(1, -34, 0, 12)
            nameL2.Position      = UDim2.new(0, 32, 0, 18)
            nameL2.Font          = Enum.Font.Gotham
            nameL2.Text          = "@" .. player.Name
            nameL2.TextColor3    = Theme.TextMuted
            nameL2.TextSize      = 9
            nameL2.TextTruncate  = Enum.TextTruncate.AtEnd
            nameL2.TextXAlignment = Enum.TextXAlignment.Left
            nameL2.ZIndex        = 106
            nameL2.Parent        = pCard

            -- Live dot
            local dot = Instance.new("Frame")
            dot.BackgroundColor3 = Theme.ToggleOn
            dot.BorderSizePixel  = 0
            dot.Size     = UDim2.new(0, 5, 0, 5)
            dot.Position = UDim2.new(1, -9, 0.5, -2)
            dot.ZIndex   = 106
            dot.Parent   = pCard
            Util.corner(dot, 3)

            playerCards[player] = pCard
            plCount.Text = tostring(#Players:GetPlayers()) .. " online"
        end

        local function removePlayerCard(player)
            if playerCards[player] then
                playerCards[player]:Destroy()
                playerCards[player] = nil
            end
            plCount.Text = tostring(#Players:GetPlayers()) .. " online"
        end

        -- Populate existing
        for _, p in ipairs(Players:GetPlayers()) do
            addPlayerCard(p)
        end

        Players.PlayerAdded:Connect(function(p)
            addPlayerCard(p)
            Notify("Player Joined", p.DisplayName .. " (@" .. p.Name .. ")", 3)
        end)

        Players.PlayerRemoving:Connect(function(p)
            removePlayerCard(p)
            Notify("Player Left", p.DisplayName .. " (@" .. p.Name .. ")", 3)
        end)
    end

    return win
end -- CreateWindow

-- ════════════════════════════════════════════════════════════════════
--  CONFIG SYSTEM
-- ════════════════════════════════════════════════════════════════════
local ConfigSystem = {}

local function getConfigPath(name)
    return Library._configFolder .. "/" .. name .. ".json"
end

function ConfigSystem:Save(name, data)
    pcall(function()
        if not isfolder(Library._configFolder) then
            makefolder(Library._configFolder)
        end
        writefile(getConfigPath(name), HttpService:JSONEncode(data))
    end)
    Notify("Config", "saved: " .. name, 2)
end

function ConfigSystem:Load(name)
    local ok, result = pcall(function()
        if isfile(getConfigPath(name)) then
            return HttpService:JSONDecode(readfile(getConfigPath(name)))
        end
        return nil
    end)
    if ok and result then
        Notify("Config", "loaded: " .. name, 2)
        return result
    end
    Notify("Config", "not found: " .. name, 2, "error")
    return nil
end

function ConfigSystem:Delete(name)
    pcall(function()
        delfile(getConfigPath(name))
    end)
    Notify("Config", "deleted: " .. name, 2)
end

function ConfigSystem:List()
    local files = {}
    pcall(function()
        if isfolder(Library._configFolder) then
            for _, f in ipairs(listfiles(Library._configFolder)) do
                local n = f:gsub(Library._configFolder .. "/", ""):gsub(".json", "")
                table.insert(files, n)
            end
        end
    end)
    return files
end

Library.Config  = ConfigSystem
Library.Notify  = Notify
Library.Theme   = Theme

-- ════════════════════════════════════════════════════════════════════
--  INIT SEQUENCE  (Loader → Key → Main)
-- ════════════════════════════════════════════════════════════════════
function Library:Init(callback)
    showLoader(function()
        showKeySystem(function()
            -- Fade in bg
            BgLayer.Visible = false
            if callback then callback() end
            -- Welcome notif after tiny delay
            task.delay(0.3, function()
                Notify("leisure.gg", "welcome! scripts loaded successfully.", 4)
            end)
        end)
    end)
end

_G.LeisureLib = Library
return Library
