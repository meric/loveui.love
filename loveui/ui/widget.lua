--- loveui is a love2d library to provide resuable GUI widgets to love2d 
-- developers.
module ("ui", package.seeall)

require "loveui/util/test"
require "loveui/util/class"

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
  
  -- Attributes
  self.attributes = {}
  
  -- Copy args to attributes
  for k, v in pairs(args or {}) do
    self.attributes[k] = v
  end
  
  -- Parent widget.
  self.owner = nil
  
  -- Cache for current style.
  self.style = nil
  
  -- Compute current style.
  self:compute()
end

--- Add a style to the widget, so all widget that matches the style's 
-- tags will have that style applied.
-- @param st The style to be added.
function widget:addstyle(st)
  -- Style can only have one owner.
  if st.owner then
    st.owner:removestyle(st)
  end
  
  -- Possibly replace old style.
  self.styles[st.tags] = st
  st.owner = self
  
  -- Re-compute style for all subwidgets
  for i, v in ipairs(self.content) do
    if v:match(st.tags) then
      v:compute()
    end
  end
  return st
end

--- Removes a style from the widget that was previously added.
-- @param st The style to be removed.
function widget:removestyle(st)
  if not self:owns(st) then
    error("A widget cannot remove a style it does not own.")
  end
  self.styles[st.tags] = nil
  st.owner = nil
  self:compute()
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
  -- Re-compute style.
  self:compute()
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
  self:compute()
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
  -- Compute the style for the sub-widget.
  w:compute()
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

--- Compute the current style for a widget, and all sub-widgets.
-- This function is expensive, do not call every frame.
-- @return The current style
function widget:compute()
  local owner = self.owner
  local styles ={}
  while owner do
    for i, v in pairs(owner.styles) do
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
  local left, top, width, height = self:bounds()
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
  -- Compute style for sub-widgets.
  for i, v in ipairs(self.content) do
    v:compute()
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
-- bounds of an event.
-- @param fn The handler function.
-- Arguments to <code>fn</code> are (self, x, y).
function widget:onmouseenter(fn)
  self.actions.mouseenter:add(fn)
  return self
end

--- Sets the on mouseleave handler for the widget.
-- A mouseleave event is triggered when the mouse moves out of the 
-- bounds of an event.
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
function widget:bounds()
  local this = self.style.styles;
  
  local width, height = this.width or "auto", this.height or "auto";
  
  -- Take care of "auto" size.
  local w, h = widget:size();
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
  return left, top, width, height
end

--- Override to calculate a default size for the widget, when its 
-- style's  <code>width</code> and <code>height</code> attributes are 
-- set to <code>"auto"</code>.
-- This method should be fast.
function widget:size()
  return 0, 0;
end

--- Returns true if the bounds of the widget contains point x, y.
-- @param x The x coordinate.
-- @param y The y coordinate.
function widget:contains(x, y)
  checktype("x", x, "number")
  checktype("y", y, "number")
  local left, top, width, height = self:bounds()
  return pointinrect({x, y}, {left, top, width, height})
end

--- Update the widget, and sub-widgets
function widget:update(dt)
  for k, v in ipairs(self.content) do
    v:update(dt)
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
    self.focused = w
    if self.focused then
      self.focused.actions.focus()
    end
  end
end

--- Send mousepressed event to widget, and/or sub-widgets.
-- @param x The x coordinate.
-- @param y The y coordinate.
-- @param button The mouse button pressed.
function widget:mousepressed(x, y, button)
  -- Accept left button clicks only.
  if button ~= "l" then
    return
  end
  local wx, wy, ww, wh = self:bounds()
  for i, w in ipairs(self.content) do
    -- Go through widgets from the latest added first.
    w = self.content[#self.content-i+1];
    local this = w.style.styles
    -- x - wx, y - wy are mouse coordinates relative to the `w`.
    if this.display~="none" and w:contains(x - wx, y - wy) then
      w:mousepressed(x - wx, y - wy, button)
      -- Consider allow actions to refuse widger to blur??
      self:focus(w)
      return
    end
  end
  local r = {self.actions.mousedown(self, x, y, button)}
  self:focus(self)
end

--- Send mousereleased event to the focused widget.
-- A mouse release event only occurs when the mouse press was sent to 
-- the same widget.
-- @param x The x coordinate.
-- @param y The y coordinate.
-- @param button The mouse button released.
function widget:mousereleased(x, y, button)
  if button ~= "l" then
    return false
  end
  local wx, wy, ww, wh = self:bounds()
  if self.focused ~= nil then
    if self.focused:contains(x - wx, y - wy) then
      self.focused.actions.click(self.focused, x, y, button)
    end
  end
end


function widget:keypressed(key, unicode)
  -- TODO
end

function widget:keyreleased(key, unicode)
  -- TODO
end

--- Draws the widget and any sub-widget within the widget.
function widget:draw()
  -- Get current style
  if self.style == nil then
    self.style = self:compute()
  end
  
  -- Calculate the widget's bounds.
  local bounds = {self:bounds()}
  local left, top = bounds[1], bounds[2]
  
  if self.owner then
    
    -- Draw background
    self:drawbackground(self.style, unpack(bounds))
    
    -- Draw border
    self:drawborder(self.style, unpack(bounds))
    
    -- Draw content
    self:drawcontent(self.style, unpack(bounds))
  end
  -- Draw sub-widgets
  push()
  translate(left, top)
  for i, v in ipairs(self.content) do
    v:draw()
  end
  pop()
end

--- Draw the border of the widget.
-- Can be overridden by subclasses.
-- @param bounds The bounding rectangle of the widget.
-- The border will reside on the outside of bounds.
-- @param st The computed style to follow.
function widget:drawborder(st, left, top, width, height)
-- TODO Take into account the following style attributes
--  borderimagesource = "none", -- "none" or a file path
--  borderimagerepeat = "repeat", -- stretch|repeat|round
--  bordercornerimage = "none" -- "none" or a file path

  local this = st.styles
  local right, bottom = left + width, top + height
    
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
        math.max(innertop, lmidtop)- lmidtop
      local length = math.atan2(dy, dx)
      if dx == 0 or dy == 0 then 
        length = math.pi/4 
      end
      arc("fill",
        radius, radius, 
        math.pi, radius, 
        math.min(width1, radius), 
        length)
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
  if this.borderleftwidth > 0  then
    color(unpack(this.borderleftcolor))
    push()
    translate(left - this.borderleftwidth, 
      top - this.bordertopwidth)
    border(this.borderleftwidth,
      this.bordertopwidth, this.bordertopleftradius, 
      this.borderbottomwidth, this.borderbottomleftradius, 
      height)
    pop()
  end
  if this.bordertopwidth > 0 then
    color(unpack(this.bordertopcolor))
    push()
    translate(left + this.borderrightwidth + width, 
      top - this.bordertopwidth)
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
      top - this.bordertopwidth)
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
function widget:drawbackground(st, left, top, width, height)
  local this = st.styles
  color(this.backgroundcolor)
  -- clip this rectangle's corners???.
  -- use poly???
  rectangle("fill", left, top, width, height)
end

--- Override to draw the content of the widget.
-- To be overridden by subclasses.
-- @param bounds The bounding rectangle of the widget.
-- The background will lie on or within the bounds
-- @param st The computed style to follow.
function widget:drawcontent(st, left, top, width, height)
  
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
    
    local bounds = {child:bounds()}
    -- Check left and top are both 10.
    assert(bounds[1] == 10 and bounds[2] == 10, 
      [[bounds[1] == 10 and bounds[2] == 10]])
    
    parent:remove(style)
    -- Check style was removed.
    assert(child.style.styles.display == nil,
      [[child.style.styles.display == nil]])
    
    assert(parent:owns(style) == false, [[parent:owns(style) == false]])
    
    bounds = {child:bounds()}
    -- Check left and top are both 0
    assert(bounds[1] == 0 and bounds[2] == 0, 
      [[bounds[1] == 0 and bounds[2] == 0]])
      
    return true
  end)
