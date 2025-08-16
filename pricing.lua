-- LootTracker/pricing.lua
local LT = LootTracker

--------------------------------------------------
-- Aux pricing
--------------------------------------------------
local function auxPrice(itemId, suffixId)
    if not aux then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[LT Debug]|r aux addon not found")
        return nil
    end
    
    -- Default suffix to 0 if not provided
    suffixId = suffixId or 0
    local itemKey = tostring(itemId) .. ":" .. tostring(suffixId)
    
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[LT Debug]|r Looking up item key: " .. itemKey)
    
    -- Try to access aux history module through the require system
    local success, history = pcall(require, 'aux.core.history')
    if success and history and history.value then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[LT Debug]|r aux.core.history loaded via require")
        local value = history.value(itemKey)
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[LT Debug]|r aux returned value: " .. tostring(value or "nil"))
        if value and value > 0 then
            return value
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[LT Debug]|r Failed to load aux.core.history via require")
    end
    
    -- Fallback: try direct access (may not work due to module system)
    if aux.core and aux.core.history and aux.core.history.value then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[LT Debug]|r Trying direct aux.core.history access")
        local value = aux.core.history.value(itemKey)
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[LT Debug]|r Direct access returned: " .. tostring(value or "nil"))
        if value and value > 0 then
            return value
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[LT Debug]|r Direct aux.core.history access not available")
    end
    
    return nil
end

--------------------------------------------------
-- Vendor pricing
--------------------------------------------------
-- WoW 1.12 does not have GetItemInfo vendor sell price directly,
-- so we use GetSellValue if LibVendorValue is present, or fallback 0.
local function vendorPrice(itemId)
    if GetSellValue then
        local value = GetSellValue(itemId)
        if value and value > 0 then
            return value
        end
    end
    return 0
end

--------------------------------------------------
-- Public API
--------------------------------------------------
function LT:GetItemValue(itemId, suffixId)
    return auxPrice(itemId, suffixId) or vendorPrice(itemId) or 0
end
