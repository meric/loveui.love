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
color = love.graphics.setColor
line = love.graphics.line
point = love.graphics.point
draw = love.graphics.draw
framebuffer = love.graphics.newFramebuffer
rendertarget = love.graphics.setRenderTarget

local function nextpow(x)
  return math.pow(2, math.ceil(math.log(x)/math.log(2)))
end
local function archash(mode, radius, width, length)
  return table.concat({mode, radius, width, length}, "|")
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
      x, y = x-radius, y-radius
      local a = math.atan2(y, x)
      if string.find(tostring(length-a), "0%.00") then 
        --print(length, a, length-a, x, y) 
      end
      if a == length then 
        --print(length, a, x, y) 
      end
      if a > 0 and a <= length then
        local dist = x*x + y*y
        if dist >= inner^2 and dist <= outer^2 and mode == "fill" then
          -- Completely filled.
          return 255, 255, 255, 255
        elseif dist >= outer^2 and dist <= (outer+1)^2 then
          -- Outer border anti-aliasing.
          return 255, 255, 255, (1-(math.sqrt(dist)-outer))*255
        elseif dist >= (inner-1)^2 and dist <= inner^2 then
          -- Inner border anti-aliasing.
          return 255, 255, 255, (math.sqrt(dist)-inner)*255
        end
      end
      return 0, 0, 0, 0
    end)
    arcimg[hash] = love.graphics.newImage(imagedata)
  end
  arcimg[hash]:setFilter("linear","nearest")
  draw(arcimg[hash], -radius, -radius)
end

--- Draw a sub-part of a circle.
-- @param radius The radius from the outer side of the arc.
-- @param width The thickness of the arc.
-- @param length The length of the arc in radians.
function arc2(mode, radius, width, length)
  -- Precision of the round edge.
  local delta = math.pi / 18
  -- Trigonometry
  local function px(radius, angle) return radius*math.cos(angle) end
  local function py(radius, angle) return radius*math.sin(angle) end
  love.graphics.setLine( 1, "smooth" )
  -- Draw arc by drawing many little trapezoids.
  -- Modify the radius to produce anti-alias effect.
  -- o = outer, i = inner.
  local o, i = radius-0.5, radius-width+0.5
  local function trapezoid(l, c)
    if mode == "fill" then 
      polygon("fill", px(i, l), py(i, l), px(o, l), py(o, l), px(o, c), 
        py(o, c), px(i, c), py(i, c))
    end
    -- Anti-aliasing round edges of arc.
    --line(px(o, l), py(o, l), px(o, c), py(o, c))
    --line(px(i, l), py(i, l), px(i, c), py(i, c))
  end
  local last = 0
  for current = delta, length, delta do
    trapezoid(last, current)
    last = current
  end
  trapezoid(last, length)
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
  --rotate(angle) 
  local hash = archash(mode, radius, width, length)
  if arccnt[hash] > 1024 then
    -- draw arc image
    arc1(mode, radius, width, length)
  else
    arccnt[hash] = arccnt[hash] + 1
    -- draw arc graphically
    arc2(mode, radius, width, length)
  end
  pop()
end
