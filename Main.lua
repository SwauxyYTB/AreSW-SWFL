-- ══════════════════════════════════════════════════
-- CHARGEMENT LIBS
-- ══════════════════════════════════════════════════
local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()
local InterfaceManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
))()

-- ← REMPLACE PAR TON VRAI LIEN RAW GITHUB
local Core = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/SwauxyYTB/AreSW-SWFL/refs/heads/main/core.lua"
))()

local Options = Fluent.Options

local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local LocalPlayer        = Players.LocalPlayer
local PlayerGui          = LocalPlayer:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════════════
-- STYLE / DIMENSIONS
-- ══════════════════════════════════════════════════
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local vp       = workspace.CurrentCamera.ViewportSize
local WIN_W    = isMobile and math.clamp(math.floor(vp.X) - 16, 290, 370) or 580
local WIN_H    = isMobile and math.clamp(math.floor(vp.Y) - 70, 360, 500) or 460
local TAB_W    = isMobile and 72 or 160

local FL_BG      = Color3.fromRGB(45,  45,  48)
local FL_SIDEBAR = Color3.fromRGB(38,  38,  40)
local FL_ITEM    = Color3.fromRGB(55,  55,  58)
local FL_HOVER   = Color3.fromRGB(65,  65,  68)
local FL_BORDER  = Color3.fromRGB(70,  70,  73)
local FL_TXT     = Color3.fromRGB(205, 205, 205)
local FL_STXT    = Color3.fromRGB(160, 160, 162)
local FL_SEP     = Color3.fromRGB(62,  62,  65)
local T_BG   = 0.17; local T_HDR  = 0.20
local T_ITEM = 0.25; local T_SEP  = 0.55

local targetParent = pcall(gethui) and gethui() or game:GetService("CoreGui")

-- ══════════════════════════════════════════════════
-- NOTIFICATION HELPER
-- ══════════════════════════════════════════════════
local function notify(title, msg, dur)
    Fluent:Notify({ Title = title or "GUI", Content = msg or "", Duration = dur or 3 })
end

-- ══════════════════════════════════════════════════
-- TEAM WINDOW  (toute la construction UI identique)
-- ══════════════════════════════════════════════════
-- [ colle ici tout le bloc TWGui / TeamWin tel quel depuis ton original ]
-- Les callbacks appellent maintenant Core.xxx :
-- ex: Core.teamExistsInJobsMain(name)

local selectedTeamColor = nil
local dropSelectedName  = nil
local listOpen          = false
local teamBtns          = {}
local TW_LIST_H         = 100
local TW_W              = 210

-- ... (construction UI identique) ...

-- Callback "Join team" : utilise Core
twJoin.MouseButton1Click:Connect(function()
    if not selectedTeamColor then setTWS("Select a team first", false); return end
    local te = ReplicatedStorage:FindFirstChild("TeamEvent")
    if not te then setTWS("TeamEvent not found", false); return end
    local ok = pcall(function() te:FireServer(selectedTeamColor) end)
    setTWS(ok and ("Joined: " .. tostring(dropSelectedName)) or "Error", ok)
end)

-- ══════════════════════════════════════════════════
-- COLOR WINDOW (idem, construction identique)
-- ══════════════════════════════════════════════════
-- Callbacks utilisent Core.applyCarColor, Core.getCarColors etc.

-- ══════════════════════════════════════════════════
-- FENÊTRE PRINCIPALE FLUENT
-- ══════════════════════════════════════════════════
local Window = Fluent:CreateWindow({
    Title       = "AreSW - SWFL",
    SubTitle    = "[PLACEHOLDER]",
    TabWidth    = TAB_W,
    Size        = UDim2.fromOffset(WIN_W, WIN_H),
    Acrylic     = false,
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl,
})

local Tabs = {
    Car    = Window:AddTab({ Title="Car",    Icon="car" }),
    Weapon = Window:AddTab({ Title="Weapon", Icon="crosshair" }),
    Game   = Window:AddTab({ Title="Game",   Icon="gamepad-2" }),
    Plrs   = Window:AddTab({ Title="Plrs",   Icon="users" }),
    Self   = Window:AddTab({ Title="Self",   Icon="user" }),
    Misc   = Window:AddTab({ Title="Misc",   Icon="wrench" }),
}

-- ══════════════════════════════════════════════════
-- CAR TAB
-- ══════════════════════════════════════════════════
local TC = Tabs.Car
local seatCarLookup = {}; local seatSeatLookup = {}; local stealLookup = {}
local selSpawnCar   = "mS3"
local selSeatCarKey = nil; local selSeatKey = nil; local selStealKey = nil
local seatCarDropObj, seatDropObj, stealDropObj

local function buildSeatCarValues()
    seatCarLookup = {}; local vals = {}
    local cf = workspace:FindFirstChild("Cars")
    if cf then
        for _, car in ipairs(cf:GetChildren()) do
            if car:IsA("Model") then
                local own   = Core.getCarOwnerName(car)         -- ← Core.xxx
                local ow    = own == "vous" and "[vous]" or "[" .. own .. "]"
                local seats = Core.getCarSeats(car)             -- ← Core.xxx
                local free  = 0
                for _, s in ipairs(seats) do if s.Occupant == nil then free += 1 end end
                local lbl  = car.Name .. " " .. ow .. " " .. free .. "/" .. #seats
                local orig = lbl; local n = 2
                while seatCarLookup[lbl] do lbl = orig .. "#" .. n; n += 1 end
                seatCarLookup[lbl] = car; table.insert(vals, lbl)
            end
        end
    end
    return #vals > 0 and vals or {"Aucun vehicule"}
end

local function buildSeatValues()
    seatSeatLookup = {}; local vals = {"Auto"}
    seatSeatLookup["Auto"] = "_auto_"
    local car = selSeatCarKey and seatCarLookup[selSeatCarKey]
    if car and car.Parent then
        for _, s in ipairs(Core.getCarSeats(car)) do        -- ← Core.xxx
            local lbl = s.Name .. (s.Occupant == nil and " [libre]" or " [occ]")
            seatSeatLookup[lbl] = s; table.insert(vals, lbl)
        end
    end
    return vals
end

local function buildStealValues()
    stealLookup = {}; local vals = {}
    local cf = workspace:FindFirstChild("Cars")
    if cf then
        for _, car in ipairs(cf:GetChildren()) do
            if car:IsA("Model") then
                local own = Core.getCarOwnerName(car)
                local ow  = own == "vous" and "[vous]" or "[" .. own .. "]"
                local ds  = car:FindFirstChild("DriveSeat")
                local spd = ds and (" ~" .. math.floor(ds.Velocity.Magnitude * 0.5682) .. "mph") or ""
                local occ = (ds and ds.Occupant ~= nil) and "[OCC]" or "[libre]"
                local lbl = car.Name .. " " .. ow .. " " .. occ .. spd
                local orig = lbl; local n = 2
                while stealLookup[lbl] do lbl = orig .. "#" .. n; n += 1 end
                stealLookup[lbl] = car; table.insert(vals, lbl)
            end
        end
    end
    return #vals > 0 and vals or {"Aucun vehicule"}
end

TC:AddSection("Driving Methods")
TC:AddDropdown("DriveMethod", {
    Title  = "Method",
    Values = {"M1 - Remote Direct","M2 - TP + ProxFire","M3 - G_Assets Clone","M4 - Humanoid:Sit"},
    Default  = "M1 - Remote Direct",
    Callback = function(v)
        if     v:find("M1") then Core.currentDriveMethod = 1
        elseif v:find("M2") then Core.currentDriveMethod = 2
        elseif v:find("M3") then Core.currentDriveMethod = 3
        else                      Core.currentDriveMethod = 4 end
        notify("Drive", "Method " .. Core.currentDriveMethod .. " active")
    end
})

TC:AddSection("Car Color")
TC:AddToggle("ShowColorWin", {
    Title = "Car Color", Default = false,
    Callback = function(v)
        CWGui.Enabled = v; ColorWin.Visible = v
        if v then buildColorCarList()
        else Core.colorCycleActive = false end
    end
})

TC:AddSection("Current Vehicle")
TC:AddDropdown("SpawnCarDrop", {
    Title    = "Vehicle to spawn",
    Values   = Core.CAR_LIST,                               -- ← Core.CAR_LIST
    Default  = "mS3",
    Callback = function(v) selSpawnCar = v end
})

TC:AddButton({ Title = "Spawn Car", Callback = function()
    local ok = pcall(function()
        ReplicatedStorage.SpawnCar:FireServer("requestSpawn", selSpawnCar)
    end)
    notify("Car", ok and selSpawnCar .. " spawned" or "Spawn error")
end })

TC:AddButton({ Title = "Drive Car", Callback = function()
    task.spawn(function()
        local car = Core.findValidCar(selSpawnCar, 4)       -- ← Core.xxx
        if not car then notify("Car", "Not found"); return end
        local ok, msg = Core.driveInCar(car, "drive")       -- ← Core.xxx
        notify("Car", ok and ("Driving: " .. selSpawnCar) or ("Error: " .. msg))
    end)
end })

TC:AddSection("Sit Car")
seatCarDropObj = TC:AddDropdown("SeatCarDrop", {
    Title = "Choose a Car", Values = {"→ Click Refresh"}, Default = nil,
    Callback = function(v)
        selSeatCarKey = v
        if seatDropObj then pcall(function() seatDropObj:SetValues(buildSeatValues()) end) end
    end
})
seatDropObj = TC:AddDropdown("SeatDrop", {
    Title = "Target Seat", Values = {"Auto"}, Default = "Auto",
    Callback = function(v) selSeatKey = v end
})
TC:AddButton({ Title = "Refresh Cars", Callback = function()
    pcall(function() seatCarDropObj:SetValues(buildSeatCarValues()) end)
    notify("Car", "Refreshed")
end })
TC:AddButton({ Title = "Sit Car", Callback = function()
    local car = selSeatCarKey and seatCarLookup[selSeatCarKey]
    if not car then notify("Car", "Select a car"); return end
    if not car.Parent then notify("Car", "Car is gone"); return end
    task.spawn(function()
        local st = nil
        if selSeatKey and selSeatKey ~= "Auto"
        and seatSeatLookup[selSeatKey] and seatSeatLookup[selSeatKey] ~= "_auto_" then
            st = seatSeatLookup[selSeatKey]
        end
        if not st then
            local all = Core.getCarSeats(car)
            for _, s in ipairs(all) do
                if s.Occupant == nil and s.Name ~= "DriveSeat" then st = s; break end
            end
            if not st then for _, s in ipairs(all) do if s.Occupant == nil then st = s; break end end end
            if not st and #all > 0 then st = all[1] end
        end
        if not st then notify("Car", "No seat found"); return end
        local ok, msg = Core.driveInCar(car, st)
        notify("Car", ok and ("Sat: " .. st.Name) or ("Error: " .. msg))
    end)
end })

TC:AddSection("Rejoin")
TC:AddToggle("AutoRejoinToggle", {
    Title = "Auto rejoin after respawn", Default = false,
    Callback = function(v) Core.autoRejoinOn = v end         -- ← Core.xxx
})
TC:AddButton({ Title = "Sit back at last seat", Callback = function()
    if not Core.persistCarName then notify("Car", "No seat remembered yet"); return end
    local car  = Core.resolveCarAfterRespawn()
    if not car then notify("Car", "Vehicle not found"); return end
    local seat = Core.findSeatInCar(car, Core.persistSeatName) or car:FindFirstChild("DriveSeat")
    if not seat then notify("Car", "Seat not found"); return end
    task.spawn(function()
        local ok, msg = Core.driveInCar(car, seat)
        notify("Car", ok and ("Rejoined ✓ " .. seat.Name) or ("Error: " .. tostring(msg)))
    end)
end })

TC:AddSection("Steal")
stealDropObj = TC:AddDropdown("StealDrop", {
    Title = "Target Vehicle", Values = {"→ Refresh"}, Default = nil,
    Callback = function(v) selStealKey = v end
})
TC:AddButton({ Title = "Refresh Cars", Callback = function()
    pcall(function() stealDropObj:SetValues(buildStealValues()) end); notify("Car", "Refreshed")
end })
TC:AddButton({ Title = "Steal & Drive", Callback = function()
    local car = selStealKey and stealLookup[selStealKey]
    if not car then notify("Car", "Select a vehicle"); return end
    if not car.Parent then notify("Car", "Car is gone"); return end
    task.spawn(function()
        local mc  = LocalPlayer.Character; if not mc then return end
        local hrp = mc:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local ds  = car:FindFirstChild("DriveSeat"); if not ds then notify("Car", "No DriveSeat"); return end
        local tpA = true
        local tpC = RunService.Heartbeat:Connect(function()
            if tpA then pcall(function() hrp.CFrame = ds.CFrame * CFrame.new(0, ds.Size.Y/2+2.5, 0) end) end
        end)
        task.wait(0.2)
        pcall(function() ReplicatedStorage.PromptEvent:FireServer("DriveRequest", ds) end)
        task.wait(0.15); tpA = false; tpC:Disconnect()
        notify("Car", "Steal attempted: " .. car.Name)
    end)
end })

-- ══════════════════════════════════════════════════
-- WEAPON TAB
-- ══════════════════════════════════════════════════
local TW_tab = Tabs.Weapon
local playerDropObj = nil

local function refreshPlayerList()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(names, plr.Name) end
    end
    if #names == 0 then names = {"No players found"} end
    if playerDropObj then pcall(function() playerDropObj:SetValues(names) end) end
end

TW_tab:AddSection("Target")
playerDropObj = TW_tab:AddDropdown("PlayerTarget", {
    Title = "Player", Values = {"No players"}, Default = nil,
    Callback = function(v)
        Core.selectedPlayer = nil                           -- ← Core.xxx
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name == v then Core.selectedPlayer = p; break end
        end
    end
})
TW_tab:AddButton({ Title = "Refresh player list", Callback = refreshPlayerList })

TW_tab:AddSection("Damage")
TW_tab:AddButton({ Title = "Inflict damage", Callback = function()
    if not Core.selectedPlayer then notify("Weapon", "Select a target"); return end
    if not Core.getGun() then notify("Weapon", "Equip M9"); return end
    local ok = Core.sendDamage(Core.selectedPlayer.Character)   -- ← Core.xxx
    notify("Weapon", ok and Core.selectedPlayer.Name .. " HIT" or "Remote not found")
end })

TW_tab:AddButton({ Title = "Loop Kill", Callback = function()
    if not Core.selectedPlayer then notify("Weapon", "Select a target"); return end
    if not Core.getGun() then notify("Weapon", "Equip M9"); return end
    if Core.killLoopActive then notify("Weapon", "Already running"); return end
    Core.killLoopActive = true
    task.spawn(function()
        local tgt = Core.selectedPlayer; local tries, maxT = 0, 80
        while Core.killLoopActive and tries < maxT do
            local ch = tgt.Character; if ch then
                local hm = ch:FindFirstChildOfClass("Humanoid")
                if hm and hm.Health > 0 then
                    Core.sendDamage(ch); task.wait(0.05); tries += 1
                else notify("Weapon", tgt.Name .. " KILLED ✓"); break end
            else task.wait(0.1); tries += 1 end
        end
        if tries >= maxT then notify("Weapon", "Took too long") end
        Core.killLoopActive = false
    end)
end })
TW_tab:AddButton({ Title = "Stop Kill Loop", Callback = function()
    Core.killLoopActive = false; notify("Weapon", "Stopped")
end })

TW_tab:AddSection("Kill Aura")
local auraRespawnConns = {}
TW_tab:AddSlider("AuraRadius", {
    Title = "Radius (studs)", Min = 5, Max = 700, Default = 200, Rounding = 5,
    Callback = function(v) Core.auraRadius = v end
})
TW_tab:AddToggle("AuraDmg", { Title = "Kill Aura (police)", Default = false, Callback = function(v)
    if v then
        if not Core.getGun() then notify("Weapon", "Equip M9") end
        local timers = {}
        local function hookRespawn(plr)
            if auraRespawnConns[plr] then auraRespawnConns[plr]:Disconnect() end
            auraRespawnConns[plr] = plr.CharacterAdded:Connect(function() timers[plr] = nil end)
        end
        for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer then hookRespawn(plr) end end
        local newPlrConn = Players.PlayerAdded:Connect(function(plr) hookRespawn(plr) end)
        Core.auraConn = RunService.Heartbeat:Connect(function()
            local ts = game:FindService("Teams"); if not ts then return end
            local myTeam = LocalPlayer.Team
            if not myTeam or myTeam.Name ~= "Criminal" then return end
            local mc = LocalPlayer.Character; if not mc then return end
            local mh = mc:FindFirstChild("HumanoidRootPart"); if not mh then return end
            local now = tick()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local pt = plr.Team
                    if pt and (pt.Name == "Police" or pt.Name == "Sheriff") then
                        local h = plr.Character:FindFirstChild("HumanoidRootPart")
                        if h and (mh.Position-h.Position).Magnitude <= (Core.auraRadius or 200) then
                            local last = timers[plr] or 0
                            if now - last >= 0.3 then
                                timers[plr] = now
                                task.spawn(function() Core.sendDamage(plr.Character) end)
                            end
                        end
                    end
                end
            end
        end)
        Core.auraConn_cleanup = newPlrConn
    else
        if Core.auraConn then Core.auraConn:Disconnect(); Core.auraConn = nil end
        if Core.auraConn_cleanup then Core.auraConn_cleanup:Disconnect(); Core.auraConn_cleanup = nil end
        for _, c in pairs(auraRespawnConns) do pcall(function() c:Disconnect() end) end
        auraRespawnConns = {}
    end
end })

TW_tab:AddSection("Taser")
TW_tab:AddButton({ Title = "Tase selected player", Callback = function()
    if not Core.selectedPlayer then notify("Taser", "Select a player"); return end
    if not Core.isPoliceOrSheriff() then notify("Taser", "Requires Police/Sheriff"); return end
    local ok = Core.fireTase(Core.selectedPlayer)
    notify("Taser", ok and Core.selectedPlayer.Name .. " tased" or "Error")
end })
TW_tab:AddButton({ Title = "Tase nearest player", Callback = function()
    if not Core.isPoliceOrSheriff() then notify("Taser", "Requires Police/Sheriff"); return end
    local n = Core.getNearestPlayer()
    if not n then notify("Taser", "No nearby player"); return end
    local ok = Core.fireTase(n)
    notify("Taser", ok and n.Name .. " tased" or "Error")
end })
TW_tab:AddToggle("TaseLoop", { Title = "Taser Loop", Default = false, Callback = function(v)
    if v and not Core.isPoliceOrSheriff() then notify("Taser", "Requires Police/Sheriff"); return end
    Core.taseLoopActive = v
    if v then
        task.spawn(function()
            while Core.taseLoopActive do
                local n = Core.getNearestPlayer()
                if n then Core.fireTase(n) end
                task.wait(5.2)
            end
        end)
    end
end })

-- ══════════════════════════════════════════════════
-- GAME TAB
-- ══════════════════════════════════════════════════
local TG = Tabs.Game
pcall(function()
    TG:AddSection("Teams")
    TG:AddToggle("ShowTeamWin", {
        Title = "Join Team", Default = false,
        Callback = function(v)
            TWGui.Enabled = v; TeamWin.Visible = v
            if v then buildTeamList() end
        end
    })
    TG:AddButton({ Title = "Rejoin current team", Callback = function()
        local mt = LocalPlayer.Team
        if not mt then notify("Game", "No team"); return end
        local te = ReplicatedStorage:FindFirstChild("TeamEvent")
        if not te then notify("Game", "TeamEvent not found"); return end
        local ok = pcall(function() te:FireServer(mt.TeamColor) end)
        notify("Game", ok and ("Rejoined: " .. mt.Name) or "Error")
    end })
end)

-- ══════════════════════════════════════════════════
-- MISC TAB
-- ══════════════════════════════════════════════════
local TM = Tabs.Misc

TM:AddSection("Character")
TM:AddButton({ Title = "Reload Character", Callback = function()
    local ok = pcall(function() ReplicatedStorage.loadCharRemote:FireServer() end)
    notify("Misc", ok and "Reloaded" or "Error")
end })

TM:AddToggle("FloorFixToggle", {
    Title = "Godmode floor fix",
    Default = false,
    Callback = function(v)
        if not v then return end
        local freezeConn = nil; local charConns = {}
        local function stopFreeze(hrp, hum)
            if freezeConn then freezeConn:Disconnect(); freezeConn = nil end
            if hrp then pcall(function() hrp.Anchored = false end) end
            if hum then pcall(function() hum.WalkSpeed = 16; hum.JumpPower = 50 end) end
        end
        local function doFix(hrp, hum)
            if not Options["FloorFixToggle"].Value then return end
            local mode = Options["FloorFixMode"].Value
            if mode == "TP Up" then
                local offset = Options["FloorFixTPHeight"].Value
                if hrp then pcall(function() hrp.CFrame = hrp.CFrame + Vector3.new(0, offset, 0) end) end
            elseif mode:find("Freeze") then
                stopFreeze(hrp, hum)
                if not hrp then return end
                pcall(function() hrp.Anchored = true end)
                if hum then pcall(function() hum.WalkSpeed = 0; hum.JumpPower = 0 end) end
                local elapsed = 0
                freezeConn = RunService.Heartbeat:Connect(function(dt)
                    elapsed += dt
                    if not Options["FloorFixToggle"].Value or not hrp or not hrp.Parent or elapsed >= 3 then
                        stopFreeze(hrp, hum)
                    end
                end)
            end
        end
        local function getWeaponForTeam()
            local team = LocalPlayer.Team; if not team then return nil end
            if team.Name == "Criminal" then return "M9" end
            if team.Name == "Police" or team.Name == "Sheriff" then return "G17" end
        end
        local function hookCharacter(character)
            for _, c in ipairs(charConns) do pcall(function() c:Disconnect() end) end; charConns = {}
            local hrp = character:WaitForChild("HumanoidRootPart", 5)
            local hum = character:WaitForChild("Humanoid", 5)
            if not hrp or not hum then return end
            local function watchTool(tool)
                if not tool:IsA("Tool") then return end
                local eqConn = tool.Equipped:Connect(function()
                    if not Options["FloorFixToggle"].Value then return end
                    local expected = getWeaponForTeam()
                    if not expected or tool.Name ~= expected then return end
                    doFix(hrp, hum)
                end)
                local uqConn = tool.Unequipped:Connect(function()
                    local expected = getWeaponForTeam()
                    if expected and tool.Name == expected then stopFreeze(hrp, hum) end
                end)
                table.insert(charConns, eqConn); table.insert(charConns, uqConn)
            end
            local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
            if bp then for _, t in ipairs(bp:GetChildren()) do watchTool(t) end end
            for _, t in ipairs(character:GetChildren()) do watchTool(t) end
            table.insert(charConns, character.ChildAdded:Connect(function(c) watchTool(c) end))
            if bp then table.insert(charConns, bp.ChildAdded:Connect(function(c) watchTool(c) end)) end
        end
        if LocalPlayer.Character then hookCharacter(LocalPlayer.Character) end
        table.insert(charConns, LocalPlayer.CharacterAdded:Connect(hookCharacter))
    end
})
TM:AddDropdown("FloorFixMode", {
    Title = "Floor fix mode",
    Values = {"Freeze for 3s(RECOMMENDED)", "TP Up"},
    Default = "Freeze for 3s(RECOMMENDED)",
    Callback = function() end
})
TM:AddSlider("FloorFixTPHeight", {
    Title = "TP height offset", Min = 1, Max = 20, Default = 5, Rounding = 1,
    Callback = function() end
})

TM:AddSection("Unlimited Ammo")
TM:AddDropdown("AmmoMethod", {
    Title  = "Ammo method",
    Values = {"Basic method", "Invisible TP ammo box"},
    Default = "Basic method",
    Callback = function(v)
        Core.selAmmoMethod = v == "Basic method" and "BS" or "tp"    -- ← Core.xxx
    end
})
TM:AddToggle("HideAmmo", {
    Title = "Hide ammo boxes", Default = false,
    Callback = function(v)
        Core.hideLoopActive = v
        if v then
            task.spawn(function()
                while Core.hideLoopActive do Core.applyHide(); task.wait(0.1) end
            end)
        end
    end
})
TM:AddToggle("AmmoLoop", {
    Title = "Get ammo every 12s", Default = false,
    Callback = function(v)
        Core.ammoLoopEnabled = v
        if v and Core.ammoEnabled then
            Core.ammoLoopActive = true
            task.spawn(function()
                while Core.ammoLoopActive and Core.ammoLoopEnabled do
                    Core.touchAmmo(); task.wait(12)
                end
            end)
        end
        if not v then Core.ammoLoopActive = false end
    end
})
TM:AddToggle("AmmoEnabled", {
    Title = "Get ammo on each shot", Default = false,
    Callback = function(v)
        Core.ammoEnabled = v
        if v then
            if Core.ammoShootConn then Core.ammoShootConn:Disconnect() end
            Core.ammoShootConn = LocalPlayer:GetMouse().Button1Down:Connect(function()
                task.spawn(function() Core.touchAmmo() end)
            end)
            if Core.ammoLoopEnabled then
                Core.ammoLoopActive = true
                task.spawn(function()
                    while Core.ammoLoopActive and Core.ammoLoopEnabled and Core.ammoEnabled do
                        Core.touchAmmo(); task.wait(10)
                    end
                end)
            end
        else
            if Core.ammoShootConn then Core.ammoShootConn:Disconnect(); Core.ammoShootConn = nil end
            Core.ammoLoopActive = false
        end
    end
})

TM:AddSection("Glasses")
TM:AddButton({ Title = "Break Glasses", Callback = function()
    task.spawn(function()
        local sr = ReplicatedStorage:FindFirstChild("Remotes")
            and ReplicatedStorage.Remotes:FindFirstChild("ShatterGlass")
        if not sr then notify("Misc", "ShatterGlass not found"); return end
        local gp = {}
        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("Part") and o.Name:sub(-6) == "_glass" then table.insert(gp, o) end
        end
        if #gp == 0 then notify("Misc", "No glass found"); return end
        local sent = 0
        for _, g in ipairs(gp) do
            if g and g.Parent then
                pcall(function() sr:FireServer(g) end); sent += 1
                if sent % 50 == 0 then task.wait() end
            end
        end
        notify("Misc", sent .. "/" .. #gp .. " glasses broken ✓")
    end)
end })

TM:AddSection("Interface")
InterfaceManager:SetFolder("CustomGUI")
InterfaceManager:BuildInterfaceSection(TM)

-- ══════════════════════════════════════════════════
-- SEAT PERSIST HOOKS (besoin de Core)
-- ══════════════════════════════════════════════════
local humanoidSeatedConn = nil

local function hookHumanoid(character)
    if humanoidSeatedConn then humanoidSeatedConn:Disconnect(); humanoidSeatedConn = nil end
    local hum = character and character:WaitForChild("Humanoid", 5)
    if not hum then return end
    humanoidSeatedConn = hum.Seated:Connect(function(isSeated, seatPart)
        if not isSeated or not seatPart then return end
        local car = Core.getCarFromSeat(seatPart)
        if not car then return end
        Core.persistCarRef   = car
        Core.persistCarName  = car.Name
        Core.persistSeatName = seatPart.Name
    end)
end

local function doRejoin(character)
    if not Core.persistCarName or not Core.persistSeatName then return end
    task.spawn(function()
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        local hum = character:WaitForChild("Humanoid", 5)
        if not hrp or not hum then return end
        task.wait(0.35)
        local car  = Core.resolveCarAfterRespawn()
        if not car then notify("Car", "Auto-rejoin: " .. Core.persistCarName .. " not found"); return end
        local seat = Core.findSeatInCar(car, Core.persistSeatName) or car:FindFirstChild("DriveSeat")
        if not seat then notify("Car", "Auto-rejoin: seat not found"); return end
        hrp.CFrame = seat.CFrame * CFrame.new(0, seat.Size.Y/2 + 0.5, 0)
        task.wait(0.06)
        if not seat.Parent then return end
        local ok, msg = Core.driveInCar(car, seat)
        notify("Car", ok and ("Auto-rejoined: " .. seat.Name) or ("Auto-rejoin failed: " .. tostring(msg)))
    end)
end

if LocalPlayer.Character then hookHumanoid(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(character)
    hookHumanoid(character)
    if Core.autoRejoinOn then doRejoin(character) end
end)

-- ══════════════════════════════════════════════════
-- PLAYER LEAVING CLEANUP
-- ══════════════════════════════════════════════════
Players.PlayerRemoving:Connect(function(plr)
    if Core.selectedPlayer == plr then
        Core.killLoopActive  = false
        Core.taseLoopActive  = false
        Core.selectedPlayer  = nil
        notify("Weapon", plr.Name .. " left the game")
    end
end)
