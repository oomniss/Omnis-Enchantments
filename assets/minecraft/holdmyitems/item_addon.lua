-- by omnis._.

global.runeActive           = global.runeActive or false
global.lastRuneSpawnTime    = global.lastRuneSpawnTime or 0
global.RuneStates           = global.RuneStates or {}
global.activeRunes          = global.activeRunes or 0

local l                     = context.mainHand and 1 or -1
local hand                  = context.hand
local particles             = context.particles
local itemName              = I:getName(context.item):gsub("minecraft:", "")
local isEnchanted           = I:isEnchanted(context.item)
local isUsingItem           = P:isUsingItem(context.player)
local deltaTime             = context.deltaTime
local time                  = P:getAge(context.player)

-- === MATCH ===
local function matched(items, matches)
    local list = type(items) == "table" and items or {items}
    local function check(i)
        if itemName == i then
            return true
        end
        if matches and itemName:match(i) then
            return true
        end
        return I:isIn(context.item, Tags:getFabricTag(i))
            or I:isIn(context.item, Tags:getVanillaTag(i))
    end
    for _, i in ipairs(list) do
        if check(i) then return true end
    end
    return false
end

-- === PARTICLE TICKER ===
local function particleTickerEnchant(particle, particleID, amp)
    local state = global.RuneStates[particleID]

    if not global.runeActive then
        particle.dead = true
        if global.RuneStates[particleID] then
            global.RuneStates[particleID] = nil
            global.activeRunes = math.max(0, global.activeRunes - 1)
        end
        return
    end

    if not state then
        state = {
            age       = 0,
            phaseX    = math.random() * 6.283,
            phaseY    = math.random() * 6.283,
            phaseZ    = math.random() * 6.283,
            speedX    = 0.025 + math.random() * 0.035,
            speedY    = 0.015 + math.random() * 0.025,
            speedZ    = 0.025 + math.random() * 0.035,
            amplitude = (math.random() * 0.0025) + amp,
            riseSpeed = 0.0008 + math.random() * 0.0015,
        }
        global.RuneStates[particleID] = state
    end

    state.age = state.age + deltaTime * 30

    state.phaseX = state.phaseX + state.speedX * deltaTime * 30
    state.phaseY = state.phaseY + state.speedY * deltaTime * 30
    state.phaseZ = state.phaseZ + state.speedZ * deltaTime * 30

    particle.dx = math.sin(state.phaseX) * state.amplitude
    particle.dy = state.riseSpeed + math.cos(state.phaseY) * state.amplitude * 0.5
    particle.dz = math.sin(state.phaseZ) * state.amplitude
end

for id, state in pairs(global.RuneStates) do
    if not state or not global.runeActive then
        global.RuneStates[id] = nil
        global.activeRunes = math.max(0, global.activeRunes - 1)
    end
end

-- === SETTINGS ===
local glowingEffect   = ${glow}
local runes           = ${runes}

local itemConfig = {
    pickaxes                 = { glow = ${glowPickaxes},         rune = ${runePickaxes} },
    axes                     = { glow = ${glowAxes},             rune = ${runeAxes} },
    hoes                     = { glow = ${glowHoes},             rune = ${runeHoes} },
    shovels                  = { glow = ${glowShovels},          rune = ${runeShovels} },
    swords                   = { glow = ${glowSwords},           rune = ${runeSwords} },
    spears                   = { glow = ${glowSpears},           rune = ${runeSpears} },
    written_book             = { glow = ${glowBooks},            rune = ${runeBooks} },
    enchanted_book           = { glow = ${glowBooks},            rune = ${runeBooks} },
    rods                     = { glow = ${glowRods},             rune = ${runeRods} },
    shears                   = { glow = ${glowShears},           rune = ${runeShears} },
    enchanted_golden_apple   = { glow = ${glowEnchantApple},     rune = ${runeEnchantApple} },
    armors                   = { glow = ${glowArmors},           rune = ${runeArmors} },
    nautilus_armor           = { glow = ${glowNautilusArmors},   rune = ${runeNautilusArmors} },
    horse_armor              = { glow = ${glowHorseArmors},      rune = ${runeHorseArmors} },
    wolf_armor               = { glow = ${glowWolfArmor},        rune = ${runeWolfArmor} },
    mace                     = { glow = ${glowMace},             rune = ${runeMace} },
    bow                      = { glow = ${glowBow},              rune = ${runeBow} },
    crossbow                 = { glow = ${glowCrossbow},         rune = ${runeCrossbow} },
    flint_and_steel          = { glow = ${glowFlintSteel},       rune = ${runeFlintSteel} },
    spyglass                 = { glow = ${glowSpyglass},         rune = ${runeSpyglass} },
    compasses                = { glow = ${glowCompasses},        rune = ${runeCompasses} },
    clock                    = { glow = ${glowClock},            rune = ${runeClock} },
    nether_star              = { glow = ${glowNetherStar},       rune = ${runeNetherStar} },
    experience_bottle        = { glow = ${glowExpBottle},        rune = ${runeExpBottle} },
    totem_of_undying         = { glow = ${glowTotem} },
    end_crystal              = { rune = ${runeEndCrystal} }
}

local function getType()
    local typeMap = {
        { types = {"pickaxes", "axes", "hoes", "shovels", "spears", "horse_armor", "nautilus_armor"} },
        { types = {"head_armor", "chest_armor", "leg_armor", "foot_armor", "elytra"}, output = "armors" },
        { types = {"fishing_rod", "on_a_stick"}, output = "rods" },
    }
    for _, list in ipairs(typeMap) do
        for _, tag in ipairs(list.types) do
            if matched(tag, true) then
                return list.output or tag
            end
        end
    end
    return itemName
end

local function enableParticle(items, particle)
    local list = type(items) == "table" and items or {items}
    for _, item in ipairs(list) do
        if matched(item, true) then
            local config = itemConfig[getType()] or {}
            return config[particle] == true
        end
    end
    return false
end

-- === TEXTURE ===
local function getTexture()
    local textureMap = {
        { items = {"swords", "spears"}, texture = "sword_glow.png" },
        { items = {"totem_of_undying"}, texture = "gold_glow.png" }
    }
    for _, entry in ipairs(textureMap) do
        for _, item in ipairs(entry.items) do
            if matched(item) then
                return entry.texture
            end
        end
    end
    return "purple_glow.png"
end
local texture = Texture:of("minecraft", "textures/particle/" .. getTexture())

-- === PARTICLES ===
local sprites2D = {"written_book", "enchanted_book", "enchanted_golden_apple", "head_armor", "chest_armor", "leg_armor", "foot_armor",
    "nautilus_armor", "shears", "compasses", "clock", "nether_star", "flint_and_steel", "experience_bottle"}
local is2D = matched(sprites2D, true)

local glowPositions = {
    pickaxes    = {x = 0.65,  y = 0.45, z = 0.1},
    axes        = {x = 0.05,  y = 0.35, z = 0.05},
    hoes        = {x = 0.05,  y = 0.35, z = 0.05},
    shovels     = {x = -0.05, y = 0.5,  z = 0.05},
    swords      = {x = 0.25,  y = 0.5,  z = 0.05, scale = 4},
    spears      = {x = 0.1,   y = 1.1,  z = 0.15, scale = isUsingItem and 4 or 6},
    horse_armor = {x = 0.04,  y = 0.07, z = 0.05},
    wolf_armor  = {x = -0.01, y = 0.25, z = 0.05},
    mace        = {x = 0.1,   y = 0.5,  z = 0.05, scale = 3.5},
    rods        = {x = 0.1,   y = 0.4,  z = 0.05},
    bow         = {x = 0.08,  y = 0,    z = 0.05, scale = 3},
    crossbow    = {x = -0.02, y = 0.05, z = 0.03, scale = 3},
    spyglass    = {x = 0.02,  y = 0,    z = 0.05},
    is2D        = {x = 0.04,  y = 0.2,  z = 0.05},
}
local pos = (is2D and glowPositions["is2D"]) or glowPositions[getType()]

if isEnchanted then
    global.runeActive = true

    if glowingEffect and enableParticle(itemName, "glow") then
        particleManager:addParticle(
            particles,
            false,
            pos.x * l, pos.y, pos.z,
            0, 0, 0, 0, 0, 0, 0, 0, 0, pos.scale or 2.5,
            texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
        )
    end
    if itemName == "trident" then
        --particleManager:addParticle(
            --particles,
            --false,
            --0.7 * l, 0.08, -0.74, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2,
            --texture, "SCREEN", hand, "SPAWN", "ADDITIVE", 0, 255
        --)
        particleManager:addParticle(
            particles,
            false,
            -1.56 * l, -0.12, 1.18, 0, 0, 0, 0, 0, 0, 0, 0, 0, -2.5,
            texture, "ITEM", hand, "SPAWN", "CUTOUT_L", 0, 255
        )
    end

    if runes and enableParticle(itemName, "rune") then
        local SPAWN_INTERVAL = 8

        if time - (global.lastRuneSpawnTime or 0) >= SPAWN_INTERVAL then
            local letter = string.char(96 + math.random(1, 26))
            local sgaTex = Texture:of("minecraft", "textures/particle/sga_" .. letter .. ".png")

            local runesAdjust = {
                { items = {"bow", "spyglass"},            pos = {x = -0.05, y = -0.3,  z = 0,   amp = 0} },
                { items = {"crossbow"},                   pos = {x = -0.1,  y = -0.4,  z = 0,   amp = 0} },
                { items = {"wolf_armor", "horse_armor"},  pos = {x = 0.05,  y = -0.25, z = 0,   amp = 0} },
                { items = {"spears"},                     pos = {x = 0.05,  y = 0.3,   z = 0.1, amp = 0} },
                { items = {"mace"},                       pos = {x = 0,     y = 0,     z = 0,   amp = 0.05} },
                { items = {"fishing_rod", "_on_a_stick"}, pos = {x = 0,     y = -0.1,  z = 0,   amp = 0} },
                { items = {"end_crystal"},                pos = {x = -0.05, y = -0.15, z = 0,   amp = 0} },
                { items = sprites2D,                      pos = {x = 0,     y = -0.3,  z = 0,   amp = 0.005} }
            }
            local function getRuneAdjust()
                for _, adjust in ipairs(runesAdjust) do
                    for _, item in ipairs(adjust.items) do
                        if matched(item, true) then
                            return adjust.pos
                        end
                    end
                end
                return {x = 0, y = 0, z = 0, amp = 0}
            end
            local runesPos = getRuneAdjust()

            local spawnX = ((math.random() * 0.5 - 0.3) + runesPos.x) * l
            local spawnY = (math.random() * 0.7 + 0.05) + runesPos.y
            local spawnZ = (math.random() * 0.3 - 0.1)  + runesPos.z

            local particleID = "ench_" .. time .. "_" .. math.random(1000, 9999)

            particleManager:addParticle(
                particles, false,
                spawnX, spawnY, spawnZ,
                0, 0, 0, 0, 0, 0, 0, 0, math.random(-8,8),
                0.05 + math.random() * 0.12,
                sgaTex, "ITEM", hand, "OPACITY", "ADDITIVE",
                12, 160 + math.random(0, 60),
                function(p) particleTickerEnchant(p, particleID, runesPos.amp) end
            )

            global.lastRuneSpawnTime = time
            global.activeRunes = global.activeRunes + 1
        end
    end
else
    global.runeActive = false
end

if enableParticle("totem_of_undying", "glow") then
    particleManager:addParticle(
        particles,
        false,
        0.03 * l, 0.2, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2.5,
        texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
    )
end