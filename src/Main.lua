-- -----------------------------------------------------------------------------
-- Earthgore Cooldown
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Track proc cooldowns for Earthgore and display a timer.
--
-- Main.lua
-- -----------------------------------------------------------------------------
EGC             = {}
EGC.name        = "EarthgoreCooldown"
EGC.version     = "0.0.1"
EGC.dbVersion   = 1
EGC.slash       = "/egc"
EGC.prefix      = "[EGC] "
EGC.HUDHidden   = false
EGC.ForceShow   = false

-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
EGC.debugMode = 1
-- -----------------------------------------------------------------------------

function EGC:Trace(debugLevel, ...)
    if debugLevel <= EGC.debugMode then
        d(EGC.prefix .. ...)
    end
end

-- -----------------------------------------------------------------------------
-- Startup
-- -----------------------------------------------------------------------------

function EGC.Initialize(event, addonName)
    if addonName ~= EGC.name then return end

    EGC:Trace(1, "EGC Loaded")
    EVENT_MANAGER:UnregisterForEvent(EGC.name, EVENT_ADD_ON_LOADED)

    EGC.preferences = ZO_SavedVars:NewAccountWide("EarthgoreCooldownVariables", EGC.dbVersion, nil, EGC:GetDefaults())

    -- Use saved debugMode value
    EGC.debugMode = EGC.preferences.debugMode

    SLASH_COMMANDS[EGC.slash] = EGC.SlashCommand

    EGC:InitSettings()
    EGC.DrawUI()
    EGC.ToggleHUD()
    EGC.RegisterEvents()

    EGC:Trace(2, "Finished Initialize()")
end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(EGC.name, EVENT_ADD_ON_LOADED, function(...) EGC.Initialize(...) end)

