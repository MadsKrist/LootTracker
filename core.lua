-- LootTracker/core.lua

LootTracker = {}
local LT = LootTracker

LT.name = "LootTracker"
LT.version = "0.1"

-- Saved variables
LootTrackerDB = LootTrackerDB or {}
LootTrackerCDB = LootTrackerCDB or {}

-- Session state
LT.session = {
    active = false,
    paused = false,
    startTime = nil,
    elapsed = 0,
    items = {},   -- [itemID] = {count = n, value = totalValue}
    money = 0,
}

--------------------------------------------------
-- Event handling
--------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("CHAT_MSG_LOOT")
frame:RegisterEvent("CHAT_MSG_MONEY")

frame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == LT.name then
        LT:OnLoad()
    elseif event == "PLAYER_LOGOUT" then
        LT:OnSave()
    elseif event == "CHAT_MSG_LOOT" then
        LT:OnItemLoot(arg1)
    elseif event == "CHAT_MSG_MONEY" then
        LT:OnMoneyLoot(arg1)
    end
end)

--------------------------------------------------
-- Lifecycle
--------------------------------------------------
function LT:OnLoad()
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00"..LT.name.." v"..LT.version.." loaded. Use /lt show.")
end

function LT:OnSave()
    -- save session state if needed
    LootTrackerCDB.session = LT.session
end

--------------------------------------------------
-- Session control
--------------------------------------------------
function LT:StartSession()
    self.session = {
        active = true,
        paused = false,
        startTime = GetTime(),
        elapsed = 0,
        items = {},
        money = 0,
    }
    self:Print("Session started.")
end

function LT:PauseSession()
    if self.session.active and not self.session.paused then
        self.session.paused = true
        self.session.elapsed = self.session.elapsed + (GetTime() - self.session.startTime)
        self:Print("Session paused.")
    elseif self.session.active and self.session.paused then
        self.session.paused = false
        self.session.startTime = GetTime()
        self:Print("Session resumed.")
    end
end

function LT:ResetSession()
    self.session = {
        active = false,
        paused = false,
        startTime = nil,
        elapsed = 0,
        items = {},
        money = 0,
    }
    self:Print("Session reset.")
end

function LT:ToggleSession()
    if not self.session.active then
        -- Start session
        self:StartSession()
    else
        -- Toggle pause/resume
        self:PauseSession()
    end
end

--------------------------------------------------
-- Loot tracking
--------------------------------------------------
function LT:OnItemLoot(msg)
    if not self.session.active or self.session.paused then return end
    
    -- Parse loot messages like "You receive loot: [Item Link]x2"
    -- or "You receive loot: [Item Link]"
    local itemLink, quantity = string.match(msg, "You receive loot: (|c%x+|Hitem:[^|]+|h%[[^%]]+%]|h|r)x?(%d*)")
    
    if itemLink then
        quantity = tonumber(quantity) or 1
        
        -- Extract item ID and suffix ID from the item link
        -- Format: |cffffffff|Hitem:item_id:enchant_id:gem1:gem2:gem3:gem4:suffix_id:unique_id:...|h[Item Name]|h|r
        -- For 1.12, the format is simpler: |Hitem:item_id:enchant_id:suffix_id:unique_id|h[Item Name]|h
        local linkData = string.match(itemLink, "item:([^|]+)")
        local parts = {}
        if linkData then
            for part in string.gmatch(linkData, "([^:]+)") do
                table.insert(parts, part)
            end
        end
        
        local itemId = tonumber(parts[1])
        local suffixId = tonumber(parts[3]) or 0  -- Third field is suffix in 1.12 format
        
        -- Debug output
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[LT Debug]|r Item link: " .. itemLink)
        if linkData then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[LT Debug]|r Link data: " .. linkData)
            local partsStr = ""
            for i, part in ipairs(parts) do
                partsStr = partsStr .. "[" .. i .. "]=" .. part .. " "
            end
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[LT Debug]|r Parts: " .. partsStr)
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[LT Debug]|r Parsed itemId: " .. tostring(itemId) .. ", suffixId: " .. tostring(suffixId))
        
        if itemId then
            -- Get item value (pass both item ID and suffix ID)
            local unitValue = self:GetItemValue(itemId, suffixId)
            local totalValue = unitValue * quantity
            
            -- Get item quality (0=Poor/Gray, 1=Common/White, 2=Uncommon/Green, 3=Rare/Blue, 4=Epic/Purple, 5=Legendary/Orange)
            local _, _, quality = GetItemInfo(itemId)
            quality = quality or 1 -- Default to white if unknown
            
            -- Add to session
            if self.session.items[itemId] then
                self.session.items[itemId].count = self.session.items[itemId].count + quantity
                self.session.items[itemId].value = self.session.items[itemId].value + totalValue
            else
                self.session.items[itemId] = {
                    count = quantity,
                    value = totalValue,
                    link = itemLink,
                    quality = quality
                }
            end
            
            self:Print(string.format("Looted %dx %s (%s each)", quantity, itemLink, self:FormatMoney(unitValue)))
            
            -- Update GUI if shown
            if self.gui and self.gui:IsShown() then
                self:UpdateGUI()
            end
        end
    end
end

function LT:OnMoneyLoot(msg)
    if not self.session.active or self.session.paused then return end
    
    -- Parse money messages like "You loot 5 Gold, 23 Silver, 15 Copper"
    -- or "You loot 15 Copper" or variations
    local totalCopper = 0
    
    -- Look for gold
    local gold = string.match(msg, "(%d+) Gold")
    if gold then
        totalCopper = totalCopper + (tonumber(gold) * 10000)
    end
    
    -- Look for silver
    local silver = string.match(msg, "(%d+) Silver")
    if silver then
        totalCopper = totalCopper + (tonumber(silver) * 100)
    end
    
    -- Look for copper
    local copper = string.match(msg, "(%d+) Copper")
    if copper then
        totalCopper = totalCopper + tonumber(copper)
    end
    
    if totalCopper > 0 then
        self.session.money = self.session.money + totalCopper
        self:Print(string.format("Looted %s", self:FormatMoney(totalCopper)))
        
        -- Update GUI if shown
        if self.gui and self.gui:IsShown() then
            self:UpdateGUI()
        end
    end
end

--------------------------------------------------
-- Utility
--------------------------------------------------
function LT:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[LT]|r "..msg)
end

function LT:FormatMoney(copper)
    if not copper or copper == 0 then return "0c" end
    
    copper = math.floor(copper)
    local gold = math.floor(copper / 10000)
    local remainder = copper - (gold * 10000)
    local silver = math.floor(remainder / 100)
    local c = remainder - (silver * 100)
    
    local result = ""
    if gold > 0 then
        result = result .. gold .. "g"
        if silver > 0 or c > 0 then result = result .. " " end
    end
    if silver > 0 then
        result = result .. silver .. "s"
        if c > 0 then result = result .. " " end
    end
    if c > 0 or result == "" then
        result = result .. c .. "c"
    end
    
    return result
end
