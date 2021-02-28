-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: Feb 27, 2021
--
-- en.lua
-- English translation strings
-- -----------------------------------------------------------------------------

local S = {}

-- Addon Strings
S.Addon_LocaleName = "en"
S.Addon_Load = "Loaded"
S.Addon_Intialized = "Finished Initialize()"

-- Tracking
S.Tracking_Combat_InCombat = "In Combat: <<1>>"
S.Tracking_Combat_OnCooldown = "<<1>> (<<2>>) on Cooldown"
S.Tracking_Combat_ResultDetails = "Name: <<1>> (<<2>>) with result <<3>>"
S.Tracking_Cooldown_Proc = "Cooldown proc for <<1>> (<<2>>)"
S.Tracking_Effect_Changed = "<<1>> (<<2>>) with change type <<3>> <<4>>"
S.Tracking_Register_CombatOff = "Unregistered combat events"
S.Tracking_Register_CombatOn = "Registered combat events"
S.Tracking_Register_Off = "Unregistered events"
S.Tracking_Register_On = "Registered events"
S.Tracking_Register_UnfileredOff = "Unregistered Unfiltered Events"
S.Tracking_Register_UnfileredOn = "Registered Unfiltered Events"
S.Tracking_Set_AlreadyDisabled = "Set already disabled for: <<1>> (<<2>>)"
S.Tracking_Set_AlreadyEnabled = "Set already enabled for: <<1>> (<<2>>)"
S.Tracking_Set_ForceDisabled = "Force disabled <<1>> (<<2>>), skipping enable"
S.Tracking_Set_FullSet = "Full set for: <<1>> (<<2>>), registering events"
S.Tracking_Set_NotActive = "Not active for: <<1>> (<<2>>), unregistering events"

-- Settings
-- LockUnlock_ButtonLock
-- LockUnlock_ButtonUnlock
-- LockUnlock_Tooltip
-- HideShow_Button_Hide
-- HideShow_Button_Show
-- HideShow_Tooltip
-- LagComp_Label
-- LagComp_Tooltip
-- ShowOutsideCombat_Label
-- ShowOutsideCombat_Tooltip
-- Grid_Label
-- Grid_Tooltip
-- Grid_Size_Label
-- Grid_Size_Tooltip
-- Select_Set
-- Select_Synergy
-- Select_Passive
-- Force_TrackingSetOn
-- Force_TrackingSetOff
-- Force_TrackingSetYolo
-- Sound_Testing
-- Customize_Select_Set
-- Customize_Select_Synergy
-- Customize_Select_Passive
-- Error_InvalidProcType
-- Initialized

-- Register
Cool.Locale.registerStrings(S)
