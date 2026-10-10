function Song:postCreate()
    local enemy = getEnemy()

    enemy.x = enemy.x + 270
    enemy.y = enemy.y - 100
end