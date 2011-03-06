ui = require 'loveui/ui'

local context = ui.context()
function love.load()
  success = love.graphics.setMode( 800, 600, false, false, 0 )
  context:add(
    ui.style("ui.button tag1", {
        left = 200, top = 200, 
        width = 100, height = 100,
        borderleftcolor = {0, 255, 0, 255},
        borderrightcolor = {0, 255, 0, 255},
        bordercolor = {255, 0, 0, 255},
        borderleftwidth = 10,
        bordertopwidth = 20,
        borderrightwidth = 30,
        borderbottomwidth=40,
        borderwidth = 20,
        borderradius = 100,
        backgroundcolor = {0, 0, 0, 255}, 
        backgroundimage = "./button.png"}),
        
    ui.button("ui.button tag1 tag2 tag3", {value = "Click"})
      :onmousedown( 
      function(self, x, y, button)
        print("mousedown", x, y, button)
      end)
      :onclick(
      function(self, x, y, button)
        print("click", x, y, button)
      end))
end

function love.update(dt)
  context:update(dt)
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

