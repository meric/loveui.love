--- loveui is a love2d library to provide resuable GUI widgets to love2d 
-- developers.
module ("ui", package.seeall)

require "loveui/util/test"

--- Process a string of whitespace separated tags into a string of 
-- sorted tags separated by whitespace, so they can be stored as keys in 
-- tables.
-- @param tags A string of tags separated by whitespace. 
-- A tag may contain any non-whitespace characters.
-- @return a string of tags separated by whitespace.
function sorttags(tags)
  if tags == nil then 
    tags = "" 
  end
  tags = tostring(tags)
  local sorted = {}
  for t in string.gmatch(tags, "[^%s]+") do
   table.insert(sorted, t)
  end
  table.sort(sorted)
  return table.concat(sorted, " ");
end

test("ui.sorttags", function() 
    return sorttags("ui.a ui.c ui.b") == "ui.a ui.b ui.c" 
  end)
  
test("ui.sorttags", function()
    return sorttags("1 3 2") == "1 2 3"
  end)

--- Convert a string of tags into a set of tags.
-- @param tags A string of tags.
function settags(tags)
  local set = {}
  for t in string.gmatch(tags, "[^%s]+") do
   set[t] = t
  end
  return set
end

--- Returns whether <code>withtags</code> is a super-set of 
-- <code>tags1</code>.
-- @param withtags A string of tags separated by whitespace. 
-- @param tags1 A string of tags separated by whitespace. 
function matchtags(withtags, tags1)
  local set1, set2 = settags(withtags), settags(tags1)
  for k, v in pairs(set2) do
    if not set1[k] then return false end
  end
  return true
end

test("ui.matchtags", function()
    return matchtags("ui.button tag1 tag2", "ui.button tag1") == true
  end)

test("ui.matchtags", function()
    return matchtags("a b c d", "d c") == true
  end)
  
test("ui.matchtags", function()
    return matchtags("a b", "a b c") == false
  end)

return ui