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

function EGC.Tracking.RegisterEffects()
    EVENT_MANAGER:RegisterForEvent(EGC.name, EVENT_EFFECT_CHANGED, EGC.Tracking.EarthgoreDidProc)
    EVENT_MANAGER:AddFilterForEvent(EGC.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, EARTHGORE_ID)
    EVENT_MANAGER:AddFilterForEvent(EGC.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EGC:Trace(2, "Registering effects")
end

function EGC.Tracking.UnregisterEffects()
    EVENT_MANAGER:UnregisterForEvent(EGC.name, EVENT_EFFECT_CHANGED)
    EGC:Trace(2, "Unregistering effects")
end

function EGC.Tracking.RegisterWornSlotUpdate()
    CALLBACK_MANAGER:RegisterCallback("WornSlotUpdate", EGC.Tracking.WornSlotUpdate)
    EGC:Trace(2, "Registering Worn Slot Update")
end

function EGC.Tracking.WornSlotUpdate(slotControl)
    if (slotControl.slotIndex ~= EQUIP_SLOT_HEAD
        and slotControl.slotIndex ~= EQUIP_SLOT_SHOULDERS) then return end

    EGC:Trace(2, "Head or shoulders changed.")
    EGC.Tracking.IsEarthgoreEquipped()
end

function EGC.Tracking.IsEarthgoreEquipped()

    local headLink      = GetItemLink(BAG_WORN, EQUIP_SLOT_HEAD)
    local shoulderLink  = GetItemLink(BAG_WORN, EQUIP_SLOT_SHOULDERS)

    local headHasSet, headSetName, _, headNumEquipped, headMaxEquipped = GetItemLinkSetInfo(headLink, true)
    local shoulderHasSet, shoulderSetName, _, shoulderNumEquipped, shoulderMaxEquipped = GetItemLinkSetInfo(shoulderLink, true)

    EGC:Trace(2, "Head: " .. headSetName .." (" .. headNumEquipped .. " of "
        .. headMaxEquipped .. ") Shoulders: " .. shoulderSetName .. " ("
        .. shoulderNumEquipped .. " of " .. shoulderMaxEquipped .. ")")

    if (headSetName == 'Earthgore' and
            shoulderSetName == 'Earthgore' and
            headNumEquipped == headMaxEquipped and
            shoulderNumEquipped == shoulderMaxEquipped) then
        EGC:Trace(1, "Wearing Earthgore!")
        EGC.enabled = true
        EGC.UI.ShowIcon(true)
        EGC.Tracking.RegisterEffects()
    else
        EGC:Trace(1, "Not wearing Earthgore!")
        EGC.enabled = false
        EGC.UI.ShowIcon(false)
        EGC.Tracking.UnregisterEffects()
    end

end

function EGC.Tracking.EarthgoreDidProc(_, changeType, _, effectName, _, _, _,
        _, _, _, _, _, _, _, _, effectAbilityId, sourceType)

    -- Ignore non-start changes
    if changeType ~= EFFECT_RESULT_GAINED then return end

    EGC:Trace(1, effectName .. " (" .. effectAbilityId .. ")")

    EGC.Tracking.timeOfProc = GetGameTimeMilliseconds()
    EGC.EGCTexture:SetColor(0.5, 0.5, 0.5, 1)

    PlaySound(SOUNDS.TELVAR_LOST)

    EVENT_MANAGER:RegisterForUpdate(EGC.name .. "Count", updateIntervalMs, EGC.UI.Update)

end

