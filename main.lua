--[[
    leisure.gg - Complete Combat Script
    Using LeisureLib UI Library
    made by @x_vvw
]]

local LeisureLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/for879/leisuregg/refs/heads/main/v1.lua"))()

--// ANTI-VELVETX PROTECTION
if _G.LeisureGG_Protected then
    error("LeisureGG is already running")
end
_G.LeisureGG_Protected = true

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")

--// ANTI-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--// SETTINGS STORAGE
local Settings = {
    -- Master
    MasterEnabled = true,
    
    -- Mouselock (3rd Person Lock)
    MouselockEnabled = false,
    MouselockKeybind = Enum.KeyCode.X,
    MouselockSmoothness = 0.2,
    MouselockFOVRadius = 200,
    MouselockShowFOV = true,
    MouselockFOVColor = Color3.fromRGB(100, 200, 255),
    MouselockWallCheck = true,
    MouselockKnockedCheck = true,
    
    -- Camlock
    CamlockEnabled = false,
    CamlockKeybind = Enum.KeyCode.Q,
    CamlockPrediction = 0.134,
    CamlockAutoPrediction = true,
    CamlockHitPart = "HumanoidRootPart",
    CamlockAirPart = "HumanoidRootPart",
    CamlockSmoothness = 0.15,
    CamlockFOVRadius = 200,
    CamlockShowFOV = true,
    CamlockFOVColor = Color3.fromRGB(255, 100, 165),
    CamlockWallCheck = true,
    CamlockKnockedCheck = true,
    CamlockCrewCheck = false,
    CamlockGrabbedCheck = true,
    CamlockResolver = true,
    CamlockJumpOffset = 1.5,
    CamlockFallOffset = 1.0,
    CamlockShakeAmount = 0,
    CamlockJitterAmount = 0,
    CamlockShowHighlight = true,
    CamlockHighlightColor = Color3.fromRGB(255, 100, 165),
    CamlockHighlightTransparency = 0.65,
    
    -- Silent Aim
    SilentEnabled = true,
    SilentPrediction = 0.134,
    SilentAutoPrediction = true,
    SilentHitParts = {"HumanoidRootPart", "Head", "UpperTorso", "LowerTorso"},
    SilentFOVRadius = 200,
    SilentShowFOV = true,
    SilentFOVColor = Color3.fromRGB(255, 80, 80),
    SilentWallCheck = true,
    SilentKnockedCheck = true,
    SilentCrewCheck = false,
    SilentGrabbedCheck = true,
    SilentAntiCurve = true,
    SilentNoGroundShots = true,
    SilentHitChance = 100,
    SilentNearestPoint = true,
    
    -- Triggerbot
    TriggerbotEnabled = false,
    TriggerbotKeybind = Enum.KeyCode.V,
    TriggerbotDelay = 0.05,
    TriggerbotWallCheck = true,
    TriggerbotKnockedCheck = true,
    
    -- Rapid Fire
    RapidFireEnabled = false,
    RapidFireDelay = 0.03,
    
    -- Movement
    FlyEnabled = false,
    FlyKeybind = Enum.KeyCode.F,
    FlySpeed = 50,
    CFrameWalkEnabled = false,
    CFrameWalkKeybind = Enum.KeyCode.C,
    CFrameWalkSpeed = 100,
    NoJumpCooldown = false,
    NoSit = false,
    NoSlow = false,
    
    -- Anti-Aim / Desync
    VelocityDesyncEnabled = false,
    VelocityDesyncKeybind = Enum.KeyCode.B,
    VelocityDesyncSpeed = 10,
    FakePosDesyncEnabled = false,
    FakePosDesyncKeybind = Enum.KeyCode.N,
    FFlagDesyncEnabled = false,
    NetworkDesyncEnabled = false,
    
    -- Visuals
    ShowHighlight = true,
    ShowHealthBar = true,
    ShowNameTags = true,
    ShowDistance = false,
    FullbrightEnabled = false,
    ChamsEnabled = false,
    ChamsColor = Color3.fromRGB(255, 100, 165),
    ChamsTransparency = 0.5,
    
    -- Staff Alert
    StaffAlertEnabled = true,
    StaffAlertAction = "Notify",
    StaffAlertDuration = 5,
    
    -- Whitelist
    Whitelist = {},
}

--// STAFF ALERT - BLACKLISTED USERS
local STAFF_IDS = {
    1617828795, 4004110354, 2596448591, 7523797355, 1236712946,
    4179791578, 3812472402, 3543999912, 968660321, 7333069745,
    7157153757, 3587870844, 2631808298, 621822647, 1094365126,
    3855523132, 2732386174, 10452135555, 848355298, 9754156539,
    10777665227, 41234321, 2400924396, 167515541, 10428537936,
    10398386750, 7627361, 4160998891, 10688896660
}

local ICON_FALLBACK = "rbxassetid://104171307729169"
local detectedPlayers = {}

--// STATE
local MouselockTarget = nil
local MouselockActive = false
local CamlockTarget = nil
local CamlockActive = false
local currentPing = 0
local toolConnection = nil
local flyBodyVel = nil
local flyBodyGyro = nil
local flying = false
local lastWallCheckTime = 0

--// FOV CIRCLES
local MouselockFOVCircle = Drawing.new("Circle")
MouselockFOVCircle.Thickness = 2
MouselockFOVCircle.Filled = false
MouselockFOVCircle.NumSides = 64
MouselockFOVCircle.Transparency = 1

local CamlockFOVCircle = Drawing.new("Circle")
CamlockFOVCircle.Thickness = 2
CamlockFOVCircle.Filled = false
CamlockFOVCircle.NumSides = 64
CamlockFOVCircle.Transparency = 1

local SilentFOVCircle = Drawing.new("Circle")
SilentFOVCircle.Thickness = 2
SilentFOVCircle.Filled = false
SilentFOVCircle.NumSides = 64
SilentFOVCircle.Transparency = 1

--// HIGHLIGHT
local targetHighlight = Instance.new("Highlight")
targetHighlight.FillColor = Settings.CamlockHighlightColor
targetHighlight.OutlineColor = Settings.CamlockHighlightColor
targetHighlight.FillTransparency = Settings.CamlockHighlightTransparency
targetHighlight.OutlineTransparency = 0.3
targetHighlight.Parent = nil

--// UTILITY FUNCTIONS
local function isPlayerValid(player)
    if not player or not player.Character then return false end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return false end
    if humanoid.Health <= 0 then return false end
    return true
end

local function isKnocked(character)
    if not character then return true end
    if character:GetAttribute("Knocked") == true then return true end
    local bodyEffects = character:FindFirstChild("BodyEffects")
    if bodyEffects then
        local ko = bodyEffects:FindFirstChild("K.O")
        if ko and ko.Value == true then return true end
        local grabbed = character:FindFirstChild("GRABBING_CONSTRAINT")
        if grabbed and Settings.CamlockGrabbedCheck then return true end
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then return true end
    return false
end

local function isSameCrew(player)
    if not Settings.CamlockCrewCheck then return false end
    local targetCrew = nil
    local localCrew = nil
    local targetDataFolder = player:FindFirstChild("DataFolder")
    if targetDataFolder then
        local targetInfo = targetDataFolder:FindFirstChild("Information")
        if targetInfo then targetCrew = targetInfo:FindFirstChild("Crew") end
    end
    local localDataFolder = LocalPlayer:FindFirstChild("DataFolder")
    if localDataFolder then
        local localInfo = localDataFolder:FindFirstChild("Information")
        if localInfo then localCrew = localInfo:FindFirstChild("Crew") end
    end
    if targetCrew and localCrew and targetCrew.Value ~= '' and localCrew.Value ~= '' then
        return targetCrew.Value == localCrew.Value
    end
    return false
end

local function isWhitelisted(player)
    for _, id in pairs(Settings.Whitelist) do
        if player.UserId == id or player.Name == id then
            return true
        end
    end
    return false
end

--// WALL CHECK - Returns true if target is visible
local function isTargetVisible(targetPart, targetCharacter)
    if not Settings.CamlockWallCheck then return true end
    local character = LocalPlayer.Character
    if not character then return true end
    local origin = Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {character, Camera}
    local result = workspace:Raycast(origin, (targetPart.Position - origin), params)
    if not result then return true end
    return result.Instance:IsDescendantOf(targetCharacter)
end

local function getMainRemote()
    local remote = ReplicatedStorage:FindFirstChild("MAINEVENT")
    if not remote then remote = ReplicatedStorage:FindFirstChild("MainEvent") end
    return remote
end

local function fireAtPosition(position)
    pcall(function()
        local remote = getMainRemote()
        if remote and remote:IsA("RemoteEvent") then
            remote:FireServer("MOUSE", position)
        end
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then pcall(function() tool:Activate() end) end
    end)
end

local function getPredictedPosition(target, prediction, jumpOffset, fallOffset, resolver, autoPred)
    if not target or not target.Character then return nil end
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local pred = prediction
    if autoPred then pred = pred + (currentPing * 0.5) end
    if pred > 0.3 then pred = 0.3 end
    if resolver and hrp.Velocity.Magnitude > 100 then pred = pred * 0.6 end
    local targetPart = target.Character:FindFirstChild("HumanoidRootPart") or hrp
    local isJumping = false
    local isFalling = false
    local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local state = humanoid:GetState()
        isJumping = (state == Enum.HumanoidStateType.Jumping)
        isFalling = (state == Enum.HumanoidStateType.Freefall)
    end
    local yOffset = 0
    if isJumping then yOffset = jumpOffset
    elseif isFalling then yOffset = fallOffset end
    return targetPart.Position + (hrp.Velocity * pred) + Vector3.new(0, yOffset, 0)
end

--// GET TARGET UNDER MOUSE - MANUAL LOCK ONLY
local function getTargetUnderMouse(fovRadius, wallCheckEnabled, knockedCheckEnabled)
    local closest, shortest = nil, fovRadius
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isPlayerValid(player) and not isWhitelisted(player) then
            local skip = false
            if knockedCheckEnabled and isKnocked(player.Character) then skip = true end
            if Settings.CamlockCrewCheck and isSameCrew(player) then skip = true end
            if not skip then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local wallValid = true
                    if wallCheckEnabled then
                        if not isTargetVisible(hrp, player.Character) then wallValid = false end
                    end
                    if wallValid then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if dist < shortest then
                                shortest = dist
                                closest = player
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

--// STAFF ALERT FUNCTIONS
local function getHeadshot(userId)
    local success, content = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    return success and content or ICON_FALLBACK
end

local function sendStaffNotification(title, text, icon)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Icon = icon or ICON_FALLBACK,
            Duration = Settings.StaffAlertDuration
        })
    end)
end

local function checkStaff()
    if not Settings.StaffAlertEnabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local isStaff = false
            for _, id in pairs(STAFF_IDS) do
                if player.UserId == id then
                    isStaff = true
                    break
                end
            end
            if isStaff and not detectedPlayers[player.UserId] then
                detectedPlayers[player.UserId] = player
                local icon = getHeadshot(player.UserId)
                if Settings.StaffAlertAction == "Kick" then
                    LocalPlayer:Kick("Staff Alert: " .. player.Name .. " joined the server")
                else
                    sendStaffNotification("⚠️ Staff Joined", player.DisplayName .. " (@ " .. player.Name .. ")", icon)
                end
            elseif not isStaff and detectedPlayers[player.UserId] then
                local icon = getHeadshot(player.UserId)
                sendStaffNotification("🚪 Staff Left", player.DisplayName .. " (@ " .. player.Name .. ")", icon)
                detectedPlayers[player.UserId] = nil
            end
        end
    end
end

--// MOUSELOCK - MANUAL ONLY
local function updateMouselock()
    if not Settings.MouselockEnabled then
        if MouselockActive then
            MouselockActive = false
            MouselockTarget = nil
        end
        return
    end
    
    if not MouselockActive or not MouselockTarget then
        return  -- No target locked, don't auto-acquire
    end
    
    -- Check if target is still valid
    if not isPlayerValid(MouselockTarget) or isKnocked(MouselockTarget.Character) then
        MouselockActive = false
        MouselockTarget = nil
        return
    end
    
    -- Check visibility for wall check (continuous)
    local hrp = MouselockTarget.Character:FindFirstChild("HumanoidRootPart")
    if hrp and Settings.MouselockWallCheck then
        if not isTargetVisible(hrp, MouselockTarget.Character) then
            -- Target behind wall, don't track
            return
        end
    end
    
    local targetPos = getPredictedPosition(MouselockTarget, 0, 0, 0, false, false)
    if targetPos then
        local currentCF = Camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, targetPos)
        Camera.CFrame = currentCF:Lerp(targetCF, Settings.MouselockSmoothness)
    end
end

--// CAMLOCK - MANUAL ONLY
local function updateCamlock()
    if not Settings.CamlockEnabled then
        if CamlockActive then
            CamlockActive = false
            CamlockTarget = nil
            if targetHighlight then targetHighlight.Parent = nil end
        end
        return
    end
    
    if not CamlockActive or not CamlockTarget then
        return  -- No target locked, don't auto-acquire
    end
    
    -- Check if target is still valid
    if not isPlayerValid(CamlockTarget) or isKnocked(CamlockTarget.Character) or isWhitelisted(CamlockTarget) then
        CamlockActive = false
        CamlockTarget = nil
        if targetHighlight then targetHighlight.Parent = nil end
        LeisureLib.Notify("Camlock", "Target eliminated", 1.5, "warning")
        return
    end
    
    -- Check visibility for wall check (continuous)
    local hrp = CamlockTarget.Character:FindFirstChild("HumanoidRootPart")
    if hrp and Settings.CamlockWallCheck then
        if not isTargetVisible(hrp, CamlockTarget.Character) then
            -- Target behind wall, don't track
            if targetHighlight then targetHighlight.Parent = nil end
            return
        elseif Settings.CamlockShowHighlight and targetHighlight then
            if targetHighlight.Parent ~= CamlockTarget.Character then
                targetHighlight.Parent = CamlockTarget.Character
            end
        end
    end
    
    if Settings.CamlockShowHighlight and targetHighlight and targetHighlight.Parent ~= CamlockTarget.Character then
        targetHighlight.Parent = CamlockTarget.Character
        targetHighlight.FillColor = Settings.CamlockHighlightColor
        targetHighlight.FillTransparency = Settings.CamlockHighlightTransparency
    end
    
    local isJumping = false
    local humanoid = CamlockTarget.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local state = humanoid:GetState()
        isJumping = (state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall)
    end
    
    local targetPos = getPredictedPosition(CamlockTarget, Settings.CamlockPrediction, Settings.CamlockJumpOffset, Settings.CamlockFallOffset, Settings.CamlockResolver, Settings.CamlockAutoPrediction)
    if targetPos then
        if Settings.CamlockShakeAmount > 0 then
            targetPos = targetPos + Vector3.new(
                math.sin(tick() * 50) * Settings.CamlockShakeAmount,
                math.cos(tick() * 50) * Settings.CamlockShakeAmount,
                0
            )
        end
        if Settings.CamlockJitterAmount > 0 then
            targetPos = targetPos + Vector3.new(
                (math.random() - 0.5) * Settings.CamlockJitterAmount,
                (math.random() - 0.5) * Settings.CamlockJitterAmount,
                0
            )
        end
        local currentCF = Camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, targetPos)
        Camera.CFrame = currentCF:Lerp(targetCF, Settings.CamlockSmoothness)
    end
end

--// SILENT AIM
local function fireSilentAim()
    if not Settings.MasterEnabled or not Settings.SilentEnabled then return end
    local target = getTargetUnderMouse(Settings.SilentFOVRadius, Settings.SilentWallCheck, Settings.SilentKnockedCheck)
    if not target or isWhitelisted(target) then return end
    local predictedPos = getPredictedPosition(target, Settings.SilentPrediction, 0, 0, false, Settings.SilentAutoPrediction)
    if predictedPos then
        fireAtPosition(predictedPos)
    end
end

--// TRIGGERBOT
local function onTriggerbot()
    if not Settings.MasterEnabled or not Settings.TriggerbotEnabled then return end
    if not CamlockActive or not CamlockTarget then return end
    if not isPlayerValid(CamlockTarget) or isKnocked(CamlockTarget.Character) or isWhitelisted(CamlockTarget) then return end
    
    -- Check visibility for triggerbot
    local hrp = CamlockTarget.Character:FindFirstChild("HumanoidRootPart")
    if hrp and Settings.TriggerbotWallCheck then
        if not isTargetVisible(hrp, CamlockTarget.Character) then
            return
        end
    end
    
    local predictedPos = getPredictedPosition(CamlockTarget, Settings.CamlockPrediction, Settings.CamlockJumpOffset, Settings.CamlockFallOffset, Settings.CamlockResolver, Settings.CamlockAutoPrediction)
    if predictedPos then
        fireAtPosition(predictedPos)
    end
end

--// TOOL CONNECTION
local function onToolAdded(tool)
    if tool:IsA("Tool") then
        if toolConnection then toolConnection:Disconnect() end
        toolConnection = tool.Activated:Connect(fireSilentAim)
    end
end
local function onCharacterAdded(character)
    character.ChildAdded:Connect(onToolAdded)
end
if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

--// RAPID FIRE LOOP
task.spawn(function()
    while task.wait(0.03) do
        if Settings.MasterEnabled and Settings.RapidFireEnabled and CamlockActive and CamlockTarget then
            if isPlayerValid(CamlockTarget) and not isKnocked(CamlockTarget.Character) and not isWhitelisted(CamlockTarget) then
                -- Check visibility for rapid fire
                local hrp = CamlockTarget.Character:FindFirstChild("HumanoidRootPart")
                local visible = true
                if hrp and Settings.CamlockWallCheck then
                    visible = isTargetVisible(hrp, CamlockTarget.Character)
                end
                if visible and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    onTriggerbot()
                end
            end
        end
    end
end)

--// FLY SYSTEM
local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    if flyBodyVel then flyBodyVel:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.MaxForce = Vector3.new(100000, 100000, 100000)
    flyBodyVel.Velocity = Vector3.new(0, 0, 0)
    flyBodyVel.Parent = hrp
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    flyBodyGyro.Parent = hrp
    humanoid.PlatformStand = true
    flying = true
end

local function stopFly()
    if flyBodyVel then flyBodyVel:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
    flying = false
end

local function updateFly()
    if not Settings.FlyEnabled then
        if flying then stopFly() end
        return
    end
    if not flying then startFly() end
    if not flyBodyVel then return end
    local moveDirection = Vector3.new(0, 0, 0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
    if moveDirection.Magnitude > 0 then
        flyBodyVel.Velocity = moveDirection.Unit * Settings.FlySpeed
    else
        flyBodyVel.Velocity = Vector3.new(0, 0, 0)
    end
    flyBodyGyro.CFrame = Camera.CFrame
end

--// CFrame WALK
local function updateCFrameWalk()
    if not Settings.CFrameWalkEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    local moveDirection = humanoid.MoveDirection
    if moveDirection and moveDirection.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame + (moveDirection.Unit * Settings.CFrameWalkSpeed * 0.016)
    end
end

--// MOVEMENT UTILITIES
local function updateNoJumpCooldown()
    if not Settings.NoJumpCooldown then return end
    local char = LocalPlayer.Character
    if not char then return end
    local bodyEffects = char:FindFirstChild("BodyEffects")
    if bodyEffects then
        local jumpCooldown = bodyEffects:FindFirstChild("JumpCooldown")
        if jumpCooldown and jumpCooldown:IsA("NumberValue") then
            jumpCooldown.Value = 0
        end
    end
end

local function updateNoSit()
    if not Settings.NoSit then return end
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Sit then
        humanoid.Sit = false
    end
end

local function updateNoSlow()
    if not Settings.NoSlow then return end
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.WalkSpeed < 16 then
        humanoid.WalkSpeed = 16
    end
end

--// VELOCITY DESYNC
local velocityDesyncActive = false
local function updateVelocityDesync()
    if not Settings.VelocityDesyncEnabled then
        if velocityDesyncActive then velocityDesyncActive = false end
        return
    end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    velocityDesyncActive = true
    local currentVel = hrp.Velocity
    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(0.01), 0)
    hrp.Velocity = Vector3.new(Settings.VelocityDesyncSpeed, Settings.VelocityDesyncSpeed, Settings.VelocityDesyncSpeed)
    task.wait()
    hrp.Velocity = currentVel
end

--// FFLAG DESYNC
local function applyFFlagDesync()
    if not Settings.FFlagDesyncEnabled then return end
    pcall(function()
        setfflag("GameNetPVHeaderRotationalVelocityZeroCutoffExponent", "-5000")
        setfflag("LargeReplicatorWrite5", "True")
        setfflag("S2PhysicsSenderRate", "15000")
        setfflag("PhysicsSenderMaxBandwidthBps", "20000")
        setfflag("SimDefaultHumanoidTimestepMultiplier", "150")
    end)
end

--// NETWORK DESYNC
local networkDesyncActive = false
local function updateNetworkDesync()
    if not Settings.NetworkDesyncEnabled then
        if networkDesyncActive then networkDesyncActive = false end
        return
    end
    networkDesyncActive = true
    pcall(function()
        local remote = getMainRemote()
        if remote then remote:FireServer("DESYNC") end
    end)
end

--// UPDATE FOV CIRCLES
local function updateFOVCircles()
    local mousePos = Vector2.new(Mouse.X, Mouse.Y + game:GetService("GuiService"):GetGuiInset().Y)
    if MouselockFOVCircle then
        MouselockFOVCircle.Position = mousePos
        MouselockFOVCircle.Radius = Settings.MouselockFOVRadius
        MouselockFOVCircle.Color = Settings.MouselockFOVColor
        MouselockFOVCircle.Visible = Settings.MouselockShowFOV and Settings.MouselockEnabled
    end
    if CamlockFOVCircle then
        CamlockFOVCircle.Position = mousePos
        CamlockFOVCircle.Radius = Settings.CamlockFOVRadius
        CamlockFOVCircle.Color = Settings.CamlockFOVColor
        CamlockFOVCircle.Visible = Settings.CamlockShowFOV and Settings.CamlockEnabled
    end
    if SilentFOVCircle then
        SilentFOVCircle.Position = mousePos
        SilentFOVCircle.Radius = Settings.SilentFOVRadius
        SilentFOVCircle.Color = Settings.SilentFOVColor
        SilentFOVCircle.Visible = Settings.SilentShowFOV and Settings.SilentEnabled
    end
end

--// UPDATE CHAMS
local function updateChams()
    if not Settings.ChamsEnabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    local highlight = part:FindFirstChild("LeisureChams")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "LeisureChams"
                        highlight.FillColor = Settings.ChamsColor
                        highlight.FillTransparency = Settings.ChamsTransparency
                        highlight.OutlineTransparency = 1
                        highlight.Parent = part
                    end
                end
            end
        end
    end
end

--// UPDATE FULLBRIGHT
local function updateFullbright()
    if Settings.FullbrightEnabled then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
    else
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        Lighting.Brightness = 1
    end
end

--// UPDATE PING
local function updatePing()
    local success, pingValue = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
    end)
    if success and pingValue then
        local ping = tonumber(string.match(pingValue, "(%d+)"))
        if ping then currentPing = ping / 1000 end
    end
end

--// KEYBINDS - MANUAL LOCK/UNLOCK
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Mouselock Toggle (X)
    if input.KeyCode == Settings.MouselockKeybind then
        if Settings.MouselockEnabled then
            if MouselockActive then
                -- Unlock
                MouselockActive = false
                MouselockTarget = nil
                LeisureLib.Notify("Mouselock", "Unlocked", 1, "warning")
            else
                -- Lock onto closest player under mouse
                local target = getTargetUnderMouse(Settings.MouselockFOVRadius, Settings.MouselockWallCheck, Settings.MouselockKnockedCheck)
                if target then
                    MouselockActive = true
                    MouselockTarget = target
                    LeisureLib.Notify("Mouselock", "Locked onto " .. target.DisplayName, 2, "success")
                else
                    LeisureLib.Notify("Mouselock", "No target found", 1, "warning")
                end
            end
        end
    end
    
    -- Camlock Toggle (Q)
    if input.KeyCode == Settings.CamlockKeybind then
        if Settings.CamlockEnabled then
            if CamlockActive then
                -- Unlock
                CamlockActive = false
                CamlockTarget = nil
                if targetHighlight then targetHighlight.Parent = nil end
                LeisureLib.Notify("Camlock", "Unlocked", 1, "warning")
            else
                -- Lock onto closest player under mouse
                local target = getTargetUnderMouse(Settings.CamlockFOVRadius, Settings.CamlockWallCheck, Settings.CamlockKnockedCheck)
                if target then
                    CamlockActive = true
                    CamlockTarget = target
                    if Settings.CamlockShowHighlight and targetHighlight then
                        targetHighlight.Parent = target.Character
                        targetHighlight.FillColor = Settings.CamlockHighlightColor
                        targetHighlight.FillTransparency = Settings.CamlockHighlightTransparency
                    end
                    LeisureLib.Notify("Camlock", "Locked onto " .. target.DisplayName, 2, "success")
                else
                    LeisureLib.Notify("Camlock", "No target found", 1, "warning")
                end
            end
        end
    end
    
    -- Fly Toggle (F)
    if input.KeyCode == Settings.FlyKeybind then
        Settings.FlyEnabled = not Settings.FlyEnabled
        LeisureLib.Notify("Fly", Settings.FlyEnabled and "ON" or "OFF", 1)
    end
    
    -- CFrame Walk Toggle (C)
    if input.KeyCode == Settings.CFrameWalkKeybind then
        Settings.CFrameWalkEnabled = not Settings.CFrameWalkEnabled
        LeisureLib.Notify("CFrame Walk", Settings.CFrameWalkEnabled and "ON" or "OFF", 1)
    end
    
    -- Velocity Desync Toggle (B)
    if input.KeyCode == Settings.VelocityDesyncKeybind then
        Settings.VelocityDesyncEnabled = not Settings.VelocityDesyncEnabled
        LeisureLib.Notify("Velocity Desync", Settings.VelocityDesyncEnabled and "ON" or "OFF", 1)
    end
    
    -- Triggerbot Toggle (V)
    if input.KeyCode == Settings.TriggerbotKeybind then
        Settings.TriggerbotEnabled = not Settings.TriggerbotEnabled
        LeisureLib.Notify("Triggerbot", Settings.TriggerbotEnabled and "ON" or "OFF", 1)
    end
    
    -- Insert key - Force UI reopen workaround
    if input.KeyCode == Enum.KeyCode.Insert then
        -- Try to find and show UI
        local success, ui = pcall(function()
            return CoreGui:FindFirstChild("LeisureGG")
        end)
        if success and ui then
            ui.Visible = not ui.Visible
            if ui.Visible then
                LeisureLib.Notify("UI", "UI reopened", 1, "success")
            end
        end
    end
end)

--// MAIN LOOPS
task.spawn(function()
    while task.wait(0.5) do
        updatePing()
        checkStaff()
        updateNoJumpCooldown()
        updateNoSit()
        updateNoSlow()
        applyFFlagDesync()
        updateChams()
        updateFullbright()
    end
end)

RunService.Heartbeat:Connect(function()
    updateFOVCircles()
    updateFly()
    updateCFrameWalk()
    updateVelocityDesync()
    updateNetworkDesync()
end)

RunService.RenderStepped:Connect(function()
    updateMouselock()
    updateCamlock()
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    MouselockActive = false
    CamlockActive = false
    CamlockTarget = nil
    if targetHighlight then targetHighlight.Parent = nil end
end)

--// ==========================================
--// LEISURE LIB INITIALIZATION
--// ==========================================

LeisureLib:Init(function()

    local Window = LeisureLib:CreateWindow({
        Title = "leisure.gg",
        Size = {720, 520},
    })

    Window:AddPlayerList()

    -- COMBAT TAB
    local CombatTab = Window:AddTab("COMBAT", "⚔")

    local MouselockSection = CombatTab:AddSection("Mouselock (3rd Person)")
    
    MouselockSection:AddToggle({
        Label = "Enable Mouselock",
        Default = Settings.MouselockEnabled,
        Callback = function(val) Settings.MouselockEnabled = val end
    })
    
    MouselockSection:AddKeybind({
        Label = "Mouselock Keybind",
        Default = Settings.MouselockKeybind,
        Callback = function(key) Settings.MouselockKeybind = key end
    })
    
    MouselockSection:AddSlider({
        Label = "Smoothness", Min = 0.05, Max = 0.5, Default = Settings.MouselockSmoothness, Decimals = 3,
        Callback = function(val) Settings.MouselockSmoothness = val end
    })
    
    MouselockSection:AddDivider("FOV Settings")
    
    MouselockSection:AddToggle({
        Label = "Show FOV", Default = Settings.MouselockShowFOV,
        Callback = function(val) Settings.MouselockShowFOV = val end
    })
    
    MouselockSection:AddSlider({
        Label = "FOV Radius", Min = 50, Max = 400, Default = Settings.MouselockFOVRadius, Decimals = 0,
        Callback = function(val) Settings.MouselockFOVRadius = val end
    })
    
    MouselockSection:AddColorPicker({
        Label = "FOV Colour", Default = Settings.MouselockFOVColor,
        Callback = function(col) Settings.MouselockFOVColor = col end
    })
    
    MouselockSection:AddDivider("Checks")
    
    MouselockSection:AddToggle({
        Label = "Wall Check", Default = Settings.MouselockWallCheck,
        Callback = function(val) Settings.MouselockWallCheck = val end
    })
    
    MouselockSection:AddToggle({
        Label = "Knocked Check", Default = Settings.MouselockKnockedCheck,
        Callback = function(val) Settings.MouselockKnockedCheck = val end
    })

    local CamlockSection = CombatTab:AddSection("Camlock")
    
    CamlockSection:AddToggle({
        Label = "Enable Camlock",
        Default = Settings.CamlockEnabled,
        Callback = function(val) Settings.CamlockEnabled = val end
    })
    
    CamlockSection:AddKeybind({
        Label = "Camlock Keybind",
        Default = Settings.CamlockKeybind,
        Callback = function(key) Settings.CamlockKeybind = key end
    })
    
    CamlockSection:AddDivider("Prediction")
    
    CamlockSection:AddToggle({
        Label = "Auto Prediction", Default = Settings.CamlockAutoPrediction,
        Callback = function(val) Settings.CamlockAutoPrediction = val end
    })
    
    CamlockSection:AddSlider({
        Label = "Prediction", Min = 0.01, Max = 0.3, Default = Settings.CamlockPrediction, Decimals = 3,
        Callback = function(val) Settings.CamlockPrediction = val end
    })
    
    CamlockSection:AddSlider({
        Label = "Smoothness", Min = 0.05, Max = 0.5, Default = Settings.CamlockSmoothness, Decimals = 3,
        Callback = function(val) Settings.CamlockSmoothness = val end
    })
    
    CamlockSection:AddDivider("Hit Parts")
    
    CamlockSection:AddDropdown({
        Label = "Ground Hit Part",
        Items = {"HumanoidRootPart", "Head", "UpperTorso", "LowerTorso"},
        Default = Settings.CamlockHitPart,
        Callback = function(val) Settings.CamlockHitPart = val end
    })
    
    CamlockSection:AddDropdown({
        Label = "Air Hit Part",
        Items = {"HumanoidRootPart", "Head", "UpperTorso", "LowerTorso"},
        Default = Settings.CamlockAirPart,
        Callback = function(val) Settings.CamlockAirPart = val end
    })
    
    CamlockSection:AddDivider("Offsets")
    
    CamlockSection:AddSlider({
        Label = "Jump Offset", Min = 0, Max = 3, Default = Settings.CamlockJumpOffset, Decimals = 2,
        Callback = function(val) Settings.CamlockJumpOffset = val end
    })
    
    CamlockSection:AddSlider({
        Label = "Fall Offset", Min = 0, Max = 3, Default = Settings.CamlockFallOffset, Decimals = 2,
        Callback = function(val) Settings.CamlockFallOffset = val end
    })
    
    CamlockSection:AddSlider({
        Label = "Shake Amount", Min = 0, Max = 2, Default = Settings.CamlockShakeAmount, Decimals = 2,
        Callback = function(val) Settings.CamlockShakeAmount = val end
    })
    
    CamlockSection:AddSlider({
        Label = "Jitter Amount", Min = 0, Max = 2, Default = Settings.CamlockJitterAmount, Decimals = 2,
        Callback = function(val) Settings.CamlockJitterAmount = val end
    })
    
    CamlockSection:AddDivider("FOV Settings")
    
    CamlockSection:AddToggle({
        Label = "Show FOV", Default = Settings.CamlockShowFOV,
        Callback = function(val) Settings.CamlockShowFOV = val end
    })
    
    CamlockSection:AddSlider({
        Label = "FOV Radius", Min = 50, Max = 400, Default = Settings.CamlockFOVRadius, Decimals = 0,
        Callback = function(val) Settings.CamlockFOVRadius = val end
    })
    
    CamlockSection:AddColorPicker({
        Label = "FOV Colour", Default = Settings.CamlockFOVColor,
        Callback = function(col) Settings.CamlockFOVColor = col end
    })
    
    CamlockSection:AddDivider("Checks")
    
    CamlockSection:AddToggle({
        Label = "Wall Check", Default = Settings.CamlockWallCheck,
        Callback = function(val) Settings.CamlockWallCheck = val end
    })
    
    CamlockSection:AddToggle({
        Label = "Knocked Check", Default = Settings.CamlockKnockedCheck,
        Callback = function(val) Settings.CamlockKnockedCheck = val end
    })
    
    CamlockSection:AddToggle({
        Label = "Crew Check", Default = Settings.CamlockCrewCheck,
        Callback = function(val) Settings.CamlockCrewCheck = val end
    })
    
    CamlockSection:AddToggle({
        Label = "Grabbed Check", Default = Settings.CamlockGrabbedCheck,
        Callback = function(val) Settings.CamlockGrabbedCheck = val end
    })
    
    CamlockSection:AddToggle({
        Label = "Resolver", Default = Settings.CamlockResolver,
        Callback = function(val) Settings.CamlockResolver = val end
    })
    
    CamlockSection:AddDivider("Highlight")
    
    CamlockSection:AddToggle({
        Label = "Show Highlight", Default = Settings.CamlockShowHighlight,
        Callback = function(val) Settings.CamlockShowHighlight = val end
    })
    
    CamlockSection:AddColorPicker({
        Label = "Highlight Colour", Default = Settings.CamlockHighlightColor,
        Callback = function(col) Settings.CamlockHighlightColor = col end
    })
    
    CamlockSection:AddSlider({
        Label = "Highlight Transparency", Min = 0, Max = 1, Default = Settings.CamlockHighlightTransparency, Decimals = 2,
        Callback = function(val) Settings.CamlockHighlightTransparency = val end
    })

    local SilentSection = CombatTab:AddSection("Silent Aim")
    
    SilentSection:AddToggle({
        Label = "Enable Silent Aim",
        Default = Settings.SilentEnabled,
        Callback = function(val) Settings.SilentEnabled = val end
    })
    
    SilentSection:AddDivider("Prediction")
    
    SilentSection:AddToggle({
        Label = "Auto Prediction", Default = Settings.SilentAutoPrediction,
        Callback = function(val) Settings.SilentAutoPrediction = val end
    })
    
    SilentSection:AddSlider({
        Label = "Prediction", Min = 0.01, Max = 0.3, Default = Settings.SilentPrediction, Decimals = 3,
        Callback = function(val) Settings.SilentPrediction = val end
    })
    
    SilentSection:AddDivider("FOV Settings")
    
    SilentSection:AddToggle({
        Label = "Show FOV", Default = Settings.SilentShowFOV,
        Callback = function(val) Settings.SilentShowFOV = val end
    })
    
    SilentSection:AddSlider({
        Label = "FOV Radius", Min = 50, Max = 400, Default = Settings.SilentFOVRadius, Decimals = 0,
        Callback = function(val) Settings.SilentFOVRadius = val end
    })
    
    SilentSection:AddColorPicker({
        Label = "FOV Colour", Default = Settings.SilentFOVColor,
        Callback = function(col) Settings.SilentFOVColor = col end
    })
    
    SilentSection:AddDivider("Checks")
    
    SilentSection:AddToggle({
        Label = "Wall Check", Default = Settings.SilentWallCheck,
        Callback = function(val) Settings.SilentWallCheck = val end
    })
    
    SilentSection:AddToggle({
        Label = "Knocked Check", Default = Settings.SilentKnockedCheck,
        Callback = function(val) Settings.SilentKnockedCheck = val end
    })
    
    SilentSection:AddToggle({
        Label = "Crew Check", Default = Settings.SilentCrewCheck,
        Callback = function(val) Settings.SilentCrewCheck = val end
    })
    
    SilentSection:AddToggle({
        Label = "Grabbed Check", Default = Settings.SilentGrabbedCheck,
        Callback = function(val) Settings.SilentGrabbedCheck = val end
    })
    
    SilentSection:AddToggle({
        Label = "Anti Curve", Default = Settings.SilentAntiCurve,
        Callback = function(val) Settings.SilentAntiCurve = val end
    })
    
    SilentSection:AddToggle({
        Label = "No Ground Shots", Default = Settings.SilentNoGroundShots,
        Callback = function(val) Settings.SilentNoGroundShots = val end
    })
    
    SilentSection:AddSlider({
        Label = "Hit Chance %", Min = 0, Max = 100, Default = Settings.SilentHitChance, Decimals = 0,
        Callback = function(val) Settings.SilentHitChance = val end
    })
    
    SilentSection:AddToggle({
        Label = "Nearest Point", Default = Settings.SilentNearestPoint,
        Callback = function(val) Settings.SilentNearestPoint = val end
    })

    local TriggerSection = CombatTab:AddSection("Triggerbot")
    
    TriggerSection:AddToggle({
        Label = "Enable Triggerbot",
        Default = Settings.TriggerbotEnabled,
        Callback = function(val) Settings.TriggerbotEnabled = val end
    })
    
    TriggerSection:AddKeybind({
        Label = "Triggerbot Keybind",
        Default = Settings.TriggerbotKeybind,
        Callback = function(key) Settings.TriggerbotKeybind = key end
    })
    
    TriggerSection:AddSlider({
        Label = "Delay (seconds)", Min = 0.01, Max = 0.3, Default = Settings.TriggerbotDelay, Decimals = 3,
        Callback = function(val) Settings.TriggerbotDelay = val end
    })
    
    TriggerSection:AddToggle({
        Label = "Wall Check", Default = Settings.TriggerbotWallCheck,
        Callback = function(val) Settings.TriggerbotWallCheck = val end
    })
    
    TriggerSection:AddToggle({
        Label = "Knocked Check", Default = Settings.TriggerbotKnockedCheck,
        Callback = function(val) Settings.TriggerbotKnockedCheck = val end
    })

    local RapidSection = CombatTab:AddSection("Rapid Fire")
    
    RapidSection:AddToggle({
        Label = "Enable Rapid Fire",
        Default = Settings.RapidFireEnabled,
        Callback = function(val) Settings.RapidFireEnabled = val end
    })
    
    RapidSection:AddSlider({
        Label = "Delay (seconds)", Min = 0.01, Max = 0.2, Default = Settings.RapidFireDelay, Decimals = 3,
        Callback = function(val) Settings.RapidFireDelay = val end
    })

    -- MOVEMENT TAB
    local MovementTab = Window:AddTab("MOVEMENT", "🏃")

    local FlySection = MovementTab:AddSection("Fly")
    
    FlySection:AddToggle({
        Label = "Enable Fly",
        Default = Settings.FlyEnabled,
        Callback = function(val) Settings.FlyEnabled = val end
    })
    
    FlySection:AddKeybind({
        Label = "Fly Keybind",
        Default = Settings.FlyKeybind,
        Callback = function(key) Settings.FlyKeybind = key end
    })
    
    FlySection:AddSlider({
        Label = "Fly Speed", Min = 10, Max = 500, Default = Settings.FlySpeed, Decimals = 0,
        Callback = function(val) Settings.FlySpeed = val end
    })

    local CFrameWalkSection = MovementTab:AddSection("CFrame Walk")
    
    CFrameWalkSection:AddToggle({
        Label = "Enable CFrame Walk",
        Default = Settings.CFrameWalkEnabled,
        Callback = function(val) Settings.CFrameWalkEnabled = val end
    })
    
    CFrameWalkSection:AddKeybind({
        Label = "CFrame Walk Keybind",
        Default = Settings.CFrameWalkKeybind,
        Callback = function(key) Settings.CFrameWalkKeybind = key end
    })
    
    CFrameWalkSection:AddSlider({
        Label = "CFrame Speed", Min = 10, Max = 500, Default = Settings.CFrameWalkSpeed, Decimals = 0,
        Callback = function(val) Settings.CFrameWalkSpeed = val end
    })

    local MiscMovementSection = MovementTab:AddSection("Misc Movement")
    
    MiscMovementSection:AddToggle({
        Label = "No Jump Cooldown",
        Default = Settings.NoJumpCooldown,
        Callback = function(val) Settings.NoJumpCooldown = val end
    })
    
    MiscMovementSection:AddToggle({
        Label = "No Sit",
        Default = Settings.NoSit,
        Callback = function(val) Settings.NoSit = val end
    })
    
    MiscMovementSection:AddToggle({
        Label = "No Slow",
        Default = Settings.NoSlow,
        Callback = function(val) Settings.NoSlow = val end
    })

    -- ANTI-AIM TAB
    local AntiAimTab = Window:AddTab("ANTI-AIM", "🔄")

    local VelocitySection = AntiAimTab:AddSection("Velocity Desync")
    
    VelocitySection:AddToggle({
        Label = "Enable Velocity Desync",
        Default = Settings.VelocityDesyncEnabled,
        Callback = function(val) Settings.VelocityDesyncEnabled = val end
    })
    
    VelocitySection:AddKeybind({
        Label = "Velocity Desync Keybind",
        Default = Settings.VelocityDesyncKeybind,
        Callback = function(key) Settings.VelocityDesyncKeybind = key end
    })
    
    VelocitySection:AddSlider({
        Label = "Speed", Min = 1, Max = 400, Default = Settings.VelocityDesyncSpeed, Decimals = 0,
        Callback = function(val) Settings.VelocityDesyncSpeed = val end
    })

    local FakePosSection = AntiAimTab:AddSection("Fake Position Desync")
    
    FakePosSection:AddToggle({
        Label = "Enable Fake Pos Desync",
        Default = Settings.FakePosDesyncEnabled,
        Callback = function(val) Settings.FakePosDesyncEnabled = val end
    })
    
    FakePosSection:AddKeybind({
        Label = "Fake Pos Keybind",
        Default = Settings.FakePosDesyncKeybind,
        Callback = function(key) Settings.FakePosDesyncKeybind = key end
    })

    local FFlagSection = AntiAimTab:AddSection("FFlag Desync")
    
    FFlagSection:AddToggle({
        Label = "Enable FFlag Desync",
        Default = Settings.FFlagDesyncEnabled,
        Callback = function(val) Settings.FFlagDesyncEnabled = val end
    })

    local NetworkSection = AntiAimTab:AddSection("Network Desync")
    
    NetworkSection:AddToggle({
        Label = "Enable Network Desync",
        Default = Settings.NetworkDesyncEnabled,
        Callback = function(val) Settings.NetworkDesyncEnabled = val end
    })

    -- VISUALS TAB
    local VisualsTab = Window:AddTab("VISUALS", "👁")

    local ESPSection = VisualsTab:AddSection("ESP")
    
    ESPSection:AddToggle({
        Label = "Show Highlight",
        Default = Settings.ShowHighlight,
        Callback = function(val) Settings.ShowHighlight = val end
    })
    
    ESPSection:AddToggle({
        Label = "Show Health Bar",
        Default = Settings.ShowHealthBar,
        Callback = function(val) Settings.ShowHealthBar = val end
    })
    
    ESPSection:AddToggle({
        Label = "Show Name Tags",
        Default = Settings.ShowNameTags,
        Callback = function(val) Settings.ShowNameTags = val end
    })
    
    ESPSection:AddToggle({
        Label = "Show Distance",
        Default = Settings.ShowDistance,
        Callback = function(val) Settings.ShowDistance = val end
    })

    local WorldSection = VisualsTab:AddSection("World")
    
    WorldSection:AddToggle({
        Label = "Fullbright",
        Default = Settings.FullbrightEnabled,
        Callback = function(val) Settings.FullbrightEnabled = val end
    })
    
    WorldSection:AddToggle({
        Label = "Chams (through walls)",
        Default = Settings.ChamsEnabled,
        Callback = function(val) Settings.ChamsEnabled = val end
    })
    
    WorldSection:AddColorPicker({
        Label = "Chams Colour",
        Default = Settings.ChamsColor,
        Callback = function(col) Settings.ChamsColor = col end
    })
    
    WorldSection:AddSlider({
        Label = "Chams Transparency", Min = 0, Max = 1, Default = Settings.ChamsTransparency, Decimals = 2,
        Callback = function(val) Settings.ChamsTransparency = val end
    })

    -- SETTINGS TAB
    local SettingsTab = Window:AddTab("SETTINGS", "⚙")

    local UISection = SettingsTab:AddSection("UI Settings")
    
    UISection:AddKeybind({
        Label = "Toggle UI Keybind",
        Default = Enum.KeyCode.RightControl,
        Callback = function(key) LeisureLib:SetToggleKeybind(key) end
    })
    
    UISection:AddColorPicker({
        Label = "Accent Colour",
        Default = Color3.fromRGB(255, 100, 165),
        Callback = function(col) LeisureLib.Theme.Accent = col end
    })
    
    UISection:AddDivider("Actions")
    
    UISection:AddButton({
        Label = "Destroy UI",
        Color = Color3.fromRGB(200, 50, 70),
        Callback = function()
            local CoreGui = game:GetService("CoreGui")
            local g = CoreGui:FindFirstChild("LeisureGG")
            if g then g:Destroy() end
            local blur = Lighting:FindFirstChildOfClass("BlurEffect")
            if blur then blur:Destroy() end
            LeisureLib.Notify("UI", "UI destroyed", 2, "warning")
        end
    })

    local StaffSection = SettingsTab:AddSection("Staff Alert")
    
    StaffSection:AddToggle({
        Label = "Enable Staff Alert",
        Default = Settings.StaffAlertEnabled,
        Callback = function(val) Settings.StaffAlertEnabled = val end
    })
    
    StaffSection:AddDropdown({
        Label = "Action",
        Items = {"Notify", "Kick"},
        Default = Settings.StaffAlertAction,
        Callback = function(val) Settings.StaffAlertAction = val end
    })
    
    StaffSection:AddSlider({
        Label = "Notification Duration (sec)",
        Min = 1, Max = 10, Default = Settings.StaffAlertDuration, Decimals = 0,
        Callback = function(val) Settings.StaffAlertDuration = val end
    })

    local WhitelistSection = SettingsTab:AddSection("Player Whitelist")
    
    local whitelistBox = WhitelistSection:AddTextBox({
        Label = "Player ID or Name",
        Placeholder = "Enter ID or Name",
        Default = ""
    })
    
    WhitelistSection:AddButton({
        Label = "Add to Whitelist",
        Color = Color3.fromRGB(80, 200, 120),
        Callback = function()
            local input = whitelistBox:Get()
            if input ~= "" then
                local num = tonumber(input)
                if num then
                    table.insert(Settings.Whitelist, num)
                else
                    table.insert(Settings.Whitelist, input)
                end
                LeisureLib.Notify("Whitelist", "Added: " .. input, 2, "success")
                whitelistBox:Set("")
            end
        end
    })
    
    WhitelistSection:AddButton({
        Label = "Clear Whitelist",
        Color = Color3.fromRGB(200, 60, 70),
        Callback = function()
            Settings.Whitelist = {}
            LeisureLib.Notify("Whitelist", "Cleared all entries", 2, "warning")
        end
    })

    local ConfigSection = SettingsTab:AddSection("Config")
    
    local configNameBox = ConfigSection:AddTextBox({
        Label = "Config Name",
        Placeholder = "my_config",
        Default = ""
    })
    
    ConfigSection:AddButton({
        Label = "Save Config",
        Color = Color3.fromRGB(80, 200, 130),
        Callback = function()
            local name = configNameBox:Get()
            if name == "" then name = "default" end
            LeisureLib.Config:Save(name, Settings)
            LeisureLib.Notify("Config", "Saved: " .. name, 2, "success")
        end
    })
    
    ConfigSection:AddButton({
        Label = "Load Config",
        Color = Color3.fromRGB(100, 160, 255),
        Callback = function()
            local name = configNameBox:Get()
            if name == "" then name = "default" end
            local data = LeisureLib.Config:Load(name)
            if data then
                for k, v in pairs(data) do
                    if Settings[k] ~= nil then Settings[k] = v end
                end
                LeisureLib.Notify("Config", "Loaded: " .. name, 2, "success")
            end
        end
    })
    
    ConfigSection:AddButton({
        Label = "Delete Config",
        Color = Color3.fromRGB(200, 60, 70),
        Callback = function()
            local name = configNameBox:Get()
            if name ~= "" then
                LeisureLib.Config:Delete(name)
                LeisureLib.Notify("Config", "Deleted: " .. name, 2, "warning")
            end
        end
    })

    local AboutSection = SettingsTab:AddSection("About")
    AboutSection:AddLabel("leisure.gg Complete Combat Script")
    AboutSection:AddLabel("made by @x_vvw")
    AboutSection:AddLabel("Version: 2.0.0")
    AboutSection:AddDivider()
    AboutSection:AddLabel("Toggle UI: RightControl (rebindable)")
    AboutSection:AddLabel("Press Q to lock/unlock Camlock")
    AboutSection:AddLabel("Press X to lock/unlock Mouselock")
    AboutSection:AddLabel("Anti-VelvetX protection active")

end)
