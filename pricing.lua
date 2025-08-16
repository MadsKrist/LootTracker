-- LootTracker/pricing.lua
local LT = LootTracker

--------------------------------------------------
-- Aux pricing
--------------------------------------------------
local function auxPrice(itemId)
    if not aux then
        return nil
    end
    
    -- Try to access aux history module through the require system
    local success, history = pcall(require, 'aux.core.history')
    if success and history and history.value then
        -- aux expects item key in format "item_id:suffix_id"
        -- For most items, suffix_id is 0
        local itemKey = tostring(itemId) .. ":0"
        local value = history.value(itemKey)
        if value and value > 0 then
            return value
        end
    end
    
    -- Fallback: try direct access (may not work due to module system)
    if aux.core and aux.core.history and aux.core.history.value then
        local itemKey = tostring(itemId) .. ":0"
        local value = aux.core.history.value(itemKey)
        if value and value > 0 then
            return value
        end
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
function LT:GetItemValue(itemId)
    return auxPrice(itemId) or vendorPrice(itemId) or 0
end
