-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: Oct 12, 2018
--
-- Data.lua
-- -----------------------------------------------------------------------------
--
-- To all you helpful individuals who romp in here to add things
-- on your own, thank you.
--
-- I'm sorry my updates overwrite your changes and you have to constantly
-- backup this file or ignore updates in order to keep your version working.
--
-- If you'd like to submit a pull request on GitHub, I'd happily take a look.
--
--      https://github.com/inimicus/cooldowns
--
-- Here is some information that might be helpful:
--
-- Debugging/Finding IDs:
-- When finding information about new sets, you can get chat log spammed with
-- information about every EVENT_COMBAT_EVENT by typing in game chat:
--
--      /cool all on
--
-- You'll get spammed with all the abilities in chat. There might even be
-- a similar debug for effects commented somewhere else in the code, too.
--
-- Proc your set/synergy/whatever, then look for it in the chat. You'll get
-- the name, the ID, and the result. Take note of these values and then add
-- them to the Sets table below along with any other values needed.
--
-- Turn off chat spam with:
--
--      /cool all off
--
-- Easy as that.
--
-- Cool.Data.Sets (table):
-- This table contains all the set, synergy, and passive information that
-- the addon uses. But you probably already knew that.
--
-- Each entry is stored in a table with its key being the string name
-- of the set to track. Because of this, non-English clients don't work.
--
-- There are plans to implement better tracking that doesn't use the set name
-- and there is already a new branch on GitHub to track efforts there. But it
-- is quite a bit out of date, unfortunately.
--
-- Big thanks to Baertram for helping out on multi-language support.
--
-- Configuration Options:
--
-- * procType (string):     One of "set", "synergy", or "passive" to indicate
--                          what kind of tracking it is. Duhhhhh.
--
-- * event (number):        What kind of action identifies the proc happened.
--                          Generally this is EVENT_COMBAT_EVENT or 131102, but
--                          some other values do exist (Wyrd Tree, others).
--
-- * description (string):  Cosmetic. Adds a description to the tooltip.
--
-- * id (number | array):   The ID that identifies the proc condition.
--                          This can also be an array of numbers for proc
--                          conditions that span multiple IDs (Perfected/Non,
--                          synergies, stupid Pirate Skelly, and more).
--
-- * result (number):       The result of the proc. These are numeric, defined
--                          in the table using their constants. When debugging,
--                          the number will appear instead of the constant name,
--                          so refer to the constants section below to match.
--
-- * cooldownDurationMs (number):   Number in milliseconds for the cooldown.
--                                  e.g. 30 seconds is 30000
--
-- * texture (string):      The path to the texture to use for the cooldown
--                          display. You can find textures with the TextureIt
--                          addon (though what's there is largely out of date)
--                          or via the method `GetAbilityIcon([abilityId])`.
--                          I just generally use any icon that doesn't
--                          look like ass. A lot look like ass.
--
-- * showFrame (bool):      Enables or disables showing the frame around
--                          the icon. Not used for monster helm icons.
--                          But most monster helm icons look like ass.
--
-- Constants:
--
-- Reference this section to make sense of what result and event numbers in
-- debug messages mean.
--
-- Results:
-- ACTION_RESULT_DAMAGE                 = 1
-- ACTION_RESULT_POWER_ENERGIZE         = 128
-- ACTION_RESULT_HEAL                   = 16
-- ACTION_RESULT_EFFECT_GAINED          = 2240 - The most common
-- ACTION_RESULT_EFFECT_GAINED_DURATION = 2245 - Use 2240 if both show up
-- ACTION_RESULT_ABILITY_ON_COOLDOWN    = 2080

-- Events:
-- EVENT_ABILITY_COOLDOWN_UPDATED       = 131181
-- EVENT_COMBAT_EVENT                   = 131102
-- EVENT_EFFECT_CHANGED                 = 131150
--
-- -----------------------------------------------------------------------------

Cool = Cool or {}
Cool.Data = {}

function Cool.GetSetData()
    local libSets = LibSets

    if not libSets then
        Cool:Trace(0, "Needed library LibSets is not loaded!")
        return
    end

    if libSets.IsSetsScanning() or not libSets.AreSetsLoaded() then
        Cool:Trace(0, "Needed library LibSets has not finished to load the sets data yet!\nPlease wait for it to finish and do the needed /reloadui afterwards (shown in a popup prompt)!")
        return
    end

    local clientLang = Cool.clientLang

    -- The data table with the sets. Table key is the unique setId from function GetItemLinkSetInfo
    -- The name is the client language dependent set name from the library LibSet
    -- local isSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)

    Cool.Data.Sets = {
        --["Magicka Furnace"] = {
        [103] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Magicka Furnace proc is available or cooldown until it is ready again.",
            id = 34813,
            result = ACTION_RESULT_POWER_ENERGIZE,
            cooldownDurationMs = 30000,
            texture = "/esoui/art/champion/champion_points_magicka_icon-hud.dds",
            showFrame = false,
        },
        --["Wyrd Tree's Blessing"] = {
        [107] = {
            procType = "set",
            event = EVENT_ABILITY_COOLDOWN_UPDATED,
            description = "Displays when the Wyrd Tree proc is available or cooldown until it is ready again.",
            id = 34871,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 15000,
            texture = "/esoui/art/icons/ability_ava_005.dds",
            showFrame = true,
        },
        --["Vestments of the Warlock"] = {
        [19] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Magicka Flood proc is available or cooldown until it is ready again.",
            id = 57163,
            result = ACTION_RESULT_POWER_ENERGIZE,
            cooldownDurationMs = 45000,
            texture = "/esoui/art/champion/champion_points_magicka_icon-hud.dds",
            showFrame = false,
        },
        --["Trappings of Invigoration"] = {
        [344] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the stamina return proc is available or cooldown until it is ready again.",
            id = 101970,
            result = ACTION_RESULT_POWER_ENERGIZE,
            cooldownDurationMs = 45000,
            texture = "/esoui/art/champion/champion_points_stamina_icon-hud.dds",
            showFrame = false,
        },
        --["Shroud of the Lich"] = {
        [134] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the magicka recovery proc is ready or when it will be available, but not the duration of increased magicka recovery.",
            id = 57164,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 60000,
            texture = "/esoui/art/champion/champion_points_magicka_icon-hud.dds",
            showFrame = false,
        },
        --["Earthgore"] = {
        [341] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the heal proc is ready or when it will be available, but not the duration of the heal over time.",
            id = 97855,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 35000,
            texture = "/esoui/art/icons/gear_undaunted_ironatronach_head_a.dds",
            showFrame = false,
        },
        --["Vestment of Olorime"] = {
        [391] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Major Courage area of effect is able to be placed, but does not indicate the duration of Major Courage.",
            id = {107141, 109084},
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 10000,
            texture = "/esoui/art/icons/placeholder/icon_health_major.dds",
            showFrame = true,
        },
        --["Vykosa"] = {
        [398] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Major Maim debuff is able to be applied.",
            id = 111354, -- Major Maim
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 15000,
            texture = "/esoui/art/icons/ability_debuff_major_maim.dds",
            --texture = "/esoui/art/icons/gear_undvykosa_helmet_a.dds",
            showFrame = true,
        },
        --["Steadfast Hero"] = {
        [421] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Major Protection buff is available through cleansing a negative effect on yourself or an ally.",
            id = 113509, -- Major Protection
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 10000,
            texture = "/esoui/art/icons/ability_buff_major_protection.dds",
            showFrame = true,
        },
        --["Zaan"] = {
        [350] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the cheese beam of fiery death is ready to ruin someone's day.",
            id = 102136,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 18000,
            texture = "/esoui/art/icons/gear_undaunted_dragonpriest_head_a.dds",
            showFrame = false,
        },
        --["Caluurion's Legacy"] = {
        [343] = {
            procType = "set",
            -- Caluurion Duration = 102060
            -- Disease  = 102033
            -- Fire     = 102027
            -- Shock    = 102034
            -- Ice      = 102032
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the fire, shock, ice, or disease ball proc is ready or when it will be available.",
            id = 102060,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 10000,
            texture = "/esoui/art/icons/death_recap_fire_ranged.dds",
            showFrame = true,
        },
        --["Mechanical Acuity"] = {
        [353] = {
            -- Wheels does it better
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Mechanical Acuity proc is ready or when it will be available, but not the duration of the crit bonus.",
            id = 99204,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 18000,
            --texture = "/esoui/art/icons/gear_clockwork_medium_head_a.dds",
            --texture = "/esoui/art/icons/ability_buff_major_sorcery.dds",
            texture = "/esoui/art/icons/ability_rogue_039.dds",
            showFrame = true,
        },
        --["Bloodspawn"] = {
        [163] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Blood Spawn ultimate generation and resistance buffs are ready or when they will be available, but not their duration.",
            id = 59517,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 6000,
            texture = "/esoui/art/icons/gear_undauntedgargoyle_head_a.dds",
            showFrame = false,
        },
        --["Stonekeeper"] = {
        [432] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Stonekeeper can generate Charge stacks or until it can generate stacks again. Does not show current Charge stacks.",
            id = 116877,
            result = ACTION_RESULT_POWER_ENERGIZE,
            cooldownDurationMs = 14000,
            texture = "/esoui/art/icons/gear_undauntedstonekeeper_head_a.dds",
            --texture = "/esoui/art/champion/champion_points_health_icon-hud.dds",
            showFrame = false,
        },
        --["Symphony of Blades"] = {
        [436] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when Meridia's Favor is ready or when it will become available to be applied to an ally.",
            id = 117111,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 18000,
            --texture = "/esoui/art/icons/gear_undnarlimor_head_a.dds",
            texture = "/esoui/art/icons/ability_mage_050.dds",
            showFrame = false,
        },
        --["Crest of Cyrodiil"] = {
        [113] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the heal on block from Crest of Cyrodiil is ready or when it will become available.",
            id = 111575,
            result = ACTION_RESULT_HEAL,
            cooldownDurationMs = 5000,
            texture = "esoui/art/icons/placeholder/icon_offensive_shieldsword_01.dds",
            showFrame = true,
        },
        --["Ravager"] = {
        [108] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when The Ravager weapon damage buff proc is ready or when it will become available.",
            id = 34872,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 10000,
            texture = "/esoui/art/icons/ability_warrior_012.dds",
            --texture = "/LuiExtended/media/icons/abilities/ability_set_the_ravager.dds",
            showFrame = true,
        },
        --["Curse Eater"] = {
        [104] = {
            procType = "set",
            event = EVENT_ABILITY_COOLDOWN_UPDATED,
            description = "Displays when the Curse Eater removal of negative effects is ready or when it will become available.",
            --id = 117359, -- Event
            id = 117360, -- Cooldown
            result = ACTION_RESULT_POWER_ENERGIZE,
            cooldownDurationMs = 8000,
            texture = "/esoui/art/icons/ability_ava_005_a.dds",
            showFrame = true,
        },
        --["Icy Conjuror"] = {
        [431] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Ice Wraith proc after applying a minor debuff is ready or when it will become available.",
            id = 117666,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 12000,
            -- LuiExtended/media/icons/abilities/ability_set_icy_conjuror.dds
            texture = "/esoui/art/icons/death_recap_cold_ranged.dds",
            showFrame = true,
        },
        --["Hide of the Werewolf"] = {
        [58] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the ultimate generation from this set is ready or when it will become available.",
            id = 34508, -- Cooldown
            result = ACTION_RESULT_POWER_ENERGIZE,
            cooldownDurationMs = 5000,
            -- LuiExtended/media/icons/abilities/ability_set_werewolf_hide.dds
            texture = "/esoui/art/icons/ability_werewolf_004_a.dds",
            showFrame = true,
        },
        -- ["Essence Thief"] = {
        [198] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the essence pool is ready to be drawn from the enemy or when it will become available.",
            id = 67324,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 10000,
            texture = "/esoui/art/icons/ability_warrior_012.dds",
            showFrame = true,
        },
        --["Armor of Truth"] = {
        [96] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when you are able to gain weapon damage by setting an enemy Off Balance or when it will become available.",
            id = 86070,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 10000,
            texture = "/esoui/art/icons/ability_debuff_offbalance.dds",
            showFrame = true,
        },
        -- ["Claw of Yolnahkriin"] = {
        [446] = {
            -- Thanks to Troodon80 for providing code and suggestion for this!
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Minor Courage effect is able to be applied, but does not indicate the duration of Minor Courage.",
            id = 121878,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 8000,
            texture = "/esoui/art/icons/placeholder/icon_health_major.dds",
            showFrame = true,
        },
        --["Pirate Skeleton"] = {
        [277] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Major Protection/Minor Defile effect from the Pirate Skeleton set can be proc, but does not indicate the duration of these buffs/debuffs.",
            -- This is fucked, why different based on class?
            id = {
                --80501, -- Equipped?
                81675, -- Necro
                83288, -- ?
                83287, -- ?
                98419, -- Templar
                98420, -- ?
                98421, -- Sorcerer?
            },
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 15000,
            texture = "/esoui/art/icons/event_witchfest_sacking_skelet.dds",
            showFrame = true,
            -- Helm icon Looks like ass
            -- texture = "/esoui/art/icons/gear_undauntedpirateskeleton_head_a.dds",
            -- showFrame = false,
        },
        --["Maarselok"] = {
        [459] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when you can spew a cone of corruption, much like your mum did when you were born.",
            id = 126941,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 7000,
            -- Helm texture looks like ass
            -- texture = "/esoui/art/icons/gear_undmaarselok_helmet_a.dds",
            texture = "/esoui/art/icons/death_recap_disease_melee.dds",
            showFrame = true,
        },
        --["Seventh Legion Brute"] = {
        [70] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the added weapon damage and health recovery effect can proc.",
            id = 127271,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 10000,
            texture = "/esoui/art/icons/ability_warrior_012.dds",
            showFrame = true,
        },
        -- ["Way of Martial Knowledge"] = {
        [147] = {
            procType = "set",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when Way of Martial Knowledge debuff can be proc.",
            id = 127070,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 8000,
            texture = "/esoui/art/icons/ability_mage_044.dds",
            showFrame = true,
        },

        -- Synergies --------------------------------------------------------------
        ["Orbs / Shards"] = {
            procType = "synergy",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Undaunted orb or Templar shard synergy is able to be used or when it will become available.",
            id = {108799, 108802, 108821, 108924},
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 20000,
            texture = "/esoui/art/icons/ability_undaunted_004b.dds",
            showFrame = true,
        },
        ["Conduit"] = {
            procType = "synergy",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Conduit synergy from the Sorcerer Lightning Splash ability is able to be used or when it will become available.",
            id = 108607,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 20000,
            texture = "/esoui/art/icons/ability_sorcerer_liquid_lightning.dds",
            showFrame = true,
        },
        ["Purify"] = {
            procType = "synergy",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Purify synergy from the Templar Cleansing Ritual ability is able to be used or when it will become available.",
            id = 108824,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 20000,
            texture = "/esoui/art/icons/ability_templar_extended_ritual.dds",
            showFrame = true,
        },
        ["Boner Shield"] = {
            procType = "synergy",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Undaunted Bone Wall/Bone Shield synergy is able to be used or when it will become available.",
            id = {108794, 108797},
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 20000,
            texture = "/esoui/art/icons/ability_undaunted_005.dds",
            showFrame = true,
        },
        ["Blood Altar"] = {
            procType = "synergy",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Undaunted Blood Altar/Overflowing Altar synergy is able to be used or when it will become available.",
            id = {108782, 108787},
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 20000,
            texture = "/esoui/art/icons/ability_undaunted_001_b.dds",
            showFrame = true,
        },
        ["Harvest"] = {
            procType = "synergy",
            -- Thanks to Liofa for patching and testing for this synergy
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Warden Healing Seed synergy is able to be used or when it will become available.",
            id = 108826,
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 20000,
            texture = "/esoui/art/icons/ability_warden_007.dds",
            showFrame = true,
        },
        ["Grave Robber"] = {
            procType = "synergy",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Grave Robber synergy from the Necromancer Avid Boneyard ability is able to be used or when it will become available.",
            id = {115567, 115571},
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 20000,
            texture = "/esoui/art/icons/ability_necromancer_004_b.dds",
            showFrame = true,
        },
        ["Pure Agony"] = {
            procType = "synergy",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Pure Agony synergy from the Necromancer Agony Totem ability is able to be used or when it will become available.",
            id = {118610, 118606},
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 20000,
            texture = "/esoui/art/icons/ability_necromancer_010_b.dds",
            showFrame = true,
        },
        ["Black Widows"] = {
            procType = "synergy",
            event = EVENT_COMBAT_EVENT,
            description = "Displays when the Black Widows synergy from the Undaunted Trapping Webs ability is able to be used or when it will become available.",
            id = {108766, 108791, 108792},
            result = ACTION_RESULT_EFFECT_GAINED,
            cooldownDurationMs = 20000,
            texture = "/esoui/art/icons/ability_undaunted_003_b.dds",
            showFrame = true,
        },

        -- Passives ---------------------------------------------------------------
        -- UnitClassId
        -- 1: Dragonknight
        -- 2: Sorcerer
        -- 3: Nightblade
        -- 4: Warden
        -- 5: Necromancer
        -- 6: Templar

        ["Corpse Consumption"] = {
            procType = "passive",
            classId = 5,
            event = EVENT_COMBAT_EVENT,
            description = "Displays the cooldown for gaining ultimate when using an ability on a corpse.",
            id = 120612,
            result = ACTION_RESULT_POWER_ENERGIZE,
            cooldownDurationMs = 16000,
            texture = "/esoui/art/icons/passive_necromancer_011.dds",
            showFrame = true,
        },
        ["Prism"] = {
            procType = "passive",
            classId = 6,
            event = EVENT_COMBAT_EVENT,
            description = "Displays the cooldown for gaining ultimate when using a Dawn's Wrath ability.",
            id = 45217,
            result = ACTION_RESULT_POWER_ENERGIZE,
            cooldownDurationMs = 6000,
            texture = "/esoui/art/icons/passive_templar_030.dds",
            showFrame = true,
        },
        ["Mountain's Blessing"] = {
            procType = "passive",
            classId = 1,
            event = EVENT_COMBAT_EVENT,
            description = "Displays the cooldown for gaining ultimate by using an Eathern Heart ability while in combat. Does not reflect the Minor Brutality portion of this passive.",
            id = 45005,
            result = ACTION_RESULT_POWER_ENERGIZE,
            cooldownDurationMs = 6000,
            texture = "/esoui/art/icons/passive_dragonknight_020.dds",
            showFrame = true,
        },
        ["Transfer"] = {
            procType = "passive",
            classId = 3,
            event = EVENT_COMBAT_EVENT,
            description = "Displays the cooldown for gaining ultimate upon activating a Siphoning ability.",
            id = 45146,
            result = ACTION_RESULT_POWER_ENERGIZE,
            cooldownDurationMs = 4000,
            texture = "/esoui/art/icons/passive_sorcerer_002.dds",
            showFrame = true,
        },
        ["Savage Beast"] = {
            procType = "passive",
            classId = 4,
            event = EVENT_COMBAT_EVENT,
            description = "Displays the cooldown for gaining ultimate upon activating an Animal Companion ability.",
            id = 88513,
            result = ACTION_RESULT_POWER_ENERGIZE,
            cooldownDurationMs = 8000,
            texture = "/esoui/art/icons/passive_warden_009.dds",
            showFrame = true,
        },
        ["Combustion"] = {
            procType = "passive",
            classId = 1,
            event = EVENT_COMBAT_EVENT,
            description = "Displays the cooldown for restoring magicka or stamina by applying burning or poisoned to an enemy.",
            -- Combustion on 108815 through 108818
            -- Stamina, Magicka
            id = {108815, 108816},
            result = ACTION_RESULT_POWER_ENERGIZE,
            cooldownDurationMs = 5000,
            texture = "/esoui/art/icons/ability_sorcerer_011.dds",
            showFrame = true,
        },
    }

end


-- These two tables work together
-- to map item slot constants to
-- human-readable names.
-- Why two tables? Good question.
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

