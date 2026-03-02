return function(ctx)
    local notify  = ctx.notify
    local Options = ctx.Options

    local Players            = game:GetService("Players")
    local ReplicatedStorage  = game:GetService("ReplicatedStorage")
    local ProximityPromptSvc = game:GetService("ProximityPromptService")
    local UserInputService   = game:GetService("UserInputService")
    local RunService         = game:GetService("RunService")
    local LocalPlayer        = Players.LocalPlayer

    -- ══════════════════════════════════════════════
    -- CAR LIST
    -- ══════════════════════════════════════════════
    local CAR_LIST = {
        "aDbs","dHCat","dChalDemon170","fExpPolice","dNeon","d10Chrgr","h00CivicBomex_kit",
        "hPas","lAven","lGall","mGt","mS3","rrSport","tCamry","tFj","tGT86","tSA80","tSA90",
        "mG550","bM4","dRamRebel","jWran","cCam","jGlad","jWran4","lHuraP","mE63S","aRS5",
        "bFSp","cC8","gG70","cCTS5","jGCT","mGTR","pHuay","hOdy","hCC","hAcc","nVer","tCor",
        "sWSTI","tCamryTRD","aNSX","fF12","rrWrth","vXC90","n400Z","nR32",
        "aGrenadierQuartermaster","p911TurboS","eMdlS","eMdlX","eRdstr","hCarlton","eMdlY",
        "eCybr","cC5","c07CTSV","hSnta","kAgra","hS2000Vortex_kit","cSlvdo3500","hS2000J_kit",
        "t4Rnr","b530i","aA6","gSierra","mLncer","sFrstr","n180SXRB_kit","hEV","vJetta",
        "lLS500","mGT63s","mMiata","pCynne","rrVelar","aRDX","tTacoma","cTahoe","bX7",
        "cSlvdo2500","dHCatPolice","dHCatPoliceUnd","dChrgrPoliceUnd","dChrgrPolice",
        "cTahoePoliceUnd","cTahoePolice","h00CivicDrag_kit","p918","mP1","fLaRari","cCaprice",
        "aSQ7","aRS6","cEscld","eG35","p911R","dChalDemon","lRCF","bM5","pCarrera","cZL1",
        "xST1","fRangerCSA","c69Cam","VCorsa","h00CivicCSouth_kit","sMonarch","iDurastarFD",
        "fF450FD","fExpdtnFire","nS15Kam_kit","fAmbulance","fExpPoliceSheriff","dMagnum",
        "fTaurusSheriff","nS15BPSports_kit","aStelvio","bBentayga","dDurango","lUrus",
        "rrCullinan","gGolfGTI","h95CivicDrag_kit","mEvo10","bVeyronSS","bM2","oETron",
        "kNinja","bS1000RR","yFZ07","cBonneville","h701","f488Pista","f458","fPortofino",
        "lAvenSVJ","oTTRS","lLC500","oR8","cSuperduke","sBusa","hdStreet","d899","fF8",
        "rrGhost","aIntegra","hAfTwin","cCruze","aGiulia","hCivicTypeR","mF1","tPrius",
        "nR33","nR34ZTune","oA7","cC7","vC40","hIoniq","h00CivicBackyard_kit","aGrenadier",
        "h95CivicFork_kit","mSpeedtail","hS2000","lHuraEVOSpyder","lGallSuperleggera",
        "lMurciSV","dPantera","lReventonRoadster","VCorsaST","lMurcielagoRoadster","a8C",
        "pFlatnose","p930","fCrownVicSheriff","d14Challenger","fCrownVicPolice","dHCatDaytona",
        "dHCatWidebody","hNSX","hSntaNLine","rrEvoque","aDelorean","aDBX","p944",
        "bChironSuperSport","dTRX","hCRZ","hH3","hH3Limo","kStinger","mPullman","mS63Coupe",
        "mS63Sedan","mSLSBS","n350Z","n350ZNismo","tMR2","bChiron","lLP800","b1M","hExorcist",
        "fF450","bE36M3PRB_kit","mEvo6TM","bF10M5","cSS","t884Runner","bX6M","fF40","pTaycan",
        "bE46M3","pGT3RS","p718Boxster","p718CaymanGT4","p718CaymanGTS","p911GT3",
        "p911GT3Touring","p911Targa","pGT3","nS15","dViperExtreme","dViper","hVenomF5","aDB11",
        "lHuraSTO","eSpano","lEvora","n180SXSpirit_kit","hVelosterN","h98Civic","nZ32",
        "hGenesisCoupe","mRX7","bZ4","aOne77","mSL65","bE92M3","eRoadsterSport","bE92GTS",
        "mCLK63","yR1","sACS","aValkyrie","cStreetTriple","kOne1","kZX10","lCTR3",
        "lCTR3Clubsport","lLFA","mSenna","sUltimateAero","tAvalonTRD","dDart","tAvalon","biX",
        "bG82M4","h21CivicHatch","m6X6","d70Charger","cSuburban","bE30M3","bE36M3","a05Integra",
        "eMdl3","vC30","n180SXBN_kit","nS15RB_kit","nR34","tTundra","cC2","cNova","j10GCT",
        "nKenmari","bE36M3LZ_kit","n370Z","n370ZNismo","fGTO","nHako","tSequoia","aAtom",
        "bMono","c620R","cXBow","cZ28","c2012ZL1","cC6ZR1","eG37","aNomad","c454SS",
        "fRangerCSU","oV8R8","dCaravan","dChalBadcatWB","dChalScatPack","dChalBadcat","oRS3",
        "cPacifica","mMC12","dRamSRT10","tGRCor","b85M6","d71Chal","d10ViperACRX","d10Viper",
        "d98Viper","sS7","h95Civic","h00Civic","tGRCorCE","tGRCorMorizo","aV12Vantage",
        "aV8Vantage","d69Daytona","d70Superbird","gYukon","nM600","pGT2RS","vAtlas","vBeetle",
        "vBus","lCountach","mFCRX7","bGNX","mEvo4","fTesta","hS2000Amuze_kit","lDelta",
        "lStratos","mGranTurismo","bE36M3RB_kit","mQuattroporte","aGiuliaGTA",
        "h23CivicTypeRFork_kit","s22B","hNR750","hRC30","aNSXTypeS","cC8Z07","m190E","kZXR750",
        "sGSXR750","kZX7RR","cC8Z06","cCTSVWagon","h95CivicMugen_kit","m570GT","m650S",
        "m675LT","m600LT","m650SSpyder","m765LT","p918Weissach","nAltima","cCTSV","cCTSVCoupe",
        "n350ZCWest_kit","n350ZRB_kit","n350ZVertex_kit","mRX7ReAm_kit","mRX7RB_kit",
        "mRX7BN_kit","tGT86Charge_kit","tGT86Modellista_kit","tGT86RB_kit","b2023M240i",
        "b2023M2","aIntensaEmozione","eG35Coupe","gSyclone","pGTO","h23CivicTypeR","hVenomGT",
        "l3Eleven","fSF90","mRX8","l340R","p911GT2RS","mGTRBS","nR35","p911GT3RS",
        "p718CaymanGT4RS","nR34CS_kit","nR34RCM_kit","nR34TS_kit","nR35TS_kit","gSierra2500",
        "gSierra3500","nS14","nSilviaK","n180SX","n370ZEnds_kit","n370ZAvoidless_kit",
        "n370ZAmuze_kit","nR35LB_kit","f2013MusGT","fTaurusSheriffUnd","fTaurus",
        "fSheriffMusGT","fSN95Terminator","fSN95CobraR","fS197Must","fRanger","fRS200",
        "fMustSuperSnake","fMustNFS","fMusGTTRT5","fMusGTTRT3","fMusGT500CR","fMusGT500",
        "fMusGT350R","fMusGT","mRX7Vertex_kit","nS14GPSport_kit","fFocusRS","nSilviaKGP_kit",
        "fBrnco2dr","fBrnco4dr","fCrownVicPoliceUnd","fF100","fCrownVic","fF150Police","fF150",
        "fFsion","nS14MSport_kit","fExpPoliceSheriffUnd","fFsionUnd","fExpdtn","kRental",
        "fFoxbody","fFiesta","f95Lightning","f99Lightning","nSilviaKBN_kit","hR4_RennSportkit",
        "nS14Wonder_kit","iIT1","hR3","fBosstang","fGT","f2013MusGTVert","fFoxbodyCobra",
        "fMaverick","nS14Zenki_kit","fF250","fBrnco4drTRT","hR3Touring","fExp","hR4","f2020GT",
        "kShifter","fExpPoliceUnd"
    }

    -- ══════════════════════════════════════════════
    -- STATE PARTAGÉ (table passée par référence)
    -- ══════════════════════════════════════════════
    local state = {
        selectedPlayer     = nil,
        killLoopActive     = false,
        taseLoopActive     = false,
        auraConn           = nil,
        auraConn_cleanup   = nil,
        ammoEnabled        = false,
        ammoLoopActive     = false,
        ammoShootConn      = nil,
        hideLoopActive     = false,
        ammoLoopEnabled    = false,
        currentDriveMethod = 1,
        selSpawnCar        = "mS3",
        selSeatCarKey      = nil,
        selSeatKey         = nil,
        selStealKey        = nil,
        selAmmoMethod      = "BS",
        killEngineEnabled  = false,
        kickUIEnabled      = true,
        autoRejoinOn       = false,
        auraRadius         = 200,
    }

    local seatCarLookup  = {}
    local seatSeatLookup = {}
    local stealLookup    = {}

    -- Persistent seat
    local persistCarRef          = nil
    local persistCarName         = nil
    local persistSeatName        = nil
    local humanoidSeatedConn     = nil
    local auraRespawnConns       = {}

    -- ══════════════════════════════════════════════
    -- FONCTIONS HELPER VOITURES
    -- ══════════════════════════════════════════════
    local function findDriveSeat(car)
        local ds = car:FindFirstChild("DriveSeat"); if ds then return ds end
        for _, d in ipairs(car:GetDescendants()) do if d:IsA("VehicleSeat") then return d end end
    end

    local function getCarSeats(car)
        local seats, seen, ds = {}, {}, nil
        for _, d in ipairs(car:GetDescendants()) do
            if (d:IsA("Seat") or d:IsA("VehicleSeat")) and not seen[d] then
                if d.Name == "DriveSeat" then ds = d else seen[d] = true; table.insert(seats, d) end
            end
        end
        if ds then table.insert(seats, 1, ds)
        else local d = findDriveSeat(car); if d and not seen[d] then table.insert(seats, 1, d) end end
        return seats
    end

    local function getGamePromptTemplate()
        local ga = workspace:FindFirstChild("G_Assets"); return ga and ga:FindFirstChild("ProximityPrompt")
    end

    local function isPlayerCar(car)
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

    local function findValidCar(carId, timeout)
        timeout = timeout or 5; local deadline = tick() + timeout
        repeat
            local cf = workspace:FindFirstChild("Cars")
            if cf then
                local fallback, dups = nil, {}
                for _, c in ipairs(cf:GetChildren()) do
                    if c.Name == carId and c:IsA("Model") then
                        local ds = c:FindFirstChild("DriveSeat"); if ds then
                            local pp = c.PrimaryPart
                            if pp and not pp.Anchored then table.insert(dups, c) else fallback = fallback or c end
                        end
                    end
                end
                if #dups > 1 then for _, c in ipairs(dups) do if isPlayerCar(c) then return c end end; return dups[1]
                elseif #dups == 1 then return dups[1]
                elseif fallback then return fallback end
            end
            task.wait(0.25)
        until tick() >= deadline
        local cf2 = workspace:FindFirstChild("Cars")
        if cf2 then for _, c in ipairs(cf2:GetChildren()) do if c.Name == carId and c:IsA("Model") then return c end end end
        return nil
    end

    local function getCarOwnerName(car)
        local pl = car:FindFirstChild("PlayerLoc")
        if pl then
            local v = pl.Value
            if type(v) == "string" and v ~= "" then return v == LocalPlayer.Name and "vous" or v end
            if typeof(v) == "Instance" and v:IsA("Player") then return v == LocalPlayer and "vous" or v.Name end
        end
        local ds = car:FindFirstChild("DriveSeat")
        if ds then
            for _, fn in ipairs({"OwnerValue","carOwner"}) do
                local f = ds:FindFirstChild(fn); if f then
                    local v = f.Value
                    if type(v) == "string" and v ~= "" then return v == LocalPlayer.Name and "vous" or v end
                    if typeof(v) == "Instance" and v:IsA("Player") then return v == LocalPlayer and "vous" or v.Name end
                end
            end
        end
        return "?"
    end

    -- ══════════════════════════════════════════════
    -- DRIVE IN CAR
    -- ══════════════════════════════════════════════
    local function driveInCar(car, seatTarget)
        local myChar = LocalPlayer.Character; if not myChar then return false, "Pas de personnage" end
        local hrp = myChar:FindFirstChild("HumanoidRootPart"); if not hrp then return false, "HRP introuvable" end
        local seats = {}
        if typeof(seatTarget) == "Instance" then
            seats = {seatTarget}
        elseif seatTarget == "drive" then
            local ds = findDriveSeat(car); if not ds then return false, "DriveSeat introuvable" end; seats = {ds}
        else
            seats = getCarSeats(car); if #seats == 0 then return false, "Aucun seat" end
        end
        local refSeat = seats[1]
        local isBike  = car:FindFirstChild("bikeHelm") ~= nil

        if state.currentDriveMethod == 1 then
            local ok, err = pcall(function() ReplicatedStorage.PromptEvent:FireServer("DriveRequest", refSeat) end)
            return ok, ok and "Remote OK" or tostring(err)

        elseif state.currentDriveMethod == 2 then
            pcall(function() ProximityPromptSvc.Enabled = true end)
            for _, seat in ipairs(seats) do
                for _, c in ipairs(seat:GetDescendants()) do
                    if c:IsA("ProximityPrompt") then pcall(function() c.Enabled = true; c.MaxActivationDistance = 9999 end) end
                end
            end
            local tpA = true
            local tpC = RunService.Heartbeat:Connect(function()
                if tpA then pcall(function() hrp.CFrame = refSeat.CFrame * CFrame.new(0, refSeat.Size.Y/2+2.5, 0) end) end
            end)
            task.wait(0.2); local fired = 0
            for _, seat in ipairs(seats) do
                for _, c in ipairs(seat:GetDescendants()) do
                    if c:IsA("ProximityPrompt") then pcall(function() fireproximityprompt(c) end); fired += 1 end
                end
                pcall(function() ReplicatedStorage.PromptEvent:FireServer("DriveRequest", seat) end)
            end
            task.wait(0.15); tpA = false; tpC:Disconnect()
            return true, "TP+Prox: " .. fired .. " fired"

        elseif state.currentDriveMethod == 3 then
            pcall(function() ProximityPromptSvc.Enabled = true end)
            for _, seat in ipairs(seats) do
                for _, c in ipairs(seat:GetDescendants()) do
                    if c:IsA("ProximityPrompt") then pcall(function() c.Enabled = true; c.MaxActivationDistance = 9999 end) end
                end
            end
            local tpA = true
            local tpC = RunService.Heartbeat:Connect(function()
                if tpA then pcall(function() hrp.CFrame = refSeat.CFrame * CFrame.new(0, refSeat.Size.Y/2+2.5, 0) end) end
            end)
            task.wait(0.2); local tmp, f3 = {}, 0
            for _, seat in ipairs(seats) do
                local prompt = seat:FindFirstChildOfClass("ProximityPrompt")
                if not prompt then
                    local tpl = getGamePromptTemplate()
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
            if #tmp > 0 then task.delay(0.4, function() for _, p in ipairs(tmp) do pcall(function() p:Destroy() end) end end) end
            return true, "G_Assets: " .. f3 .. " fired"

        elseif state.currentDriveMethod == 4 then
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

    -- ══════════════════════════════════════════════
    -- SIÈGE PERSISTANT
    -- ══════════════════════════════════════════════
    local function getCarFromSeat(seatPart)
        local cf = workspace:FindFirstChild("Cars"); if not cf then return nil end
        local ancestor = seatPart.Parent
        while ancestor and ancestor ~= workspace do
            if ancestor.Parent == cf and ancestor:IsA("Model") then return ancestor end
            ancestor = ancestor.Parent
        end
        return nil
    end

    local function resolveCarAfterRespawn()
        local cf = workspace:FindFirstChild("Cars"); if not cf then return nil end
        if persistCarRef and persistCarRef.Parent == cf then return persistCarRef end
        if not persistCarName then return nil end
        local fallback = nil
        for _, car in ipairs(cf:GetChildren()) do
            if car.Name == persistCarName and car:IsA("Model") then
                local pl = car:FindFirstChild("PlayerLoc")
                if pl then
                    local v = pl.Value
                    if (type(v) == "string" and v == LocalPlayer.Name) or
                       (typeof(v) == "Instance" and v == LocalPlayer) then
                        return car
                    end
                end
                fallback = fallback or car
            end
        end
        return fallback
    end

    local function findSeatInCar(car, seatName)
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

    local doRejoin  -- forward declare

    local function hookHumanoid(character)
        if humanoidSeatedConn then humanoidSeatedConn:Disconnect(); humanoidSeatedConn = nil end
        local hum = character and character:WaitForChild("Humanoid", 5)
        if not hum then return end
        humanoidSeatedConn = hum.Seated:Connect(function(isSeated, seatPart)
            if not isSeated or not seatPart then return end
            local car = getCarFromSeat(seatPart)
            if not car then return end
            persistCarRef   = car
            persistCarName  = car.Name
            persistSeatName = seatPart.Name
        end)
    end

    doRejoin = function(character)
        if not persistCarName or not persistSeatName then return end
        task.spawn(function()
            local hrp = character:WaitForChild("HumanoidRootPart", 5)
            local hum = character:WaitForChild("Humanoid", 5)
            if not hrp or not hum then return end
            task.wait(0.35)
            local car  = resolveCarAfterRespawn()
            if not car then notify("Car", "Auto rejoin: " .. persistCarName .. " not found"); return end
            local seat = findSeatInCar(car, persistSeatName)
            if not seat then seat = car:FindFirstChild("DriveSeat") end
            if not seat then notify("Car", "Auto-rejoin: seat '" .. persistSeatName .. "' doesnt exist"); return end
            hrp.CFrame = seat.CFrame * CFrame.new(0, seat.Size.Y/2 + 0.5, 0)
            task.wait(0.06)
            if not seat.Parent then return end
            local ok, msg = driveInCar(car, seat)
            if ok then
                notify("Car", "Auto rejoin " .. seat.Name .. " (" .. car.Name .. ")")
            else
                notify("Car", "Auto rejoin failed: " .. tostring(msg))
            end
        end)
    end

    -- ══════════════════════════════════════════════
    -- BUILDERS DROPDOWN VOITURES
    -- ══════════════════════════════════════════════
    local function buildSeatCarValues()
        seatCarLookup = {}; local vals = {}
        local cf = workspace:FindFirstChild("Cars")
        if cf then
            for _, car in ipairs(cf:GetChildren()) do
                if car:IsA("Model") then
                    local own   = getCarOwnerName(car)
                    local ow    = own == "vous" and "[vous]" or "[" .. own .. "]"
                    local seats = getCarSeats(car)
                    local free  = 0; for _, s in ipairs(seats) do if s.Occupant == nil then free += 1 end end
                    local lbl   = car.Name .. " " .. ow .. " " .. free .. "/" .. #seats
                    local orig  = lbl; local n = 2
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
        local car = state.selSeatCarKey and seatCarLookup[state.selSeatCarKey]
        if car and car.Parent then
            for _, s in ipairs(getCarSeats(car)) do
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
                    local own = getCarOwnerName(car)
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

    -- ══════════════════════════════════════════════
    -- WEAPON FUNCTIONS
    -- ══════════════════════════════════════════════
    local function getGun()
        local c = LocalPlayer.Character; return c and c:FindFirstChild("M9")
    end

    local function sendDamage(targetChar)
        if not targetChar then return false end
        local hum = targetChar:FindFirstChildOfClass("Humanoid")
        local hrp = targetChar:FindFirstChild("HumanoidRootPart")
        local torso = targetChar:FindFirstChild("UpperTorso") or hrp
        if not hum or not hrp then return false end
        local gun = getGun(); if not gun then return false end
        local GS = gun:FindFirstChild("GunScript_Server")
        local GL = gun:FindFirstChild("GunScript_Local")
        local ok = pcall(function()
            ReplicatedStorage.Remotes.InflictTarget:InvokeServer(gun, LocalPlayer, hum, hrp,
                ReplicatedStorage.Modules.ProjectileHandler,
                {16,2,true,13.85,false,10000,1000},
                {0,0,false,false,GS.IgniteScript,GS.IcifyScript,100,100},
                {false,5,3}, torso,
                {false,{1930359546},1,1.5,1,GL.GoreEffect})
        end)
        return ok
    end

    local function findTaseBeam()
        local function check(c) for _,t in ipairs(c:GetChildren()) do local b=t:FindFirstChild("taseBeam"); if b then return b end end end
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack"); if bp then local b=check(bp); if b then return b end end
        if LocalPlayer.Character then local b=check(LocalPlayer.Character); if b then return b end end
        for _,plr in ipairs(Players:GetPlayers()) do if plr~=LocalPlayer then
            if plr.Character then local b=check(plr.Character); if b then return b end end
            local pbp=plr:FindFirstChildOfClass("Backpack"); if pbp then local b=check(pbp); if b then return b end end
        end end
        local function srch(p,d) if d<=0 then return nil end; for _,c in ipairs(p:GetChildren()) do if c.Name=="taseBeam" then return c end; local f=srch(c,d-1); if f then return f end end end
        return srch(workspace,4)
    end

    local function getNearestPlayer()
        local mc = LocalPlayer.Character; if not mc then return nil end
        local mh = mc:FindFirstChild("HumanoidRootPart"); if not mh then return nil end
        local nearest, minD = nil, math.huge
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LocalPlayer and plr.Character then
                local h=plr.Character:FindFirstChild("HumanoidRootPart")
                if h then local d=(mh.Position-h.Position).Magnitude; if d<minD then minD=d; nearest=plr end end
            end
        end
        return nearest
    end

    local function isPoliceOrSheriff()
        local t = LocalPlayer.Team; return t and (t.Name=="Police" or t.Name=="Sheriff")
    end

    local function fireTase(tp)
        if not isPoliceOrSheriff() then return false end
        local b = findTaseBeam(); if not b then return false end
        local ok = pcall(function() ReplicatedStorage.Events.taseEvent:FireServer(b, tp) end)
        return ok
    end

    -- ══════════════════════════════════════════════
    -- KILL LOOP
    -- ══════════════════════════════════════════════
    local function startKillLoop()
        if not state.selectedPlayer then notify("Weapon","JUS select a plr who's IN THE police team"); return end
        if not getGun() then notify("Weapon","Equip ur M9(only supportin default free weapon for now)"); return end
        if state.killLoopActive then notify("Weapon","kill is already bein processed"); return end
        state.killLoopActive = true
        task.spawn(function()
            local tgt = state.selectedPlayer; local tries, maxT = 0, 80
            while state.killLoopActive and tries < maxT do
                local ch = tgt.Character; if ch then
                    local hm = ch:FindFirstChildOfClass("Humanoid")
                    if hm and hm.Health > 0 then sendDamage(ch); task.wait(0.05); tries += 1
                    else notify("Weapon", tgt.Name .. " MURDERED ✓"); break end
                else task.wait(0.1); tries += 1 end
            end
            if tries >= maxT then notify("Weapon","Couldnt rly kill him, took too long") end
            state.killLoopActive = false
        end)
    end

    -- ══════════════════════════════════════════════
    -- KILL AURA
    -- ══════════════════════════════════════════════
    local function startAura()
        if not getGun() then notify("Weapon","Equip ur M9 for murderin police guy(s) ") end
        local myTeam = LocalPlayer.Team
        if not myTeam or myTeam.Name ~= "Criminal" then notify("Weapon","Required Criminal team to kill em") end
        local timers = {}

        local function hookRespawn(plr)
            if auraRespawnConns[plr] then auraRespawnConns[plr]:Disconnect() end
            auraRespawnConns[plr] = plr.CharacterAdded:Connect(function() timers[plr] = nil end)
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then hookRespawn(plr) end
        end
        local newPlrConn = Players.PlayerAdded:Connect(function(plr) hookRespawn(plr) end)

        state.auraConn = RunService.Heartbeat:Connect(function()
            local ts = game:FindService("Teams"); if not ts then return end
            local mt = LocalPlayer.Team
            if not mt or mt.Name ~= "Criminal" then return end
            local mc = LocalPlayer.Character; if not mc then return end
            local mh = mc:FindFirstChild("HumanoidRootPart"); if not mh then return end
            local now = tick()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local pt = plr.Team
                    if pt and (pt.Name == "Police" or pt.Name == "Sheriff") then
                        local h = plr.Character:FindFirstChild("HumanoidRootPart")
                        if h and (mh.Position - h.Position).Magnitude <= state.auraRadius then
                            local last = timers[plr] or 0
                            if now - last >= 0.3 then
                                timers[plr] = now
                                task.spawn(function() sendDamage(plr.Character) end)
                            end
                        end
                    end
                end
            end
        end)
        state.auraConn_cleanup = newPlrConn
    end

    local function stopAura()
        if state.auraConn then state.auraConn:Disconnect(); state.auraConn = nil end
        if state.auraConn_cleanup then state.auraConn_cleanup:Disconnect(); state.auraConn_cleanup = nil end
        for _, c in pairs(auraRespawnConns) do pcall(function() c:Disconnect() end) end
        auraRespawnConns = {}
    end

    -- ══════════════════════════════════════════════
    -- AMMO FUNCTIONS
    -- ══════════════════════════════════════════════
    local function getAllAmmoBoxes()
        local r = {}
        for _,o in ipairs(workspace:GetChildren()) do
            if o.Name == "AmmoBox (Unlimited Use)" then table.insert(r, o) end
        end
        return r
    end

    local function applyHide()
        for _,box in ipairs(getAllAmmoBoxes()) do
            local p = {}
            if box:IsA("BasePart") then table.insert(p, box) end
            for _,d in ipairs(box:GetDescendants()) do
                if d:IsA("BasePart") then table.insert(p, d)
                elseif d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
                    pcall(function() d.Enabled = false end)
                end
            end
            for _,pt in ipairs(p) do
                pcall(function() pt.Transparency = 1; pt.CanCollide = false; pt.Massless = true end)
            end
        end
    end

    local function getBoxPart(box)
        if box:IsA("BasePart") and box:FindFirstChildOfClass("TouchInterest") then return box end
        for _,d in ipairs(box:GetDescendants()) do if d:IsA("TouchInterest") then return d.Parent end end
        if box:IsA("BasePart") then return box end
        return box:FindFirstChildWhichIsA("BasePart", true)
    end

    local function touchAmmo()
        local mc = LocalPlayer.Character; if not mc then return end
        local hrp = mc:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local boxes = getAllAmmoBoxes(); if #boxes == 0 then return end
        local part = getBoxPart(boxes[1]); if not part then return end
        if state.selAmmoMethod == "BS" then
            pcall(function() firetouchinterest(hrp,part,0); task.wait(0.02); firetouchinterest(hrp,part,1) end)
        else
            local orig = hrp.CFrame
            pcall(function() hrp.CFrame = part.CFrame + Vector3.new(0, part.Size.Y/2+1, 0) end)
            task.wait(0.08)
            pcall(function() hrp.CFrame = orig end)
        end
    end

    local function setHideLoop(v)
        state.hideLoopActive = v
        if v then
            task.spawn(function()
                while state.hideLoopActive do applyHide(); task.wait(0.1) end
            end)
        end
    end

    local function setAmmoLoop(v)
        state.ammoLoopEnabled = v
        if v and state.ammoEnabled then
            state.ammoLoopActive = true
            task.spawn(function()
                while state.ammoLoopActive and state.ammoLoopEnabled do
                    touchAmmo(); task.wait(12)
                end
            end)
        end
        if not v then state.ammoLoopActive = false end
    end

    local function setAmmoEnabled(v)
        state.ammoEnabled = v
        if v then
            if state.ammoShootConn then state.ammoShootConn:Disconnect() end
            state.ammoShootConn = LocalPlayer:GetMouse().Button1Down:Connect(function()
                task.spawn(touchAmmo)
            end)
            if state.ammoLoopEnabled then
                state.ammoLoopActive = true
                task.spawn(function()
                    while state.ammoLoopActive and state.ammoLoopEnabled and state.ammoEnabled do
                        touchAmmo(); task.wait(10)
                    end
                end)
            end
        else
            if state.ammoShootConn then state.ammoShootConn:Disconnect(); state.ammoShootConn = nil end
            state.ammoLoopActive = false
        end
    end

    -- ══════════════════════════════════════════════
    -- COLOR FUNCTIONS (logique pure, sans UI)
    -- ══════════════════════════════════════════════
    local function getPropFE(car)
        for _, child in pairs(car:GetChildren()) do
            if child:IsA("RemoteEvent") and child.Name:match("Prop_FE") then return child end
        end
        return nil
    end

    local function getCarColors(car)
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

    local function applyCarColor(car, c)
        local propFE = getPropFE(car); if not propFE then return end
        for _, part in pairs(car:GetDescendants()) do
            if part:IsA("MeshPart") and part.Name ~= "Window" and part.Name ~= "Wheel" then
                pcall(function() propFE:FireServer("UpdateColor", part, c.R * 255, c.G * 255, c.B * 255) end)
            end
        end
    end

    local function getCarsInWorkspace()
        local cars, nameCount = {}, {}
        local cf = workspace:FindFirstChild("Cars"); if not cf then return cars end
        for _, child in pairs(cf:GetChildren()) do
            if child:IsA("Model") then nameCount[child.Name] = (nameCount[child.Name] or 0) + 1 end
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

    -- ══════════════════════════════════════════════
    -- TEAM FUNCTION
    -- ══════════════════════════════════════════════
    local function teamExistsInJobsMain(name)
        local jm = workspace:FindFirstChild("jobsMain"); if not jm then return true end
        return jm:FindFirstChild(name) ~= nil
    end

    -- ══════════════════════════════════════════════
    -- FLOOR FIX CALLBACK (utilise Options passé en ctx)
    -- ══════════════════════════════════════════════
    local function floorFixCallback(v)
        if not v then return end
        local freezeConn = nil
        local charConns  = {}

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
                    if not Options["FloorFixToggle"].Value
                    or not hrp or not hrp.Parent
                    or elapsed >= 3 then
                        stopFreeze(hrp, hum); return
                    end
                end)
            end
        end

        local function getWeaponForTeam()
            local team = LocalPlayer.Team; if not team then return nil end
            if team.Name == "Criminal" then return "M9" end
            if team.Name == "Police" or team.Name == "Sheriff" then return "G17" end
            return nil
        end

        local function hookCharacter(character)
            for _, c in ipairs(charConns) do pcall(function() c:Disconnect() end) end
            charConns = {}
            stopFreeze(
                character:FindFirstChild("HumanoidRootPart"),
                character:FindFirstChildWhichIsA("Humanoid")
            )
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
                table.insert(charConns, eqConn)
                table.insert(charConns, uqConn)
            end

            local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
            if bp then for _, t in ipairs(bp:GetChildren()) do watchTool(t) end end
            for _, t in ipairs(character:GetChildren()) do watchTool(t) end
            local cc = character.ChildAdded:Connect(function(c) watchTool(c) end)
            local bc = bp and bp.ChildAdded:Connect(function(c) watchTool(c) end)
            table.insert(charConns, cc)
            if bc then table.insert(charConns, bc) end
        end

        if LocalPlayer.Character then hookCharacter(LocalPlayer.Character) end
        local sc = LocalPlayer.CharacterAdded:Connect(hookCharacter)
        table.insert(charConns, sc)
    end

    -- ══════════════════════════════════════════════
    -- INIT CONNECTIONS (CharacterAdded / PlayerRemoving)
    -- ══════════════════════════════════════════════
    if LocalPlayer.Character then hookHumanoid(LocalPlayer.Character) end

    LocalPlayer.CharacterAdded:Connect(function(character)
        hookHumanoid(character)
        if state.autoRejoinOn then doRejoin(character) end
    end)

    Players.PlayerRemoving:Connect(function(plr)
        if state.selectedPlayer == plr then
            state.killLoopActive = false
            state.taseLoopActive = false
            state.selectedPlayer = nil
            notify("Weapon", plr.Name .. " a quitte")
        end
    end)

    -- ══════════════════════════════════════════════
    -- RETOUR DU MODULE
    -- ══════════════════════════════════════════════
    return {
        -- Données
        CAR_LIST         = CAR_LIST,
        state            = state,
        seatCarLookup    = seatCarLookup,
        seatSeatLookup   = seatSeatLookup,
        stealLookup      = stealLookup,

        -- Accesseurs persist seat (lecture depuis AreSW-SWFL.lua)
        getPersistCarName  = function() return persistCarName end,
        getPersistSeatName = function() return persistSeatName end,

        -- Voitures
        findDriveSeat          = findDriveSeat,
        getCarSeats            = getCarSeats,
        isPlayerCar            = isPlayerCar,
        findValidCar           = findValidCar,
        getCarOwnerName        = getCarOwnerName,
        driveInCar             = driveInCar,
        resolveCarAfterRespawn = resolveCarAfterRespawn,
        findSeatInCar          = findSeatInCar,
        buildSeatCarValues     = buildSeatCarValues,
        buildSeatValues        = buildSeatValues,
        buildStealValues       = buildStealValues,

        -- Weapon
        getGun             = getGun,
        sendDamage         = sendDamage,
        findTaseBeam       = findTaseBeam,
        getNearestPlayer   = getNearestPlayer,
        isPoliceOrSheriff  = isPoliceOrSheriff,
        fireTase           = fireTase,

        -- Loops
        startKillLoop  = startKillLoop,
        stopKillLoop   = function() state.killLoopActive = false end,
        startAura      = startAura,
        stopAura       = stopAura,

        -- Ammo
        getAllAmmoBoxes = getAllAmmoBoxes,
        applyHide      = applyHide,
        touchAmmo      = touchAmmo,
        setHideLoop    = setHideLoop,
        setAmmoLoop    = setAmmoLoop,
        setAmmoEnabled = setAmmoEnabled,

        -- Color (logique pure)
        getPropFE          = getPropFE,
        getCarColors       = getCarColors,
        applyCarColor      = applyCarColor,
        getCarsInWorkspace = getCarsInWorkspace,

        -- Team
        teamExistsInJobsMain = teamExistsInJobsMain,

        -- Misc
        floorFixCallback = floorFixCallback,
    }
end
