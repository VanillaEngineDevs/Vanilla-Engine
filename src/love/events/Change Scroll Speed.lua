scrollspeedChange = nil
currrrrrrScrollspeed = nil

function onEvent(n, v1, v2)
    --v1 = scroll speed multiplier
    --v2 = time it takes to change

    currrrrrrScrollspeed = speed

    newspeed = currrrrrrScrollspeed * v1

    -- find the difference between the two speeds and scale all hold notes (1 = currrrrScrollspeed, 2 = newspeed)

    diff = newspeed - currrrrrrScrollspeed
    for i = 1, 4 do
        for j = 1, #boyfriendNotes[i] do
            if boyfriendNotes[i][j]:getAnimName() == "hold" or boyfriendNotes[i][j]:getAnimName() == "end" then
                boyfriendNotes[i][j].sizeY = boyfriendNotes[i][j].sizeY * (1 + diff)
            end
        end

        for j = 1, #enemyNotes[i] do
            if enemyNotes[i][j]:getAnimName() == "hold" or enemyNotes[i][j]:getAnimName() == "end" then
                enemyNotes[i][j].sizeY = enemyNotes[i][j].sizeY * (1 + diff)
            end
        end
    end
end