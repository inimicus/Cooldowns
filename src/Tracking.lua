-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Tracking.lua
-- -----------------------------------------------------------------------------

Cool.Tracking = {}

local updateIntervalMs = 100

-- ACTION_RESULT_POWER_ENERGIZE = 128
-- ACTION_RESULT_HEAL = 16
-- ACTION_RESULT_EFFECT_GAINED = 2240
-- ACTION_RESULT_EFFECT_GAINED_DURATION = 2245

Cool.Tracking.Sets = {
    Warlock = {
        name = "Vestments of the Warlock",
        settingsColor = "FF5EBD",
        id = 57163,
        enabled = false,
        result = ACTION_RESULT_POWER_ENERGIZE,
        cooldownDurationMs = 60000,
        onCooldown = false,
        timeOfProc = 0,
        texture = "/esoui/art/champion/champion_points_magicka_icon-hud.dds",
    },
    Trappings = {
        name = "Trappings of Invigoration",
        settingsColor = "FFA6D8",
        id = 101970,
        enabled = false,
        result = ACTION_RESULT_POWER_ENERGIZE,
        cooldownDurationMs = 60000,
        onCooldown = false,
        timeOfProc = 0,
        texture = "/esoui/art/champion/champion_points_stamina_icon-hud.dds",
    },
    Lich = {
        name = "Shroud of the Lich",
        settingsColor = "FF5EBD",
        id = 57164,
        enabled = false,
        result = ACTION_RESULT_EFFECT_GAINED,
        cooldownDurationMs = 60000,
        onCooldown = false,
        timeOfProc = 0,
        texture = "/esoui/art/champion/champion_points_magicka_icon-hud.dds",
    },
    Earthgore = {
        name = "Earthgore",
        settingsColor = "FFDE65",
        id = 97855,
        enabled = false,
        result = ACTION_RESULT_EFFECT_GAINED,
        cooldownDurationMs = 35000,
        onCooldown = false,
        timeOfProc = 0,
        texture = "/esoui/art/icons/gear_undaunted_ironatronach_head_a.dds",
    },
    Olorime = {
        name = "Vestment of Olorime",
        settingsColor = "FCFCCB",
        id = 107141,
        enabled = false,
        result = ACTION_RESULT_EFFECT_GAINED,
        cooldownDurationMs = 10000,
        onCooldown = false,
        timeOfProc = 0,
        texture = "/esoui/art/icons/placeholder/icon_health_major.dds",
    },
}

Cool.Tracking.ITEM_SLOTS = {
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

Cool.Tracking.ITEM_SLOT_NAMES = {
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

function Cool.Tracking.DidEventCombatEvent(setKey, _, result, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)

    local set = Cool.Tracking.Sets[setKey]

    if result == ACTION_RESULT_ABILITY_ON_COOLDOWN then
        Cool:Trace(1, zo_strformat("<<1>> (<<2>>) on Cooldown", abilityName, abilityId))
    elseif result == set.result then
        Cool:Trace(1, zo_strformat("Name: <<1>> ID: <<2>> with result <<3>>", abilityName, abilityId, result))
        set.onCooldown = true
        set.timeOfProc = GetGameTimeMilliseconds()
        Cool.UI.PlaySound(Cool.preferences.sets[setKey].sounds.onProc.sound)
        EVENT_MANAGER:RegisterForUpdate(Cool.name .. setKey .. "Count", updateIntervalMs, function(...) Cool.UI.Update(setKey) return end)
    else
        Cool:Trace(1, zo_strformat("Name: <<1>> ID: <<2>> with result <<3>>", abilityName, abilityId, result))
    end

end

function Cool.Tracking.RegisterUnfiltered()
    EVENT_MANAGER:RegisterForEvent(Cool.name .. "_Unfiltered", EVENT_COMBAT_EVENT, Cool.Tracking.DidEventCombatEventUnfiltered)
    Cool:Trace(1, "Registered Unfiltered Events")
end

function Cool.Tracking.UnregisterUnfiltered()
    EVENT_MANAGER:UnregisterForEvent(Cool.name .. "_Unfiltered", EVENT_COMBAT_EVENT)
    Cool:Trace(1, "Unregistered Unfiltered Events")
end

function Cool.Tracking.RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(Cool.name, EVENT_PLAYER_ALIVE, Cool.Tracking.OnAlive)
    EVENT_MANAGER:RegisterForEvent(Cool.name, EVENT_PLAYER_DEAD, Cool.Tracking.OnDeath)
	EVENT_MANAGER:RegisterForEvent(Cool.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, Cool.Tracking.WornSlotUpdate)
    EVENT_MANAGER:AddFilterForEvent(Cool.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_BAG_ID, BAG_WORN,
        REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
	
	if not Cool.preferences.showOutsideCombat then
		Cool.Tracking.RegisterCombatEvent()
	end

    Cool:Trace(2, "Registered Events")
end

function Cool.Tracking.UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent(Cool.name, EVENT_PLAYER_ALIVE)
    EVENT_MANAGER:UnregisterForEvent(Cool.name, EVENT_PLAYER_DEAD)
	EVENT_MANAGER:UnregisterForEvent(Cool.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    Cool:Trace(2, "Unregistered Events")
end

function Cool.Tracking.RegisterCombatEvent()
    EVENT_MANAGER:RegisterForEvent(Cool.name .. "COMBAT", EVENT_PLAYER_COMBAT_STATE, function(...) Cool.IsInCombat(...) end)
    Cool:Trace(2, "Registered combat events")
end

function Cool.Tracking.UnregisterCombatEvent()
    EVENT_MANAGER:UnregisterForEvent(Cool.name .. "COMBAT", EVENT_PLAYER_COMBAT_STATE)
    Cool:Trace(2, "Unregistered combat events")
end

function Cool.IsInCombat(_, inCombat)
    Cool.isInCombat = inCombat
    Cool:Trace(2, zo_strformat("In Combat: <<1>>", tostring(inCombat)))
    Cool.UI:SetCombatStateDisplay()
end

function Cool.Tracking.OnAlive()
    Cool.UI:SetCombatStateDisplay()
end

function Cool.Tracking.OnDeath()
    Cool.UI:SetCombatStateDisplay()
end

function Cool.Tracking.WornSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
    -- Ignore costume updates
    if slotId == EQUIP_SLOT_COSTUME then return end

    -- Check equipped sets
    Cool.Tracking.CheckEquippedSet()
end

function Cool.Tracking.CheckEquippedSet()

    -- Check every slot for sets
    for index, slot in pairs(Cool.Tracking.ITEM_SLOTS) do
        local itemLink = GetItemLink(BAG_WORN, slot)
        local slotName = Cool.Tracking.ITEM_SLOT_NAMES[index]

        -- If slot is empty
        if itemLink == "" then
            Cool:Trace(2, zo_strformat("<<1>>: Not Equipped", slotName))

        -- Non-empty slot
        else
            local hasSet, setName, numBonuses, numEquipped, maxEquipped = GetItemLinkSetInfo(itemLink, true)

            -- Set item equipped
            if hasSet then
                Cool:Trace(2, zo_strformat("<<1>>: <<2>> (<<3>> of <<4>>)", slotName, setName, numEquipped, maxEquipped))

                -- Check if we should enable tracking
                Cool.Tracking.EnableTrackingForSet(setName, numEquipped, maxEquipped)

            -- Not a set item, ignore
            else
                Cool:Trace(2, zo_strformat("<<1>>: No Set", slotName))
            end
        end

    end

end

function Cool.Tracking.EnableTrackingForSet(setName, numEquipped, maxEquipped)

    -- Compared equipped sets to sets we should track
    for key, set in pairs(Cool.Tracking.Sets) do

        -- If a set we should track
        if setName == set.name then

            -- Full bonus active
            if numEquipped == maxEquipped then

                -- Don't enable if already enabled
                if not set.enabled then
                    Cool:Trace(1, zo_strformat("Full set for: <<1>>, registering events", setName))
                    EVENT_MANAGER:RegisterForEvent(Cool.name .. "_" .. set.id, EVENT_COMBAT_EVENT, function(...) Cool.Tracking.DidEventCombatEvent(key, ...) end)
                    EVENT_MANAGER:AddFilterForEvent(Cool.name .. "_" .. set.id, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, set.id)
                    EVENT_MANAGER:AddFilterForEvent(Cool.name .. "_" .. set.id, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
                    set.enabled = true
                    Cool.UI.Draw(key)
                else 
                    Cool:Trace(2, zo_strformat("Set already enabled for: <<1>>", setName))
                end

            -- Full bonus not active
            else

                -- Don't disable if already disabled
                if set.enabled then
                    Cool:Trace(1, zo_strformat("Not active for: <<1>>, unregistering events", setName))
                    EVENT_MANAGER:UnregisterForEvent(Cool.name .. "_" .. set.id, EVENT_COMBAT_EVENT)
                    set.enabled = false
                    Cool.UI.Draw(key)
                else
                    Cool:Trace(2, zo_strformat("Set already disabled for: <<1>>", setName))
                end
            end

        end
    end

end

function Cool.Tracking.DidEventCombatEventUnfiltered(_, result, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    -- Exclude common unnecessary abilities
    local ignoreList = {
        sprint        = 973,
        sprintDrain   = 15356,
        block         = 14890,
        interrupt     = 55146,
        interrupt     = 55146,
        roll          = 28549,
        immov         = 29721,
        phase         = 98294,
        dodgeFatigue  = 69143,
    }

    for index, value in pairs(ignoreList) do
        if abilityId == value then return end
    end

    Cool:Trace(1, zo_strformat("<<1>> (<<2>>) with result <<3>>", abilityName, abilityId, result))
end

