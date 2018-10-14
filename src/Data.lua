-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: Oct 12, 2018
--
-- Data.lua
-- -----------------------------------------------------------------------------

-- Constants

-- ACTION_RESULT_POWER_ENERGIZE = 128
-- ACTION_RESULT_HEAL = 16
-- ACTION_RESULT_EFFECT_GAINED = 2240
-- ACTION_RESULT_EFFECT_GAINED_DURATION = 2245
-- ACTION_RESULT_ABILITY_ON_COOLDOWN = 2080

-- EVENT_ABILITY_COOLDOWN_UPDATED = 131181
-- EVENT_COMBAT_EVENT = 131102

Cool.Data = {}

Cool.Data.Sets = {
    ["Wyrd Tree's Blessing"] = {
        event = EVENT_ABILITY_COOLDOWN_UPDATED,
        description = "Displays when the Wyrd Tree proc is available or cooldown until it is ready again.",
        settingsColor = "FCFCCB",
        id = 34871,
        enabled = false,
        result = ACTION_RESULT_EFFECT_GAINED,
        cooldownDurationMs = 15000,
        onCooldown = false,
        timeOfProc = 0,
        texture = "/esoui/art/champion/champion_points_magicka_icon-hud.dds",
    },
    ["Vestments of the Warlock"] = {
        event = EVENT_COMBAT_EVENT,
        description = "Displays when the Magicka Flood proc is available or cooldown until it is ready again.",
        settingsColor = "3A97CF",
        id = 57163,
        enabled = false,
        result = ACTION_RESULT_POWER_ENERGIZE,
        cooldownDurationMs = 60000,
        onCooldown = false,
        timeOfProc = 0,
        texture = "/esoui/art/champion/champion_points_magicka_icon-hud.dds",
    },
    ["Trappings of Invigoration"] = {
        event = EVENT_COMBAT_EVENT,
        description = "Displays when the stamina return proc is available or cooldown until it is ready again.",
        settingsColor = "92C843",
        id = 101970,
        enabled = false,
        result = ACTION_RESULT_POWER_ENERGIZE,
        cooldownDurationMs = 60000,
        onCooldown = false,
        timeOfProc = 0,
        texture = "/esoui/art/champion/champion_points_stamina_icon-hud.dds",
    },
    ["Shroud of the Lich"] = {
        event = EVENT_COMBAT_EVENT,
        description = "Displays when the magicka recovery proc is ready or when it will be available, but not the duration of increased magicka recovery.",
        settingsColor = "3A97CF",
        id = 57164,
        enabled = false,
        result = ACTION_RESULT_EFFECT_GAINED,
        cooldownDurationMs = 60000,
        onCooldown = false,
        timeOfProc = 0,
        texture = "/esoui/art/champion/champion_points_magicka_icon-hud.dds",
    },
    ["Earthgore"] = {
        event = EVENT_COMBAT_EVENT,
        description = "Displays when the heal proc is ready or when it will be available, but not the duration of the heal over time.",
        settingsColor = "CD5031",
        id = 97855,
        enabled = false,
        result = ACTION_RESULT_EFFECT_GAINED,
        cooldownDurationMs = 35000,
        onCooldown = false,
        timeOfProc = 0,
        texture = "/esoui/art/icons/gear_undaunted_ironatronach_head_a.dds",
    },
    ["Vestment of Olorime"] = {
        event = EVENT_COMBAT_EVENT,
        description = "Displays when the Major Courage area of effect is able to be placed, but does not indicate the duration of Major Courage.",
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

Cool.Data.ITEM_SLOTS = {
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

Cool.Data.ITEM_SLOT_NAMES = {
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

