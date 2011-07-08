module ("ui", package.seeall)

function __or(...)
  local result = false
  for i, v in ipairs({...}) do
    result = result or v
    if result then return result end
  end
  return result
end
