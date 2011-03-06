--- loveui is a love2d library to provide resuable GUI widgets to love2d 
-- developers.
module ("ui", package.seeall)

require "loveui/util/test"

--- Returns whether a point is within a rectangle boundary
-- @param point A sized 2 array of x, y values
-- @param rect A sized 4 array of x, y, w, h values
function pointinrect(point, rect)
  local x1, y1 = unpack(point)
  local x2, y2, w, h = unpack(rect)
  return x1 >= x2 and y1 >= y2 and x1 <= x2 + w and y1 <= y2 + h
end

test("ui.pointinrect", function()
    return pointinrect({0,0},{1,1,100,100}) == false
  end)

test("ui.pointinrect", function()
    return pointinrect({1,1},{1,1,100,100}) == true
  end)

test("ui.pointinrect", function()
    return pointinrect({101,101},{1,1,100,100}) == true
  end)

test("ui.pointinrect", function()
    return pointinrect({101,102},{1,1,100,100}) == false
  end)
  
return ui
