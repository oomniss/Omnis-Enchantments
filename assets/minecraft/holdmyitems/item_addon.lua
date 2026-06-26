-- by omnis._.

global.runeDebounceStart    = 0;
global.runeID               = 0;
global.runeStates           = {};

local HMIversion = context == nil and "5.0" or "5.1+"

mainHand    = HMIversion == "5.1+" and context.mainHand or mainHand
hand        = HMIversion == "5.1+" and context.hand or hand
particles   = HMIversion == "5.1+" and context.particles or particles
player      = HMIversion == "5.1+" and context.player or player
item        = HMIversion == "5.1+" and context.item or item
deltaTime   = HMIversion == "5.1+" and context.deltaTime or deltaTime

local l               = mainHand and 1 or -1
local itemName        = I:getName(item):gsub("minecraft:", "")
local time            = P:getAge(player)
local isEnchanted     = I:isEnchanted(item)
local isUsingItem     = P:isUsingItem(player)
local glowIntensity   = ${glowIntensity}
local runesIntensity  = ${runesIntensity}

local maceFusion      = ${compatMacefusion}

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
        return I:isIn(item, Tags:getFabricTag(i))
            or I:isIn(item, Tags:getVanillaTag(i))
    end
    for _, i in ipairs(list) do
        if check(i) then return true end
    end
    return false
end

-- === GET ITEM TYPE ===
local function getType()
    local typeMap = {
        { items = {"pickaxes", "axes", "hoes", "shovels", "spears", "horse_armor", "nautilus_armor", "swords"} },
        { items = {"enchanted_book", "written_book"}, type = "books" },
        { items = {"head_armor", "chest_armor", "leg_armor", "foot_armor", "elytra"}, type = "armors" },
        { items = {"fishing_rod", "on_a_stick"}, type = "rods" },
    }
    for _, list in ipairs(typeMap) do
        for _, tag in ipairs(list.items) do
            if matched(tag, true) then
                return list.type or tag
            end
        end
    end
    return itemName
end
local itemType = getType()

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
    trident                  = { glow = ${glowTrident},          rune = ${runeTrident} },
    end_crystal              = { rune = ${runeEndCrystal} }
}

local function enableParticle(item, particle, condition)
    if matched(item, true) and condition then
        local config = itemConfig[itemType] or {}
        return config[particle] == true
    end
    return false
end

-- === PARTICLE TICKER ===
local function particleTicker(particle, particleID)
    if not I:isEnchanted(item) then
        particle.dead = true
        if runeStates[particleID] then
            runeStates[particleID] = nil
        end
        return
    end

    local state = runeStates[particleID]

    if not state then
        state = {
            age               = 0,
            phaseX            = math.random() * 6.283,
            phaseY            = math.random() * 6.283,
            phaseZ            = math.random() * 6.283,
            speedX            = 0.025 + math.random() * 0.035,
            speedY            = 0.015 + math.random() * 0.025,
            speedZ            = 0.025 + math.random() * 0.035,
            amplitude         = (math.random() * 0.0025),
            riseSpeed         = 0.0008 + math.random() * 0.0015,
            expirationDate    = time + 250,
        }
        runeStates[particleID] = state
    end

    local dt = deltaTime or 0
    state.age = state.age + dt * 30

    state.phaseX = state.phaseX + state.speedX * dt * 30
    state.phaseY = state.phaseY + state.speedY * dt * 30
    state.phaseZ = state.phaseZ + state.speedZ * dt * 30

    particle.dx = math.sin(state.phaseX) * state.amplitude
    particle.dy = state.riseSpeed + math.cos(state.phaseY) * state.amplitude * 0.5
    particle.dz = math.sin(state.phaseZ) * state.amplitude
end

for id, state in pairs(runeStates) do
    if time >= state.expirationDate then
        runeStates[id] = nil
    end
end

if runeID > 999999 then
    runeID = 0
    runeStates = {}
end

-- === TEXTURE ===
local textureMap = {
    general   = "circle_purple_glow",
    swords    = "oval_purple_glow",
    spears    = "oval_purple_glow",
    rods      = "oval_purple_glow",
    spyglass  = "oval_purple_glow",
    trident   = "oval_purple_glow"
}
local textureName = textureMap[getType()] or textureMap.general
local texture = Texture:of("minecraft", "textures/particle/" .. textureName .. ".png")

-- === PARTICLES ===
local sprites2D = {"written_book", "enchanted_book", "enchanted_golden_apple", "head_armor", "chest_armor", "leg_armor", "foot_armor",
    "nautilus_armor", "shears", "compasses", "clock", "nether_star", "flint_and_steel", "experience_bottle"}
local is2D = matched(sprites2D, true)

local particlePosition = {
    pickaxes          = { move = {x = -0.03,  y = 0.42,  z = 0.15} },
    axes              = { move = {x = -0.05,  y = 0.4,   z = 0.11} },
    hoes              = { move = {x = -0.05,  y = 0.4,   z = 0.11} },
    shovels           = { move = {x = 0.02,   y = 0.4,   z = 0.05}, scale = 4 },
    horse_armor       = { move = {x = 0.01,   y = 0.05,  z = 0.05} },
    wolf_armor        = { move = {x = 0.03,   y = 0.2,   z = 0.05} },
    mace              = { move = {x = 0.05,   y = 0.4,   z = 0.05}, scale = 5 },
    bow               = { move = {x = 0.02,   y = -0.13, z = 0.05}, scale = 4.5 },
    crossbow          = { move = {x = -0.1,   y = 0.05 , z = 0} },
    rods              = { move = {x = 0.05,   y = 0.25,  z = 0.05}, rotate = {x = 25, y = 0, z = 0},   scale = 3.7 },
    swords            = { move = {x = 0.02,   y = 0.4,   z = 0.05}, scale = 3.2 },
    spears            = { move = {x = 0.2,    y = 0.5,   z = 0.1},  rotate = {x = 30, y = 0, z = 20},  scale = 5.5, lumen = 120 },
    spyglass          = { move = {x = -0.02,  y = -0.1,  z = 0.05}, rotate = {x = 10, y = 0, z = -10} },
    is2D              = { move = {x = -0.06,  y = 0.2,   z = 0.15}, scale = 3.5},
    shield            = { move = {x = 0.05,   y = 0.4,   z = 0.05}, rotate = {x = 20,  y = 0, z = 10} },
    trident           = { move = {x = 0.08,   y = isUsingItem and -0.5 or 0.4, z = 0.05}, rotate = {x = 20,  y = 0, z = isUsingItem and 90 or 10} }
}

local posEntry        = (is2D and particlePosition["is2D"]) or particlePosition[itemType] or {}
local move            = posEntry.move   or {x = 0, y = 0, z = 0}
local rotate          = posEntry.rotate or {x = 0, y = 0, z = 0}
local scale           = posEntry.scale  or 3

local defaultLumen    = 130
local prop            = (posEntry.lumen or defaultLumen) / defaultLumen
glowIntensity         = glowIntensity * prop

local apply           = itemName ~= "brush" and itemName ~= "shield" and (HMIversion ~= "5.1+" or itemName ~= "trident")

if isEnchanted then
    if glowingEffect and enableParticle(itemName, "glow", apply) then
        particleManager:addParticle(
            particles,
            true,
            move.x * l, move.y, move.z,
            0, 0, 0,
            rotate.x, rotate.y * l, rotate.z * l,
            0, 0, 0, scale,
            texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, glowIntensity
        )
    end

    if runes and enableParticle(itemName, "rune", apply) then
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

            local letter        = string.char(96 + math.random(1, 26))
            local sgaTex        = Texture:of("minecraft", "textures/particle/sga_" .. letter .. ".png")

            local spreads = {
                circle = {
                    x = {min = -0.25, max = 0.2},
                    y = {min = -0.2,  max = 0.2},
                    z = {min = -0.2,  max = 0.1}
                },
                oval = {
                    x = {min = -0.2,  max = 0.15},
                    y = {min = -0.4,  max = 0.4},
                    z = {min = -0.2,  max = 0.1}
                }
            }
            local textureType   = textureName:match("oval") or textureName:match("circle")
            local spreadX       = spreads[textureType].x
            local spreadY       = spreads[textureType].y
            local spreadZ       = spreads[textureType].z

            local compatibility = {
                {
                    maceFusion,
                    items = {"mace"},
                    x = {min = -0.3,  max = 0.25},
                    y = {min = -0.4,   max = 0.4},
                    z = {min = -0.25,  max = 0.15}
                }
            }
            local target = false
            for _, entry in ipairs(compatibility) do
                if entry[1] then
                    for _, item in ipairs(entry.items) do
                        if item == itemType then
                            spreadX = entry.x
                            spreadY = entry.y
                            spreadZ = entry.z

                            target = true
                            break
                        end
                    end
                    if target then break end
                end
            end

            local randomX       = math.random() * (spreadX.max - spreadX.min) + spreadX.min
            local randomY       = math.random() * (spreadY.max - spreadY.min) + spreadY.min
            local randomZ       = math.random() * (spreadZ.max - spreadZ.min) + spreadZ.min
            local spawnX        = (move.x + randomX) * l
            local spawnY        = move.y + randomY
            local spawnZ        = move.z + randomZ

            particleManager:addParticle(
                particles, false,
                spawnX, spawnY, spawnZ,
                0, 0, 0, 0, 0, 0, 0, 0, 0,
                0.05 + math.random() * 0.12,
                sgaTex, "ITEM", hand, "OPACITY", "CUTOUT_L",
                5, 160 + math.random(0, 60),
                function(p) particleTicker(p, runeID) end
            )
        end
    end
else
    for id in pairs(runeStates) do
        runeStates[id] = nil
    end
end