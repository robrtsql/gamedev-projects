require "gameloop"
require "camera"

love.graphics.setDefaultFilter('nearest', 'nearest')

ninja = {
  x=150,
  y=150,
  prev_x=150,
  prev_y=150,
  view_x=150,
  view_y=150,
  speed=150,
  img = love.graphics.newImage("ninja.png")
}
tile = love.graphics.newImage("tile.png")
camera:scale(1/3)

function love.update(dt)
  ninja.prev_x = ninja.x
  ninja.prev_y = ninja.y

  if love.keyboard.isDown('a') then
    ninja.x = ninja.x - (ninja.speed * dt)
  elseif love.keyboard.isDown('d') then
    ninja.x = ninja.x + (ninja.speed * dt)
  end

  if love.keyboard.isDown('w') then
    ninja.y = ninja.y - (ninja.speed * dt)
  elseif love.keyboard.isDown('s') then
    ninja.y = ninja.y + (ninja.speed * dt)
  end

  if love.keyboard.isDown('escape') then
    love.event.quit(0)
  end
end

function love.interpolate(alpha)
  ninja.view_x = ninja.x * alpha + ninja.prev_x * (1 - alpha)
  ninja.view_y = ninja.y * alpha + ninja.prev_y * (1 - alpha)
  camera:centerOn(ninja.view_x, ninja.view_y)
end

function love.draw()
  camera:set()

  for i = 1, 10 do
    tile_x = 0 + (i * 16)
    for j = 1, 10 do
      tile_y = 0 + (j * 16)
      love.graphics.draw(tile, tile_x, tile_y)
    end
  end

  love.graphics.draw(ninja.img, ninja.view_x, ninja.view_y)
  camera:unset()
  love.graphics.print("Keys [W],[S],[A],[D] for up, down, left & right",6,6)
  love.graphics.print("Frames displayed per second: "..love.timer.getFPS(),6,22)
end
