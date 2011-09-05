--- loveui is a love2d library to provide resuable GUI widgets to love2d 
-- developers.

module ("ui", package.seeall)

polygon = love.graphics.polygon
rectangle = love.graphics.rectangle
push = love.graphics.push
pop = love.graphics.pop
rotate = love.graphics.rotate
translate = love.graphics.translate
scale = love.graphics.scale
line = love.graphics.line
draw = love.graphics.draw
framebuffer = love.graphics.newFramebuffer
rendertarget = love.graphics.setRenderTarget
scissor = love.graphics.setScissor
getscissor = love.graphics.getScissor
newfont = love.graphics.newFont
text = love.graphics.print
time = love.timer.getTime
keyheld = love.keyboard.isDown
mouseheld = love.mouse.isDown
mousex = love.mouse.getX
mousey = love.mouse.getY

-- Stash current graphics settings into a table
-- @return Returns the settings in a table, to be <code>unstash</code>ed later
function stash()
  -- TODO Stash other settings
  local stashed = {}
  local l, t, w, h = getscissor()
  stashed.color = {color()}
  stashed.scissor = l and {l, t, w, h} or nil
  return stashed
end

-- Restore previously stashed graphics settings
-- @param t Table returned by a previous <code>stash()</code> call.
function unstash(t)
  -- TODO Unstash other settings
  if t.scissor then
    scissor(unpack(t.scissor))
  else
    scissor()
  end
  color(unpack(t.color))
end

function font(...)
  if ... then 
    if ... ~= love.graphics.getFont() then
      love.graphics.setFont(...)
    end
  else 
    return love.graphics.getFont() 
  end
end

function textheight()
  local current = font()
  return current and current:getHeight() or 0
end

function textwidth(t)
  local current = font()
  return current and current:getWidth(t) or 0
end

function point(x, y)
  rectangle("fill", x, y, 1, 1)
end

function color(...)
  if ... then return love.graphics.setColor(...)
  else return love.graphics.getColor() end
end

local function nextpow(x)
  return math.pow(2, math.ceil(math.log(x)/math.log(2)))
end
local function archash(mode, radius, width, length)
  return table.concat({mode, radius, width, length}, "|")
end

local function arcpixel(mode, x, y, inner, outer, length)
  local a = math.atan2(y, x)
  if a >= 0 and a <= length then
    local dist = x*x + y*y
    if dist >= inner^2 and dist <= outer^2 and mode == "fill" then
      -- Completely filled.
      return 255
    elseif dist >= outer^2 and dist <= (outer+1)^2 then
      -- Outer border anti-aliasing.
      return (1-(math.sqrt(dist)-outer))*255
    elseif dist >= (inner-1)^2 and dist <= inner^2 then
      -- Inner border anti-aliasing.
      return (math.sqrt(dist)-inner)*255
    end
  end
  return 0
end

--- Draw a sub-part of a circle. Memo-ed using images.
-- @param radius The radius from the outer side of the arc.
-- @param width The thickness of the arc.
-- @param length The length of the arc in radians.
local arcimg = {}
function arc1(mode, radius, width, length)
  local hash = archash(mode, radius, width, length)
  if not arcimg[hash] then
    -- Create image data. 
    local size = nextpow(radius*2)
    local imagedata = love.image.newImageData(size, size)
    -- Outer and inner radius of arc.
    -- Reduce radius to allow for extra-width from anti-aliasing.
    local outer, inner = radius- 0.5, radius-width + 0.5
    -- Map each pixel.
    imagedata:mapPixel(function(x, y, r, g, b, a)
      return 255, 255, 255, arcpixel(mode, x, y, inner, outer, length)
    end)
    arcimg[hash] = love.graphics.newImage(imagedata)
  end
  arcimg[hash]:setFilter("linear","nearest")
  draw(arcimg[hash], 0, 0)
end

function arc2(mode, radius, width, length)
  -- Outer and inner radius of arc.
  -- Reduce radius to allow for extra-width from anti-aliasing.
  local outer, inner = radius - 0.5 , radius-width + 0.5
  local currentcolor = {color()}
  ui.push()
    for x = 0, radius * 2 do
      for y = 0, radius * 2 do
        local a = arcpixel(mode, x, y, inner, outer, length)
        if a > 0 then
          local pointcolor = {unpack(currentcolor)}
          pointcolor[4] = pointcolor[4] * (a / 255)
          color(unpack(pointcolor))
          point(x, y)
        end
      end
    end
  ui.pop()
  color(unpack(currentcolor))
end

--- Draw a sub-part of a circle.
-- @param x The center x coordinate.
-- @param y The center y coordinate.
-- @param angle The angle to rotate the arc.
-- @param radius The radius from the outer side of the arc.
-- @param width The thickness of the arc.
-- @param length The length of the arc in radians.
local arccnt = setmetatable({}, {__index = function() return 0 end})
function arc(mode, left, top, angle, radius, width, length)
  assert(mode == "fill" or mode == "line")
  if length > 2 * math.pi then length = 2 * math.pi end
  while angle < -math.pi do angle = angle + math.pi*2 end
  while angle+length > math.pi do angle = angle - math.pi*2 end
  radius = math.max(radius, 0)
  width = math.min(radius, width)
  push() 
  translate(left, top)
  rotate(angle) 
  local hash = archash(mode, radius, width, length)
  if arccnt[hash] > -1 then
    -- draw arc image
    arc1(mode, radius-1, width, length)
  else
    arccnt[hash] = arccnt[hash] + 1
    -- draw arc graphically
    arc2(mode, radius-1, width, length)
  end
  pop()
end
