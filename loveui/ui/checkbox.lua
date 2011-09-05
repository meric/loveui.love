--- loveui is a love2d library to provide resuable GUI widgets to love2d 
-- developers.
module ("ui", package.seeall)

require "loveui/util/test"
require "loveui/util/class"
require "loveui/ui/widget"
require "loveui/ui/context"

checkbox = class(widget)

--- A checkbox that the user turn on or off.
-- @param tags A string of whitespaced separated tags
-- @param args A table of key-value object attributes
function checkbox:init(tags, args)
  checkbox.__super.init(self, tags, args)
  
  -- Add checkbox tag.
  self:add("ui.checkbox")
  
  self:onclick(function(self, x, y, button)
    self:toggle()
  end)
end


function checkbox:size()
  return 10, 10
end

function checkbox:toggle()
  local old = self.attributes.value
  if self.attributes.value then
    self.attributes.value = false
  else
    self.attributes.value = true
  end
  self.actions.change(self, old, self.attributes.value)
  return self.attributes.value
end

function checkbox:drawcontent()
  if self.attributes.value then
    local height = self.style.styles.height
    local width = self.style.styles.width
    color(self.style.styles.color)
    rectangle("fill", 1, 1, width-2, height-2)
  end
end

return ui