function onBeatHit()
    if curBeat == 202 then
        runHaxeCode([[
            game.camGame.setFilters([]);
            game.camHUD.setFilters([]);
        ]]);
    end
end