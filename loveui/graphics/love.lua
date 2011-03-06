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
draw = love.graphics.draw
framebuffer = love.graphics.newFramebuffer
rendertarget = love.graphics.setRenderTarget

--- Draw a sub-part of a circle.
-- TODO: Draw antialiased arc.
-- @param x The center x coordinate.
-- @param y The center y coordinate.
-- @param angle The angle to rotate the arc.
-- @param radius The radius from the outer side of the arc.
-- @param width The thickness of the arc.
-- @param length The length of the arc in radians.
function arc(mode, x, y, angle, radius, width, length)
  assert(mode == "fill" or mode == "line")
  -- Width cannot be larger than radius.
  width = math.min(radius, width)
  
  -- Angle must be between 0 and 2 PI
  angle = math.max(math.min(math.pi * 2, angle), 0)
  
  -- Precision of the round edge.
  local delta = math.pi / 18
  
  -- Trigonometry
  local function pointx(radius, angle)
    return radius*math.cos(angle)+x
  end
  local function pointy(radius, angle)
    return radius*math.sin(angle)+y
  end
  
  local last = angle
  love.graphics.setLine( 1, "smooth" )
  -- Draw arc by drawing many little trapezoids.
  
  -- Modify the radius to produce anti-alias effect.
  local outer = radius-0.5
  local inner = radius-width+0.5
  
  local function trapezoid(last, current)
    if mode == "fill" then
      polygon("fill",
        pointx(inner, last), pointy(inner, last),
        pointx(outer, last), pointy(outer, last),
        pointx(outer, current), pointy(outer, current),
        pointx(inner, current),pointy(inner, current))
    end
    -- Anti-aliasing round edges of arc.
    line(pointx(outer, last), pointy(outer, last), 
      pointx(outer, current), pointy(outer, current))
    
    line(pointx(inner, last), pointy(inner, last),
      pointx(inner, current), pointy(inner, current))
  end
  
  for current = angle+delta, angle+length, delta do
    trapezoid(last, current)
    last = current
  end
  trapezoid(last, angle+length)
  
  -- Anti-aliasing flat edges of arc.
  line(pointx(outer, angle), pointy(outer, angle),
    pointx(inner, angle), pointy(inner, angle))
  line(pointx(outer, angle+length), pointy(outer, angle+length),
    pointx(inner, angle+length), pointy(inner, angle+length))
end

  
--- Draw a sub-part of a circle.
-- TODO: Draw antialiased arc.
-- @param x The center x coordinate.
-- @param y The center y coordinate.
-- @param angle The angle to rotate the arc.
-- @param radius The radius from the outer side of the arc.
-- @param width The thickness of the arc.
-- @param length The length of the arc in radians.
local arcs = {}
function arc(mode, left, top, angle, radius, width, length)
  -- Normalize angle and angle+length.
  if length > 2 * math.pi then length = 2 * math.pi end
  while angle < -math.pi do angle = angle + math.pi*2 end
  while angle+length > math.pi do angle = angle - math.pi*2 end
  
  -- Get hash of arguments.
  local params = {mode, left, top, angle, radius, width, length}
  local hash = table.concat(params, "|")
  
  -- If not memoed for this set of arguments, then memo it.
  if not arcs[hash] then
    -- Create image data.
    local imagedata = love.image.newImageData(radius*2, radius*2)
    
    -- Current color.
    local c = {love.graphics.getColor( )}
    
    -- Outer and inner radius of arc.
    -- Reduce radius to allow for extra-width from anti-aliasing.
    local outer, inner = radius- 0.5, radius-width + 0.5
    
    -- Map each pixel.
    imagedata:mapPixel(function(x, y, r, g, b, a)
      x, y = x-outer, y-outer
      local a = math.atan2(y, x)
      if a > angle and a <= angle+length then
        if x*x + y*y > inner^2 and x*x + y*y <= outer^2  then
          return 255, 255, 255, 255
        elseif x*x + y*y > outer^2 and x*x + y*y <= (outer+1)^2 then
          return 255, 255, 255, (1-(math.sqrt(x*x + y*y)-outer))*255
        elseif x*x + y*y >= (inner-1)^2 and x*x + y*y < inner^2 then
          return 255, 255, 255, (math.sqrt(x*x + y*y)-inner)*255
        end
      end
      return 0, 0, 0, 0
    end)
    arcs[hash] = love.graphics.newImage(imagedata)
  end
  -- Draw saved image.
  draw(arcs[hash], left-radius, top-radius)
end









