--- loveui is a love2d library to provide resuable GUI widgets to love2d 
-- developers.
module ("ui", package.seeall)

require "loveui/util/test"
require "loveui/util/class"

chain = class()

--- A chain of functions.
-- When called, each function in the chain will be called with the 
-- arguments.
-- One can use table.insert and table.remove as normal to add or remove 
-- functions from the chain.
-- @param ... The argument to each function.
function chain:__call(...)
  local r = {}
  for i, fn in ipairs(self) do
    local result = fn(...)
    table.insert(r, result)
  end
  return unpack(r)
end

--- Remove functions from a chain
-- @param fn A function to remove from the chain
-- @param ... Other functions to remove from the chain
function chain:remove(fn, ...)
  for i, f in ipairs(self) do
    if f == fn then
      table.remove(self, i)
      return fn, ... and self:remove(...) or nil
    end
  end
  return nil
end

--- Add a function to the end of the chain.
-- @param ... Functions to be added.
function chain:add(...)
  for i, v in ipairs({...}) do
    table.insert(self, v)
  end
  return ...
end

return ui