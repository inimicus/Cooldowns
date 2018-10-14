-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: Oct 13, 2018
--
-- Equipped.lua
-- -----------------------------------------------------------------------------

Cool.Equipped = {}
local items = {}
local sets = {}

local function GetNumSetBonuses(itemLink)
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
        return 2
    else
        return 1
    end
end

local function AddSetBonus(slot, itemLink)
    local hasSet, setName, _, _, maxEquipped = GetItemLinkSetInfo(itemLink, true)

    if hasSet then
        -- Initialize first time encountering a set
        if sets[setName] == nil then
            sets[setName] = {}
            sets[setName].maxBonus = maxEquipped
            sets[setName].bonuses = {}
        end

        -- Update bonuses
        sets[setName].bonuses[slot] = GetNumSetBonuses(itemLink)
    end
end

local function RemoveSetBonus(slot, itemLink)
    local hasSet, setName, _, _, _ = GetItemLinkSetInfo(itemLink, true)

    if hasSet then
        -- Don't remove bonus if bonus wasn't added to begin with
        if sets[setName] ~= nil and sets[setName].bonuses[slot] ~=nil then
            sets[setName].bonuses[slot] = 0
        end
    end
end

local function UpdateEnabledSets()
    for key, set in pairs(Cool.Data.Sets) do
        if sets[key] ~= nil then

            local totalBonus = 0
            for slot, bonus in pairs(sets[key].bonuses) do
                totalBonus = totalBonus + bonus
            end

            if totalBonus >= sets[key].maxBonus then
                Cool.Tracking.EnableTrackingForSet(key, true)
            else
                Cool.Tracking.EnableTrackingForSet(key, false)
            end

        end
    end
end

local function UpdateSingleSlot(slotId, itemLink)
    local previousLink = items[slotId]

    -- Update equipped item
    items[slotId] = itemLink

    -- Item did not change
    if itemLink == previousLink then
        Cool:Trace(1, zo_strformat("Same item equipped: <<1>>", itemLink))
        return

    -- Item Removed (slot empty)
    elseif itemLink == '' then
        Cool:Trace(1, "Item unequipped")
        RemoveSetBonus(slotId, previousLink)

    -- Item Changed
    else
        Cool:Trace(1, zo_strformat("New item equipped: <<1>>", itemLink))
        RemoveSetBonus(slotId, previousLink)
        AddSetBonus(slotId, itemLink)
    end

    UpdateEnabledSets()
end

function Cool.Equipped.WornSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
    -- Ignore costume updates
    if slotId == EQUIP_SLOT_COSTUME then return end

    local itemLink = GetItemLink(badId, slotId)
    UpdateSingleSlot(slotId, itemLink)
end

function Cool.Equipped.UpdateAllSlots()
    for index, slot in pairs(Cool.Data.ITEM_SLOTS) do
        local itemLink = GetItemLink(BAG_WORN, slot)

        if itemLink ~= "" then
            items[slot] = itemLink
            AddSetBonus(slot, itemLink)
        end
    end

    UpdateEnabledSets()
end

