
function receiveMoney(faction)

    local x, y = Sector():getCoordinates()
    local money = 60000 * Balancing_GetSectorRichnessFactor(x, y)

    Sector():dropBundle(Entity().translationf, faction, nil, money)
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

    Sector():dropTurret(Entity().translationf, faction, nil, turret)

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

    local upgrade = generator:generateSectorSystem(x, y)
    Sector():dropUpgrade(Entity().translationf, faction, nil, upgrade)
end