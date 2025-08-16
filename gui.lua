-- LootTracker/gui.lua
local LT = LootTracker

-- Aux-style GUI constants
local FONT = "Fonts\\ARIALN.TTF"
local FONT_SIZE = {
    small = 11,
    medium = 13,
    large = 16,
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
    f:SetWidth(350)
    f:SetHeight(270)
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
    closeBtn:SetWidth(17)
    closeBtn:SetHeight(17)
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -7, -7)
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
   --  f.title = f:CreateFontString(nil, "OVERLAY")
   --  f.title:SetFont(FONT, FONT_SIZE.large)
   --  f.title:SetTextColor(unpack(COLORS.text.enabled))
   --  f.title:SetPoint("TOP", f, "TOP", 0, -10)
   --  f.title:SetText("Loot Tracker")
    
   --  f:Hide()

    --------------------------------------------------
    -- Stats panel
    --------------------------------------------------
    local statsPanel = CreateFrame("Frame", nil, f)
    statsPanel:SetPoint("TOPLEFT", f, "TOPLEFT", 7, -28)
    statsPanel:SetWidth(336)
    statsPanel:SetHeight(60)
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
    listPanel:SetPoint("TOPLEFT", statsPanel, "BOTTOMLEFT", 0, -7)
    listPanel:SetWidth(336)
    listPanel:SetHeight(130)
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
    
    f.toggleBtn = create_aux_button(f, "Start")
    f.toggleBtn:SetPoint("BOTTOMLEFT", 7, 7)
    f.toggleBtn:SetScript("OnClick", function() 
        LT:ToggleSession() 
        LT:UpdateGUI() 
    end)

    f.resetBtn = create_aux_button(f, "Reset")
    f.resetBtn:SetPoint("BOTTOMRIGHT", -7, 7)
    f.resetBtn:SetScript("OnClick", function() LT:ResetSession() LT:UpdateGUI() end)

    -- Quality filter button
    f.qualityBtn = create_aux_button(f, "All")
    f.qualityBtn:SetPoint("BOTTOM", 0, 7)
    f.qualityBtn:SetScript("OnClick", function() LT:CycleQualityFilter() end)

    -- Timers for different update intervals
    f.timer = 0
    f.gphTimer = 0
    f:SetScript("OnUpdate", function()
        f.timer = f.timer + arg1
        f.gphTimer = f.gphTimer + arg1
        
        if f.timer >= 1.0 then -- Update time display every second
            f.timer = 0
            if LT.session.active then
                LT:UpdateGUI(false) -- Don't recalculate GPH
            end
        end
        
        if f.gphTimer >= 5.0 then -- Update GPH every 5 seconds
            f.gphTimer = 0
            if LT.session.active then
                LT:UpdateGUI(true) -- Recalculate GPH
            end
        end
    end)

    self.gui = f
end

--------------------------------------------------
-- Show / Hide GUI
--------------------------------------------------
function LT:ShowGUI()
    self:CreateGUI()
    self:LoadSettings() -- Apply saved settings
    
    -- Initialize quality filter button text
    if self.gui.qualityBtn then
        local qualities = {
            {level = 0, name = "All"},
            {level = 1, name = "White+"},
            {level = 2, name = "Green+"},
            {level = 3, name = "Blue+"},
            {level = 4, name = "Purple+"}
        }
        
        local currentFilter = self.qualityFilter or 0
        for _, quality in ipairs(qualities) do
            if quality.level == currentFilter then
                self.gui.qualityBtn:SetText(quality.name)
                break
            end
        end
    end
    
    self.gui:Show()
    self:UpdateGUI()
end

--------------------------------------------------
-- Update GUI contents
--------------------------------------------------
function LT:UpdateGUI(recalculateGPH)
    if not self.gui or not self.gui:IsShown() then return end
    local s = self.session

    if not s.active then
        self.gui.stats:SetText("No active session")
        -- Reset cached GPH when no session
        self.cachedGPH = nil
    else
        local elapsed = s.elapsed
        if not s.paused and s.startTime then
            elapsed = elapsed + (GetTime() - s.startTime)
        end

        local totalValue = s.money
        for _, entry in pairs(s.items) do
            totalValue = totalValue + entry.value
        end

        -- Only recalculate GPH if requested or if we don't have a cached value
        local gph = self.cachedGPH or 0
        if recalculateGPH ~= false then -- Default to true if not specified
            if elapsed > 0 then
                gph = (totalValue / elapsed) * 3600
            else
                gph = 0
            end
            self.cachedGPH = gph
        end

        self.gui.stats:SetText(string.format(
            "Time: %s\nTotal: %s\nGold/hr: %s",
            self:FormatTime(elapsed),
            self:FormatMoney(totalValue),
            self:FormatMoney(gph)
        ))
    end

    -- Update toggle button text
    if self.gui.toggleBtn then
        if not s.active then
            self.gui.toggleBtn:SetText("Start")
        elseif s.paused then
            self.gui.toggleBtn:SetText("Resume")
        else
            self.gui.toggleBtn:SetText("Pause")
        end
    end

    -- Clear item content
    for _, font in ipairs(self.gui.items) do
        font:Hide()
    end
    wipe(self.gui.items)

    -- Get current quality filter
    local minQuality = self.qualityFilter or 0
    
    local y = -2
    for _, entry in pairs(self.session.items) do
        -- Apply quality filter for display (but all items still count in totals)
        if (entry.quality or 1) >= minQuality then
            local line = self.gui.itemContent:CreateFontString(nil, "OVERLAY")
            line:SetFont(FONT, FONT_SIZE.medium)
            line:SetTextColor(unpack(COLORS.text.enabled))
            line:SetPoint("TOPLEFT", 1, y)
            line:SetPoint("TOPRIGHT", -1, y)
            line:SetJustifyH("LEFT")
            line:SetText(entry.count.."x "..entry.link.." = "..self:FormatMoney(entry.value))
            table.insert(self.gui.items, line)
            y = y - 16
        end
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
        if not LootTrackerDB then
            LootTrackerDB = {}
        end
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
    if self.gui.toggleBtn and self.gui.toggleBtn:GetFontString() then
        self.gui.toggleBtn:GetFontString():SetFont(FONT, fontSize)
    end
    if self.gui.resetBtn and self.gui.resetBtn:GetFontString() then
        self.gui.resetBtn:GetFontString():SetFont(FONT, fontSize)
    end
    
    -- Store setting for persistence
    if not LootTrackerDB then
        LootTrackerDB = {}
    end
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
        
        if settings.qualityFilter then
            self.qualityFilter = settings.qualityFilter
        end
    end
end

--------------------------------------------------
-- Reset window position
--------------------------------------------------
function LT:ResetWindowPosition()
    if self.gui then
        self.gui:ClearAllPoints()
        self.gui:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        self:Print("Window position reset to center")
    else
        self:Print("Window not open")
    end
end

--------------------------------------------------
-- Quality Filter
--------------------------------------------------
function LT:CycleQualityFilter()
    -- Quality levels: 0=Gray, 1=White, 2=Green, 3=Blue, 4=Purple, 5=Orange
    local qualities = {
        {level = 0, name = "All"},
        {level = 1, name = "White+"},
        {level = 2, name = "Green+"},
        {level = 3, name = "Blue+"},
        {level = 4, name = "Purple+"}
    }
    
    -- Find current index
    local currentIndex = 1
    for i, quality in ipairs(qualities) do
        if quality.level == (self.qualityFilter or 0) then
            currentIndex = i
            break
        end
    end
    
    -- Move to next
    currentIndex = currentIndex + 1
    if currentIndex > table.getn(qualities) then
        currentIndex = 1
    end
    
    -- Set new filter
    self.qualityFilter = qualities[currentIndex].level
    
    -- Update button text
    if self.gui and self.gui.qualityBtn then
        self.gui.qualityBtn:SetText(qualities[currentIndex].name)
    end
    
    -- Save setting
    if not LootTrackerDB then
        LootTrackerDB = {}
    end
    if not LootTrackerDB.settings then
        LootTrackerDB.settings = {}
    end
    LootTrackerDB.settings.qualityFilter = self.qualityFilter
    
    -- Update display
    self:UpdateGUI()
end
