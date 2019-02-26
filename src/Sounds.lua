-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: Oct 6, 2018
--
-- Sounds.lua
-- -----------------------------------------------------------------------------
Cool = Cool or {}
Cool.Sounds = {}
function Cool.GetSounds()
    if SOUNDS then
        for soundName, _ in pairs(SOUNDS) do
            if soundName ~= "NONE" then
                table.insert(Cool.Sounds, soundName)
            end
        end
        if #Cool.Sounds > 0 then
            table.sort(Cool.Sounds)
            table.insert(Cool.Sounds, 1, "NONE")
        end
    end
end