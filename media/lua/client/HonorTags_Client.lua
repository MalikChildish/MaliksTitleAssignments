HonorTags = HonorTags or {}

function HonorTags.save(data, user)
    sendClientCommand("HonorTagsTable", "Save", { data = data, user = user })
end

function HonorTags.sfx(user)
    sendClientCommand("HonorTagsTable", "SFX", { user = user })
end

function HonorTags.Sync(module, command, args)
    local pl = getPlayer()
    if not pl then return end
    if not isClient() then return end
    if module == "HonorTagsTable" then
        if command == "ToOne" then
            if pl:getOnlineID() == args.id then
                ModData.add("HonorTagsTable", args.data)
            end
        elseif command == "ToAll" then
            if pl:getOnlineID() ~= args.id then
                print("OnServerCommand HonorTagsTable")
                if HonorTagsTable[args.user] == nil then
                    ModData.add("HonorTagsTable", args.data)
                end
            end
        elseif command == "SFX" then
            if pl:getUsername() == args.user then
                pl:setHaloNote(tostring('Unlocked New Tag'), 150, 250, 150, 900)
                getSoundManager():playUISound("GainExperienceLevel")
            end
        elseif command == "Refresh" then
            print("Refreshing HonorTagsTable for player " .. pl:getUsername())
            HonorTags.initData(pl:getUsername())
        end
    end
end
Events.OnServerCommand.Add(HonorTags.Sync)

function HonorTags.RecieveData(str, data)
    if str == "HonorTagsTable" and data then
        print("OnReceiveGlobalModData HonorTagsTable")
        ModData.add("HonorTagsTable", data)
    end
end
Events.OnReceiveGlobalModData.Add(HonorTags.RecieveData)

function HonorTags.initData(user)
    if not HonorTagsTable then
        HonorTagsTable = ModData.getOrCreate("HonorTagsTable")
    end
    if HonorTagsTable[user] == nil then 
        HonorTagsTable[user] = {
            ["Survivor"] = true,
            ["Citizen"] = true,
            ["Scavenger"] = false,
            ["Lone Wolf"] = false,
            ["Grim Survivor"] = false,
            ["Relentless"] = false,
            ["Death Defier"] = false,
            ["Nightmare Walker"] = false,
            ["Undying"] = false,
            ["Apocalypse Veteran"] = false,
            ["Eternal Survivor"] = false,
            ["Zombie Bait"] = false,
            ["Walker Slayer"] = false,
            ["Deadeye"] = false,
            ["Undead Hunter"] = false,
            ["Grave Dancer"] = false,
            ["Wasteland Reaper"] = false,
            ["Death's Vanguard"] = false,
            ["Brainscrambler"] = false,
            ["Zom-b-gone Specialist"] = false,
            ["Horde Slayer"] = false,
            ["Content Creator"] = false,
            ['Choice'] = '',
        }
        if isDebugEnabled() then print('HonorTags.initData ' .. tostring(user)) end
        HonorTags.save(HonorTagsTable, user)
    end
end

function HonorTags.reInit()
    local user = getPlayer():getUsername()
    if user then
        HonorTags.initData(user)
        Events.OnPlayerUpdate.Remove(HonorTags.reInit)
    end
end
Events.OnPlayerUpdate.Add(HonorTags.reInit)

function HonorTags.gameStart()
    ModData.request('HonorTagsTable')
    local user = getPlayer():getUsername()
    if user then
        HonorTags.initData(user)
    end
end
Events.OnGameStart.Add(HonorTags.gameStart)

function HonorTags.refreshTags()
    sendClientCommand("HonorTagsTable", "Refresh", {})
end

function HonorTags.Init()
    HonorTagsTable = ModData.getOrCreate("HonorTagsTable")
end
Events.OnInitGlobalModData.Add(HonorTags.Init)
