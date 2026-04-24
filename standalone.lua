--[[
    leisure.gg - Complete Combat Script
    Made by @x_vvw
    For Da Strike / Da Uphill
]]

--// SILENT AIM - Da Strike / Da Uphill

getgenv().ResolveKey = "C"
getgenv().CamlockKey = "F"
getgenv().SilentKey = "V"
getgenv().AutoAirKey = "B"
getgenv().TriggerKey = "T"
getgenv().GuiKey = "M"
getgenv().LegitSmoothKey = "L"
getgenv().BlatantKey = "K"
getgenv().SilentLockKey = "Q"
getgenv().AutoShootKey = "J"
getgenv().ComboKey = "N"
getgenv().FreeAutoAirKey = "U"
getgenv().IncFreeAutoAirFOVKey = "]"
getgenv().DecFreeAutoAirFOVKey = "["

-- === SETTINGS ===
getgenv().Smoothing = 0.35
getgenv().LegitSmoothing = 0.040
getgenv().BlatantSmoothing = 0.070
getgenv().BasePred = 0.18
getgenv().PredPingFactor = 0.00029
getgenv().PredDistFactor = 0.000052
getgenv().PredVelFactor = 0
getgenv().MaxPred = 0.18
getgenv().MinPred = 0.18
getgenv().PredX = 0.18
getgenv().PredY = 0.18
getgenv().Radius = 235
getgenv().TriggerFOV = 50
getgenv().FreeAutoAirFOV = 27
getgenv().JumpOffsetBase = 0.034
getgenv().FallOffsetBase = 0.034
getgenv().AirExtraBoostBase = 0.048
getgenv().AirVelFactor = 0
getgenv().VelSmooth = 0.034
getgenv().airTriggerDelay = 0.15
getgenv().airFireRate = 0
getgenv().TriggerFireRate = 0
getgenv().useHoldMode = false

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local WS = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

--// REMOTE DETECTION
local MainRemote = nil
local ShootArg = nil
local detectedGame = "Unknown"

local function detectRemote()
    if RS:FindFirstChild("MAINEVENT") then
        MainRemote = RS.MAINEVENT
        ShootArg = "MOUSE"
        detectedGame = "Da Strike"
    elseif RS:FindFirstChild("MainEvent") then
        MainRemote = RS.MainEvent
        ShootArg = "UpdateMousePos"
        detectedGame = "Da Hood"
    else
        for _, remote in ipairs(RS:GetChildren()) do
            if remote:IsA("RemoteEvent") and (remote.Name:lower():find("main") or remote.Name:lower():find("shoot") or remote.Name:lower():find("mouse")) then
                MainRemote = remote
                ShootArg = "UpdateMousePos"
                detectedGame = "Copy (" .. remote.Name .. ")"
                break
            end
        end
    end
end

detectRemote()
if not MainRemote then
    warn("Unsupported game!")
    return
end
print("Detected: " .. detectedGame .. " | leisure.gg")

--// WHITELIST SYSTEM
local whitelist = {}

local function isWhitelisted(player)
    return whitelist[player.UserId] == true
end

local function toggleWhitelist(player)
    if isWhitelisted(player) then
        whitelist[player.UserId] = nil
        return false
    else
        whitelist[player.UserId] = true
        return true
    end
end

--// STAFF DETECTION LIST (UPDATED)
local STAFF_IDS = {
    1617828795, 4004110354, 2596448591, 7523797355, 1236712946,
    4179791578, 3812472402, 3543999912, 968660321, 7333069745,
    7157153757, 3587870844, 2631808298, 621822647, 1094365126,
    3855523132, 2732386174, 10452135555, 848355298, 9754156539,
    10777665227, 41234321, 2400924396, 167515541, 10428537936,
    10398386750, 7627361, 4160998891, 10688896660, 1625652054,
    1140775443, 10688080297, 2324239577, 1499556980, 43829894,
    7707645153, 3253044731, 4559062275, 14100504, 8127126958,
    2892547873, 3103057356, 2219142671, 3011358513, 1926407929, 32435725
}

local function isStaff(player)
    for _, id in pairs(STAFF_IDS) do
        if player.UserId == id then
            return true
        end
    end
    return false
end

--// STATE
local resolver = false
local silentAim = false
local camlock = false
local lockedTarget = nil
local autoAirFire = false
local triggerBot = false
local legitSmooth = false
local blatantMode = false
local silentLockEnabled = false
local silentLockedTarget = nil
local autoShoot = false
local comboMode = false
local freeAutoAir = false

local lastPos, lastTime, lastVel, velHistory = {}, {}, {}, {}
local airStart = {}
local hitCount = 0
local currentPing = 50
local lastAutoFire = 0
local lastTriggerFire = 0
local lastAutoShoot = 0
local lastFreeAutoAirFire = 0
local forceTarget = nil

--// NOTIFICATION FUNCTION
local function sendNotification(title, text, icon)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Icon = "rbxassetid://95448083455045",
            Duration = 3
        })
    end)
end

--// ANTI-GROUND
local function isRagdolled(plr)
    if not plr or not plr.Character then return false end
    local hum = plr.Character:FindFirstChild("Humanoid")
    if not hum then return false end
    if hum.Health <= 1 then return true end
    local state = hum:GetState()
    if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.Physics then
        return true
    end
    if hum.PlatformStand then return true end
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local yAxis = root.CFrame.UpVector.Y
        if math.abs(yAxis) < 0.7 then return true end
    end
    return false
end

local function isKatana(tool)
    if not tool then return false end
    local n = tool.Name:lower()
    return n:find("katana") or (tool.ToolTip and tool.ToolTip:lower():find("katana"))
end

local function isVisible(plr)
    if not plr or not plr.Character or not LocalPlayer.Character then return false end
    if isRagdolled(plr) then return false end
    local targetPart = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("Torso") or plr.Character:FindFirstChild("HumanoidRootPart")
    if not targetPart then return false end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    local result = WS:Raycast(origin, direction, raycastParams)
    if not result then return true end
    return result.Instance and result.Instance:IsDescendantOf(plr.Character)
end

--// PING LOOP
task.spawn(function()
    while task.wait(0.3) do
        local pingItem = Stats.Network.ServerStatsItem["Data Ping"]
        currentPing = pingItem and pingItem:GetValue() or 50
    end
end)

--// PREDICTION
local function getPred(target)
    local pingMs = currentPing
    local base = getgenv().BasePred + (pingMs * getgenv().PredPingFactor)
    if target and target.Character and LocalPlayer.Character then
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and myRoot then
            local dist = (targetRoot.Position - myRoot.Position).Magnitude
            base = base + dist * getgenv().PredDistFactor
            local targetVel = targetRoot.AssemblyLinearVelocity
            local myVel = myRoot.AssemblyLinearVelocity
            local relVel = (targetVel - myVel).Magnitude
            base = base + relVel * getgenv().PredVelFactor
            if relVel > 55 then base = base + (relVel - 55) * 0.0028 end
            if blatantMode then base = base - 0.0035 end
            local hum = target.Character:FindFirstChild("Humanoid")
            if hum and (hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall) then
                base = base + (math.abs(targetVel.Y) > 12 and 0.0032 or 0.001)
            end
        end
    end
    return math.clamp(base, getgenv().MinPred, getgenv().MaxPred)
end

--// FIND CLOSEST TARGET (Original - with whitelist filter)
local function findClosest(customRadius)
    local r = customRadius or getgenv().Radius
    local closest, minDist = nil, r
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and not isRagdolled(plr) and not isWhitelisted(plr) then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local screen, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist2d = (Vector2.new(screen.X, screen.Y) - center).Magnitude
                    if dist2d < minDist then
                        minDist = dist2d
                        closest = plr
                    end
                end
            end
        end
    end
    return closest
end

--// CUSTOM VELOCITY
local function getCustomVel(hrp, plr)
    local t = tick()
    if not lastPos[plr] then
        lastPos[plr], lastTime[plr] = hrp.Position, t
        return hrp.AssemblyLinearVelocity
    end
    local dt = math.clamp(t - lastTime[plr], 1/240, 1/30)
    local newVel = (hrp.Position - lastPos[plr]) / dt
    local hist = velHistory[plr] or {}
    table.insert(hist, newVel)
    if #hist > 15 then table.remove(hist, 1) end
    velHistory[plr] = hist
    local avgVel = #hist > 1 and (function() local s = Vector3.zero; for _,v in hist do s += v end; return s/#hist end)() or newVel
    if lastVel[plr] then avgVel = avgVel:Lerp(lastVel[plr], getgenv().VelSmooth) end
    lastVel[plr], lastPos[plr], lastTime[plr] = avgVel, hrp.Position, t
    return avgVel
end

--// GET AIM POSITION
local function getAimPos(plr)
    if not plr or not plr.Character then return Vector3.new() end
    if isWhitelisted(plr) then return Vector3.new() end
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return Vector3.new() end
    
    local hum = plr.Character:FindFirstChild("Humanoid")
    local isAir = hum and (hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall)
    
    local partName
    if isAir then
        partName = "Torso"
    else
        partName = blatantMode and "Torso" or "Head"
    end
    local aimPart = plr.Character:FindFirstChild(partName) or root
    
    local pos = aimPart.Position
    local vel = resolver and getCustomVel(root, plr) or root.AssemblyLinearVelocity
    local g = WS.Gravity
    local offsetY = 0
    if isAir then
        local baseOffset = (hum:GetState() == Enum.HumanoidStateType.Freefall) and getgenv().FallOffsetBase or getgenv().JumpOffsetBase
        local velEffect = math.abs(vel.Y) * getgenv().AirVelFactor
        offsetY = baseOffset + velEffect + (vel.Y > 0 and getgenv().AirExtraBoostBase or 0)
        if vel.Y > 22 then offsetY = offsetY + (vel.Y - 22) * 0.0011 end
    end
    pos = pos + Vector3.new(0, offsetY, 0)
    
    local tX = getgenv().PredX
    local tY = getgenv().PredY
    local predXZ = Vector3.new(vel.X * tX, 0, vel.Z * tX)
    local predY = isAir and (vel.Y * tY - 0.5 * g * tY * tY + (vel.Y > 0 and 0.24 * tY or 0)) or (vel.Y * tY)
    
    return pos + predXZ + Vector3.new(0, predY, 0)
end

--// TOOL HOOK
local function hookTool(tool)
    if not tool:IsA("Tool") then return end
    tool.Activated:Connect(function()
        local target = forceTarget
        if not target and silentLockEnabled and silentLockedTarget then
            target = silentLockedTarget
        elseif not target and silentAim then
            target = findClosest()
        end
        if target and not isRagdolled(target) and not isWhitelisted(target) then
            local aimPos = getAimPos(target)
            MainRemote:FireServer(ShootArg, aimPos)
            hitCount = hitCount + 1
        end
    end)
end

local function onChar(char)
    char.ChildAdded:Connect(hookTool)
    for _, v in char:GetChildren() do hookTool(v) end
end

if LocalPlayer.Character then onChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(onChar)

--// BLUR EFFECT AND PARTICLES
local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 0
blurEffect.Parent = Lighting

local particleContainer = nil
local particles = {}

local function createParticles()
    if particleContainer then
        for _, p in pairs(particles) do
            pcall(function() p:Destroy() end)
        end
        particles = {}
        particleContainer:Destroy()
    end
    
    particleContainer = Instance.new("Frame")
    particleContainer.Name = "ParticleContainer"
    particleContainer.Size = UDim2.new(1, 0, 1, 0)
    particleContainer.BackgroundTransparency = 1
    particleContainer.Parent = screenGui
    particleContainer.ZIndex = 999
    particleContainer.Visible = false
    
    for i = 1, 35 do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(3, 8), 0, math.random(3, 8))
        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundColor3 = Color3.fromRGB(255, math.random(100, 200), math.random(150, 255))
        particle.BackgroundTransparency = math.random(30, 70) / 100
        particle.BorderSizePixel = 0
        particle.ZIndex = 1000
        particle.Parent = particleContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = particle
        
        local speedX = (math.random(-50, 50) / 100)
        local speedY = (math.random(-50, 50) / 100)
        local speed = math.random(20, 60) / 100
        
        particles[i] = {
            frame = particle,
            speedX = speedX,
            speedY = speedY,
            speed = speed,
            posX = math.random(),
            posY = math.random()
        }
    end
end

local function animateParticles()
    task.spawn(function()
        while true do
            if screenGui.Enabled and particleContainer and particleContainer.Visible then
                for _, p in pairs(particles) do
                    p.posX = p.posX + (p.speedX * p.speed * 0.01)
                    p.posY = p.posY + (p.speedY * p.speed * 0.01)
                    
                    if p.posX > 1 then p.posX = 0 end
                    if p.posX < 0 then p.posX = 1 end
                    if p.posY > 1 then p.posY = 0 end
                    if p.posY < 0 then p.posY = 1 end
                    
                    p.frame.Position = UDim2.new(p.posX, 0, p.posY, 0)
                end
            end
            task.wait(0.05)
        end
    end)
end

--// UI FRAME
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LeisureGG"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false
screenGui.Enabled = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 750, 0, 500)
mainFrame.Position = UDim2.new(0.5, -375, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Draggable = true
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 100, 165)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.3
mainStroke.Parent = mainFrame

--// HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
header.BackgroundTransparency = 0
header.BorderSizePixel = 0
header.Parent = mainFrame

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0, 32, 0, 32)
logo.Position = UDim2.new(0, 15, 0.5, -16)
logo.Image = "rbxassetid://95448083455045"
logo.BackgroundTransparency = 1
logo.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 200, 1, 0)
title.Position = UDim2.new(0, 55, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "leisure.gg"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(0, 200, 0, 16)
subtitle.Position = UDim2.new(0, 55, 1, -20)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "by @x_vvw"
subtitle.TextColor3 = Color3.fromRGB(255, 180, 210)
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

--// SPLIT CONTAINER (Left - Features, Right - Whitelist)
local splitContainer = Instance.new("Frame")
splitContainer.Size = UDim2.new(1, -20, 1, -70)
splitContainer.Position = UDim2.new(0, 10, 0, 60)
splitContainer.BackgroundTransparency = 1
splitContainer.Parent = mainFrame

-- LEFT PANEL (Features)
local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0.5, -5, 1, 0)
leftPanel.BackgroundTransparency = 1
leftPanel.Parent = splitContainer

-- RIGHT PANEL (Whitelist)
local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(0.5, -5, 1, 0)
rightPanel.Position = UDim2.new(0.5, 5, 0, 0)
rightPanel.BackgroundTransparency = 1
rightPanel.Parent = splitContainer

-- Divider between panels
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, 1, 1, -20)
divider.Position = UDim2.new(0.5, 0, 0, 10)
divider.BackgroundColor3 = Color3.fromRGB(255, 100, 165)
divider.BackgroundTransparency = 0.5
divider.BorderSizePixel = 0
divider.Parent = splitContainer

--// LEFT PANEL CONTENT (Scrolling)
local leftContent = Instance.new("ScrollingFrame")
leftContent.Size = UDim2.new(1, -10, 1, 0)
leftContent.Position = UDim2.new(0, 5, 0, 0)
leftContent.BackgroundTransparency = 1
leftContent.BorderSizePixel = 0
leftContent.CanvasSize = UDim2.new(0, 0, 0, 0)
leftContent.ScrollBarThickness = 3
leftContent.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 165)
leftContent.Parent = leftPanel

local leftLayout = Instance.new("UIListLayout")
leftLayout.Padding = UDim.new(0, 8)
leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
leftLayout.Parent = leftContent

leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    leftContent.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y + 20)
end)

-- Helper functions for UI elements
local function addLabel(parent, text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, 28)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(220, 220, 220)
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function addStatusLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, 24)
    lbl.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    lbl.BackgroundTransparency = 0.3
    lbl.BorderSizePixel = 0
    lbl.Font = Enum.Font.Gotham
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    
    local lblCorner = Instance.new("UICorner")
    lblCorner.CornerRadius = UDim.new(0, 6)
    lblCorner.Parent = lbl
    
    return lbl
end

local function addDivider(parent)
    local div = Instance.new("Frame")
    div.Size = UDim2.new(1, -16, 0, 1)
    div.BackgroundColor3 = Color3.fromRGB(255, 100, 165)
    div.BackgroundTransparency = 0.5
    div.BorderSizePixel = 0
    div.Parent = parent
    return div
end

-- Populate left panel
addLabel(leftContent, "leisure.gg", Color3.fromRGB(255, 100, 165))
addLabel(leftContent, "Game: " .. detectedGame, Color3.fromRGB(180, 180, 180))
addLabel(leftContent, "Hits: " .. hitCount, Color3.fromRGB(255, 200, 100))
addDivider(leftContent)

addLabel(leftContent, "STATUS", Color3.fromRGB(255, 100, 165))

local statusLabels = {}
statusLabels.silentLock = addStatusLabel(leftContent, "Silent Lock: OFF")
statusLabels.camlock = addStatusLabel(leftContent, "Camlock: OFF")
statusLabels.silent = addStatusLabel(leftContent, "Silent Aim: OFF")
statusLabels.resolver = addStatusLabel(leftContent, "Resolver: OFF")
statusLabels.blatant = addStatusLabel(leftContent, "Blatant Mode: OFF")
statusLabels.legit = addStatusLabel(leftContent, "Legit Mode: OFF")
statusLabels.autoAir = addStatusLabel(leftContent, "Auto Air: OFF")
statusLabels.freeAutoAir = addStatusLabel(leftContent, "Free Auto Air: OFF")
statusLabels.trigger = addStatusLabel(leftContent, "Triggerbot: OFF")
statusLabels.autoShoot = addStatusLabel(leftContent, "Auto Shoot: OFF")
statusLabels.combo = addStatusLabel(leftContent, "Combo Mode: OFF")

addDivider(leftContent)

addLabel(leftContent, "CONTROLS", Color3.fromRGB(255, 100, 165))
addLabel(leftContent, "Q - Silent Lock", Color3.fromRGB(200, 200, 200))
addLabel(leftContent, "F - Camlock", Color3.fromRGB(200, 200, 200))
addLabel(leftContent, "V - Silent Aim", Color3.fromRGB(200, 200, 200))
addLabel(leftContent, "B - Auto Air", Color3.fromRGB(200, 200, 200))
addLabel(leftContent, "U - Free Auto Air", Color3.fromRGB(200, 200, 200))
addLabel(leftContent, "T - Triggerbot", Color3.fromRGB(200, 200, 200))
addLabel(leftContent, "J - Auto Shoot", Color3.fromRGB(200, 200, 200))
addLabel(leftContent, "N - Combo Mode", Color3.fromRGB(200, 200, 200))
addLabel(leftContent, "C - Resolver", Color3.fromRGB(200, 200, 200))
addLabel(leftContent, "K - Blatant Mode", Color3.fromRGB(200, 200, 200))
addLabel(leftContent, "L - Legit Mode", Color3.fromRGB(200, 200, 200))

addDivider(leftContent)

addLabel(leftContent, "STATS", Color3.fromRGB(255, 100, 165))
local hitsLabel = addLabel(leftContent, "Total Hits: 0", Color3.fromRGB(255, 200, 100))
local pingLabel = addLabel(leftContent, "Ping: " .. currentPing .. "ms", Color3.fromRGB(100, 200, 255))

--// RIGHT PANEL - WHITELIST (Live Player List)
local rightHeader = Instance.new("TextLabel")
rightHeader.Size = UDim2.new(1, -10, 0, 30)
rightHeader.Position = UDim2.new(0, 5, 0, 0)
rightHeader.BackgroundTransparency = 1
rightHeader.Font = Enum.Font.GothamBold
rightHeader.Text = "PLAYER WHITELIST"
rightHeader.TextColor3 = Color3.fromRGB(255, 100, 165)
rightHeader.TextSize = 14
rightHeader.TextXAlignment = Enum.TextXAlignment.Center
rightHeader.Parent = rightPanel

local whitelistScroll = Instance.new("ScrollingFrame")
whitelistScroll.Size = UDim2.new(1, -10, 1, -40)
whitelistScroll.Position = UDim2.new(0, 5, 0, 35)
whitelistScroll.BackgroundTransparency = 1
whitelistScroll.BorderSizePixel = 0
whitelistScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
whitelistScroll.ScrollBarThickness = 3
whitelistScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 165)
whitelistScroll.Parent = rightPanel

local whitelistLayout = Instance.new("UIListLayout")
whitelistLayout.Padding = UDim.new(0, 6)
whitelistLayout.SortOrder = Enum.SortOrder.Name
whitelistLayout.Parent = whitelistScroll

whitelistLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    whitelistScroll.CanvasSize = UDim2.new(0, 0, 0, whitelistLayout.AbsoluteContentSize.Y + 20)
end)

-- Avatar cache
local avatarCache = {}

local function getAvatarThumbnail(userId)
    if avatarCache[userId] then
        return avatarCache[userId]
    end
    local success, url = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if success and url then
        avatarCache[userId] = url
        return url
    end
    return "rbxassetid://95448083455045"
end

local function updateWhitelistDisplay()
    for _, child in ipairs(whitelistScroll:GetChildren()) do
        if child:IsA("Frame") and child.Name == "PlayerCard" then
            child:Destroy()
        end
    end
    
    local players = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(players, plr)
        end
    end
    
    table.sort(players, function(a, b)
        return a.DisplayName:lower() < b.DisplayName:lower()
    end)
    
    for _, plr in ipairs(players) do
        local isWhitelistedFlag = isWhitelisted(plr)
        local isStaffFlag = isStaff(plr)
        
        local card = Instance.new("Frame")
        card.Name = "PlayerCard"
        card.Size = UDim2.new(1, 0, 0, 55)
        card.BackgroundColor3 = isWhitelistedFlag and Color3.fromRGB(40, 80, 40) or Color3.fromRGB(20, 20, 28)
        card.BackgroundTransparency = 0.3
        card.BorderSizePixel = 0
        card.Parent = whitelistScroll
        
        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 8)
        cardCorner.Parent = card
        
        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.Parent = card
        
        clickBtn.MouseButton1Click:Connect(function()
            local newState = toggleWhitelist(plr)
            if newState then
                card.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
                sendNotification("Whitelist", plr.DisplayName .. " added to whitelist")
            else
                card.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
                sendNotification("Whitelist", plr.DisplayName .. " removed from whitelist")
            end
        end)
        
        -- Avatar
        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 40, 0, 40)
        avatar.Position = UDim2.new(0, 8, 0.5, -20)
        avatar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        avatar.BackgroundTransparency = 0.3
        avatar.BorderSizePixel = 0
        avatar.Parent = card
        local avatarCorner = Instance.new("UICorner")
        avatarCorner.CornerRadius = UDim.new(1, 0)
        avatarCorner.Parent = avatar
        
        task.spawn(function()
            avatar.Image = getAvatarThumbnail(plr.UserId)
        end)
        
        -- Display Name
        local displayName = Instance.new("TextLabel")
        displayName.Size = UDim2.new(1, -60, 0, 22)
        displayName.Position = UDim2.new(0, 56, 0, 6)
        displayName.BackgroundTransparency = 1
        displayName.Font = Enum.Font.GothamBold
        displayName.Text = plr.DisplayName
        displayName.TextColor3 = Color3.fromRGB(255, 255, 255)
        displayName.TextSize = 13
        displayName.TextXAlignment = Enum.TextXAlignment.Left
        displayName.Parent = card
        
        -- Username
        local userName = Instance.new("TextLabel")
        userName.Size = UDim2.new(1, -60, 0, 16)
        userName.Position = UDim2.new(0, 56, 0, 30)
        userName.BackgroundTransparency = 1
        userName.Font = Enum.Font.Gotham
        userName.Text = "@" .. plr.Name
        userName.TextColor3 = Color3.fromRGB(180, 180, 200)
        userName.TextSize = 10
        userName.TextXAlignment = Enum.TextXAlignment.Left
        userName.Parent = card
        
        -- Staff Tag
        if isStaffFlag then
            local staffTag = Instance.new("TextLabel")
            staffTag.Size = UDim2.new(0, 45, 0, 18)
            staffTag.Position = UDim2.new(1, -55, 0, 8)
            staffTag.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
            staffTag.BackgroundTransparency = 0.2
            staffTag.BorderSizePixel = 0
            staffTag.Font = Enum.Font.GothamBold
            staffTag.Text = "STAFF"
            staffTag.TextColor3 = Color3.fromRGB(255, 255, 255)
            staffTag.TextSize = 10
            staffTag.Parent = card
            local staffCorner = Instance.new("UICorner")
            staffCorner.CornerRadius = UDim.new(0, 4)
            staffCorner.Parent = staffTag
        end
        
        -- Whitelist indicator (green dot)
        if isWhitelistedFlag then
            local indicator = Instance.new("Frame")
            indicator.Size = UDim2.new(0, 8, 0, 8)
            indicator.Position = UDim2.new(1, -18, 0.5, -4)
            indicator.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
            indicator.BorderSizePixel = 0
            indicator.Parent = card
            local indicatorCorner = Instance.new("UICorner")
            indicatorCorner.CornerRadius = UDim.new(1, 0)
            indicatorCorner.Parent = indicator
        end
        
        clickBtn.MouseEnter:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.1), {BackgroundTransparency = 0.1}):Play()
        end)
        clickBtn.MouseLeave:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.1), {BackgroundTransparency = 0.3}):Play()
        end)
    end
end

--// UPDATE UI FUNCTION
local function updateUI()
    statusLabels.silentLock.Text = "Silent Lock: " .. (silentLockEnabled and "ON [" .. (silentLockedTarget and silentLockedTarget.Name or "None") .. "]" or "OFF")
    statusLabels.camlock.Text = "Camlock: " .. (camlock and "ON [" .. (lockedTarget and lockedTarget.Name or "None") .. "]" or "OFF")
    statusLabels.silent.Text = "Silent Aim: " .. (silentAim and "ON" or "OFF")
    statusLabels.resolver.Text = "Resolver: " .. (resolver and "ON" or "OFF")
    statusLabels.blatant.Text = "Blatant Mode: " .. (blatantMode and "ON" or "OFF")
    statusLabels.legit.Text = "Legit Mode: " .. (legitSmooth and "ON" or "OFF")
    statusLabels.autoAir.Text = "Auto Air: " .. (autoAirFire and "ON" or "OFF")
    statusLabels.freeAutoAir.Text = "Free Auto Air: " .. (freeAutoAir and "ON" or "OFF")
    statusLabels.trigger.Text = "Triggerbot: " .. (triggerBot and "ON" or "OFF")
    statusLabels.autoShoot.Text = "Auto Shoot: " .. (autoShoot and "ON" or "OFF")
    statusLabels.combo.Text = "Combo Mode: " .. (comboMode and "ON" or "OFF")
    hitsLabel.Text = "Total Hits: " .. hitCount
    pingLabel.Text = "Ping: " .. currentPing .. "ms"
end

--// UPDATE UI LOOP
task.spawn(function()
    while task.wait(0.5) do
        updateUI()
        updateWhitelistDisplay()
    end
end)

--// UI TOGGLE (RightShift / Insert)
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert then
        screenGui.Enabled = not screenGui.Enabled
        if screenGui.Enabled then
            TweenService:Create(blurEffect, TweenInfo.new(0.3), {Size = 12}):Play()
            if particleContainer then particleContainer.Visible = true end
        else
            TweenService:Create(blurEffect, TweenInfo.new(0.3), {Size = 0}):Play()
            if particleContainer then particleContainer.Visible = false end
        end
    end
end)

--// DOT GUI (White dot on locked target)
local dotGui = Instance.new("ScreenGui")
dotGui.Name = "SilentLockDot"
dotGui.Parent = CoreGui
dotGui.ResetOnSpawn = false

local dot = Instance.new("Frame", dotGui)
dot.Size = UDim2.new(0, 9, 0, 9)
dot.AnchorPoint = Vector2.new(0.5, 0.5)
dot.BackgroundColor3 = Color3.new(1, 1, 1)
dot.BorderSizePixel = 0
dot.Visible = false
Instance.new("UICorner", dot).CornerRadius = UDim.new(0, 4)

--// PLAYER UPDATE CONNECTIONS
Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    updateWhitelistDisplay()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    updateWhitelistDisplay()
end)

--// CAMLOCK + DOT UPDATE
RunService.RenderStepped:Connect(function()
    if camlock and lockedTarget then
        local aim = getAimPos(lockedTarget)
        local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, aim)
        if blatantMode then
            Camera.CFrame = targetCFrame
        elseif legitSmooth then
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, getgenv().LegitSmoothing)
        else
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, getgenv().Smoothing)
        end
    end
    
    if silentLockEnabled and silentLockedTarget and silentLockedTarget.Character then
        local hum = silentLockedTarget.Character:FindFirstChild("Humanoid")
        local isAir = hum and (hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall)
        local partName = (isAir or blatantMode) and "Torso" or "Head"
        local torso = silentLockedTarget.Character:FindFirstChild(partName) or silentLockedTarget.Character:FindFirstChild("HumanoidRootPart")
        if torso then
            local screenPos, onScreen = Camera:WorldToViewportPoint(torso.Position)
            if onScreen then
                dot.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
                dot.Visible = true
            else
                dot.Visible = false
            end
        else
            dot.Visible = false
        end
    else
        dot.Visible = false
    end
end)

--// FIND AIR TARGET (with whitelist filter)
local function findAirTarget(fov)
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local bestTarget = nil
    local bestDist = fov
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and not isRagdolled(plr) and not isWhitelisted(plr) then
            local hum = plr.Character:FindFirstChild("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local isAir = (hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall)
                if isAir then
                    local screen, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local dist2d = (Vector2.new(screen.X, screen.Y) - center).Magnitude
                        if dist2d < bestDist then
                            bestDist = dist2d
                            bestTarget = plr
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

--// AUTO FUNCTIONS LOOP (with whitelist checks)
RunService.Heartbeat:Connect(function()
    local function isLowHP(target)
        if not target or not target.Character then return true end
        local hum = target.Character:FindFirstChild("Humanoid")
        return not hum or hum.Health <= 1
    end
    
    if camlock and lockedTarget and (isLowHP(lockedTarget) or isRagdolled(lockedTarget)) then
        camlock = false
        lockedTarget = nil
    end
    if silentLockEnabled and silentLockedTarget and (isLowHP(silentLockedTarget) or isRagdolled(silentLockedTarget)) then
        silentLockEnabled = false
        silentLockedTarget = nil
    end
    
    local isLegitMode = legitSmooth and not blatantMode
    local triggerFOV = isLegitMode and 40 or getgenv().TriggerFOV
    local freeAirFOV = isLegitMode and 40 or getgenv().FreeAutoAirFOV
    
    -- TRIGGERBOT
    if triggerBot then
        local shouldFire = not getgenv().useHoldMode or UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if shouldFire and tick() - lastTriggerFire >= getgenv().TriggerFireRate then
            local target = nil
            if silentLockEnabled and silentLockedTarget and not isWhitelisted(silentLockedTarget) then
                target = silentLockedTarget
            elseif camlock and lockedTarget and not isWhitelisted(lockedTarget) then
                target = lockedTarget
            else
                target = findClosest(triggerFOV)
            end
            if target and isVisible(target) and not isWhitelisted(target) then
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and not isKatana(tool) then
                    forceTarget = target
                    tool:Activate()
                    forceTarget = nil
                    lastTriggerFire = tick()
                    hitCount = hitCount + 1
                end
            end
        end
    end
    
    -- AUTO SHOOT
    if autoShoot then
        if tick() - lastAutoShoot >= getgenv().TriggerFireRate then
            local target = nil
            if silentLockEnabled and silentLockedTarget and not isWhitelisted(silentLockedTarget) then
                target = silentLockedTarget
            elseif camlock and lockedTarget and not isWhitelisted(lockedTarget) then
                target = lockedTarget
            elseif silentAim then
                target = findClosest()
            end
            if target and isVisible(target) and not isWhitelisted(target) then
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and not isKatana(tool) then
                    forceTarget = target
                    tool:Activate()
                    forceTarget = nil
                    lastAutoShoot = tick()
                    hitCount = hitCount + 1
                end
            end
        end
    end
    
    -- AUTO AIR
    if autoAirFire then
        local target = (silentLockEnabled and silentLockedTarget) or (camlock and lockedTarget)
        if target and target.Character and not isWhitelisted(target) then
            local hum = target.Character:FindFirstChild("Humanoid")
            if hum then
                local isAir = (hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall)
                if isAir then
                    if not airStart[target] then airStart[target] = tick() end
                    if tick() - airStart[target] >= getgenv().airTriggerDelay and tick() - lastAutoFire >= getgenv().airFireRate then
                        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if tool and not isKatana(tool) then
                            forceTarget = target
                            tool:Activate()
                            forceTarget = nil
                            lastAutoFire = tick()
                            hitCount = hitCount + 1
                        end
                    end
                else
                    airStart[target] = nil
                end
            end
        end
    end
    
    -- FREE AUTO AIR
    if freeAutoAir then
        if tick() - lastFreeAutoAirFire >= getgenv().airFireRate then
            local target = findAirTarget(freeAirFOV)
            if target and isVisible(target) and not isWhitelisted(target) then
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and not isKatana(tool) then
                    forceTarget = target
                    tool:Activate()
                    forceTarget = nil
                    lastFreeAutoAirFire = tick()
                    hitCount = hitCount + 1
                end
            end
        end
    end
end)

--// KEYBINDS
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    local k = input.KeyCode.Name
    
    if k == getgenv().ResolveKey then
        resolver = not resolver
    elseif k == getgenv().CamlockKey then
        if comboMode then
            local wasOn = camlock
            camlock = not camlock
            silentLockEnabled = camlock
            if camlock and not wasOn then
                local target = findClosest()
                if target then
                    lockedTarget = target
                    silentLockedTarget = target
                    sendNotification("leisure.gg", "Combo Lock ON → " .. target.Name)
                end
            else
                lockedTarget = nil
                silentLockedTarget = nil
                sendNotification("leisure.gg", "Combo Lock OFF")
            end
        else
            camlock = not camlock
            lockedTarget = camlock and findClosest() or nil
            if camlock and lockedTarget then
                sendNotification("leisure.gg", "Camlock ON → " .. lockedTarget.Name)
            elseif not camlock then
                sendNotification("leisure.gg", "Camlock OFF")
            end
        end
    elseif k == getgenv().SilentKey then
        silentAim = not silentAim
    elseif k == getgenv().AutoAirKey then
        autoAirFire = not autoAirFire
    elseif k == getgenv().TriggerKey then
        triggerBot = not triggerBot
    elseif k == getgenv().LegitSmoothKey and not blatantMode then
        legitSmooth = not legitSmooth
        if legitSmooth then blatantMode = false end
    elseif k == getgenv().BlatantKey then
        blatantMode = not blatantMode
        if blatantMode then legitSmooth = false end
    elseif k == getgenv().SilentLockKey then
        if not silentLockEnabled then
            local target = findClosest()
            if target then
                silentLockEnabled = true
                silentLockedTarget = target
                sendNotification("leisure.gg", "Silent Lock ON → " .. target.Name)
            else
                sendNotification("leisure.gg", "No target found")
            end
        else
            silentLockEnabled = false
            silentLockedTarget = nil
            sendNotification("leisure.gg", "Silent Lock OFF")
        end
    elseif k == getgenv().AutoShootKey then
        autoShoot = not autoShoot
    elseif k == getgenv().ComboKey then
        comboMode = not comboMode
    elseif k == getgenv().FreeAutoAirKey then
        freeAutoAir = not freeAutoAir
        local isLegit = legitSmooth and not blatantMode
        local fov = isLegit and 40 or getgenv().FreeAutoAirFOV
        print("Free Auto Air: " .. (freeAutoAir and "ON (FOV " .. fov .. ")" or "OFF"))
    elseif k == getgenv().IncFreeAutoAirFOVKey then
        if not (legitSmooth and not blatantMode) then
            getgenv().FreeAutoAirFOV = math.min(200, getgenv().FreeAutoAirFOV + 5)
            print("Free Auto Air FOV increased to " .. getgenv().FreeAutoAirFOV)
        else
            print("Cannot change FOV in Legit Mode (fixed at 40)")
        end
    elseif k == getgenv().DecFreeAutoAirFOVKey then
        if not (legitSmooth and not blatantMode) then
            getgenv().FreeAutoAirFOV = math.max(10, getgenv().FreeAutoAirFOV - 5)
            print("Free Auto Air FOV decreased to " .. getgenv().FreeAutoAirFOV)
        else
            print("Cannot change FOV in Legit Mode (fixed at 40)")
        end
    end
end)

--// INITIALIZE PARTICLES AND BLUR
createParticles()
animateParticles()

--// STARTUP MESSAGE
print("leisure.gg loaded - Made by @x_vvw")
print("RightShift / Insert - Toggle UI")
print("Q - Silent Lock | F - Camlock | V - Silent Aim | T - Triggerbot | J - Auto Shoot")
print("B - Auto Air | U - Free Auto Air | K - Blatant | L - Legit | C - Resolver | N - Combo Mode")
print("[ / ] - Free Auto Air FOV")
sendNotification("leisure.gg", "Loaded - RightShift/Insert to open UI", 3)
