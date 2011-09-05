--- loveui is a love2d library to provide resuable GUI widgets to love2d 
-- developers.
module ("ui", package.seeall)

require "loveui/util/test"
require "loveui/util/class"
require "loveui/util/operator"

widget = class()

--- Initiates a widget instance.
-- The widget class is meant to be subclassed by other widgets and is 
-- not designed to be instantiated.
-- Subclasses are supposed to read args from self.attributes.
-- @param tags A string of whitespaced separated tags
-- @param args A table of key-value object attributes
function widget:init(tags, args)
  -- Arguments can be in any order.
  if type(tags) == "table" or type(args) == "string" then
    args, tags = tags, args
  end
  
  checktype("tags", tags, "number", "string", "nil")
  checktype("args", args, "table", "nil")
  
  -- Attributes
  self.attributes = {}
  
  -- Copy args to attributes
  for k, v in pairs(args or {}) do
    self.attributes[k] = v
  end
  
  -- Tags that identify this widget.
  self.tags = sorttags(tags)
  
  -- Styles that apply to child widgets.
  self.styles = {}
  
  -- Child widgets.
  self.content = {}
  
  -- Subwidget that is being interacted with.
  self.focused = nil
  
  -- Actions.
  self.actions = {
    click = chain(), 
    change = chain(), 
    focus = chain(), 
    blur = chain(), 
    mousedown = chain(), 
    mouseenter = chain(), 
    mouseleave = chain(), 
    keypress = chain(), 
    keyup = chain(), 
    keydown = chain()
  }
  
  -- Parent widget.
  self.owner = nil
  
  -- Cache for current style.
  self.style = nil
  
  -- Compute current style.
  self:computestyle()
  
  -- Cache of current bounds. (relative)
  self.bounds = nil
  
  -- Cache of current bounds. (absolute)
  self.area = nil
  
  self.visible = nil
  
  -- Compute current bounds
  self:computebounds()
  
  -- Compute current bounds
  self:computearea()
end

--- Add a style to the widget, so all widget that matches the style's 
-- tags will have that style applied.
-- @param st The style to be added.
function widget:addstyle(st)
  -- Style can only have one owner.
  if st.owner then
    st.owner:removestyle(st)
  end
  
  -- self.styles[st.tags] = st -- Replace old style.
  -- later styles have precedence
  table.insert(self.styles, st)
  st.owner = self
  return st
end

--- Removes a style from the widget that was previously added.
-- @param st The style to be removed.
function widget:removestyle(st)
  if not self:owns(st) then
    error("A widget cannot remove a style it does not own.")
  end
  for i, v in ipairs(self.styles) do
    if v == st then
      self.styles[i] = nil
      break
    end
  end
  st.owner = nil
  return st
end

--- Add a tag to the widget, so only styles with tags that this widget 
-- matches will be applied to this widget.
-- @param t The tag to be added.
function widget:addtag(t)
  t = tostring(t)
  -- Must be non-empty string.
  if #t > 0 then
    -- If tag already matches then nothing needs to be done.
    if not self:match(t) then
      -- Append tag to current tags.
      t = self.tags .. " ".. t
      self.tags = sorttags(t)
    end
  end
  return t
end

function widget:removetag(t)
  t = tostring(t)
  if not self:owns(t) then
    error("A widget cannot remove a tag it does not own.")
  end
  if #t > 0 then
    if self:match(t) then
      local tag, count = " "..self.tags.." "
      tag, count = string.gsub(tag, t, "");
      self.tags = sorttags(tag)
    end
  end
end

--- Add a widget to the widget. 
-- @param w The widget to be added.
function widget:addwidget(w)
  -- Widget can have only one owner.
  if w.owner then
    w.owner:removewidget(w)
  end
  table.insert(self.content, w)
  w.owner = self
end

--- Removes a widget from the widget that was previously added.
-- @param w The widget to be removed.
function widget:removewidget(w)
  if not self:owns(w) then
    error("A widget cannot remove a widget it does not own.")
  end
  for i, v in ipairs(self.content) do
    if v == w then
      table.remove(self.content, i);
      break;
    end
  end
  w.owner = nil
  return w
end

--- Add elements to the widget.
-- An element could be <code>widget</code> or <code>style</code> or tag.
-- @param ... <code>widget</code>s or <code>style</code>s or a string. 
function widget:add(...)
  for i, elt in ipairs({...}) do
    if type(elt) ~= "table" then
      self:addtag(elt)
    elseif elt.__class == style then
      self:addstyle(elt)
    else
      self:addwidget(elt)
    end
  end
  -- Compute current style for the sub-widgets
  if self.owner then
    self.owner:computestyle()
    self.owner:computebounds()
    self.owner:computearea()
  end
  self:computestyle()
  self:computearea()
  return ...
end

--- Checks whether an element was added to a widget and not removed.
-- @param elt The widget or style.
-- @return Returns <code>true</code> if the element was added to the 
-- widget and not removed.
function widget:owns(...)
  local results = {}
  for i, elt in ipairs({...}) do
    if type(elt) ~= "table" then
      -- Check if owns the tag.
      table.insert(results, self:match(elt))
    else
      -- Check if owns the style or element
      table.insert(results, elt.owner == self)
    end
  end
  return unpack(results)
end

--- Remove elements from the widget.
-- An element could be <code>widget</code> or <code>style</code> or tag.
-- @param ... <code>widget</code>s or <code>style</code>s or a string. 
function widget:remove(...)
  for i, elt in ipairs({...}) do
    if type(elt) ~= "table" then
      self:removetag(elt)
    elseif elt.__class == style then
      self:removestyle(elt)
    else
      self:removewidget(elt)
    end
  end
  self:computestyle()
  self:computebounds()
  self:computearea()
  if self.owner then
    self.owner:computestyle()
    self.owner:computebounds()
    self.owner:computearea()
  end
  return ...
end

--- Gets all sub-widgets of the widget with the matching tags.
-- Excludes the widget being called even if it matches the tags 
-- specified in the argument.
-- @param tags A string of whitespaced separated tags
-- @return A table containing the matching widgets
function widget:get(tags)
  local widgets = {}
  for i, v in ipairs(self.content) do
    if v:match(tags) then
      table.insert(widgets, v)
      for j, w in ipairs(v:get(tags)) do
        table.insert(widgets, w)
      end
    end
  end
  return widgets
end

--- Checks whether the widget matches the specified tags.
-- @param tags A string of whitespaced separated tags
-- @return Returns <code>true</code> if the widget matches the tags.
function widget:match(tags)
  return matchtags(self.tags, tags)
end

--- Copies all key-value pairs into the widgets' attributes field.
-- @param attrs A table containing key-value pairs
function widget:apply(attrs)
  for k, v in pairs(attrs) do
    self.attributes[k] = v
  end
end

local function numberof(str, s)
  local n = 0
  for w in str:gmatch(s) do
    n = n + 1
  end
  return n
end

--- Compute the current style for a widget, and all sub-widgets.
-- This function is expensive, do not call every frame.
-- @return The current style
function widget:computestyle()
  -- Compute style for sub-widgets to get bounds.
  for i, v in ipairs(self.content) do
    v:computestyle()
  end
  local styles ={}
  local owner = self.owner
  while owner do
    for i, v in ipairs(owner.styles) do
      if self:match(v.tags) then
        for k, w in pairs(v.styles) do
          styles[k] = w
        end
      end
    end
    owner = owner.owner
  end
  self.style = style(self.tags, styles)
  local this = self.style.styles
  self:computebounds()
  local left, top, width, height = unpack(self.bounds)
  this.width = width
  this.height = height
  
  local function constrain(name, val)
    if this[name] then
      this[name] = math.min(val, this[name])
    end
  end
  local min = math.min(width/2, height/2)
  if this.borderradius then
    constrain("bordertopleftradius", min + 
      math.min(this.borderleftwidth, this.bordertopwidth))
    constrain("bordertoprightradius", min + 
      math.min(this.borderleftwidth, this.bordertopwidth))
    constrain("borderbottomleftradius", min + 
      math.min(this.borderleftwidth, this.borderbottomwidth))
    constrain("borderbottomrightradius", min + 
      math.min(this.borderleftwidth, this.borderbottomwidth))
  end
  this.borderleftwidth = this.borderleftwidth or 0
  this.bordertopwidth = this.bordertopwidth or 0
  this.borderrightwidth = this.borderrightwidth or 0
  this.borderbottomwidth = this.borderbottomwidth or 0
  this.bordertopleftradius = this.bordertopleftradius or 0
  this.bordertoprightradius = this.bordertoprightradius or 0
  this.borderbottomleftradius = this.borderbottomleftradius or 0
  this.borderbottomrightradius = this.borderbottomrightradius or 0
  -- Compute style for sub-widgets to update with this widget's style.
  for i, v in ipairs(self.content) do
    v:computestyle()
  end
  return self.style
end

--- Sets the on click handler for the widget.
-- A click occurs when a mouse press and a mouse release occurs on the 
-- same widget's bounds.
-- @param fn The handler function. 
-- Arguments to <code>fn</code> are (self, x, y, button).
function widget:onclick(fn)
  self.actions.click:add(fn)
  return self
end

--- Sets the on change handler for the widget.
-- A change occurs when a widget's user value changes.
-- It is up to the widget as to when the handler is called.
-- @param fn The handler function.
-- Arguments to <code>fn</code> are (self, oldvalue, newvalue).
function widget:onchange(fn)
  self.actions.change:add(fn)
  return self
end

--- Sets the on focus handler for the widget.
-- A change occurs when a widget has been focused by mouse or tab.
-- @param fn The handler function.
-- Arguments to <code>fn</code> are (self).
function widget:onfocus(fn)
  self.actions.focus:add(fn)
  return self
end

--- Sets the on lost focus handler for the widget.
-- A change occurs when a widget has lost focus by mouse or tab.
-- @param fn The handler function.
-- Arguments to <code>fn</code> are (self).
function widget:onblur(fn)
  self.actions.blur:add(fn)
  return self
end

--- Sets the on mousedown handler for the widget.
-- @param fn The handler function.
-- Arguments to <code>fn</code> are (self, x, y, button).
function widget:onmousedown(fn)
  self.actions.mousedown:add(fn)
  return self
end

--- Sets the on mouseenter handler for the widget.
-- A mouseenter event is triggered when the mouse moves within the 
-- bounds of a widget.
-- @param fn The handler function.
-- Arguments to <code>fn</code> are (self, x, y).
function widget:onmouseenter(fn)
  self.actions.mouseenter:add(fn)
  return self
end

--- Sets the on mouseleave handler for the widget.
-- A mouseleave event is triggered when the mouse moves out of the 
-- bounds of a widget.
-- @param fn The handler function.
-- Arguments to <code>fn</code> are (self, x, y).
function widget:onmouseleave(fn)
  self.actions.mouseleave:add(fn)
  return self
end

--- Sets the on keypress handler for the widget.
-- A keypress event is triggered when a key is held and released while 
-- the element is focused.
-- @param fn The handler function.
-- Arguments to <code>fn</code> are (self, key, unicode).
function widget:onkeypress(fn)
  self.actions.keypress:add(fn)
  return self
end

--- Sets the on keyup handler for the widget.
-- A keyup event is triggered when a key is released while the 
-- element is focused.
-- @param fn The handler function.
-- Arguments to <code>fn</code> are (self, key, unicode).
function widget:onkeyup(fn)
  self.actions.keyup:add(fn)
  return self
end

--- Sets the on keydown handler for the widget.
-- A keydown event is triggered when a key is helf while the 
-- element is focused.
-- @param fn The handler function.
-- Arguments to <code>fn</code> are (self, key, unicode).
function widget:onkeydown(fn)
  self.actions.keydown:add(fn)
  return self
end

--- Calculates the left, top, width, height. Left, top are relative if 
-- the computed style's <code>position</code> attribute is 
-- <code>"relative"</code>; It is absolute if the <code>position</code> 
-- attribute is <code>"absolute"</code>.
-- This method should be fast.
function widget:computebounds()
  local this = self.style.styles;
  
  if font() == nil then
    font(self.style.styles.font)
  end
  
  local width, height = this.width or "auto", this.height or "auto";
  
  -- Take care of "auto" size.
  local w, h = self:size();
  if width == "auto" and height == "auto" then
    width, height = w, h
  elseif width == "auto" then
    width = w
  elseif height == "auto" then
    height = h
  end
  
  local left, top = this.left, this.top
  
  -- Convert right, bottom to left, top if necessary
  if not left and this.right then
    left = this.right - width
  elseif not left and not this.right then
    left = 0
  end
  
  if not top and this.bottom then
    top = this.bottom - height
  elseif not top and not this.bottom then
    top = 0
  end
  
  self.bounds = {left, top, width, height}
  
  -- Compute bounds for sub-widgets.
  for i, v in ipairs(self.content) do
    v:computebounds()
  end
  
  return {left, top, width, height}
end

--- Calculates the left, top, width, height, taking into account borders. Left, 
-- top are absolute.
-- This method should be fast.
function widget:computearea()
  if not self.bounds then self.computebounds() end
  local lwidth = (self.style.styles.borderleftwidth or 0)
  local rwidth = (self.style.styles.borderrightwidth or 0)
  local ewidth = lwidth + rwidth
  local theight = (self.style.styles.bordertopwidth or 0)
  local bheight = (self.style.styles.borderbottomwidth or 0)
  local eheight = theight + bheight 
  
  if not self.owner then 
    self.area = {unpack(self.bounds)}
    self.area[1] = self.area[1] - lwidth
    self.area[2] = self.area[2] - theight
    self.area[3] = self.area[3] + ewidth
    self.area[4] = self.area[4] + eheight
      -- Compute bounds for sub-widgets.
    for i, v in ipairs(self.content) do
      v:computearea()
    end
    return self.area 
  end
    
  local area = {unpack(self.bounds)}
  area[1] = area[1] - lwidth
  area[2] = area[2] - theight
  area[3] = area[3] + ewidth
  area[4] = area[4] + eheight
  if not self.owner.area then return self.owner:computearea() end
  area[1] = area[1] + self.owner.area[1]
  area[2] = area[2] + self.owner.area[2]
  area[3] = math.min(math.max(self.owner.area[3]-self.bounds[1], 0), 
                     self.bounds[3]+ewidth)
  area[4] = math.min(math.max(self.owner.area[4]-self.bounds[2], 0), 
                     self.bounds[4]+eheight)
  self.area = area
  
  -- Compute bounds for sub-widgets.
  for i, v in ipairs(self.content) do
    v:computearea()
  end
  return area
end

--- Override to calculate a default size for the widget, when its 
-- style's  <code>width</code> and <code>height</code> attributes are 
-- set to <code>"auto"</code>.
-- This method should be fast.
function widget:size()
  local size = {0, 0}
  for i, v in ipairs(self.content) do
    local cw, ch = v:size()
    local ewidth = (v.style.styles.borderleftwidth or 0) + 
                 (v.style.styles.borderrightwidth or 0)
    local eheight = (v.style.styles.bordertopwidth or 0) + 
                    (v.style.styles.borderbottomwidth or 0) 
    size[1] = math.max(size[1], v.bounds[1] + v.bounds[3] + ewidth, 
                       v.bounds[1] + cw + ewidth)
    size[2] = math.max(size[2], v.bounds[2] + v.bounds[4] + eheight, 
                       v.bounds[2] + ch + eheight)
  end
  return unpack(size);
end

--- Returns true if the bounds of the widget contains point x, y.
-- @param x The x coordinate.
-- @param y The y coordinate.
function widget:contains(x, y)
  checktype("x", x, "number")
  checktype("y", y, "number")
  if not self.bounds then
    self:computebounds()
  end
  local left, top, width, height = unpack(self.bounds)
  local aleft, atop, awidth, aheight = unpack(self.area)
  return pointinrect({x, y}, {left, top, awidth, aheight})
end

--- Update the widget, and sub-widgets
function widget:update(dt)
  for k, v in ipairs(self.content) do
    v:update(dt)
  end
  if self.owner then
    local mx, my = love.mouse.getPosition()
    local bx, by = unpack(self.bounds)
    local wx, wy = unpack(self.area)
    wx, wy = wx - bx, wy - by
    if not self:match("ui.hover") and self:contains(mx-wx, my-wy) then
      self:mouseenter(mx, my)
    end
    if self:match("ui.hover") and not self:contains(mx-wx, my-wy) then
      self:mouseleave(mx, my)
    end
  end
end

--- Switch focus to self or a subwidget and invoke to appropriate 
-- handlers.
-- @param w The widget to focus. Should be a subwidget or self but this 
-- is not checked by the function.
function widget:focus(w)
  if self.focused ~= w then
    if self.focused then
      self.focused.actions.blur()
    end
    if self.focused then
      self.focused:remove("ui.focus")
    end
    self.focused = w
    if self.focused then
      self.focused:add("ui.focus")
      self.focused.actions.focus()
    end
  end
end

function widget:enabled()
  local this = self.style.styles
  return this.display ~= "none" and self.attributes.disabled ~= true
end

--- Send mouseleave event to widget, and/or sub-widgets.
-- @param x The x coordinate where mouse left.
-- @param y The y coordinate where mouse left.
-- @param button The mouse button pressed.
function widget:mouseleave(x, y)
  if not self.bounds then
    self:computebounds()
  end
  local wx, wy, ww, wh = unpack(self.bounds)
  for i, w in ipairs(self.content) do
    -- Go through widgets from the latest added first.
    w = self.content[#self.content-i+1];
    local this = w.style.styles
    -- x - wx, y - wy are mouse coordinates relative to the `w`.
    if w:enabled() and w:contains(x - wx, y - wy) and w:match("ui.hover") and 
       w:mouseleave(x - wx, y - wy) then
      return true 
    end
  end
  self:remove("ui.hover")
  if self:match("ui.pressed") then
    self:remove("ui.pressed")
  end
  self.actions.mouseenter(self, x, y)
  return #self.actions.mouseenter > 0 or true
end


function widget:mouseenter(x, y)
  if not self.bounds then
    self:computebounds()
  end
  local wx, wy, ww, wh = unpack(self.bounds)
  for i, w in ipairs(self.content) do
    -- Go through widgets from the latest added first.
    w = self.content[#self.content-i+1];
    local this = w.style.styles
    -- x - wx, y - wy are mouse coordinates relative to the `w`.
    if w:enabled() and w:contains(x - wx, y - wy) and 
      w:mouseenter(x - wx, y - wy) then
      return true 
    end
  end
  self:add("ui.hover")
  if self:enabled() then
    self.actions.mouseenter(self, x, y)
  end
  return #self.actions.mouseenter > 0 or true
end

--- Send mousepressed event to widget, and/or sub-widgets.
-- @param x The x coordinate.
-- @param y The y coordinate.
-- @param button The mouse button pressed.
function widget:mousepressed(x, y, button)
  if not self.bounds then
    self:computebounds()
  end
  
  local wx, wy, ww, wh = unpack(self.bounds)
  if self.owner then 
    self.owner:focus(self)
  else 
    self:focus(self) 
  end
  for i, w in ipairs(self.content) do
    -- Go through widgets from the latest added first.
    w = self.content[#self.content-i+1];
    local this = w.style.styles
    -- x - wx, y - wy are mouse coordinates relative to the `w`.
    if w:enabled() and w:contains(x - wx, y - wy) and 
       w:mousepressed(x - wx, y - wy, button) then
      return true 
    end
  end
  self:add("ui.pressed")
  if self:enabled() then
    self.actions.mousedown(self, x - wx, y - wy, button)
  end
  return #self.actions.mousedown > 0 or 
         #self.actions.focus > 0 or
         #self.actions.click > 0
end

--- Send mousereleased event to the focused widget.
-- A mouse release event only occurs when the mouse press was sent to 
-- the same widget.
-- @param x The x coordinate.
-- @param y The y coordinate.
-- @param button The mouse button released.
function widget:mousereleased(x, y, button)
  if not self.bounds then self:computebounds() end
  local wx, wy, ww, wh = unpack(self.bounds)
  if self.focused ~= nil and self.focused ~= self then
    if self.focused:enabled() and self.focused:contains(x - wx, y - wy) and
        self.focused:mousereleased(x - wx, y - wy, button)  then
       return true
    end
  end
  if self:match("ui.pressed") then
    self:remove("ui.pressed")
    if self:enabled() then
      self.actions.click(self, x-wx, y-wy, button)
    end
    return #self.actions.click > 0
  end
end

function widget:keypressed(key, unicode)
  if self.focused ~= self and self.focused then
    self.focused:keypressed(key, unicode)
  end
  if self:enabled() then
    self.actions.keydown(self, key, unicode)
  end
end

function widget:keyreleased(key, unicode)
  if key == "tab" then
    if not self.focused or self.focused == self then
      self:focus(self.content[1])
    else
      for i, v in ipairs(self.content) do
        if self.focused == v then
          self:focus(self.content[i+1])
          break
        end
      end
    end
  else
    if self.focused ~= self and self.focused then
      self.focused:keyreleased(key, unicode)
    end
    if self:enabled() then
      self.actions.keyup(self, key, unicode)
    end
  end
  
end

--- Draws the widget and any sub-widget within the widget.
function widget:draw()
  -- Get current style
  
  if self.style == nil then
    self.style = self:computestyle()
  end
  if not self.bounds then
    self:computebounds()
  end
  if not self.area then
    self:computearea()
  end
  
  font(self.style.styles.font)
  
  -- Calculate the widget's bounds.
  local bounds = self.bounds
  local left, top, width, height = unpack(bounds)
  push()
  translate(left, top)
  local st = self.style
  if self.owner then
    scissor(unpack(self.area))
    -- Draw background
    self:drawbackground(st)
    -- Draw content
    self:drawcontent(st)
  end
  
  -- Draw sub-widgets
  push()
  for i, v in ipairs(self.content) do
    v:draw()
  end
  pop()
  
  -- Draw border
  if self.owner then
    self:drawborder(st)
  end
  pop()
end

-- Draw a border part
-- width1 width of border
-- width2 width of adjacent border
-- radius border radius of corner between this border and adjacent
-- height half height of widget
local function borderpart(width1, width2, radius, height)
  local outerleft, outertop = 0, 0
  local innerleft, innertop = width1, width2
  local lmidtop = math.min(outertop + radius, innertop + height)
  local tmidleft = math.min(outerleft + radius, width1)
  -- side
  polygon("fill",
    outerleft, lmidtop,
    tmidleft, lmidtop,
    innerleft, math.max(innertop, lmidtop),
    innerleft, innertop + height,
    outerleft, innertop + height)
  -- corner
  if radius > 0 then
    local dx, dy = innerleft - tmidleft, 
      math.max(innertop - lmidtop, 0)
    local length = math.atan2(dy, dx)-0.001
    if dx == 0 or dy == 0 then 
      length = math.pi/4 
    end
    arc("fill",
      radius+1, radius+1, 
      math.pi, radius+1, 
      math.min(width1, radius+1), 
      length+0.01)
  end
end
-- Draws a border
-- wid width of border
-- awid1 first adjacent width
-- rad1 first radius
-- awid2 second adjacent width
-- rad2 second radius
-- height height of widget
local function border(wid, awid1, rad1, awid2, rad2, height)
  borderpart(wid, awid1, rad1, height/2)
  push()
  translate(0, height + awid1 + awid2)
  rotate(math.pi)
  scale( -1, 1 )
  borderpart(wid, awid2, rad2, height/2)
  pop()
end

--- Draw the border of the widget.
-- Can be overridden by subclasses.
-- @param bounds The bounding rectangle of the widget.
-- The border will reside on the outside of bounds.
-- @param st The computed style to follow.
function widget:drawborder(st)
-- TODO Take into account the following style attributes
--  borderimagesource = "none", -- "none" or a file path
--  borderimagerepeat = "repeat", -- stretch|repeat|round
--  bordercornerimage = "none" -- "none" or a file path

  local left, top, width, height = unpack(self.bounds)
  local this = st.styles
  local right, bottom = width, height
    
  
  if this.borderleftwidth > 0  then
    color(unpack(this.borderleftcolor))
    push()
    translate(0 - this.borderleftwidth, 
      0 - this.bordertopwidth)
    border(this.borderleftwidth,
      this.bordertopwidth, this.bordertopleftradius, 
      this.borderbottomwidth, this.borderbottomleftradius, 
      height)
    pop()
  end
  if this.bordertopwidth > 0 then
    color(unpack(this.bordertopcolor))
    push()
    translate(0 + this.borderrightwidth + width, 
      0 - this.bordertopwidth)
    rotate(math.pi/2)
    border(this.bordertopwidth,
      this.borderrightwidth, this.bordertoprightradius, 
      this.borderleftwidth, this.bordertopleftradius, 
      width)
    pop()
  end
  if this.borderbottomwidth > 0 then
    color(unpack(this.borderbottomcolor))
    push()
    translate(right + this.borderrightwidth, 
      bottom + this.borderbottomwidth)
    rotate(math.pi/2)
    scale(-1, 1)
    border(this.borderbottomwidth,
      this.borderrightwidth, this.borderbottomrightradius, 
      this.borderleftwidth, this.borderbottomleftradius, 
      width)
    pop()
  end
  if this.borderrightwidth > 0 then
    color(unpack(this.borderrightcolor))
    push()
    translate(right + this.borderrightwidth, 
      0 - this.bordertopwidth)
    scale(-1, 1)
    border(this.borderrightwidth,
      this.bordertopwidth, this.bordertopleftradius, 
      this.borderbottomwidth, this.borderbottomleftradius, 
      height)
    pop()
  end
end

--- Draw the background of the widget.
-- Can be overridden by subclasses.
-- @param bounds The bounding rectangle of the widget.
-- The background will lie on or within the bounds
-- @param st The computed style to follow.
function widget:drawbackground(st)
  local this = st.styles
  local left, top, width, height = unpack(self.bounds)
  local right, bottom = width, height
  color(this.backgroundcolor)
  -- draw corner, then use polygon.
  local leftradius = math.max(this.bordertopleftradius, 
                              this.borderbottomleftradius)
  local rightradius = math.max(this.bordertoprightradius, 
                               this.borderbottomrightradius)
  local topradius = math.max(this.bordertopleftradius, 
                             this.bordertoprightradius)
  local bottomradius = math.max(this.borderbottomleftradius, 
                                this.borderbottomrightradius)
  local leftrw = math.max(leftradius - this.borderleftwidth, 0)
  local rightrw = math.max(rightradius - this.borderrightwidth, 0)
  local toprw = math.max(topradius - this.bordertopwidth, 0)
  local bottomrw = math.max(bottomradius - this.borderbottomwidth, 0)
  rectangle("fill", 0+leftrw, 
                    0+toprw, 
                    width-(leftrw+rightrw), 
                    height-(toprw+bottomrw))
  
 
  if this.borderleftwidth > 0  then
  push()
  translate(0 - this.borderleftwidth, 0 - this.bordertopwidth)
  border(leftrw + this.borderleftwidth,
    toprw, this.bordertopleftradius-0.5, 
    bottomrw, this.borderbottomleftradius-0.5, 
    height + this.bordertopwidth + this.borderbottomwidth - (toprw+bottomrw))
  pop()
  end
  if this.bordertopwidth > 0  then
  push()
  translate(0 + this.borderrightwidth + width, 0 - this.bordertopwidth)
  rotate(math.pi/2)
  border(leftrw + this.bordertopwidth,
    rightrw, this.bordertoprightradius-0.5, 
    leftrw, this.bordertopleftradius-0.5, 
    width + this.borderleftwidth + this.borderrightwidth-(leftrw+rightrw))
  pop()
  end
  if this.borderbottomwidth > 0  then
  push()
  translate(right + this.borderrightwidth, bottom + this.borderbottomwidth)
  rotate(math.pi/2)
  scale(-1, 1)
  border(bottomrw + this.borderbottomwidth,
    rightrw, this.borderbottomrightradius-0.5, 
    leftrw, this.borderbottomleftradius-0.5, 
    width + this.borderleftwidth + this.borderrightwidth-(leftrw+rightrw))
  pop()
  end
  if this.borderrightwidth > 0  then
  push()
  translate(right + this.borderrightwidth, 0 - this.bordertopwidth)
  scale(-1, 1)
  border(rightrw + this.borderrightwidth,
    toprw, this.bordertopleftradius-0.5, 
    bottomrw, this.borderbottomleftradius-0.5, 
    height + this.bordertopwidth + this.borderbottomwidth - (toprw+bottomrw))
  pop()
  end
end

--- Override to draw the content of the widget.
-- To be overridden by subclasses.
-- @param bounds The bounding rectangle of the widget.
-- The background will lie on or within the bounds
-- @param st The computed style to follow.
function widget:drawcontent(st, width, height)
  
end

test("ui.widget", function()
    local parent = widget("parent")
    local child = parent:add(widget("child"))
    
    parent:update(0)
    
    assert(#parent:get("child") == 1, [[#parent:get("child") == 1]])
    
    local style = parent:add(
      style("child", {
        display="inline", 
        left = 10, 
        top = 10
      }))
    
    assert(parent:owns(style) == true, [[parent:owns(style) == true]])
    
    assert(child.style.styles.display == "inline", 
      [[child.style.styles.display == "inline"]])
    
    child:remove("child")
    assert(child.style.styles.display == nil, 
      [[child.style.styles.display == nil]])
    
    child:add("child")
    assert(child.style.styles.display == "inline",
      [[child.style.styles.display == "inline"]])
    
    local bounds = child:computebounds()
    -- Check left and top are both 10.
    assert(bounds[1] == 10 and bounds[2] == 10, 
      [[bounds[1] == 10 and bounds[2] == 10]])
    
    parent:remove(style)
    -- Check style was removed.
    assert(child.style.styles.display == nil,
      [[child.style.styles.display == nil]])
    
    assert(parent:owns(style) == false, [[parent:owns(style) == false]])
    
    bounds = child:computebounds()
    -- Check left and top are both 0
    assert(bounds[1] == 0 and bounds[2] == 0, 
      [[bounds[1] == 0 and bounds[2] == 0]])
      
    return true
  end)
