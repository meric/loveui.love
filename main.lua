ui = require 'loveui/ui'

local context = ui.context()
function love.load()
  success = love.graphics.setMode( 800, 600, false, false, 0 )
  context:add(
    ui.style("ui.button tag1", {
        left = 200, top = 200, 
        width = 100, height = 25,
        --background: -webkit-gradient(linear, 0% 0%, 0% 100%, from(#EBEBEB), to(#A1A1A1));,
        bordercolor = {64, 64, 64, 128},
        borderimage = "./button.png",
        borderimageslice = {25, 25, 25, 25},
        borderimagerepeat = {"stretch", "stretch"},
        borderwidth = 40,
        bordertopcolor = {255, 0, 0, 128},
        borderbottomcolor = {0, 0, 255, 128},
        borderradius = 100,
        background = function(x, y, r, g, b, a)
          -- x, y >= 0 <= width, height
          return r, g, b, a
        end,
        backgroundcolor = {255,255,255,255},
        backgroundimage = "./button.png",
        backgroundimagerepeat = "stretch",
        backgroundgradient = function (x, y, r, g, b, a)
          return r, g, b, a
        end}),
    -- background : string(image name),function(gradient),table(color)?
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
  --print(love.timer.getFPS())
end

function love.draw()
  --context:draw()
  
  local radius = 200
  ui.push()
    ui.translate(100,100)
    ui.color{255,255,255,255}
    ui.rectangle("fill", 0,0,radius*2,radius*2)
    
    
    ui.push()
      ui.translate(radius-100,radius)
      ui.color{255,0,0,128}
      ui.arc1("fill", radius, radius, math.pi/8)
      ui.translate(-2,0)
    ui.pop()
    
  ui.pop()
  
  ui.push()
    ui.translate(300,100)
    ui.color{255,255,255,255}
    ui.rectangle("fill", 100,0,radius*2,radius*2)
    ui.push()
      ui.translate(radius,radius)
      ui.color{255,0,0,128}
      ui.arc3("fill", radius, radius, math.pi/4)
      --ui.arc2("fill", radius, radius, math.pi/4)
    ui.pop()
  
  ui.pop()
  
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

