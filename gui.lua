-- LootTracker/gui.lua
local LT = LootTracker

-- Aux-style GUI constants
local FONT = "Fonts\\ARIALN.TTF"
local FONT_SIZE = {
    small = 13,
    medium = 15,
    large = 18,
}

-- Default settings
local DEFAULT_SCALE = 1.0
local DEFAULT_FONT_SIZE = "medium"

-- Color scheme similar to aux
local COLORS = {
    window = { bg = {0.05, 0.05, 0.08, 0.95}, border = {0.2, 0.2, 0.3, 1} },
    panel = { bg = {0.1, 0.1, 0.15, 0.9}, border = {0.25, 0.25, 0.35, 1} },
    content = { bg = {0.15, 0.15, 0.2, 0.9}, border = {0.3, 0.3, 0.4, 1} },
    text = { enabled = {0.9, 0.9, 0.9, 1}, disabled = {0.5, 0.5, 0.5, 1} },
    label = { enabled = {0.7, 0.7, 0.8, 1} }
}

-- Helper functions for aux-style frames
local function set_frame_style(frame, bg_color, border_color, left, right, top, bottom)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1.5,
        tile = true,
        insets = { left = left or 0, right = right or 0, top = top or 0, bottom = bottom or 0 }
    })
    frame:SetBackdropColor(unpack(bg_color))
    frame:SetBackdropBorderColor(unpack(border_color))
end

local function set_window_style(frame)
    set_frame_style(frame, COLORS.window.bg, COLORS.window.border, 1, 1, 1, 1)
end

local function set_panel_style(frame)
    set_frame_style(frame, COLORS.panel.bg, COLORS.panel.border, 1, 1, 1, 1)
end

local function set_content_style(frame)
    set_frame_style(frame, COLORS.content.bg, COLORS.content.border, 1, 1, 1, 1)
end

--------------------------------------------------
-- Create main frame
--------------------------------------------------
function LT:CreateGUI()
    if self.gui then return end

    local f = CreateFrame("Frame", "LootTrackerFrame", UIParent)
    f:SetWidth(320)
    f:SetHeight(420)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function() f:StartMoving() end)
    f:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)
    
    -- Aux-style window background
    set_window_style(f)
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, f)
    closeBtn:SetWidth(20)
    closeBtn:SetHeight(20)
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5, -5)
    set_content_style(closeBtn)
    
    local closeText = closeBtn:CreateFontString()
    closeText:SetFont(FONT, FONT_SIZE.medium)
    closeText:SetTextColor(unpack(COLORS.text.enabled))
    closeText:SetAllPoints()
    closeText:SetJustifyH("CENTER")
    closeText:SetJustifyV("CENTER")
    closeText:SetText("×")
    
    local closeHighlight = closeBtn:CreateTexture(nil, "HIGHLIGHT")
    closeHighlight:SetAllPoints()
    closeHighlight:SetTexture(1, 0.2, 0.2, 0.3)
    
    closeBtn:SetScript("OnClick", function() f:Hide() end)
    
    -- Title using aux font styling
    f.title = f:CreateFontString(nil, "OVERLAY")
    f.title:SetFont(FONT, FONT_SIZE.large)
    f.title:SetTextColor(unpack(COLORS.text.enabled))
    f.title:SetPoint("TOP", f, "TOP", 0, -10)
    f.title:SetText("Loot Tracker")
    
    f:Hide()

    --------------------------------------------------
    -- Stats panel
    --------------------------------------------------
    local statsPanel = CreateFrame("Frame", nil, f)
    statsPanel:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -35)
    statsPanel:SetWidth(300)
    statsPanel:SetHeight(70)
    set_panel_style(statsPanel)
    
    f.stats = statsPanel:CreateFontString(nil, "OVERLAY")
    f.stats:SetFont(FONT, FONT_SIZE.medium)
    f.stats:SetTextColor(unpack(COLORS.text.enabled))
    f.stats:SetPoint("TOPLEFT", statsPanel, "TOPLEFT", 8, -8)
    f.stats:SetJustifyH("LEFT")
    f.stats:SetText("No session running")

    --------------------------------------------------
    -- Scrollable item list
    --------------------------------------------------
    local listPanel = CreateFrame("Frame", nil, f)
    listPanel:SetPoint("TOPLEFT", statsPanel, "BOTTOMLEFT", 0, -10)
    listPanel:SetWidth(300)
    listPanel:SetHeight(240)
    set_content_style(listPanel)
    
    local scrollFrame = CreateFrame("ScrollFrame", "LTItemScroll", listPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -15, 5)

    -- Apply aux-style scrollbar
    local scrollBar = _G[scrollFrame:GetName() .. "ScrollBar"]
    if scrollBar then
        scrollBar:ClearAllPoints()
        scrollBar:SetPoint("TOPRIGHT", listPanel, "TOPRIGHT", -4, -4)
        scrollBar:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -4, 4)
        scrollBar:SetWidth(10)
        
        -- Style the thumb
        local thumbTex = scrollBar:GetThumbTexture()
        if thumbTex then
            thumbTex:SetPoint("CENTER", 0, 0)
            thumbTex:SetTexture("Interface\\Buttons\\WHITE8X8")
            thumbTex:SetVertexColor(0.4, 0.4, 0.5, 0.9) -- Lighter gray color
            thumbTex:SetHeight(50)
            thumbTex:SetWidth(scrollBar:GetWidth())
        end
        
        -- Hide scroll buttons completely
        local scrollBarName = scrollBar:GetName()
        local upButton = _G[scrollBarName .. "ScrollUpButton"]
        local downButton = _G[scrollBarName .. "ScrollDownButton"]
        
        if upButton then 
            upButton:Hide()
            upButton:SetAlpha(0)
            upButton:EnableMouse(false)
        end
        if downButton then 
            downButton:Hide()
            downButton:SetAlpha(0)
            downButton:EnableMouse(false)
        end
        
        -- Also try alternative naming patterns
        local upButton2 = _G[scrollBarName .. "UpButton"]
        local downButton2 = _G[scrollBarName .. "DownButton"]
        
        if upButton2 then 
            upButton2:Hide()
            upButton2:SetAlpha(0)
            upButton2:EnableMouse(false)
        end
        if downButton2 then 
            downButton2:Hide()
            downButton2:SetAlpha(0)
            downButton2:EnableMouse(false)
        end
        
        -- Style the track
        set_panel_style(scrollBar)
    end

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(270)
    content:SetHeight(1000) -- Large height for scrolling
    scrollFrame:SetScrollChild(content)

    f.itemContent = content
    f.items = {}

    --------------------------------------------------
    -- Buttons
    --------------------------------------------------
    local function create_aux_button(parent, text)
        local button = CreateFrame("Button", nil, parent)
        button:SetWidth(80)
        button:SetHeight(24)
        set_content_style(button)
        
        local highlight = button:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints()
        highlight:SetTexture(1, 1, 1, 0.2)
        
        local label = button:CreateFontString()
        label:SetFont(FONT, FONT_SIZE.medium)
        label:SetAllPoints(button)
        label:SetJustifyH("CENTER")
        label:SetJustifyV("CENTER")
        label:SetTextColor(unpack(COLORS.text.enabled))
        button:SetFontString(label)
        button:SetText(text)
        
        return button
    end
    
    f.startBtn = create_aux_button(f, "Start")
    f.startBtn:SetPoint("BOTTOMLEFT", 15, 15)
    f.startBtn:SetScript("OnClick", function() LT:StartSession() LT:UpdateGUI() end)

    f.pauseBtn = create_aux_button(f, "Pause")
    f.pauseBtn:SetPoint("LEFT", f.startBtn, "RIGHT", 15, 0)
    f.pauseBtn:SetScript("OnClick", function() LT:PauseSession() LT:UpdateGUI() end)

    f.resetBtn = create_aux_button(f, "Reset")
    f.resetBtn:SetPoint("LEFT", f.pauseBtn, "RIGHT", 15, 0)
    f.resetBtn:SetScript("OnClick", function() LT:ResetSession() LT:UpdateGUI() end)

    self.gui = f
end

--------------------------------------------------
-- Show / Hide GUI
--------------------------------------------------
function LT:ShowGUI()
    self:CreateGUI()
    self:LoadSettings() -- Apply saved settings
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

    local y = -8
    for _, entry in pairs(self.session.items) do
        local line = self.gui.itemContent:CreateFontString(nil, "OVERLAY")
        line:SetFont(FONT, FONT_SIZE.small)
        line:SetTextColor(unpack(COLORS.text.enabled))
        line:SetPoint("TOPLEFT", 5, y)
        line:SetPoint("TOPRIGHT", -5, y)
        line:SetJustifyH("LEFT")
        line:SetText(entry.count.."x "..entry.link.." = "..self:FormatMoney(entry.value))
        table.insert(self.gui.items, line)
        y = y - 16
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

--------------------------------------------------
-- Scale and Font Size Functions
--------------------------------------------------
function LT:SetScale(scale)
    if self.gui then
        self.gui:SetScale(scale)
        -- Store setting for persistence
        if not LootTrackerDB.settings then
            LootTrackerDB.settings = {}
        end
        LootTrackerDB.settings.scale = scale
    end
end

function LT:SetFontSize(size)
    if not self.gui then return end
    
    local fontSize = FONT_SIZE[size] or FONT_SIZE.medium
    
    -- Update title
    if self.gui.title then
        self.gui.title:SetFont(FONT, fontSize + 3) -- Title slightly larger
    end
    
    -- Update stats text
    if self.gui.stats then
        self.gui.stats:SetFont(FONT, fontSize)
    end
    
    -- Update all item text
    for _, item in ipairs(self.gui.items) do
        if item and item.SetFont then
            item:SetFont(FONT, fontSize - 2) -- Items slightly smaller
        end
    end
    
    -- Update button text
    if self.gui.startBtn and self.gui.startBtn:GetFontString() then
        self.gui.startBtn:GetFontString():SetFont(FONT, fontSize)
    end
    if self.gui.pauseBtn and self.gui.pauseBtn:GetFontString() then
        self.gui.pauseBtn:GetFontString():SetFont(FONT, fontSize)
    end
    if self.gui.resetBtn and self.gui.resetBtn:GetFontString() then
        self.gui.resetBtn:GetFontString():SetFont(FONT, fontSize)
    end
    
    -- Store setting for persistence
    if not LootTrackerDB.settings then
        LootTrackerDB.settings = {}
    end
    LootTrackerDB.settings.fontSize = size
end

function LT:LoadSettings()
    if LootTrackerDB and LootTrackerDB.settings then
        local settings = LootTrackerDB.settings
        
        if settings.scale then
            self:SetScale(settings.scale)
        end
        
        if settings.fontSize then
            self:SetFontSize(settings.fontSize)
        end
    end
end
