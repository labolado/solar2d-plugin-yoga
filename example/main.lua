local yoga = require("plugin.yoga")

-- Full screen (including letterbox margins)
local W = display.actualContentWidth
local H = display.actualContentHeight
local ox = display.screenOriginX
local oy = display.screenOriginY

local root = yoga.newNode()
root:setWidth(W)
root:setHeight(H)
root:setFlexDirection(yoga.FlexDirection.column)

local header = yoga.newNode()
header:setHeight(80)

local content = yoga.newNode()
content:setFlexGrow(1)

local footer = yoga.newNode()
footer:setHeight(60)

root:insertChild(header, 0)
root:insertChild(content, 1)
root:insertChild(footer, 2)

root:calculateLayout()

-- Draw
local colors = {
    {0.2, 0.6, 1.0},
    {0.9, 0.9, 0.9},
    {0.2, 0.8, 0.4},
}
local labels = {"Header", "Content", "Footer"}
local nodes = {header, content, footer}

for i, node in ipairs(nodes) do
    local x, y, w, h = node:getLayout()
    local rect = display.newRect(ox + x + w/2, oy + y + h/2, w, h)
    rect:setFillColor(unpack(colors[i]))
    local text = display.newText(labels[i], ox + x + w/2, oy + y + h/2, native.systemFontBold, 20)
    text:setFillColor(0)
end

root:freeRecursive()
print("Yoga v3.2.1 layout demo")
