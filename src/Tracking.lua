-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Tracking.lua
-- -----------------------------------------------------------------------------

Cool = Cool or {}
Cool.Tracking = {}

local EM = EVENT_MANAGER
local updateIntervalMs = 100
local S = Cool.Locale.Get

-- ----------------------------------------------------------------------------
-- Callback Functions
-- ----------------------------------------------------------------------------

local function OnCooldownUpdated(setKey, eventCode, abilityId)
    -- When cooldown of this ability occurs, this function is continually called
    -- until the set is off cooldown.
    -- We can use the first call of this function to detect a proc state.

    local set = Cool.Data.Sets[setKey]

    -- Ignore if set is on cooldown
    if set.onCooldown == true then return end

    set.timeOfProc = GetGameTimeMilliseconds()

    -- Delay proc time by the current frame duration if lag compensation is enabled
    -- This helps mitigate false procs when the set is seen as off cooldown,
    -- but the COOLDOWN_UPDATED event is still being called.
    -- This delay aims to let COOLDOWN_UPDATED finish, which can vary depending
    -- on lag conditions, before deeming the set as off cooldown.
    if Cool.preferences.lagCompensation then
        -- Add current frame delta - does NOT account for wide variances/spikes
        set.timeOfProc = set.timeOfProc + GetFrameDeltaTimeMilliseconds()
    end

    set.onCooldown = true
    Cool.UI.PlaySound(Cool.preferences.sets[setKey].sounds.onProc)
    EM:RegisterForUpdate(Cool.name .. setKey .. "Count", updateIntervalMs, function(...) Cool.UI.Update(setKey) return end)

    Cool:Trace(1, S("Tracking_Cooldown_Proc"), setKey, abilityId)
end

local function OnCombatEvent(setKey, _, result, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)

    local set = Cool.Data.Sets[setKey]

    if result == ACTION_RESULT_ABILITY_ON_COOLDOWN then
        Cool:Trace(1, S("Tracking_Combat_OnCooldown"), abilityName, abilityId)
    elseif result == set.result then
        Cool:Trace(1, S("Tracking_Combat_ResultDetails"), abilityName, abilityId, result)
        set.onCooldown = true
        set.timeOfProc = GetGameTimeMilliseconds()
        Cool.UI.PlaySound(Cool.preferences.sets[setKey].sounds.onProc)
        EM:RegisterForUpdate(Cool.name .. setKey .. "Count", updateIntervalMs, function(...) Cool.UI.Update(setKey) return end)
    else
        Cool:Trace(1, S("Tracking_Combat_ResultDetails"), abilityName, abilityId, result)
    end

end

local function IsInCombat(_, inCombat)
    Cool.isInCombat = inCombat
    Cool:Trace(2, S("Tracking_Combat_InCombat"), tostring(inCombat))
    Cool.UI:SetCombatStateDisplay()
end

local function OnAlive()
    Cool.isDead = false
    Cool.UI:SetCombatStateDisplay()
end

local function OnDeath()
    Cool.isDead = true
    Cool.UI:SetCombatStateDisplay()
end

-- Common unnecessary ability ids
local ignoreList = {
    --sprint
    [973] = true,
    --sprintDrain
    [15356] = true,
    --block
    [14890] = true,
    --interrupt
    [55146] = true,
    --roll
    [28549] = true,
    --immov
    [29721] = true,
    --phase
    [98294] = true,
    --dodgeFatigue
    [69143] = true,
}

local function OnCombatEventUnfiltered(_, result, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    -- Exclude common unnecessary abilities
    local abortNow = ignoreList[abilityId] or false
    if abortNow then return end

    Cool:Trace(1, S("Tracking_Combat_ResultDetails"), abilityName, abilityId, result)
end

local function OnEffectChangedUnfiltered(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    -- Exclude common unnecessary abilities
    local abortNow = ignoreList[abilityId] or false
    if abortNow then return end

    Cool:Trace(1, S("Tracking_Effect_Changed"), effectName, abilityId, changeType, iconName)
end

-- ----------------------------------------------------------------------------
-- Event Register/Unregister
-- ----------------------------------------------------------------------------

function Cool.Tracking.RegisterUnfiltered()
    --EM:RegisterForEvent(Cool.name .. "_UnfilteredEffect", EVENT_EFFECT_CHANGED, OnEffectChangedUnfiltered)
    --EM:AddFilterForEvent(Cool.name .. "_UnfilteredEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EM:RegisterForEvent(Cool.name .. "_Unfiltered", EVENT_COMBAT_EVENT, OnCombatEventUnfiltered)
    EM:AddFilterForEvent(Cool.name .. "_Unfiltered", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    Cool:Trace(1, S("Tracking_Register_UnfilteredOn"))
end

function Cool.Tracking.UnregisterUnfiltered()
    EM:UnregisterForEvent(Cool.name .. "_Unfiltered", EVENT_COMBAT_EVENT)
    Cool:Trace(1, S("Tracking_Register_UnfilteredOff"))
end

function Cool.Tracking.RegisterEvents()
    EM:RegisterForEvent(Cool.name, EVENT_PLAYER_ALIVE, OnAlive)
    EM:RegisterForEvent(Cool.name, EVENT_PLAYER_DEAD, OnDeath)

    if not Cool.preferences.showOutsideCombat then
        Cool.Tracking.RegisterCombatEvent()
    end

    Cool:Trace(1, S("Tracking_Register_On"))
end

function Cool.Tracking.UnregisterEvents()
    EM:UnregisterForEvent(Cool.name, EVENT_PLAYER_ALIVE)
    EM:UnregisterForEvent(Cool.name, EVENT_PLAYER_DEAD)
    Cool:Trace(1, S("Tracking_Register_Off"))
end

function Cool.Tracking.RegisterCombatEvent()
    EM:RegisterForEvent(Cool.name .. "COMBAT", EVENT_PLAYER_COMBAT_STATE, IsInCombat)
    Cool:Trace(2, S("Tracking_Register_CombatOn"))
end

function Cool.Tracking.UnregisterCombatEvent()
    EM:UnregisterForEvent(Cool.name .. "COMBAT", EVENT_PLAYER_COMBAT_STATE)
    Cool:Trace(2, S("Tracking_Register_CombatOff"))
end

-- ----------------------------------------------------------------------------
-- Utility Functions
-- ----------------------------------------------------------------------------

function Cool.Tracking.EnableSynergiesFromPrefs()
    for key, enable in pairs(Cool.character.synergy) do
        if enable == true then
            Cool.Tracking.EnableTrackingForSet(key, true, key)
        end
    end
end

function Cool.Tracking.EnablePassivesFromPrefs()
    for key, enable in pairs(Cool.character.passive) do
        if enable == true then
            Cool.Tracking.EnableTrackingForSet(key, true, key)
        end
    end
end

function Cool.Tracking.EnableTrackingForSet(setName, enabled, setKey)

    local set = Cool.Data.Sets[setKey]

    -- Ignore sets not in our table
    if set == nil then return end

    -- Full bonus active
    if enabled then

        -- Check manual disable first
        if Cool.character[set.procType][setKey] ~= nil
				and Cool.character[set.procType][setKey] == false then
            -- Skip enabling set
            Cool:Trace(1, S("Tracking_Set_ForceDisabled"), setName, setKey)
            return
        end

        -- Don't enable if already enabled
        if not set.enabled then
            Cool:Trace(1, S("Tracking_Set_FullSet"), setName, setKey)

            -- Set callback based on event
            local procFunction = nil
            if set.event == EVENT_ABILITY_COOLDOWN_UPDATED then
                procFunction = OnCooldownUpdated
            else
                procFunction = OnCombatEvent
            end

            -- Register events
            if type(set.id) == 'table' then
                for i=1, #set.id do
                    EM:RegisterForEvent(Cool.name .. "_" .. set.id[i], set.event, function(...) procFunction(setKey, ...) end)
                    EM:AddFilterForEvent(Cool.name .. "_" .. set.id[i], set.event,
                        REGISTER_FILTER_ABILITY_ID, set.id[i],
                        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
                end
            else
                EM:RegisterForEvent(Cool.name .. "_" .. set.id, set.event, function(...) procFunction(setKey, ...) end)
                EM:AddFilterForEvent(Cool.name .. "_" .. set.id, set.event,
                    REGISTER_FILTER_ABILITY_ID, set.id,
                    REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
            end

            set.enabled = true
            Cool.UI.Draw(setKey)
        else
            Cool:Trace(2, S("Tracking_Set_AlreadyEnabled"), setName, setKey)
        end

    -- Full bonus not active
    else

        -- Don't disable if already disabled
        if set.enabled then
            Cool:Trace(1, S("Tracking_Set_NotActive"), setName, setKey)
            if type(set.id) == 'table' then
                for i=1, #set.id do
                    EM:UnregisterForEvent(Cool.name .. "_" .. set.id[i], set.event)
                end
            else
                EM:UnregisterForEvent(Cool.name .. "_" .. set.id, set.event)
            end
            set.enabled = false
            Cool.UI.Draw(setKey)
        else
            Cool:Trace(2, S("Tracking_Set_AlreadyDisabled"), setName, setKey)
        end
    end

end

