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
            sounds = {
                onProc = {
                    enabled = false,
                    volume = 75,
                    sound = nil,
                },
                onReady = {
                    enabled = false,
                    volume = 75,
                    sound = nil,
                },
            },
        },
        Lich = {
            x = 150,
            y = 150,
            size = 100,
            sounds = {
                onProc = {
                    enabled = false,
                    volume = 75,
                    sound = nil,
                },
                onReady = {
                    enabled = false,
                    volume = 75,
                    sound = nil,
                },
            },
        },
        Earthgore = {
            x = 150,
            y = 150,
            size = 100,
            sounds = {
                onProc = {
                    enabled = false,
                    volume = 75,
                    sound = nil,
                },
                onReady = {
                    enabled = false,
                    volume = 75,
                    sound = nil,
                },
            },
        },
        Olorime = {
            x = 150,
            y = 150,
            size = 80,
            sounds = {
                onProc = {
                    enabled = false,
                    volume = 75,
                    sound = nil,
                },
                onReady = {
                    enabled = false,
                    volume = 75,
                    sound = nil,
                },
            },
        },
    },
    unlocked = true,
}

function Cool.Defaults.Get()
    return defaults
end
