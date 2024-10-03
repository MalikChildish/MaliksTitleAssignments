HonorTagsUI = ISCollapsableWindow:derive("HonorTagsUI")
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
function HonorTagsUI:initialise()
    ISCollapsableWindow.initialise(self)

    local fontHgt = FONT_HGT_SMALL
    local buttonWid1 = getTextManager():MeasureStringX(UIFont.Small, "APPLY") + 12
    local buttonWid2 = getTextManager():MeasureStringX(UIFont.Small, "DELETE") + 12
    local buttonWid = math.max(math.max(buttonWid1, buttonWid2), 100)
    local buttonHgt = math.max(fontHgt + 6, 25)
    local padBottom = 10

    self.apply = ISButton:new((self:getWidth() / 2) - 5 - buttonWid, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, 'APPLY', self, HonorTagsUI.onClick)
    self.apply.internal = "APPLY"
    self.apply:initialise()
    self.apply:instantiate()
    self.apply.borderColor = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.apply)
--[[
    self.delete = ISButton:new((self:getWidth() / 2) + 5, self:getHeight() - padBottom - buttonHgt, buttonWid, buttonHgt, 'DELETE', self, HonorTagsUI.onClick)
    self.delete.internal = "DELETE"
    self.delete:initialise()
    self.delete:instantiate()
    self.delete.borderColor = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.delete)
]]
    self.fontHgt = FONT_HGT_MEDIUM
    local inset = 2
    local height = inset + self.fontHgt * self.numLines + inset
    local y = 55

    local label = ISLabel:new((self:getWidth() / 3) - 15, y, height, "Tag:", 1, 1, 1, 1, UIFont.Small)
    label:initialise()
    self:addChild(label)
	local textTag = HonorTagsTable[self.targUser]['Choice']
    self.entryTag = ISTextEntryBox:new(textTag, (self:getWidth() / 3), y, (self:getWidth() / 2) - 20, height)
    self.entryTag.font = UIFont.Medium
    self.entryTag:initialise()
    self.entryTag:instantiate()
    self:addChild(self.entryTag)
	--[[

    self.closeButton = ISButton:new(self:getWidth() - buttonWid3 - 5 , 0, buttonWid3, 12, "X", self, HonorTagsUI.onClick)
    self.closeButton.internal = "X"
    self.closeButton:initialise()
    self.closeButton:instantiate()
    self.closeButton.borderColor = {r=1, g=1, b=1, a=0.1}
    self.closeButton.backgroundColor = {r=0.8, g=0.1, b=0.1, a=0.8}  -- Red background
    self.closeButton.font = UIFont.Small
    self:addChild(self.closeButton)

]]
end

function HonorTagsUI:refresh()

end
function HonorTagsUI:destroy()
    UIManager.setShowPausedMessage(true)
    self:setVisible(false)
    self:removeFromUIManager()
end

function HonorTagsUI:onClick(button)
--[[
    if button.internal == "DELETE" then
		--HonorTagsChoice[self.targUser] = ''
		HonorTagsTable[self.targUser]['Choice'] = ''
		HonorTags.save(HonorTagsChoice)
        return
    end]]

    if button.internal == "APPLY" then
        local entry = self.entryTag:getInternalText()
      --  HonorTagsChoice[self.targUser] = tostring(entry)
		HonorTagsTable[self.targUser]['Choice'] = tostring(entry)
        HonorTags.save(HonorTagsTable, self.targUser)
		return
    end
--[[
	if button.internal == "X" then
		HonorTagsUI:refresh()
        self:destroy()
    end
]]
end

function HonorTagsUI:titleBarHeight()
    return 16
end

function HonorTagsUI:prerender()
    self.backgroundColor.a = 0.8
    self.entryTag.backgroundColor.a = 0.8
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)

    local th = self:titleBarHeight()
    self:drawTextureScaled(self.titlebarbkg, 2, 1, self:getWidth() - 4, th - 2, 1, 1, 1, 1)

    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    self:drawTextCentre("Assign Tag", self:getWidth() / 2, 20, 1, 1, 1, 1, UIFont.NewLarge)

    self:updateButtons()
end

function HonorTagsUI:updateButtons()
    self.apply:setEnable(true)
    self.apply.tooltip = nil
end

function HonorTagsUI:render()
end

function HonorTagsUI:onMouseMove(dx, dy)
    self.mouseOver = true
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end

function HonorTagsUI:onMouseMoveOutside(dx, dy)
    self.mouseOver = false
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end

function HonorTagsUI:onMouseDown(x, y)
    if not self:getIsVisible() then
        return
    end
    self.downX = x
    self.downY = y
    self.moving = true
    self:bringToTop()
end

function HonorTagsUI:onMouseUp(x, y)
    if not self:getIsVisible() then
        return
    end
    self.moving = false
    if ISMouseDrag.tabPanel then
        ISMouseDrag.tabPanel:onMouseUp(x, y)
    end
    ISMouseDrag.dragView = nil
end

function HonorTagsUI:onMouseUpOutside(x, y)
    if not self:getIsVisible() then
        return
    end
    self.moving = false
    ISMouseDrag.dragView = nil
end

function HonorTagsUI:new(x, y, width, height, targUser)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0.5}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.width = width
    o.height = height
    o.anchorLeft = true
    o.anchorRight = true
    o.anchorTop = true
    o.anchorBottom = true
    o.targUser = targUser
    o.titlebarbkg = getTexture("media/ui/Panel_TitleBar.png")
    o.numLines = 1
    o.maxLines = 1
    o.multipleLine = false
    return o
end

function HonorTagsUI:UI_Open(targUser)
    if targUser ~= nil then
		local xOrigin = getCore():getScreenWidth()  / 2
        local yOrigin = getCore():getScreenHeight()  / 2
        local ui = HonorTagsUI:new(xOrigin, yOrigin, 300, 200, targUser)
        ui:initialise()
        ui:addToUIManager()
    end
end

function HonorTagsUI:bringToFront()
    -- Bring the UI instance to the front
    if self and self:isValid() then
        self:bringToFront()
    end
end
