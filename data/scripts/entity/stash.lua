
function receiveMoney(faction)

    local x, y = Sector():getCoordinates()
    local money = 50000 * Balancing_GetSectorRichnessFactor(x, y)

    Sector():dropBundle(Entity().translationf, faction, nil, money)
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
    local turret = SectorTurretGenerator():generate(x, y, 0, rarity)

    Sector():dropTurret(Entity().translationf, faction, nil, turret)
end

function receiveUpgrade(faction)
    local x, y = Sector():getCoordinates()

    local rarity = getDropRarity()
    
    local generator = UpgradeGenerator()
    if faction.isPlayer and faction.ownsBlackMarketDLC then
        generator.blackMarketUpgradesEnabled = true
    end

    local upgrade = generator:generateSectorSystem(x, y, rarity)
    Sector():dropUpgrade(Entity().translationf, faction, nil, upgrade)
end

function receiveDrop(faction)
    -- Drop is based on a 50% chance of either a turret or a system
    if random():getFloat() < 0.5 then
        receiveTurret(faction)
    else
        receiveUpgrade(faction)
    end
end

function getExtraDropProbabilities()
    local probabilities = {
        0.30, 0.15, 0.08, 0.04, 0.02
    }

    return probabilities
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

    local probabilities = getExtraDropProbabilities()
    local p = 0
    for _, probability in pairs(probabilities) do
        p = random():getFloat()
        player:sendChatMessage("Improved Stash", ChatMessageType.Normal, "Evaluating probability %1% against chance threshold %2%", p, probability)
        if p <= probability then
            receiveDrop(receiver)
        end
    end
end
