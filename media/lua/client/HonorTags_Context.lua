HonorTags = HonorTags or {}

HonorTags.TagPrices = {
    ["Survivor"] = {hours = 0, kills = 0, menu = "hours"},
    ["Citizen"] = {hours = 0, kills = 0, menu = "kills"},
    ["Scavenger"] = {hours = 24, kills = 0, menu = "hours"},
    ["Lone Wolf"] = {hours = 48, kills = 0, menu = "hours"},
    ["Grim Survivor"] = {hours = 60, kills = 0, menu = "hours"},
    ["Relentless"] = {hours = 70, kills = 0, menu = "hours"},
    ["Death Defier"] = {hours = 120, kills = 0, menu = "hours"},
    ["Nightmare Walker"] = {hours = 240, kills = 0, menu = "hours"},
    ["Undying"] = {hours = 480, kills = 0, menu = "hours"},
    ["Apocalypse Veteran"] = {hours = 576, kills = 0, menu = "hours"},
    ["Eternal Survivor"] = {hours = 720, kills = 0, menu = "hours"},
    ["Zombie Bait"] = {hours = 0, kills = 1, menu = "kills"},
    ["Walker Slayer"] = {hours = 0, kills = 100, menu = "kills"},
    ["Deadeye"] = {hours = 0, kills = 200, menu = "kills"},
    ["Undead Hunter"] = {hours = 0, kills = 400, menu = "kills"},
    ["Grave Dancer"] = {hours = 0, kills = 600, menu = "kills"},
    ["Wasteland Reaper"] = {hours = 0, kills = 800, menu = "kills"},
    ["Death's Vanguard"] = {hours = 0, kills = 1000, menu = "kills"},
    ["Brainscrambler"] = {hours = 0, kills = 1250, menu = "kills"},
    ["Zom-b-gone Specialist"] = {hours = 0, kills = 1500, menu = "kills"},
    ["Horde Slayer"] = {hours = 0, kills = 3000, menu = "kills"},
    ["Content Creator"] = {hours = 1, kills = 0, menu = "hours", adminOnly = true},  -- Admin-only tag
}

-- Sort tags alphabetically
function HonorTags.sortTagsAlphabetically(tags)
    local sortedTags = {}
    for tag, owned in pairs(tags) do
        if owned == true and tag ~= "Choice" then
            table.insert(sortedTags, tag)
        end
    end
    table.sort(sortedTags)
    return sortedTags
end

-- Sort tags by price
function HonorTags.sortTagsByPrice(tags, priceType)
    local sortedTags = {}
    for tag, data in pairs(tags) do
        if data.menu == priceType then
            table.insert(sortedTags, {tag = tag, cost = data[priceType]})
        end
    end
    table.sort(sortedTags, function(a, b)
        return a.cost < b.cost
    end)
    return sortedTags
end

function HonorTags.refreshHonorTags(user)
    local playerTags = HonorTagsTable[user]
    local updated = false

    if not playerTags then
        HonorTags.initData(user)
        updated = true
    else
        for tag, data in pairs(HonorTags.TagPrices) do
            if playerTags[tag] == nil then
                playerTags[tag] = false
                updated = true
            end
        end
    end

    for tag, _ in pairs(playerTags) do
        if tag ~= 'Choice' and not HonorTags.TagPrices[tag] then
            if HonorTagsTable[user]["Choice"] == tag then
                HonorTagsTable[user]["Choice"] = ''
                print("Removed selected title: " .. tostring(tag) .. " for user: " .. user)
            end
            playerTags[tag] = nil
            updated = true
        end
    end

    if updated then
        HonorTags.save(HonorTagsTable, user)
        print("HonorTagsTable updated for user: " .. user)
    end
end

function HonorTags.isShowingTag(user)
    return HonorTagsTable[user]["Choice"] ~= nil and HonorTagsTable[user]["Choice"] ~= ''
end

function HonorTags.Context(playerNum, context, worldobjects)
    local pl = getSpecificPlayer(playerNum)
    local user = pl:getUsername()

    HonorTags.refreshHonorTags(user)

    local Main = context:addOptionOnTop("HonorTag")
    Main.iconTexture = getTexture("media/ui/TAGContextIcon.png")
    local opt = ISContextMenu:getNew(context)
    context:addSubMenu(Main, opt)
    local targ = clickedPlayer

    if isAdmin() then
        if user then
            local Subg = opt:addOptionOnTop("Grant: ".. tostring(user))
            Subg.iconTexture = getTexture("media/ui/TAGCustom.png")
            local grntOpt = ISContextMenu:getNew(context)
            opt:addSubMenu(Subg, grntOpt)

            local honors = HonorTagsTable[user]
            if honors then
                for tag, owned in pairs(honors) do
                    local honor = grntOpt:addOption(tostring(tag), worldobjects, function()
                        local id = pl:getOnlineID()
                        if not getPlayerByOnlineID(id) then
                            pl:setHaloNote(tostring('Failed To Grant Honor Tag To '.. tostring(user)), 250, 0, 0, 900)
                        else
                            pl:setHaloNote(tostring('Granted Honor Tag To '.. tostring(user)), 0, 250, 0, 900)

                            local bool = HonorTagsTable[user][tag]
                            bool = not bool
                            HonorTagsTable[user][tag] = bool
                            if bool == true then
                                HonorTags.sfx(user)
                            end
                            if bool == false and HonorTagsTable[user]["Choice"] == tostring(tag) then
                                HonorTagsTable[user]["Choice"] = ''
                            end
                            HonorTags.save(HonorTagsTable, user)
                        end
                    end)

                    local tip = ISWorldObjectContextMenu.addToolTip()
                    if owned == true then
                        grntOpt:setOptionChecked(honor, true)
                        honor.iconTexture = getTexture("media/ui/TAGOwned.png")
                        tip.description = tostring('Unlocked')
                    else
                        grntOpt:setOptionChecked(honor, false)
                        honor.iconTexture = getTexture("media/ui/TAGNone.png")
                        tip.description = tostring('Locked')
                    end
                    honor.toolTip = tip
                end
            end
        end

        if targ then
            local targUser = targ:getUsername()
            if targUser then
                local Subg = opt:addOptionOnTop("Grant: ".. tostring(targUser))
                Subg.iconTexture = getTexture("media/ui/TAGCustom.png")
                local grntOpt = ISContextMenu:getNew(context)
                opt:addSubMenu(Subg, grntOpt)

                local honors = HonorTagsTable[targUser]
                if honors then
                    for tag, owned in pairs(honors) do
                        local honor = grntOpt:addOption(tostring(tag), worldobjects, function()
                            local id = targ:getOnlineID()
                            if not getPlayerByOnlineID(id) then
                                pl:setHaloNote(tostring('Failed To Grant Honor Tag To '.. tostring(targUser)), 250, 0, 0, 900)
                            else
                                pl:setHaloNote(tostring('Granted Honor Tag To '.. tostring(targUser)), 0, 250, 0, 900)

                                local bool = HonorTagsTable[targUser][tag]
                                bool = not bool
                                HonorTagsTable[targUser][tag] = bool
                                if bool == true then
                                    HonorTags.sfx(targUser)
                                end
                                if bool == false and HonorTagsTable[targUser]["Choice"] == tostring(tag) then
                                    HonorTagsTable[targUser]["Choice"] = ''
                                end
                                HonorTags.save(HonorTagsTable, targUser)
                            end
                        end)

                        local tip = ISWorldObjectContextMenu.addToolTip()
                        if owned == true then
                            grntOpt:setOptionChecked(honor, true)
                            honor.iconTexture = getTexture("media/ui/TAGOwned.png")
                            tip.description = tostring('Unlocked')
                        else
                            grntOpt:setOptionChecked(honor, false)
                            honor.iconTexture = getTexture("media/ui/TAGNone.png")
                            tip.description = tostring('Locked')
                        end
                        honor.toolTip = tip
                    end
                end
            end
        end
    end

    ----------------------- Select Menu ---------------------------
    local sub = opt:addOptionOnTop("Select:")
    local opt2 = ISContextMenu:getNew(context)
    opt:addSubMenu(sub, opt2)
    opt:setOptionChecked(sub, HonorTags.isShowingTag(user))

    -- Alphabetically sort and display owned tags
    local honors = HonorTagsTable[user]
    if honors ~= nil then
        local sortedOwnedTags = HonorTags.sortTagsAlphabetically(honors)
        for _, tag in ipairs(sortedOwnedTags) do
            local hopt = opt2:addOption(tostring(tag), worldobjects, function()
                if HonorTagsTable[user]["Choice"] ~= nil and HonorTagsTable[user]["Choice"] == tostring(tag) then
                    HonorTagsTable[user]['Choice'] = ''
                else
                    HonorTagsTable[user]['Choice'] = tostring(tag)
                end
                HonorTags.save(HonorTagsTable, user)
                context:hideAndChildren()
            end)

            local tip = ISWorldObjectContextMenu.addToolTip()
            if HonorTagsTable[user]["Choice"] ~= nil and HonorTagsTable[user]["Choice"] == tostring(tag) then
                hopt.iconTexture = getTexture("media/ui/TAGActive.png")
                tip.description = tostring('Equipped')
            else
                hopt.iconTexture = getTexture("media/ui/TAGOwned.png")
                tip.description = tostring('Unlocked')
            end
            hopt.toolTip = tip
        end
    end

    ----------------------- Buy Menu ---------------------------

    local ul = opt:addOption("Unlock")
    local optUnlock = ISContextMenu:getNew(context)
    opt:addSubMenu(ul, optUnlock)

    if HonorTags.isCantUseHrs() and HonorTags.isCantUseKills() then
        ul.iconTexture = getTexture("media/ui/TAGContextIcon_BuyMenuOff.png")
        local tip = ISWorldObjectContextMenu.addToolTip()
        tip.description = tostring('Disabled By Admin')
        ul.notAvailable = true
        ul.toolTip = tip
    else
        ul.iconTexture = getTexture("media/ui/TAGContextIcon_BuyMenu.png")
    end

    ----------------------- Hours Buy Menu ---------------------------
    local subHrs = optUnlock:addOption("Hours Survived: " .. tostring(round(pl:getHoursSurvived())))
    local optHrs = ISContextMenu:getNew(context)
    optUnlock:addSubMenu(subHrs, optHrs)

    if HonorTags.isCantUseHrs() then
        subHrs.iconTexture = getTexture("media/ui/TAGContextIcon_BuyMenuOff.png")
        local tip = ISWorldObjectContextMenu.addToolTip()
        tip.description = tostring('Disabled By Admin')
        subHrs.notAvailable = true
        subHrs.toolTip = tip
    else
        subHrs.iconTexture = getTexture("media/ui/TAGContextIcon_HrsMenu.png")
    end

    -- Sort the tags by hours cost and display in buy menu
    local sortedHoursTags = HonorTags.sortTagsByPrice(HonorTags.TagPrices, "hours")
    for _, tagData in ipairs(sortedHoursTags) do
        local tag = tagData.tag
        -- Content Creator is admin only
        if not honors[tag] and (not HonorTags.TagPrices[tag].adminOnly or isAdmin()) then
            local bOpt1 = optHrs:addOption(tostring(tag), worldobjects, function()
                if HonorTags.isCanPayHrs(pl, tag) then
                    HonorTags.doPayHrs(pl, tag)
                    HonorTags.doPayMsg(pl, tag)
                    HonorTagsTable[user][tag] = true
                    HonorTags.save(HonorTagsTable, user)
                end
                context:hideAndChildren()
            end)

            if HonorTags.isCanPayHrs(pl, tag) then
                bOpt1.iconTexture = getTexture("media/ui/TAGContextIcon_HrsOn.png")
            else
                bOpt1.notAvailable = true
                bOpt1.iconTexture = getTexture("media/ui/TAGContextIcon_HrsOff.png")
            end

            local tip = ISWorldObjectContextMenu.addToolTip()
            tip.description = 'Cost: ' .. tostring(HonorTags.getHrsCost(tag)) .. ' hours survived'
            if HonorTags.getHrsCost(tag) == 1 then
                tip.description = 'Cost: Survive 1 hour'
            elseif HonorTags.getHrsCost(tag) == 24 then
                tip.description = 'Cost: Survive a day'
            elseif HonorTags.getHrsCost(tag) == 168 then
                tip.description = 'Cost: Survive a week'
            end

            bOpt1.toolTip = tip
        end
    end

    ----------------------- Kills Buy Menu ---------------------------
    local subKills = optUnlock:addOption("Zombie Kills: " .. tostring(pl:getZombieKills()))
    local optKills = ISContextMenu:getNew(context)
    optUnlock:addSubMenu(subKills, optKills)

    if HonorTags.isCantUseKills() then
        subKills.iconTexture = getTexture("media/ui/TAGContextIcon_BuyMenuOff.png")
        local tip = ISWorldObjectContextMenu.addToolTip()
        tip.description = tostring('Disabled By Admin')
        subKills.notAvailable = true
        subKills.toolTip = tip
    else
        subKills.iconTexture = getTexture("media/ui/TAGContextIcon_KillsMenu.png")
    end

    -- Sort the tags by kills cost and display in buy menu
    local sortedKillsTags = HonorTags.sortTagsByPrice(HonorTags.TagPrices, "kills")
    for _, tagData in ipairs(sortedKillsTags) do
        local tag = tagData.tag
        -- Content Creator is admin only
        if not honors[tag] and (not HonorTags.TagPrices[tag].adminOnly or isAdmin()) then
            local bOpt2 = optKills:addOption(tostring(tag), worldobjects, function()
                if HonorTags.isCanPayKills(pl, tag) then
                    HonorTags.doPayKills(pl, tag)
                    HonorTags.doPayMsg(pl, tag)
                    HonorTagsTable[user][tag] = true
                    HonorTags.save(HonorTagsTable, user)
                end
                context:hideAndChildren()
            end)

            if HonorTags.isCanPayKills(pl, tag) then
                bOpt2.iconTexture = getTexture("media/ui/TAGContextIcon_KillsOn.png")
            else
                bOpt2.notAvailable = true
                bOpt2.iconTexture = getTexture("media/ui/TAGContextIcon_KillsOff.png")
            end

            local tip = ISWorldObjectContextMenu.addToolTip()
            tip.description = 'Cost: ' .. tostring(HonorTags.getKillsCost(tag)) .. ' zombie kills'
            if HonorTags.getKillsCost(tag) == 1 then
                tip.description = 'Cost: Kill a zombie'
            end
            bOpt2.toolTip = tip
        end
    end
end

function HonorTags.GrantTag(user, tagName, tagPrice, paymentType)
    local player = getPlayerFromUsername(user)
    local playerHours = player:getHoursSurvived()
    local playerKills = player:getZombieKills()

    if tagName == "Content Creator" and not isAdmin() then
        print("Only admins can grant the Content Creator tag.")
        return
    end

    if paymentType == "hours" and playerHours >= tagPrice.hours then
        HonorTagsTable[user]["Choice"] = tagName
        player:setHoursSurvived(playerHours - tagPrice.hours)
        print("Granted tag " .. tagName .. " to " .. user .. " using hours")
    elseif paymentType == "kills" and playerKills >= tagPrice.kills then
        HonorTagsTable[user]["Choice"] = tagName
        player:setZombieKills(playerKills - tagPrice.kills)
        print("Granted tag " .. tagName .. " to " .. user .. " using kills")
    else
        print("Not enough points to grant tag " .. tagName .. " to " .. user)
    end
end

Events.OnFillWorldObjectContextMenu.Remove(HonorTags.Context)
Events.OnFillWorldObjectContextMenu.Add(HonorTags.Context)
