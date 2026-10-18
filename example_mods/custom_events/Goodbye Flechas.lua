function onEvent(name, value1, value2)
    if name == 'Goodbye Flechas' then
        local targetAlpha = tonumber(value1)
        local duration = tonumber(value2)

        for i = 4, 7 do
            noteTweenAlpha('playerStrum' .. i, i, targetAlpha, duration, 'linear')
        end

        for i = 0, 3 do
            noteTweenAlpha('opponentStrum' .. i, i, targetAlpha, duration, 'linear')
        end
    end
end