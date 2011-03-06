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
        local dist = x*x + y*y
        if dist > inner^2 and dist <= outer^2  then
          -- Completely filled.
          return 255, 255, 255, 255
        elseif dist > outer^2 and dist <= (outer+1)^2 then
          -- Outer border anti-aliasing.
          return 255, 255, 255, (1-(math.sqrt(dist)-outer))*255
        elseif dist >= (inner-1)^2 and dist < inner^2 then
          -- Inner border anti-aliasing.
          return 255, 255, 255, (math.sqrt(dist)-inner)*255
        end
      end
      return 0, 0, 0, 0
    end)
    arcs[hash] = love.graphics.newImage(imagedata)
  end
  -- Draw saved image.
  draw(arcs[hash], left-radius, top-radius)
end









