-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: Feb 27, 2021
--
-- Debug.lua
-- -----------------------------------------------------------------------------

Cool = Cool or {}

--- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
--
-- Setting this value here will apply as soon as the addon loads.
-- It may also be set in-game with `/cool debug [level]`, but it
-- is not persisted between UI reloads.
Cool.debugMode = 3

--- Trace method
-- Outputs debug messages based on the debug level
function Cool:Trace(debugLevel, ...)
    if debugLevel <= Cool.debugMode then
        local message = zo_strformat(...)
        d(Cool.prefix .. message)
    end
end
