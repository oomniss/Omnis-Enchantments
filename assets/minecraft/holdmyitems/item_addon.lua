-- by omnis._.

global.enchantActive          = global.enchantActive or false
global.lastEnchantSpawnTime   = global.lastEnchantSpawnTime or 0
global.enchantParticleStates  = global.enchantParticleStates or {}
global.activeEnchantParticles = global.activeEnchantParticles or 0

local l                       = context.mainHand and 1 or -1
local hand                    = context.hand
local particles               = context.particles
local itemName                = I:getName(context.item):gsub("minecraft:", "")
local isEnchanted             = I:isEnchanted(context.item)
local isUsingItem             = P:isUsingItem(context.player)
local deltaTime               = context.deltaTime
local time                    = P:getAge(context.player)

-- === FUNCTIONS ===
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

local function particleTickerEnchant(particle, particleID, amp)
    local state = global.enchantParticleStates[particleID]

    if not global.enchantActive then
        particle.dead = true
        if global.enchantParticleStates[particleID] then
            global.enchantParticleStates[particleID] = nil
            global.activeEnchantParticles = math.max(0, global.activeEnchantParticles - 1)
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
        global.enchantParticleStates[particleID] = state
    end

    state.age = state.age + deltaTime * 30

    state.phaseX = state.phaseX + state.speedX * deltaTime * 30
    state.phaseY = state.phaseY + state.speedY * deltaTime * 30
    state.phaseZ = state.phaseZ + state.speedZ * deltaTime * 30

    particle.dx = math.sin(state.phaseX) * state.amplitude
    particle.dy = state.riseSpeed + math.cos(state.phaseY) * state.amplitude * 0.5
    particle.dz = math.sin(state.phaseZ) * state.amplitude
end

for id, state in pairs(global.enchantParticleStates) do
    if not state or not global.enchantActive then
        global.enchantParticleStates[id] = nil
        global.activeEnchantParticles = math.max(0, global.activeEnchantParticles - 1)
    end
end

-- === ITEMS ===
local glow                      = ${glow}
local enchantParticles          = ${enchantPart} and not matched({"trident", "brush", "shield"})

local isPickaxe                 = matched("pickaxes") and ${glowPickaxes}
local isAxe                     = matched("axes") and ${glowAxes}
local isHoe                     = matched("hoes") and ${glowHoes}
local isShovel                  = matched("shovels") and ${glowShovels}
local isSword                   = matched("swords") and ${glowSwords}
local isSpear                   = matched("spears") and ${glowSpears}
local isBook                    = matched({"enchanted_book", "written_book"}) and ${glowBooks}
local isRod                     = matched({"fishing_rod", "carrot_on_a_stick", "warped_fungus_on_a_stick"}) and ${glowRods}
local isShears                  = matched("shears") and ${glowShears}
local isEnchantedGoldenApple    = matched("enchanted_golden_apple") and ${glowEnchantApple}
local isArmor                   = matched({"head_armor", "chest_armor", "leg_armor", "foot_armor", "elytra"}) and ${glowArmors}
local isNautilusArmor           = matched("nautilus_armor", true) and ${glowNautilusArmors}
local isHorseArmor              = matched("horse_armor", true) and ${glowHorseArmors}
local isWolfArmor               = matched("wolf_armor") and ${glowWolfArmor}
local isMace                    = matched("mace") and ${glowMace}
local isBow                     = matched("bow") and ${glowBow}
local isCrossbow                = matched("crossbow") and ${glowCrossbow}
local isFlintSteel              = matched("flint_and_steel") and ${glowFlintSteel}
local isSpyglass                = matched("spyglass") and ${glowSpyglass}
local isCompass                 = matched({"compasses"}) and ${glowCompasses}
local isClock                   = matched({"clock"}) and ${glowClock}
local isNetherStar              = matched("nether_star") and ${glowNetherStar}
local isExperienceBottle        = matched("experience_bottle") and ${glowExpBottle}
local isTotem                   = matched("totem_of_undying") and ${glowTotem}

local isShield                  = matched("shield")
local isBrush                   = matched("brush")
local isTrident                 = matched("trident")
local isEndCrystal              = matched("end_crystal")

local is2D =
    isBook
    or isEnchantedGoldenApple
    or isArmor
    or isNautilusArmor
    or isShears
    or isCompass
    or isClock
    or isFlintSteel
    or isNetherStar
    or isExperienceBottle

-- === TEXTURE ===
local function getTexture()
    local textureMap = {
        {isSword or isSpear,    "sword"},
        {isTotem,               "gold"}
    }
    for _, entry in ipairs(textureMap) do
        if entry[1] and not isUsingItem then
            return entry[2] .. "_glow.png"
        end
    end
    return "purple_glow.png"
end
local texture = Texture:of("minecraft", "textures/particle/" .. getTexture())

-- === PARTICLES ===
if isEnchanted then
    global.enchantActive = true

    if glow then
        if isPickaxe then
            particleManager:addParticle(
                particles,
                false,
                0.065 * l, 0.45, 0.1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2.5,
                texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
            )
        elseif isAxe or isHoe then
            particleManager:addParticle(
                particles,
                false,
                0.05 * l, 0.35, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2.5,
                texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
            )
        elseif isShovel then
            particleManager:addParticle(
                particles,
                false,
                -0.05 * l, 0.5, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2.5,
                texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
            )
        elseif isSword then
            particleManager:addParticle(
                particles,
                false,
                0.025 * l, 0.5, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4,
                texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
            )
        elseif isSpear then
            particleManager:addParticle(
                particles,
                false,
                0.1 * l, 1.1, 0.15, 0, 0, 0, 0, 0, 0, 0, 0, 0, isUsingItem and 4 or 6,
                texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
            )
        elseif is2D then
            particleManager:addParticle(
                particles,
                false,
                0.04 * l, 0.2, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2.5,
                texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
            )
        elseif isHorseArmor then
            particleManager:addParticle(
                particles,
                false,
                0.04 * l, 0.07, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2.5,
                texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
            )
        elseif isWolfArmor then
            particleManager:addParticle(
                particles,
                false,
                0.1 * l, 0.25, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2.5,
                texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
            )
        elseif isMace then
            particleManager:addParticle(
                particles,
                false,
                0.1 * l, 0.5, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3.5,
                texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
            )
        elseif isRod then
            particleManager:addParticle(
                particles,
                false,
                0.1 * l, 0.4, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2.5,
                texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
            )
        elseif isBow then
            particleManager:addParticle(
                particles,
                false,
                0.08 * l, 0, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
                texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
            )
        elseif isSpyglass then
            particleManager:addParticle(
                particles,
                false,
                0.02 * l, 0, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2.5,
                texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
            )
        elseif isCrossbow then
            particleManager:addParticle(
                particles,
                false,
                -0.02 * l, 0.05, 0.03, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
                texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 200
            )
            elseif isShield then
                particleManager:addParticle(
                    particles,
                    true,
                    0 * l, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3.5,
                    texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
                )
            elseif isTrident then
                particleManager:addParticle(
                    particles,
                    false,
                    0 * l, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3.5,
                    texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
                )
            elseif isBrush then
                particleManager:addParticle(
                    particles,
                    false,
                    0.03 * l, 0.2, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
                    texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
                )
        end
    end

    if enchantParticles then
        local SPAWN_INTERVAL = 8

        if time - (global.lastEnchantSpawnTime or 0) >= SPAWN_INTERVAL then
            local letter = string.char(96 + math.random(1, 26))
            local sgaTex = Texture:of("minecraft", "textures/particle/sga_" .. letter .. ".png")

            local x, y, z, amp = 0, 0, 0, 0
            local adjustParticles = {
                { isBow or isSpyglass,                  {-0.05, -0.3, 0} },
                { isCrossbow,                           {-0.1, -0.4, 0} },
                { is2D or isWolfArmor or isHorseArmor,  {0.05, -0.25, 0} },
                { isSpear,                              {0.05, 0.3, 0.1} },
                { isMace,                               {0, 0, 0, 0.05} },
                { isRod,                                {0, -0.1, 0} },
                { isEndCrystal,                         {0, -0.15, 0} }
            }
            for _, entry in ipairs(adjustParticles) do
                if entry[1] then 
                    x = entry[2][1]
                    y = entry[2][2]
                    z = entry[2][3]
                    if entry[4] then
                        amp = entry[4]
                    end
                    break
                end
            end

            local spawnX = ((math.random() * 0.5 - 0.3) + x) * l
            local spawnY = (math.random() * 0.7 + 0.05) + y
            local spawnZ = (math.random() * 0.3 - 0.1) + z

            local particleID = "ench_" .. time .. "_" .. math.random(1000, 9999)

            particleManager:addParticle(
                particles, false,
                spawnX, spawnY, spawnZ,
                0, 0, 0, 0, 0, 0, 0, 0, math.random(-8,8),
                0.05 + math.random() * 0.12,
                sgaTex, "ITEM", hand, "OPACITY", "ADDITIVE",
                12, 160 + math.random(0, 60),
                function(p) particleTickerEnchant(p, particleID, amp) end
            )

            global.lastEnchantSpawnTime = time
            global.activeEnchantParticles = global.activeEnchantParticles + 1
        end
    end
else
    global.enchantActive = false
end

if isTotem then
    particleManager:addParticle(
        particles,
        false,
        0.03 * l, 0.2, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2.5,
        texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
    )
end