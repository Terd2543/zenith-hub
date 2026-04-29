-- ================================
-- ZENITH HUB - FULLY FIXED
-- Removed UIShadow (fixed Size error)
-- No local register overflow (used Zenith table)
-- ================================

-- เก็บตัวแปรหลักไว้ในตาราง Zenith เพื่อลดจำนวน local registers
getgenv().Zenith = getgenv().Zenith or {}
local Z = getgenv().Zenith

-- ประกาศฟังก์ชันและตัวแปรแบบ global (ไม่มี local) เพื่อไม่ให้กิน local registers
Players = game:GetService("Players")
RunService = game:GetService("RunService")
Debris = game:GetService("Debris")
ReplicatedStorage = game:GetService("ReplicatedStorage")
Workspace = game:GetService("Workspace")
PathfindingService = game:GetService("PathfindingService")
VIM = game:GetService("VirtualInputManager")
GuiService = game:GetService("GuiService")
UserInputService = game:GetService("UserInputService")
CoreGui = game:GetService("CoreGui")
TweenService = game:GetService("TweenService")
ContextActionService = game:GetService("ContextActionService")
HttpService = game:GetService("HttpService")
TeleportService = game:GetService("TeleportService")

-- ต้องรอให้ Net โหลดก่อน แต่เราจะใช้ pcall จัดการในภายหลัง
local NetModule, RagdollModule, CharModule, Util, BuyPromptUI, EmotesUI, EmotesList, CoreUI, ItemsFolder, MeleeFolder
pcall(function()
    NetModule = require(ReplicatedStorage.Modules.Core.Net)
    RagdollModule = require(game.ReplicatedStorage.Modules.Game.Ragdoll)
    CharModule = require(game.ReplicatedStorage.Modules.Core.Char)
    Util = require(ReplicatedStorage.Modules.Core.Util)
    BuyPromptUI = require(ReplicatedStorage.Modules.Game.UI.BuyPromptUI)
    EmotesUI = require(ReplicatedStorage.Modules.Game.Emotes.EmotesUI)
    EmotesList = require(ReplicatedStorage.Modules.Game.Emotes.EmotesList)
    CoreUI = require(ReplicatedStorage.Modules.Core.UI)
    ItemsFolder = ReplicatedStorage:WaitForChild("Items")
    MeleeFolder = ItemsFolder:WaitForChild("melee")
end)

-- ========== PART 1: โหมดเลือก (Normal / God) - FIXED (removed UIShadow) ==========
local Client = Players.LocalPlayer
local playerGui = Client:WaitForChild("PlayerGui")
local Done = false

local function checkCondition()
    local splashScreenGui = playerGui:FindFirstChild("SplashScreenGui")
    if splashScreenGui then
        local frame = splashScreenGui:FindFirstChild("Frame")
        if frame then
            local playButton = frame:FindFirstChild("PlayButton")
            if playButton and playButton.Visible == true then
                return true
            end
        end
    end
    return false
end

if checkCondition() then
    local FONT = Enum.Font.GothamBold
    local FONT_BUTTON = Enum.Font.GothamSemibold

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "zhXUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui

    -- Main Frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 380, 0, 150)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    main.BackgroundTransparency = 0.12
    main.BorderSizePixel = 0
    main.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 24)
    corner.Parent = main

    -- Outer glow stroke (แทน UIShadow ที่ถูกลบ)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(120, 150, 255)
    stroke.Thickness = 1.8
    stroke.Transparency = 0.45
    stroke.Parent = main

    -- Gradient background
    local bgGradient = Instance.new("UIGradient")
    bgGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 40))
    }
    bgGradient.Rotation = 135
    bgGradient.Parent = main

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 44)
    title.Position = UDim2.new(0, 0, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = "✨ ZENITH HUB ✨"
    title.Font = FONT
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(235, 235, 255)
    title.TextStrokeTransparency = 0.4
    title.TextStrokeColor3 = Color3.fromRGB(80, 100, 200)
    title.Parent = main

    local function makeButton(txt, xPos, colorAccent)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 150, 0, 46)
        btn.Position = UDim2.new(0, xPos, 0, 80)
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
        btn.BackgroundTransparency = 0.3
        btn.Text = txt
        btn.Font = FONT_BUTTON
        btn.TextSize = 17
        btn.TextColor3 = Color3.fromRGB(230, 230, 255)
        btn.AutoButtonColor = false
        btn.Parent = main

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 14)
        btnCorner.Parent = btn

        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = colorAccent or Color3.fromRGB(100, 130, 255)
        btnStroke.Thickness = 1.2
        btnStroke.Transparency = 0.5
        btnStroke.Parent = btn

        local hoverIn = TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.1,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        })
        local hoverOut = TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.3,
            TextColor3 = Color3.fromRGB(230, 230, 255)
        })
        local strokeIn = TweenService:Create(btnStroke, TweenInfo.new(0.2), { Transparency = 0.15 })
        local strokeOut = TweenService:Create(btnStroke, TweenInfo.new(0.2), { Transparency = 0.5 })

        btn.MouseEnter:Connect(function()
            hoverIn:Play()
            strokeIn:Play()
        end)
        btn.MouseLeave:Connect(function()
            hoverOut:Play()
            strokeOut:Play()
        end)

        return btn
    end

    local normalBtn = makeButton("🔰 NORMAL MODE", 30, Color3.fromRGB(80, 200, 120))
    local godBtn = makeButton("👑 GOD MODE", 200, Color3.fromRGB(255, 100, 100))

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0.8, 0, 0, 1.5)
    line.Position = UDim2.new(0.1, 0, 0.55, 0)
    line.BackgroundColor3 = Color3.fromRGB(100, 130, 255)
    line.BackgroundTransparency = 0.6
    line.BorderSizePixel = 0
    line.Parent = main
    Instance.new("UICorner", line).CornerRadius = UDim.new(1, 0)

    main.BackgroundTransparency = 0.25
    local fadeIn = TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.12
    })
    fadeIn:Play()

    local function destroyUI()
        local fadeOut = TweenService:Create(main, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        })
        fadeOut:Play()
        fadeOut.Completed:Wait()
        screenGui:Destroy()
    end

    local function pressButton(guiObject)
        if not guiObject then return end
        pcall(function()
            guiObject:Activate()
        end)
        pcall(function()
            firesignal(guiObject.MouseButton1Click)
        end)
        pcall(function()
            firesignal(guiObject.Activated)
        end)
    end

    normalBtn.MouseButton1Click:Connect(function()
        destroyUI()
        task.spawn(function()
            task.wait(2.5)
            local splashGui = playerGui:FindFirstChild("SplashScreenGui")
            if splashGui and splashGui.Enabled then
                local frame = splashGui:FindFirstChild("Frame")
                local playButton = frame and frame:FindFirstChild("PlayButton")
                pressButton(playButton)
            end
            Done = true
        end)
    end)

    godBtn.MouseButton1Click:Connect(function()
        destroyUI()
        task.spawn(function()
            local Creator = require(ReplicatedStorage.Modules.Game.CharacterCreator.CharacterCreator)
            local Util = require(ReplicatedStorage.Modules.Core.Util)
            local UI = require(ReplicatedStorage.Modules.Core.UI)
            local Char = require(ReplicatedStorage.Modules.Core.Char)

            if not _G.Bypass then
                local func = getupvalue(NetModule.get,2)
                if func then
                    setconstant(func,3,"KUYIENGOKUYIENGO")
                    setconstant(func,4,"KUYIENGOKUYIENGO")
                end
                _G.Bypass = true
            end

            local old
            old = hookfunction(NetModule.send,function(...)
                local d = {...}
                if d[1] == "leave_character_creator" or d[1] == "player_created_outfit" then
                    return nil
                end
                return old(...)
            end)

            task.wait(2.5)
            local splashGui = playerGui:FindFirstChild("SplashScreenGui")
            if splashGui and splashGui.Enabled then
                local frame = splashGui:FindFirstChild("Frame")
                local playButton = frame and frame:FindFirstChild("PlayButton")
                pressButton(playButton)
            end

            task.wait(4)
            local characterCreator = playerGui:FindFirstChild("CharacterCreator")
            if characterCreator then
                local menuFrame = characterCreator:FindFirstChild("MenuFrame")
                local skipButton = menuFrame and menuFrame:FindFirstChild("AvatarMenuSkipButton")
                pressButton(skipButton)
            end

            task.wait(2.5)
            replicatesignal(game.Players.LocalPlayer.Kill)
            task.wait(7)
            NetModule.send("death_screen_request_respawn")
            Done = true
        end)
    end)

else
    Done = true
end

repeat task.wait() until Done

-- ========== PART 2: ZENITH HUB (เต็มรูปแบบ) ==========
-- ใช้ _G.Zenith สำหรับเก็บ state และตัวแปรต่างๆ เพื่อลดจำนวน local variables

-- สร้าง namespace หลัก
Z = getgenv().Zenith
Z.raknetLib = raknet
Z.desyncEnabled = false
Z.setDesync = function(state)
    if Z.raknetLib then
        if state then
            Z.raknetLib.desync(true)
            print("[Success] เปิดโหมดล่องหน (Desync) เรียบร้อยแล้ว")
        else
            Z.raknetLib.desync(false)
            print("[Success] ปิดโหมดล่องหน (Desync) แล้ว")
        end
    else
        warn("[Error] ไม่พบ Raknet library ใน Executor นี้")
    end
end

-- ตัวแปรสำคัญของระบบ
Z.LocalPlayer = Players.LocalPlayer
Z.Character = Z.LocalPlayer.Character or Z.LocalPlayer.CharacterAdded:Wait()
Z.Humanoid = Z.Character:WaitForChild("Humanoid")
Z.HumanoidRootPart = Z.Character:WaitForChild("HumanoidRootPart")
Z.Camera = Workspace.CurrentCamera
Z.Mouse = Z.LocalPlayer:GetMouse()
Z.isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
Z.item_drawings = {}
Z.droppedItems = workspace:WaitForChild("DroppedItems")
Z.WeaponDB = {}
Z.BillboardCache = {}
Z.espPlayers = {}
Z.playerHighlights = {}
Z.PositionHistory = {}
Z.TracerSmoothedPos = Vector3.new()
Z.CounterTable = nil

-- รันหา CounterTable
pcall(function()
    for _, obj in ipairs(getgc(true)) do
        if typeof(obj) == "table" and rawget(obj, "event") and rawget(obj, "func") then
            Z.CounterTable = obj
            break
        end
    end
end)

-- ฟังก์ชัน utilities (global)
function getPing()
    local gui = Z.LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return 0.2 end
    local stats = gui:FindFirstChild("NetworkStats")
    if not stats then return 0.2 end
    local pingLabel = stats:FindFirstChild("PingLabel")
    if not pingLabel then return 0.2 end
    local text = pingLabel.Text
    if type(text) ~= "string" then return 0.2 end
    local num = tonumber(text:match("%d+"))
    if not num then return 0.2 end
    local ping = num / 1000
    if ping < 0 or ping > 2 then ping = 0.2 end
    return ping
end

function isPlayerExcluded(playerName)
    for _, excludedName in ipairs(Z.excludedPlayerNames or {}) do
        if excludedName ~= "" and string.find(string.lower(playerName), string.lower(excludedName)) then
            return true
        end
    end
    return false
end

function getClosestTarget()
    local closest = nil
    local shortestDistance = Z.FOVRadius or 120
    local center = Vector2.new(Z.Camera.ViewportSize.X / 2, Z.Camera.ViewportSize.Y / 2)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Z.LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if head and humanoid and humanoid.Health > 0 and hrp then
                local screenPos, onScreen = Z.Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local screenVector = Vector2.new(screenPos.X, screenPos.Y)
                    local distanceFromCenter = (screenVector - center).Magnitude
                    if distanceFromCenter <= (Z.FOVRadius or 120) and not isPlayerExcluded(player.Name) then
                        if distanceFromCenter < shortestDistance then
                            shortestDistance = distanceFromCenter
                            closest = player
                        end
                    end
                end
            end
        end
    end
    return closest
end

function predictPosition(targetPart, hrp)
    if not targetPart then return Vector3.zero end
    local character = targetPart.Parent
    local player = character and Players:GetPlayerFromCharacter(character)
    if not player then return targetPart.Position end
    local velocity = Z.calculateVelocity and Z.calculateVelocity(player) or Vector3.zero
    local ping = getPing() or 0.1
    if ping < 0 then ping = 0.1 end
    return targetPart.Position + (velocity * ping * 1.2)
end

function isBehindWall(startPos, endPos)
    if not startPos or not endPos then return false end
    local direction = endPos - startPos
    if direction.Magnitude < 1 then return false end
    local ignoreList = {}
    local char = Z.LocalPlayer.Character
    if char then table.insert(ignoreList, char) end
    local tgtChar = Z.CurrentTarget and Z.CurrentTarget.Character
    if tgtChar then table.insert(ignoreList, tgtChar) end
    local raycastResult = workspace:Raycast(startPos, direction, RaycastParams.new())
    if not raycastResult then return false end
    local hitPart = raycastResult.Instance
    return hitPart and not table.find(ignoreList, hitPart.Parent)
end

function setupCharacter(char)
    Z.Character = char
    Z.Humanoid = char:WaitForChild("Humanoid")
    Z.HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    if Z.moveConnection then pcall(function() Z.moveConnection:Disconnect() end) end
    Z.moveConnection = RunService.RenderStepped:Connect(function()
        if Z.walkSpeedEnabled and Z.Humanoid and Z.HumanoidRootPart then
            if Z.Humanoid.MoveDirection.Magnitude > 0 then
                Z.HumanoidRootPart.CFrame = Z.HumanoidRootPart.CFrame + (Z.Humanoid.MoveDirection.Unit * (Z.speedValue or 0.05))
            end
        end
    end)
end

function isDowned()
    local hum = CharModule and CharModule.get_hum() or nil
    if not hum then return false end
    if hum.Health <= 0 then return false end
    return hum:GetAttribute("HasBeenDowned") or hum:GetAttribute("IsDead")
end

function getHRP()
    local char = CharModule and CharModule.current_char and CharModule.current_char.get() or nil
    if not char then return end
    return char:FindFirstChild("HumanoidRootPart")
end

function teleportUnderground()
    local hrp = getHRP()
    if not hrp then return end
    Z.undergroundBaseCFrame = hrp.CFrame + Vector3.new(0, -55, 0)
    hrp.CFrame = Z.undergroundBaseCFrame
end

function flickerAndMove()
    if Z.flickering then return end
    Z.flickering = true
    task.spawn(function()
        while Z.flickering and Z.enabled and isDowned() do
            local hum = CharModule and CharModule.get_hum()
            if hum and hum.Health <= 0 then break end
            local hrp = getHRP()
            if hrp and Z.undergroundBaseCFrame then
                local angle = math.random() * math.pi * 2
                local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * 30
                local randomPos = Z.undergroundBaseCFrame.Position + offset
                hrp.CFrame = CFrame.new(randomPos)
                task.wait(0.05)
                hrp.CFrame = Z.undergroundBaseCFrame
            end
            task.wait(0.1)
        end
        Z.flickering = false
    end)
end

function NetGet(...)
    if not Z.CounterTable or not Z.CounterTable.func then return end
    local args = {...}
    for i, v in ipairs(args) do
        if typeof(v) == "Instance" then
            if v:IsA("Model") and #v:GetChildren() == 0 then
                local fallback = Workspace:FindFirstChild("DroppedItems")
                if fallback then
                    local model = fallback:FindFirstChildWhichIsA("Model")
                    if model then args[i] = model else return end
                else return end
            end
        end
    end
    Z.CounterTable.func = (Z.CounterTable.func or 0) + 1
    local success, result = pcall(function()
        local GetRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Get")
        return GetRemote:InvokeServer(Z.CounterTable.func, unpack(args))
    end)
    if not success then warn("[NetGet Error]", result) end
    return result
end

function CheckAndPickup()
    if not Z.sucking then return end
    local dropped = Workspace:FindFirstChild("DroppedItems")
    if not dropped then return end
    local now = tick()
    local itemsToPickup = {}
    for _, item in ipairs(dropped:GetChildren()) do
        if item:IsA("Model") then
            local part = item:FindFirstChildWhichIsA("BasePart")
            if part then
                local distance = (Z.HumanoidRootPart.Position - part.Position).Magnitude
                if distance <= 20 and (now - (Z.lastPickupTimes and Z.lastPickupTimes[item] or 0)) >= 0 then
                    table.insert(itemsToPickup, item)
                    if not Z.lastPickupTimes then Z.lastPickupTimes = {} end
                    Z.lastPickupTimes[item] = now
                end
            end
        end
    end
    if #itemsToPickup > 0 then
        for _, item in ipairs(itemsToPickup) do
            spawn(function() NetGet("pickup_dropped_item", item) end)
        end
    end
end

function SafeCall(f, ...) return pcall(f, ...) end
local tu_unpack = table.unpack or unpack

function CallRemote(remote, ...)
    if not remote then return end
    local args = {...}
    if remote.ClassName == "RemoteEvent" then
        if Z.CounterTable and type(Z.CounterTable.event) == "number" then
            Z.CounterTable.event = Z.CounterTable.event + 1
            SafeCall(function(...) remote:FireServer(Z.CounterTable.event, ...) end, tu_unpack(args))
        else
            Z.localEventCounter = (Z.localEventCounter or 0) + 1
            SafeCall(function(...) remote:FireServer(Z.localEventCounter, ...) end, tu_unpack(args))
        end
    elseif remote.ClassName == "RemoteFunction" then
        if Z.CounterTable and type(Z.CounterTable.func) == "number" then
            Z.CounterTable.func = Z.CounterTable.func + 1
            SafeCall(function(...) remote:InvokeServer(Z.CounterTable.func, ...) end, tu_unpack(args))
        else
            Z.localFuncCounter = (Z.localFuncCounter or 0) + 1
            SafeCall(function(...) remote:InvokeServer(Z.localFuncCounter, ...) end, tu_unpack(args))
        end
    else
        SafeCall(function(...)
            if remote.FireServer then remote:FireServer(...)
            elseif remote.InvokeServer then remote:InvokeServer(...) end
        end, tu_unpack(args))
    end
end

function getPlayersInRange(radius)
    local inRange = {}
    local char = Z.LocalPlayer.Character
    if not char or not char.PrimaryPart then return inRange end
    local pos = char.PrimaryPart.Position
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Z.LocalPlayer and player.Character and player.Character.PrimaryPart then
            local ok, mag = pcall(function() return (player.Character.PrimaryPart.Position - pos).Magnitude end)
            if ok and mag and mag <= radius then table.insert(inRange, player) end
        end
    end
    return inRange
end

function getActiveTool()
    local char = Z.LocalPlayer and Z.LocalPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if pcall(function() return item:IsA("Tool") end) and item:IsA("Tool") then return item end
        end
    end
    local backpack = Z.LocalPlayer and Z.LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if pcall(function() return item:IsA("Tool") end) and item:IsA("Tool") then return item end
        end
    end
    return nil
end

function isMeleeTool(tool)
    if not tool then return false end
    if tool.Name == "Fists" then return true end
    local meleeItems = ReplicatedStorage:WaitForChild("Items"):WaitForChild("melee")
    local throwableItems = ReplicatedStorage:WaitForChild("Items"):WaitForChild("throwable")
    if meleeItems:FindFirstChild(tool.Name) and not throwableItems:FindFirstChild(tool.Name) then return true end
    return false
end

function AttackNearby()
    if not Z.Remote then return end
    local char = Z.LocalPlayer.Character
    if not char or not char.PrimaryPart then return end
    local tool = getActiveTool()
    if not tool or not isMeleeTool(tool) then return end
    local okParent, parent = pcall(function() return tool.Parent end)
    if not okParent or parent ~= Z.LocalPlayer.Character then return end
    local targets = getPlayersInRange(Z.scanRadius or 20)
    if #targets == 0 then return end
    local okLocalPos, localPos = pcall(function() return char.PrimaryPart.Position end)
    if not okLocalPos or not localPos then return end
    local playerTargets = {}
    local predictedPositions = {}
    for _, player in pairs(targets) do
        if player and player.Character and player.Character.PrimaryPart then
            local head = player.Character:FindFirstChild("Head")
            local hrp = player.Character.PrimaryPart
            if head and hrp then
                local predictedPos = predictPosition(head, hrp)
                table.insert(playerTargets, player)
                table.insert(predictedPositions, predictedPos)
            end
        end
    end
    if #playerTargets == 0 then return end
    local primaryPredictedPos = predictedPositions[1]
    local lookAtCFrame = CFrame.lookAt(localPos, primaryPredictedPos)
    local args = { "melee_attack", tool, playerTargets, lookAtCFrame, 0.75 }
    pcall(function() CallRemote(Z.Remote, tu_unpack(args)) end)
end

Z.running = false
function StartAutoAttack()
    if Z.running then return end
    Z.running = true
    task.spawn(function()
        while Z.running do
            task.wait(Z.scanInterval or 0.4)
            if Z.hookEnabled and Z.LocalPlayer and Z.LocalPlayer.Character and Z.LocalPlayer.Character.PrimaryPart then
                pcall(AttackNearby)
            end
        end
    end)
end

function createNeonEffectAtPosition(pos, fadeTime) end
function performTeleport()
    if not Z.HumanoidRootPart then return end
    local currentPos = Z.HumanoidRootPart.Position
    local bottomPos = Vector3.new(currentPos.X, currentPos.Y - (Z.maxHeight or 10), currentPos.Z)
    Z.HumanoidRootPart.CFrame = CFrame.new(bottomPos)
    Z.lockedY = bottomPos.Y
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://95298029662868"
    sound.Volume = 1
    sound.PlayOnRemove = true
    sound.Parent = Z.HumanoidRootPart
    sound:Destroy()
    createNeonEffectAtPosition(currentPos, 1.5)
    createNeonEffectAtPosition(bottomPos, 2)
end
function toggleTeleport()
    if not Z.featureEnabled then return end
    Z.teleportActive = not Z.teleportActive
    if Z.teleportActive then performTeleport() else Z.lockedY = nil end
end
Z.connection = nil
function lockYPosition()
    if Z.connection then pcall(function() Z.connection:Disconnect() end) end
    Z.connection = RunService.Heartbeat:Connect(function()
        if Z.teleportActive and Z.lockedY and Z.HumanoidRootPart then
            local currentPos = Z.HumanoidRootPart.Position
            if math.abs(currentPos.Y - Z.lockedY) > 0.1 then
                Z.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, Z.lockedY, currentPos.Z)
            end
        end
    end)
end

function registerItems(folder)
    for _, tool in ipairs(folder:GetChildren()) do
        if tool:IsA("Tool") then
            local handle = tool:FindFirstChild("Handle")
            local key = nil
            local displayName = tool:GetAttribute("DisplayName") or tool.Name
            local itemId = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
            local rarity = tool:GetAttribute("RarityName") or "Common"
            local imageId = tool:GetAttribute("ImageId") or "rbxassetid://7072725737"
            if handle then
                local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                if mesh and mesh.MeshId ~= "" then
                    key = mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
                elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then
                    key = handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity
                end
            end
            if not key and itemId and itemId ~= "" and itemId ~= tool.Name then
                key = "ITEMID_" .. itemId .. "_RARITY_" .. rarity
            end
            if not key then
                key = "NAME_" .. displayName .. "_" .. tool.Name .. "_RARITY_" .. rarity
            end
            if Z.WeaponDB[key] then
                warn("Duplicate weapon key detected: " .. key .. " (Tool: " .. tool.Name .. ", Rarity: " .. rarity .. ")")
            end
            Z.WeaponDB[key] = { Name = displayName, Rarity = rarity, ImageId = imageId, ToolName = tool.Name }
        end
    end
end

function getItemKey(tool)
    local handle = tool:FindFirstChild("Handle")
    local displayName = tool:GetAttribute("DisplayName") or tool.Name
    local itemId = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
    local rarity = tool:GetAttribute("RarityName") or "Common"
    if handle then
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if mesh and mesh.MeshId ~= "" then
            return mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
        elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then
            return handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity
        end
    end
    if itemId and itemId ~= "" and itemId ~= tool.Name then
        return "ITEMID_" .. itemId .. "_RARITY_" .. rarity
    end
    return "NAME_" .. displayName .. "_" .. tool.Name .. "_RARITY_" .. rarity
end

function getWeaponInfo(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    local key = getItemKey(tool)
    return Z.WeaponDB[key]
end

function createBillboardForPlayer(player)
    if not Z.ESPEnabled or player == Z.LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if Z.BillboardCache[player] then Z.BillboardCache[player]:Destroy() Z.BillboardCache[player] = nil end
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = hrp
    billboard.Size = UDim2.new(0, 90, 0, 20)
    billboard.StudsOffset = Vector3.new(0, -5.0, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = char
    billboard:ClearAllChildren()
    local layout = Instance.new("UIListLayout", billboard)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local tools = {}
    for _, container in ipairs({"Backpack", "StarterGear", "StarterPack"}) do
        local obj = player:FindFirstChild(container)
        if obj then
            for _, tool in ipairs(obj:GetChildren()) do
                if tool:IsA("Tool") and tool.Name ~= "Fists" then table.insert(tools, tool) end
            end
        end
    end
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name ~= "Fists" then table.insert(tools, tool) end
        end
    end
    for _, tool in ipairs(tools) do
        local info = getWeaponInfo(tool)
        if info then
            local img = Instance.new("ImageLabel", billboard)
            img.Size = UDim2.new(0, 20, 0, 20)
            img.BackgroundTransparency = 0.1
            img.Image = info.ImageId
            img.BackgroundColor3 = Color3.fromRGB(240, 248, 255)
            Instance.new("UICorner", img).CornerRadius = UDim.new(0, 10)
            local border = Instance.new("UIStroke", img)
            border.Color = Z.RARITY_COLORS and Z.RARITY_COLORS[info.Rarity] or Color3.new(1,1,1)
            border.Thickness = 2
        end
    end
    Z.BillboardCache[player] = billboard
end

function setFinishPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = Z.holdTime or 1
        prompt.MaxActivationDistance = 20
    end
end
function tryHoldPrompt(prompt, duration)
    if not prompt or prompt:GetAttribute("__AutoFinishBusy") then return end
    prompt:SetAttribute("__AutoFinishBusy", true)
    pcall(function() if prompt.InputHoldBegin then prompt:InputHoldBegin() end end)
    pcall(function() if prompt.HoldBegin then prompt:HoldBegin() end end)
    pcall(function() if prompt.Trigger then prompt:Trigger() end end)
    task.wait(duration)
    pcall(function() if prompt.InputHoldEnd then prompt:InputHoldEnd() end end)
    pcall(function() if prompt.HoldEnd then prompt:HoldEnd() end end)
    prompt:SetAttribute("__AutoFinishBusy", nil)
end
function findFinishPrompts()
    local found = {}
    for _, char in pairs(workspace:GetChildren()) do
        local player = Players:GetPlayerFromCharacter(char)
        if player and not isPlayerExcluded(player.Name) then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local prompt = hrp:FindFirstChild("FinishPrompt")
                if prompt then
                    setFinishPrompt(prompt)
                    table.insert(found, prompt)
                end
            end
        end
    end
    return found
end
function applyToAll()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Z.LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local prompt = hrp:FindFirstChild("FinishPrompt")
                if prompt then setFinishPrompt(prompt) end
            end
        end
    end
end
function setupFastFinishForPlayer(p)
    if p ~= Z.LocalPlayer then
        p.CharacterAdded:Connect(function(char)
            char.DescendantAdded:Connect(function(desc)
                if Z.fastFinishEnabled and desc.Name == "FinishPrompt" and desc:IsA("ProximityPrompt") and desc.Parent and desc.Parent.Name == "HumanoidRootPart" then
                    setFinishPrompt(desc)
                end
            end)
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if hrp and Z.fastFinishEnabled then
                local prompt = hrp:FindFirstChild("FinishPrompt")
                if prompt then setFinishPrompt(prompt) end
            end
        end)
        if p.Character then
            local char = p.Character
            char.DescendantAdded:Connect(function(desc)
                if Z.fastFinishEnabled and desc.Name == "FinishPrompt" and desc:IsA("ProximityPrompt") and desc.Parent and desc.Parent.Name == "HumanoidRootPart" then
                    setFinishPrompt(desc)
                end
            end)
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and Z.fastFinishEnabled then
                local prompt = hrp:FindFirstChild("FinishPrompt")
                if prompt then setFinishPrompt(prompt) end
            end
        end
    end
end
function getPlayer(name)
    name = string.lower(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), name) or string.find(string.lower(p.DisplayName), name) then
            return p
        end
    end
end
function ForcePart(v)
    if v:IsA("BasePart") and not v.Anchored and not v.Parent:FindFirstChildOfClass("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then
        for _, obj in ipairs(v:GetChildren()) do
            if obj:IsA("BodyMover") or obj:IsA("RocketPropulsion") then obj:Destroy() end
        end
        for _, junk in ipairs({"Attachment", "AlignPosition", "Torque"}) do
            local f = v:FindFirstChild(junk)
            if f then f:Destroy() end
        end
        v.CanCollide = false
        local Torque = Instance.new("Torque", v)
        local AlignPosition = Instance.new("AlignPosition", v)
        local Attachment2 = Instance.new("Attachment", v)
        Torque.Torque = Vector3.new(100000,100000,100000)
        Torque.Attachment0 = Attachment2
        AlignPosition.MaxForce = math.huge
        AlignPosition.MaxVelocity = math.huge
        AlignPosition.Responsiveness = 9999
        AlignPosition.Attachment0 = Attachment2
        AlignPosition.Attachment1 = Z.Attachment1
    end
end
function ToggleBring(name)
    local player = getPlayer(name)
    if not player then return end
    Z.Active = not Z.Active
    if Z.Active then
        local char = player.Character or player.CharacterAdded:Wait()
        local targetRoot = char:WaitForChild("HumanoidRootPart")
        for _, v in ipairs(Workspace:GetDescendants()) do ForcePart(v) end
        Z.BringConnection = Workspace.DescendantAdded:Connect(ForcePart)
        task.spawn(function()
            while Z.Active do
                if Z.Attachment1 then Z.Attachment1.WorldCFrame = targetRoot.CFrame end
                task.wait()
            end
        end)
    else
        if Z.BringConnection then Z.BringConnection:Disconnect() end
    end
end

function TrySkipCrate()
    local success, CrateController = pcall(function() return require(ReplicatedStorage.Modules.Game.CrateSystem.Crate) end)
    if not (success and CrateController) then return end
    task.spawn(function()
        local spinning = CrateController.spinning
        if not spinning then return end
        local waited = 0
        while not spinning.get() do
            if waited > 3 then break end
            task.wait(0.05)
            waited = waited + 0.05
        end
        if spinning.get() then pcall(function() CrateController.skip_spin() end) end
    end)
end

function SetupAutoSkip()
    local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 5)
    if not remotesFolder then return end
    local sendRemote = remotesFolder:WaitForChild("Send", 5)
    if not (sendRemote and sendRemote:IsA("RemoteEvent")) then return end
    sendRemote.OnClientEvent:Connect(function(...)
        if Z.AutoSkipEnabled then TrySkipCrate() end
    end)
end

function createESP(player)
    if Z.espPlayers[player] then return end
    local nameText = Drawing.new("Text")
    nameText.Size = 16
    nameText.Center = true
    nameText.Outline = true
    nameText.Color = isPlayerExcluded(player.Name) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
    nameText.Font = 4
    local distanceText = Drawing.new("Text")
    distanceText.Size = 14
    distanceText.Center = true
    distanceText.Outline = true
    distanceText.Color = Color3.fromRGB(255,255,255)
    distanceText.Font = 4
    local healthBg = Drawing.new("Square")
    healthBg.Filled = false
    healthBg.Thickness = 1
    healthBg.Color = Color3.fromRGB(0,0,0)
    healthBg.Transparency = 0.9
    healthBg.Visible = false
    local healthFg = Drawing.new("Square")
    healthFg.Filled = true
    healthFg.Transparency = 0.9
    healthFg.Visible = false
    local drawings = {nameText, distanceText, healthBg, healthFg}
    local conn = RunService.RenderStepped:Connect(function()
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(drawings) do obj.Visible = false end
            return
        end
        local hrp = player.Character.HumanoidRootPart
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local dist = 0
        if Z.LocalPlayer.Character and Z.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            dist = (hrp.Position - Z.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        end
        local screenPos, onScreen = Z.Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen or screenPos.Z <= 0 then
            for _, obj in pairs(drawings) do obj.Visible = false end
            return
        end
        local centerX = screenPos.X
        local currentTopY = screenPos.Y - 15
        if Z.healthESPEnabled and humanoid and humanoid.Health > 0 then
            local perc = humanoid.Health / (humanoid.MaxHealth > 0 and humanoid.MaxHealth or 1)
            local barHeight = 4
            local barWidth = 60
            local healthX = centerX - barWidth / 2
            healthBg.Position = Vector2.new(healthX, currentTopY - barHeight - 2)
            healthBg.Size = Vector2.new(barWidth, barHeight)
            healthBg.Visible = true
            healthFg.Position = Vector2.new(healthX, currentTopY - barHeight - 2)
            healthFg.Size = Vector2.new(barWidth * perc, barHeight)
            healthFg.Color = Color3.fromHSV(perc * 0.333, 0.8, 0.9)
            healthFg.Visible = true
            currentTopY = currentTopY - barHeight - 6
        else
            healthBg.Visible = false
            healthFg.Visible = false
        end
        if Z.nameESPEnabled then
            local minSize, maxSize = 14, 42
            local scaleDist = math.clamp(dist / 50, 0, 1)
            local dynamicSize = maxSize - (maxSize - minSize) * scaleDist
            nameText.Text = player.Name
            nameText.Size = math.floor(dynamicSize)
            nameText.Color = isPlayerExcluded(player.Name) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
            nameText.Outline = true
            nameText.Position = Vector2.new(centerX, currentTopY - 16)
            nameText.Visible = true
        else
            nameText.Visible = false
        end
        distanceText.Text = Z.distanceESPEnabled and string.format("%.0f studs", dist) or ""
        distanceText.Position = Vector2.new(centerX, screenPos.Y + 20)
        distanceText.Visible = Z.distanceESPEnabled
    end)
    Z.espPlayers[player] = {conn = conn, drawings = drawings}
end

function loadESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Z.LocalPlayer and not Z.espPlayers[player] then createESP(player) end
    end
    Players.PlayerAdded:Connect(function(player)
        if player ~= Z.LocalPlayer then
            player.CharacterAdded:Connect(function()
                task.wait(0.1)
                if not Z.espPlayers[player] then createESP(player) end
            end)
            if player.Character and not Z.espPlayers[player] then
                task.wait(0.1); createESP(player)
            end
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        if Z.espPlayers[player] then
            for _, obj in pairs(Z.espPlayers[player].drawings) do
                if obj and obj.Destroy then pcall(function() obj:Destroy() end)
                elseif typeof(obj) == "table" and obj.Visible ~= nil then obj.Visible = false end
            end
            if Z.espPlayers[player].conn then pcall(function() Z.espPlayers[player].conn:Disconnect() end) end
            Z.espPlayers[player] = nil
        end
    end)
end

-- ตั้งค่าเริ่มต้นของตัวแปรที่ใช้บ่อย (global)
Z.RARITY_COLORS = {
    Common = Color3.fromRGB(255,255,255),
    Uncommon = Color3.fromRGB(99,255,52),
    Rare = Color3.fromRGB(51,170,255),
    Epic = Color3.fromRGB(237,44,255),
    Legendary = Color3.fromRGB(255,150,0),
    Omega = Color3.fromRGB(255,20,51)
}
Z.SilentAimEnabled = false
Z.SilentAimAttachEnabled = false
Z.FOVRadius = 120
Z.CurrentTarget = nil
Z.SilentFOVCircle = nil
Z.Tracer = Drawing.new("Line")
Z.Tracer.Thickness = 1
Z.Tracer.Color = Color3.fromRGB(255,50,50)
Z.Tracer.Transparency = 1
Z.Tracer.Visible = false
Z.nameESPEnabled = false
Z.distanceESPEnabled = false
Z.healthESPEnabled = false
Z.excludedPlayerNames = {}
Z.walkSpeedEnabled = false
Z.speedValue = 0.05
Z.FlyEnabled = false
Z.isFlyingUp = false
Z.floatPower = 40
Z.teleportActive = false
Z.featureEnabled = false
Z.lockedY = nil
Z.maxHeight = 10
Z.startY = nil
Z.moveConnection = nil
Z.flyJumpConnection = nil
Z.hookEnabled = false
Z.clickCount = 0
Z.fastFinishEnabled = false
Z.Active = false
Z.BringConnection = nil
Z.holdTime = 1
Z.scanInterval = 0.4
Z.flickering = false
Z.undergroundBaseCFrame = nil
getgenv().Sky = false
getgenv().SkyAmount = 1500
Z.AutoSkipEnabled = false
Z.sucking = false
Z.lastPickupTimes = {}
Z.DROP_DEPTH = -55
Z.MOVE_RADIUS = 30
Z.FLICKER_RATE = 0.1
Z.AutoRespawnEnabled = false
Z.scanRadius = 20
Z.localEventCounter = 0
Z.localFuncCounter = 0
Z.AutoSprintEnabled = false
Z.ESPEnabled = false
Z.ESPConnection = nil
Z.FistsBuffEnabled = false
Z.OriginalValues = {}
Z.BOX_SIZE_SCALE = 100
Z.highlightEnabled = false
Z.Remote = nil
pcall(function() Z.Remote = ReplicatedStorage:WaitForChild("Remotes",5):WaitForChild("Send",5) end)
Z.WindUI = nil
pcall(function() Z.WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))() end)
Z.Window = nil
if Z.WindUI then
    Z.Window = Z.WindUI:CreateWindow({
        Title = "ZENITH HUB  |  Block Spin 🔫| FREE💸",
        Icon = "list",
        Author = "HI! I'M KUNGHE I'M COOL :)",
        Folder = "MYSTIC HUB Now!!!",
        Size = UDim2.fromOffset(650,400),
        Theme = "Dark",
        Transparent = true,
        Resizable = true,
        KeyCode = Enum.KeyCode.G
    })
    Z.Window:Tag({ Title = "v5.6", Color = Color3.fromHex("#30ff6a"), Radius = 12 })
else
    Z.Window = { Tab = function(_) return { Section = function() end, Toggle = function() end, Slider = function() end, Button = function() end, Input = function() return {} end, Divider = function() end } end }
end

Z.ConfigManager = Z.Window.ConfigManager
Z.myConfig = Z.ConfigManager:CreateConfig("CathubConfig")

-- ตั้งค่า UI สำหรับมือถือ
if not Z.isMobile then
    Z.SilentFOVCircle = Drawing.new("Circle")
    Z.SilentFOVCircle.Thickness = 1.4
    Z.SilentFOVCircle.NumSides = 64
    Z.SilentFOVCircle.Filled = false
    Z.SilentFOVCircle.Transparency = 0.6
    Z.SilentFOVCircle.Radius = Z.FOVRadius
    Z.SilentFOVCircle.Visible = false
else
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MobileFOV"
    ScreenGui.Parent = Z.LocalPlayer:WaitForChild("PlayerGui")
    Z.SilentFOVCircle = Instance.new("Frame")
    Z.SilentFOVCircle.Size = UDim2.fromOffset(Z.FOVRadius*2, Z.FOVRadius*2)
    Z.SilentFOVCircle.AnchorPoint = Vector2.new(0.5,0.5)
    Z.SilentFOVCircle.Position = UDim2.fromScale(0.5,0.5)
    Z.SilentFOVCircle.BackgroundTransparency = 1
    local circleUI = Instance.new("UICorner")
    circleUI.CornerRadius = UDim.new(1,0)
    circleUI.Parent = Z.SilentFOVCircle
    local border = Instance.new("UIStroke")
    border.Thickness = 2
    border.Transparency = 0.2
    border.Parent = Z.SilentFOVCircle
    Z.SilentFOVCircle.Parent = ScreenGui
end

Z.HISTORY_SIZE = 6
Z.PREDICT_FACTOR = 1.2
Z.SKY_Y_THRESHOLD = 150
Z.SMOOTH_ALPHA = 0.75

-- velocity calculation
function Z.calculateVelocity(player)
    local hist = Z.PositionHistory[player]
    if not hist or #hist < 2 then return Vector3.new() end
    local totalVel = Vector3.new()
    local count = 0
    for i = 2, #hist do
        local dt = hist[i].time - hist[i-1].time
        if dt > 0 then
            totalVel = totalVel + (hist[i].pos - hist[i-1].pos) / dt
            count = count + 1
        end
    end
    if count == 0 then return Vector3.new() end
    local avgVel = totalVel / count
    if avgVel.Y > Z.SKY_Y_THRESHOLD then
        return Vector3.new(avgVel.X * 1.15, math.clamp(avgVel.Y * 0.85, 0, 400), avgVel.Z * 1.15)
    end
    return avgVel
end

-- ตั้ง heartbeats และ connections
RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Z.LocalPlayer and player.Character then
            local character = player.Character
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
            if hrp and humanoid and humanoid.Health > 0 then
                Z.PositionHistory[player] = Z.PositionHistory[player] or {}
                table.insert(Z.PositionHistory[player], {time = os.clock(), pos = hrp.Position})
                if #Z.PositionHistory[player] > Z.HISTORY_SIZE then table.remove(Z.PositionHistory[player],1) end
            else
                Z.PositionHistory[player] = nil
            end
        end
    end
end)
Players.PlayerRemoving:Connect(function(player) Z.PositionHistory[player] = nil end)

-- hook silent aim
if Z.Remote and Z.Remote.FireServer then
    local ok, res = pcall(function()
        Z.oldFire = hookfunction(Z.Remote.FireServer, function(self, ...)
            if self ~= Z.Remote then return Z.oldFire(self, ...) end
            local args = {...}
            if Z.SilentAimEnabled and args[2] == "shoot_gun" and Z.CurrentTarget then
                local head = Z.CurrentTarget.Character and Z.CurrentTarget.Character:FindFirstChild("Head")
                local hrp = Z.CurrentTarget.Character and Z.CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = Z.CurrentTarget.Character and Z.CurrentTarget.Character:FindFirstChild("Humanoid")
                if head and hrp and humanoid then
                    local aimPos = predictPosition(head, hrp)
                    local myHead = Z.LocalPlayer.Character and Z.LocalPlayer.Character:FindFirstChild("Head")
                    local myPos = myHead and myHead.Position or nil
                    local function isShotgun()
                        if not Z.Character then return false end
                        for _, tool in ipairs(Z.Character:GetChildren()) do
                            if tool:IsA("Tool") then
                                local ammoType = tool:GetAttribute("AmmoType")
                                if ammoType == "shotgun" or ammoType == "shootgun" then return true end
                            end
                        end
                        return false
                    end
                    if isShotgun() then
                        args[4] = CFrame.new(myPos, aimPos)
                        local pellets = {}
                        for i = 1, 6 do
                            local spread = Vector3.new(math.random(-2,2)*0.03, math.random(-2,2)*0.03, math.random(-2,2)*0.03)
                            table.insert(pellets, { [1] = { Instance = head, Normal = Vector3.new(0,1,0), Position = aimPos + spread } })
                        end
                        args[5] = pellets
                    else
                        local blocked = isBehindWall(myPos, aimPos)
                        if blocked then args[4] = CFrame.new(math.huge, math.huge, math.huge)
                        else args[4] = CFrame.new(myPos, aimPos) end
                        args[5] = { [1] = { [1] = { Instance = head, Normal = Vector3.new(0,1,0), Position = aimPos } } }
                    end
                    local success, beam = pcall(function()
                        local part = Instance.new("Part")
                        part.Anchored = true
                        part.CanCollide = false
                        part.Size = Vector3.new(0.08,0.08, (aimPos - Z.LocalPlayer.Character.Head.Position).Magnitude)
                        part.CFrame = CFrame.new(Z.LocalPlayer.Character.Head.Position, aimPos) * CFrame.new(0,0,-part.Size.Z/2)
                        part.Material = Enum.Material.Neon
                        part.Transparency = 0.35
                        part.Color = Color3.fromRGB(255,0,0)
                        part.Parent = workspace
                        Debris:AddItem(part,4)
                        return part
                    end)
                    if humanoid then
                        local previousHealth = humanoid.Health
                        spawn(function()
                            wait(0.1)
                            if humanoid and humanoid.Health < previousHealth then
                                if success and beam then beam.Color = Color3.fromRGB(0,255,0) end
                                for _, part in ipairs(Z.CurrentTarget.Character:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        local box = Instance.new("Part")
                                        box.Size = part.Size + Vector3.new(0.05,0.05,0.05)
                                        box.CFrame = part.CFrame
                                        box.Anchored = true
                                        box.CanCollide = false
                                        box.Material = Enum.Material.Neon
                                        box.Color = Color3.fromRGB(255,0,0)
                                        box.Transparency = 0.5
                                        box.Parent = Workspace
                                        local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear)
                                        TweenService:Create(box, tweenInfo, {Transparency = 1}):Play()
                                        Debris:AddItem(box,2)
                                    end
                                end
                                if head then
                                    local blood = Instance.new("Part")
                                    blood.Size = Vector3.new(0.2,0.2,0.2)
                                    blood.Shape = Enum.PartType.Ball
                                    blood.Material = Enum.Material.Neon
                                    blood.Color = Color3.fromRGB(255,0,0)
                                    blood.CFrame = CFrame.new(head.Position)
                                    blood.Anchored = false
                                    blood.CanCollide = false
                                    blood.Parent = Workspace
                                    local bv = Instance.new("BodyVelocity")
                                    bv.Velocity = Vector3.new(math.random(-5,5), math.random(5,10), math.random(-5,5))
                                    bv.P = 5000
                                    bv.MaxForce = Vector3.new(4000,4000,4000)
                                    bv.Parent = blood
                                    Debris:AddItem(blood,1)
                                end
                            else
                                if success and beam then beam.Color = Color3.fromRGB(255,0,0) end
                            end
                        end)
                    end
                end
            end
            return Z.oldFire(self, unpack(args))
        end)
    end)
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        if Z.SilentAimAttachEnabled then Z.CurrentTarget = getClosestTarget() end
        Z.CurrentTarget = (Z.SilentAimEnabled or Z.SilentAimAttachEnabled) and getClosestTarget() or nil
        local TracerTarget = getClosestTarget()
        if Z.SilentFOVCircle then
            Z.SilentFOVCircle.Visible = Z.SilentAimEnabled
            if Z.SilentAimEnabled then
                if Z.isMobile then
                    Z.SilentFOVCircle.Position = UDim2.fromScale(0.5,0.5)
                    Z.SilentFOVCircle.Size = UDim2.fromOffset(Z.FOVRadius*2, Z.FOVRadius*2)
                    local border = Z.SilentFOVCircle:FindFirstChildWhichIsA("UIStroke")
                    if border then border.Color = Color3.fromHSV((tick()*0.3)%1,1,1) end
                else
                    Z.SilentFOVCircle.Position = Vector2.new(Z.Camera.ViewportSize.X/2, Z.Camera.ViewportSize.Y/2)
                    Z.SilentFOVCircle.Radius = Z.FOVRadius
                    Z.SilentFOVCircle.Color = Color3.fromHSV((tick()*0.3)%1,1,1)
                end
            end
        end
        if TracerTarget and TracerTarget.Character then
            local character = TracerTarget.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local targetPart = (Z.SelectedAimPart == "HumanoidRootPart") and character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
            if humanoid and humanoid.Health > 0 and targetPart then
                local centerScreenPos = Vector2.new(Z.Camera.ViewportSize.X/2, Z.Camera.ViewportSize.Y/2)
                local newPos = targetPart.Position
                Z.TracerSmoothedPos = Z.TracerSmoothedPos:Lerp(newPos, Z.SMOOTH_ALPHA)
                local targetPos = Z.TracerSmoothedPos
                local targetScreenPos, targetOnScreen = Z.Camera:WorldToViewportPoint(targetPos)
                if targetOnScreen then
                    Z.Tracer.Visible = true
                    Z.Tracer.From = centerScreenPos
                    Z.Tracer.To = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
                    Z.Tracer.Color = Color3.fromRGB(255,50,50)
                    Z.Tracer.Thickness = 1.3
                    if not Z.TracerESP then
                        Z.TracerESP = {}
                        for i=1,4 do
                            Z.TracerESP[i] = Drawing.new("Line")
                            Z.TracerESP[i].Color = Color3.fromRGB(255,255,255)
                            Z.TracerESP[i].Thickness = 1.2
                            Z.TracerESP[i].Visible = true
                        end
                    end
                    local headTopPos = Z.Camera:WorldToViewportPoint(targetPart.Position + Vector3.new(0,0.5,0))
                    local headBottomPos = Z.Camera:WorldToViewportPoint(targetPart.Position - Vector3.new(0,0.5,0))
                    local center = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
                    local sizeY = (headTopPos - headBottomPos).Magnitude / 2
                    local sizeX = sizeY
                    local minSize, maxSize = 8, 25
                    sizeX = math.clamp(sizeX, minSize, maxSize)
                    sizeY = math.clamp(sizeY, minSize, maxSize)
                    local top = Vector2.new(center.X, center.Y - sizeY)
                    local bottom = Vector2.new(center.X, center.Y + sizeY)
                    local left = Vector2.new(center.X - sizeX, center.Y)
                    local right = Vector2.new(center.X + sizeX, center.Y)
                    Z.TracerESP[1].From, Z.TracerESP[1].To = top, right
                    Z.TracerESP[2].From, Z.TracerESP[2].To = right, bottom
                    Z.TracerESP[3].From, Z.TracerESP[3].To = bottom, left
                    Z.TracerESP[4].From, Z.TracerESP[4].To = left, top
                    for i=1,4 do Z.TracerESP[i].Visible = true end
                else
                    Z.Tracer.Visible = false
                    if Z.TracerESP then for i=1,4 do Z.TracerESP[i].Visible = false end end
                end
            else
                Z.Tracer.Visible = false
                if Z.TracerESP then for i=1,4 do Z.TracerESP[i].Visible = false end end
                Z.TracerSmoothedPos = Vector3.new()
            end
        else
            Z.Tracer.Visible = false
            if Z.TracerESP then for i=1,4 do Z.TracerESP[i].Visible = false end end
            Z.TracerSmoothedPos = Vector3.new()
        end
        if Z.FlyEnabled and Z.isFlyingUp and Z.HumanoidRootPart then
            local v = Z.HumanoidRootPart.Velocity
            Z.HumanoidRootPart.Velocity = Vector3.new(v.X, Z.floatPower, v.Z)
        end
        if Z.teleportActive and Z.lockedY and Z.HumanoidRootPart then
            local currentPos = Z.HumanoidRootPart.Position
            if math.abs(currentPos.Y - Z.lockedY) > 0.1 then
                Z.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, Z.lockedY, currentPos.Z)
            end
        end
    end)
end)

Z.LocalPlayer.CharacterAdded:Connect(function(newChar) Z.Character = newChar end)
RunService.Heartbeat:Connect(function()
    if getgenv().Sky and Z.LocalPlayer.Character and Z.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local Root = Z.LocalPlayer.Character.HumanoidRootPart
        local originalVel = Root.Velocity
        local angle = math.rad(tick() * 1500 % 360)
        local x = math.cos(angle) * getgenv().SkyAmount
        local z = math.sin(angle) * getgenv().SkyAmount
        local yVel = math.random(280,480)
        Root.Velocity = Vector3.new(x, yVel, z)
        RunService.RenderStepped:Wait()
        Root.Velocity = originalVel
    end
end)
RunService.Heartbeat:Connect(function()
    if not Z.enabled then return end
    if isDowned() then
        local hrp = getHRP()
        if hrp and not Z.undergroundBaseCFrame then teleportUnderground() end
        flickerAndMove()
    else
        if Z.undergroundBaseCFrame then
            local hrp = getHRP()
            if hrp then hrp.CFrame = Z.undergroundBaseCFrame + Vector3.new(0, -Z.DROP_DEPTH, 0) end
        end
        Z.undergroundBaseCFrame = nil
        Z.flickering = false
    end
end)
RunService.Heartbeat:Connect(function()
    if not Z.LocalPlayer.Character or not Z.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Z.Character = Z.LocalPlayer.Character or Z.LocalPlayer.CharacterAdded:Wait()
        Z.HumanoidRootPart = Z.Character:WaitForChild("HumanoidRootPart")
    end
    pcall(CheckAndPickup)
end)

ContextActionService:BindAction("FlyUp", function(actionName, inputState, inputObject)
    if not Z.FlyEnabled then return Enum.ContextActionResult.Pass end
    local isJumpPressed = false
    if inputObject.UserInputType == Enum.UserInputType.Keyboard and inputObject.KeyCode == Enum.KeyCode.Space then isJumpPressed = true end
    if inputObject.UserInputType == Enum.UserInputType.Touch then isJumpPressed = true end
    if isJumpPressed then
        if inputState == Enum.UserInputState.Begin then
            Z.isFlyingUp = true
            Z.Humanoid.Jump = true
            return Enum.ContextActionResult.Sink
        elseif inputState == Enum.UserInputState.End then
            Z.isFlyingUp = false
            return Enum.ContextActionResult.Sink
        end
    end
    return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.Space)

RunService.RenderStepped:Connect(function(deltaTime)
    if Z.FlyEnabled and Z.isFlyingUp then
        Z.HumanoidRootPart.Velocity = Vector3.new(Z.HumanoidRootPart.Velocity.X, Z.floatPower, Z.HumanoidRootPart.Velocity.Z)
    end
end)
Z.LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if Z.flyJumpConnection then Z.flyJumpConnection:Disconnect() end
    Z.flyJumpConnection = hum:GetPropertyChangedSignal("Jumping"):Connect(function()
        if Z.FlyEnabled and hum.Jumping then Z.isFlyingUp = true else Z.isFlyingUp = false end
    end)
end)

Z.LocalPlayer.CharacterAdded:Connect(setupCharacter)
if Z.LocalPlayer.Character then setupCharacter(Z.LocalPlayer.Character) end
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G and Z.WindUI and Z.Window then
        if Z.Window.Toggle then Z.Window:Toggle()
        elseif Z.Window.SetVisible then Z.Window:SetVisible(not Z.Window.Visible) end
    end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Z and Z.featureEnabled then toggleTeleport() end
end)
Z.LocalPlayer.CharacterAdded:Connect(function(newChar)
    Z.Character = newChar
    Z.HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    Z.lockedY = nil
    Z.teleportActive = false
    lockYPosition()
end)
lockYPosition()
Z.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    Z.running = false
    task.wait(0.1)
    StartAutoAttack()
end)
StartAutoAttack()
for _, category in ipairs({"gun", "melee", "throwable", "consumable", "farming", "misc", "rod", "fish"}) do
    registerItems(ReplicatedStorage:WaitForChild("Items")[category])
end
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if Z.ESPEnabled then wait(0.2); createBillboardForPlayer(player) end
    end)
end)
Players.PlayerRemoving:Connect(function(player)
    if Z.BillboardCache[player] then Z.BillboardCache[player]:Destroy(); Z.BillboardCache[player] = nil end
end)
for _, p in ipairs(Players:GetPlayers()) do setupFastFinishForPlayer(p) end
Players.PlayerAdded:Connect(setupFastFinishForPlayer)
task.spawn(function()
    while true do
        task.wait(Z.scanInterval or 0.4)
        if Z.fastFinishEnabled then
            for _, prompt in ipairs(findFinishPrompts()) do
                task.spawn(function() tryHoldPrompt(prompt, Z.holdTime or 1) end)
            end
        end
    end
end)
SetupAutoSkip()
ReplicatedStorage.ChildAdded:Connect(function(child) if child.Name == "Remotes" then SetupAutoSkip() end end)
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if Z.highlightEnabled then updateHighlight(player) end
        if Z.espPlayers[player] and Z.espPlayers[player].drawings then
            local nameText = Z.espPlayers[player].drawings[1]
            nameText.Color = isPlayerExcluded(player.Name) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
        end
    end)
end)
Players.PlayerRemoving:Connect(function(player)
    if Z.espPlayers[player] then
        for _, obj in pairs(Z.espPlayers[player].drawings) do
            if obj and obj.Destroy then pcall(function() obj:Destroy() end)
            elseif typeof(obj) == "table" and obj.Visible ~= nil then obj.Visible = false end
        end
        if Z.espPlayers[player].conn then pcall(function() Z.espPlayers[player].conn:Disconnect() end) end
        Z.espPlayers[player] = nil
    end
end)
task.spawn(function()
    while task.wait(1) do
        if Z.highlightEnabled then
            for _, player in pairs(Players:GetPlayers()) do updateHighlight(player) end
        end
    end
end)
loadESP()

-- ฟังก์ชัน updateHighlight (ต้องประกาศก่อนใช้)
function updateHighlight(player)
    if player == Z.LocalPlayer then return end
    if not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if Z.playerHighlights[player] then Z.playerHighlights[player]:Destroy(); Z.playerHighlights[player] = nil end
    if Z.highlightEnabled then
        local highlight = Instance.new("Highlight")
        highlight.Name = "PlayerHighlight"
        highlight.Adornee = player.Character
        highlight.FillColor = Color3.fromRGB(0,170,255)
        highlight.OutlineColor = Color3.fromRGB(0,170,255)
        highlight.Parent = workspace
        Z.playerHighlights[player] = highlight
    end
end

-- สร้าง GUI tabs (ต้องทำหลังจาก Z.Window พร้อม)
local Tab = Z.Window:Tab({Title = "COMBAT:", Icon = "crosshair"})
Tab:Section({Title = "GUN:"})
local SilentToggle = Tab:Toggle({ Title = "Silent Aim", Default = false, Callback = function(state) Z.SilentAimEnabled = state; Z.CurrentTarget = nil end })
Z.myConfig:Register("SilentAim", SilentToggle)
local AttachToggle = Tab:Toggle({ Title = "Red Line Lock", Default = false, Callback = function(state) Z.SilentAimAttachEnabled = state; Z.CurrentTarget = nil end })
Z.myConfig:Register("SilentAimAttach", AttachToggle)
local FOVSlider = Tab:Slider({ Title = "FOV: ", Step = 1, Value = { Min = 20, Max = 800, Default = Z.FOVRadius }, Callback = function(value) Z.FOVRadius = tonumber(value) or 120 end })
Z.myConfig:Register("FOVRadius", FOVSlider)
local FriendsInput = Tab:Input({ Title = "Safe Friend", Desc = "", Value = "", InputIcon = "shield-check", Type = "Input", Placeholder = "", Callback = function(input)
    Z.excludedPlayerNames = {}
    for name in string.gmatch(input, "%S+") do table.insert(Z.excludedPlayerNames, name) end
    for _, player in pairs(Players:GetPlayers()) do
        if Z.espPlayers[player] and Z.espPlayers[player].drawings then
            local nameText = Z.espPlayers[player].drawings[1]
            nameText.Color = isPlayerExcluded(player.Name) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
        end
    end
end })
Z.myConfig:Register("FriendsList", FriendsInput)

local Tab_mods = Z.Window:Tab({Title = "WEAPON:", Icon = "layers"})
Tab_mods:Section({Title = "MODS:"})
local GunsFolder = ReplicatedStorage:WaitForChild("Items"):WaitForChild("gun")
getgenv().FireRateValue = 1000
getgenv().AccuracyValue = 1
getgenv().RecoilValue = 0
getgenv().Durability = 999999999
getgenv().Auto = true
getgenv().automatic = true
getgenv().AutoValue = true
getgenv().GunModsAutoApply = false

local function isGunTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    return GunsFolder:FindFirstChild(tool.Name) ~= nil or tool.Name:match("Gun") or tool:FindFirstChild("Handle")
end
local function forceSetAttribute(tool, attrName, value)
    if tool and tool.SetAttribute then pcall(function() tool:SetAttribute(attrName, value) end) end
end
local function debugPrintAttributes(tool) end
local function applyGodGun(tool)
    if not tool or not isGunTool(tool) then return end
    pcall(function()
        tool:SetAttribute("fire_rate", getgenv().FireRateValue)
        tool:SetAttribute("accuracy", getgenv().AccuracyValue)
        tool:SetAttribute("Recoil", getgenv().RecoilValue)
        tool:SetAttribute("Durability", getgenv().Durability)
        tool:SetAttribute("automatic", getgenv().AutoValue)
    end)
    task.spawn(function()
        for attempt = 1, 20 do
            local attrNames = tool:GetAttributes()
            local keys = {}
            for k in pairs(attrNames) do table.insert(keys, k) end
            table.sort(keys)
            if #keys >= 11 then
                local targetKey = keys[11]
                for i = 1, 5 do forceSetAttribute(tool, targetKey, true); task.wait(0.01) end
            end
            task.wait(0.1)
        end
    end)
    task.wait(0.5)
    debugPrintAttributes(tool)
end
RunService.Heartbeat:Connect(function()
    if not getgenv().GunModsAutoApply then return end
    local char = Z.LocalPlayer.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and isGunTool(tool) then pcall(applyGodGun, tool) end
    end
end)
Z.LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    repeat
        task.wait(0.1)
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and isGunTool(tool) then task.spawn(applyGodGun, tool) end
        end
    until not getgenv().GunModsAutoApply
end)
Z.LocalPlayer.Character.ChildAdded:Connect(function(child)
    if child:IsA("Tool") and getgenv().GunModsAutoApply then task.wait(0.2); applyGodGun(child) end
end)

Tab_mods:Slider({ Title = "Fire Rate", Step = 10, Value = {Min=100, Max=3000, Default=1000}, Callback = function(v) getgenv().FireRateValue = v end })
Tab_mods:Slider({ Title = "Accuracy", Step = 0.01, Value = {Min=0, Max=1, Default=1}, Callback = function(v) getgenv().AccuracyValue = v end })
Tab_mods:Slider({ Title = "Recoil", Step = 0.1, Value = {Min=0, Max=10, Default=0}, Callback = function(v) getgenv().RecoilValue = v end })
Tab_mods:Slider({ Title = "Reload Time", Step = 0.1, Value = {Min=0.1, Max=10, Default=0.1}, Callback = function(v) getgenv().ReloadValue = v end })
Tab_mods:Toggle({ Title = "Automatic", Icon = "check", Type = "Checkbox", Value = false, Callback = function(v)
    getgenv().automatic = v
    getgenv().GunModsAutoApply = v
    if v and Z.WindUI then Z.WindUI:Notify({ Title = "✅ Auto Modify", Duration = 2 }) end
end })

Tab_mods:Section({Title = "COMBAT"})
local function modifyFists(tool, enable)
    if tool then
        local attributes = tool:GetAttributes()
        local keys = {}
        for name,_ in pairs(attributes) do table.insert(keys, name) end
        table.sort(keys)
        if #keys >= 7 then
            local attr6 = keys[6]
            local attr7 = keys[7]
            if enable then
                if Z.OriginalValues[attr6] == nil then Z.OriginalValues[attr6] = tool:GetAttribute(attr6) end
                if Z.OriginalValues[attr7] == nil then Z.OriginalValues[attr7] = tool:GetAttribute(attr7) end
                tool:SetAttribute(attr6, 360)
                tool:SetAttribute(attr7, 20)
            else
                if Z.OriginalValues[attr6] then tool:SetAttribute(attr6, Z.OriginalValues[attr6]) end
                if Z.OriginalValues[attr7] then tool:SetAttribute(attr7, Z.OriginalValues[attr7]) end
            end
        end
    end
end
local meleeNames = {}
for _, v in ipairs(MeleeFolder:GetChildren()) do table.insert(meleeNames, v.Name) end
local function isMeleeTool(tool)
    if not tool:IsA("Tool") then return false end
    if tool.Name == "Fists" then return true end
    for _, name in ipairs(meleeNames) do if tool.Name == name then return true end end
    return false
end
local function checkAndModifyFists()
    local Character = Z.LocalPlayer.Character
    local backpack = Z.LocalPlayer:FindFirstChild("Backpack")
    if not Character or not backpack then return end
    local tools = {}
    for _, t in ipairs(Character:GetChildren()) do if isMeleeTool(t) then table.insert(tools, t) end end
    for _, t in ipairs(backpack:GetChildren()) do if isMeleeTool(t) then table.insert(tools, t) end end
    for _, tool in ipairs(tools) do modifyFists(tool, Z.FistsBuffEnabled) end
end
RunService.Heartbeat:Connect(function() if Z.FistsBuffEnabled then checkAndModifyFists() end end)
Z.LocalPlayer.CharacterAdded:Connect(function() task.wait(1); if Z.FistsBuffEnabled then checkAndModifyFists() end end)
Z.myConfig:Register("Fists Modifier", Tab_mods:Toggle({ Title = "Melee Aura", Desc = "WideFists", Default = false, Callback = function(Value) Z.FistsBuffEnabled = Value; checkAndModifyFists() end }))
local autoAttackToggle = Tab_mods:Toggle({ Title = "Auto Attack", Default = false, Callback = function(state) Z.hookEnabled = state end })
Z.myConfig:Register("AutoAttack_Enabled", autoAttackToggle)

local Tab_ESP = Z.Window:Tab({Title = "ESP:", Icon = "eye"})
Tab_ESP:Section({Title = "Visual:"})
local ItemsESPToggle = Tab_ESP:Toggle({ Title = "Inventory Viewer", Default = false, Callback = function(state)
    Z.ESPEnabled = state
    if state then
        for _, p in ipairs(Players:GetPlayers()) do if p ~= Z.LocalPlayer and p.Character then createBillboardForPlayer(p) end end
        Z.ESPConnection = RunService.Heartbeat:Connect(function()
            for _, p in ipairs(Players:GetPlayers()) do if p ~= Z.LocalPlayer and p.Character then createBillboardForPlayer(p) end end
        end)
        if Z.WindUI then Z.WindUI:Notify({ Title = "✅ ESP Items Enabled", Duration = 3 }) end
    else
        if Z.ESPConnection then Z.ESPConnection:Disconnect(); Z.ESPConnection = nil end
        for _, billboard in pairs(Z.BillboardCache) do billboard:Destroy() end
        Z.BillboardCache = {}
        if Z.WindUI then Z.WindUI:Notify({ Title = "❌ ESP Items Disabled", Duration = 3 }) end
    end
end })
Z.myConfig:Register("ItemsESP", ItemsESPToggle)
local NameESPToggle = Tab_ESP:Toggle({ Title = "Name", Default = false, Callback = function(state) Z.nameESPEnabled = state end })
Z.myConfig:Register("NameESP", NameESPToggle)
local HealthESPToggle = Tab_ESP:Toggle({ Title = "Health", Default = false, Callback = function(state) Z.healthESPEnabled = state end })
Z.myConfig:Register("HealthESP", HealthESPToggle)
local DistanceESPToggle = Tab_ESP:Toggle({ Title = "Distance", Default = false, Callback = function(state) Z.distanceESPEnabled = state end })
Z.myConfig:Register("DistanceESP", DistanceESPToggle)
local HighlightToggle = Tab_ESP:Toggle({ Title = "Highlight", Default = false, Callback = function(state)
    Z.highlightEnabled = state
    for _, player in pairs(game.Players:GetPlayers()) do updateHighlight(player) end
end })
Z.myConfig:Register("HighlightESP", HighlightToggle)

local Tab_Character = Z.Window:Tab({Title = "CHARACTER:", Icon = "user"})
Tab_Character:Section({Title = "CHARACTER:"})
local WalkSpeedToggle = Tab_Character:Toggle({ Title = "Walk Speed", Default = false, Callback = function(state) Z.walkSpeedEnabled = state end })
Z.myConfig:Register("WalkSpeed", WalkSpeedToggle)
local SpeedSlider = Tab_Character:Slider({ Title = "Speed Multiplier", Step = 0.5, Value = {Min=1, Max=5, Default=2}, Callback = function(value) Z.speedValue = value * 0.05 end })
Z.myConfig:Register("SpeedMultiplier", SpeedSlider)
local JumpPowerToggle = Tab_Character:Toggle({ Title = "Jump Power (Fly)", Default = false, Callback = function(state) Z.FlyEnabled = state; if not Z.FlyEnabled then Z.isFlyingUp = false end end })
Z.myConfig:Register("JumpPower", JumpPowerToggle)
local Net = {}
function Net.send(...) local args={...}; Z.CounterTable.event = Z.CounterTable.event + 1; pcall(function() Remotes.Send:FireServer(Z.CounterTable.event, unpack(args)) end) end
local AutoSprintToggle = Tab_Character:Toggle({ Title = "Infinite Stamina", Default = false, Callback = function(state)
    Z.AutoSprintEnabled = state
    if Z.AutoSprintEnabled then
        local success, SprintModule = pcall(function() return require(ReplicatedStorage.Modules.Game.Sprint) end)
        if success and SprintModule then
            local consume_stamina = SprintModule.consume_stamina
            local SprintBar = getupvalue(consume_stamina, 2).sprint_bar
            if SprintBar then
                local Old = SprintBar.update
                SprintBar.update = function(...) return Old(function() return 1 end) end
                getgenv().OriginalSprintUpdate = Old
                getgenv().AutoSprintLoop = task.spawn(function()
                    while Z.AutoSprintEnabled do
                        pcall(function() Net.send("set_sprinting_1", true); task.wait(0.5); Net.send("set_sprinting_1", false) end)
                        task.wait(0.1)
                    end
                    pcall(function() Net.send("set_sprinting_1", false) end)
                end)
                if Z.WindUI then Z.WindUI:Notify({ Title = "✅ INF STAMINA", Duration = 3 }) end
            else Z.AutoSprintEnabled = false; AutoSprintToggle:Set(false) end
        else Z.AutoSprintEnabled = false; AutoSprintToggle:Set(false) end
    else
        if getgenv().AutoSprintLoop then task.cancel(getgenv().AutoSprintLoop); getgenv().AutoSprintLoop = nil end
        pcall(function() Net.send("set_sprinting_1", false) end)
        local success, SprintModule = pcall(function() return require(ReplicatedStorage.Modules.Game.Sprint) end)
        if success and SprintModule then
            local consume_stamina = SprintModule.consume_stamina
            local SprintBar = getupvalue(consume_stamina, 2).sprint_bar
            if SprintBar and getgenv().OriginalSprintUpdate then SprintBar.update = getgenv().OriginalSprintUpdate; getgenv().OriginalSprintUpdate = nil end
        end
        if Z.WindUI then Z.WindUI:Notify({ Title = "❌ Auto Sprint Disabled", Duration = 3 }) end
    end
end })
Z.myConfig:Register("AutoSprint", AutoSprintToggle)
local AntiLockToggle = Tab_Character:Toggle({ Title = "Anti Lock", Default = false, Callback = function(state) getgenv().Sky = state; if state then getgenv().SkyAmount = 1500 end end })
Z.myConfig:Register("AntiLock", AntiLockToggle)
local AntiKillToggle = Tab_Character:Toggle({ Title = "Anti Kill", Default = false, Callback = function(state) Z.enabled = state; if state then if Z.WindUI then Z.WindUI:Notify({ Title = " Anti Kill Enabled", Duration = 3 }) end else if Z.WindUI then Z.WindUI:Notify({ Title = "❌ Anti Kill Disabled", Duration = 3 }) end end end })
Z.myConfig:Register("AntiKill", AntiKillToggle)
local PickupToggle = Tab_Character:Toggle({ Title = "Pickup items", Default = false, Callback = function(state) Z.sucking = state end })
Z.myConfig:Register("PickupItems", PickupToggle)
local AntiRagdollToggle = Tab_Character:Toggle({ Title = "Anti Ragdoll", Default = false, Callback = function(state)
    local _AntiRagdollEnabled = state
    if not _AntiRagdollEnabled then return end
    pcall(function()
        local function findCounter() for _, obj in ipairs(getgc and getgc(true) or {}) do if typeof(obj) == "table" and rawget(obj, "event") and rawget(obj, "func") then return obj end end end
        local CounterTable = findCounter()
        if not CounterTable then return end
        local function sendRemoteAction(action) CounterTable.event = (CounterTable.event or 0) + 1; local SendRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Send"); SendRemote:FireServer(CounterTable.event, action) end
        task.spawn(function() while _AntiRagdollEnabled do sendRemoteAction("end_ragdoll_early"); task.wait(0.3); if not _AntiRagdollEnabled then break end; sendRemoteAction("clear_ragdoll"); task.wait(0.3) end end)
    end)
end })
Z.myConfig:Register("AntiRagdoll", AntiRagdollToggle)
local HideNameToggle = Tab_Character:Toggle({ Title = "Hide Name", Default = false, Callback = function(state)
    pcall(function()
        local character = Z.LocalPlayer.Character or Z.LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local gui = hrp:FindFirstChild("CharacterBillboardGui")
        if gui then local nameLabel = gui:FindFirstChild("PlayerName"); if nameLabel and nameLabel:IsA("TextLabel") then nameLabel.Visible = not state end end
    end)
end })
Z.myConfig:Register("HideName", HideNameToggle)
local AutoRespawnToggle = Tab_Character:Toggle({ Title = "Auto Respawn", Default = false, Callback = function(state)
    local _AutoRespawnEnabled = state
    if not _AutoRespawnEnabled then return end
    pcall(function()
        local function findCounter() for _, obj in ipairs(getgc and getgc(true) or {}) do if typeof(obj) == "table" and rawget(obj, "event") and rawget(obj, "func") then return obj end end end
        local CounterTable = findCounter()
        if not CounterTable then return end
        local function sendRemoteAction(action) CounterTable.event = (CounterTable.event or 0) + 1; local SendRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Send"); SendRemote:FireServer(CounterTable.event, action) end
        task.spawn(function() while _AutoRespawnEnabled do local char = Z.LocalPlayer.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); if hum and hum.Health <= 0 then task.wait(6); if _AutoRespawnEnabled then sendRemoteAction("death_screen_request_respawn") end end; task.wait(0.5) end end)
    end)
end })
Z.myConfig:Register("AutoRespawn", AutoRespawnToggle)
Tab_Character:Divider()
Tab_Character:Section({Title = "PC HOLD (Z)"})
local SnapToggle = Tab_Character:Toggle({ Title = "Snap Under Map", Default = false, Callback = function(state)
    Z.featureEnabled = state
    if Z.featureEnabled then
        Z.clickCount = (Z.clickCount or 0) + 1
        if Z.clickCount < 2 then return end
        Z.startY = Z.HumanoidRootPart and Z.HumanoidRootPart.Position.Y or nil
        Z.teleportActive = true
        performTeleport()
    else
        Z.teleportActive = false
        Z.lockedY = nil
        Z.startY = nil
    end
end })
Z.myConfig:Register("SnapUnderMap", SnapToggle)
local SnapSlider = Tab_Character:Slider({ Title = "Snap:", Step = 1, Value = {Min=1, Max=50, Default=10}, Callback = function(value)
    Z.maxHeight = value
    if Z.teleportActive and Z.HumanoidRootPart and Z.startY then
        local bottomPos = Vector3.new(Z.HumanoidRootPart.Position.X, Z.startY - Z.maxHeight, Z.HumanoidRootPart.Position.Z)
        Z.HumanoidRootPart.CFrame = CFrame.new(bottomPos)
        Z.lockedY = bottomPos.Y
    end
end })
Z.myConfig:Register("SnapHeight", SnapSlider)

local Tab_player = Z.Window:Tab({Title = "PLAYER:", Icon = "person-standing"})
Tab_player:Section({Title = "PLAYER:"})
Z.Folder = Instance.new("Folder", Workspace)
Z.CorePart = Instance.new("Part", Z.Folder)
Z.Attachment1 = Instance.new("Attachment", Z.CorePart)
Z.CorePart.Anchored = true
Z.CorePart.CanCollide = false
Z.CorePart.Transparency = 1
local AutoFinnishToggle = Tab_player:Toggle({ Title = "Auto Finnish", Default = false, Callback = function(state)
    Z.fastFinishEnabled = state
    if state then applyToAll(); if Z.WindUI then Z.WindUI:Notify({Title="✅ Auto Finish Enabled", Description="✅ Auto Enabled", Duration=3}) end
    else if Z.WindUI then Z.WindUI:Notify({Title="❌ Auto Disabled", Description="❌ Auto Disabled", Duration=3}) end end
end })
Z.myConfig:Register("AutoFinnish", AutoFinnishToggle)
Tab_player:Divider()

local Tab_buyer = Z.Window:Tab({Title = "BUY:", Icon = "landmark"})
Tab_buyer:Section({Title = "BUY:"})
local function safeToggle(title, desc, key, callback)
    pcall(function()
        local ToggleElement = Tab_buyer:Toggle({ Title = title, Desc = desc, Icon = "check", Type = "Checkbox", Default = false, Callback = function(state) Z.AutoSkipEnabled = state; if callback then callback(state) end end })
        Z.myConfig:Register(key, ToggleElement)
        Z.myConfig:Register(key.."Backup", ToggleElement)
    end)
end
safeToggle("Skip Crate Spin", "ข้ามการหมุนกล่องอัตโนมัติ", "SkipCrate", function(state) if state then TrySkipCrate() end end)

local Tab_misc = Z.Window:Tab({Title = "MISC:", Icon = "warehouse"})
Tab_misc:Section({Title = "INVISIBLE (DESYNC)"})
local InvisibleToggle = Tab_misc:Toggle({ Title = "Invisible Mode (Desync)", Desc = "เปิดโหมดล่องหน (ใช้ได้กับบาง Executor เท่านั้น)", Default = false, Callback = function(state) Z.desyncEnabled = state; Z.setDesync(state); if state then if Z.WindUI then Z.WindUI:Notify({Title="👻 Invisible Mode ON", Duration=2}) end else if Z.WindUI then Z.WindUI:Notify({Title="👤 Invisible Mode OFF", Duration=2}) end end end })
Z.myConfig:Register("InvisibleToggle", InvisibleToggle)
Tab_misc:Divider()
local placeId = game.PlaceId
local Input = Tab_misc:Input({ Title = "Server Hop by ID", Value = "", InputIcon = "send", Type = "Input", Placeholder = "id sever here!", Callback = function(input)
    if not input or input == "" then return end
    local serverIds = {}
    for id in string.gmatch(input, "[%w%-]+") do table.insert(serverIds, id) end
    if #serverIds == 0 then return end
    for _, id in ipairs(serverIds) do print("กำลังวาร์ปไปเซิร์ฟ:", id); task.wait(0.5); pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, id, Z.LocalPlayer) end) end
end })
Tab_misc:Button({ Title = "Server Rejoin", Desc = "Come back old sever", Callback = function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer) end })
local function FindServer()
    local servers = {}
    local cursor = nil
    for i=1,5 do
        local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100%s", placeId, cursor and "&cursor="..cursor or ""))) end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do if server.playing < server.maxPlayers and server.playing <= 20 then table.insert(servers, server) end end
            cursor = result.nextPageCursor
            if not cursor then break end
        end
        task.wait(0.2)
    end
    if #servers > 0 then
        table.sort(servers, function(a,b) return a.playing > b.playing end)
        local bestServer = servers[1]
        print(string.format("✅ JobId: %s | ผู้เล่น: %d/%d", bestServer.id, bestServer.playing, bestServer.maxPlayers))
        TeleportService:TeleportToPlaceInstance(placeId, bestServer.id, Players.LocalPlayer)
    else warn("❌ ไม่พบเซิร์ฟเวอร์ครับพี่") end
end
local Serverhop = Tab_misc:Button({ Title = "Server Hop", Desc = "Hop to a new server (sometime don't work)", Locked = false, Callback = function()
    local PlaceId = 104715542330896
    local success, servers = pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Desc&limit=100")) end)
    if not success or not servers or not servers.data then warn("ไม่สามารถดึงข้อมูลเซิร์ฟเวอร์ได้เลยพี่"); return end
    local availableServers = {}
    for _, server in ipairs(servers.data) do if server.playing < server.maxPlayers and server.id ~= game.JobId then table.insert(availableServers, server) end end
    if #availableServers == 0 then warn("ไม่มีเซิร์ฟเวอร์ว่างเลยพี่ขณะนี้"); return end
    table.sort(availableServers, function(a,b) return a.playing > b.playing end)
    local targetServer = availableServers[1]
    game.StarterGui:SetCore("SendNotification", { Title = "Server Hop", Text = "กำลังย้ายไปเซิร์ฟเวอร์คนเยอะ...", Duration = 3 })
    TeleportService:TeleportToPlaceInstance(PlaceId, targetServer.id, game.Players.LocalPlayer)
end })
Tab_misc:Divider()
local ClaimAllQuestButton = Tab_misc:Button({ Title = "Claim All Quest", Callback = function()
    task.spawn(function()
        local success, err = pcall(function()
            local function findCounter() for _, obj in ipairs(getgc and getgc(true) or {}) do if typeof(obj) == "table" and rawget(obj, "event") and rawget(obj, "func") then return obj end end end
            local CounterTable = findCounter() if not CounterTable then return end
            local Net = {}
            function Net.get(...) local args={...}; CounterTable.func = (CounterTable.func or 0) + 1; local GetRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Get"); return GetRemote:InvokeServer(CounterTable.func, table.unpack(args)) end
            local questFrame = Z.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Quests"):WaitForChild("QuestsHolder"):WaitForChild("QuestsScrollingFrame")
            for _, child in ipairs(questFrame:GetChildren()) do if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageButton") then Net.get("claim_quest", child.Name); task.wait(0.2) end end
        end)
        if success then print("Claim All Quests Completed") else warn(err) end
    end)
end })
Z.myConfig:Register("ClaimAllQuest", ClaimAllQuestButton)
local saveFunc = Z.myConfig["Save"]
local deleteFunc = Z.myConfig["Delete"]
local loadFunc = Z.myConfig["Load"]
Tab_misc:Section({Title = "Config Management"})
local SaveConfigButton = Tab_misc:Button({ Title = "Save Config", Callback = function() if saveFunc then saveFunc(Z.myConfig) end end })
Z.myConfig:Register("SaveConfig", SaveConfigButton)
local DeleteConfigButton = Tab_misc:Button({ Title = "Delete Config", Callback = function() if deleteFunc then deleteFunc(Z.myConfig) end end })
Z.myConfig:Register("DeleteConfig", DeleteConfigButton)
if loadFunc then loadFunc(Z.myConfig) end

-- Extra bypasses (tween, sell button, backpack lock, emotes, dropped items ESP)
local _old_tween = Util.tween
Util.tween = function(instance, tweenInfo, properties)
    if instance and instance:IsA("NumberValue") and properties and properties.Value ~= nil then
        instance.Value = properties.Value
        return { Cancel = function() end }
    end
    return _old_tween(instance, tweenInfo, properties)
end
local success, sellBtn = pcall(function() return BuyPromptUI.get("SellPromptSellButton") end)
if success and sellBtn then
    local hold = sellBtn:FindFirstChild("HoldStroke", true)
    if hold then hold.Enabled = false; local uiGrad = hold:FindFirstChildOfClass("UIGradient"); if uiGrad then uiGrad.Enabled = false end end
    for _, v in pairs(sellBtn:GetDescendants()) do if v:IsA("NumberValue") then v.Value = 1 end end
end
task.wait(2); print("Bypass")
local function lockTool(tool) if tool and tool:IsA("Tool") then pcall(function() tool:SetAttribute("Locked", true) end) end end
local function setupBackpack(backpack) if not backpack then return end; for _, tool in ipairs(backpack:GetChildren()) do lockTool(tool) end; backpack.ChildAdded:Connect(lockTool) end
local function init() local backpack = Z.LocalPlayer:FindFirstChildOfClass("Backpack"); if backpack then setupBackpack(backpack) else Z.LocalPlayer.ChildAdded:Connect(function(child) if child:IsA("Backpack") then setupBackpack(child) end end) end end
init()
Z.LocalPlayer.CharacterAdded:Connect(function() task.wait(1); init() end)
task.wait(1); print("Bypass hotbar inf")
local function hookButton(button)
    if not button then return end
    if button:FindFirstChild("UnlocksAtText") then button.UnlocksAtText.Visible = false end
    if button:FindFirstChild("EmoteName") then button.EmoteName.Visible = true end
    CoreUI.on_click(button, function()
        local hum = CharModule.get_hum()
        if not hum or hum.Health <= 0 then return end
        if EmotesUI.current_emote_playing.get() == button then EmotesUI.current_emote_playing.set(nil) else EmotesUI.current_emote_playing.set(button) end
        task.wait(0.12)
        EmotesUI.enabled.set(false)
    end)
    EmotesUI.current_emote_playing.hook(function(current) if button:FindFirstChild("EmoteEquipped") then button.EmoteEquipped.Visible = (current == button) end end)
end
local function hookAllEmotes() for index, emote in pairs(EmotesList) do local button = CoreUI.get("EmoteTemplate").Parent:FindFirstChild(emote.name); hookButton(button) end end
hookAllEmotes()
Z.LocalPlayer.CharacterAdded:Connect(function() task.wait(1); hookAllEmotes() end)
task.wait(2)
local CurrentCamera = nil; repeat task.wait() until workspace.CurrentCamera; CurrentCamera = workspace.CurrentCamera
local function getRarityColor(item)
    if item.Name == "Money" then return Color3.fromRGB(0,255,0) end
    for _, folder in ipairs(ItemsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            local tool = folder:FindFirstChild(item.Name)
            if tool and tool:GetAttribute("RarityName") then
                local rarity = tool:GetAttribute("RarityName")
                return Z.RARITY_COLORS[rarity] or Color3.fromRGB(255,255,255)
            end
        end
    end
    return Color3.fromRGB(255,255,255)
end
local function cleanupItemDrawings()
    for item, d in pairs(Z.item_drawings) do
        if not item or not item.Parent then
            if d.circle then pcall(function() d.circle:Remove() end) end
            if d.innerCircle then pcall(function() d.innerCircle:Remove() end) end
            if d.name then pcall(function() d.name:Remove() end) end
            if d.amount then pcall(function() d.amount:Remove() end) end
            if d.highlight then pcall(function() d.highlight:Destroy() end) end
            Z.item_drawings[item] = nil
        end
    end
end
RunService.RenderStepped:Connect(function()
    cleanupItemDrawings()
    if not Z.droppedItems then return end
    local hrp = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, d in pairs(Z.item_drawings) do
        d.circle.Visible = false; d.innerCircle.Visible = false; d.name.Visible = false; d.amount.Visible = false
        if d.highlight then d.highlight.Enabled = false end
    end
    local nearbyItems = {}
    for _, item in ipairs(Z.droppedItems:GetChildren()) do
        if item:IsA("Model") and item:FindFirstChild("PickUpZone") and not item:GetAttribute("Locked") then
            local success, pos = pcall(function() return item.PickUpZone.Position end)
            if success and pos then
                local dist = (pos - hrp.Position).Magnitude
                table.insert(nearbyItems, {item = item, dist = dist})
            end
        end
    end
    table.sort(nearbyItems, function(a,b) return a.dist < b.dist end)
    for i = 1, math.min(20, #nearbyItems) do
        local item = nearbyItems[i].item
        local d = Z.item_drawings[item]
        if not d then
            d = { circle = Drawing.new("Circle"), innerCircle = Drawing.new("Circle"), name = Drawing.new("Text"), amount = Drawing.new("Text") }
            d.circle.Thickness = 2; d.circle.Transparency = 0.7; d.circle.Filled = false
            d.innerCircle.Thickness = 2; d.innerCircle.Transparency = 1; d.innerCircle.Filled = true
            d.name.Outline = true; d.name.OutlineColor = Color3.fromRGB(0,0,0); d.name.Center = true; d.name.Size = 16; d.name.Font = 4
            d.amount.Outline = true; d.amount.OutlineColor = Color3.fromRGB(0,0,0); d.amount.Center = true; d.amount.Size = 13; d.amount.Color = Color3.fromRGB(200,200,200)
            Z.item_drawings[item] = d
        end
        if not d.highlight or not d.highlight.Parent then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Highlight"
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0.1
            highlight.Adornee = item
            highlight.Parent = item
            d.highlight = highlight
        end
        local rootPos, onScreen = CurrentCamera:WorldToViewportPoint(item.PickUpZone.Position)
        if onScreen then
            local color = getRarityColor(item)
            local radius = math.clamp(Z.BOX_SIZE_SCALE / rootPos.Z, 3, 6)
            if d.highlight then d.highlight.FillColor = color; d.highlight.OutlineColor = color; d.highlight.Enabled = true end
            d.circle.Position = Vector2.new(rootPos.X, rootPos.Y); d.circle.Radius = radius + 5; d.circle.Color = color; d.circle.Visible = true
            d.innerCircle.Position = Vector2.new(rootPos.X, rootPos.Y); d.innerCircle.Radius = radius; d.innerCircle.Color = color; d.innerCircle.Visible = true
            d.name.Color = color; d.name.Position = Vector2.new(rootPos.X, rootPos.Y - radius - 20); d.name.Text = item.Name; d.name.Visible = true
            local amount = item:GetAttribute("Amount") or 1
            d.amount.Position = Vector2.new(rootPos.X, rootPos.Y + radius + 15); d.amount.Text = amount > 1 and "["..tostring(amount).."]" or ""; d.amount.Visible = amount > 1
        else
            d.circle.Visible = false; d.innerCircle.Visible = false; d.name.Visible = false; d.amount.Visible = false
            if d.highlight then d.highlight.Enabled = false end
        end
    end
end)
Players.PlayerRemoving:Connect(function(plr)
    if plr == Client then
        for _, d in pairs(Z.item_drawings) do
            pcall(function() d.circle:Remove() end); pcall(function() d.innerCircle:Remove() end)
            pcall(function() d.name:Remove() end); pcall(function() d.amount:Remove() end)
            pcall(function() if d.highlight then d.highlight:Destroy() end end)
        end
        Z.item_drawings = {}
    end
end)

print("ZENITH HUB LOADED SUCCESSFULLY (Fixed UIShadow error & local register overflow)")
