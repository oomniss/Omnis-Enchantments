-- by omnis._.

global.runeDebounceStart    = 0;
global.runeID               = 0;
global.runeStates           = {};

local l                     = context.mainHand and 1 or -1
local hand                  = context.hand
local particles             = context.particles
local deltaTime             = context.deltaTime
local itemName              = I:getName(context.item):gsub("minecraft:", "")
local time                  = P:getAge(context.player)
local isEnchanted           = I:isEnchanted(context.item)
local glowIntensity         = ${glowIntensity}
local runesIntensity        = ${runesIntensity}

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

-- === GET ITEM TYPE ===
local function getType()
    local typeMap = {
        { types = {"pickaxes", "axes", "hoes", "shovels", "spears", "horse_armor", "nautilus_armor", "swords"} },
        { types = {"enchanted_book", "written_book"}, output = "books" },
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
    books                    = { glow = ${glowBooks},            rune = ${runeBooks} },
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

local function enableParticle(items, particle)
    local list = type(items) == "table" and items or {items}
    for _, i in ipairs(list) do
        if matched(i, true) then
            local config = itemConfig[getType()] or {}
            return config[particle] == true
        end
    end
    return false
end

-- === PARTICLE TICKER ===
local function particleTicker(particle, particleID)
    if not I:isEnchanted(context.item) then
        particle.dead = true
        if runeStates[particleID] then
            runeStates[particleID] = nil
        end
        return
    end

    local state = runeStates[particleID]

    if not state then
        state = {
            age       = 0,
            phaseX    = math.random() * 6.283,
            phaseY    = math.random() * 6.283,
            phaseZ    = math.random() * 6.283,
            speedX    = 0.025 + math.random() * 0.035,
            speedY    = 0.015 + math.random() * 0.025,
            speedZ    = 0.025 + math.random() * 0.035,
            amplitude = (math.random() * 0.0025),
            riseSpeed = 0.0008 + math.random() * 0.0015,
            expirationDate = time + 250,
        }
        runeStates[particleID] = state
    end

    state.age = state.age + deltaTime * 30

    state.phaseX = state.phaseX + state.speedX * deltaTime * 30
    state.phaseY = state.phaseY + state.speedY * deltaTime * 30
    state.phaseZ = state.phaseZ + state.speedZ * deltaTime * 30

    particle.dx = math.sin(state.phaseX) * state.amplitude
    particle.dy = state.riseSpeed + math.cos(state.phaseY) * state.amplitude * 0.5
    particle.dz = math.sin(state.phaseZ) * state.amplitude
end

for id, state in pairs(runeStates) do
    if time >= state.expirationDate then
        runeStates[id] = nil
    end
end

-- === TEXTURE ===
local textureMap = {
    general             = Texture:of("minecraft", "textures/particle/circle_purple_glow.png"),
    swords              = Texture:of("minecraft", "textures/particle/oval_purple_glow.png"),
    spears              = Texture:of("minecraft", "textures/particle/oval_purple_glow.png"),
    rods                = Texture:of("minecraft", "textures/particle/oval_purple_glow.png"),
    spyglass            = Texture:of("minecraft", "textures/particle/oval_purple_glow.png"),
    totem_of_undying    = Texture:of("minecraft", "textures/particle/gold_glow.png"),
}
local texture = textureMap[getType()] or textureMap.general

-- === PARTICLES ===
local sprites2D = {"written_book", "enchanted_book", "enchanted_golden_apple", "head_armor", "chest_armor", "leg_armor", "foot_armor",
    "nautilus_armor", "shears", "compasses", "clock", "nether_star", "flint_and_steel", "experience_bottle"}
local is2D = matched(sprites2D, true)

local particlePosition = {
    pickaxes    = { move = {x = -0.03,  y = 0.42,  z = 0.15} },
    axes        = { move = {x = -0.05,  y = 0.4,   z = 0.11} },
    hoes        = { move = {x = -0.05,  y = 0.4,   z = 0.11} },
    shovels     = { move = {x = 0.02,   y = 0.4,   z = 0.05}, scale = 4 },
    horse_armor = { move = {x = 0.01,   y = 0.05,  z = 0.05} },
    wolf_armor  = { move = {x = 0.03,   y = 0.2,   z = 0.05} },
    mace        = { move = {x = 0.05,   y = 0.4,   z = 0.05}, scale = 5 },
    bow         = { move = {x = 0.02,   y = -0.13, z = 0.05}, scale = 4.5 },
    crossbow    = { move = {x = -0.1,   y = 0.05 , z = 0} },
    rods        = { move = {x = 0.1,    y = 0.25,  z = 0.05}, rotate = {x = 30, y = 0, z = 0},   scale = 3.7 },
    swords      = { move = {x = 0,      y = 0.4,   z = 0.05}, rotate = {x = 5,  y = 0, z = -10}, scale = 3.2 },
    spears      = { move = {x = 0.1,    y = 0.8,   z = 0.1},  rotate = {x = 30, y = 0, z = 20},  scale = 4.7 },
    spyglass    = { move = {x = -0.02,  y = -0.1,  z = 0.05}, rotate = {x = 10, y = 0, z = -10} },
    is2D        = { move = {x = -0.06,  y = 0.2,   z = 0.15}, scale = 3.5}
}

local posEntry    = (is2D and particlePosition["is2D"]) or particlePosition[getType()] or {}
local move        = posEntry.move   or {x = 0, y = 0, z = 0}
local rotate      = posEntry.rotate or {x = 0, y = 0, z = 0}
local scale       = posEntry.scale  or 3

if isEnchanted then
    if glowingEffect and enableParticle(itemName, "glow") then
        particleManager:addParticle(
            particles,
            false,
            move.x * l, move.y, move.z,
            0, 0, 0,
            rotate.x, rotate.y * l, rotate.z * l,
            0, 0, 0, scale,
            texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, glowIntensity
        )
    end

    if runes and enableParticle(itemName, "rune") then
        runeActive = true
        local SPAWN_INTERVAL = 12 - (runesIntensity - 1)

        local aliveCount = 0
        for id, state in pairs(runeStates) do
            if state then aliveCount = aliveCount + 1 end
        end
        if runeDebounceStart > time then
            runeDebounceStart = time
        end

        if (time - runeDebounceStart >= SPAWN_INTERVAL) and aliveCount < 50 then
            runeDebounceStart = time
            runeID = runeID + 1

            local letter = string.char(96 + math.random(1, 26))
            local sgaTex = Texture:of("minecraft", "textures/particle/sga_" .. letter .. ".png")

            -- Delimitadores de spawn para cada eixo (relativo ao centro do item)
            local spreadX = {min = -0.25, max = 0.2}
            local spreadY = {min = -0.2, max = 0.12}
            local spreadZ = {min = -0.2, max = 0.15}

            -- Gera posição aleatória dentro dos limites de cada eixo
            local randomX = math.random() * (spreadX.max - spreadX.min) + spreadX.min
            local randomY = math.random() * (spreadY.max - spreadY.min) + spreadY.min
            local randomZ = math.random() * (spreadZ.max - spreadZ.min) + spreadZ.min

            local spawnX = (move.x + randomX) * l
            local spawnY = move.y + randomY
            local spawnZ = move.z + randomZ

            particleManager:addParticle(
                particles, false,
                spawnX, spawnY, spawnZ,
                0, 0, 0, 0, 0, 0, 0, 0, math.random(-8,8),
                0.05 + math.random() * 0.12,
                sgaTex, "ITEM", hand, "OPACITY", "CUTOUT_L",
                12, 160 + math.random(0, 60),
                function(p) particleTicker(p, runeID) end
            )
        end
    end
else
    for id in pairs(runeStates) do
        runeStates[id] = nil
    end
end

if enableParticle("totem_of_undying", "glow") then
    particleManager:addParticle(
        particles,
        false,
        0.03 * l, 0.2, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2.5,
        texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
    )
end