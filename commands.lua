-- LootTracker/commands.lua
local LT = LootTracker

--------------------------------------------------
-- Slash command setup
--------------------------------------------------
SLASH_LOOTTRACKER1 = "/lt"

SlashCmdList["LOOTTRACKER"] = function(msg)
    msg = string.lower(msg or "")
    if msg == "start" then
        LT:StartSession()
    elseif msg == "pause" then
        LT:PauseSession()
    elseif msg == "reset" then
        LT:ResetSession()
    elseif msg == "show" then
        if LT.gui and LT.gui:IsShown() then
            LT.gui:Hide()
        else
            if LT.ShowGUI then
                LT:ShowGUI()
            else
                LT:Print("GUI not implemented yet.")
            end
        end
    elseif msg == "" then
        LT:Print("Commands: /lt start | pause | reset | show")
    else
        LT:Print("Unknown command: "..msg)
    end
end
