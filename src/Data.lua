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
-- EVENT_EFFECT_CHANGED = 131150
Cool = Cool or {}
Cool.Data = {}

function Cool.GetSetData()
    local libSets = LibSets
    if not libSets then d("[Cooldowns]Needed library LibSets is not loaded!") return end
    if libSets.IsSetsScanning() or not libSets.AreSetsLoaded() then d("[Cooldowns]Needed library LibSets has not finished to load the sets data yet!\nPlease wait for it to finish and do the needed /reloadui afterwards (shown in a popup prompt)!") return end

    local clientLang = Cool.clientLang

    --The data table with the sets. Table key is the unique setId from function GetItemLinkSetInfo
    --The name is the client language dependent set name from the library LibSet
    --local isSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
    Cool.Data.Sets = {
        --Magicka Furnace
        [103] = {
            name = libSets.GetSetName(103, clientLang),
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Magicka Furnace proc is available or cooldown until it is ready again.",
            settingsColor = "3A97CF",
            id = 34813,
            enabled = false,
            result = ACTION_RESULT_POWER_ENERGIZE,
            cooldownDurationMs = 30000,
            onCooldown = false,
            timeOfProc = 0,
            texture = "/esoui/art/champion/champion_points_magicka_icon-hud.dds",
            showFrame = false,
            isSynergy = false,
        },
        --Wyrd Tree's Blessing
        [107] = {
            name = libSets.GetSetName(107, clientLang),
            event = EVENT_ABILITY_COOLDOWN_UPDATED,
            description = "Displays when the Wyrd Tree proc is available or cooldown until it is ready again.",
            settingsColor = "FCFCCB",
            id = 34871,
            enabled = false,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 15000,
            onCooldown = false,
            timeOfProc = 0,
            texture = "/esoui/art/icons/ability_ava_005.dds",
            showFrame = true,
            isSynergy = false,
        },
        --Vestments of the Warlock
        [19] = {
            name = libSets.GetSetName(19, clientLang),
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
            showFrame = false,
            isSynergy = false,
        },
        --Trappings of Invigoration
        [344] = {
            name = libSets.GetSetName(344, clientLang),
            name = "Wyrd Tree's Blessing",
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
            showFrame = false,
            isSynergy = false,
        },
        --Shroud of the Lich
        [134] = {
            name = libSets.GetSetName(134, clientLang),
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
            showFrame = false,
            isSynergy = false,
        },
        --Earthgore
        [341] = {
            name = libSets.GetSetName(341, clientLang),
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
            showFrame = false,
            isSynergy = false,
        },
        --Vestment of Olorime
        [391] = {
            name = libSets.GetSetName(391, clientLang),
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
            showFrame = true,
            isSynergy = false,
        },
        --Vykosa
        [398] = {
            name = libSets.GetSetName(398, clientLang),
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Major Maim debuff is able to be applied.",
            settingsColor = "CD5031",
            id = 111354, -- Major Maim
            enabled = false,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 15000,
            onCooldown = false,
            timeOfProc = 0,
            texture = "/esoui/art/icons/ability_debuff_major_maim.dds",
            --texture = "/esoui/art/icons/gear_undvykosa_helmet_a.dds",
            showFrame = true,
            isSynergy = false,
        },
        --Steadfast Hero
        [421] = {
            name = libSets.GetSetName(421, clientLang),
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Major Protection buff is available through cleansing a negative effect on yourself or an ally.",
            settingsColor = "FCFCCB",
            id = 113509, -- Major Protection
            enabled = false,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 10000,
            onCooldown = false,
            timeOfProc = 0,
            texture = "/esoui/art/icons/ability_buff_major_protection.dds",
            showFrame = true,
            isSynergy = false,
        },
        --Zaan
        [350] = {
            name = libSets.GetSetName(350, clientLang),
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the cheese beam of fiery death is ready to ruin someone's day.",
            settingsColor = "3A97CF",
            id = 102136,
            enabled = false,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 18000,
            onCooldown = false,
            timeOfProc = 0,
            texture = "/esoui/art/icons/gear_undaunted_dragonpriest_head_a.dds",
            showFrame = false,
            isSynergy = false,
        },
        --Caluurion's Legacy
        [343] = {
            name = libSets.GetSetName(343, clientLang),
            -- Caluurion Duration = 102060
            -- Disease  = 102033
            -- Fire     = 102027
            -- Shock    = 102034
            -- Ice      = 102032
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the fire, shock, ice, or disease ball proc is ready or when it will be available.",
            settingsColor = "3A97CF",
            id = 102060,
            enabled = false,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 10000,
            onCooldown = false,
            timeOfProc = 0,
            texture = "/esoui/art/icons/death_recap_fire_ranged.dds",
            showFrame = true,
            isSynergy = false,
        },
        --Mechanical Acuity
        [353] = {
            name = libSets.GetSetName(353, clientLang),
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Mechanical Acuity proc is ready or when it will be available, but not the duration of the crit bonus.",
            settingsColor = "CD5031",
            id = 99204,
            enabled = false,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 18000,
            onCooldown = false,
            timeOfProc = 0,
            --texture = "/esoui/art/icons/gear_clockwork_medium_head_a.dds",
            texture = "/esoui/art/icons/ability_buff_major_sorcery.dds",
            showFrame = true,
            isSynergy = false,
        },
        --Blood Spawn
        [163] = {
            name = libSets.GetSetName(163, clientLang),
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Blood Spawn ultimate generation and resistance buffs are ready or when they will be available, but not their duration.",
            settingsColor = "CD5031",
            id = 59517,
            enabled = false,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 6000,
            onCooldown = false,
            timeOfProc = 0,
            texture = "/esoui/art/icons/gear_undauntedgargoyle_head_a.dds",
            showFrame = false,
            isSynergy = false,
        },
        --Stonekeeper
        [432] = {
            name = libSets.GetSetName(432, clientLang),
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Stonekeeper can generate Charge stacks or until it can generate stacks again. Does not show current Charge stacks.",
            settingsColor = "CD5031",
            id = 116877,
            enabled = false,
            result = ACTION_RESULT_POWER_ENERGIZE,
            cooldownDurationMs = 14000,
            onCooldown = false,
            timeOfProc = 0,
            texture = "/esoui/art/icons/gear_undauntedstonekeeper_head_a.dds",
            --texture = "/esoui/art/champion/champion_points_health_icon-hud.dds",
            showFrame = false,
            isSynergy = false,
        },
        --Symphony of Blades
        [436] = {
            name = libSets.GetSetName(436, clientLang),
            event = EVENT_COMBAT_EVENT,
            description = "Displays when Meridia's Favor is ready or when it will become available to be applied to an ally.",
            settingsColor = "CD5031",
            id = 117111,
            enabled = false,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 18000,
            onCooldown = false,
            timeOfProc = 0,
            texture = "/esoui/art/icons/gear_undnarlimor_head_a.dds",
            showFrame = false,
            isSynergy = false,
        },
        --Crest of Cyrodiil
        [113] = {
            name = libSets.GetSetName(113, clientLang),
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the heal on block from Crest of Cyrodiil is ready or when it will become available.",
            settingsColor = "92C843",
            id = 111575,
            enabled = false,
            result = ACTION_RESULT_HEAL,
            cooldownDurationMs = 5000,
            onCooldown = false,
            timeOfProc = 0,
            texture = "esoui/art/icons/placeholder/icon_offensive_shieldsword_01.dds",
            showFrame = true,
            isSynergy = false,
        },
        --Ravager
        [108] = {
            name = libSets.GetSetName(108, clientLang),
            event = EVENT_COMBAT_EVENT,
            description = "Displays when The Ravager weapon damage buff proc is ready or when it will become available.",
            settingsColor = "92C843",
            id = 34872,
            enabled = false,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 10000,
            onCooldown = false,
            timeOfProc = 0,
            texture = "/esoui/art/icons/ability_warrior_012.dds",
            --texture = "/LuiExtended/media/icons/abilities/ability_set_the_ravager.dds",
            showFrame = true,
            isSynergy = false,
        },

        -- Synergies --------------------------------------------------------------
        ["Orbs / Shards"] = {
            name = {
                ["en"] = "Orbs / Shards",
                ["de"] = "Kugeln / Scherben",
            },
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Undaunted orb or Templar shard synergy is able to be used or when it will become available.",
            settingsColor = "FCFCCB",
            id = {108799, 108802, 108821, 108924},
            enabled = false,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 20000,
            onCooldown = false,
            timeOfProc = 0,
            texture = "/esoui/art/icons/ability_undaunted_004b.dds",
            showFrame = true,
            isSynergy = true,
        },
        ["Conduit"] = {
            name = {
                ["en"] = "Conduit",
                ["de"] = "Conduit",
            },
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Conduit synergy from the Sorcerer Lightning Splash ability is able to be used or when it will become available.",
            settingsColor = "3A97CF",
            id = 108607,
            enabled = false,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 20000,
            onCooldown = false,
            timeOfProc = 0,
            texture = "/esoui/art/icons/ability_sorcerer_liquid_lightning.dds",
            showFrame = true,
            isSynergy = true,
        },
        ["Purify"] = {
            name = {
                ["en"] = "Purify",
                ["de"] = "Purify",
            },
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Purify synergy from the Templar Cleansing Ritual ability is able to be used or when it will become available.",
            settingsColor = "FCFCCB",
            id = 108824,
            enabled = false,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 20000,
            onCooldown = false,
            timeOfProc = 0,
            texture = "/esoui/art/icons/ability_templar_extended_ritual.dds",
            showFrame = true,
            isSynergy = true,
        },
        ["Boner Shield"] = {
            name = {
                ["en"] = "Boner Shield",
                ["de"] = "Knochenschild",
            },
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Undaunted Bone Wall/Bone Shield synergy is able to be used or when it will become available.",
            settingsColor = "92C843",
            id = {108794, 108797},
            enabled = false,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 20000,
            onCooldown = false,
            timeOfProc = 0,
            texture = "/esoui/art/icons/ability_undaunted_005.dds",
            showFrame = true,
            isSynergy = true,
        },
        ["Blood Altar"] = {
            name = {
                ["en"] = "Blood Altar",
                ["de"] = "Blut Altar",
            },
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Undaunted Blood Altar/Overflowing Altar synergy is able to be used or when it will become available.",
            settingsColor = "CD5031",
            id = {108782, 108787},
            enabled = false,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 20000,
            onCooldown = false,
            timeOfProc = 0,
            texture = "/esoui/art/icons/ability_undaunted_001_b.dds",
            showFrame = true,
            isSynergy = true,
        },
        ["Harvest"] = {
            name = {
                ["en"] = "Harvest",
                ["de"] = "Harvest",
            },
            -- Thanks to Liofa for patching and testing for this synergy
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Warden Healing Seed synergy is able to be used or when it will become available.",
            settingsColor = "CD5031",
            id = 108826,
            enabled = false,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 20000,
            onCooldown = false,
            timeOfProc = 0,
            texture = "/esoui/art/icons/ability_warden_007.dds",
            showFrame = true,
            isSynergy = true,
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
end
