function love.load()
  love.setUpdateTimestep(1/100)
end

function love.setUpdateTimestep(ts)
  love.updateTimestep = ts
end

function love.run()
  math.randomseed( os.time() )
  math.random() math.random()

  if love.load then love.load(arg) end

  local dt = 0
  local accumulator = 0

  -- Main loop
  while true do

    -- Process events.
    if love.event then
      love.event.pump()
      for e,a,b,c,d in love.event.poll() do
        if e == "quit" then
          if not love.quit or not love.quit() then
            if love.audio then love.audio.stop() end
            return
          end
        end
        love.handlers[e](a,b,c,d)
      end
    end

    -- Update dt for any uses during this timestep of love.timer.getDelta
    if love.timer then
      love.timer.step()
      dt = love.timer.getDelta()
    end

    local fixedTimestep = love.updateTimestep

    if fixedTimestep then
      if dt > 0.25 then
        dt = 0.25 -- note: max frame time to avoid spiral of death
      end

      accumulator = accumulator + dt
      --_logger:debug("love.run - acc=%f fts=%f", accumulator, fixedTimestep)

      while accumulator >= fixedTimestep do
        if love.update then love.update(fixedTimestep) end
        accumulator = accumulator - fixedTimestep
      end

    else
      -- no fixed timestep in place, so just update
      -- will pass 0 if love.timer is disabled
      if love.update then love.update(dt) end
    end

    local alpha = accumulator/fixedTimestep
    love.interpolate(alpha)

    -- draw
    if love.graphics then
      love.graphics.clear()
      if love.draw then love.draw() end
      if love.timer then love.timer.sleep(0.001) end
      love.graphics.present()
    end
  end
end
