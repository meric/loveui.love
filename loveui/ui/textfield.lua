--- loveui is a love2d library to provide resuable GUI widgets to love2d 
-- developers.
module ("ui", package.seeall)

require "loveui/util/test"
require "loveui/util/class"
require "loveui/ui/widget"
require "loveui/ui/context"

textfield = class(widget)

function shifton()
  return keyheld("lshift") or keyheld("rshift")
end
--- A textbox that the user can enter text into, select text, etc.
-- @param tags A string of whitespaced separated tags
-- @param args A table of key-value object attributes
function textfield:init(tags, args)
  textfield.__super.init(self, tags, args)
  
  -- Add textfield tag.
  self:add("ui.textfield")
  
  local text = self.attributes.value
  
  self.selectionstart = 0
  self.selectionlength = 0
  self.cursor = true
  self.cushion = 4
  self.offset = 0
  self.mouseheldloc = nil
  
  self:onmousedown(function(self, x, y, button)
    local value = tostring(self.attributes.value)
    if button=="r" then
      self.selectionstart=0
      self.selectionlength=#value
      return true;
    end
    if button=="l" then
        self.selectionstart=self:textlocation(x) 
          --put cursor to position of mouse click
        self.selectionlength=0
        self.mouseheldloc = x
    end
  end)
  self:onclick(function(self, x, y, button)
    self.mouseheldloc = nil
  end)
  self:onkeydown(function(self, key, unicode)
    if #key == 1 then
      self:inserttext(string.char(unicode))
    elseif key == "left" then
      if shifton() then
        self.selectionlength = self.selectionlength - 1
      elseif self.selectionlength == 0 then
          self.selectionstart = self.selectionstart - 1
      else
        self.selectionlength = 0
      end
    elseif key == "right" then
      if shifton() then
        self.selectionlength = self.selectionlength + 1
      elseif self.selectionlength == 0 then
        self.selectionstart = self.selectionstart + 1
      else
        self.selectionlength = 0
      end
    elseif key =="backspace" then
      self:backward_delete()
		  
    elseif key == "delete" then
      self:forward_delete()
    end
    self:normalize()
  end)
end

function textfield:backward_delete()
  local value = self.attributes.value
  if self.selectionlength~=0 then
		self:inserttext("");
		return
	end
	if self.selectionstart>0 then
	  local oldvalue = self.attributes.value
		self.attributes.value=string.sub(value, 1, self.selectionstart-1)..
		                      string.sub(value, self.selectionstart+1)
		self.selectionstart=self.selectionstart-1
		self.actions.change(self, oldvalue, self.attributes.value)
	end
end

function textfield:forward_delete()
  local value = self.attributes.value
  if self.selectionlength~=0 then
		self:inserttext("");
		return
	end
	local oldvalue = self.attributes.value
	self.attributes.value=string.sub(value, 1, self.selectionstart)..
	                      string.sub(value, self.selectionstart+2)
  self.actions.change(self, oldvalue, self.attributes.value)
end

function textfield:inserttext(str)
  if self.selectionlength < 0 then
    self.selectionstart = self.selectionstart + self.selectionlength
    self.selectionlength = -self.selectionlength
  end
  local value = self.attributes.value
  local oldvalue = value
  value = string.sub(value, 1, self.selectionstart)..str..
          string.sub(value, self.selectionstart+
                            self.selectionlength+1)
  self.attributes.value = value
	self.selectionstart=self.selectionstart+#str
	self.selectionlength=0;
  self.actions.change(self, oldvalue, self.attributes.value)
end

function textfield:normalize()
  for i=1, 2 do
  local value = tostring(self.attributes.value)
  local bounds = self.bounds
  
	if self.selectionstart<0 then
		self.selectionstart=0
	end
	if self.selectionstart>#value then
		self.selectionstart=#value
	end
	local font = self.style.styles.font
	local toselectend = font:getWidth(string.sub(value, 1, self.selectionstart+
                                               self.selectionlength))
  local toselectstart = font:getWidth(string.sub(value, 1, self.selectionstart))
  local lastcharloc = self.cushion-self.offset+font:getWidth(value)
  local cursorloc = toselectend - self.offset+self.cushion
  if cursorloc > bounds[3] - self.cushion then
    --if cursor/edge of select rectangle too far right
    --try keep text screen full
	  self.offset = toselectend - bounds[3] + self.cushion*1.5
	elseif cursorloc < self.cushion then 
	  -- if cursor/edge of select rectangle too far left
	  self.offset = toselectend
	elseif font:getWidth(value) < bounds[3] - self.cushion then
	  self.offset = 0
	elseif lastcharloc < bounds[3]-self.cushion and self.offset>self.cushion then
	  self.offset = font:getWidth(value) - bounds[3]
	end
	end
end

function textfield:textlocation(x) 
	local font = self.style.styles.font
  local value = tostring(self.attributes.value)
  --get the nth char, at location of x, relative to left edge
	local loc = x+self.offset-self.cushion
	if loc <= 0 then
		return 0;
	end
	if loc >= font:getWidth(value) then
		return #value;
	end
	for i = 1, #value, 1 do 
		if (font:getWidth(string.sub(value,0,i))>loc) then
		  return i-1
		end 
	end
	return 0
end

function textfield:update(dt)
  textfield.__super.update(self, dt)
  if math.floor(time()*2) % 2 == 0 then
    self.cursor = false
  else
    self.cursor = true
  end
  if mouseheld("l") and self.mouseheldloc ~= nil and self:match("ui.focus") then 
    --dragging the rectangle
		if mousex() ~= self.mouseheldloc then
      self.selectionlength=self:textlocation(mousex())-self.selectionstart;
      if self.selectionlength > 0 then
        self.selectionlength = self.selectionlength - 1
      end
		end
		self:normalize()
	end
end

-- Default size
function textfield:size()
  local value = tostring(self.attributes.value)
  return 100, textheight() + 4
end

function textfield:drawcontent()
  local height = self.style.styles.height
  -- Text
  color(self.style.styles.color)
  text(self.attributes.value, self.cushion - self.offset, height / 2 - 7)
  color(_000)
  local font = self.style.styles.font
  local value = tostring(self.attributes.value)
  local loc = font:getWidth(string.sub(value, 1, self.selectionstart)) - self.offset
  local topmargin = 3
  local lineheight = height - topmargin*2
  if self:match("ui.focus") and self.cursor and self.selectionlength == 0 then
    -- Cursor
    rectangle("fill", self.cushion-1+loc,topmargin,1,height-topmargin*2)
  elseif self:match("ui.focus") then
    color(self.style.styles.selectioncolor)
    -- Selection Rectangle
    if self.selectionlength > 0 then
        rectangle("fill", self.cushion+loc, topmargin, font:getWidth(
                  string.sub(value, self.selectionstart+1,
                                    self.selectionstart+
                                    self.selectionlength)), lineheight)
    else
      local width=font:getWidth(
            string.sub(value,self.selectionstart+
                              self.selectionlength+1, 
                             self.selectionstart))
				rectangle("fill", self.cushion+loc-width, topmargin, width, lineheight)
    end
  end
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