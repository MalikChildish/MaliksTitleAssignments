local function HonorTagsServer(module, command, player, args)
	if isClient() then return end
	if module == "HonorTagsTable" then
		if command == "Fetch" then
			sendServerCommand("HonorTagsTable", "ToOne", { id = player:getOnlineID(), data = args.data, user = args.user})
			ModData.transmit("HonorTagsTable", args.data)
		elseif command == "Save" then
			sendServerCommand("HonorTagsTable", "ToAll", { id = player:getOnlineID(), data = args.data, user = args.user})
			ModData.transmit("HonorTagsTable", args.data)
		elseif command == "SFX" then
			sendServerCommand("HonorTagsTable", "SFX", args)
		end

	end
end

Events.OnClientCommand.Add(HonorTagsServer)

