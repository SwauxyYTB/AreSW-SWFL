-- core.lua
local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local ProximityPromptSvc = game:GetService("ProximityPromptService")
local RunService         = game:GetService("RunService")
local LocalPlayer        = Players.LocalPlayer

local M = {}

-- ══════════════════════════════════════════
-- ÉTAT PARTAGÉ
-- ══════════════════════════════════════════
M.selectedPlayer    = nil
M.killLoopActive    = false
M.taseLoopActive    = false
M.auraConn          = nil
M.auraConn_cleanup  = nil
M.ammoEnabled       = false
M.ammoLoopActive    = false
M.ammoShootConn     = nil
M.hideLoopActive    = false
M.ammoLoopEnabled   = false
M.currentDriveMethod = 1

M.persistCarRef     = nil
M.persistCarName    = nil
M.persistSeatName   = nil
M.autoRejoinOn      = false

-- ══════════════════════════════════════════
-- CONSTANTES
-- ══════════════════════════════════════════
M.CAR_LIST = {
    "aDbs","dHCat","dChalDemon170", -- ... ta liste complète ici
}

-- ══════════════════════════════════════════
-- FONCTIONS VOITURE
-- ══════════════════════════════════════════
function M.findDriveSeat(car)
    local ds = car:FindFirstChild("DriveSeat")
    if ds then return ds end
    for _, d in ipairs(car:GetDescendants()) do
        if d:IsA("VehicleSeat") then return d end
    end
end

function M.getCarSeats(car)
    local seats, seen, ds = {}, {}, nil
    for _, d in ipairs(car:GetDescendants()) do
        if (d:IsA("Seat") or d:IsA("VehicleSeat")) and not seen[d] then
            if d.Name == "DriveSeat" then ds = d
            else seen[d] = true; table.insert(seats, d) end
        end
    end
    if ds then table.insert(seats, 1, ds)
    else
        local d = M.findDriveSeat(car)
        if d and not seen[d] then table.insert(seats, 1, d) end
    end
    return seats
end

function M.isPlayerCar(car)
    local pn = LocalPlayer.Name
    local pl = car:FindFirstChild("PlayerLoc")
    if pl then
        local v = pl.Value
        if type(v) == "string" and v ~= "" then return v == pn end
        if typeof(v) == "Instance" and v:IsA("Player") then return v == LocalPlayer end
    end
    local ds = car:FindFirstChild("DriveSeat")
    if ds then
        for _, fn in ipairs({"OwnerValue","carOwner"}) do
            local f = ds:FindFirstChild(fn); if f then
                local v = f.Value
                if type(v) == "string" and v ~= "" then return v == pn end
                if typeof(v) == "Instance" and v:IsA("Player") then return v == LocalPlayer end
            end
        end
    end
    return true
end

function M.findValidCar(carId, timeout)
    timeout = timeout or 5
    local deadline = tick() + timeout
    repeat
        local cf = workspace:FindFirstChild("Cars")
        if cf then
            local fallback, dups = nil, {}
            for _, c in ipairs(cf:GetChildren()) do
                if c.Name == carId and c:IsA("Model") then
                    local ds = c:FindFirstChild("DriveSeat"); if ds then
                        local pp = c.PrimaryPart
                        if pp and not pp.Anchored then table.insert(dups, c)
                        else fallback = fallback or c end
                    end
                end
            end
            if #dups > 1 then
                for _, c in ipairs(dups) do if M.isPlayerCar(c) then return c end end
                return dups[1]
            elseif #dups == 1 then return dups[1]
            elseif fallback then return fallback end
        end
        task.wait(0.25)
    until tick() >= deadline
    local cf2 = workspace:FindFirstChild("Cars")
    if cf2 then
        for _, c in ipairs(cf2:GetChildren()) do
            if c.Name == carId and c:IsA("Model") then return c end
        end
    end
    return nil
end

function M.getCarOwnerName(car)
    local pl = car:FindFirstChild("PlayerLoc")
    if pl then
        local v = pl.Value
        if type(v) == "string" and v ~= "" then
            return v == LocalPlayer.Name and "vous" or v
        end
        if typeof(v) == "Instance" and v:IsA("Player") then
            return v == LocalPlayer and "vous" or v.Name
        end
    end
    local ds = car:FindFirstChild("DriveSeat")
    if ds then
        for _, fn in ipairs({"OwnerValue","carOwner"}) do
            local f = ds:FindFirstChild(fn); if f then
                local v = f.Value
                if type(v) == "string" and v ~= "" then
                    return v == LocalPlayer.Name and "vous" or v
                end
                if typeof(v) == "Instance" and v:IsA("Player") then
                    return v == LocalPlayer and "vous" or v.Name
                end
            end
        end
    end
    return "?"
end

function M.getGamePromptTemplate()
    local ga = workspace:FindFirstChild("G_Assets")
    return ga and ga:FindFirstChild("ProximityPrompt")
end

function M.driveInCar(car, seatTarget)
    local myChar = LocalPlayer.Character
    if not myChar then return false, "Pas de personnage" end
    local hrp = myChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return false, "HRP introuvable" end

    local seats = {}
    if typeof(seatTarget) == "Instance" then
        seats = {seatTarget}
    elseif seatTarget == "drive" then
        local ds = M.findDriveSeat(car)
        if not ds then return false, "DriveSeat introuvable" end
        seats = {ds}
    else
        seats = M.getCarSeats(car)
        if #seats == 0 then return false, "Aucun seat" end
    end

    local refSeat = seats[1]
    local isBike  = car:FindFirstChild("bikeHelm") ~= nil

    if M.currentDriveMethod == 1 then
        local ok, err = pcall(function()
            ReplicatedStorage.PromptEvent:FireServer("DriveRequest", refSeat)
        end)
        return ok, ok and "Remote OK" or tostring(err)

    elseif M.currentDriveMethod == 2 then
        pcall(function() ProximityPromptSvc.Enabled = true end)
        for _, seat in ipairs(seats) do
            for _, c in ipairs(seat:GetDescendants()) do
                if c:IsA("ProximityPrompt") then
                    pcall(function() c.Enabled = true; c.MaxActivationDistance = 9999 end)
                end
            end
        end
        local tpA = true
        local tpC = RunService.Heartbeat:Connect(function()
            if tpA then
                pcall(function()
                    hrp.CFrame = refSeat.CFrame * CFrame.new(0, refSeat.Size.Y/2+2.5, 0)
                end)
            end
        end)
        task.wait(0.2); local fired = 0
        for _, seat in ipairs(seats) do
            for _, c in ipairs(seat:GetDescendants()) do
                if c:IsA("ProximityPrompt") then
                    pcall(function() fireproximityprompt(c) end); fired += 1
                end
            end
            pcall(function() ReplicatedStorage.PromptEvent:FireServer("DriveRequest", seat) end)
        end
        task.wait(0.15); tpA = false; tpC:Disconnect()
        return true, "TP+Prox: " .. fired .. " fired"

    elseif M.currentDriveMethod == 3 then
        pcall(function() ProximityPromptSvc.Enabled = true end)
        for _, seat in ipairs(seats) do
            for _, c in ipairs(seat:GetDescendants()) do
                if c:IsA("ProximityPrompt") then
                    pcall(function() c.Enabled = true; c.MaxActivationDistance = 9999 end)
                end
            end
        end
        local tpA = true
        local tpC = RunService.Heartbeat:Connect(function()
            if tpA then
                pcall(function()
                    hrp.CFrame = refSeat.CFrame * CFrame.new(0, refSeat.Size.Y/2+2.5, 0)
                end)
            end
        end)
        task.wait(0.2); local tmp, f3 = {}, 0
        for _, seat in ipairs(seats) do
            local prompt = seat:FindFirstChildOfClass("ProximityPrompt")
            if not prompt then
                local tpl = M.getGamePromptTemplate()
                if tpl then
                    local ok2, cl = pcall(function() return tpl:Clone() end)
                    if ok2 and cl then
                        if isBike then pcall(function() cl.ActionText = "RIDE" end) end
                        pcall(function() cl.Enabled = true; cl.MaxActivationDistance = 9999 end)
                        cl.Parent = seat; prompt = cl; table.insert(tmp, cl)
                    end
                end
            end
            if prompt and pcall(function() fireproximityprompt(prompt) end) then f3 += 1 end
            pcall(function() ReplicatedStorage.PromptEvent:FireServer("DriveRequest", seat) end)
        end
        task.wait(0.15); tpA = false; tpC:Disconnect()
        if #tmp > 0 then
            task.delay(0.4, function()
                for _, p in ipairs(tmp) do pcall(function() p:Destroy() end) end
            end)
        end
        return true, "G_Assets: " .. f3 .. " fired"

    elseif M.currentDriveMethod == 4 then
        local hum = myChar:FindFirstChildWhichIsA("Humanoid")
        if not hum then return false, "Humanoid introuvable" end
        if not refSeat.Parent then return false, "Siège disparu" end
        hrp.CFrame = refSeat.CFrame * CFrame.new(0, refSeat.Size.Y/2 + 0.5, 0)
        task.wait(0.06)
        if not refSeat.Parent then return false, "Siège disparu après TP" end
        refSeat:Sit(hum)
        return true, "Sit direct OK"
    end

    return false, "Methode inconnue"
end

-- ══════════════════════════════════════════
-- REJOIN / SEAT PERSIST
-- ══════════════════════════════════════════
function M.getCarFromSeat(seatPart)
    local cf = workspace:FindFirstChild("Cars"); if not cf then return nil end
    local ancestor = seatPart.Parent
    while ancestor and ancestor ~= workspace do
        if ancestor.Parent == cf and ancestor:IsA("Model") then return ancestor end
        ancestor = ancestor.Parent
    end
    return nil
end

function M.resolveCarAfterRespawn()
    local cf = workspace:FindFirstChild("Cars"); if not cf then return nil end
    if M.persistCarRef and M.persistCarRef.Parent == cf then return M.persistCarRef end
    if not M.persistCarName then return nil end
    local fallback = nil
    for _, car in ipairs(cf:GetChildren()) do
        if car.Name == M.persistCarName and car:IsA("Model") then
            local pl = car:FindFirstChild("PlayerLoc")
            if pl then
                local v = pl.Value
                if (type(v) == "string" and v == LocalPlayer.Name) or
                   (typeof(v) == "Instance" and v == LocalPlayer) then return car end
            end
            fallback = fallback or car
        end
    end
    return fallback
end

function M.findSeatInCar(car, seatName)
    local ds = car:FindFirstChild(seatName)
    if ds and (ds:IsA("Seat") or ds:IsA("VehicleSeat")) then return ds end
    local body = car:FindFirstChild("Body")
    if body then
        local s = body:FindFirstChild(seatName)
        if s and (s:IsA("Seat") or s:IsA("VehicleSeat")) then return s end
    end
    for _, d in ipairs(car:GetDescendants()) do
        if d.Name == seatName and (d:IsA("Seat") or d:IsA("VehicleSeat")) then return d end
    end
    return nil
end

-- ══════════════════════════════════════════
-- WEAPON / COMBAT
-- ══════════════════════════════════════════
function M.getGun()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("M9")
end

function M.sendDamage(targetChar)
    if not targetChar then return false end
    local hum   = targetChar:FindFirstChildOfClass("Humanoid")
    local hrp   = targetChar:FindFirstChild("HumanoidRootPart")
    local torso = targetChar:FindFirstChild("UpperTorso") or hrp
    if not hum or not hrp then return false end
    local gun = M.getGun(); if not gun then return false end
    local GS = gun:FindFirstChild("GunScript_Server")
    local GL = gun:FindFirstChild("GunScript_Local")
    local ok = pcall(function()
        ReplicatedStorage.Remotes.InflictTarget:InvokeServer(
            gun, LocalPlayer, hum, hrp,
            ReplicatedStorage.Modules.ProjectileHandler,
            {16,2,true,13.85,false,10000,1000},
            {0,0,false,false,GS.IgniteScript,GS.IcifyScript,100,100},
            {false,5,3}, torso,
            {false,{1930359546},1,1.5,1,GL.GoreEffect}
        )
    end)
    return ok
end

function M.isPoliceOrSheriff()
    local t = LocalPlayer.Team
    return t and (t.Name == "Police" or t.Name == "Sheriff")
end

function M.findTaseBeam()
    local function check(c)
        for _, t in ipairs(c:GetChildren()) do
            local b = t:FindFirstChild("taseBeam"); if b then return b end
        end
    end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then local b = check(bp); if b then return b end end
    if LocalPlayer.Character then local b = check(LocalPlayer.Character); if b then return b end end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if plr.Character then local b = check(plr.Character); if b then return b end end
            local pbp = plr:FindFirstChildOfClass("Backpack")
            if pbp then local b = check(pbp); if b then return b end end
        end
    end
    local function srch(p, d)
        if d <= 0 then return nil end
        for _, c in ipairs(p:GetChildren()) do
            if c.Name == "taseBeam" then return c end
            local f = srch(c, d-1); if f then return f end
        end
    end
    return srch(workspace, 4)
end

function M.getNearestPlayer()
    local mc = LocalPlayer.Character; if not mc then return nil end
    local mh = mc:FindFirstChild("HumanoidRootPart"); if not mh then return nil end
    local nearest, minD = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local h = plr.Character:FindFirstChild("HumanoidRootPart")
            if h then
                local d = (mh.Position - h.Position).Magnitude
                if d < minD then minD = d; nearest = plr end
            end
        end
    end
    return nearest
end

function M.fireTase(tp)
    if not M.isPoliceOrSheriff() then return false end
    local b = M.findTaseBeam(); if not b then return false end
    local ok = pcall(function()
        ReplicatedStorage.Events.taseEvent:FireServer(b, tp)
    end)
    return ok
end

-- ══════════════════════════════════════════
-- AMMO
-- ══════════════════════════════════════════
M.selAmmoMethod = "BS"

function M.getAllAmmoBoxes()
    local r = {}
    for _, o in ipairs(workspace:GetChildren()) do
        if o.Name == "AmmoBox (Unlimited Use)" then table.insert(r, o) end
    end
    return r
end

function M.getBoxPart(box)
    if box:IsA("BasePart") and box:FindFirstChildOfClass("TouchInterest") then return box end
    for _, d in ipairs(box:GetDescendants()) do
        if d:IsA("TouchInterest") then return d.Parent end
    end
    if box:IsA("BasePart") then return box end
    return box:FindFirstChildWhichIsA("BasePart", true)
end

function M.applyHide()
    for _, box in ipairs(M.getAllAmmoBoxes()) do
        local p = {}
        if box:IsA("BasePart") then table.insert(p, box) end
        for _, d in ipairs(box:GetDescendants()) do
            if d:IsA("BasePart") then table.insert(p, d)
            elseif d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
                pcall(function() d.Enabled = false end)
            end
        end
        for _, pt in ipairs(p) do
            pcall(function() pt.Transparency = 1; pt.CanCollide = false; pt.Massless = true end)
        end
    end
end

function M.touchAmmo()
    local mc = LocalPlayer.Character; if not mc then return end
    local hrp = mc:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local boxes = M.getAllAmmoBoxes(); if #boxes == 0 then return end
    local part = M.getBoxPart(boxes[1]); if not part then return end
    if M.selAmmoMethod == "BS" then
        pcall(function()
            firetouchinterest(hrp, part, 0)
            task.wait(0.02)
            firetouchinterest(hrp, part, 1)
        end)
    else
        local orig = hrp.CFrame
        pcall(function() hrp.CFrame = part.CFrame + Vector3.new(0, part.Size.Y/2+1, 0) end)
        task.wait(0.08)
        pcall(function() hrp.CFrame = orig end)
    end
end

-- ══════════════════════════════════════════
-- COLOR CHANGER
-- ══════════════════════════════════════════
M.colorCycleActive = false
M.colorSelectedCar = nil
M.colorCarColors   = {}

function M.getPropFE(car)
    for _, child in pairs(car:GetChildren()) do
        if child:IsA("RemoteEvent") and child.Name:match("Prop_FE") then return child end
    end
    return nil
end

function M.getCarColors(car)
    local colors = {}
    pcall(function()
        local tune = car:FindFirstChild("A-Chassis Tune"); if not tune then return end
        local interface = tune:FindFirstChild("A-Chassis Interface"); if not interface then return end
        local propFE = nil
        for _, child in pairs(interface:GetChildren()) do
            if child.Name:match("^Prop") then propFE = child; break end
        end
        if not propFE then return end
        for i = 1, 5 do
            local colorBtn = propFE:FindFirstChild("color" .. i)
            if colorBtn then table.insert(colors, colorBtn.BackgroundColor3) end
        end
    end)
    return colors
end

function M.applyCarColor(car, c)
    local propFE = M.getPropFE(car); if not propFE then return end
    for _, part in pairs(car:GetDescendants()) do
        if part:IsA("MeshPart") and part.Name ~= "Window" and part.Name ~= "Wheel" then
            pcall(function()
                propFE:FireServer("UpdateColor", part, c.R*255, c.G*255, c.B*255)
            end)
        end
    end
end

function M.getCarsInWorkspace()
    local cars, nameCount = {}, {}
    local cf = workspace:FindFirstChild("Cars"); if not cf then return cars end
    for _, child in pairs(cf:GetChildren()) do
        if child:IsA("Model") then
            nameCount[child.Name] = (nameCount[child.Name] or 0) + 1
        end
    end
    local seen = {}
    for _, child in pairs(cf:GetChildren()) do
        if child:IsA("Model") then
            local name = child.Name
            if nameCount[name] > 1 then
                seen[name] = (seen[name] or 0) + 1
                table.insert(cars, { model = child, label = name .. " " .. seen[name] })
            else
                table.insert(cars, { model = child, label = name })
            end
        end
    end
    return cars
end

-- ══════════════════════════════════════════
-- TEAMS
-- ══════════════════════════════════════════
function M.teamExistsInJobsMain(name)
    local jm = workspace:FindFirstChild("jobsMain"); if not jm then return true end
    return jm:FindFirstChild(name) ~= nil
end

return M
