-- LootTracker/pricing.lua
local LT = LootTracker

--------------------------------------------------
-- Aux pricing
--------------------------------------------------
local function auxPrice(itemId)
    -- Debug: Print aux structure
    if aux then
        DEFAULT_CHAT_FRAME:AddMessage("[LT Debug] aux exists")
        
        -- Check different possible paths
        if aux.history then
            DEFAULT_CHAT_FRAME:AddMessage("[LT Debug] aux.history exists")
            if aux.history.value then
                DEFAULT_CHAT_FRAME:AddMessage("[LT Debug] aux.history.value exists")
            end
        end
        
        if aux.core then
            DEFAULT_CHAT_FRAME:AddMessage("[LT Debug] aux.core exists")
            if aux.core.history then
                DEFAULT_CHAT_FRAME:AddMessage("[LT Debug] aux.core.history exists")
                if aux.core.history.value then
                    DEFAULT_CHAT_FRAME:AddMessage("[LT Debug] aux.core.history.value exists")
                end
            end
        end
        
        -- Try to get value using different approaches
        local itemKey = tostring(itemId) .. ":0"
        local value = nil
        
        if aux.core and aux.core.history and aux.core.history.value then
            value = aux.core.history.value(itemKey)
            DEFAULT_CHAT_FRAME:AddMessage("[LT Debug] aux.core.history.value(" .. itemKey .. ") = " .. tostring(value))
        elseif aux.history and aux.history.value then
            value = aux.history.value(itemKey)
            DEFAULT_CHAT_FRAME:AddMessage("[LT Debug] aux.history.value(" .. itemKey .. ") = " .. tostring(value))
        end
        
        if value and value > 0 then
            return value
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("[LT Debug] aux not found")
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
