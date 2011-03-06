--- loveui is a love2d library to provide resuable GUI widgets to love2d 
-- developers.
module ("ui", package.seeall)

require "loveui/util/test"

--- Creates a class using shallow copy.
-- An instance of the class can be created by calling the class as a 
-- function.
-- The class' <code>__super</code> key refers to its parent class, if 
-- any.
-- The <code>init</code> function can be overridden to initialize 
-- instances of the class; Arguments provided when the class is called 
-- is passed to this <code>init</code> function.
-- @param parent [optional] The parent class to subclass from.
-- @return The newly created class.
function class(parent)
  parent = parent or {init=function() end}
  local new = {init=function() end}
  
  -- A child class is a shallow copy of its parent class.
  for k, v in pairs(parent) do
    new[k] = v
  end
  new.__super = parent
  
  -- Each class is the metatable of all of its instances.
  new.__index = new
  
  return setmetatable(new, {__call = function(t , ...) 
    local instance=setmetatable({__class = new}, new);
    new.init(instance, ...)
    return instance
  end})
end

-- Test the class function.
test("ui.class", function()
  local parent = class()
  parent.name = "parent"
  function parent:method() end
  
  local child = class(parent)
  child.name = "child"
  function child:methoda() end
  local c = child()
  assert(getmetatable(c).__index.name == "child")
  assert(c.name == "child", [[c.name == "child"]])
  assert(child.method, [[child.method]])
  assert(child.methoda, [[child.methoda]])
  assert(c.method, [[c.method]])
  assert(c.methoda, [[c.methoda]])
  return true
  end)

return ui