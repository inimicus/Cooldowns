-- -----------------------------------------------------------------------------
-- Earthgore Cooldown
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Tracking.lua
-- -----------------------------------------------------------------------------

local EARTHGORE_ID = 97855
local timeOfProc
local updateIntervalMs = 100
local cooldownDurationMs = 35000

function EGC.RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(EGC.name, EVENT_EFFECT_CHANGED, EGC.EarthgoreDidProc)
    EVENT_MANAGER:AddFilterForEvent(EGC.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, EARTHGORE_ID)
    EVENT_MANAGER:AddFilterForEvent(EGC.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
end

function EGC.EarthgoreDidProc(eventCode, changeType, effectSlot, effectName,
        unitTag, startTimeSec, endTimeSec, stackCount, iconName, buffType,
        effectType, abilityType, statusEffectType, unitName, unitId,
        effectAbilityId, sourceType)

    -- Ignore non-start changes
    if changeType ~= EFFECT_RESULT_GAINED then return end

    EGC:Trace(1, effectName .. " (" .. effectAbilityId .. ")")

    timeOfProc = GetGameTimeMilliseconds()
    EVENT_MANAGER:RegisterForUpdate(EGC.name .. "Count", updateIntervalMs, EGC.CountdownUpdate)
end

function EGC.CountdownUpdate()
    EGC.onCooldown = true
    EGC.ToggleShow()

    local countdown = (timeOfProc + cooldownDurationMs - GetGameTimeMilliseconds()) / 1000

    if (countdown < 0) then
        EVENT_MANAGER:UnregisterForUpdate(EGC.name .. "Count")
        EGC.onCooldown = false
        EGC.EGCLabel:SetText("0.0")
        EGC.ToggleShow()
    elseif (countdown < 1) then
        EGC.EGCLabel:SetText(string.format("%.1f", countdown))
    else 
        EGC.EGCLabel:SetText(string.format("%.0f", countdown))
    end

end

