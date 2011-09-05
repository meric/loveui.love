--- loveui is a love2d library to provide resuable GUI widgets to love2d 
-- developers.
module ("ui", package.seeall)

require "loveui/util/test"
require "loveui/util/class"
require "loveui/ui/widget"
require "loveui/ui/style"


_000 = {0,0,0,255}
_555 = {85,85,85,255}
_999 = {153,153,153,255}
_bbb = {187,187,187,255}
_ccc = {204,204,204,255}
_ddd = {221,221,221,255}
_eee = {238,238,238,255}
_fff = {255,255,255,255}

-- Default style is supposed to apply to all widgets.
local defaultstyle = style("",
{
  -- Location (relative)
  left = 0, -- Any number of pixels.
  top = 0, -- Any number of pixels.

  -- Size
  width = "auto", -- Any number or "auto".
  height = "auto",-- Any number or "auto".
  
  -- Visibility
  opacity = 1, -- 0 to 1, 1 means opaque.
  
  -- Display
  display = "inline", -- none|inline. Use none to disable widget

  -- Text
  color = {0,0,0,255}, -- RGBA, RGBA is 0-255.
  fontfamily = "arial", -- "arial" only.
  fontsize = 16, -- Any number.
  fontweight = "normal", -- "normal" or "bold".
  
  -- Space
  padding = 0, -- Any number of pixels.
  margin = 0, -- Any number of pixels.
  
  -- Background
  backgroundcolor = {255,255,255,255}, -- RGBA, RGBA is 0-255.
  backgroundimagesource = "none", -- "none" or a file path
  backgroundrepeat = "repeat", -- repeatx|repeaty|repeat|norepeat
  backgroundposition = {0,0}, -- {X, Y} offset of background image.
  font = newfont("loveui/font/VeraBd.ttf", 14),
  
  -- Border
  borderwidth = 0, -- Any number
  borderradius = 0, -- Any number
  bordercolor = {0,0,0,255}, -- RGBA, RGBA is 0-255.
  borderimagesource = "none", -- "none" or a file path
  borderimagerepeat = "repeat", -- stretch|repeat|round
  bordercornerimage = "none", -- "none" or a file path
  
  selectioncolor = {0,0,0,24}
})

local defaultbutton = ui.style("ui.button", {
  bordercolor=_ccc,
  backgroundcolor=_eee,
  borderradius=0,
  borderwidth=1,
})
local defaultbuttonhover = ui.style("ui.button ui.hover", {
  --backgroundcolor={187,187,187,255},
  bordercolor=_999,
  borderwidth=1
})
local defaultbuttonpressed = ui.style("ui.button ui.pressed", {
  backgroundcolor=_ddd,
})
local defaulttextfield = ui.style("ui.textfield", {
  bordercolor=_ccc,
  backgroundcolor=_fff,
  --borderradius=3,
  borderwidth=1,
})
local defaulttextfieldhover = ui.style("ui.textfield ui.hover", {
  --backgroundcolor={187,187,187,255},
  bordercolor=_999,
  borderwidth=1
})
local defaulttextfieldfocus = ui.style("ui.textfield ui.focus", {
  bordercolor=_555,
  borderwidth=1
})

local defaultcheckbox= ui.style("ui.checkbox", {
  bordercolor=_555,
  backgroundcolor=_fff,
  color=_555,
  borderwidth=1,
})

local defaultlabel= ui.style("ui.label", {
  bordercolor=_000,
  backgroundcolor=_fff,
  color=_000,
  borderwidth=0,
})

context = class(widget)

--- Initiates a context instance.
-- The context is a super-widget to which all other widgets are added 
-- to. It has :update(dt), :draw(), :keypressed(key, unicode), 
-- :keyreleased(key, unicode), :mousepressed(x, y, button), 
-- :mousereleased(x, y, button) which needs to be called by the love 
-- program at the appropriate places to feed input into the widgets.
-- @param tags A string of whitespaced separated tags
-- @param args A table of key-value object attributes
function context:init(tags, args)
  context.__super.init(self, tags, args)
  -- Add the default style that applies to all widgets.
  self:add(defaultstyle, 
          defaultbutton, 
          defaultbuttonhover,
          defaultbuttonpressed,
          defaulttextfield,
          defaulttextfieldhover,
          defaulttextfieldfocus,
          defaultcheckbox,
          defaultlabel)
end

function context:update(dt)
  context.__super.update(self, dt)
end

function context:draw()
  local t = stash()
  context.__super.draw(self)
  unstash(t)
end

test("ui.context.mousepressed", function()
    local c = context()
    c:update(0)
    local w, s = c:add(widget("t"), 
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

test("ui.context.mousereleased", function()
    local c = context()
    local w, s = c:add(widget("t"), 
      style("t", {left = 50, top = 70, width = 100, height = 100}))
    local clicked = false
    w:onclick(function(w, x, y, button)
      clicked = true
    end)
    c:mousepressed(51, 71, "l")
    assert(c.focused == w, "c.focused == w")
    c:mousereleased(50, 70, "l")
    assert(clicked == true, [[clicked == true]])
    clicked = false
    c:mousepressed(50, 50, "l")
    assert(c.focused == c, "c.focused == c")
    c:mousepressed(50, 70, "l")
    c:mousereleased(50, 50, "l")
    assert(clicked == false, [[clicked == false]])
    return true
  end)

return ui