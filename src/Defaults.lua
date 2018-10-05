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
    sets = {
        Trappings = {
            x = 150,
            y = 150,
            size = 100,
        },
        Lich = {
            x = 150,
            y = 150,
            size = 100,
        },
        Earthgore = {
            x = 150,
            y = 150,
            size = 100,
        },
        Olorime = {
            x = 150,
            y = 150,
            size = 80,
        },
    },
    unlocked = true,
}

function Cool.Defaults.Get()
    return defaults
end
