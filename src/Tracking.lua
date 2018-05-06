-- -----------------------------------------------------------------------------
-- Earthgore Cooldown
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Tracking.lua
-- -----------------------------------------------------------------------------

EGC.Tracking = {}
EGC.Tracking.timeOfProc = 0
EGC.Tracking.cooldownDurationMs = 35000

local EARTHGORE_ID = 97855
local updateIntervalMs = 100

function EGC.Tracking.Register()
    EVENT_MANAGER:RegisterForEvent(EGC.name, EVENT_EFFECT_CHANGED, EGC.Tracking.EarthgoreDidProc)
    EVENT_MANAGER:AddFilterForEvent(EGC.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, EARTHGORE_ID)
    EVENT_MANAGER:AddFilterForEvent(EGC.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
end

function EGC.Tracking.EarthgoreDidProc(_, changeType, _, effectName, _, _, _,
        _, _, _, _, _, _, _, _, effectAbilityId, sourceType)

    -- Ignore non-start changes
    if changeType ~= EFFECT_RESULT_GAINED then return end

    EGC:Trace(1, effectName .. " (" .. effectAbilityId .. ")")

    EGC.Tracking.timeOfProc = GetGameTimeMilliseconds()
    EGC.EGCTexture:SetColor(0.5, 0.5, 0.5, 1)
    EVENT_MANAGER:RegisterForUpdate(EGC.name .. "Count", updateIntervalMs, EGC.UI.Update)

end

