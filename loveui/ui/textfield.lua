--- loveui is a love2d library to provide resuable GUI widgets to love2d 
-- developers.
module ("ui", package.seeall)

require "loveui/util/test"
require "loveui/util/class"
require "loveui/ui/widget"
require "loveui/ui/context"

textfield = class(widget)

--- A textbox that the user can enter text into, select text, etc.
-- @param tags A string of whitespaced separated tags
-- @param args A table of key-value object attributes
function textfield:init(tags, args)
  textfield.__super.init(self, tags, args)
  
  -- Add textfield tag.
  self:add("ui.textfield")
  
  local text = self.attributes.value
end

test("ui.textfield", function()
    local tx = textfield("mytag", { value = "Okay" })
    
    assert(tx.attributes.value == "Okay", 
      [[tx.attributes.value == "Okay"]])
    
    assert(tx:owns("mytag"), [[tx:owns("mytag")]])
    
    assert(tx:owns("ui.textfield"), [[tx:owns("ui.textfield")]])
    return true
  end)

progress = class(widget)

--- A progress bar that displays the progress of an operation.
-- @param tags A string of whitespaced separated tags
-- @param args A table of key-value object attributes
function progress:init(tags, args)
  progress.__super.init(self, tags, args)
  
  -- Add progress tag
  self:add("ui.progress")
  
  local value = self.attributes.value
end

return ui