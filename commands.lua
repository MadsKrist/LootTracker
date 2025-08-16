-- LootTracker/commands.lua
local LT = LootTracker

--------------------------------------------------
-- Slash command setup
--------------------------------------------------
SLASH_LOOTTRACKER1 = "/lt"

SlashCmdList["LOOTTRACKER"] = function(msg)
    local args = {}
    for word in string.gfind(msg, "%S+") do
        table.insert(args, string.lower(word))
    end
    
    local cmd = args[1] or ""
    
    if cmd == "start" then
        LT:StartSession()
    elseif cmd == "pause" then
        LT:PauseSession()
    elseif cmd == "reset" then
        LT:ResetSession()
    elseif cmd == "show" then
        if LT.gui and LT.gui:IsShown() then
            LT.gui:Hide()
        else
            if LT.ShowGUI then
                LT:ShowGUI()
            else
                LT:Print("GUI not implemented yet.")
            end
        end
    elseif cmd == "scale" then
        local scale = tonumber(args[2])
        if scale and scale >= 0.5 and scale <= 2.0 then
            LT:SetScale(scale)
            LT:Print("Scale set to " .. scale)
        else
            LT:Print("Usage: /lt scale <0.5-2.0>")
        end
    elseif cmd == "fontsize" then
        local size = args[2]
        if size == "small" or size == "medium" or size == "large" then
            LT:SetFontSize(size)
            LT:Print("Font size set to " .. size)
        else
            LT:Print("Usage: /lt fontsize <small|medium|large>")
        end
    elseif cmd == "" then
        LT:Print("Commands:")
        LT:Print("  /lt start | pause | reset | show")
        LT:Print("  /lt scale <0.5-2.0>")
        LT:Print("  /lt fontsize <small|medium|large>")
    else
        LT:Print("Unknown command: "..cmd)
    end
end
