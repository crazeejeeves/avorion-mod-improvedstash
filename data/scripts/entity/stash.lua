include ("utility")

function receiveMoney(faction)

    local x, y = Sector():getCoordinates()
    local sectorMultiplier = Balancing_GetSectorRewardFactor(x, y)
    local bonusMultiplier = getBonusMultiplier()

    local money = 50000 * sectorMultiplier * bonusMultiplier
    Sector():dropBundle(Entity().translationf, faction, nil, money)

    local material = getMaterialType(x, y)
    local resources = 1000 * sectorMultiplier * bonusMultiplier
    Sector():dropResources(Entity().translationf, faction, nil, material, resources)
end

function getMaterialType(x, y)
    local probabilities = Balancing_GetMaterialProbability(x, y)
    return Material(getValueFromDistribution(probabilities))
end

function getBonusMultiplier()
    local probability = random():getFloat()
    local multiplier = 1.0

    if probability < 0.005 then
        multiplier = 10.0
    elseif probability < 0.1 then
        multiplier = 3.0
    elseif probability < 0.25 then
        multiplier = 1.5
    end

    return multiplier
end

function getDropRarity()
    local rarity = Rarity(RarityType.Exceptional)
    local probability = random():getFloat()

    if probability < 0.005 then
        rarity = Rarity(RarityType.Legendary)
    elseif probability < 0.05 then
        rarity = Rarity(RarityType.Exotic)
    elseif probability >= 0.7 then
        rarity = Rarity(RarityType.Rare)
    end

    return rarity
end

function receiveTurret(faction)
    local x, y = Sector():getCoordinates()

    local generator = SectorTurretGenerator()
    generator.minRarity = getDropRarity()

    local turret = generator:generate(x, y, 0)
    Sector():dropTurret(Entity().translationf, faction, nil, turret)
end

function receiveUpgrade(faction)
    local x, y = Sector():getCoordinates()

    local generator = UpgradeGenerator()
    generator.minRarity = getDropRarity()

    if faction.isPlayer and faction.ownsBlackMarketDLC then
        generator.blackMarketUpgradesEnabled = true
    end

    if faction.isPlayer and faction.ownsIntoTheRiftDLC then
        generator.intoTheRiftUpgradesEnabled = true
    end

    local upgrade = generator:generateSectorSystem(x, y)
    Sector():dropUpgrade(Entity().translationf, faction, nil, upgrade)
end
