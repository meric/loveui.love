--- loveui is a love2d library to provide resuable GUI widgets to love2d 
-- developers.
module ("ui", package.seeall)

require "loveui/util/test"
require "loveui/util/class"
require "loveui/ui/widget"
require "loveui/ui/context"

label = class(widget)

--- A checkbox that the user turn on or off.
-- @param tags A string of whitespaced separated tags
-- @param args A table of key-value object attributes
function label:init(tags, args)
  label.__super.init(self, tags, args)
  
  -- Add checkbox tag.
  self:add("ui.label")
end

function label:size()
  local value = tostring(self.attributes.value)
  return textwidth(value), textheight()
end

function label:drawcontent()
  color(self.style.styles.color)
  local height = self.style.styles.height
  local width = self.style.styles.width
  text(tostring(self.attributes.value), 0, 0)
end

return ui