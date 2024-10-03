HonorTags = HonorTags or {}
HonorTagsInstance = {}
HonorTagsInstance.__index = HonorTagsInstance
HonorTagsInstance.taggedPl = HonorTagsInstance.taggedPl or {}

-- Set the default font here
local DEFAULT_FONT = UIFont.NewLarge -- Change this to your desired default font

function HonorTagsInstance:limitClamp(val)
	local limit = SandboxVars.HonorTags.OffsetLimit
    local min = val - limit
    val = math.max(val, min)
    val = math.min(val, min + 2 * limit)
	return math.abs(val)
end

function HonorTagsInstance:Clamp(val)
	local min = getCore():getScreenHeight() / 2 - SandboxVars.HonorTags.Offset
	local max = getCore():getScreenHeight() / 2 + SandboxVars.HonorTags.Offset
	val = tonumber(val)
	val = math.min(val, max)
	val = math.max(val, min)
	return val
end

function HonorTagsInstance:TagHandler(targUser, tag)
    if not targUser or not tag then return end

    local function onTick(ticks)
        local targ = getPlayerFromUsername(targUser)
        if not targ then return end

        if targ:isDead() or not tag or not self.taggedPl[targUser] then
            if self.taggedPl[targUser] then
                if isDebugEnabled() then
                    getPlayer():setHaloNote('Removed Tag From ' .. tostring(targUser), 250, 0, 0, 900)
                end
                self.taggedPl[targUser] = nil
            end
            Events.OnTick.Remove(onTick)
            return
        end

        local R = 250
        local G = 250
        local B = 250
        local mpc = getCore():getMpTextColor()
        if SandboxVars.HonorTags.UsePersonalColor and mpc then
            R = mpc:getR()
            G = mpc:getG()
            B = mpc:getB()
        end
        tag:setDefaultColors(R, G, B)
        tag:setVisibleRadius(SandboxVars.HonorTags.VisibleRadius)

        local x, y, z = targ:getX(), targ:getY(), targ:getZ()
        local zoom = getCore():getZoom(0)
		local tagX = (IsoUtils.XToScreen(x, y, z, 0) - IsoCamera.getOffX() - targ:getOffsetX()) / zoom
		local tagY = round((IsoUtils.YToScreen(x, y, z, 0) - IsoCamera.getOffY() - targ:getOffsetY() - SandboxVars.HonorTags.Offset) / zoom) - (SandboxVars.HonorTags.OffsetLimit / zoom)

		local caption = HonorTagsTable[targUser]["Choice"] or ''

		local targSq = targ:getSquare()
		local sq = getPlayer():getSquare()

		if targSq and sq and not targSq:isBlockedTo(sq) then
			tag:ReadString(DEFAULT_FONT, caption, -1)  -- Apply the default font here
			tag:AddBatchedDraw(tagX, tagY, false, 1)
		end
    end

    Events.OnTick.Add(onTick)
    self.taggedPl[targUser] = onTick
end

function HonorTagsInstance:onNewPlDiscovered(targUser)
	if not self.taggedPl[targUser] and targUser then
		if isDebugEnabled() then
			getPlayer():setHaloNote('Added Tag To '..tostring(targUser),0,250,0,500)
		end
		---@TextDrawObject(r,  g,  b,  allowBBcode)
		local tag = TextDrawObject.new()
		self:TagHandler(targUser, tag)
	end
end

function HonorTagsInstance:Collector()
	local onlineUsers = getOnlinePlayers()
	for i=0, onlineUsers:size()-1 do
		local targUser = onlineUsers:get(i):getUsername()
		if HonorTagsTable[targUser] ~= nil then
			HonorTagsInstance:onNewPlDiscovered(targUser)
		else
			HonorTags.initData(targUser)
		end
	end
end

Events.OnPlayerUpdate.Add(function() HonorTagsInstance:Collector() end)
setmetatable(HonorTagsInstance, HonorTagsInstance)
