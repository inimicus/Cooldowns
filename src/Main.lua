-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Track cooldowns for various sets
--
-- Main.lua
-- -----------------------------------------------------------------------------
Cool            = Cool or {}
Cool.name       = "Cooldowns"
Cool.version    = "1.7.0"
Cool.dbVersion  = 1
Cool.slash      = "/cool"
Cool.prefix     = "[Cooldowns] "
Cool.HUDHidden  = false
Cool.ForceShow  = false
Cool.isInCombat = false
Cool.isDead     = false

local EM = EVENT_MANAGER
local S = Cool.Locale.Get

-- -----------------------------------------------------------------------------
-- Startup
-- -----------------------------------------------------------------------------

function Cool.Initialize(event, addonName)
    if addonName ~= Cool.name then return end

    Cool:Trace(1, S("Addon_Loaded"))
    EM:UnregisterForEvent(Cool.name, EVENT_ADD_ON_LOADED)

    -- Load the sets data (using LibSets)
    Cool.GetSetData()

    -- Populate default settings for sets
    Cool.Defaults:Generate()

    -- Account-wide: Sets and synergy prefs
    Cool.preferences = ZO_SavedVars:NewAccountWide("CooldownsVariables", Cool.dbVersion, nil, Cool.Defaults.Get())

    -- Per-Character: Synergy display status
    -- Other synergy preferences are still account-wide
    Cool.character = ZO_SavedVars:New("CooldownsVariables", Cool.dbVersion, nil, Cool.Defaults.GetCharacter())
    Cool.Settings.Upgrade()

    -- Use saved debugMode value
    Cool.debugMode = Cool.preferences.debugMode

    SLASH_COMMANDS[Cool.slash] = Cool.UI.SlashCommand

    -- Update initial combat/dead state
    -- In the event that UI is loaded mid-combat or while dead
    Cool.isInCombat = IsUnitInCombat("player")
    Cool.isDead = IsUnitDead("player")

    Cool.Settings.Init()
    Cool.Tracking.RegisterEvents()
    Cool.Tracking.EnableSynergiesFromPrefs()
    Cool.Tracking.EnablePassivesFromPrefs()

    -- Configure and register LibEquipmentBonus
    local LEB = LibEquipmentBonus
    local Equip = LEB:Init(Cool.name)
    Equip:Register(Cool.Tracking.EnableTrackingForSet)

    Cool.UI.ToggleHUD()

    Cool:Trace(2, S("Addon_Initialized"))
end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EM:RegisterForEvent(Cool.name, EVENT_ADD_ON_LOADED, Cool.Initialize)

