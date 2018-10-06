-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Track cooldowns for various sets
--
-- Main.lua
-- -----------------------------------------------------------------------------
Cool             = {}
Cool.name        = "Cooldowns"
Cool.version     = "1.0.0"
Cool.dbVersion   = 1
Cool.slash       = "/cool"
Cool.prefix      = "[Cool] "
Cool.onCooldown  = false
Cool.enabled     = false
Cool.HUDHidden   = false
Cool.ForceShow   = false

-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
Cool.debugMode = 0
-- -----------------------------------------------------------------------------

function Cool:Trace(debugLevel, ...)
    if debugLevel <= Cool.debugMode then
        d(Cool.prefix .. ...)
    end
end

-- -----------------------------------------------------------------------------
-- Startup
-- -----------------------------------------------------------------------------

function Cool.Initialize(event, addonName)
    if addonName ~= Cool.name then return end

    Cool:Trace(1, "Cool Loaded")
    EVENT_MANAGER:UnregisterForEvent(Cool.name, EVENT_ADD_ON_LOADED)

    Cool.preferences = ZO_SavedVars:NewAccountWide("CooldownsVariables", Cool.dbVersion, nil, Cool.Defaults.Get())

    -- Use saved debugMode value
    Cool.debugMode = Cool.preferences.debugMode

    SLASH_COMMANDS[Cool.slash] = Cool.UI.SlashCommand

    Cool.Settings.Init()
    Cool.Tracking.RegisterEvents()
    Cool.Tracking.CheckEquippedSet()
    Cool.UI.ToggleHUD()

    Cool:Trace(2, "Finished Initialize()")
end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(Cool.name, EVENT_ADD_ON_LOADED, function(...) Cool.Initialize(...) end)

