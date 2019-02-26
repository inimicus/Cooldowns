-- -----------------------------------------------------------------------------
-- LibEquipmentBonus
-- Author:  g4rr3t
-- Created: Oct 19, 2018
--
-- LibEquipmentBonus.lua
-- -----------------------------------------------------------------------------

-- Register LEB with LibStub
local MAJOR, MINOR = "LibEquipmentBonus", 2
local leb, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

-- Exit if same or more recent version is already loaded
if not leb then return end

local libName = 'LibEquipmentBonus'
local prefix = '[LibEquipmentBonus] '

-- Shared Data
leb.sets = leb.sets or {}
leb.items = leb.items or {}
leb.addons = leb.addons or {}

-- Upvar
local sets = leb.sets
local items = leb.items
local addons = leb.addons

-- Slots to monitor
local ITEM_SLOTS = {
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

local function GetNumSetBonuses(itemLink)
    local _, _, _, equipType = GetItemLinkInfo(itemLink)
    -- 2H weapons, staves, bows count as two set pieces
    if equipType == EQUIP_TYPE_TWO_HAND then
        return 2
    else
        return 1
    end
end

local function Trace(addon, debugLevel, ...)
    if debugLevel <= addon.debugMode then
        local message = zo_strformat(...)
        d(prefix .. '[' .. addon.addonId .. '] ' .. message)
    end
end

local function AddSetBonus(slot, itemLink)
    local hasSet, setName, _, _, maxEquipped = GetItemLinkSetInfo(itemLink, true)

    if hasSet then
        -- Initialize first time encountering a set
        if leb.sets[setName] == nil then
            leb.sets[setName] = {}
            leb.sets[setName].maxBonus = maxEquipped
            leb.sets[setName].equippedMax = false
            leb.sets[setName].bonuses = {}
        end

        -- Update bonuses
        leb.sets[setName].bonuses[slot] = GetNumSetBonuses(itemLink)
    end
end

local function RemoveSetBonus(slot, itemLink)
    local hasSet, setName, _, _, _ = GetItemLinkSetInfo(itemLink, true)

    if hasSet then
        -- Don't remove bonus if bonus wasn't added to begin with
        if leb.sets[setName] ~= nil and leb.sets[setName].bonuses[slot] ~= nil then
            leb.sets[setName].bonuses[slot] = 0
        end
    end
end

local function UpdateEnabledSets(forceNotify)

    for key, set in pairs(leb.sets) do
        if set ~= nil then

            -- Sum bonuses
            local totalBonus = 0
            for slot, bonus in pairs(set.bonuses) do
                totalBonus = totalBonus + bonus
            end

            -- Establish enabled and changed state
            local setMaxDidChange = false
            if totalBonus >= set.maxBonus then
                if not leb.sets[key].equippedMax then
                    setMaxDidChange = true
                    leb.sets[key].equippedMax = true
                end
            else
                if leb.sets[key].equippedMax then
                    setMaxDidChange = true
                    leb.sets[key].equippedMax = false
                end
            end

            if setMaxDidChange or forceNotify ~= nil then
                -- Notify addons
                for i=1, #addons do
                    if (addons[i].filterBySetName == nil or addons[i].filterBySetName == key) then
                        if (forceNotify ~= nil and forceNotify == addons[i].addonId) or forceNotify == nil then
                            Trace(addons[i], 1, "Notifying set update for: <<1>> (Enabled: <<2>>)", key, tostring(leb.sets[key].equippedMax))
                            addons[i].EquipmentUpdateCallback(key, leb.sets[key].equippedMax)
                        else
                            Trace(addons[i], 2, "Force notify not matched, not notifying for: <<1>> (Enabled: <<2>>)", key, tostring(leb.sets[key].equippedMax))
                        end
                    else
                        Trace(addons[i], 2, "Filter prevents notify: <<1>> (Enabled: <<2>>)", key, tostring(leb.sets[key].equippedMax))
                    end
                end
            end

            -- Reset change state
            setMaxDidChange = false

        end
    end
end

local function UpdateSingleSlot(slotId, itemLink)
    local previousLink = leb.items[slotId]

    -- Update equipped item
    leb.items[slotId] = itemLink

    -- Item did not change
    if itemLink == previousLink then
        return

    -- Item Removed (slot empty)
    elseif itemLink == '' then
        RemoveSetBonus(slotId, previousLink)

    -- Item Changed
    else
        RemoveSetBonus(slotId, previousLink)
        AddSetBonus(slotId, itemLink)
    end

    UpdateEnabledSets()
end

local function WornSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
    -- Ignore costume updates
    if slotId == EQUIP_SLOT_COSTUME then return end

    local itemLink = GetItemLink(bagId, slotId)
    UpdateSingleSlot(slotId, itemLink)
end

local function UpdateAllSlots()

    for index, slot in pairs(ITEM_SLOTS) do
        local itemLink = GetItemLink(BAG_WORN, slot)

        if itemLink ~= "" then
            leb.items[slot] = itemLink
            AddSetBonus(slot, itemLink)
        end
    end

end

function leb:SetDebug(debugLevel)
    -- Level of debug output
    -- 1: Low    - Basic debug info, show core functionality
    -- 2: Medium - More information about skills and addon details
    -- 3: High   - Everything
    self.debugMode = debugLevel
    Trace(self, 1, "Setting debug to <<1>>", debugLevel)
end

function leb:FilterBySetName(setName)
    self.filterBySetName = setName
    Trace(self, 1, "Added filter for: <<1>>", setName)
end

function leb:Register(callback)

    if callback == nil then
        Trace(self, 0, 'Callback function required! Aborting register.')
        return
    end

    self.EquipmentUpdateCallback = callback

    EVENT_MANAGER:RegisterForEvent(libName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, WornSlotUpdate)
    EVENT_MANAGER:AddFilterForEvent(libName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_BAG_ID, BAG_WORN,
        REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

    if next(leb.items) == nil then
        Trace(self, 2, 'Populating equipped items')
        UpdateAllSlots()
    else
        Trace(self, 2, 'Equipped items already populated')
    end

    UpdateEnabledSets(self.addonId)

end

function leb:Init(addonId)

    if type(addonId) ~= 'string' or string.len(addonId) == 0 then
        PrintLater('[LibEquipmentBonus] Addon ID must be a string! Aborting initialization.')
        return
    end

    local lib = {}
    lib.addonId = addonId
    lib.debugMode = 0

    setmetatable(lib, self)
    self.__index = self

    addons[#leb.addons+1] = lib

    return lib
end

