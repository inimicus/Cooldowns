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
--setmetatable(leb, {__call = leb.Init})

local libName = 'LibEquipmentBonus'
local prefix = '[LibEquipmentBonus] '

-- Shared Data
leb.sets = leb.sets or {}
leb.items = leb.items or {}

-- Upvar
local sets = leb.sets
local items = leb.items

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

function leb:Trace(debugLevel, ...)
    if debugLevel <= self.debugMode then
        d(prefix .. '[' .. self.addonId .. '] ' .. ...)
    end
end

function leb:AddSetBonus(slot, itemLink)
    local hasSet, setName, _, _, maxEquipped = GetItemLinkSetInfo(itemLink, true)

    if hasSet and (self.filterBySetName == nil or setName == self.filterBySetName) then
        self:Trace(3, zo_strformat("Adding set bonus for: <<1>> (<<2>>)", itemLink, setName))

        -- Initialize first time encountering a set
        if leb.sets[setName] == nil then
            leb.sets[setName] = {}
            leb.sets[setName].maxBonus = maxEquipped
            leb.sets[setName].bonuses = {}
        end

        -- Update bonuses
        leb.sets[setName].bonuses[slot] = GetNumSetBonuses(itemLink)
    end
end

function leb:RemoveSetBonus(slot, itemLink)
    local hasSet, setName, _, _, _ = GetItemLinkSetInfo(itemLink, true)

    if hasSet and (self.filterBySetName == nil or setName == self.filterBySetName) then
        self:Trace(3, zo_strformat("Removing set bonus for: <<1>> (<<2>>)", itemLink, setName))

        -- Don't remove bonus if bonus wasn't added to begin with
        if leb.sets[setName] ~= nil and leb.sets[setName].bonuses[slot] ~=nil then
            leb.sets[setName].bonuses[slot] = 0
        end
    end
end

function leb:UpdateEnabledSets()
    self:Trace(2, 'Updating Enabled Sets')
    for key, set in pairs(leb.sets) do
        if set ~= nil then

            local totalBonus = 0
            for slot, bonus in pairs(set.bonuses) do
                totalBonus = totalBonus + bonus
            end

            if totalBonus >= set.maxBonus then
                if not set.equippedMax then
                    self:Trace(1, zo_strformat("Enabled: <<1>>", key))
                    set.equippedMax = true
                    self.EquipmentUpdateCallback(key, true)
                end
            else
                if set.equippedMax then
                    self:Trace(1, zo_strformat("Disabled: <<1>>", key))
                    set.equippedMax = false
                    self.EquipmentUpdateCallback(key, false)
                end
            end

        end
    end
end

function leb:UpdateSingleSlot(slotId, itemLink)
    local previousLink = leb.items[slotId]

    -- Update equipped item
    leb.items[slotId] = itemLink

    -- Item did not change
    if itemLink == previousLink then
        self:Trace(1, zo_strformat("Same item equipped: <<1>>", itemLink))
        return

    -- Item Removed (slot empty)
    elseif itemLink == '' then
        self:Trace(1, zo_strformat("Item unequipped: <<1>>", previousLink))
        self:RemoveSetBonus(slotId, previousLink)

    -- Item Changed
    else
        self:Trace(1, zo_strformat("New item equipped: <<1>>", itemLink))
        self:RemoveSetBonus(slotId, previousLink)
        self:AddSetBonus(slotId, itemLink)
    end

    self:UpdateEnabledSets()
end

function leb:WornSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
    -- Ignore costume updates
    if slotId == EQUIP_SLOT_COSTUME then return end

    local itemLink = GetItemLink(bagId, slotId)
    self:UpdateSingleSlot(slotId, itemLink)
end

function leb:UpdateAllSlots()

    self:Trace(1, 'Updating All Slots')
    for index, slot in pairs(ITEM_SLOTS) do
        local itemLink = GetItemLink(BAG_WORN, slot)

        if itemLink ~= "" then
            leb.items[slot] = itemLink
            self:AddSetBonus(slot, itemLink)
        end
    end

    self:UpdateEnabledSets()
end

function leb:SetDebug(debugLevel)
    -- Level of debug output
    -- 1: Low    - Basic debug info, show core functionality
    -- 2: Medium - More information about skills and addon details
    -- 3: High   - Everything
    self.debugMode = debugLevel
    self:Trace(1, zo_strformat("Setting debug to <<1>>", debugLevel))
end

function leb:FilterBySetName(setName)
    self.filterBySetName = setName
    self:Trace(1, zo_strformat("Added filter for: <<1>>", setName))
end

function leb:Register(callback)

    if callback == nil then
        self:Trace(0, 'Callback function required!')
        return
    end

    EVENT_MANAGER:RegisterForEvent(libName .. '_' .. self.addonId, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) self:WornSlotUpdate(...) end)
    EVENT_MANAGER:AddFilterForEvent(libName .. '_' .. self.addonId, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_BAG_ID, BAG_WORN,
        REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

    self.EquipmentUpdateCallback = callback

    if next(leb.items) == nil then
        self:Trace(1, 'Populating items')
        self:UpdateAllSlots()
    else
        self:Trace(1, 'Already populated, enabling sets')
        self:UpdateEnabledSets()
    end

end

function leb:Init(addonId)

    if type(addonId) ~= 'string' then
        PrintLater('[LibEquipmentBonus] Addon ID must be a string!')
        return
    end

    lib = {}
    lib.addonId = addonId
    setmetatable(lib, self)
    self.__index = self
    return lib
end

