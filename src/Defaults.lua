-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Defaults.lua
-- -----------------------------------------------------------------------------

Cool.Defaults = {}

local defaults = {
    debugMode = 0,
    sets = {},
    unlocked = true,
    showOutsideCombat = true,
}

function Cool.Defaults.Get()
    for key, set in pairs(Cool.Tracking.Sets) do
        defaults.sets[key] = {
            x = 150,
            y = 150,
            size = 75,
            sounds = {
                onProc = {
                    enabled = false,
                    sound = nil,
                },
                onReady = {
                    enabled = false,
                    sound = nil,
                },
            },
        }
    end
    return defaults
end
