
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

function receiveDrop(faction)
    -- Drop is based on a 50% chance of either a turret or a system
    if random():getFloat() < 0.5 then
        receiveTurret(faction)
    else
        receiveUpgrade(faction)
    end
end

local original_claim = claim
function claim()
    -- Perform default behavior
    original_claim()

    local receiver, ship, player = getInteractingFaction(callingPlayer, AlliancePrivilege.AddItems, AlliancePrivilege.AddResources)
    if not receiver then return end

    local entity = Entity()
    local dist = ship:getNearestDistance(entity)
    if dist > 20.0 then
        -- Abort message display. Default behavior already performs this.
        -- The check is duplicated as there is no return value from the original function
        -- to detect the abort of 'claim'
        return
    end

    -- Default behavior includes a guaranteed drop with a 50% chance of a second
    -- The following drops are ADDITIONAL to the default.

    local extraGuaranteedDrops = 2
    local extraProbableDrops = 3

    for i = 1, extraGuaranteedDrops do
        receiveDrop(receiver)
    end

    for i = 1, extraProbableDrops do
        if random():getFloat() < 0.5 then
            receiveDrop(receiver)
        end
    end
end
