--- loveui is a love2d library to provide resuable GUI widgets to love2d 
-- developers.
module ("ui", package.seeall)

-- Set this value to true to run unit tests when this library is run.
local DEBUG = true

--- Tests a test case.
-- Prints a message when test fails, but does not raise error.
-- To fail a test, throw an error or return false.
-- To pass a test, return true.
-- @param name The name of the test case.
-- @param case A function that returns false if the test failed.
function test(name, case)
  if not DEBUG then return end
  local ok, err = pcall(case)
  if not ok or not err then
    print("Test failed for test: ".. tostring(name))
    print(err)
  end
end

-- Test the unit test function.
test("ui.test", function()
    local ok, err = pcall(test, "test", function()
        return true
      end)
    assert(ok, "ok")
    return true
  end)
  
--- Checks the type of a value
-- @param name The variable name.
-- @param value The value whose type to check.
-- @param ... Types that a valid.
function checktype(name, value, ...)
  local t = type(value)
  for k, v in ipairs({...}) do
    if t == tostring(v) then
      return
    end
  end
  local types = table.concat({...}, ", ")
  error("Type of "..name.." is not one of "..types)
end

test("ui.checktype", function()
    checktype("val", 3, "number")
    checktype("val", 3, "number", "nil")
    checktype("val", 3, "nil", "number")
    checktype("val", "3", "nil", "string")
    checktype("val", {}, "nil", "table")
    local ok, err = pcall(checktype, "val", 1, "nil")
    assert(not ok, "not ok")
    return true
  end)

return ui