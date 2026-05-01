-- ── Splash Screen UI ─────────────────────────────────────────
do
    local _Players = game:GetService("Players")
    local _TweenService = game:GetService("TweenService")
    local _ReplicatedStorage = game:GetService("ReplicatedStorage")
    local _player = _Players.LocalPlayer
    local _playerGui = _player:WaitForChild("PlayerGui")
    local _Net = require(_ReplicatedStorage.Modules.Core.Net)

    local FONT = Enum.Font.GothamBold

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "zhXUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = _playerGui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0,320,0,120)
    main.Position = UDim2.fromScale(0.5,0.5)
    main.AnchorPoint = Vector2.new(0.5,0.5)
    main.BackgroundColor3 = Color3.fromRGB(120,0,255)
    main.BackgroundTransparency = 0.2
    main.BorderSizePixel = 0
    main.Parent = screenGui
    Instance.new("UICorner",main).CornerRadius = UDim.new(0,14)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(155,55,255)
    stroke.Thickness = 2
    stroke.Transparency = 0
    stroke.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,34)
    title.Position = UDim2.new(0,0,0,4)
    title.BackgroundTransparency = 1
    title.Text = "Zenith Hub"
    title.Font = FONT
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Parent = main

    local function makeButton(txt,x)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,130,0,38)
        btn.Position = UDim2.new(0,x,0,62)
        btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
        btn.BackgroundTransparency = 0.35
        btn.Text = txt
        btn.Font = FONT
        btn.TextSize = 16
        btn.TextColor3 = Color3.fromRGB(30,30,30)
        btn.AutoButtonColor = false
        btn.Parent = main
        Instance.new("UICorner",btn).CornerRadius = UDim.new(0,10)
        return btn
    end

    local normalBtn = makeButton("Normal mode", 20)
    local godBtn = makeButton("God mode", 170)

    local Done = false

    local function destroyUI()
        local tw = _TweenService:Create(main, TweenInfo.new(0.22), {
            Size = UDim2.new(0,0,0,0),
            BackgroundTransparency = 1
        })
        tw:Play()
        tw.Completed:Wait()
        screenGui:Destroy()
    end

    local function pressButton(guiObject)
        if not guiObject then return end
        pcall(function() firesignal(guiObject.MouseButton1Click) end)
        pcall(function() firesignal(guiObject.Activated) end)
    end

    normalBtn.MouseButton1Click:Connect(function()
        destroyUI()
        task.spawn(function()
            task.wait(0.5)
            local splashGui = _playerGui:FindFirstChild("SplashScreenGui")
            if splashGui then
                local frame = splashGui:FindFirstChild("Frame")
                local playButton = frame and frame:FindFirstChild("PlayButton")
                pressButton(playButton)
            end
            Done = true
             local characterCreator = _playerGui:FindFirstChild("CharacterCreator")
            if characterCreator then
                local menuFrame = characterCreator:FindFirstChild("MenuFrame")
                local skipButton = menuFrame and menuFrame:FindFirstChild("AvatarMenuSkipButton")
                pressButton(skipButton)
            end
        end)
    end)


task.wait(4)


    godBtn.MouseButton1Click:Connect(function()
        destroyUI()
        task.spawn(function()
            if not _G.Bypass then
                local func = getupvalue(_Net.get, 2)
                if func then
                    setconstant(func, 3, "KUYIENGOKUYIENGO")
                    setconstant(func, 4, "KUYIENGOKUYIENGO")
                end
                _G.Bypass = true
            end

            local old
            old = hookfunction(_Net.send, function(...)
                local d = {...}
                if d[1] == "leave_character_creator" or d[1] == "player_created_outfit" then
                    return nil
                end
                return old(...)
            end)

            task.wait(0.5)
            local splashGui = _playerGui:FindFirstChild("SplashScreenGui")
            if splashGui then
                local frame = splashGui:FindFirstChild("Frame")
                local playButton = frame and frame:FindFirstChild("PlayButton")
                pressButton(playButton)
            end

            task.wait(0.5)
            local characterCreator = _playerGui:FindFirstChild("CharacterCreator")
            if characterCreator then
                local menuFrame = characterCreator:FindFirstChild("MenuFrame")
                local skipButton = menuFrame and menuFrame:FindFirstChild("AvatarMenuSkipButton")
                pressButton(skipButton)
            end

            task.wait(2.5)
            replicatesignal(game.Players.LocalPlayer.Kill)
            task.wait(7)
            _Net.send("death_screen_request_respawn")
            Done = true
        end)
    end)

    repeat task.wait() until Done
end

raknetLib = raknet
desyncEnabled = false

function setDesync(state)
    if raknetLib then
        if state then
            raknetLib.desync(true)
            print("[Success] เปิดโหมดล่องหน (Desync) เรียบร้อยแล้ว")
            print("[Note] จะกลับมาเห็นตัวอีกครั้ง ต้องปิด toggle นี้ หรือออกจากเกม")
        else
            raknetLib.desync(false)
            print("[Success] ปิดโหมดล่องหน (Desync) แล้ว")
        end
    else
        warn("[Error] ไม่พบ Raknet library ใน Executor นี้")
    end
end

task.wait(3)


Players = game:GetService("Players")
RunService = game:GetService("RunService")
ReplicatedStorage = game:GetService("ReplicatedStorage")
UserInputService = game:GetService("UserInputService")
TweenService = game:GetService("TweenService")
Debris = game:GetService("Debris")
Workspace = game:GetService("Workspace")
ContextActionService = game:GetService("ContextActionService")
Remotes = ReplicatedStorage:WaitForChild("Remotes")
Util = require(ReplicatedStorage.Modules.Core.Util)
BuyPromptUI = require(ReplicatedStorage.Modules.Game.UI.BuyPromptUI)
EmotesUI = require(ReplicatedStorage.Modules.Game.Emotes.EmotesUI)
EmotesList = require(ReplicatedStorage.Modules.Game.Emotes.EmotesList)
CoreUI = require(ReplicatedStorage.Modules.Core.UI)
CharModule = require(ReplicatedStorage.Modules.Core.Char)
ItemsFolder = ReplicatedStorage:WaitForChild("Items")
MeleeFolder = ItemsFolder:WaitForChild("melee")
LocalPlayer = Players.LocalPlayer
Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
Humanoid = Character:WaitForChild("Humanoid")
HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
Client = Players.LocalPlayer
item_drawings = {}
droppedItems = workspace:WaitForChild("DroppedItems")

Camera = Workspace.CurrentCamera
Mouse = LocalPlayer:GetMouse()
isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
WindUI = nil
pcall(function()
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

Window = nil
if WindUI then
    Window = WindUI:CreateWindow({
        Title = "ZENITH HUB  |  Block Spin 🔫| PAID 💸",
        Icon = "list",
        Author = "HI! I'M YUGI:)",
        Folder = "ZENITH HUB Now!!!",
        Size = UDim2.fromOffset(650, 400),
        Theme = "Dark",
        Transparent = true,
        Resizable = true,
        KeyCode = Enum.KeyCode.G
    })
    Window:Tag({
        Title = "v5.7.5",
        Color = Color3.fromHex("#30ff6a"),
        Radius = 12
    })
else
    Window = {
        Tab = function(_)
            return {
                Section = function() end,
                Toggle = function() end,
                Slider = function() end,
                Button = function() end,
                Input = function() return {} end,
                Divider = function() end
            }
        end
    }
end

ConfigManager = Window.ConfigManager
myConfig = ConfigManager:CreateConfig("CathubConfig")
Remote = nil
pcall(function()
    Remote = ReplicatedStorage:WaitForChild("Remotes", 5):WaitForChild("Send", 5)
end)

SilentAimEnabled = false
SilentAimAttachEnabled = false
FOVRadius = 120
CurrentTarget = nil
SilentFOVCircle = nil
Tracer = Drawing.new("Line")
Tracer.Thickness = 1
Tracer.Color = Color3.fromRGB(255, 50, 50)
Tracer.Transparency = 1
Tracer.Visible = false

espPlayers = {}
nameESPEnabled = false
distanceESPEnabled = false
healthESPEnabled = false
excludedPlayerNames = {}

walkSpeedEnabled = false
speedValue = 0.05
FlyEnabled = false
isFlyingUp = false
floatPower = 40
teleportActive = false
featureEnabled = false
lockedY = nil
maxHeight = 10
startY = nil
moveConnection = nil
flyJumpConnection = nil
hookEnabled = false
clickCount = 0
fastFinishEnabled = false
Active = false
BringConnection = nil
holdTime = 1
scanInterval = 0.4
flickering = false
undergroundBaseCFrame = nil
getgenv = getgenv or function() return _G end
getgenv().Sky = false
getgenv().SkyAmount = 1500
AutoSkipEnabled = false
sucking = false
lastPickupTimes = {}
DROP_DEPTH = -55
MOVE_RADIUS = 30
FLICKER_RATE = 0.1
AutoRespawnEnabled = false
WallShootEnabled = false
ShootEnabled = false
ChckEnabled = false
scanRadius = 20
localEventCounter = 0
localFuncCounter = 0
AutoSprintEnabled = false

RARITY_COLORS = {
    ["Common"] = Color3.fromRGB(255, 255, 255),
    ["Uncommon"] = Color3.fromRGB(99, 255, 52),
    ["Rare"] = Color3.fromRGB(51, 170, 255),
    ["Epic"] = Color3.fromRGB(237, 44, 255),
    ["Legendary"] = Color3.fromRGB(255, 150, 0),
    ["Omega"] = Color3.fromRGB(255, 20, 51)
}
WeaponDB = {}
BillboardCache = {}
ESPEnabled = false
ESPConnection = nil
FistsBuffEnabled = false
OriginalValues = {}
BOX_SIZE_SCALE = 100
playerHighlights = {}
highlightEnabled = false

-- มองของบนพื้น
groundItemsESPEnabled = true

CounterTable = nil
pcall(function()
    for _, Obj in ipairs(getgc(true)) do
        if typeof(Obj) == "table" and rawget(Obj, "event") and rawget(Obj, "func") then
            CounterTable = Obj
            break
        end
    end
end)

function getPing()
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

function isPlayerExcluded(playerName)
    for _, excludedName in ipairs(excludedPlayerNames) do
        if excludedName ~= "" and string.find(string.lower(playerName), string.lower(excludedName)) then
            return true
        end
    end
    return false
end

function getClosestTarget()
    local closest = nil
    local shortestDistance = FOVRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if head and humanoid and humanoid.Health > 0 and hrp then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local screenVector = Vector2.new(screenPos.X, screenPos.Y)
                    local distanceFromCenter = (screenVector - center).Magnitude
                    if distanceFromCenter <= FOVRadius and not isPlayerExcluded(player.Name) then
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

function predictPosition(head, hrp)
    if not head then return Vector3.zero end
    local ping = (getPing and getPing()) or (game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000)
    if ping > 1 then ping = 0.2 end
    local vel = (hrp and hrp.AssemblyLinearVelocity) or Vector3.zero
    return head.Position + (vel * ping * 1.21)
end

function isBehindWall(startPos, endPos)
    if not startPos or not endPos then return false end
    local direction = endPos - startPos
    if direction.Magnitude < 1 then return false end
    local ignoreList = {}
    local char = LocalPlayer.Character
    if char then table.insert(ignoreList, char) end
    local tgtChar = CurrentTarget and CurrentTarget.Character
    if tgtChar then table.insert(ignoreList, tgtChar) end
    local raycastResult = workspace:Raycast(startPos, direction, RaycastParams.new())
    if not raycastResult then return false end
    local hitPart = raycastResult.Instance
    return hitPart and not table.find(ignoreList, hitPart.Parent)
end

function setupCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    if moveConnection then
        pcall(function() moveConnection:Disconnect() end)
    end
    moveConnection = RunService.RenderStepped:Connect(function()
        if walkSpeedEnabled and Humanoid and HumanoidRootPart then
            if Humanoid.MoveDirection.Magnitude > 0 then
                HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + (Humanoid.MoveDirection.Unit * speedValue)
            end
        end
    end)
end

function isDowned()
    local hum = CharModule.get_hum()
    if not hum then return false end
    if hum.Health <= 0 then return false end
    return hum:GetAttribute("HasBeenDowned") or hum:GetAttribute("IsDead")
end

function getHRP()
    local char = CharModule.current_char.get()
    if not char then return end
    return char:FindFirstChild("HumanoidRootPart")
end

function teleportUnderground()
    local hrp = getHRP()
    if not hrp then return end
    local original = hrp.CFrame
    undergroundBaseCFrame = original + Vector3.new(0, DROP_DEPTH, 0)
    hrp.CFrame = undergroundBaseCFrame
end

function flickerAndMove()
    if flickering then return end
    flickering = true
    task.spawn(function()
        while flickering and enabled and isDowned() do
            local hum = CharModule.get_hum()
            if hum and hum.Health <= 0 then break end
            local hrp = getHRP()
            if hrp and undergroundBaseCFrame then
                local angle = math.random() * math.pi * 2
                local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * MOVE_RADIUS
                local randomPos = undergroundBaseCFrame.Position + offset
                hrp.CFrame = CFrame.new(randomPos)
                task.wait(0.05)
                hrp.CFrame = undergroundBaseCFrame
            end
            task.wait(FLICKER_RATE)
        end
        flickering = false
    end)
end

function NetGet(...)
    if not CounterTable or not CounterTable.func then return end
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
    CounterTable.func = (CounterTable.func or 0) + 1
    local success, result = pcall(function()
        local GetRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Get")
        return GetRemote:InvokeServer(CounterTable.func, unpack(args))
    end)
    if not success then warn("[NetGet Error]", result) end
    return result
end

function CheckAndPickup()
    if not sucking then return end
    local dropped = Workspace:FindFirstChild("DroppedItems")
    if not dropped then return end
    local now = tick()
    local itemsToPickup = {}
    for _, item in ipairs(dropped:GetChildren()) do
        if item:IsA("Model") then
            local part = item:FindFirstChildWhichIsA("BasePart")
            if part then
                local distance = (HumanoidRootPart.Position - part.Position).Magnitude
                if distance <= 20 and (now - (lastPickupTimes[item] or 0)) >= 0 then
                    table.insert(itemsToPickup, item)
                    lastPickupTimes[item] = now
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

function SafeCall(f, ...)
    local ok, res = pcall(f, ...)
    return ok, res
end

tu_unpack = table.unpack or unpack

function CallRemote(remote, ...)
    if not remote then return end
    local args = {...}
    if remote.ClassName == "RemoteEvent" then
        if CounterTable and type(CounterTable.event) == "number" then
            CounterTable.event = CounterTable.event + 1
            SafeCall(function(...) remote:FireServer(CounterTable.event, ...) end, tu_unpack(args))
        else
            localEventCounter = (localEventCounter or 0) + 1
            SafeCall(function(...) remote:FireServer(localEventCounter, ...) end, tu_unpack(args))
        end
    elseif remote.ClassName == "RemoteFunction" then
        if CounterTable and type(CounterTable.func) == "number" then
            CounterTable.func = CounterTable.func + 1
            SafeCall(function(...) remote:InvokeServer(CounterTable.func, ...) end, tu_unpack(args))
        else
            localFuncCounter = (localFuncCounter or 0) + 1
            SafeCall(function(...) remote:InvokeServer(localFuncCounter, ...) end, tu_unpack(args))
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

function getActiveTool()
    local char = LocalPlayer and LocalPlayer.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if pcall(function() return item:IsA("Tool") end) and item:IsA("Tool") then return item end
        end
    end
    local backpack = LocalPlayer and LocalPlayer:FindFirstChild("Backpack")
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
    if meleeItems:FindFirstChild(tool.Name) and not throwableItems:FindFirstChild(tool.Name) then
        return true
    end
    return false
end

function AttackNearby()
    if not Remote then return end
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return end
    local tool = getActiveTool()
    if not tool or not isMeleeTool(tool) then return end
    local okParent, parent = pcall(function() return tool.Parent end)
    if not okParent or parent ~= LocalPlayer.Character then return end
    local targets = getPlayersInRange(scanRadius)
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
    local args = {"melee_attack", tool, playerTargets, lookAtCFrame, 0.75}
    pcall(function() CallRemote(Remote, tu_unpack(args)) end)
end

running = false
function StartAutoAttack()
    if running then return end
    running = true
    task.spawn(function()
        while running do
            task.wait(scanInterval)
            if hookEnabled and LocalPlayer and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                pcall(AttackNearby)
            end
        end
    end)
end

function createNeonEffectAtPosition(pos, fadeTime) end

function performTeleport()
    if not HumanoidRootPart then return end
    local currentPos = HumanoidRootPart.Position
    local bottomPos = Vector3.new(currentPos.X, currentPos.Y - maxHeight, currentPos.Z)
    HumanoidRootPart.CFrame = CFrame.new(bottomPos)
    lockedY = bottomPos.Y
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://95298029662868"
    sound.Volume = 1
    sound.PlayOnRemove = true
    sound.Parent = HumanoidRootPart
    sound:Destroy()
    createNeonEffectAtPosition(currentPos, 1.5)
    createNeonEffectAtPosition(bottomPos, 2)
end

function toggleTeleport()
    if not featureEnabled then return end
    teleportActive = not teleportActive
    if teleportActive then performTeleport() else lockedY = nil end
end

connection = nil
function lockYPosition()
    if connection then pcall(function() connection:Disconnect() end) end
    connection = RunService.Heartbeat:Connect(function()
        if teleportActive and lockedY and HumanoidRootPart then
            local currentPos = HumanoidRootPart.Position
            if math.abs(currentPos.Y - lockedY) > 0.1 then
                HumanoidRootPart.CFrame = CFrame.new(currentPos.X, lockedY, currentPos.Z)
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
            if WeaponDB[key] then
                warn("Duplicate weapon key detected: " .. key .. " (Tool: " .. tool.Name .. ", Rarity: " .. rarity .. ")")
            end
            WeaponDB[key] = {
                Name = displayName,
                Rarity = rarity,
                ImageId = imageId,
                ToolName = tool.Name
            }
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
    return WeaponDB[key]
end

function createBillboardForPlayer(player)
    if not ESPEnabled or player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if BillboardCache[player] then
        BillboardCache[player]:Destroy()
        BillboardCache[player] = nil
    end
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
            border.Color = RARITY_COLORS[info.Rarity] or Color3.new(1,1,1)
            border.Thickness = 2
        end
    end
    BillboardCache[player] = billboard
end

function setFinishPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = holdTime
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
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local prompt = hrp:FindFirstChild("FinishPrompt")
                if prompt then setFinishPrompt(prompt) end
            end
        end
    end
end

function setupFastFinishForPlayer(p)
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function(char)
            char.DescendantAdded:Connect(function(desc)
                if fastFinishEnabled and desc.Name == "FinishPrompt" and desc:IsA("ProximityPrompt") and desc.Parent and desc.Parent.Name == "HumanoidRootPart" then
                    setFinishPrompt(desc)
                end
            end)
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if hrp and fastFinishEnabled then
                local prompt = hrp:FindFirstChild("FinishPrompt")
                if prompt then setFinishPrompt(prompt) end
            end
        end)
        if p.Character then
            local char = p.Character
            char.DescendantAdded:Connect(function(desc)
                if fastFinishEnabled and desc.Name == "FinishPrompt" and desc:IsA("ProximityPrompt") and desc.Parent and desc.Parent.Name == "HumanoidRootPart" then
                    setFinishPrompt(desc)
                end
            end)
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and fastFinishEnabled then
                local prompt = hrp:FindFirstChild("FinishPrompt")
                if prompt then setFinishPrompt(prompt) end
            end
        end
    end
end

function getPlayer(name)
    name = string.lower(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), name) or string.find(string.lower(p.DisplayName), name) then return p end
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
        Torque.Torque = Vector3.new(100000, 100000, 100000)
        Torque.Attachment0 = Attachment2
        AlignPosition.MaxForce = math.huge
        AlignPosition.MaxVelocity = math.huge
        AlignPosition.Responsiveness = 9999
        AlignPosition.Attachment0 = Attachment2
        AlignPosition.Attachment1 = Attachment1
    end
end

function ToggleBring(name)
    local player = getPlayer(name)
    if not player then return end
    Active = not Active
    if Active then
        local char = player.Character or player.CharacterAdded:Wait()
        local targetRoot = char:WaitForChild("HumanoidRootPart")
        for _, v in ipairs(Workspace:GetDescendants()) do ForcePart(v) end
        BringConnection = Workspace.DescendantAdded:Connect(ForcePart)
        task.spawn(function()
            while Active do
                Attachment1.WorldCFrame = targetRoot.CFrame
                task.wait()
            end
        end)
    else
        if BringConnection then BringConnection:Disconnect() end
    end
end

function TrySkipCrate()
    loadstring(game:HttpGet("https://pastefy.app/HEGoWtob/raw"))()
end

-- =========================
-- Boost FPS (ภาพกาก)
-- =========================

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Terrain = workspace:FindFirstChildOfClass("Terrain")

local function Bootsfps()
    -- ลบท้องฟ้า + เอฟเฟกต์
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky")
        or v:IsA("Atmosphere")
        or v:IsA("BloomEffect")
        or v:IsA("SunRaysEffect")
        or v:IsA("ColorCorrectionEffect")
        or v:IsA("DepthOfFieldEffect") then
            v:Destroy()
        end
    end

    -- ปิดเงา / แสง
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0
    Lighting.FogEnd = 9e9
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0

    -- Terrain กาก
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
    end

    -- ทำทั้งแมพเป็นสีเทา / plastic
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
            v.CastShadow = false
            v.Color = Color3.fromRGB(120,120,120)

        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1

        elseif v:IsA("ParticleEmitter")
        or v:IsA("Trail")
        or v:IsA("Beam") then
            v.Enabled = false
        end
    end
end


function SetupAutoSkip()
    local remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 5)
    if not remotesFolder then return end
    local sendRemote = remotesFolder:WaitForChild("Send", 5)
    if not (sendRemote and sendRemote:IsA("RemoteEvent")) then return end
    sendRemote.OnClientEvent:Connect(function(...)
        if AutoSkipEnabled then TrySkipCrate() end
    end)
end

function createESP(player)
    if espPlayers[player] then return end
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
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        end
        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen or screenPos.Z <= 0 then
            for _, obj in pairs(drawings) do obj.Visible = false end
            return
        end
        local centerX = screenPos.X
        local currentTopY = screenPos.Y - 15
        if healthESPEnabled and humanoid and humanoid.Health > 0 then
            local perc = humanoid.Health / (humanoid.MaxHealth > 0 and humanoid.MaxHealth or 1)
            local barHeight = 4
            local barWidth = 60
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
            healthBg.Visible = false
            healthFg.Visible = false
        end
        if nameESPEnabled then
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
        distanceText.Text = distanceESPEnabled and string.format("%.0f m", dist) or ""
        distanceText.Position = Vector2.new(centerX, screenPos.Y + 20)
        distanceText.Visible = distanceESPEnabled
    end)
    espPlayers[player] = {conn = conn, drawings = drawings}
end

function loadESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not espPlayers[player] then createESP(player) end
    end
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function()
                task.wait(0.1)
                if not espPlayers[player] then createESP(player) end
            end)
            if player.Character and not espPlayers[player] then
                task.wait(0.1)
                createESP(player)
            end
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        if espPlayers[player] then
            for _, obj in pairs(espPlayers[player].drawings) do
                if obj and obj.Destroy then pcall(function() obj:Destroy() end)
                elseif typeof(obj) == "table" and obj.Visible ~= nil then obj.Visible = false end
            end
            if espPlayers[player].conn then pcall(function() espPlayers[player].conn:Disconnect() end) end
            espPlayers[player] = nil
        end
    end)
end

if not isMobile then
    SilentFOVCircle = Drawing.new("Circle")
    SilentFOVCircle.Thickness = 1.4
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
    SilentFOVCircle.Size = UDim2.fromOffset(FOVRadius*2, FOVRadius*2)
    SilentFOVCircle.AnchorPoint = Vector2.new(0.5,0.5)
    SilentFOVCircle.Position = UDim2.fromScale(0.5,0.5)
    SilentFOVCircle.BackgroundTransparency = 1
    local circleUI = Instance.new("UICorner")
    circleUI.CornerRadius = UDim.new(1,0)
    circleUI.Parent = SilentFOVCircle
    local border = Instance.new("UIStroke")
    border.Thickness = 2
    border.Transparency = 0.2
    border.Parent = SilentFOVCircle
    SilentFOVCircle.Parent = ScreenGui
end

HISTORY_SIZE = 6
PREDICT_FACTOR = 1.2
SKY_Y_THRESHOLD = 150
SMOOTH_ALPHA = 0.75
PositionHistory = {}
TracerSmoothedPos = Vector3.new()

RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
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

Players.PlayerRemoving:Connect(function(player) PositionHistory[player] = nil end)

function calculateVelocity(player)
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

function predictPosition(targetPart, hrp)
    if not targetPart then return Vector3.zero end
    local character = targetPart.Parent
    local player = character and Players:GetPlayerFromCharacter(character)
    if not player then return targetPart.Position end
    local velocity = calculateVelocity(player) or Vector3.zero
    local ping = (getPing and getPing()) or 0.1
    if ping < 0 then ping = 0.1 end
    return targetPart.Position + (velocity * ping * PREDICT_FACTOR)
end

function CallRemote(remote, ...)
    if not CounterTable then return end
    local args = {...}
    if remote.ClassName == "RemoteEvent" then
        CounterTable.event = CounterTable.event + 1
        remote:FireServer(CounterTable.event, unpack(args))
    elseif remote.ClassName == "RemoteFunction" then
        CounterTable.func = CounterTable.func + 1
        remote:InvokeServer(CounterTable.func, unpack(args))
    end
end

function getAimPositionAndPart(character) return nil, nil end
function isShotgun()
    if not Character then return false end
    for _, tool in ipairs(Character:GetChildren()) do
        if tool:IsA("Tool") then
            local ammoType = tool:GetAttribute("AmmoType")
            if ammoType == "shotgun" or ammoType == "shootgun" then return true end
        end
    end
    return false
end

oldFire = nil
if Remote and Remote.FireServer then
    local ok, res = pcall(function()
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
                        args[4] = CFrame.new(myPos, aimPos)
                        local pellets = {}
                        for i = 1,6 do
                            local spread = Vector3.new(math.random(-2,2)*0.03, math.random(-2,2)*0.03, math.random(-2,2)*0.03)
                            table.insert(pellets, {[1] = {Instance = head, Normal = Vector3.new(0,1,0), Position = aimPos + spread}})
                        end
                        args[5] = pellets
                    else
                        local blocked = isBehindWall(myPos, aimPos)
                        if blocked then
                            args[4] = CFrame.new(math.huge, math.huge, math.huge)
                        else
                            args[4] = CFrame.new(myPos, aimPos)
                        end
                        args[5] = {[1] = {[1] = {Instance = head, Normal = Vector3.new(0,1,0), Position = aimPos}}}
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
            return oldFire(self, unpack(args))
        end)
    end)
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        if SilentAimAttachEnabled then CurrentTarget = getClosestTarget() end
        CurrentTarget = (SilentAimEnabled or SilentAimAttachEnabled) and getClosestTarget() or nil
        local TracerTarget = getClosestTarget()
        if SilentFOVCircle then
            SilentFOVCircle.Visible = SilentAimEnabled
            if SilentAimEnabled then
                if isMobile then
                    SilentFOVCircle.Position = UDim2.fromScale(0.5,0.5)
                    SilentFOVCircle.Size = UDim2.fromOffset(FOVRadius*2, FOVRadius*2)
                    local border = SilentFOVCircle:FindFirstChildWhichIsA("UIStroke")
                    if border then border.Color = Color3.fromHSV((tick()*0.3)%1, 1, 1) end
                else
                    SilentFOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    SilentFOVCircle.Radius = FOVRadius
                    SilentFOVCircle.Color = Color3.fromHSV((tick()*0.3)%1, 1, 1)
                end
            end
        end
        if TracerTarget and TracerTarget.Character then
            local character = TracerTarget.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local targetPart = (SelectedAimPart == "HumanoidRootPart") and character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
            if humanoid and humanoid.Health > 0 and targetPart then
                local centerScreenPos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                local newPos = targetPart.Position
                TracerSmoothedPos = TracerSmoothedPos:Lerp(newPos, SMOOTH_ALPHA)
                local targetPos = TracerSmoothedPos
                local targetScreenPos, targetOnScreen = Camera:WorldToViewportPoint(targetPos)
                if targetOnScreen then
                    Tracer.Visible = true
                    Tracer.From = centerScreenPos
                    Tracer.To = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
                    Tracer.Color = Color3.fromRGB(255,50,50)
                    Tracer.Thickness = 1.3
                    if not TracerESP then
                        TracerESP = {}
                        for i=1,4 do
                            TracerESP[i] = Drawing.new("Line")
                            TracerESP[i].Color = Color3.fromRGB(255,255,255)
                            TracerESP[i].Thickness = 1.2
                            TracerESP[i].Visible = true
                        end
                    end
                    local headTopPos = Camera:WorldToViewportPoint(targetPart.Position + Vector3.new(0,0.5,0))
                    local headBottomPos = Camera:WorldToViewportPoint(targetPart.Position - Vector3.new(0,0.5,0))
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
                    TracerESP[1].From, TracerESP[1].To = top, right
                    TracerESP[2].From, TracerESP[2].To = right, bottom
                    TracerESP[3].From, TracerESP[3].To = bottom, left
                    TracerESP[4].From, TracerESP[4].To = left, top
                    for i=1,4 do TracerESP[i].Visible = true end
                else
                    Tracer.Visible = false
                    if TracerESP then for i=1,4 do TracerESP[i].Visible = false end end
                end
            else
                Tracer.Visible = false
                if TracerESP then for i=1,4 do TracerESP[i].Visible = false end end
            end
        else
            Tracer.Visible = false
            if TracerESP then for i=1,4 do TracerESP[i].Visible = false end end
            TracerSmoothedPos = Vector3.new()
        end
        if FlyEnabled and isFlyingUp and HumanoidRootPart then
            local v = HumanoidRootPart.Velocity
            HumanoidRootPart.Velocity = Vector3.new(v.X, floatPower, v.Z)
        end
        if teleportActive and lockedY and HumanoidRootPart then
            local currentPos = HumanoidRootPart.Position
            if math.abs(currentPos.Y - lockedY) > 0.1 then
                HumanoidRootPart.CFrame = CFrame.new(currentPos.X, lockedY, currentPos.Z)
            end
        end
    end)
end)

LocalPlayer.CharacterAdded:Connect(function(newChar) Character = newChar end)

RunService.Heartbeat:Connect(function()
    if getgenv().Sky and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local Root = LocalPlayer.Character.HumanoidRootPart
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
    if not enabled then return end
    if isDowned() then
        local hrp = getHRP()
        if hrp and not undergroundBaseCFrame then teleportUnderground() end
        flickerAndMove()
    else
        if undergroundBaseCFrame then
            local hrp = getHRP()
            if hrp then hrp.CFrame = undergroundBaseCFrame + Vector3.new(0, -DROP_DEPTH, 0) end
        end
        undergroundBaseCFrame = nil
        flickering = false
    end
end)

RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    end
    pcall(CheckAndPickup)
end)

ContextActionService:BindAction("FlyUp", function(actionName, inputState, inputObject)
    if not FlyEnabled then return Enum.ContextActionResult.Pass end
    local isJumpPressed = false
    if inputObject.UserInputType == Enum.UserInputType.Keyboard and inputObject.KeyCode == Enum.KeyCode.Space then isJumpPressed = true end
    if inputObject.UserInputType == Enum.UserInputType.Touch then isJumpPressed = true end
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

RunService.RenderStepped:Connect(function(deltaTime)
    if FlyEnabled and isFlyingUp then
        HumanoidRootPart.Velocity = Vector3.new(HumanoidRootPart.Velocity.X, floatPower, HumanoidRootPart.Velocity.Z)
    end
end)

-- hit jump
local player = game.Players.LocalPlayer
local jumpPowerEnabled = true
local jumpConn_HJ = nil

local function setupHighJump(char)
    if not jumpPowerEnabled then return end
    local humanoid = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    humanoid.UseJumpPower = true
    humanoid.JumpPower = 60
    
    if jumpConn_HJ then
        pcall(function() jumpConn_HJ:Disconnect() end)
    end
    
    jumpConn_HJ = game:GetService("UserInputService").JumpRequest:Connect(function()
        if not jumpPowerEnabled then return end
        if hrp and hrp.Parent then
            local look = hrp.CFrame.LookVector
            hrp.Velocity = look * 80 + Vector3.new(0, 100, 0)
        end
    end)
end

player.CharacterAdded:Connect(function(char)
    wait(0.5)
    if jumpPowerEnabled then
        setupHighJump(char)
    end
end)

if player.Character then
    setupHighJump(player.Character)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if flyJumpConnection then flyJumpConnection:Disconnect() end
    flyJumpConnection = hum:GetPropertyChangedSignal("Jumping"):Connect(function()
        if FlyEnabled and hum.Jumping then isFlyingUp = true else isFlyingUp = false end
    end)
end)

LocalPlayer.CharacterAdded:Connect(setupCharacter)
if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G and WindUI and Window then
        if Window.Toggle then Window:Toggle() elseif Window.SetVisible then Window:SetVisible(not Window.Visible) end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Z and featureEnabled then toggleTeleport() end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    lockedY = nil
    teleportActive = false
    lockYPosition()
end)

lockYPosition()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    running = false
    task.wait(0.1)
    StartAutoAttack()
end)

-- ========== SKIP CRATE SYSTEM (ใหม่) ==========


local CrateController = require(ReplicatedStorage.Modules.Game.CrateSystem.Crate)
local skipLoopRunning = false

local function SkipCurrentCrates()
    pcall(function()
        for _, crate in pairs(CrateController.class.objects) do
            crate.states.open.set(true)
            CrateController.skipping.set(true)
        end
    end)
end

-- เริ่ม loop skip ตลอดไป
local function StartInfiniteSkip()
    if skipLoopRunning then return end
    skipLoopRunning = true
    task.spawn(function()
        while skipLoopRunning do
            SkipCurrentCrates()
            task.wait(0.05)
        end
    end)
    if WindUI then WindUI:Notify({Title = "♾️ Skip Crate ตลอดไป", Duration = 2}) end
end

-- ปุ่ม: กดแล้วทำงานตลอด ไม่มีปิด (ต้องรีสตาร์ทสคริปต์หรือออกเกมถึงจะหยุด)



StartAutoAttack()
for _, category in ipairs({"gun","melee","throwable","consumable","farming","misc","rod","fish"}) do
    registerItems(ReplicatedStorage:WaitForChild("Items")[category])
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESPEnabled then wait(0.2) createBillboardForPlayer(player) end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if BillboardCache[player] then
        BillboardCache[player]:Destroy()
        BillboardCache[player] = nil
    end
end)

for _, p in ipairs(Players:GetPlayers()) do setupFastFinishForPlayer(p) end
Players.PlayerAdded:Connect(setupFastFinishForPlayer)

task.spawn(function()
    while true do
        task.wait(scanInterval)
        if fastFinishEnabled then
            for _, prompt in ipairs(findFinishPrompts()) do
                task.spawn(function() tryHoldPrompt(prompt, holdTime) end)
            end
        end
    end
end)

SetupAutoSkip()
ReplicatedStorage.ChildAdded:Connect(function(child) if child.Name == "Remotes" then SetupAutoSkip() end end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if highlightEnabled then updateHighlight(player) end
        if espPlayers[player] and espPlayers[player].drawings then
            local nameText = espPlayers[player].drawings[1]
            nameText.Color = isPlayerExcluded(player.Name) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if espPlayers[player] then
        for _, obj in pairs(espPlayers[player].drawings) do
            if obj and obj.Destroy then pcall(function() obj:Destroy() end)
            elseif typeof(obj) == "table" and obj.Visible ~= nil then obj.Visible = false end
        end
        if espPlayers[player].conn then pcall(function() espPlayers[player].conn:Disconnect() end) end
        espPlayers[player] = nil
    end
end)

task.spawn(function()
    while task.wait(1) do
        if highlightEnabled then
            for _, player in pairs(Players:GetPlayers()) do updateHighlight(player) end
        end
    end
end)

loadESP()

-- UI Tabs
local Tab = Window:Tab({Title = "COMBAT:", Icon = "crosshair"})
Tab:Section({Title = "GUN:"})
local SilentToggle = Tab:Toggle({Title = "Silent Aim", Default = false, Callback = function(state) SilentAimEnabled = state; CurrentTarget = nil end})
myConfig:Register("SilentAim", SilentToggle)
local AttachToggle = Tab:Toggle({Title = "Red Line Lock", Default = false, Callback = function(state) SilentAimAttachEnabled = state; CurrentTarget = nil end})
myConfig:Register("SilentAimAttach", AttachToggle)
local FOVSlider = Tab:Slider({Title = "FOV: ", Step = 1, Value = {Min=20, Max=800, Default=FOVRadius}, Callback = function(value) FOVRadius = tonumber(value) or 120 end})
myConfig:Register("FOVRadius", FOVSlider)
local FriendsInput = Tab:Input({Title = "Safe Friend", Desc = "", Value = "", InputIcon = "shield-check", Type = "Input", Placeholder = "", Callback = function(input)
    excludedPlayerNames = {}
    for name in string.gmatch(input, "%S+") do table.insert(excludedPlayerNames, name) end
    for _, player in pairs(Players:GetPlayers()) do
        if espPlayers[player] and espPlayers[player].drawings then
            local nameText = espPlayers[player].drawings[1]
            nameText.Color = isPlayerExcluded(player.Name) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
        end
    end
end})
myConfig:Register("FriendsList", FriendsInput)
pcall(function() Tab:Divider() end)

local Tab_mods = Window:Tab({Title = "WEAPON:", Icon = "layers"})
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

function isGunTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    return GunsFolder:FindFirstChild(tool.Name) ~= nil or tool.Name:match("Gun") or tool:FindFirstChild("Handle")
end

function forceSetAttribute(tool, attrName, value)
    if tool and tool.SetAttribute then pcall(function() tool:SetAttribute(attrName, value) end) end
end

function debugPrintAttributes(tool)
    local attrs = tool:GetAttributes()
    local keys = {}
    for k,v in pairs(attrs) do table.insert(keys, k) end
    table.sort(keys)
end

function applyGodGun(tool)
    if not tool or not isGunTool(tool) then return end
    pcall(function()
        tool:SetAttribute("fire_rate", getgenv().FireRateValue)
        tool:SetAttribute("accuracy", getgenv().AccuracyValue)
        tool:SetAttribute("Recoil", getgenv().RecoilValue)
        tool:SetAttribute("Durability", getgenv().Durability)
        tool:SetAttribute("automatic", getgenv().AutoValue)
    end)
    task.spawn(function()
        for attempt=1,20 do
            local attrNames = tool:GetAttributes()
            local keys = {}
            for k in pairs(attrNames) do table.insert(keys, k) end
            table.sort(keys)
            if #keys >= 11 then
                local targetKey = keys[11]
                for i=1,5 do forceSetAttribute(tool, targetKey, true); task.wait(0.01) end
            end
            task.wait(0.1)
        end
    end)
    task.wait(0.5)
    debugPrintAttributes(tool)
end

RunService.Heartbeat:Connect(function()
    if not getgenv().GunModsAutoApply then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and isGunTool(tool) then pcall(applyGodGun, tool) end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    repeat
        task.wait(0.1)
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and isGunTool(tool) then task.spawn(applyGodGun, tool) end
        end
    until not getgenv().GunModsAutoApply
end)

LocalPlayer.Character.ChildAdded:Connect(function(child)
    if child:IsA("Tool") and getgenv().GunModsAutoApply then
        task.wait(0.2)
        applyGodGun(child)
    end
end)

Tab_mods:Slider({Title = "Fire Rate", Step = 10, Value = {Min=100, Max=3000, Default=1000}, Callback = function(v) getgenv().FireRateValue = v end})
Tab_mods:Slider({Title = "Accuracy", Step = 0.01, Value = {Min=0, Max=1, Default=1}, Callback = function(v) getgenv().AccuracyValue = v end})
Tab_mods:Slider({Title = "Recoil", Step = 0.1, Value = {Min=0, Max=10, Default=0}, Callback = function(v) getgenv().RecoilValue = v end})
Tab_mods:Slider({Title = "Reload Time", Step = 0.1, Value = {Min=0.1, Max=10, Default=0.1}, Callback = function(v) getgenv().ReloadValue = v end})
Tab_mods:Toggle({Title = "Automatic", Icon = "check", Type = "Checkbox", Value = false, Callback = function(v)
    getgenv().automatic = v
    getgenv().GunModsAutoApply = v
    if v and WindUI then WindUI:Notify({Title = "✅ Auto Modify", Duration = 2}) end
end})

Tab_mods:Section({Title = "COMBAT"})

function modifyFists(tool, enable)
    if tool then
        local attributes = tool:GetAttributes()
        local keys = {}
        for name,_ in pairs(attributes) do table.insert(keys, name) end
        table.sort(keys)
        if #keys >= 7 then
            local attr6 = keys[6]
            local attr7 = keys[7]
            if enable then
                if OriginalValues[attr6] == nil then OriginalValues[attr6] = tool:GetAttribute(attr6) end
                if OriginalValues[attr7] == nil then OriginalValues[attr7] = tool:GetAttribute(attr7) end
                tool:SetAttribute(attr6, 360)
                tool:SetAttribute(attr7, 20)
            else
                if OriginalValues[attr6] then tool:SetAttribute(attr6, OriginalValues[attr6]) end
                if OriginalValues[attr7] then tool:SetAttribute(attr7, OriginalValues[attr7]) end
            end
        end
    end
end

local meleeNames = {}
for _, v in ipairs(MeleeFolder:GetChildren()) do table.insert(meleeNames, v.Name) end

function isMeleeTool(tool)
    if not tool:IsA("Tool") then return false end
    if tool.Name == "Fists" then return true end
    for _, name in ipairs(meleeNames) do if tool.Name == name then return true end end
    return false
end

function checkAndModifyFists()
    local Character = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not Character or not backpack then return end
    local tools = {}
    for _, t in ipairs(Character:GetChildren()) do if isMeleeTool(t) then table.insert(tools, t) end end
    for _, t in ipairs(backpack:GetChildren()) do if isMeleeTool(t) then table.insert(tools, t) end end
    for _, tool in ipairs(tools) do modifyFists(tool, FistsBuffEnabled) end
end

RunService.Heartbeat:Connect(function() if FistsBuffEnabled then checkAndModifyFists() end end)
LocalPlayer.CharacterAdded:Connect(function() task.wait(1); if FistsBuffEnabled then checkAndModifyFists() end end)

myConfig:Register("Fists Modifier", Tab_mods:Toggle({Title = "Melee Aura", Desc = "WideFists", Default = false, Callback = function(Value) FistsBuffEnabled = Value; checkAndModifyFists() end}))

local autoAttackToggle = Tab_mods:Toggle({Title = "Auto Attack", Default = false, Callback = function(state) hookEnabled = state end})
myConfig:Register("AutoAttack_Enabled", autoAttackToggle)

local Tab_ESP = Window:Tab({Title = "ESP:", Icon = "eye"})
Tab_ESP:Section({Title = "Visual:"})
local ItemsESPToggle = Tab_ESP:Toggle({Title = "Inventory Viewer", Default = false, Callback = function(state)
    ESPEnabled = state
    if state then
        for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then createBillboardForPlayer(p) end end
        ESPConnection = RunService.Heartbeat:Connect(function() for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then createBillboardForPlayer(p) end end end)
        if WindUI then WindUI:Notify({Title = "✅ ESP Items Enabled", Duration = 3}) end
    else
        if ESPConnection then ESPConnection:Disconnect(); ESPConnection = nil end
        for _, billboard in pairs(BillboardCache) do billboard:Destroy() end
        BillboardCache = {}
        if WindUI then WindUI:Notify({Title = "❌ ESP Items Disabled", Duration = 3}) end
    end
end})
myConfig:Register("ItemsESP", ItemsESPToggle)
local NameESPToggle = Tab_ESP:Toggle({Title = "Name", Default = false, Callback = function(state) nameESPEnabled = state end})
myConfig:Register("NameESP", NameESPToggle)
local HealthESPToggle = Tab_ESP:Toggle({Title = "Health", Default = false, Callback = function(state) healthESPEnabled = state end})
myConfig:Register("HealthESP", HealthESPToggle)
local DistanceESPToggle = Tab_ESP:Toggle({Title = "Distance", Default = false, Callback = function(state) distanceESPEnabled = state end})
myConfig:Register("DistanceESP", DistanceESPToggle)

local HighlightToggle = Tab_ESP:Toggle({Title = "Highlight", Default = false, Callback = function(state) highlightEnabled = state; for _, player in pairs(game.Players:GetPlayers()) do updateHighlight(player) end end})
myConfig:Register("HighlightESP", HighlightToggle)

function updateHighlight(player)
    if player == game.Players.LocalPlayer then return end
    if not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if playerHighlights[player] then playerHighlights[player]:Destroy(); playerHighlights[player] = nil end
    if highlightEnabled then
        local highlight = Instance.new("Highlight")
        highlight.Name = "PlayerHighlight"
        highlight.Adornee = player.Character
        highlight.FillColor = Color3.fromRGB(0,170,255)
        highlight.OutlineColor = Color3.fromRGB(0,170,255)
        highlight.Parent = workspace
        playerHighlights[player] = highlight
    end
end

game.Players.PlayerAdded:Connect(function(player) player.CharacterAdded:Connect(function() task.wait(0.1); updateHighlight(player) end) end)
game.Players.PlayerRemoving:Connect(function(player) if playerHighlights[player] then playerHighlights[player]:Destroy(); playerHighlights[player] = nil end end)
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        player.CharacterAdded:Connect(function() task.wait(0.1); updateHighlight(player) end)
        updateHighlight(player)
    end
end

local Tab_Character = Window:Tab({Title = "CHARACTER:", Icon = "user"})
Tab_Character:Section({Title = "CHARACTER:"})
local WalkSpeedToggle = Tab_Character:Toggle({Title = "Walk Speed", Default = false, Callback = function(state) walkSpeedEnabled = state end})
myConfig:Register("WalkSpeed", WalkSpeedToggle)
local SpeedSlider = Tab_Character:Slider({Title = "Speed Multiplier", Step = 0.5, Value = {Min=1, Max=5, Default=2}, Callback = function(value) speedValue = value * 0.05 end})
myConfig:Register("SpeedMultiplier", SpeedSlider)
local JumpPowerToggle = Tab_Character:Toggle({Title = "Jump Power (Fly)", Default = false, Callback = function(state) FlyEnabled = state; if not FlyEnabled then isFlyingUp = false end end})
myConfig:Register("JumpPower", JumpPowerToggle)

Net = {}
function Net.send(...)
    local args = {...}
    CounterTable.event = CounterTable.event + 1
    pcall(function() Remotes.Send:FireServer(CounterTable.event, unpack(args)) end)
end

local AutoSprintToggle = Tab_Character:Toggle({Title = "Infinite Stamina", Default = false, Callback = function(state)
    AutoSprintEnabled = state
    if AutoSprintEnabled then
        local success, SprintModule = pcall(function() return require(ReplicatedStorage.Modules.Game.Sprint) end)
        if success and SprintModule then
            local consume_stamina = SprintModule.consume_stamina
            local SprintBar = getupvalue(consume_stamina, 2).sprint_bar
            if SprintBar then
                local Old = SprintBar.update
                SprintBar.update = function(...) return Old(function() return 1 end) end
                getgenv().OriginalSprintUpdate = Old
                getgenv().AutoSprintLoop = task.spawn(function()
                    while AutoSprintEnabled do
                        pcall(function() Net.send("set_sprinting_1", true); task.wait(0.5); Net.send("set_sprinting_1", false) end)
                        task.wait(0.1)
                    end
                    pcall(function() Net.send("set_sprinting_1", false) end)
                end)
                if WindUI then WindUI:Notify({Title = "✅ INF STAMINA", Duration = 3}) end
            else
                AutoSprintEnabled = false
                AutoSprintToggle:Set(false)
            end
        else
            AutoSprintEnabled = false
            AutoSprintToggle:Set(false)
        end
    else
        if getgenv().AutoSprintLoop then task.cancel(getgenv().AutoSprintLoop); getgenv().AutoSprintLoop = nil end
        pcall(function() Net.send("set_sprinting_1", false) end)
        local success, SprintModule = pcall(function() return require(ReplicatedStorage.Modules.Game.Sprint) end)
        if success and SprintModule then
            local consume_stamina = SprintModule.consume_stamina
            local SprintBar = getupvalue(consume_stamina, 2).sprint_bar
            if SprintBar and getgenv().OriginalSprintUpdate then
                SprintBar.update = getgenv().OriginalSprintUpdate
                getgenv().OriginalSprintUpdate = nil
            end
        end
        if WindUI then WindUI:Notify({Title = "❌ Auto Sprint Disabled", Duration = 3}) end
    end
end})
myConfig:Register("AutoSprint", AutoSprintToggle)

local AntiLockToggle = Tab_Character:Toggle({Title = "Anti Lock", Default = false, Callback = function(state) getgenv().Sky = state; if state then getgenv().SkyAmount = 1500 end end})
myConfig:Register("AntiLock", AntiLockToggle)

local AntiKillToggle = Tab_Character:Toggle({Title = "Anti Kill", Default = false, Callback = function(state) enabled = state; if state then if WindUI then WindUI:Notify({Title = " Anti Kill Enabled", Duration = 3}) end else if WindUI then WindUI:Notify({Title = "❌ Anti Kill Disabled", Duration = 3}) end end end})
myConfig:Register("AntiKill", AntiKillToggle)

pcall(function() if Tab_Character and typeof(Tab_Character.Divider) == "function" then Tab_Character:Divider() end end)
pcall(function() if Tab_Character and typeof(Tab_Character.Section) == "function" then Tab_Character:Section({Title = "Att:"}) end end)

local PickupToggle = Tab_Character:Toggle({Title = "Pickup items", Default = false, Callback = function(state) sucking = state end})
myConfig:Register("PickupItems", PickupToggle)

local AntiRagdollToggle = Tab_Character:Toggle({Title = "Anti Ragdoll", Default = false, Callback = function(state)
    local _AntiRagdollEnabled = state
    if not _AntiRagdollEnabled then return end
    pcall(function()
        local function findCounter()
            for _, obj in ipairs(getgc and getgc(true) or {}) do
                if typeof(obj) == "table" and rawget(obj, "event") and rawget(obj, "func") then return obj end
            end
        end
        local CounterTable = findCounter()
        if not CounterTable then return end
        local function sendRemoteAction(action)
            CounterTable.event = (CounterTable.event or 0) + 1
            local SendRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Send")
            SendRemote:FireServer(CounterTable.event, action)
        end
        task.spawn(function()
            while _AntiRagdollEnabled do
                sendRemoteAction("end_ragdoll_early")
                task.wait(0.3)
                if not _AntiRagdollEnabled then break end
                sendRemoteAction("clear_ragdoll")
                task.wait(0.3)
            end
        end)
    end)
end})
myConfig:Register("AntiRagdoll", AntiRagdollToggle)

local HideNameToggle = Tab_Character:Toggle({Title = "Hide Name", Default = false, Callback = function(state)
    pcall(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local gui = hrp:FindFirstChild("CharacterBillboardGui")
        if gui then
            local nameLabel = gui:FindFirstChild("PlayerName")
            if nameLabel and nameLabel:IsA("TextLabel") then nameLabel.Visible = not state end
        end
    end)
end})
myConfig:Register("HideName", HideNameToggle)

local AutoRespawnToggle = Tab_Character:Toggle({Title = "Auto Respawn", Default = false, Callback = function(state)
    local _AutoRespawnEnabled = state
    if not _AutoRespawnEnabled then return end
    pcall(function()
        local function findCounter()
            for _, obj in ipairs(getgc and getgc(true) or {}) do
                if typeof(obj) == "table" and rawget(obj, "event") and rawget(obj, "func") then return obj end
            end
        end
        local CounterTable = findCounter()
        if not CounterTable then return end
        local function sendRemoteAction(action)
            CounterTable.event = (CounterTable.event or 0) + 1
            local SendRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Send")
            SendRemote:FireServer(CounterTable.event, action)
        end
        task.spawn(function()
            while _AutoRespawnEnabled do
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then
                    task.wait(6)
                    if _AutoRespawnEnabled then sendRemoteAction("death_screen_request_respawn") end
                end
                task.wait(0.5)
            end
        end)
    end)
end})
myConfig:Register("AutoRespawn", AutoRespawnToggle)

Tab_Character:Divider()
Tab_Character:Section({Title = "PC HOLD (Z)"})

local SnapToggle = Tab_Character:Toggle({Title = "Snap Under Map", Default = false, Callback = function(state)
    featureEnabled = state
    if featureEnabled then
        clickCount = clickCount + 1
        if clickCount < 2 then return end
        startY = HumanoidRootPart and HumanoidRootPart.Position.Y or nil
        teleportActive = true
        performTeleport()
    else
        teleportActive = false
        lockedY = nil
        startY = nil
    end
end})
myConfig:Register("SnapUnderMap", SnapToggle)

local SnapSlider = Tab_Character:Slider({Title = "Snap:", Step = 1, Value = {Min=1, Max=100, Default=10}, Callback = function(value)
    maxHeight = value
    if teleportActive and HumanoidRootPart and startY then
        local bottomPos = Vector3.new(HumanoidRootPart.Position.X, startY - maxHeight, HumanoidRootPart.Position.Z)
        HumanoidRootPart.CFrame = CFrame.new(bottomPos)
        lockedY = bottomPos.Y
    end
end})
myConfig:Register("SnapHeight", SnapSlider)

-- ============================================================
-- TAB PLAYER (Auto Finish + Bring Part)
-- ============================================================
-- ============================================================
-- TAB PLAYER (Auto Finish + Bring Player แบบ Input + Toggle)
-- ============================================================
-- ============================================================
-- TAB PLAYER (รวม Bring Part)
-- ============================================================
local Tab_player = Window:Tab({Title = "PLAYER:", Icon = "person-standing"})
Tab_player:Section({Title = "PLAYER:"})

local AutoFinnishToggle = Tab_player:Toggle({Title = "Auto Finish", Default = false, Callback = function(state)
    fastFinishEnabled = state
    if state then
        applyToAll()
        if WindUI then WindUI:Notify({Title = "✅ Auto Finish Enabled", Duration = 3}) end
    else
        if WindUI then WindUI:Notify({Title = "❌ Auto Disabled", Duration = 3}) end
    end
end})
myConfig:Register("AutoFinnish", AutoFinnishToggle)

Tab_player:Divider()
Tab_player:Section({Title = "BRING PART"})
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local function findCounterTable()
    if not getgc then return nil end
    for _, obj in ipairs(getgc(true)) do
        if typeof(obj) == "table" and rawget(obj, "event") and rawget(obj, "func") then
            return obj
        end
    end
    return nil
end

-- ===== ระบบดึงผู้เล่น (Bring Part) =====
local bringNameInput = ""
local BringActive = false
local BringConnection = nil
local selectedBringPlayer = ""

-- สร้าง Attachment สำหรับดึงตัว
local _bringFolder = Instance.new("Folder", workspace)
_bringFolder.Name = "BringSystem"
local _bringCorePart = Instance.new("Part", _bringFolder)
_bringCorePart.Name = "BringCore"
_bringCorePart.Anchored = true
_bringCorePart.CanCollide = false
_bringCorePart.Transparency = 1
local _bringAttachment1 = Instance.new("Attachment", _bringCorePart)
_bringAttachment1.Name = "BringAttachment"

-- ฟังก์ชัน Force Part (ป้องกันการกระเด้ง)
local function _forcePart(v)
    if v:IsA("BasePart") and not v.Anchored and not v.Parent:FindFirstChildOfClass("Humanoid") and
       not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then
        for _, obj in ipairs(v:GetChildren()) do
            if obj:IsA("BodyMover") or obj:IsA("RocketPropulsion") then obj:Destroy() end
        end
        for _, junk in ipairs({"Attachment", "AlignPosition", "Torque"}) do
            local f = v:FindFirstChild(junk)
            if f then f:Destroy() end
        end
        v.CanCollide = false
        local Torque = Instance.new("Torque", v)
        local AlignPos = Instance.new("AlignPosition", v)
        local Att2 = Instance.new("Attachment", v)
        Torque.Torque = Vector3.new(100000, 100000, 100000)
        Torque.Attachment0 = Att2
        AlignPos.MaxForce = math.huge
        AlignPos.MaxVelocity = math.huge
        AlignPos.Responsiveness = 9999
        AlignPos.Attachment0 = Att2
        AlignPos.Attachment1 = _bringAttachment1
    end
end

-- ฟังก์ชันหาผู้เล่น
local function getPlayer(name)
    name = string.lower(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), name) or string.find(string.lower(p.DisplayName), name) then
            return p
        end
    end
    return nil
end

-- ฟังก์ชันเริ่ม/หยุดดึง
local function toggleBringPlayer(playerName, state)
    BringActive = state
    if BringConnection then BringConnection:Disconnect() BringConnection = nil end
    if not state then return end
    
    local target = getPlayer(playerName)
    if not target then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Bring", 
            Text = "ไม่พบผู้เล่น: "..playerName, 
            Duration = 3
        })
        BringActive = false
        return
    end
    
    local char = target.Character or target.CharacterAdded:Wait()
    local targetRoot = char:WaitForChild("HumanoidRootPart")
    
    -- Force Part ทุกอัน
    for _, v in ipairs(workspace:GetDescendants()) do pcall(_forcePart, v) end
    BringConnection = workspace.DescendantAdded:Connect(function(v) pcall(_forcePart, v) end)
    
    -- ลูปดึงผู้เล่น
    task.spawn(function()
        while BringActive do
            if targetRoot and targetRoot.Parent then
                _bringAttachment1.WorldCFrame = targetRoot.CFrame
            end
            task.wait()
        end
    end)
end

-- ฟังก์ชันดึงชื่อผู้เล่นทั้งหมด
local function getPlayerNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    if #names == 0 then table.insert(names, "ไม่มีผู้เล่นอื่น") end
    return names
end


local bringDropdown = nil
local bringActive = false

-- Dropdown เลือกผู้เล่น
bringDropdown = Tab_player:Dropdown({
    Title = "เลือกผู้เล่น",
    Values = getPlayerNames(),
    Value = getPlayerNames()[1] or "ไม่มีผู้เล่นอื่น",
    Multi = false,
    Callback = function(selected)
        if type(selected) == "string" and selected ~= "ไม่มีผู้เล่นอื่น" then
            selectedBringPlayer = selected
        elseif selected == "ไม่มีผู้เล่นอื่น" then
            selectedBringPlayer = ""
        end
    end
})

-- ปุ่มรีเฟรชรายชื่อ
Tab_player:Button({
    Title = "รีเฟรชรายชื่อ",
    Desc = "อัปเดตรายชื่อผู้เล่นในเซิร์ฟเวอร์",
    Callback = function()
        local names = getPlayerNames()
        bringDropdown:Refresh(names, true)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Bring", 
            Text = "อัปเดตรายชื่อเรียบร้อย ("..#names.." คน)", 
            Duration = 1
        })
    end
})

Tab_player:Divider()

-- Toggle สำหรับดึงผู้เล่น
local bringToggle = Tab_player:Toggle({
    Title = "Bring Player (ค้างไว้)",
    Desc = "ดึงผู้เล่นที่เลือกมาหาคุณตลอดเวลา",
    Value = false,
    Callback = function(state)
        if state then
            if not selectedBringPlayer or selectedBringPlayer == "" or selectedBringPlayer == "ไม่มีผู้เล่นอื่น" then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Bring", 
                    Text = "กรุณาเลือกผู้เล่นก่อน", 
                    Duration = 2
                })
                bringToggle:Set(false)
                return
            end
            bringActive = true
            toggleBringPlayer(selectedBringPlayer, true)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Bring", 
                Text = "กำลังดึง "..selectedBringPlayer, 
                Duration = 2
            })
        else
            bringActive = false
            toggleBringPlayer(selectedBringPlayer, false)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Bring", 
                Text = "หยุดดึง "..selectedBringPlayer, 
                Duration = 2
            })
        end
    end
})


Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    pcall(function() bringDropdown:Refresh(getPlayerNames(), true) end)
end)

Players.PlayerRemoving:Connect(function(player)
    task.wait(0.5)
    pcall(function() bringDropdown:Refresh(getPlayerNames(), true) end)
    if bringActive and selectedBringPlayer == player.Name then
        bringToggle:Set(false)
        toggleBringPlayer(selectedBringPlayer, false)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Bring", 
            Text = "ผู้เล่นออกจากเกม หยุดดึง", 
            Duration = 2
        })
    end
end)

Tab_player:Divider()


-- ============================================================
-- REMOTE TAB (Ammo Crate)
-- ============================================================
local Tab_remote = Window:Tab({Title = "REMOTE:", Icon = "satellite-dish"})
Tab_remote:Section({Title = "AMMO CRATE CONTROLLER"})

local function getCrateOptions()
    local map = workspace:FindFirstChild("Map")
    if not map then return nil end
    local tiles = map:FindFirstChild("Tiles")
    if not tiles then return nil end
    local gunShopTile = tiles:FindFirstChild("GunShopTile")
    if not gunShopTile then return nil end
    local patriotWeapons = gunShopTile:FindFirstChild("PatriotWeapons")
    if not patriotWeapons then return nil end
    local interior = patriotWeapons:FindFirstChild("Interior")
    if not interior then return nil end
    local crates = interior:FindFirstChild("Crates")
    if not crates then return nil end
    local ammoCrate = crates:FindFirstChild("Ammo Crate")
    if not ammoCrate then return nil end
    return ammoCrate:FindFirstChild("CrateOptions")
end

local function openCrateWithType(bulletType)
    local crateOptions = getCrateOptions()
    if not crateOptions then
        if WindUI then WindUI:Notify({Title = "❌ ไม่พบ Ammo Crate", Duration = 2}) end
        return
    end
    local targetItem = crateOptions:FindFirstChild(bulletType)
    if not targetItem then
        if WindUI then WindUI:Notify({Title = "❌ ไม่มี " .. bulletType, Duration = 2}) end
        return
    end
    local result = NetGet("open_crate", targetItem, "money")
    if result then
        if WindUI then WindUI:Notify({Title = "🔫 เปิด " .. bulletType .. " สำเร็จ", Duration = 2}) end
    else
        if WindUI then WindUI:Notify({Title = "❌ เปิดไม่สำเร็จ", Duration = 2}) end
    end
end

local selectedBulletType = "Pistol"
local bulletDropdown = Tab_remote:Dropdown({
    Title = "เลือกประเภทกระสุน",
    Values = {"Pistol", "Rifle", "Shotgun", "Random"},
    Value = "Pistol",
    Multi = false,
    Callback = function(selected)
        selectedBulletType = selected
    end
})

Tab_remote:Button({
    Title = "เปิด Ammo Crate",
    Desc = "ใช้ประเภทกระสุนที่เลือก",
    Callback = function()
        local useType = selectedBulletType
        if useType == "Random" then
            local options = {"Pistol", "Rifle", "Shotgun"}
            useType = options[math.random(1, #options)]
            if WindUI then WindUI:Notify({Title = "🎲 สุ่มได้ " .. useType, Duration = 1}) end
        end
        openCrateWithType(useType)
    end
})

-- ============================================================
-- BUY TAB
-- ============================================================
local Tab_buyer = Window:Tab({Title = "BUY:", Icon = "shopping-cart"})
Tab_buyer:Section({Title = "Bank"})

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local BankBalance = Tab_buyer:Button({Title = "🏦 Bank Balance", Desc = "N/A"})
local HandBalance = Tab_buyer:Button({Title = "💸 Hand Balance", Desc = "N/A"})

local function HandMoney()
    local txt = PlayerGui:FindFirstChild("TopRightHud") and PlayerGui.TopRightHud:FindFirstChild("Holder") and PlayerGui.TopRightHud.Holder:FindFirstChild("Frame") and PlayerGui.TopRightHud.Holder.Frame:FindFirstChild("MoneyTextLabel")
    if txt then
        return tonumber(txt.Text:match("%$(%d+)")) or 0
    end
    return 0
end

local function ATMMoney()
    for _, v in ipairs(PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") and string.find(v.Text, "Bank Balance") then
            return tonumber(v.Text:match("%$(%d+)")) or 0
        end
    end
    return 0
end

task.spawn(function()
    while task.wait(0.5) do
        BankBalance:SetDesc('<b><font color="#FFFFFF">$' .. (ATMMoney() or 0) .. "</font></b>")
        HandBalance:SetDesc('<b><font color="#FFFFFF">$' .. (HandMoney() or 0) .. "</font></b>")
    end
end)

Tab_buyer:Section({Title = "CRATE SYSTEM"})
Tab_buyer:Button({
    Title = "Skip Crates (ตลอดไป)",
    Callback = function()
        if not skipLoopRunning then
            StartInfiniteSkip()
        else
            if WindUI then WindUI:Notify({Title = "กำลังทำงานอยู่แล้ว", Duration = 2}) end
        end
    end
})

-- ============================================================
-- MISC TAB
-- ============================================================
local Tab_misc = Window:Tab({Title = "MISC:", Icon = "warehouse"})
Tab_misc:Section({Title = "INVISIBLE (DESYNC)"})
local InvisibleToggle = Tab_misc:Toggle({
    Title = "Invisible Mode (Desync)",
    Desc = "เปิดโหมดล่องหน",
    Default = false,
    Callback = function(state)
        desyncEnabled = state
        setDesync(state)
    end
})

myConfig:Register("InvisibleMode", InvisibleToggle)

Tab_misc:Divider()
Tab_misc:Toggle({
    Title = "มองของบนพื้น",
    Default = groundItemsESPEnabled,
    Callback = function(state)
        groundItemsESPEnabled = state
        if not state then
            for _, d in pairs(item_drawings) do
                if d.circle then d.circle.Visible = false end
                if d.innerCircle then d.innerCircle.Visible = false end
                if d.name then d.name.Visible = false end
                if d.amount then d.amount.Visible = false end
                if d.highlight then d.highlight.Enabled = false end
            end
        end
    end
})

-- Server Hop
local placeId = game.PlaceId
Tab_misc:Input({
    Title = "Server Hop by ID",
    Value = "",
    InputIcon = "send",
    Type = "Input",
    Placeholder = "id server here!",
    Callback = function(input)
        if not input or input == "" then return end
        for id in string.gmatch(input, "[%w%-]+") do
            task.wait(0.5)
            pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, id, LocalPlayer) end)
        end
    end
})

Tab_misc:Button({Title = "Server Rejoin", Callback = function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end})

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
Tab_misc:Button({
    Title = "Server Hop",
    Callback = function()
        local PlaceId = 104715542330896
        local success, servers = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Desc&limit=100"))
        end)
        if success and servers and servers.data then
            local available = {}
            for _, s in ipairs(servers.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then table.insert(available, s) end
            end
            if #available > 0 then
                table.sort(available, function(a,b) return a.playing > b.playing end)
                TeleportService:TeleportToPlaceInstance(PlaceId, available[1].id, LocalPlayer)
            end
        end
    end
})

Tab_misc:Divider()
Tab_misc:Button({Title = "Claim All Quest", Callback = function()
    task.spawn(function()
        local function findCounter()
            if not getgc then return nil end
            for _, obj in ipairs(getgc(true)) do
                if type(obj) == "table" and rawget(obj, "event") and rawget(obj, "func") then return obj end
            end
            return nil
        end
        local ct = findCounter()
        if not ct then return end
        local GetRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Get")
        local questFrame = LocalPlayer.PlayerGui.Quests.QuestsHolder.QuestsScrollingFrame
        for _, child in ipairs(questFrame:GetChildren()) do
            ct.func = (ct.func or 0) + 1
            pcall(function() GetRemote:InvokeServer(ct.func, "claim_quest", child.Name) end)
            task.wait(0.2)
        end
    end)
end})

Tab_misc:Button({Title = "Boost FPS (ภาพกาก)", Callback = function()
    Bootsfps()
    if WindUI then WindUI:Notify({Title = "✅ Boost FPS ON", Duration = 2}) end
end})

Tab_misc:Section({Title = "Config Management"})
Tab_misc:Button({Title = "Save Config", Callback = function() if myConfig.Save then myConfig.Save(myConfig) end end})
Tab_misc:Button({Title = "Delete Config", Callback = function() if myConfig.Delete then myConfig.Delete(myConfig) end end})
if myConfig.Load then myConfig.Load(myConfig) end

-- ============================================================
-- ส่วน ESP ไอเทมบนพื้น (คงเดิม แต่ตัดให้สั้น)
-- ============================================================
function getRarityColor(item)
    if item.Name == "Money" then return Color3.fromRGB(0,255,0) end
    for _, folder in ipairs(ItemsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            local tool = folder:FindFirstChild(item.Name)
            if tool and tool:GetAttribute("RarityName") then
                return RARITY_COLORS[tool:GetAttribute("RarityName")] or Color3.fromRGB(255,255,255)
            end
        end
    end
    return Color3.fromRGB(255,255,255)
end

function cleanupItemDrawings()
    for item, d in pairs(item_drawings) do
        if not item or not item.Parent then
            pcall(function() if d.circle then d.circle:Remove() end end)
            pcall(function() if d.innerCircle then d.innerCircle:Remove() end end)
            pcall(function() if d.name then d.name:Remove() end end)
            pcall(function() if d.amount then d.amount:Remove() end end)
            pcall(function() if d.highlight then d.highlight:Destroy() end end)
            item_drawings[item] = nil
        end
    end
end

RunService.RenderStepped:Connect(function()
    cleanupItemDrawings()
    if not groundItemsESPEnabled then return end
    if not droppedItems then return end
    local hrp = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, d in pairs(item_drawings) do
        if d.circle then d.circle.Visible = false end
        if d.innerCircle then d.innerCircle.Visible = false end
        if d.name then d.name.Visible = false end
        if d.amount then d.amount.Visible = false end
        if d.highlight then d.highlight.Enabled = false end
    end
    local nearby = {}
    for _, item in ipairs(droppedItems:GetChildren()) do
        if item:IsA("Model") and item:FindFirstChild("PickUpZone") and not item:GetAttribute("Locked") then
            local pos = pcall(function() return item.PickUpZone.Position end) and item.PickUpZone.Position
            if pos then
                table.insert(nearby, {item=item, dist=(pos-hrp.Position).Magnitude})
            end
        end
    end
    table.sort(nearby, function(a,b) return a.dist < b.dist end)
    for i=1, math.min(20, #nearby) do
        local item = nearby[i].item
        local d = item_drawings[item]
        if not d then
            d = {
                circle = Drawing.new("Circle"),
                innerCircle = Drawing.new("Circle"),
                name = Drawing.new("Text"),
                amount = Drawing.new("Text")
            }
            d.circle.Thickness = 2; d.circle.Transparency = 0.7; d.circle.Filled = false
            d.innerCircle.Thickness = 2; d.innerCircle.Transparency = 1; d.innerCircle.Filled = true
            d.name.Outline = true; d.name.Center = true; d.name.Size = 16; d.name.Font = 4
            d.amount.Outline = true; d.amount.Center = true; d.amount.Size = 13
            item_drawings[item] = d
        end
        if not d.highlight or not d.highlight.Parent then
            local h = Instance.new("Highlight"); h.FillTransparency = 0.5; h.OutlineTransparency = 0.1; h.Adornee = item; h.Parent = item; d.highlight = h
        end
        local pos, on = Camera:WorldToViewportPoint(item.PickUpZone.Position)
        if on then
            local color = getRarityColor(item)
            local rad = math.clamp(BOX_SIZE_SCALE / pos.Z, 3, 6)
            d.highlight.FillColor = color; d.highlight.OutlineColor = color; d.highlight.Enabled = true
            d.circle.Position = Vector2.new(pos.X, pos.Y); d.circle.Radius = rad+5; d.circle.Color = color; d.circle.Visible = true
            d.innerCircle.Position = Vector2.new(pos.X, pos.Y); d.innerCircle.Radius = rad; d.innerCircle.Color = color; d.innerCircle.Visible = true
            d.name.Position = Vector2.new(pos.X, pos.Y - rad - 20); d.name.Text = item.Name; d.name.Color = color; d.name.Visible = true
            local amt = item:GetAttribute("Amount") or 1
            d.amount.Position = Vector2.new(pos.X, pos.Y + rad + 15); d.amount.Text = amt>1 and "["..amt.."]" or ""; d.amount.Visible = amt>1
        else
            d.circle.Visible = false; d.innerCircle.Visible = false; d.name.Visible = false; d.amount.Visible = false; if d.highlight then d.highlight.Enabled = false end
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if plr == Client then
        for _, d in pairs(item_drawings) do
            pcall(function() d.circle:Remove() end); pcall(function() d.innerCircle:Remove() end)
            pcall(function() d.name:Remove() end); pcall(function() d.amount:Remove() end)
            pcall(function() if d.highlight then d.highlight:Destroy() end end)
        end
        item_drawings = {}
    end
end)

-- ส่วน Bypass อื่น ๆ (lockTool, init, hookEmotes, etc.) - คงเดิม
function lockTool(tool)
    if tool and tool:IsA("Tool") then pcall(function() tool:SetAttribute("Locked", true) end) end
end
function setupBackpack(backpack)
    if not backpack then return end
    for _, tool in ipairs(backpack:GetChildren()) do lockTool(tool) end
    backpack.ChildAdded:Connect(lockTool)
end
function init()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then setupBackpack(backpack)
    else LocalPlayer.ChildAdded:Connect(function(c) if c:IsA("Backpack") then setupBackpack(c) end end) end
end
init()
LocalPlayer.CharacterAdded:Connect(function() task.wait(1); init() end)

task.wait(1)
function hookButton(button)
    if not button then return end
    if button:FindFirstChild("UnlocksAtText") then button.UnlocksAtText.Visible = false end
    if button:FindFirstChild("EmoteName") then button.EmoteName.Visible = true end
    CoreUI.on_click(button, function()
        local hum = CharModule.get_hum()
        if not hum or hum.Health <= 0 then return end
        if EmotesUI.current_emote_playing.get() == button then EmotesUI.current_emote_playing.set(nil)
        else EmotesUI.current_emote_playing.set(button) end
        task.wait(0.12)
        EmotesUI.enabled.set(false)
    end)
    EmotesUI.current_emote_playing.hook(function(current)
        if button:FindFirstChild("EmoteEquipped") then button.EmoteEquipped.Visible = (current == button) end
    end)
end
function hookAllEmotes()
    for _, emote in pairs(EmotesList) do
        local btn = CoreUI.get("EmoteTemplate").Parent:FindFirstChild(emote.name)
        hookButton(btn)
    end
end
hookAllEmotes()
LocalPlayer.CharacterAdded:Connect(function() task.wait(1); hookAllEmotes() end)

task.wait(2)
local CurrentCamera = nil
repeat task.wait() until workspace.CurrentCamera
CurrentCamera = workspace.CurrentCamera

local _old_tween = Util.tween
Util.tween = function(inst, info, props)
    if inst and inst:IsA("NumberValue") and props and props.Value ~= nil then
        inst.Value = props.Value
        return { Cancel = function() end }
    end
    return _old_tween(inst, info, props)
end

local success, sellBtn = pcall(function() return BuyPromptUI.get("SellPromptSellButton") end)
if success and sellBtn then
    local hold = sellBtn:FindFirstChild("HoldStroke", true)
    if hold then hold.Enabled = false end
    for _, v in pairs(sellBtn:GetDescendants()) do if v:IsA("NumberValue") then v.Value = 1 end end
end

print("Bypass complete")
