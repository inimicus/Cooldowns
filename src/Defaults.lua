-- -----------------------------------------------------------------------------
-- Earthgore Cooldown
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Defaults.lua
-- -----------------------------------------------------------------------------

EGC.Defaults = {}

local defaults = {
    debugMode = 0,
    sets = {
        Trappings = {
            x = 150,
            y = 150,
        },
        Lich = {
            x = 150,
            y = 150,
        },
        Earthgore = {
            x = 150,
            y = 150,
        },
    },
    unlocked = true,
}

function EGC.Defaults.Get()
    return defaults
end
