local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local ContextActionService = game:GetService("ContextActionService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Util = require(ReplicatedStorage.Modules.Core.Util)
local BuyPromptUI = require(ReplicatedStorage.Modules.Game.UI.BuyPromptUI)
local EmotesUI = require(ReplicatedStorage.Modules.Game.Emotes.EmotesUI)
local EmotesList = require(ReplicatedStorage.Modules.Game.Emotes.EmotesList)
local CoreUI = require(ReplicatedStorage.Modules.Core.UI)
local CharModule = require(ReplicatedStorage.Modules.Core.Char)
local ItemsFolder = ReplicatedStorage:WaitForChild("Items")
local MeleeFolder = ItemsFolder:WaitForChild("melee")
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Send", 5)
local remoteGet = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Get")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- WindUI
local WindUI = nil
pcall(function() WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))() end)
local Window
local useFallbackGUI = false
if WindUI then
    Window = WindUI:CreateWindow({
        Title = "ZENITH HUB",
        Icon = "list",
        Author = "ZENITH TEAM",
        Folder = "ZENITH HUB",
        Size = UDim2.fromOffset(650, 400),
        Theme = "Dark",
        Transparent = true,
        Resizable = true,
        KeyCode = Enum.KeyCode.G
        KeySystem = {                                                   
        Note = " Key System.",        
        API = {                                                     
            { -- pandadevelopment
                Type = "pandadevelopment", -- type
                ServiceId = "0e57e459-b188-4aff-b991-ea4cf3766b21", -- service id
            },                                                      
        }, 
    })
    if Window then
        Window:Tag({ Title = "v3.0", Color = Color3.fromHex("#30ff6a"), Radius = 12 })
    else
        useFallbackGUI = true
    end
else
    useFallbackGUI = true
end

-- Fallback GUI (simplified, keep as original but not shown for length)
local FallbackGui = nil
local FallbackTabs = {}
if useFallbackGUI then
    -- Placeholder, assume fallback creation code exists in full script
end

local ConfigManager = Window.ConfigManager
local myConfig = ConfigManager:CreateConfig("ZenithConfig")

-- ========== UTILITIES ==========
local function getPing()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return 0.2 end
    local stats = gui:FindFirstChild("NetworkStats")
    if not stats then return 0.2 end
    local pingLabel = stats:FindFirstChild("PingLabel")
    if not pingLabel then return 0.2 end
    local text = pingLabel.Text
    if typeof(text) ~= "string" then return 0.2 end
    local num = tonumber(text:match("%d+"))
    if not num then return 0.2 end
    local ping = num / 1000
    if ping < 0 or ping > 2 then ping = 0.2 end
    return ping
end

local excludedPlayerNames = {}
local function isPlayerExcluded(playerName)
    for _, excludedName in ipairs(excludedPlayerNames) do
        if excludedName ~= "" and string.find(string.lower(playerName), string.lower(excludedName)) then
            return true
        end
    end
    return false
end

-- ========== COUNTER TABLE (dynamic find) ==========
local function findCounterTable()
    for _, obj in ipairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "event") and rawget(obj, "func") then
            return obj
        end
    end
    return nil
end

local function getCounter(isEvent)
    local ct = findCounterTable()
    if not ct then return nil end
    if isEvent then
        ct.event = (ct.event or 0) + 1
        return ct.event
    else
        ct.func = (ct.func or 0) + 1
        return ct.func
    end
end

local function fireRemote(action, ...)
    local seq = getCounter(true)
    if not seq then return false end
    local remoteSend = ReplicatedStorage.Remotes.Send
    pcall(function() remoteSend:FireServer(seq, action, ...) end)
    return true
end

local function invokeRemote(action, ...)
    local seq = getCounter(false)
    if not seq then return nil end
    local remoteGet = ReplicatedStorage.Remotes.Get
    local success, result = pcall(function() return remoteGet:InvokeServer(seq, action, ...) end)
    return success and result or nil
end

-- ========== PICKUP SYSTEM (uses _G to survive obfuscation) ==========
_G.ZenithPickup = _G.ZenithPickup or { sucking = false, lastPickupTimes = {} }

local function NetGet(...)
    local counterTable = findCounterTable()
    if not counterTable or not counterTable.func then return end
    local args = {...}
    for i, v in ipairs(args) do
        if typeof(v) == "Instance" and v:IsA("Model") and #v:GetChildren() == 0 then
            local fallback = workspace:FindFirstChild("DroppedItems")
            if fallback then
                local model = fallback:FindFirstChildWhichIsA("Model")
                if model then args[i] = model else return end
            else return end
        end
    end
    counterTable.func = (counterTable.func or 0) + 1
    local success, result = pcall(function()
        return ReplicatedStorage.Remotes.Get:InvokeServer(counterTable.func, unpack(args))
    end)
    if not success then warn("[NetGet Error]", result) end
    return result
end

local function CheckAndPickup()
    if not _G.ZenithPickup.sucking then return end
    local dropped = workspace:FindFirstChild("DroppedItems")
    if not dropped then return end
    local now = tick()
    local itemsToPickup = {}
    for _, item in ipairs(dropped:GetChildren()) do
        if item:IsA("Model") then
            local part = item:FindFirstChildWhichIsA("BasePart")
            if part then
                local dist = (HumanoidRootPart.Position - part.Position).Magnitude
                if dist <= 20 and (now - (_G.ZenithPickup.lastPickupTimes[item] or 0)) >= 0 then
                    table.insert(itemsToPickup, item)
                    _G.ZenithPickup.lastPickupTimes[item] = now
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

-- ========== OTHER VARIABLES (keep local as they don't break obf) ==========
local SilentAimEnabled = false
local SilentAimAttachEnabled = false
local FOVRadius = 120
local CurrentTarget = nil
local SelectedAimPart = "Head"
local SilentFOVCircle = nil
local Tracer = Drawing.new("Line")
Tracer.Thickness = 1
Tracer.Color = Color3.fromRGB(255, 50, 50)
Tracer.Transparency = 1
Tracer.Visible = false

-- ESP variables
local nameESPEnabled = false
local distanceESPEnabled = false
local healthESPEnabled = false
local highlightEnabled = false
local espPlayers = {}
local playerHighlights = {}

-- Walk speed, fly, etc.
local walkSpeedEnabled = false
local speedValue = 0.05
local FlyEnabled = false
local isFlyingUp = false
local floatPower = 40
local teleportActive = false
local featureEnabled = false
local lockedY = nil
local maxHeight = 10
local startY = nil
local moveConnection = nil
local flyJumpConnection = nil
local hookEnabled = false
local clickCount = 0
local fastFinishEnabled = false
local AutoSkipEnabled = false
local sucking = false -- local copy for UI, but actual state is in _G
local AutoSprintEnabled = false
local getgenv = getgenv or function() return _G end
getgenv().Sky = false
getgenv().SkyAmount = 1500
local antiDeathEnabled = false
local antiDeathLoopRunning = false
local antiDeathActive = false
local SAFE_DEPTH = 20

-- Magnet pickup additional
local magnetEnabled = false
local magnetRadius = 2000
local magnetSpeed = 0.8
local magnetConnection = nil

-- Gun mod
getgenv().FireRateValue = 1000
getgenv().AccuracyValue = 1
getgenv().RecoilValue = 0
getgenv().Durability = 999999999
getgenv().AutoValue = true
getgenv().GunModsAutoApply = false
local FistsBuffEnabled = false
local OriginalValues = {}

-- ========== SILENT AIM TARGETING & PREDICTION ==========
local HISTORY_SIZE = 6
local PREDICT_FACTOR = 1.2
local SKY_Y_THRESHOLD = 150
local PositionHistory = {}

RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if hrp and humanoid and humanoid.Health > 0 then
                PositionHistory[player] = PositionHistory[player] or {}
                table.insert(PositionHistory[player], {time = os.clock(), pos = hrp.Position})
                if #PositionHistory[player] > HISTORY_SIZE then table.remove(PositionHistory[player], 1) end
            else
                PositionHistory[player] = nil
            end
        end
    end
end)

local function calculateVelocity(player)
    local hist = PositionHistory[player]
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
    if avgVel.Y > SKY_Y_THRESHOLD then
        return Vector3.new(avgVel.X * 1.15, math.clamp(avgVel.Y * 0.85, 0, 400), avgVel.Z * 1.15)
    end
    return avgVel
end

local function predictPosition(targetPart, hrp)
    if not targetPart then return Vector3.zero end
    local character = targetPart.Parent
    local player = character and Players:GetPlayerFromCharacter(character)
    if not player then return targetPart.Position end
    local velocity = calculateVelocity(player) or Vector3.zero
    local ping = getPing()
    return targetPart.Position + (velocity * ping * PREDICT_FACTOR)
end

local function getClosestTarget()
    local closest = nil
    local shortestDistance = FOVRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local aimPart = player.Character:FindFirstChild(SelectedAimPart)
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if aimPart and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist <= FOVRadius and dist < shortestDistance and not isPlayerExcluded(player.Name) then
                        shortestDistance = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

local function isBehindWall(startPos, endPos)
    if not startPos or not endPos then return false end
    local direction = endPos - startPos
    if direction.Magnitude < 1 then return false end
    local ignoreList = {}
    if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
    if CurrentTarget and CurrentTarget.Character then table.insert(ignoreList, CurrentTarget.Character) end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = ignoreList
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(startPos, direction, params)
    return result ~= nil
end

local function isShotgun()
    if not Character then return false end
    for _, tool in ipairs(Character:GetChildren()) do
        if tool:IsA("Tool") then
            local ammoType = tool:GetAttribute("AmmoType")
            if ammoType == "shotgun" or ammoType == "shootgun" then return true end
        end
    end
    return false
end

-- Hook Remote for silent aim
local oldFire = nil
if Remote and Remote.FireServer then
    pcall(function()
        oldFire = hookfunction(Remote.FireServer, function(self, ...)
            if self ~= Remote then return oldFire(self, ...) end
            local args = {...}
            if SilentAimEnabled and args[2] == "shoot_gun" and CurrentTarget then
                local head = CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head")
                local hrp = CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Humanoid")
                if head and hrp and humanoid then
                    local aimPos = predictPosition(head, hrp)
                    local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
                    local myPos = myHead and myHead.Position or nil
                    if isShotgun() then
                        if myPos then args[4] = CFrame.new(myPos, aimPos) end
                        local pellets = {}
                        for i = 1, 6 do
                            local spread = Vector3.new(math.random(-2,2)*0.03, math.random(-2,2)*0.03, math.random(-2,2)*0.03)
                            table.insert(pellets, { [1] = { Instance = head, Normal = Vector3.new(0,1,0), Position = aimPos + spread } })
                        end
                        args[5] = pellets
                    else
                        local blocked = myPos and isBehindWall(myPos, aimPos)
                        if myPos then args[4] = blocked and CFrame.new(math.huge, math.huge, math.huge) or CFrame.new(myPos, aimPos) end
                        args[5] = { [1] = { [1] = { Instance = head, Normal = Vector3.new(0,1,0), Position = aimPos } } }
                    end
                    local success, beam = pcall(function()
                        local part = Instance.new("Part")
                        part.Anchored = true
                        part.CanCollide = false
                        part.Size = Vector3.new(0.08, 0.08, (aimPos - LocalPlayer.Character.Head.Position).Magnitude)
                        part.CFrame = CFrame.new(LocalPlayer.Character.Head.Position, aimPos) * CFrame.new(0,0,-part.Size.Z/2)
                        part.Material = Enum.Material.Neon
                        part.Transparency = 0.35
                        part.Color = Color3.fromRGB(255,0,0)
                        part.Parent = workspace
                        Debris:AddItem(part, 4)
                        return part
                    end)
                    if humanoid then
                        local previousHealth = humanoid.Health
                        spawn(function()
                            wait(0.1)
                            if humanoid and humanoid.Health < previousHealth then
                                if success and beam then beam.Color = Color3.fromRGB(0,255,0) end
                                for _, part in ipairs(CurrentTarget.Character:GetDescendants()) do
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
                                        TweenService:Create(box, TweenInfo.new(1.5), {Transparency = 1}):Play()
                                        Debris:AddItem(box, 2)
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
                                    Debris:AddItem(blood, 1)
                                end
                            else
                                if success and beam then beam.Color = Color3.fromRGB(255,0,0) end
                            end
                        end)
                    end
                end
            end
            return oldFire(self, unpack(args))
        end)
    end)
end

-- FOV Circle (Rainbow)
if not isMobile then
    SilentFOVCircle = Drawing.new("Circle")
    SilentFOVCircle.Color = Color3.fromRGB(255, 100, 100)
    SilentFOVCircle.Thickness = 1.5
    SilentFOVCircle.NumSides = 64
    SilentFOVCircle.Filled = false
    SilentFOVCircle.Transparency = 0.6
    SilentFOVCircle.Radius = FOVRadius
    SilentFOVCircle.Visible = false
else
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MobileFOV"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    SilentFOVCircle = Instance.new("Frame")
    SilentFOVCircle.Size = UDim2.fromOffset(FOVRadius * 2, FOVRadius * 2)
    SilentFOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    SilentFOVCircle.Position = UDim2.fromScale(0.5, 0.5)
    SilentFOVCircle.BackgroundTransparency = 1
    local circleUI = Instance.new("UICorner")
    circleUI.CornerRadius = UDim.new(1, 0)
    circleUI.Parent = SilentFOVCircle
    local border = Instance.new("UIStroke")
    border.Thickness = 2
    border.Transparency = 0.4
    border.Parent = SilentFOVCircle
    SilentFOVCircle.Parent = ScreenGui
end

-- RenderStepped (update FOV, fly, teleport)
RunService.RenderStepped:Connect(function()
    pcall(function()
        if SilentAimAttachEnabled then CurrentTarget = getClosestTarget() end
        CurrentTarget = (SilentAimEnabled or SilentAimAttachEnabled) and getClosestTarget() or nil
        if SilentFOVCircle then
            SilentFOVCircle.Visible = SilentAimEnabled
            if SilentAimEnabled then
                if isMobile then
                    SilentFOVCircle.Position = UDim2.fromScale(0.5, 0.5)
                    SilentFOVCircle.Size = UDim2.fromOffset(FOVRadius * 2, FOVRadius * 2)
                    local border = SilentFOVCircle:FindFirstChildWhichIsA("UIStroke")
                    if border then border.Color = Color3.fromHSV((tick() * 0.3) % 1, 1, 1) end
                else
                    SilentFOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    SilentFOVCircle.Radius = FOVRadius
                    SilentFOVCircle.Color = Color3.fromHSV((tick() * 0.3) % 1, 1, 1)
                end
            end
        end
        if FlyEnabled and isFlyingUp and HumanoidRootPart then
            HumanoidRootPart.Velocity = Vector3.new(HumanoidRootPart.Velocity.X, floatPower, HumanoidRootPart.Velocity.Z)
        end
        if teleportActive and lockedY and HumanoidRootPart then
            local currentPos = HumanoidRootPart.Position
            if math.abs(currentPos.Y - lockedY) > 0.1 then
                HumanoidRootPart.CFrame = CFrame.new(currentPos.X, lockedY, currentPos.Z)
            end
        end
    end)
end)

-- Magnet Pickup
local function startMagnet()
    if magnetConnection then magnetConnection:Disconnect() end
    magnetConnection = RunService.Heartbeat:Connect(function()
        if not magnetEnabled then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local dropped = workspace:FindFirstChild("DroppedItems")
        if not dropped then return end
        for _, item in pairs(dropped:GetChildren()) do
            local itemPos = nil
            if item:IsA("BasePart") then itemPos = item.Position else
                local part = item:FindFirstChildWhichIsA("BasePart")
                if part then itemPos = part.Position end
            end
            if not itemPos then continue end
            local dist = (hrp.Position - itemPos).Magnitude
            if dist <= magnetRadius then
                pcall(function() remoteGet:InvokeServer("pickup_dropped_item", item) end)
                if item:IsA("BasePart") then
                    item.CFrame = item.CFrame:Lerp(CFrame.new(hrp.Position), magnetSpeed)
                else
                    local part = item:FindFirstChildWhichIsA("BasePart")
                    if part then part.CFrame = part.CFrame:Lerp(CFrame.new(hrp.Position), magnetSpeed) end
                end
            end
        end
    end)
end

local function stopMagnet()
    if magnetConnection then magnetConnection:Disconnect() end
end

-- Anti kill
local function getSafePosition()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local ray = Ray.new(hrp.Position + Vector3.new(0,20,0), Vector3.new(0,-100,0))
    local hit, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
    local groundY = hit and hitPos.Y or (hrp.Position.Y - SAFE_DEPTH-10)
    return CFrame.new(hrp.Position.X, groundY + 3, hrp.Position.Z)
end

local function startAntiKill()
    if antiDeathLoopRunning then return end
    antiDeathLoopRunning = true
    antiDeathActive = true
    task.spawn(function()
        while antiDeathEnabled and antiDeathActive do
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 and hum.Health < 30 then
                local safePos = getSafePosition()
                if safePos and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = safePos
                    hum.Health = hum.MaxHealth
                    if WindUI and not useFallbackGUI then
                        WindUI:Notify({Title = "🛡️ Anti Kill", Text = "ชีวิตต่ำ! พาคุณขึ้นพื้นปลอดภัย", Duration = 2})
                    end
                end
            end
            task.wait(0.3)
        end
        antiDeathLoopRunning = false
        antiDeathActive = false
    end)
end

local function stopAntiKill()
    antiDeathEnabled = false
    antiDeathActive = false
    antiDeathLoopRunning = false
end

-- Fly bind
ContextActionService:BindAction("FlyUp", function(_, inputState, inputObject)
    if not FlyEnabled then return Enum.ContextActionResult.Pass end
    local isJumpPressed = (inputObject.UserInputType == Enum.UserInputType.Keyboard and inputObject.KeyCode == Enum.KeyCode.Space) or (inputObject.UserInputType == Enum.UserInputType.Touch)
    if isJumpPressed then
        if inputState == Enum.UserInputState.Begin then
            isFlyingUp = true
            Humanoid.Jump = true
            return Enum.ContextActionResult.Sink
        elseif inputState == Enum.UserInputState.End then
            isFlyingUp = false
            return Enum.ContextActionResult.Sink
        end
    end
    return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.Space)

-- Auto finish
local function setFinishPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 1
        prompt.MaxActivationDistance = 20
    end
end
local function tryHoldPrompt(prompt, duration)
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
local function findFinishPrompts()
    local found = {}
    for _, char in pairs(workspace:GetChildren()) do
        local player = Players:GetPlayerFromCharacter(char)
        if player and not isPlayerExcluded(player.Name) then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local prompt = hrp:FindFirstChild("FinishPrompt")
                if prompt then setFinishPrompt(prompt); table.insert(found, prompt) end
            end
        end
    end
    return found
end
local function applyToAll()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local prompt = hrp:FindFirstChild("FinishPrompt")
                if prompt then setFinishPrompt(prompt) end
            end
        end
    end
end

-- Auto skip crate
local function TrySkipCrate()
    local success, CrateController = pcall(function() return require(ReplicatedStorage.Modules.Game.CrateSystem.Crate) end)
    if not (success and CrateController) then return end
    task.spawn(function()
        local spinning = CrateController.spinning
        if not spinning then return end
        local waited = 0
        while not spinning.get() do if waited > 3 then break end task.wait(0.05); waited = waited+0.05 end
        if spinning.get() then pcall(function() CrateController.skip_spin() end) end
    end)
end

-- Setup auto skip
local function SetupAutoSkip()
    local remotesFolder = ReplicatedStorage:WaitForChild("Remotes",5)
    if not remotesFolder then return end
    local sendRemote = remotesFolder:WaitForChild("Send",5)
    if not (sendRemote and sendRemote:IsA("RemoteEvent")) then return end
    sendRemote.OnClientEvent:Connect(function() if AutoSkipEnabled then TrySkipCrate() end end)
end
SetupAutoSkip()

-- WalkSpeed
local function setupCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    if moveConnection then moveConnection:Disconnect() end
    moveConnection = RunService.RenderStepped:Connect(function()
        if walkSpeedEnabled and Humanoid and HumanoidRootPart then
            if Humanoid.MoveDirection.Magnitude > 0 then
                HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + (Humanoid.MoveDirection.Unit * speedValue)
            end
        end
    end)
end
LocalPlayer.CharacterAdded:Connect(setupCharacter)
if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end

-- CheckAndPickup loop
RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    end
    pcall(CheckAndPickup)
end)

-- Teleport snap
local function performTeleport()
    if not HumanoidRootPart then return end
    local currentPos = HumanoidRootPart.Position
    local bottomPos = Vector3.new(currentPos.X, currentPos.Y - maxHeight, currentPos.Z)
    HumanoidRootPart.CFrame = CFrame.new(bottomPos)
    lockedY = bottomPos.Y
end
local function toggleTeleport()
    if not featureEnabled then return end
    teleportActive = not teleportActive
    if teleportActive then performTeleport() else lockedY = nil end
end
local connection
local function lockYPosition()
    if connection then connection:Disconnect() end
    connection = RunService.Heartbeat:Connect(function()
        if teleportActive and lockedY and HumanoidRootPart then
            local currentPos = HumanoidRootPart.Position
            if math.abs(currentPos.Y - lockedY) > 0.1 then
                HumanoidRootPart.CFrame = CFrame.new(currentPos.X, lockedY, currentPos.Z)
            end
        end
    end)
end
lockYPosition()

-- ESP (Drawing)
local function createESP(player)
    if espPlayers[player] then return end
    local nameText = Drawing.new("Text")
    nameText.Size = 16; nameText.Center = true; nameText.Outline = true; nameText.Font = 4
    local distanceText = Drawing.new("Text")
    distanceText.Size = 14; distanceText.Center = true; distanceText.Outline = true; distanceText.Font = 4
    local healthBg = Drawing.new("Square")
    healthBg.Filled = false; healthBg.Thickness = 1; healthBg.Color = Color3.new(0,0,0); healthBg.Transparency = 0.9
    local healthFg = Drawing.new("Square")
    healthFg.Filled = true; healthFg.Transparency = 0.9
    local drawings = {nameText, distanceText, healthBg, healthFg}
    local conn = RunService.RenderStepped:Connect(function()
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(drawings) do obj.Visible = false end; return
        end
        local hrp = player.Character.HumanoidRootPart
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local dist = 0
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        end
        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen or screenPos.Z <= 0 then
            for _, obj in pairs(drawings) do obj.Visible = false end; return
        end
        local centerX = screenPos.X
        local currentTopY = screenPos.Y - 15
        if healthESPEnabled and humanoid and humanoid.Health > 0 then
            local perc = humanoid.Health / (humanoid.MaxHealth > 0 and humanoid.MaxHealth or 1)
            local barHeight = 4; local barWidth = 60
            local healthX = centerX - barWidth/2
            healthBg.Position = Vector2.new(healthX, currentTopY - barHeight - 2)
            healthBg.Size = Vector2.new(barWidth, barHeight)
            healthBg.Visible = true
            healthFg.Position = Vector2.new(healthX, currentTopY - barHeight - 2)
            healthFg.Size = Vector2.new(barWidth * perc, barHeight)
            healthFg.Color = Color3.fromHSV(perc * 0.333, 0.8, 0.9)
            healthFg.Visible = true
            currentTopY = currentTopY - barHeight - 6
        else
            healthBg.Visible = false; healthFg.Visible = false
        end
        if nameESPEnabled then
            local minSize, maxSize = 14, 42
            local scaleDist = math.clamp(dist / 50, 0, 1)
            local dynamicSize = maxSize - (maxSize - minSize) * scaleDist
            nameText.Text = player.Name
            nameText.Size = math.floor(dynamicSize)
            nameText.Color = isPlayerExcluded(player.Name) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
            nameText.Position = Vector2.new(centerX, currentTopY - 16)
            nameText.Visible = true
        else
            nameText.Visible = false
        end
        distanceText.Text = distanceESPEnabled and string.format("%.0f studs", dist) or ""
        distanceText.Position = Vector2.new(centerX, screenPos.Y + 20)
        distanceText.Visible = distanceESPEnabled
    end)
    espPlayers[player] = {conn = conn, drawings = drawings}
end
local function loadESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not espPlayers[player] then createESP(player) end
    end
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function() task.wait(0.1); if not espPlayers[player] then createESP(player) end end)
            if player.Character then task.wait(0.1); createESP(player) end
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        if espPlayers[player] then
            for _, obj in pairs(espPlayers[player].drawings) do pcall(function() obj:Remove() end) end
            if espPlayers[player].conn then pcall(function() espPlayers[player].conn:Disconnect() end) end
            espPlayers[player] = nil
        end
    end)
end
loadESP()

function updateHighlight(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    if playerHighlights[player] then playerHighlights[player]:Destroy() end
    if highlightEnabled then
        local highlight = Instance.new("Highlight")
        highlight.Adornee = player.Character
        highlight.FillColor = Color3.fromRGB(0,170,255)
        highlight.OutlineColor = Color3.fromRGB(0,170,255)
        highlight.Parent = workspace
        playerHighlights[player] = highlight
    end
end
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function() task.wait(0.1); updateHighlight(player) end)
        updateHighlight(player)
    end
end
Players.PlayerAdded:Connect(function(player) player.CharacterAdded:Connect(function() task.wait(0.1); updateHighlight(player) end) end)
Players.PlayerRemoving:Connect(function(player) if playerHighlights[player] then playerHighlights[player]:Destroy() end end)

-- Gun mod
local GunsFolder = ReplicatedStorage:WaitForChild("Items"):WaitForChild("gun")
local function isGunTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    return GunsFolder:FindFirstChild(tool.Name) ~= nil or tool.Name:match("Gun") or tool:FindFirstChild("Handle")
end
local function applyGodGun(tool)
    if not tool or not isGunTool(tool) then return end
    pcall(function()
        tool:SetAttribute("fire_rate", getgenv().FireRateValue)
        tool:SetAttribute("accuracy", getgenv().AccuracyValue)
        tool:SetAttribute("Recoil", getgenv().RecoilValue)
        tool:SetAttribute("Durability", getgenv().Durability)
        tool:SetAttribute("automatic", getgenv().AutoValue)
    end)
end
RunService.Heartbeat:Connect(function()
    if not getgenv().GunModsAutoApply then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and isGunTool(tool) then pcall(applyGodGun, tool) end
    end
end)

-- Melee aura
local meleeNames = {}
for _, v in ipairs(MeleeFolder:GetChildren()) do table.insert(meleeNames, v.Name) end
local function isMeleeTool(tool)
    if not tool:IsA("Tool") then return false end
    if tool.Name == "Fists" then return true end
    for _, name in ipairs(meleeNames) do if tool.Name == name then return true end end
    return false
end
local function modifyFists(tool, enable)
    if tool then
        local keys = {}
        for k in pairs(tool:GetAttributes()) do table.insert(keys, k) end
        table.sort(keys)
        if #keys >= 7 then
            local attr6 = keys[6]; local attr7 = keys[7]
            if enable then
                if OriginalValues[attr6] == nil then OriginalValues[attr6] = tool:GetAttribute(attr6) end
                if OriginalValues[attr7] == nil then OriginalValues[attr7] = tool:GetAttribute(attr7) end
                tool:SetAttribute(attr6, 360); tool:SetAttribute(attr7, 20)
            else
                if OriginalValues[attr6] then tool:SetAttribute(attr6, OriginalValues[attr6]) end
                if OriginalValues[attr7] then tool:SetAttribute(attr7, OriginalValues[attr7]) end
            end
        end
    end
end
local function checkAndModifyFists()
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not char or not bp then return end
    for _, t in ipairs(char:GetChildren()) do if isMeleeTool(t) then modifyFists(t, FistsBuffEnabled) end end
    for _, t in ipairs(bp:GetChildren()) do if isMeleeTool(t) then modifyFists(t, FistsBuffEnabled) end end
end
RunService.Heartbeat:Connect(function() if FistsBuffEnabled then checkAndModifyFists() end end)

-- Auto attack (melee)
local scanInterval = 0.4
local runningAA = false
local function getPlayersInRange(radius)
    local inRange = {}
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return inRange end
    local pos = char.PrimaryPart.Position
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character.PrimaryPart then
            local ok, mag = pcall(function() return (player.Character.PrimaryPart.Position - pos).Magnitude end)
            if ok and mag and mag <= radius then table.insert(inRange, player) end
        end
    end
    return inRange
end
local function getActiveTool()
    local char = LocalPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do if item:IsA("Tool") then return item end end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then for _, item in ipairs(backpack:GetChildren()) do if item:IsA("Tool") then return item end end end
    return nil
end
local function AttackNearby()
    if not Remote then return end
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return end
    local tool = getActiveTool()
    if not tool or not isMeleeTool(tool) then return end
    if tool.Parent ~= LocalPlayer.Character then return end
    local targets = getPlayersInRange(20)
    if #targets == 0 then return end
    local localPos = char.PrimaryPart.Position
    local playerTargets = {}
    local predictedPositions = {}
    for _, player in pairs(targets) do
        if player.Character and player.Character.PrimaryPart then
            local head = player.Character:FindFirstChild("Head")
            local hrp = player.Character.PrimaryPart
            if head and hrp then
                table.insert(playerTargets, player)
                table.insert(predictedPositions, predictPosition(head, hrp))
            end
        end
    end
    if #playerTargets == 0 then return end
    local lookAtCFrame = CFrame.lookAt(localPos, predictedPositions[1])
    local args = {"melee_attack", tool, playerTargets, lookAtCFrame, 0.75}
    pcall(function()
        local seq = getCounter(true)
        if seq then Remote:FireServer(seq, unpack(args)) end
    end)
end
local function StartAutoAttack()
    if runningAA then return end
    runningAA = true
    task.spawn(function()
        while runningAA do
            task.wait(scanInterval)
            if hookEnabled and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                pcall(AttackNearby)
            end
        end
    end)
end
StartAutoAttack()

-- UI: simple creation (WindUI or fallback) - truncated for length, assume full UI exists in actual script
-- We'll just add the necessary toggles

-- Create tabs using safe functions (these would be defined earlier)
local CombatTab = Window:Tab({Title = "COMBAT:", Icon = "crosshair"})
local WeaponTab = Window:Tab({Title = "WEAPON:", Icon = "layers"})
local ESPTab = Window:Tab({Title = "ESP:", Icon = "eye"})
local CharacterTab = Window:Tab({Title = "CHARACTER:", Icon = "user"})
local MiscTab = Window:Tab({Title = "MISC:", Icon = "warehouse"})

-- COMBAT
CombatTab:Section({Title = "GUN:"})
CombatTab:Toggle({Title = "Silent Aim", Default = false, Callback = function(v) SilentAimEnabled = v; CurrentTarget = nil end})
CombatTab:Toggle({Title = "Red Line Lock", Default = false, Callback = function(v) SilentAimAttachEnabled = v; CurrentTarget = nil end})
CombatTab:Slider({Title = "FOV", Step = 1, Value = {Min=20, Max=800, Default=FOVRadius}, Callback = function(v) FOVRadius = v end})
CombatTab:Input({Title = "Safe Friend", Placeholder = "ชื่อ", Callback = function(v)
    excludedPlayerNames = {string.match(v:lower(), "%S+")}
end})

-- WEAPON
WeaponTab:Section({Title = "MODS:"})
WeaponTab:Slider({Title = "Fire Rate", Step = 10, Value = {Min=100, Max=3000, Default=1000}, Callback = function(v) getgenv().FireRateValue = v end})
WeaponTab:Slider({Title = "Accuracy", Step = 0.01, Value = {Min=0, Max=1, Default=1}, Callback = function(v) getgenv().AccuracyValue = v end})
WeaponTab:Slider({Title = "Recoil", Step = 0.1, Value = {Min=0, Max=10, Default=0}, Callback = function(v) getgenv().RecoilValue = v end})
WeaponTab:Toggle({Title = "Auto Modify", Default = false, Callback = function(v) getgenv().GunModsAutoApply = v end})
WeaponTab:Toggle({Title = "Melee Aura", Default = false, Callback = function(v) FistsBuffEnabled = v; checkAndModifyFists() end})
WeaponTab:Toggle({Title = "Auto Attack", Default = false, Callback = function(v) hookEnabled = v end})

-- ESP
ESPTab:Section({Title = "ESP:"})
ESPTab:Toggle({Title = "Name ESP", Default = false, Callback = function(v) nameESPEnabled = v end})
ESPTab:Toggle({Title = "Health ESP", Default = false, Callback = function(v) healthESPEnabled = v end})
ESPTab:Toggle({Title = "Distance ESP", Default = false, Callback = function(v) distanceESPEnabled = v end})
ESPTab:Toggle({Title = "Highlight", Default = false, Callback = function(v) highlightEnabled = v; for _, plr in pairs(Players:GetPlayers()) do updateHighlight(plr) end end})
ESPTab:Section({Title = "MAGNET PICKUP"})
ESPTab:Toggle({Title = "ดูดของอัตโนมัติ", Default = false, Callback = function(v) magnetEnabled = v; if v then startMagnet() else stopMagnet() end end})
ESPTab:Slider({Title = "รัศมีดูด", Step = 100, Value = {Min=500, Max=5000, Default=2000}, Callback = function(v) magnetRadius = v end})
ESPTab:Slider({Title = "ความเร็วดูด", Step = 1, Value = {Min=3, Max=20, Default=8}, Callback = function(v) magnetSpeed = v/10 end})

-- CHARACTER
CharacterTab:Section({Title = "MOVEMENT"})
CharacterTab:Toggle({Title = "Walk Speed", Default = false, Callback = function(v) walkSpeedEnabled = v end})
CharacterTab:Slider({Title = "Speed Multiplier", Step = 0.5, Value = {Min=1, Max=5, Default=2}, Callback = function(v) speedValue = v * 0.05 end})
CharacterTab:Toggle({Title = "Fly Mode (hold space)", Default = false, Callback = function(v) FlyEnabled = v end})
CharacterTab:Slider({Title = "Fly Power", Step = 5, Value = {Min=20, Max=100, Default=40}, Callback = function(v) floatPower = v end})
CharacterTab:Section({Title = "PROTECTION"})
CharacterTab:Toggle({Title = "Anti Kill", Default = false, Callback = function(v)
    antiDeathEnabled = v
    if v then startAntiKill() else stopAntiKill() end
end})
CharacterTab:Toggle({Title = "Pickup items (basic)", Default = false, Callback = function(v)
    _G.ZenithPickup.sucking = v
end})
CharacterTab:Section({Title = "SNAP (Z)"})
CharacterTab:Toggle({Title = "Snap Under Map", Default = false, Callback = function(v) featureEnabled = v; if v then clickCount=1; startY = HumanoidRootPart and HumanoidRootPart.Position.Y or nil; teleportActive = true; performTeleport() else teleportActive = false; lockedY = nil; startY = nil end end})
CharacterTab:Slider({Title = "Snap Depth", Step = 1, Value = {Min=1, Max=50, Default=10}, Callback = function(v) maxHeight = v end})

-- MISC
MiscTab:Section({Title = "AUTO SKIP CRATE"})
MiscTab:Toggle({Title = "Skip Crate Spin", Default = false, Callback = function(v) AutoSkipEnabled = v; if v then TrySkipCrate() end end})
MiscTab:Button({Title = "Skip Now", Callback = function() TrySkipCrate() end})

-- Final notification
game:GetService("StarterGui"):SetCore("SendNotification", {Title = "ZENITH HUB", Text = "โหลดสำเร็จ! (Pickup Fixed)", Duration = 4})
