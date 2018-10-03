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

EGC.Tracking.Sets = {
    {
        name = "Trappings of Invigoration",
        id = 101970,
        enabled = false,
        draw = function() return end,
    },
    {
        name = "Shroud of the Lich",
        id = 57164,
        enabled = false,
        draw = function() return end,
    },
    {
        name = "Earthgore",
        id = 97855,
        enabled = false,
        draw = function() EGC.UI.DrawEarthgore() return end,
    },
}

EGC.Tracking.ITEM_SLOTS = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
}

EGC.Tracking.ITEM_SLOT_NAMES = {
    "Head",
    "Neck",
    "Chest",
    "Shoulders",
    "Main-Hand Weapon",
    "Off-Hand Weapon",
    "Waist",
    "Legs",
    "Feet",
    "Ring 1",
    "Ring 2",
    "Hands",
    "Backup Main-Hand Weapon",
    "Backup Off-Hand Weapon",
}

local EARTHGORE_ID = 97855
local TRAPPINGS_ID = 101970
local LICH_ID = 57164

local updateIntervalMs = 100

function EGC.Tracking.RegisterEffects()
    --EVENT_MANAGER:RegisterForEvent(EGC.name, EVENT_EFFECT_CHANGED, EGC.Tracking.EarthgoreDidProc)
    --EVENT_MANAGER:AddFilterForEvent(EGC.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, EARTHGORE_ID)
    --EVENT_MANAGER:AddFilterForEvent(EGC.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForEvent(EGC.name, EVENT_COMBAT_EVENT, DidEventCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(EGC.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, TRAPPINGS_ID)
    EVENT_MANAGER:AddFilterForEvent(EGC.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForEvent(EGC.name .. "lich", EVENT_COMBAT_EVENT, DidEventCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(EGC.name .. "lich", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, LICH_ID)
    EVENT_MANAGER:AddFilterForEvent(EGC.name .. "lich", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForEvent(EGC.name .. "earthgore", EVENT_COMBAT_EVENT, DidEventCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(EGC.name .. "earthgore", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, EARTHGORE_ID)
    EVENT_MANAGER:AddFilterForEvent(EGC.name .. "earthgore", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EGC:Trace(2, "Registering effects")
end

-- EVENT_COMBAT_EVENT (
--*[ActionResult|#ActionResult]* _result_,
--*bool* _isError_,
--*string* _abilityName_,
--*integer* _abilityGraphic_,
--*[ActionSlotType|#ActionSlotType]* _abilityActionSlotType_,
--*string* _sourceName_,
--*[CombatUnitType|#CombatUnitType]* _sourceType_,
--*string* _targetName_,
--*[CombatUnitType|#CombatUnitType]* _targetType_,
--*integer* _hitValue_,
--*[CombatMechanicType|#CombatMechanicType]* _powerType_,
--*[DamageType|#DamageType]* _damageType_,
--*bool* _log_,
--*integer* _sourceUnitId_,
--*integer* _targetUnitId_,
--*integer* _abilityId_)
function DidEventCombatEvent(_, result, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
        -- ACTION_RESULT_POWER_ENERGIZE = 128 = Trappings
        -- ACTION_RESULT_HEAL = 16 = Earthgore HOT, but with a different ability ID
        -- ACTION_RESULT_EFFECT_GAINED = 2240 = Earthgore, Lich
        -- ACTION_RESULT_EFFECT_GAINED_DURATION = 2245 = Secondary lich effect (increased magicka recovery duration)

        if result == ACTION_RESULT_ABILITY_ON_COOLDOWN then
            EGC:Trace(1, zo_strformat("<<1>> (<<2>>) on Cooldown", abilityName, abilityId))
        elseif result == ACTION_RESULT_POWER_ENERGIZE then
            EGC:Trace(1, zo_strformat("Name: <<1>> ID: <<2>> with result <<3>>", abilityName, abilityId, result))
        else
            EGC:Trace(1, zo_strformat("Name: <<1>> ID: <<2>> with result <<3>>", abilityName, abilityId, result))
        end

        --EGC:Trace(1, zo_strformat("Event <<1>> (<<2>>) Icon: <<3>>", abilityName, abilityId, GetAbilityIcon(abilityId)))
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
	-- Ignore costume updates
    if slotControl.slotIndex == EQUIP_SLOT_COSTUME then return end

    -- Provide changed slot to check function
    EGC.Tracking.CheckEquippedSet(slotControl)
end

function EGC.Tracking.CheckEquippedSet(slotControl)

    -- If we're given a slot control to inspect
    if slotControl ~= nil then
        local itemLink = GetItemLink(BAG_WORN, slotControl.slotIndex)
        local hasSet, setName, numBonuses, numEquipped, maxEquipped = GetItemLinkSetInfo(itemLink, true)

        -- Item Removed
        if itemLink == "" then
            EGC:Trace(1, zo_strformat("Equipment unequipped"))

            -- Rerun this function, but check all pieces
            -- When an item is unequipped, we need to check all pieces
            -- that are currently equipped in order to determine if
            -- the set bonus is still active.
            EGC.Tracking.CheckEquippedSet()

        -- Non-empty slot
        else
            -- Process only items with set bouses
            if hasSet then
                EGC.Tracking.EnableTrackingForSet(setName, numEquipped, maxEquipped)
            end
        end

    -- Check all equipped items
    else
        -- Check every slot for sets
        for index, slot in pairs(EGC.Tracking.ITEM_SLOTS) do
            local itemLink = GetItemLink(BAG_WORN, slot)
            local slotName = EGC.Tracking.ITEM_SLOT_NAMES[index]

            -- If slot is empty
            if itemLink == "" then
                EGC:Trace(2, zo_strformat("<<1>>: Not Equipped", slotName))

            -- Non-empty slot
            else
                local hasSet, setName, numBonuses, numEquipped, maxEquipped = GetItemLinkSetInfo(itemLink, true)

                -- Set item equipped
                if hasSet then
                    EGC:Trace(2, zo_strformat("<<1>>: <<2>> (<<3>> of <<4>>)", slotName, setName, numEquipped, maxEquipped))

                    -- Check if we should enable tracking
                    EGC.Tracking.EnableTrackingForSet(setName, numEquipped, maxEquipped)

                -- Not a set item, ignore
                else
                    EGC:Trace(2, zo_strformat("<<1>>: No Set", slotName))
                end
            end

        end
    end

end

function EGC.Tracking.EnableTrackingForSet(setName, numEquipped, maxEquipped)

    -- Compared equipped sets to sets we should track
    for _, set in pairs(EGC.Tracking.Sets) do

        -- If a set we should track
        if setName == set.name then

            -- Full bonus active
            if numEquipped == maxEquipped then
                EGC:Trace(1, zo_strformat("Full set for: <<1>>, registering events", setName))
                EVENT_MANAGER:RegisterForEvent(EGC.name .. "_" .. set.id, EVENT_COMBAT_EVENT, DidEventCombatEvent)
                EVENT_MANAGER:AddFilterForEvent(EGC.name .. "_" .. set.id, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, set.id)
                EVENT_MANAGER:AddFilterForEvent(EGC.name .. "_" .. set.id, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
                -- TODO: Enable Set
                set.enabled = true

            -- Full bonus not active
            else
                EGC:Trace(1, zo_strformat("Not active for: <<1>>, unregistering events", setName))
                EVENT_MANAGER:UnregisterForEvent(EGC.name .. "_" .. set.id, EVENT_COMBAT_EVENT)
                -- TODO: Disable Set
                set.enabled = false
            end

        end
    end
    
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

    --EGC:Trace(1, effectName .. " (" .. effectAbilityId .. ")")
    --EGC:Trace(1, zo_strformat("Effect <<1>> (<<2>>) Icon: <<3>>", effectName, effectAbilityId, GetAbilityIcon(effectAbilityId)))

    EGC.Tracking.timeOfProc = GetGameTimeMilliseconds()
    EGC.EGCTexture:SetColor(0.5, 0.5, 0.5, 1)

    PlaySound(SOUNDS.TELVAR_LOST)

    EVENT_MANAGER:RegisterForUpdate(EGC.name .. "Count", updateIntervalMs, EGC.UI.Update)

end

