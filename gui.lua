-- LootTracker/gui.lua
local LT = LootTracker

--------------------------------------------------
-- Create main frame
--------------------------------------------------
function LT:CreateGUI()
    if self.gui then return end

    local f = CreateFrame("Frame", "LootTrackerFrame", UIParent, "BasicFrameTemplate")
    f:SetSize(300, 400)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
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
    scrollFrame:SetPoint("TOPLEFT", 10, -60)
    scrollFrame:SetSize(260, 250)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(260, 250)
    scrollFrame:SetScrollChild(content)

    f.itemContent = content
    f.items = {}

    --------------------------------------------------
    -- Buttons
    --------------------------------------------------
    f.startBtn = CreateFrame("Button", nil, f, "GameMenuButtonTemplate")
    f.startBtn:SetPoint("BOTTOMLEFT", 10, 10)
    f.startBtn:SetSize(70, 25)
    f.startBtn:SetText("Start")
    f.startBtn:SetScript("OnClick", function() LT:StartSession() LT:UpdateGUI() end)

    f.pauseBtn = CreateFrame("Button", nil, f, "GameMenuButtonTemplate")
    f.pauseBtn:SetPoint("LEFT", f.startBtn, "RIGHT", 10, 0)
    f.pauseBtn:SetSize(70, 25)
    f.pauseBtn:SetText("Pause")
    f.pauseBtn:SetScript("OnClick", function() LT:PauseSession() LT:UpdateGUI() end)

    f.resetBtn = CreateFrame("Button", nil, f, "GameMenuButtonTemplate")
    f.resetBtn:SetPoint("LEFT", f.pauseBtn, "RIGHT", 10, 0)
    f.resetBtn:SetSize(70, 25)
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
    local h = floor(seconds / 3600)
    local m = floor((seconds % 3600) / 60)
    local s = floor(seconds % 60)
    return string.format("%02dh %02dm %02ds", h, m, s)
end
