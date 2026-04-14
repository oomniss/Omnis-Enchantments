-- by omnis._.

local l           = context.mainHand and 1 or -1
local hand        = context.hand
local particles   = context.particles
local itemName    = I:getName(context.item):gsub("minecraft:", "")
local isEnchanted = I:isEnchanted(context.item)
local isUsingItem = P:isUsingItem(context.player)

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
        if i:find("[%^%$%(%)%%%.%[%]%*%+%-%?]") then
            return false
        end
        return I:isIn(context.item, Tags:getFabricTag(i))
            or I:isIn(context.item, Tags:getVanillaTag(i))
    end

    for _, i in ipairs(list) do
        if check(i) then return true end
    end
    return false
end

-- === PARTICLES ===
local glowParticles             = ${glowParticles}
local enchantParticles          = true

local isPickaxe                 = matched("pickaxes") and ${glowPickaxes}
local isAxe                     = matched("axes")
local isHoe                     = matched("hoes")
local isShovel                  = matched("shovels")
local isSword                   = matched("swords") and ${glowSwords}
local isSpear                   = matched("spears")
local isTrident                 = matched("trident")
local isBook                    = matched({"enchanted_book", "written_book"})
local isRod                     = matched({"fishing_rod", "carrot_on_a_stick", "warped_fungus_on_a_stick"})
local isShears                  = matched("shears")
local isEnchantedGoldenApple    = matched("enchanted_golden_apple")
local isArmor                   = matched({"head_armor", "chest_armor", "leg_armor", "foot_armor", "elytra"})
local isNautilusArmor           = matched("nautilus_armor", true)
local isHorseArmor              = matched("horse_armor", true)
local isWolfArmor               = matched("wolf_armor")
local isMace                    = matched("mace")
local isBow                     = matched("bow")
local isCrossbow                = matched("crossbow")
local isShield                  = matched("shield")
local isFlintSteel              = matched("flint_and_steel")
local isBrush                   = matched("brush")
local isSpyglass                = matched("spyglass")
local isCompass                 = matched({"compasses", "clock"})
local isNetherStar              = matched("nether_star")
local isExperienceBottle        = matched("experience_bottle")
local isTotem                   = matched("totem_of_undying") and ${glowTotem}

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
    return "purple" .. "_glow.png"
end

local texture = Texture:of("minecraft", "textures/particle/" .. getTexture())

-- === PARTICLES ===
if isEnchanted then
    if glowParticles then
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
        elseif isBook or isEnchantedGoldenApple or isArmor or isNautilusArmor or isShears or isCompass or isFlintSteel or isNetherStar or isExperienceBottle then
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
        elseif isShield then -- não funciona por algum motivo - entity
            particleManager:addParticle(
                particles,
                true,
                0 * l, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3.5,
                texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
            )
        elseif isTrident then -- não funciona por algum motivo - entity
            particleManager:addParticle(
                particles,
                true,
                0 * l, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3.5,
                texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
            )
        elseif isBrush then -- não funciona por algum motivo
            particleManager:addParticle(
                particles,
                false,
                0.03 * l, 0.2, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
                texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255
            )
        end
    end

    if enchantParticles then
        
    end
end

if isTotem then
    particleManager:addParticle(
        particles,
        false,
        0.03 * l, 0.2, 0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4,
        texture, "ITEM", hand, "SPAWN", "ADDITIVE", 0, 255 
    )
end