ui = require 'loveui/ui'

local context = ui.context()
function love.load()
  love.graphics.setBackgroundColor{255,255,255}
  success = love.graphics.setMode( 800, 600, false, false, 0 )
  local st_b1, button_b1, st_t1, textfield_t1 = 
  context:add(
    ui.style("b1", {left=10,top=10,color={0,0,255}}),
    ui.button("b1", {value = "Menu"})
      :onclick(function(self, x, y, button)
        print("click", x, y, button)
      end),
    ui.style("t1", {left=10,top=50}),
    ui.textfield("t1", {value="text"})
      :onchange(function(self, old, new)
        print(old.." -> " .. new)
      end))
end

function love.update(dt)
  context:update(dt)
  --print(love.timer.getFPS())
end

function love.draw()
  context:draw()
end

function love.keypressed(key, unicode)
  context:keypressed(key, unicode)
end

function love.keyreleased(key, unicode)
  context:keyreleased(key, unicode)
end

function love.mousepressed(x, y, button)
  context:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  context:mousereleased(x, y, button)
end

