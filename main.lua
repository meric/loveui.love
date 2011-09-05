ui = require 'loveui/ui'

local context = ui.context()
function love.load()
  love.graphics.setBackgroundColor{255,255,255}
  success = love.graphics.setMode( 800, 600, false, false, 0 )
  st_b1, button_b1, st_t1, textfield_t1, st_c1, checkbox_c1 = 
  context:add(
    ui.style("b1", {left=10,top=10,borderradius=1,color={0,0,255}}),
    ui.button("b1", {value = "Menu"})
      :onclick(function(self, x, y, button)
        print("click", x, y, button)
      end),
    ui.style("t1", {left=10,top=40,borderradius=1}),
    ui.textfield("t1", {value="text"})
      :onchange(function(self, old, new)
        print(old.." -> " .. new)
      end),
    ui.style("c1", {left=190,top=43}),
    ui.checkbox("c1",{})
      :onchange(function(self, old, new)
        textfield_t1:apply{disabled=new}
      end),
    ui.style("l1", {left=120,top=40}),
    ui.label("l1",{value="disabled"})
      :onclick(function()
        -- make it so clicking on label toggles checkbox
        checkbox_c1:toggle()
      end),
    ui.style("ui.hover",{backgroundcolor={255,0,0,50}}))
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

