require "gameloop"

--this a ninja object
ninja = {  x=150,
          y=150,
          prev_x=150,
          prev_y=150,
          view_x=150,
          view_y=150,
          speed=150,
          img = love.graphics.newImage("ninja.png") }


function love.update(dt)
  ninja.prev_x = ninja.x
  ninja.prev_y = ninja.y

  if love.keyboard.isDown('a') then
    ninja.x = ninja.x - (ninja.speed * dt)
  end

  if love.keyboard.isDown('d') then
    ninja.x = ninja.x + (ninja.speed * dt)
  end

  if love.keyboard.isDown('w') then
    ninja.y = ninja.y - (ninja.speed * dt)
  end

  if love.keyboard.isDown('s') then
    ninja.y = ninja.y + (ninja.speed * dt)
  end
end

function love.interpolate(alpha)
  ninja.view_x = ninja.x * alpha + ninja.prev_x * (1 - alpha)
  ninja.view_y = ninja.y * alpha + ninja.prev_y * (1 - alpha)
end

function love.draw()
  love.graphics.draw(ninja.img, ninja.view_x, ninja.view_y)
  love.graphics.print("Keys [W],[S],[A],[D] for up, down, left & right",6,6)
  love.graphics.print("Frames displayed per second: "..love.timer.getFPS(),6,22)
end
