-- LootTracker/pricing.lua
local LT = LootTracker

--------------------------------------------------
-- Aux pricing
--------------------------------------------------
local function auxPrice(itemId)
    if aux and aux.history and aux.history.value then
        local value = aux.history.value(itemId)
        if value and value > 0 then
            return value
        end
    end
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
