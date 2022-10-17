-- PLAYER
local player = { x = 200, y = 710, speed = 300, img = nil }

-- SHOOT
local shoot = true
local maxShootTimer = 0.2
local bulletSpeed = 400
local shootTimer = maxShootTimer
local bulletImg = nil
local bullets = {}

-- ENEMY
local enemyTimerMax = 0.4
local enemySpeed = 200
local enemyTimer = enemyTimerMax
local enemyImg = nil
local enemies = {}

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
  end

local isAlive = true
local score = 0

function love.load(arg)
    player.img = love.graphics.newImage("assets/plane.png")
    bulletImg = love.graphics.newImage("assets/bullet.png")
    enemyImg = love.graphics.newImage("assets/enemy.png")
end

function love.update(dt)
    shootTimer = shootTimer - (1 * dt)
    if shootTimer < 0 then shoot = true end

    enemyTimer = enemyTimer - (1 * dt)
    if enemyTimer < 0 then
        enemyTimer = enemyTimerMax

        -- Create an enemy
        local randomNumber = math.random(10, love.graphics.getWidth() - 10)
        local newEnemy = { x = randomNumber, y = -10, img = enemyImg }
        table.insert(enemies, newEnemy)
    end

    if love.keyboard.isDown("space") and shoot then
        local newBullet = { x = player.x + (player.img:getWidth() / 2), y = player.y, img = bulletImg}
        table.insert(bullets, newBullet)
        shoot = false
        shootTimer = maxShootTimer
    end

    if love.keyboard.isDown("escape") then
        love.event.push("quit")
    end

    if love.keyboard.isDown("left", "a") then
        if player.x > 0 then
            player.x = player.x - (player.speed * dt)
        end
    elseif love.keyboard.isDown("right", "d") then
       if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
            player.x = player.x + (player.speed * dt)
       end
    end

    for i, bullet in ipairs(bullets) do
        bullet.y = bullet.y - (bulletSpeed * dt)

        if bullet.y < 0 then
            table.remove(bullets, i)
        end
    end

    for i, enemy in ipairs(enemies) do
        enemy.y = enemy.y + (enemySpeed * dt)

        if(enemy.y > 850) then
            table.remove(enemies, i)
        end
    end

    for i, enemy in ipairs(enemies) do
        for j, bullet in ipairs(bullets) do
            if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
                table.remove(enemies, i)
                table.remove(bullets, i)
                score = score + 1
            end
        end

        if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) and isAlive then
            table.remove(enemies, i)
            isAlive = false
        end
    end

    if not isAlive and love.keyboard.isDown('r') then
        -- remove all our bullets and enemies from screen
        bullets = {}
        enemies = {}
        -- reset timers
        shootTimer = maxShootTimer
        enemyTimer = enemyTimerMax
        -- move player back to default position
        player.x = 50
        player.y = 710   
        -- reset our game state
        score = 0
        isAlive = true
    end
end

function love.draw(arg)
    love.graphics.draw(player.img, player.x, player.y)

    for i, bullet in ipairs(bullets) do
        love.graphics.draw(bullet.img, bullet.x, bullet.y)
    end

    for i, enemy in ipairs(enemies) do
        love.graphics.draw(enemy.img, enemy.x, enemy.y, 0, 1, -1)
    end

    if isAlive then
        love.graphics.draw(player.img, player.x, player.y)
    else
        love.graphics.print("Press 'R' to restart", love.graphics:getWidth() / 2 - 50, love.graphics:getHeight() / 2 - 10)
    end
end