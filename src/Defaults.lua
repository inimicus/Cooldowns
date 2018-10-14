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
    for key, set in pairs(Cool.Data.Sets) do
        defaults.sets[key] = {
            x = 150,
            y = 150,
            size = 64,
            sounds = {
                onProc = {
                    enabled = true,
                    sound = 'STATS_PURCHASE',
                },
                onReady = {
                    enabled = true,
                    sound = 'SKILL_LINE_ADDED',
                },
            },
        }
    end
    return defaults
end
