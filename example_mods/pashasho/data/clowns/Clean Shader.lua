function onBeatHit()
    if curBeat == 204 then
        runHaxeCode([[
            game.camGame.setFilters([]);
            game.camHUD.setFilters([]);
        ]]);
    end
end