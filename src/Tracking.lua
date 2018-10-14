-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Tracking.lua
-- -----------------------------------------------------------------------------

Cool.Tracking = {}
Cool.Tracking.equipped = {}

local updateIntervalMs = 100

function Cool.Tracking.OnCooldownUpdated(setKey, eventCode, abilityId)
    -- When cooldown of this ability occurs, this function is continually called
    -- until the set is off cooldown.
    -- We can use the first call of this function to detect a proc state.

    local set = Cool.Tracking.Sets[setKey]

    -- Ignore if set is on cooldown
    if set.onCooldown == true then return end

    Cool:Trace(1, zo_strformat("Cooldown proc for <<1>> (<<2>>)", setKey, abilityId))

    set.onCooldown = true
    set.timeOfProc = GetGameTimeMilliseconds()
    Cool.UI.PlaySound(Cool.preferences.sets[setKey].sounds.onProc.sound)
    EVENT_MANAGER:RegisterForUpdate(Cool.name .. setKey .. "Count", updateIntervalMs, function(...) Cool.UI.Update(setKey) return end)
end


function Cool.Tracking.OnCombatEvent(setKey, _, result, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)

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
-- ----------------------------------------------------------------------------
-- Event Register/Unregister
-- ----------------------------------------------------------------------------

function Cool.Tracking.RegisterUnfiltered()
    EVENT_MANAGER:RegisterForEvent(Cool.name .. "_Unfiltered", EVENT_COMBAT_EVENT, Cool.Tracking.OnCombatEventUnfiltered)
    EVENT_MANAGER:AddFilterForEvent(Cool.name .. "_Unfiltered", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
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
    Cool.HUDHidden = false
    Cool.UI:SetCombatStateDisplay()
end

function Cool.Tracking.OnDeath()
    Cool.HUDHidden = true
    Cool.UI:SetCombatStateDisplay()
end

function Cool.Tracking.WornSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
    -- Ignore costume updates
    if slotId == EQUIP_SLOT_COSTUME then return end

    local wornLink = GetItemLink(badId, slotId)
    local hasSet, setName, numBonuses, numEquipped, maxEquipped = GetItemLinkSetInfo(wornLink, true)

    -- Detect changes to equipped 
    if wornLink == Cool.Tracking.equipped[slotId] then
        -- No change
        Cool:Trace(1, zo_strformat("Same item equipped: <<1>>", wornLink))
        return
    elseif wornLink == '' then
        -- Remove
        Cool:Trace(1, "Item unequipped")
        Cool.Tracking.equipped[slotId] = nil
        Cool.Tracking.CheckEquippedSetBonus()
    else 
        -- Changed
        Cool:Trace(1, zo_strformat("New item equipped: <<1>>", wornLink))
        Cool.Tracking.equipped[slotId] = wornLink

        -- Check equipped sets
        --Cool.Tracking.CheckEquippedSet()
        Cool.Tracking.CheckEquippedSetBonus()
    end
end

function Cool.Tracking.CheckEquippedSetBonus()
    local setBonus = {}

    for slot, itemLink in pairs(Cool.Tracking.equipped) do

        local hasSet, setName, numBonuses, numEquipped, maxEquipped = GetItemLinkSetInfo(itemLink, true)

        -- Count set equipped bonuses
        if hasSet then

            -- Initialize set bonus count
            setBonus[setName] = setBonus[setName] or 0

            -- 2H weapons, staves, bows count as two set pieces
            if GetItemLinkWeaponType(itemLink) == WEAPONTYPE_BOW
                or GetItemLinkWeaponType(itemLink) == WEAPONTYPE_FIRE_STAFF
                or GetItemLinkWeaponType(itemLink) == WEAPONTYPE_FROST_STAFF
                or GetItemLinkWeaponType(itemLink) == WEAPONTYPE_HEALING_STAFF
                or GetItemLinkWeaponType(itemLink) == WEAPONTYPE_LIGHTNING_STAFF
                or GetItemLinkWeaponType(itemLink) == WEAPONTYPE_TWO_HANDED_AXE
                or GetItemLinkWeaponType(itemLink) == WEAPONTYPE_TWO_HANDED_HAMMER
                or GetItemLinkWeaponType(itemLink) == WEAPONTYPE_TWO_HANDED_SWORD
            then
                -- Counts as 2
                setBonus[setName] = setBonus[setName] + 2
            else
                -- Counts as 1
                setBonus[setName] = setBonus[setName] + 1
            end
        end

    end
end

function Cool.Tracking.CheckEquippedSet()

    -- Clear equipped
    Cool.Tracking.equipped = {}

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

                -- Save sets
                Cool.Tracking.equipped[slot] = itemLink

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

                    -- Set callback based on event
                    local procFunction = nil
                    if set.event == EVENT_ABILITY_COOLDOWN_UPDATED then
                        procFunction = Cool.Tracking.OnCooldownUpdated
                    else
                        procFunction = Cool.Tracking.OnCombatEvent
                    end

                    -- Register events
                    EVENT_MANAGER:RegisterForEvent(Cool.name .. "_" .. set.id, set.event, function(...) procFunction(key, ...) end)
                    EVENT_MANAGER:AddFilterForEvent(Cool.name .. "_" .. set.id, set.event,
                        REGISTER_FILTER_ABILITY_ID, set.id,
                        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

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
                    EVENT_MANAGER:UnregisterForEvent(Cool.name .. "_" .. set.id, set.event)
                    set.enabled = false
                    Cool.UI.Draw(key)
                else
                    Cool:Trace(2, zo_strformat("Set already disabled for: <<1>>", setName))
                end
            end

        end
    end

end

function Cool.Tracking.OnCombatEventUnfiltered(_, result, _, abilityName, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    -- Exclude common unnecessary abilities
    local ignoreList = {
        sprint        = 973,
        sprintDrain   = 15356,
        block         = 14890,
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

