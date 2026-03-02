-- ══════════════════════════════════════════════════════════════════
--  AreSW-SWFL.lua — Interface Fluent + chargement de logic.lua
--  ⚠️  REMPLACE LA LIGNE "LOGIC_RAW_URL" par l'URL raw de ton repo
--      ex: https://raw.githubusercontent.com/TON_USER/TON_REPO/main/logic.lua
-- ══════════════════════════════════════════════════════════════════

local LOGIC_RAW_URL = "https://raw.githubusercontent.com/TON_USER/TON_REPO/main/logic.lua"

-- ══════════════════════════════════════════════
-- CHARGEMENT LIBRAIRIES
-- ══════════════════════════════════════════════
local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()
local InterfaceManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
))()

local Options = Fluent.Options

local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local ProximityPromptSvc = game:GetService("ProximityPromptService")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local LocalPlayer        = Players.LocalPlayer
local PlayerGui          = LocalPlayer:WaitForChild("PlayerGui")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local vp       = workspace.CurrentCamera.ViewportSize
local WIN_W    = isMobile and math.clamp(math.floor(vp.X) - 16, 290, 370) or 580
local WIN_H    = isMobile and math.clamp(math.floor(vp.Y) - 70, 360, 500) or 460
local TAB_W    = isMobile and 72 or 160

-- ══════════════════════════════════════════════════════════════════
--  SHARED STYLE CONSTANTS
-- ══════════════════════════════════════════════════════════════════
local FL_BG      = Color3.fromRGB(45,  45,  48)
local FL_SIDEBAR = Color3.fromRGB(38,  38,  40)
local FL_ITEM    = Color3.fromRGB(55,  55,  58)
local FL_HOVER   = Color3.fromRGB(65,  65,  68)
local FL_BORDER  = Color3.fromRGB(70,  70,  73)
local FL_TXT     = Color3.fromRGB(205, 205, 205)
local FL_STXT    = Color3.fromRGB(160, 160, 162)
local FL_SEP     = Color3.fromRGB(62,  62,  65)

local T_BG   = 0.17
local T_HDR  = 0.20
local T_ITEM = 0.25
local T_SEP  = 0.55

local targetParent = pcall(gethui) and gethui() or game:GetService("CoreGui")

-- ══════════════════════════════════════════════════════════════════
--  TEAM WINDOW
-- ══════════════════════════════════════════════════════════════════
local TWGui = Instance.new("ScreenGui")
TWGui.Name           = "TeamWindow_Fluent"
TWGui.ResetOnSpawn   = false
TWGui.IgnoreGuiInset = true
TWGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
TWGui.DisplayOrder   = 10
TWGui.Enabled        = false
TWGui.Parent         = targetParent

local TW_W = 210

local TeamWin = Instance.new("Frame")
TeamWin.Name                   = "TeamWin"
TeamWin.Size                   = UDim2.new(0, TW_W, 0, 280)
TeamWin.Position               = UDim2.new(0.5, 8, 0.5, -140)
TeamWin.BackgroundColor3       = FL_BG
TeamWin.BackgroundTransparency = T_BG
TeamWin.BorderSizePixel        = 0
TeamWin.Active                 = true
TeamWin.Draggable              = true
TeamWin.ClipsDescendants       = true
TeamWin.Visible                = false
TeamWin.Parent                 = TWGui
Instance.new("UICorner", TeamWin).CornerRadius = UDim.new(0, 9)
local twBd = Instance.new("UIStroke", TeamWin)
twBd.Color = FL_BORDER; twBd.Thickness = 1

local twHdr = Instance.new("Frame")
twHdr.Name             = "Header"
twHdr.Size             = UDim2.new(1, 0, 0, 34)
twHdr.BackgroundColor3 = FL_BG
twHdr.BackgroundTransparency = T_BG
twHdr.BorderSizePixel  = 0
twHdr.ZIndex           = 2
twHdr.Parent           = TeamWin
Instance.new("UICorner", twHdr).CornerRadius = UDim.new(0, 9)
local twHdrFix = Instance.new("Frame")
twHdrFix.Size             = UDim2.new(1, 0, 0, 9)
twHdrFix.Position         = UDim2.new(0, 0, 1, -9)
twHdrFix.BackgroundColor3 = FL_BG
twHdrFix.BackgroundTransparency = T_BG
twHdrFix.BorderSizePixel  = 0
twHdrFix.ZIndex           = 2
twHdrFix.Parent           = twHdr

local twHdrTitle = Instance.new("TextLabel")
twHdrTitle.Size                 = UDim2.new(1, -40, 1, 0)
twHdrTitle.Position             = UDim2.new(0, 12, 0, 0)
twHdrTitle.BackgroundTransparency = 1
twHdrTitle.Text                 = "AreSW - SWFL - Team Selector"
twHdrTitle.Font                 = Enum.Font.GothamBold
twHdrTitle.TextSize             = 11.5
twHdrTitle.TextColor3           = FL_TXT
twHdrTitle.TextXAlignment       = Enum.TextXAlignment.Left
twHdrTitle.ZIndex               = 3
twHdrTitle.Parent               = twHdr

local twHdrClose = Instance.new("TextButton")
twHdrClose.Size                = UDim2.new(0, 20, 0, 20)
twHdrClose.Position            = UDim2.new(1, -26, 0.5, -10)
twHdrClose.BackgroundColor3    = FL_ITEM
twHdrClose.BackgroundTransparency = T_ITEM
twHdrClose.BorderSizePixel     = 0
twHdrClose.Text                = "x"
twHdrClose.Font                = Enum.Font.GothamBold
twHdrClose.TextSize            = 9
twHdrClose.TextColor3          = FL_STXT
twHdrClose.AutoButtonColor     = false
twHdrClose.ZIndex              = 4
Instance.new("UICorner", twHdrClose).CornerRadius = UDim.new(0, 5)
twHdrClose.Parent = twHdr

local twHdrLine = Instance.new("Frame")
twHdrLine.Size             = UDim2.new(1, 0, 0, 1)
twHdrLine.Position         = UDim2.new(0, 0, 0, 34)
twHdrLine.BackgroundColor3 = FL_BORDER
twHdrLine.BackgroundTransparency = T_SEP
twHdrLine.BorderSizePixel  = 0
twHdrLine.ZIndex           = 2
twHdrLine.Parent           = TeamWin

local twDrop = Instance.new("TextButton")
twDrop.Name                = "DropBtn"
twDrop.Size                = UDim2.new(1, -20, 0, 30)
twDrop.Position            = UDim2.new(0, 10, 0, 44)
twDrop.BackgroundColor3    = FL_ITEM
twDrop.BackgroundTransparency = T_ITEM
twDrop.BorderSizePixel     = 0
twDrop.Text                = "  Selectionner..."
twDrop.Font                = Enum.Font.Gotham
twDrop.TextSize            = 11
twDrop.TextColor3          = FL_STXT
twDrop.TextXAlignment      = Enum.TextXAlignment.Left
twDrop.AutoButtonColor     = false
twDrop.ZIndex              = 3
twDrop.Parent              = TeamWin
Instance.new("UICorner", twDrop).CornerRadius = UDim.new(0, 6)
local twDropBd = Instance.new("UIStroke", twDrop)
twDropBd.Color = FL_BORDER; twDropBd.Thickness = 1

local twDropArrow = Instance.new("TextLabel")
twDropArrow.Size                  = UDim2.new(0, 20, 1, 0)
twDropArrow.Position              = UDim2.new(1, -22, 0, 0)
twDropArrow.BackgroundTransparency = 1
twDropArrow.Text                  = "▲"
twDropArrow.Font                  = Enum.Font.GothamBold
twDropArrow.TextSize              = 9
twDropArrow.TextColor3            = FL_STXT
twDropArrow.ZIndex                = 4
twDropArrow.Parent                = twDrop

local twListOuter = Instance.new("Frame")
twListOuter.Name              = "ListOuter"
twListOuter.Size              = UDim2.new(1, -20, 0, 0)
twListOuter.Position          = UDim2.new(0, 10, 0, 78)
twListOuter.BackgroundTransparency = 1
twListOuter.ClipsDescendants  = true
twListOuter.ZIndex            = 3
twListOuter.Parent            = TeamWin

local twScroll = Instance.new("ScrollingFrame")
twScroll.Size                  = UDim2.new(1, 0, 1, 0)
twScroll.BackgroundTransparency = 1
twScroll.BorderSizePixel       = 0
twScroll.ScrollBarThickness    = 2
twScroll.ScrollBarImageColor3  = FL_BORDER
twScroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
twScroll.CanvasSize            = UDim2.new(0, 0, 0, 0)
twScroll.ScrollingDirection    = Enum.ScrollingDirection.Y
twScroll.ZIndex                = 4
twScroll.Parent                = twListOuter
local twScrollL = Instance.new("UIListLayout", twScroll)
twScrollL.SortOrder = Enum.SortOrder.LayoutOrder
twScrollL.Padding   = UDim.new(0, 0)

local twSep = Instance.new("Frame")
twSep.Size             = UDim2.new(1, -20, 0, 1)
twSep.Position         = UDim2.new(0, 10, 0, 80)
twSep.BackgroundColor3 = FL_BORDER
twSep.BackgroundTransparency = T_SEP
twSep.BorderSizePixel  = 0
twSep.ZIndex           = 2
twSep.Parent           = TeamWin

local twActY = 88

local twJoin = Instance.new("TextButton")
twJoin.Size             = UDim2.new(0, 94, 0, 28)
twJoin.Position         = UDim2.new(0, 10, 0, twActY)
twJoin.BackgroundColor3 = FL_ITEM
twJoin.BackgroundTransparency = T_ITEM
twJoin.BorderSizePixel  = 0
twJoin.Text             = "Join team"
twJoin.Font             = Enum.Font.GothamBold
twJoin.TextSize         = 11
twJoin.TextColor3       = FL_TXT
twJoin.AutoButtonColor  = false
twJoin.ZIndex           = 3
twJoin.Parent           = TeamWin
Instance.new("UICorner", twJoin).CornerRadius = UDim.new(0, 6)
local twJoinBd = Instance.new("UIStroke", twJoin)
twJoinBd.Color = FL_BORDER; twJoinBd.Thickness = 1

local twReFire = Instance.new("TextButton")
twReFire.Size             = UDim2.new(0, 94, 0, 28)
twReFire.Position         = UDim2.new(0, 108, 0, twActY)
twReFire.BackgroundColor3 = FL_ITEM
twReFire.BackgroundTransparency = T_ITEM
twReFire.BorderSizePixel  = 0
twReFire.Text             = "Rejoin"
twReFire.Font             = Enum.Font.Gotham
twReFire.TextSize         = 11
twReFire.TextColor3       = FL_STXT
twReFire.AutoButtonColor  = false
twReFire.ZIndex           = 3
twReFire.Parent           = TeamWin
Instance.new("UICorner", twReFire).CornerRadius = UDim.new(0, 6)
local twRefBd = Instance.new("UIStroke", twReFire)
twRefBd.Color = FL_BORDER; twRefBd.Thickness = 1

local twStatus = Instance.new("TextLabel")
twStatus.Size                  = UDim2.new(1, -20, 0, 16)
twStatus.Position              = UDim2.new(0, 10, 0, twActY + 32)
twStatus.BackgroundTransparency = 1
twStatus.Text                  = "..."
twStatus.Font                  = Enum.Font.Gotham
twStatus.TextSize              = 10
twStatus.TextColor3            = FL_STXT
twStatus.TextXAlignment        = Enum.TextXAlignment.Left
twStatus.ZIndex                = 2
twStatus.Parent                = TeamWin

local TW_LIST_H = 100

-- ══════════════════════════════════════════════════════════════════
--  COLOR WINDOW
-- ══════════════════════════════════════════════════════════════════
local colorCycleActive  = false
local colorSelectedCar  = nil
local colorCarColors    = {}

local CWGui = Instance.new("ScreenGui")
CWGui.Name           = "ColorWindow_Fluent"
CWGui.ResetOnSpawn   = false
CWGui.IgnoreGuiInset = true
CWGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
CWGui.DisplayOrder   = 10
CWGui.Enabled        = false
CWGui.Parent         = targetParent

local CW_W = 210

local ColorWin = Instance.new("Frame")
ColorWin.Name                   = "ColorWin"
ColorWin.Size                   = UDim2.new(0, CW_W, 0, 310)
ColorWin.Position               = UDim2.new(0.5, 8 + TW_W + 12, 0.5, -140)
ColorWin.BackgroundColor3       = FL_BG
ColorWin.BackgroundTransparency = T_BG
ColorWin.BorderSizePixel        = 0
ColorWin.Active                 = true
ColorWin.Draggable              = true
ColorWin.ClipsDescendants       = true
ColorWin.Visible                = false
ColorWin.Parent                 = CWGui
Instance.new("UICorner", ColorWin).CornerRadius = UDim.new(0, 9)
local cwBd = Instance.new("UIStroke", ColorWin)
cwBd.Color = FL_BORDER; cwBd.Thickness = 1

local cwHdr = Instance.new("Frame")
cwHdr.Name             = "Header"
cwHdr.Size             = UDim2.new(1, 0, 0, 34)
cwHdr.BackgroundColor3 = FL_BG
cwHdr.BackgroundTransparency = T_BG
cwHdr.BorderSizePixel  = 0
cwHdr.ZIndex           = 2
cwHdr.Parent           = ColorWin
Instance.new("UICorner", cwHdr).CornerRadius = UDim.new(0, 9)

local cwHdrFix = Instance.new("Frame")
cwHdrFix.Size             = UDim2.new(1, 0, 0, 9)
cwHdrFix.Position         = UDim2.new(0, 0, 1, -9)
cwHdrFix.BackgroundColor3 = FL_BG
cwHdrFix.BackgroundTransparency = T_BG
cwHdrFix.BorderSizePixel  = 0
cwHdrFix.ZIndex           = 2
cwHdrFix.Parent           = cwHdr

local cwHdrTitle = Instance.new("TextLabel")
cwHdrTitle.Size                 = UDim2.new(1, -40, 1, 0)
cwHdrTitle.Position             = UDim2.new(0, 12, 0, 0)
cwHdrTitle.BackgroundTransparency = 1
cwHdrTitle.Text                 = "AreSW - SWFL - Color Changer"
cwHdrTitle.Font                 = Enum.Font.GothamBold
cwHdrTitle.TextSize             = 10.15
cwHdrTitle.TextColor3           = FL_TXT
cwHdrTitle.TextXAlignment       = Enum.TextXAlignment.Left
cwHdrTitle.ZIndex               = 3
cwHdrTitle.Parent               = cwHdr

local cwHdrMin = Instance.new("TextButton")
cwHdrMin.Size                = UDim2.new(0, 20, 0, 20)
cwHdrMin.Position            = UDim2.new(1, -50, 0.5, -10)
cwHdrMin.BackgroundColor3    = FL_ITEM
cwHdrMin.BackgroundTransparency = T_ITEM
cwHdrMin.BorderSizePixel     = 0
cwHdrMin.Text                = "─"
cwHdrMin.Font                = Enum.Font.GothamBold
cwHdrMin.TextSize            = 9
cwHdrMin.TextColor3          = FL_STXT
cwHdrMin.AutoButtonColor     = false
cwHdrMin.ZIndex              = 4
Instance.new("UICorner", cwHdrMin).CornerRadius = UDim.new(0, 5)
cwHdrMin.Parent = cwHdr

local cwHdrClose = Instance.new("TextButton")
cwHdrClose.Size                = UDim2.new(0, 20, 0, 20)
cwHdrClose.Position            = UDim2.new(1, -26, 0.5, -10)
cwHdrClose.BackgroundColor3    = FL_ITEM
cwHdrClose.BackgroundTransparency = T_ITEM
cwHdrClose.BorderSizePixel     = 0
cwHdrClose.Text                = "X"
cwHdrClose.Font                = Enum.Font.GothamBold
cwHdrClose.TextSize            = 9
cwHdrClose.TextColor3          = FL_STXT
cwHdrClose.AutoButtonColor     = false
cwHdrClose.ZIndex              = 4
Instance.new("UICorner", cwHdrClose).CornerRadius = UDim.new(0, 5)
cwHdrClose.Parent = cwHdr

local cwHdrLine = Instance.new("Frame")
cwHdrLine.Size             = UDim2.new(1, 0, 0, 1)
cwHdrLine.Position         = UDim2.new(0, 0, 0, 34)
cwHdrLine.BackgroundColor3 = FL_BORDER
cwHdrLine.BackgroundTransparency = T_SEP
cwHdrLine.BorderSizePixel  = 0
cwHdrLine.ZIndex           = 2
cwHdrLine.Parent           = ColorWin

local cwDrop = Instance.new("TextButton")
cwDrop.Name                = "DropBtn"
cwDrop.Size                = UDim2.new(1, -20, 0, 30)
cwDrop.Position            = UDim2.new(0, 10, 0, 44)
cwDrop.BackgroundColor3    = FL_ITEM
cwDrop.BackgroundTransparency = T_ITEM
cwDrop.BorderSizePixel     = 0
cwDrop.Text                = "  Selectionner vehicule..."
cwDrop.Font                = Enum.Font.Gotham
cwDrop.TextSize            = 11
cwDrop.TextColor3          = FL_STXT
cwDrop.TextXAlignment      = Enum.TextXAlignment.Left
cwDrop.AutoButtonColor     = false
cwDrop.ZIndex              = 3
cwDrop.Parent              = ColorWin
Instance.new("UICorner", cwDrop).CornerRadius = UDim.new(0, 6)
local cwDropBd = Instance.new("UIStroke", cwDrop)
cwDropBd.Color = FL_BORDER; cwDropBd.Thickness = 1

local cwDropArrow = Instance.new("TextLabel")
cwDropArrow.Size                  = UDim2.new(0, 20, 1, 0)
cwDropArrow.Position              = UDim2.new(1, -22, 0, 0)
cwDropArrow.BackgroundTransparency = 1
cwDropArrow.Text                  = "▼"
cwDropArrow.Font                  = Enum.Font.GothamBold
cwDropArrow.TextSize              = 9
cwDropArrow.TextColor3            = FL_STXT
cwDropArrow.ZIndex                = 4
cwDropArrow.Parent                = cwDrop

local cwListOuter = Instance.new("Frame")
cwListOuter.Name              = "ListOuter"
cwListOuter.Size              = UDim2.new(1, -20, 0, 0)
cwListOuter.Position          = UDim2.new(0, 10, 0, 78)
cwListOuter.BackgroundTransparency = 1
cwListOuter.ClipsDescendants  = true
cwListOuter.ZIndex            = 3
cwListOuter.Parent            = ColorWin

local cwScroll = Instance.new("ScrollingFrame")
cwScroll.Size                  = UDim2.new(1, 0, 1, 0)
cwScroll.BackgroundTransparency = 1
cwScroll.BorderSizePixel       = 0
cwScroll.ScrollBarThickness    = 2
cwScroll.ScrollBarImageColor3  = FL_BORDER
cwScroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
cwScroll.CanvasSize            = UDim2.new(0, 0, 0, 0)
cwScroll.ScrollingDirection    = Enum.ScrollingDirection.Y
cwScroll.ZIndex                = 4
cwScroll.Parent                = cwListOuter
local cwScrollL = Instance.new("UIListLayout", cwScroll)
cwScrollL.SortOrder = Enum.SortOrder.LayoutOrder
cwScrollL.Padding   = UDim.new(0, 0)

local cwSep = Instance.new("Frame")
cwSep.Size             = UDim2.new(1, -20, 0, 1)
cwSep.Position         = UDim2.new(0, 10, 0, 80)
cwSep.BackgroundColor3 = FL_BORDER
cwSep.BackgroundTransparency = T_SEP
cwSep.BorderSizePixel  = 0
cwSep.ZIndex           = 2
cwSep.Parent           = ColorWin

local cwPreviewRow = Instance.new("Frame")
cwPreviewRow.Size             = UDim2.new(1, -20, 0, 20)
cwPreviewRow.Position         = UDim2.new(0, 10, 0, 88)
cwPreviewRow.BackgroundTransparency = 1
cwPreviewRow.BorderSizePixel  = 0
cwPreviewRow.ZIndex           = 3
cwPreviewRow.Parent           = ColorWin

local cwCycleBtn
local setCWS

local cwPreviews = {}
local cwHalos    = {}

-- Les swatches couleur sont créés après L (logic) donc on forward-declare
-- leur logique click et on les branche après init de L
for i = 1, 5 do
    local halo = Instance.new("Frame")
    halo.Size             = UDim2.new(0, 32, 0, 24)
    halo.Position         = UDim2.new(0, (i - 1) * 32 - 2, 0.5, -12)
    halo.BackgroundTransparency = 1
    halo.BorderSizePixel  = 0
    halo.ZIndex           = 3
    halo.Visible          = false
    halo.Parent           = cwPreviewRow
    Instance.new("UICorner", halo).CornerRadius = UDim.new(0, 6)
    local haloBd = Instance.new("UIStroke", halo)
    haloBd.Color = Color3.fromRGB(235, 235, 235); haloBd.Thickness = 1.5
    cwHalos[i] = halo

    local sw = Instance.new("TextButton")
    sw.Size             = UDim2.new(0, 28, 1, 0)
    sw.Position         = UDim2.new(0, (i - 1) * 32, 0, 0)
    sw.BackgroundColor3 = Color3.fromRGB(50, 50, 52)
    sw.BorderSizePixel  = 0
    sw.Text             = ""
    sw.AutoButtonColor  = false
    sw.ZIndex           = 4
    sw.Parent           = cwPreviewRow
    Instance.new("UICorner", sw).CornerRadius = UDim.new(0, 4)
    local swBd = Instance.new("UIStroke", sw)
    swBd.Color = FL_BORDER; swBd.Thickness = 1
    cwPreviews[i] = sw
end

local cwSep2 = Instance.new("Frame")
cwSep2.Size             = UDim2.new(1, -20, 0, 1)
cwSep2.Position         = UDim2.new(0, 10, 0, 115)
cwSep2.BackgroundColor3 = FL_BORDER
cwSep2.BackgroundTransparency = T_SEP
cwSep2.BorderSizePixel  = 0
cwSep2.ZIndex           = 2
cwSep2.Parent           = ColorWin

cwCycleBtn = Instance.new("TextButton")
cwCycleBtn.Size             = UDim2.new(1, -20, 0, 28)
cwCycleBtn.Position         = UDim2.new(0, 10, 0, 123)
cwCycleBtn.BackgroundColor3 = FL_ITEM
cwCycleBtn.BackgroundTransparency = T_ITEM
cwCycleBtn.BorderSizePixel  = 0
cwCycleBtn.Text             = "▶  Start Color switches(rainbow effect ig)"
cwCycleBtn.Font             = Enum.Font.GothamBold
cwCycleBtn.TextSize         = 11
cwCycleBtn.TextColor3       = FL_TXT
cwCycleBtn.AutoButtonColor  = false
cwCycleBtn.ZIndex           = 3
cwCycleBtn.Parent           = ColorWin
Instance.new("UICorner", cwCycleBtn).CornerRadius = UDim.new(0, 6)
local cwCycleBd = Instance.new("UIStroke", cwCycleBtn)
cwCycleBd.Color = FL_BORDER; cwCycleBd.Thickness = 1

local cwRefresh = Instance.new("TextButton")
cwRefresh.Size             = UDim2.new(1, -20, 0, 28)
cwRefresh.Position         = UDim2.new(0, 10, 0, 157)
cwRefresh.BackgroundColor3 = FL_ITEM
cwRefresh.BackgroundTransparency = T_ITEM
cwRefresh.BorderSizePixel  = 0
cwRefresh.Text             = "Refresh vehicules"
cwRefresh.Font             = Enum.Font.Gotham
cwRefresh.TextSize         = 11
cwRefresh.TextColor3       = FL_STXT
cwRefresh.AutoButtonColor  = false
cwRefresh.ZIndex           = 3
cwRefresh.Parent           = ColorWin
Instance.new("UICorner", cwRefresh).CornerRadius = UDim.new(0, 6)
local cwRefBd2 = Instance.new("UIStroke", cwRefresh)
cwRefBd2.Color = FL_BORDER; cwRefBd2.Thickness = 1

local cwStatus = Instance.new("TextLabel")
cwStatus.Size                  = UDim2.new(1, -20, 0, 16)
cwStatus.Position              = UDim2.new(0, 10, 0, 191)
cwStatus.BackgroundTransparency = 1
cwStatus.Text                  = "..."
cwStatus.Font                  = Enum.Font.Gotham
cwStatus.TextSize              = 10
cwStatus.TextColor3            = FL_STXT
cwStatus.TextXAlignment        = Enum.TextXAlignment.Left
cwStatus.ZIndex                = 2
cwStatus.Parent                = ColorWin

local CW_LIST_H = 100

-- ══════════════════════════════════════════════
-- MAIN WINDOW FLUENT
-- ══════════════════════════════════════════════
local Window = Fluent:CreateWindow({
    Title       = "AreSW - SWFL",
    SubTitle    = "[PLACEHOLDER]",
    TabWidth    = TAB_W,
    Size        = UDim2.fromOffset(WIN_W, WIN_H),
    Acrylic     = false,
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl,
})

-- ══════════════════════════════════════════════
-- NOTIFY HELPER (défini ici, passé à logic.lua)
-- ══════════════════════════════════════════════
local function notify(title, msg, dur)
    Fluent:Notify({ Title = title or "GUI", Content = msg or "", Duration = dur or 3 })
end

-- ══════════════════════════════════════════════
-- CHARGEMENT DE LOGIC.LUA DEPUIS GITHUB
-- ══════════════════════════════════════════════
local LogicInit = loadstring(game:HttpGet(LOGIC_RAW_URL))()
local L = LogicInit({ notify = notify, Options = Options })

-- ══════════════════════════════════════════════
-- LOGIQUE TEAM WINDOW (UI dans ce fichier, fonctions via L)
-- ══════════════════════════════════════════════
local selectedTeamColor = nil
local teamBtns          = {}
local listOpen          = false
local dropSelectedName  = nil

local function setTWS(msg, ok)
    twStatus.Text = msg
    twStatus.TextColor3 = ok == true  and Color3.fromRGB(100, 210, 100)
                       or ok == false and Color3.fromRGB(220,  70,  70)
                       or FL_STXT
end

local function updateTWLayout()
    local lh = listOpen and TW_LIST_H or 0
    local listBottom = 78 + lh
    twSep.Position    = UDim2.new(0, 10, 0, listBottom + 4)
    twJoin.Position   = UDim2.new(0, 10,  0, listBottom + 12)
    twReFire.Position = UDim2.new(0, 108, 0, listBottom + 12)
    twStatus.Position = UDim2.new(0, 10,  0, listBottom + 44)
    TeamWin.Size      = UDim2.new(0, TW_W, 0, listBottom + 12 + 28 + 20 + 6)
    twListOuter.Size  = UDim2.new(1, -20, 0, lh)
    twDropArrow.Text  = listOpen and "▲" or "▼"
end

local function buildTeamList()
    for _, b in ipairs(teamBtns) do pcall(function() b:Destroy() end) end
    teamBtns = {}; selectedTeamColor = nil; dropSelectedName = nil
    twDrop.Text = "  Select..."
    local ts = game:FindService("Teams")
    if not ts then setTWS("Teams introuvable", false); return end
    local count = 0
    for idx, team in ipairs(ts:GetTeams()) do
        -- Utilise la fonction de logic.lua via L
        local include = (team.Name == "Unemployed") or L.teamExistsInJobsMain(team.Name)
        if include then
            local row = Instance.new("Frame")
            row.Size             = UDim2.new(1, 0, 0, 28)
            row.BackgroundColor3 = FL_HOVER
            row.BackgroundTransparency = 1
            row.BorderSizePixel  = 0
            row.LayoutOrder      = idx
            row.ZIndex           = 5
            row.Parent           = twScroll
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
            local rowSep = Instance.new("Frame", row)
            rowSep.Size             = UDim2.new(1, 0, 0, 1)
            rowSep.Position         = UDim2.new(0, 0, 1, -1)
            rowSep.BackgroundColor3 = FL_SEP
            rowSep.BackgroundTransparency = 0.3
            rowSep.BorderSizePixel  = 0
            rowSep.ZIndex           = 6
            local rowBtn = Instance.new("TextButton", row)
            rowBtn.Size                 = UDim2.new(1, 0, 1, 0)
            rowBtn.BackgroundTransparency = 1
            rowBtn.BorderSizePixel      = 0
            rowBtn.Text                 = "  " .. team.Name
            rowBtn.Font                 = Enum.Font.Gotham
            rowBtn.TextSize             = 11
            rowBtn.TextColor3           = FL_TXT
            rowBtn.TextXAlignment       = Enum.TextXAlignment.Left
            rowBtn.AutoButtonColor      = false
            rowBtn.ZIndex               = 7
            table.insert(teamBtns, row)
            rowBtn.MouseEnter:Connect(function()
                if team.TeamColor ~= selectedTeamColor then row.BackgroundTransparency = 0 end
            end)
            rowBtn.MouseLeave:Connect(function()
                if team.TeamColor ~= selectedTeamColor then row.BackgroundTransparency = 1 end
            end)
            rowBtn.MouseButton1Click:Connect(function()
                for _, b in ipairs(teamBtns) do
                    pcall(function()
                        b.BackgroundTransparency = 1
                        b:FindFirstChildOfClass("TextButton").TextColor3 = FL_TXT
                    end)
                end
                row.BackgroundTransparency = 0
                rowBtn.TextColor3 = FL_TXT
                selectedTeamColor = team.TeamColor
                dropSelectedName  = team.Name
                listOpen  = false
                updateTWLayout()
                twDrop.Text       = "  " .. team.Name
                twDrop.TextColor3 = FL_TXT
                setTWS("Selectionne : " .. team.Name, nil)
            end)
            count += 1
        end
    end
    if count == 0 then setTWS("Aucune team disponible", false)
    else setTWS(count .. " team(s)", nil) end
end

twDrop.MouseButton1Click:Connect(function() listOpen = not listOpen; updateTWLayout() end)

for _, btn in ipairs({twJoin, twReFire, twHdrClose}) do
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = FL_HOVER; btn.BackgroundTransparency = T_ITEM - 0.05 end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = FL_ITEM; btn.BackgroundTransparency = T_ITEM end)
end
twHdrClose.MouseEnter:Connect(function() twHdrClose.BackgroundColor3 = Color3.fromRGB(190,50,50); twHdrClose.BackgroundTransparency = 0.1 end)
twHdrClose.MouseLeave:Connect(function() twHdrClose.BackgroundColor3 = FL_ITEM; twHdrClose.BackgroundTransparency = T_ITEM end)

twHdrClose.MouseButton1Click:Connect(function()
    TeamWin.Visible = false
    pcall(function()
        local tog = Options["ShowTeamWin"]
        if tog then rawset(tog, "Value", false); pcall(function() tog:OnChanged() end) end
    end)
end)

twJoin.MouseButton1Click:Connect(function()
    if not selectedTeamColor then setTWS("Jus select a team u want to join in", false); return end
    local te = ReplicatedStorage:FindFirstChild("TeamEvent")
    if not te then setTWS("TeamEvent introuvable", false); return end
    local ok = pcall(function() te:FireServer(selectedTeamColor) end)
    setTWS(ok and ("joined : " .. tostring(dropSelectedName)) or "Error", ok)
end)

twReFire.MouseButton1Click:Connect(function()
    local mt = LocalPlayer.Team
    if not mt then setTWS("Pas de team", false); return end
    local te = ReplicatedStorage:FindFirstChild("TeamEvent")
    if not te then setTWS("TeamEvent introuvable", false); return end
    local ok = pcall(function() te:FireServer(mt.TeamColor) end)
    setTWS(ok and ("Resent : " .. mt.Name) or "Error", ok)
end)

updateTWLayout()

-- ══════════════════════════════════════════════
-- LOGIQUE COLOR WINDOW (UI dans ce fichier, fonctions via L)
-- ══════════════════════════════════════════════
setCWS = function(msg, ok)
    cwStatus.Text = msg
    cwStatus.TextColor3 = ok == true  and Color3.fromRGB(100, 210, 100)
                       or ok == false and Color3.fromRGB(220,  70,  70)
                       or FL_STXT
end

local function updateCWLayout()
    local lh = cwListOpen and CW_LIST_H or 0
    local listBottom = 78 + lh
    cwSep.Position        = UDim2.new(0, 10, 0, listBottom + 4)
    cwPreviewRow.Position = UDim2.new(0, 10, 0, listBottom + 12)
    cwSep2.Position       = UDim2.new(0, 10, 0, listBottom + 38)
    cwCycleBtn.Position   = UDim2.new(0, 10, 0, listBottom + 46)
    cwRefresh.Position    = UDim2.new(0, 10, 0, listBottom + 80)
    cwStatus.Position     = UDim2.new(0, 10, 0, listBottom + 112)
    ColorWin.Size         = UDim2.new(0, CW_W, 0, listBottom + 112 + 20)
    cwListOuter.Size      = UDim2.new(1, -20, 0, lh)
    cwDropArrow.Text      = cwListOpen and "▲" or "▼"
end

-- cwListOpen doit être accessible dans updateCWLayout ci-dessus, on le déclare ici
local cwCarBtns  = {}
local cwListOpen = false

-- On redefine updateCWLayout maintenant que cwListOpen existe (closure)
updateCWLayout = function()
    local lh = cwListOpen and CW_LIST_H or 0
    local listBottom = 78 + lh
    cwSep.Position        = UDim2.new(0, 10, 0, listBottom + 4)
    cwPreviewRow.Position = UDim2.new(0, 10, 0, listBottom + 12)
    cwSep2.Position       = UDim2.new(0, 10, 0, listBottom + 38)
    cwCycleBtn.Position   = UDim2.new(0, 10, 0, listBottom + 46)
    cwRefresh.Position    = UDim2.new(0, 10, 0, listBottom + 80)
    cwStatus.Position     = UDim2.new(0, 10, 0, listBottom + 112)
    ColorWin.Size         = UDim2.new(0, CW_W, 0, listBottom + 112 + 20)
    cwListOuter.Size      = UDim2.new(1, -20, 0, lh)
    cwDropArrow.Text      = cwListOpen and "▲" or "▼"
end

local function updateColorPreviews()
    for i = 1, 5 do
        if colorCarColors[i] then
            cwPreviews[i].BackgroundColor3 = colorCarColors[i]
            local swBd = cwPreviews[i]:FindFirstChildOfClass("UIStroke")
            if swBd then swBd.Color = FL_BORDER end
        else
            cwPreviews[i].BackgroundColor3 = Color3.fromRGB(50, 50, 52)
        end
    end
end

-- Branchement des clicks swatches (maintenant que L et setCWS existent)
for i = 1, 5 do
    local sw  = cwPreviews[i]
    local idx = i
    sw.MouseButton1Click:Connect(function()
        if not colorSelectedCar or not colorSelectedCar.Parent then
            setCWS("Jus select a vehicule", false); return
        end
        if not colorCarColors[idx] then
            setCWS("Color wasnt found(probably path changed or bug, if u did smth with dex, stop for ur own sake)", false); return
        end
        colorCycleActive = false
        cwCycleBtn.Text = "▶  Start Color switches(rainbow effect ig)"
        L.applyCarColor(colorSelectedCar, colorCarColors[idx])   -- via logic.lua
        for j = 1, 5 do
            local bd = cwPreviews[j]:FindFirstChildOfClass("UIStroke")
            if bd then bd.Color = (j == idx) and FL_TXT or FL_BORDER; bd.Thickness = (j == idx) and 2 or 1 end
            cwHalos[j].Visible = (j == idx)
        end
        setCWS("Color " .. idx .. " applied", true)
    end)
    sw.MouseEnter:Connect(function()
        if colorCarColors[idx] then
            local bd = sw:FindFirstChildOfClass("UIStroke")
            if bd and bd.Thickness == 1 then bd.Color = FL_TXT end
        end
    end)
    sw.MouseLeave:Connect(function()
        local bd = sw:FindFirstChildOfClass("UIStroke")
        if bd and bd.Thickness == 1 then bd.Color = FL_BORDER end
    end)
end

local function buildColorCarList()
    for _, b in ipairs(cwCarBtns) do pcall(function() b:Destroy() end) end
    cwCarBtns = {}
    colorCycleActive = false
    cwCycleBtn.Text = "▶  Start Color switches(rainbow effect ig)"
    cwCycleBtn.BackgroundColor3 = FL_ITEM

    local cars = L.getCarsInWorkspace()   -- via logic.lua
    if #cars == 0 then setCWS("No vehicules was found", false); return end

    for idx, car in ipairs(cars) do
        local row = Instance.new("Frame")
        row.Size             = UDim2.new(1, 0, 0, 28)
        row.BackgroundColor3 = FL_HOVER
        row.BackgroundTransparency = 1
        row.BorderSizePixel  = 0
        row.LayoutOrder      = idx
        row.ZIndex           = 5
        row.Parent           = cwScroll
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

        local rowSep = Instance.new("Frame", row)
        rowSep.Size             = UDim2.new(1, 0, 0, 1)
        rowSep.Position         = UDim2.new(0, 0, 1, -1)
        rowSep.BackgroundColor3 = FL_SEP
        rowSep.BackgroundTransparency = 0.3
        rowSep.BorderSizePixel  = 0
        rowSep.ZIndex           = 6

        local rowBtn = Instance.new("TextButton", row)
        rowBtn.Size                 = UDim2.new(1, 0, 1, 0)
        rowBtn.BackgroundTransparency = 1
        rowBtn.BorderSizePixel      = 0
        rowBtn.Text                 = "  " .. car.label
        rowBtn.Font                 = Enum.Font.Gotham
        rowBtn.TextSize             = 11
        rowBtn.TextColor3           = FL_TXT
        rowBtn.TextXAlignment       = Enum.TextXAlignment.Left
        rowBtn.AutoButtonColor      = false
        rowBtn.ZIndex               = 7

        table.insert(cwCarBtns, row)

        rowBtn.MouseEnter:Connect(function()
            if colorSelectedCar ~= car.model then row.BackgroundTransparency = 0 end
        end)
        rowBtn.MouseLeave:Connect(function()
            if colorSelectedCar ~= car.model then row.BackgroundTransparency = 1 end
        end)
        rowBtn.MouseButton1Click:Connect(function()
            colorCycleActive = false
            cwCycleBtn.Text = "▶  Start Color switches(rainbow effect ig)"
            cwCycleBtn.BackgroundColor3 = FL_ITEM
            for _, b in ipairs(cwCarBtns) do
                pcall(function()
                    b.BackgroundTransparency = 1
                    b:FindFirstChildOfClass("TextButton").TextColor3 = FL_TXT
                end)
            end
            row.BackgroundTransparency = 0
            rowBtn.TextColor3 = FL_TXT
            colorSelectedCar = car.model
            cwDrop.Text       = "  " .. car.label
            cwDrop.TextColor3 = FL_TXT
            cwListOpen = false
            updateCWLayout()
            colorCarColors = L.getCarColors(car.model)   -- via logic.lua
            updateColorPreviews()
            if #colorCarColors > 0 then
                setCWS(#colorCarColors .. " Found", true)
            else
                setCWS("Dang no color found", false)
            end
        end)
    end
    setCWS(#cars .. " vehicule(s)", nil)
end

cwDrop.MouseButton1Click:Connect(function()
    cwListOpen = not cwListOpen; updateCWLayout()
end)

cwRefresh.MouseButton1Click:Connect(function()
    buildColorCarList(); setCWS("Refreshed List", nil)
end)

cwCycleBtn.MouseButton1Click:Connect(function()
    if not colorSelectedCar then setCWS("JUS select A vEhiCULE", false); return end
    if not colorSelectedCar.Parent then setCWS("Well ig u respawned ur car or its too far away", false); return end
    if #colorCarColors == 0 then setCWS("STrangely no color was found, there's no way", false); return end

    colorCycleActive = not colorCycleActive

    if colorCycleActive then
        cwCycleBtn.Text = "Stop Rainbow effect"
        setCWS("Color switches active...", true)
        task.spawn(function()
            local index = 1
            while colorCycleActive do
                if not colorSelectedCar or not colorSelectedCar.Parent then
                    colorCycleActive = false; break
                end
                local c = colorCarColors[index]
                L.applyCarColor(colorSelectedCar, c)   -- via logic.lua
                for i = 1, 5 do
                    local swBd = cwPreviews[i]:FindFirstChildOfClass("UIStroke")
                    local isActive = (i == index)
                    if swBd then
                        swBd.Color     = isActive and Color3.fromRGB(230, 230, 230) or FL_BORDER
                        swBd.Thickness = isActive and 2.5 or 1
                    end
                    cwPreviews[i].BackgroundTransparency = isActive and 0 or 0.15
                    cwHalos[i].Visible = isActive
                end
                index = (index % #colorCarColors) + 1
                task.wait(0.5)
            end
            cwCycleBtn.Text = "▶  Restart Color switches(rainbow effect ig)"
            for i = 1, 5 do
                local swBd = cwPreviews[i]:FindFirstChildOfClass("UIStroke")
                if swBd then swBd.Color = FL_BORDER; swBd.Thickness = 1 end
                cwPreviews[i].BackgroundTransparency = 0
                cwHalos[i].Visible = false
            end
            if not colorCycleActive then setCWS("Color Switches Stopped", nil) end
        end)
    else
        setCWS("Stopped", nil)
    end
end)

local cwMinimized = false
local cwFullHeight = nil

local function setCWMinimized(v)
    cwMinimized = v
    if v then
        cwFullHeight = ColorWin.Size.Y.Offset
        ColorWin.Size = UDim2.new(0, CW_W, 0, 34)
        cwHdrMin.Text = "X"
    else
        ColorWin.Size = UDim2.new(0, CW_W, 0, cwFullHeight or 280)
        cwHdrMin.Text = "─"
    end
end

cwHdrMin.MouseButton1Click:Connect(function() setCWMinimized(not cwMinimized) end)

for _, btn in ipairs({cwCycleBtn, cwRefresh, cwHdrClose, cwHdrMin}) do
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = FL_HOVER; btn.BackgroundTransparency = T_ITEM - 0.05
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = FL_ITEM; btn.BackgroundTransparency = T_ITEM
    end)
end
cwHdrClose.MouseEnter:Connect(function()
    cwHdrClose.BackgroundColor3 = Color3.fromRGB(190, 50, 50); cwHdrClose.BackgroundTransparency = 0.1
end)
cwHdrClose.MouseLeave:Connect(function()
    cwHdrClose.BackgroundColor3 = FL_ITEM; cwHdrClose.BackgroundTransparency = T_ITEM
end)

cwHdrClose.MouseButton1Click:Connect(function()
    colorCycleActive = false
    ColorWin.Visible = false
    CWGui.Enabled    = false
    pcall(function()
        local tog = Options["ShowColorWin"]
        if tog then rawset(tog, "Value", false); pcall(function() tog:OnChanged() end) end
    end)
end)

updateCWLayout()

-- ══════════════════════════════════════════════
--  BOUTON RUGBY (toggle visibilité fenêtre)
-- ══════════════════════════════════════════════
local fluentGui = nil
task.spawn(function()
    task.wait(0.5)
    pcall(function() fluentGui = Fluent.GUI end)
    if not fluentGui or not fluentGui:IsA("ScreenGui") then
        for _, g in ipairs(PlayerGui:GetChildren()) do
            if g:IsA("ScreenGui") and g ~= TWGui and g ~= CWGui
            and g.Name ~= "TeamWindow_Orion" and g.Name ~= "RugbyToggleSG" then
                if g:FindFirstChildOfClass("Frame") then fluentGui = g; break end
            end
        end
    end
end)

local RugbySG = Instance.new("ScreenGui")
RugbySG.Name            = "RugbyToggleSG"
RugbySG.ResetOnSpawn    = false
RugbySG.IgnoreGuiInset  = true
RugbySG.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
RugbySG.DisplayOrder    = 20
RugbySG.Parent          = PlayerGui

local RugbyFrame = Instance.new("Frame")
RugbyFrame.Size               = UDim2.new(0, 92, 0, 30)
RugbyFrame.Position           = isMobile
    and UDim2.new(0.5, -46, 0, 4)
    or  UDim2.new(0, 10, 1, -44)
RugbyFrame.BackgroundColor3       = Color3.fromRGB(28, 28, 38)
RugbyFrame.BackgroundTransparency = 0.22
RugbyFrame.BorderSizePixel        = 0
RugbyFrame.Active                 = true
RugbyFrame.Parent                 = RugbySG
Instance.new("UICorner", RugbyFrame).CornerRadius = UDim.new(1, 0)

local rl = Instance.new("Frame", RugbyFrame)
rl.Size = UDim2.new(0,1,0,14); rl.Position = UDim2.new(0.5,0,0.5,-7)
rl.BackgroundColor3 = Color3.fromRGB(180,180,200); rl.BackgroundTransparency=0.5
rl.BorderSizePixel=0; rl.ZIndex=3
Instance.new("UICorner",rl).CornerRadius=UDim.new(1,0)

local rlLabel = Instance.new("TextLabel", RugbyFrame)
rlLabel.Size = UDim2.new(1,-8,1,0); rlLabel.Position = UDim2.new(0,4,0,0)
rlLabel.BackgroundTransparency = 1
rlLabel.Text = "AreSW - SWFL"
rlLabel.Font = Enum.Font.GothamBold; rlLabel.TextSize = 11
rlLabel.TextColor3 = Color3.fromRGB(220,220,230)
rlLabel.TextXAlignment = Enum.TextXAlignment.Center
rlLabel.ZIndex = 3

local rlBtn = Instance.new("TextButton", RugbyFrame)
rlBtn.Size = UDim2.new(1,0,1,0)
rlBtn.BackgroundTransparency = 1; rlBtn.Text = ""; rlBtn.ZIndex = 4

local function getFluentMainFrame()
    if not fluentGui then return nil end
    for _, c in ipairs(fluentGui:GetChildren()) do if c:IsA("Frame") then return c end end
end
local function isFluentVisible()
    if not fluentGui then return true end
    if not fluentGui.Enabled then return false end
    local f = getFluentMainFrame()
    return f == nil or f.Visible
end
local function setRugbyVisual(visible)
    RugbyFrame.BackgroundColor3 = visible and Color3.fromRGB(28,28,38) or Color3.fromRGB(18,18,24)
    rlLabel.TextColor3 = visible and Color3.fromRGB(220,220,230) or Color3.fromRGB(90,90,110)
end

rlBtn.MouseButton1Click:Connect(function()
    if not fluentGui then pcall(function() fluentGui = Fluent.GUI end) end
    if fluentGui then
        if not fluentGui.Enabled then
            fluentGui.Enabled = true
            if Window.Minimized then Window:Minimize() end
            setRugbyVisual(true)
        elseif Window.Minimized then
            Window:Minimize()
            setRugbyVisual(true)
        else
            fluentGui.Enabled = false
            setRugbyVisual(false)
        end
    end
end)

-- ══════════════════════════════════════════════
-- TABS
-- ══════════════════════════════════════════════
local Tabs = {
    Car    = Window:AddTab({ Title="Car",    Icon="car" }),
    Weapon = Window:AddTab({ Title="Weapon", Icon="crosshair" }),
    Game   = Window:AddTab({ Title="Game",   Icon="gamepad-2" }),
    Plrs   = Window:AddTab({ Title="Plrs",   Icon="users" }),
    Self   = Window:AddTab({ Title="Self",   Icon="user" }),
    Misc   = Window:AddTab({ Title="Misc",   Icon="wrench" }),
}

-- ══════════════════════════════════════════════
--  CAR TAB
-- ══════════════════════════════════════════════
local TC = Tabs.Car
local seatCarDropObj, seatDropObj, stealDropObj

TC:AddSection("Drivin methods")
TC:AddDropdown("DriveMethod", {
    Title  = "Methods",
    Values = {"M1 - Remote Direct","M2 - TP + ProxFire","M3 - G_Assets Clone","M4 - Humanoid:Sit direct"},
    Default  = "M1 - Remote Direct",
    Callback = function(v)
        if     v:find("M1") then L.state.currentDriveMethod = 1
        elseif v:find("M2") then L.state.currentDriveMethod = 2
        elseif v:find("M3") then L.state.currentDriveMethod = 3
        else                      L.state.currentDriveMethod = 4 end
        notify("Drive", "Methode " .. L.state.currentDriveMethod .. " activee")
    end
})

TC:AddSection("Car Color")
TC:AddToggle("ShowColorWin", {
    Title = "Car Color", Description = "Car Color switcher and jus color selector", Default = false,
    Callback = function(v)
        CWGui.Enabled = v; ColorWin.Visible = v
        if v then buildColorCarList() else colorCycleActive = false end
    end
})

TC:AddSection("Current vehicule")
TC:AddDropdown("SpawnCarDrop", {
    Title = "Vehicule a spawner", Values = L.CAR_LIST, Default = "mS3",
    Callback = function(v) L.state.selSpawnCar = v end
})

TC:AddButton({ Title = "Godmode plus invisibility(Cars shi)", Description = "Make u unkillable(workin for everyone) and invisible(perhaps except hair and for sum avatars or smth) as long as u DONT ENTER a car", Callback = function()
    local id = L.state.selSpawnCar
    notify("Car", "Step 1/3 - Spawning " .. id .. "...", 4)

    local ok1 = pcall(function() ReplicatedStorage.SpawnCar:FireServer("requestSpawn", id) end)
    if not ok1 then notify("Car", "Spawn failed", 3); return end

    task.spawn(function()
        task.wait(1.5)
        local car = L.findValidCar(id, 8)
        if not car then notify("Car", id .. " not found", 3); return end

        local ds = nil
        local dsWait = 0
        repeat
            task.wait(0.2); dsWait += 0.2
            ds = car:FindFirstChild("DriveSeat")
            if ds then
                local pp = car.PrimaryPart or ds
                if pp.Anchored then ds = nil end
            end
        until ds or dsWait >= 5
        if not ds then notify("Car", "DriveSeat not ready", 3); return end

        notify("Car", "Step 2/3 - Entering... (M" .. L.state.currentDriveMethod .. ")", 5)

        local perAttemptTimeout = L.state.currentDriveMethod == 4 and 1.5 or 3.0
        local maxAttempts = 6
        local seated = false
        local attempts = 0

        local function isSeated()
            local mc = LocalPlayer.Character; if not mc then return false end
            local hum = mc:FindFirstChildWhichIsA("Humanoid")
            if hum and hum.SeatPart then return true end
            if ds and ds.Parent then
                for _, c in ipairs(ds:GetChildren()) do
                    if c.Name == "SeatWeld" and c:IsA("Weld") then return true end
                end
            end
            return false
        end

        repeat
            attempts += 1
            if L.state.currentDriveMethod ~= 1 then
                local mc  = LocalPlayer.Character
                local hrp = mc and mc:FindFirstChild("HumanoidRootPart")
                if hrp and ds.Parent then
                    hrp.CFrame = ds.CFrame * CFrame.new(0, ds.Size.Y / 2 + 1.2, 0)
                end
                task.wait(L.state.currentDriveMethod == 4 and 0.05 or 0.2)
            end
            L.driveInCar(car, "drive")
            local w = 0
            repeat task.wait(0.1); w += 0.1 until isSeated() or w >= perAttemptTimeout
            if isSeated() then
                seated = true
            elseif attempts < maxAttempts then
                notify("Car", "Not seated (attempt " .. attempts .. "/" .. maxAttempts .. "), retrying...", 2)
                task.wait(0.4)
            end
        until seated or attempts >= maxAttempts

        if not seated then
            notify("Car", "Couldnt get seated after " .. maxAttempts .. " tries - try M1 or move closer to car", 6)
            return
        end

        task.wait(L.state.currentDriveMethod == 4 and 0.6 or 0.25)
        if not isSeated() then notify("Car", "Lost seat before trigger, try again", 4); return end

        notify("Car", "Seated, step 3/3 - Triggerin...", 3)
        task.wait(0.15)

        local ok3 = pcall(function() ReplicatedStorage.SpawnCar:FireServer("requestSpawn", id) end)
        if ok3 then
            pcall(function() ReplicatedStorage.SpawnCar:FireServer("requestSpawn", id) end)
            pcall(function() ReplicatedStorage.cleanUIEvent:FireServer("requestClean", LocalPlayer) end)
            task.wait(0.5)
            notify("Car", "Done ✓  Stay out of cars to keep it", 6)
            pcall(function() Options["FloorFixToggle"]:SetValue(true) end)
        else
            notify("Car", "Step 3 failed", 3)
        end
    end)
end })

TC:AddButton({ Title = "Spawn Car", Callback = function()
    notify("Car", pcall(function() ReplicatedStorage.SpawnCar:FireServer("requestSpawn", L.state.selSpawnCar) end)
        and L.state.selSpawnCar .. " spawne" or "Erreur Spawn")
end })

TC:AddButton({ Title = "Drive Car", Callback = function()
    task.spawn(function()
        local car = L.findValidCar(L.state.selSpawnCar, 4)
        if not car then notify("Car", "Introuvable"); return end
        local ok, msg = L.driveInCar(car, "drive")
        notify("Car", ok and ("Drive: " .. L.state.selSpawnCar) or ("Error: " .. msg))
    end)
end })

TC:AddSection("Sit Car")
seatCarDropObj = TC:AddDropdown("SeatCarDrop", {
    Title = "Choose a Car", Values = {"→ Click Refresh"}, Default = nil,
    Callback = function(v)
        L.state.selSeatCarKey = v
        if seatDropObj then pcall(function() seatDropObj:SetValues(L.buildSeatValues()) end) end
    end
})
seatDropObj = TC:AddDropdown("SeatDrop", {
    Title = "Target Seat", Values = {"Auto"}, Default = "Auto",
    Callback = function(v) L.state.selSeatKey = v end
})
TC:AddButton({ Title = "Refresh Car", Callback = function()
    pcall(function() seatCarDropObj:SetValues(L.buildSeatCarValues()) end)
    notify("Car", "Refreshed list")
end })
TC:AddButton({ Title = "Sit Car", Callback = function()
    local car = L.state.selSeatCarKey and L.seatCarLookup[L.state.selSeatCarKey]
    if not car then notify("Car", "Jus select a car"); return end
    if not car.Parent then notify("Car", "Looks like u have to do it again"); return end
    task.spawn(function()
        if L.state.currentDriveMethod == 2 or L.state.currentDriveMethod == 3 then
            pcall(function() ProximityPromptSvc.Enabled = true end); task.wait(0.05)
        end
        local st = nil
        if L.state.selSeatKey and L.state.selSeatKey ~= "Auto"
        and L.seatSeatLookup[L.state.selSeatKey]
        and L.seatSeatLookup[L.state.selSeatKey] ~= "_auto_" then
            st = L.seatSeatLookup[L.state.selSeatKey]
        end
        if not st then
            local all = L.getCarSeats(car)
            for _, s in ipairs(all) do if s.Occupant == nil and s.Name ~= "DriveSeat" then st = s; break end end
            if not st then for _, s in ipairs(all) do if s.Occupant == nil then st = s; break end end end
            if not st and #all > 0 then st = all[1] end
        end
        if not st then notify("Car", "No seat"); return end
        local ok, msg = L.driveInCar(car, st)
        notify("Car", ok and ("Assis: " .. st.Name) or ("Erreur: " .. msg))
    end)
end })

TC:AddSection("Rejoin")
TC:AddToggle("AutoRejoinToggle", {
    Title       = "Auto rejoin after respawn",
    Description = "Get u ah back to ur last known car seat",
    Default     = false,
    Callback    = function(v) L.state.autoRejoinOn = v end
})
TC:AddButton({
    Title       = "Sit back at ur last seat",
    Description = "[PLACEHOLDER]",
    Callback    = function()
        local pName = L.getPersistCarName()
        local pSeat = L.getPersistSeatName()
        if not pName then notify("Car", "No seats detected(Try to sit first)"); return end
        local car  = L.resolveCarAfterRespawn()
        if not car then notify("Car", "Véhicule '" .. pName .. "' introuvable"); return end
        local seat = L.findSeatInCar(car, pSeat) or car:FindFirstChild("DriveSeat")
        if not seat then notify("Car", "Seat '" .. pSeat .. "' not found"); return end
        task.spawn(function()
            local ok, msg = L.driveInCar(car, seat)
            notify("Car", ok and ("Rejoin ✓  " .. seat.Name .. " (" .. car.Name .. ")") or ("Error: " .. tostring(msg)))
        end)
    end
})

TC:AddSection("Steal a car(JUS FREE OP SHi)")
stealDropObj = TC:AddDropdown("StealDrop", {
    Title = "Target Vehicule To Steal", Values = {"→ Press Refresh"}, Default = nil,
    Callback = function(v) L.state.selStealKey = v end
})
TC:AddToggle("KillEngineToggle", {
    Title = "[Test]", Default = false,
    Callback = function(v) L.state.killEngineEnabled = v end
})
TC:AddToggle("KickUIToggle", {
    Title = "Delete/Hide sum UI driver(jus wanted to try tho)", Default = false,
    Callback = function(v) L.state.kickUIEnabled = v end
})
TC:AddButton({ Title = "Refresh Car(s)", Callback = function()
    pcall(function() stealDropObj:SetValues(L.buildStealValues()) end); notify("Car", "Refreshed")
end })
TC:AddButton({ Title = "Steal and Drive", Description = "Actually can try to steal and drive someone vehicule(FUNNY AF TO TROLL, jus buggy sumtimes ALSO can fling ppl vehicule if u try to enter into a passenger seat)", Callback = function()
    local car = L.state.selStealKey and L.stealLookup[L.state.selStealKey]
    if not car then notify("Car", "Jus select a vehicule to steal"); return end
    if not car.Parent then notify("Car", "No car found(either got respawned, plr left, or u are too far)"); return end
    task.spawn(function()
        local mc  = LocalPlayer.Character; if not mc  then return end
        local hrp = mc:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local ds  = car:FindFirstChild("DriveSeat"); if not ds then notify("Car", "Driver Seat Not found"); return end
        if L.state.killEngineEnabled then
            local io = car:FindFirstChild("IsOn")
            if io then pcall(function() io.Value = false end); task.wait(0.1) end
        end
        if L.state.kickUIEnabled and ds.Occupant then
            local oc = ds.Occupant.Parent
            if oc then
                local cd = Players:GetPlayerFromCharacter(oc)
                if cd then
                    local ce = ReplicatedStorage:FindFirstChild("cleanUIEvent")
                    if ce then pcall(function() ce:FireServer("requestClean", cd) end); task.wait(0.15) end
                end
            end
        end
        pcall(function() ds.Disabled = false end)
        local tpA = true
        local tpC = RunService.Heartbeat:Connect(function()
            if tpA then pcall(function() hrp.CFrame = ds.CFrame * CFrame.new(0, ds.Size.Y/2+2.5, 0) end) end
        end)
        task.wait(0.2)
        pcall(function() ReplicatedStorage.PromptEvent:FireServer("DriveRequest", ds) end)
        task.wait(0.15); tpA = false; tpC:Disconnect()
        notify("Car", "Attempted tryin to steal: " .. car.Name)
    end)
end })

-- ══════════════════════════════════════════════
--  WEAPON TAB
-- ══════════════════════════════════════════════
local TW = Tabs.Weapon
local playerDropObj = nil

local function refreshPlayerList()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(names, plr.Name) end
    end
    if #names == 0 then names = {"No plrs was found either u alone or jus refresh"} end
    if playerDropObj then pcall(function() playerDropObj:SetValues(names) end) end
end

TW:AddSection("Target")
playerDropObj = TW:AddDropdown("PlayerTarget", {
    Title  = "Player", Values = {"Aucun joueur"}, Default = nil,
    Callback = function(v)
        L.state.selectedPlayer = nil
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name == v then L.state.selectedPlayer = p; break end
        end
    end
})
TW:AddButton({ Title="Refresh plrs list", Callback = function() refreshPlayerList() end })

TW:AddSection("Degats")
TW:AddButton({ Title="Inflict/send damages to police(OP, crazy tho)", Callback=function()
    if not L.state.selectedPlayer then notify("Weapon","Jus select ur next victim and u will be in peace"); return end
    if not L.getGun() then notify("Weapon","Equip ur M9(only supportin default free weapon for now)"); return end
    local ok = L.sendDamage(L.state.selectedPlayer.Character)
    notify("Weapon", ok and L.state.selectedPlayer.Name.." HIT" or "Hum guys the remote even wasnt found... either false alarm or got patched")
end })
TW:AddButton({ Title="Loop Kill", Description="Loop kill a police guy until he die", Callback=function()
    if not L.getGun() then notify("Weapon","Equip ur M9(only supportin default free weapon for now)"); return end
    L.startKillLoop()
end })
TW:AddButton({ Title="Stop killin(u sure u wanna have mercy..?)", Callback=function()
    L.stopKillLoop(); notify("Weapon","Killin stopped")
end })

TW:AddSection("Kill aura(VERY OP)")
TW:AddSlider("AuraRadius", {
    Title = "Radius (studs)", Min = 5, Max = 700, Default = 200, Rounding = 5,
    Callback = function(v) L.state.auraRadius = v end
})
TW:AddToggle("AuraDmg", {
    Title = "Kill nearby policer(kill aura)", Default = false,
    Callback = function(v)
        if v then L.startAura()
        else       L.stopAura() end
    end
})

TW:AddSection("Taser")
TW:AddButton({ Title="Target plr to tase(need to be police team)", Callback=function()
    if not L.state.selectedPlayer then notify("Taser","Select a BAD BOY"); return end
    if not L.isPoliceOrSheriff() then notify("Taser","Require ou Sheriff"); return end
    local ok = L.fireTase(L.state.selectedPlayer)
    notify("Taser", ok and L.state.selectedPlayer.Name.." tase" or "Erreur")
end })
TW:AddButton({ Title="Taser joueur proche", Callback=function()
    if not L.isPoliceOrSheriff() then notify("Taser","Required to be Police team or Sheriff"); return end
    local n = L.getNearestPlayer(); if not n then notify("Taser","No nearby criminal"); return end
    local ok = L.fireTase(n)
    notify("Taser", ok and n.Name.." tase" or "Error")
end })
TW:AddToggle("TaseLoop", {
    Title = "Taser loop (need to be close enough unfortunately)", Default = false,
    Callback = function(v)
        if v and not L.isPoliceOrSheriff() then notify("Taser","GNG Required Police team or Sheriff"); return end
        L.state.taseLoopActive = v
        if v then
            task.spawn(function()
                while L.state.taseLoopActive do
                    local n = L.getNearestPlayer()
                    if n then L.fireTase(n) end
                    task.wait(5.2)
                end
            end)
        end
    end
})

-- ══════════════════════════════════════════════
--  GAME TAB
-- ══════════════════════════════════════════════
local TG = Tabs.Game

local success, err = pcall(function()
    TG:AddSection("Teams")

    local _allowTeamToggle = false

    TG:AddToggle("ShowTeamWin", {
        Title = "Join team", Default = false,
        Callback = function(Value)
            TWGui.Enabled  = Value
            TeamWin.Visible = Value
            if Value then buildTeamList() end
        end
    })

    TG:AddButton({
        Title = "Rejoin the same actual team",
        Callback = function()
            local mt = LocalPlayer.Team
            if not mt then notify("Game", "No team been selected, cmon jus select"); return end
            local te = ReplicatedStorage:FindFirstChild("TeamEvent")
            if not te then notify("Game", "TeamEvent wasnt found..?"); return end
            local ok = pcall(function() te:FireServer(mt.TeamColor) end)
            notify("Game", ok and ("Rejoined team: " .. mt.Name) or "Error FireServer")
        end
    })

    task.delay(2.5, function()
        TWGui.Enabled = false
        _allowTeamToggle = true
    end)
end)

if not success then warn("Error while loadin the game tab :", err) end

-- ══════════════════════════════════════════════
--  PLRS / SELF TABS (placeholder)
-- ══════════════════════════════════════════════
Tabs.Plrs:AddSection("Plrs"); Tabs.Plrs:AddParagraph({ Title="Soon", Content="Plrs functionalities" })
Tabs.Self:AddSection("Self"); Tabs.Self:AddParagraph({ Title="Soon", Content="Perso functionalities" })

-- ══════════════════════════════════════════════
--  MISC TAB
-- ══════════════════════════════════════════════
local TM = Tabs.Misc

TM:AddSection("Personnage")
TM:AddButton({ Title="Reload Char", Callback=function()
    local ok = pcall(function() ReplicatedStorage.loadCharRemote:FireServer() end)
    notify("Misc", ok and "Reloaded Char" or "Error loadCharRemote")
end })

TM:AddToggle("FloorFixToggle", {
    Title = "Godmode floor fix",
    Description = "When u equip M9 (or G17 for police or sheriff), either freezes u or TP u up slightly to prevent fallin thro the map(AUTO ENABLED WHEN GODMODE IS SUCESSFULLY SET UP, with godmode option)",
    Default = false,
    Callback = function(v) L.floorFixCallback(v) end   -- délégué à logic.lua
})

TM:AddDropdown("FloorFixMode", {
    Title = "Floor fix mode",
    Values = {"Freeze for 3s(RECOMMENDED)", "TP Up"},
    Default  = "Freeze for 3s(RECOMMENDED)",
    Callback = function(v) end
})

TM:AddSlider("FloorFixTPHeight", {
    Title    = "TP height offset",
    Min      = 1,
    Max      = 20,
    Default  = 5,
    Rounding = 1,
    Callback = function(v) end
})

TM:AddSection("Unlimited Ammo")

TM:AddDropdown("AmmoMethod", {
    Title = "ammo method",
    Values = {"Basic method","Invisible TP ammo box"},
    Default = "Basic Method",
    Callback = function(v)
        L.state.selAmmoMethod = (v == "Basic Method") and "BS" or "tp"
    end
})
TM:AddToggle("HideAmmo", {
    Title = "Hide ammo boxes",
    Description = "Makes ammo boxes invisible and no collided. HIGHLY Recommended if ur executor is makin it buggy or smth else (like yep xeno, probably more similar ones)",
    Default = false,
    Callback = function(v) L.setHideLoop(v) end
})
TM:AddToggle("AmmoLoop", {
    Title = "Get ammo every 12s",
    Description = "Loop, basic but less laggy better for low devices or complicated executor, like xeno, L xeno. Anyways jus wanna do my best to please yall also btw less detected by the game(or even roblox ig) even tho this game isnt properly protected against exploit(deadah)",
    Default = false,
    Callback = function(v) L.setAmmoLoop(v) end
})
TM:AddToggle("AmmoEnabled", {
    Title = "Get ammo boxes for every shot",
    Description = "Get ammo for each shot. Tested it had no real issues so workin fine(delta is workin well so far and xeno aswell but kinda annoyin in game if u see a random ammo box poppin up) BUT can get slightly laggy dependin on devices/perfs or even executor(xeno, alr i will stop now)",
    Default = false,
    Callback = function(v) L.setAmmoEnabled(v) end
})

TM:AddSection("Glasses(jus for fun at this point)")
TM:AddButton({ Title="Break Glasses around u", Description="Basically tryin to breal every/most glasses around u _glass", Callback=function()
    task.spawn(function()
        local sr = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ShatterGlass")
        if not sr then notify("Misc","ShatterGlass wasnt found"); return end
        local gp = {}
        for _,o in ipairs(workspace:GetDescendants()) do
            if o:IsA("Part") and o.Name:sub(-6) == "_glass" then table.insert(gp, o) end
        end
        if #gp == 0 then notify("Misc","No glasses found"); return end
        local sent = 0
        for _,g in ipairs(gp) do
            if g and g.Parent then
                pcall(function() sr:FireServer(g) end); sent += 1
                if sent % 50 == 0 then task.wait() end
            end
        end
        notify("Misc", sent.."/"..#gp.."Broke Glasses ✓")
    end)
end })

TM:AddSection("Interface")
InterfaceManager:SetFolder("CustomGUI")
InterfaceManager:BuildInterfaceSection(TM)
