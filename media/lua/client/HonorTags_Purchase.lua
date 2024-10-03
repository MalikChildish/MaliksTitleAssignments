HonorTags = HonorTags or {}

-----------------------    checkers*        ---------------------------
function HonorTags.isCantUseHrs()
    return SandboxVars.HonorTags.HrsPerTag == 0
end

function HonorTags.isCantUseKills()
    return SandboxVars.HonorTags.KillsPerTag == 0
end

function HonorTags.isCanPayHrs(pl, tag)
    if not pl then return false end
    if HonorTags.isCantUseHrs() then return false end
    if pl:getHoursSurvived() >= HonorTags.getHrsCost(tag) then
        return true
    end
    return false
end

function HonorTags.isCanPayKills(pl, tag)
    if not pl then return false end
    if HonorTags.isCantUseKills() then return false end
    if pl:getZombieKills() >= HonorTags.getKillsCost(tag) then
        return true
    end
    return false
end

-----------------------    getters*        ---------------------------
function HonorTags.getHrsCost(tag)
    return HonorTags.TagPrices[tag] and HonorTags.TagPrices[tag].hours or SandboxVars.HonorTags.HrsPerTag or 672
end

function HonorTags.getKillsCost(tag)
    return HonorTags.TagPrices[tag] and HonorTags.TagPrices[tag].kills or SandboxVars.HonorTags.KillsPerTag or 1000
end

----------------------- setters*       ---------------------------
function HonorTags.doPayHrs(pl, tag)
    if HonorTags.isCanPayHrs(pl, tag) then
        local newVal = tonumber(pl:getHoursSurvived()) - tonumber(HonorTags.getHrsCost(tag))
        pl:setHoursSurvived(newVal)
    end
end

function HonorTags.doPayKills(pl, tag)
    if HonorTags.isCanPayKills(pl, tag) then
        local newVal = tonumber(pl:getZombieKills()) - tonumber(HonorTags.getKillsCost(tag))
        pl:setZombieKills(newVal)
    end
end

function HonorTags.doPayMsg(pl, tag)
    local msg = 'UNLOCKED '..tostring(tag).. ' Tag'
    pl:setHaloNote(tostring(msg),150,250,150,900)
    getSoundManager():playUISound("GainExperienceLevel")
end

-----------------------        ---------------------------