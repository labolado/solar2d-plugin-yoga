local yoga = require("plugin.yoga")

-- Create a simple header + content + footer layout
local root = yoga.newNode()
root:setWidth(display.contentWidth)
root:setHeight(display.contentHeight)
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

-- Draw colored rectangles at computed positions
local colors = {
    {0.2, 0.6, 1.0},   -- header: blue
    {0.9, 0.9, 0.9},    -- content: light gray
    {0.2, 0.8, 0.4},    -- footer: green
}

local nodes = {header, content, footer}
local labels = {"Header", "Content", "Footer"}

for i, node in ipairs(nodes) do
    local x, y, w, h = node:getLayout()
    local rect = display.newRect(x + w/2, y + h/2, w, h)
    rect:setFillColor(unpack(colors[i]))

    local text = display.newText(labels[i], x + w/2, y + h/2, native.systemFontBold, 20)
    text:setFillColor(0)
end

-- Cleanup
root:freeRecursive()

print("Yoga " .. "v3.2.1" .. " layout demo")
