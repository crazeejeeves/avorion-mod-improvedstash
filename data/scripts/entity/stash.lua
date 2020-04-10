
function receiveMoney(faction)

    local x, y = Sector():getCoordinates()
    local money = 50000 * Balancing_GetSectorRichnessFactor(x, y)

    faction:receive("Found %1% Credits in a stash."%_T, money)
end

function getDropRarity()
    local rarity = Rarity(RarityType.Uncommon)
    local probability = random():getFloat()

    if probability < 0.005 then
        rarity = Rarity(RarityType.Legendary)
    elseif probability < 0.05 then
        rarity = Rarity(RarityType.Exotic)
    elseif probability < 0.3 then
        rarity = Rarity(RarityType.Exceptional)
    elseif probability < 0.7 then
        rarity = Rarity(RarityType.Rare)
    end

    return rarity
end

function receiveTurret(faction)
    local x, y = Sector():getCoordinates()

    local rarity = getDropRarity()
    local turret = InventoryTurret(SectorTurretGenerator():generate(x, y, 0, rarity))

    faction:getInventory():addOrDrop(turret)
end

function receiveUpgrade(faction)
    local x, y = Sector():getCoordinates()

    local rarity = getDropRarity()
    local upgrade = UpgradeGenerator():generateSectorSystem(x, y, rarity)
    
    faction:getInventory():addOrDrop(upgrade)
end