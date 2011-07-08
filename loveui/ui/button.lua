--- loveui is a love2d library to provide resuable GUI widgets to love2d 
-- developers.
module ("ui", package.seeall)

require "loveui/util/test"
require "loveui/util/class"
require "loveui/ui/widget"
require "loveui/ui/context"

button = class(widget)

--- A clickable button that invokes a function on click.
-- @param tags A string of whitespaced separated tags
-- @param args A table of key-value object attributes
function button:init(tags, args)
  button.__super.init(self, tags, args)
  
  -- Add button tag.
  self:add("ui.button")
  
  -- Add button handlers
  self:onmouseenter(function(self, x, y)
    -- set own appearance.
  end)
  
  local label = self.attributes.value;
end

function button:drawcontent()
  color(self.style.styles.color)
  assert(self.attributes.value, "button requires `value` attribute set.")
  text(self.attributes.value, 11, 11)
end

test("ui.button", function()
    local bt = button("mytag", { value = "Okay" })
    
    assert(bt.attributes.value == "Okay", 
      [[bt.attributes.value == "Okay"]])
    
    assert(bt:owns("mytag"), [[bt:owns("mytag")]])
    
    assert(bt:owns("ui.button"), [[bt:owns("ui.button")]])
    return true
  end)

test("ui.button", function()
    local c = context()
    local w, s = c:add(button("t"), 
      style("t", {left = 50, top = 70, width = 100, height = 100}))
    local clicked = false
    w:onmousedown(function(w, x, y, button)
      clicked = true
    end)
    c:mousepressed(50, 70, "l")
    assert(clicked == true, [[clicked == true]])
    clicked = false
    c:mousepressed(50, 69, "l")
    assert(clicked == false, [[clicked == false]])
    return true
  end)

return ui