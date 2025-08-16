-- LootTracker/gui.lua
local LT = LootTracker

--------------------------------------------------
-- Create main frame
--------------------------------------------------
function LT:CreateGUI()
    if self.gui then return end

    local f = CreateFrame("Frame", "LootTrackerFrame", UIParent)
    f:SetWidth(300)
    f:SetHeight(400)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function() f:StartMoving() end)
    f:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)
    
    -- Add backdrop for background
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    f:SetBackdropColor(0, 0, 0, 0.8)
    
    -- Add title background
    f.TitleBg = f:CreateTexture(nil, "ARTWORK")
    f.TitleBg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    f.TitleBg:SetWidth(256)
    f.TitleBg:SetHeight(64)
    f.TitleBg:SetPoint("TOP", 0, 12)
    
    f:Hide()

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.title:SetPoint("CENTER", f.TitleBg, "CENTER", 0, 0)
    f.title:SetText("Loot Tracker")

    --------------------------------------------------
    -- Stats area
    --------------------------------------------------
    f.stats = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.stats:SetPoint("TOPLEFT", 10, -30)
    f.stats:SetJustifyH("LEFT")
    f.stats:SetText("No session running")

    --------------------------------------------------
    -- Scrollable item list
    --------------------------------------------------
    local scrollFrame = CreateFrame("ScrollFrame", "LTItemScroll", f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -60)
    scrollFrame:SetWidth(260)
    scrollFrame:SetHeight(250)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(260)
    content:SetHeight(250)
    scrollFrame:SetScrollChild(content)

    f.itemContent = content
    f.items = {}

    --------------------------------------------------
    -- Buttons
    --------------------------------------------------
    f.startBtn = CreateFrame("Button", nil, f, "GameMenuButtonTemplate")
    f.startBtn:SetPoint("BOTTOMLEFT", 10, 10)
    f.startBtn:SetWidth(70)
    f.startBtn:SetHeight(25)
    f.startBtn:SetText("Start")
    f.startBtn:SetScript("OnClick", function() LT:StartSession() LT:UpdateGUI() end)

    f.pauseBtn = CreateFrame("Button", nil, f, "GameMenuButtonTemplate")
    f.pauseBtn:SetPoint("LEFT", f.startBtn, "RIGHT", 10, 0)
    f.pauseBtn:SetWidth(70)
    f.pauseBtn:SetHeight(25)
    f.pauseBtn:SetText("Pause")
    f.pauseBtn:SetScript("OnClick", function() LT:PauseSession() LT:UpdateGUI() end)

    f.resetBtn = CreateFrame("Button", nil, f, "GameMenuButtonTemplate")
    f.resetBtn:SetPoint("LEFT", f.pauseBtn, "RIGHT", 10, 0)
    f.resetBtn:SetWidth(70)
    f.resetBtn:SetHeight(25)
    f.resetBtn:SetText("Reset")
    f.resetBtn:SetScript("OnClick", function() LT:ResetSession() LT:UpdateGUI() end)

    self.gui = f
end

--------------------------------------------------
-- Show / Hide GUI
--------------------------------------------------
function LT:ShowGUI()
    self:CreateGUI()
    self.gui:Show()
    self:UpdateGUI()
end

--------------------------------------------------
-- Update GUI contents
--------------------------------------------------
function LT:UpdateGUI()
    if not self.gui or not self.gui:IsShown() then return end
    local s = self.session

    if not s.active then
        self.gui.stats:SetText("No active session")
    else
        local elapsed = s.elapsed
        if not s.paused and s.startTime then
            elapsed = elapsed + (GetTime() - s.startTime)
        end

        local gph = 0
        local totalValue = s.money
        for _, entry in pairs(s.items) do
            totalValue = totalValue + entry.value
        end
        if elapsed > 0 then
            gph = (totalValue / elapsed) * 3600
        end

        self.gui.stats:SetText(string.format(
            "Time: %s\nTotal: %s\nGold/hr: %s",
            self:FormatTime(elapsed),
            self:FormatMoney(totalValue),
            self:FormatMoney(gph)
        ))
    end

    -- Clear item content
    for _, font in ipairs(self.gui.items) do
        font:Hide()
    end
    wipe(self.gui.items)

    local y = -5
    for _, entry in pairs(self.session.items) do
        local line = self.gui.itemContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        line:SetPoint("TOPLEFT", 0, y)
        line:SetText(entry.count.."x "..entry.link.." = "..self:FormatMoney(entry.value))
        table.insert(self.gui.items, line)
        y = y - 15
    end
end

--------------------------------------------------
-- Helpers
--------------------------------------------------
function LT:FormatTime(seconds)
    local h = math.floor(seconds / 3600)
    local remainder = seconds - (h * 3600)
    local m = math.floor(remainder / 60)
    local s = remainder - (m * 60)
    return string.format("%02dh %02dm %02ds", h, m, s)
end
