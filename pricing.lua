-- LootTracker/pricing.lua
local LT = LootTracker

--------------------------------------------------
-- Aux pricing
--------------------------------------------------
local function auxPrice(itemId, suffixId)
    if not aux then
        return nil
    end
    
    -- Default suffix to 0 if not provided
    suffixId = suffixId or 0
    
    -- Try to access aux history module through the require system
    local success, history = pcall(require, 'aux.core.history')
    if success and history and history.value then
        -- aux expects item key in format "item_id:suffix_id"
        local itemKey = tostring(itemId) .. ":" .. tostring(suffixId)
        local value = history.value(itemKey)
        if value and value > 0 then
            return value
        end
    end
    
    -- Fallback: try direct access (may not work due to module system)
    if aux.core and aux.core.history and aux.core.history.value then
        local itemKey = tostring(itemId) .. ":" .. tostring(suffixId)
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
function LT:GetItemValue(itemId, suffixId)
    return auxPrice(itemId, suffixId) or vendorPrice(itemId) or 0
end
