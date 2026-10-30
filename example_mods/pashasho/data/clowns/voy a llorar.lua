local health = false
local Time = 3

function onGameOver()
    if not health then
        health = true


        soundFadeOut('', 0.01, 0)
        setSoundVolume('', 0)


        setProperty('vocals.volume', 0)


        makeLuaSprite('deathBlack', nil, 0, 0)
        makeGraphic('deathBlack', screenWidth, screenHeight, '000000')
        setObjectCamera('deathBlack', 'other')
        addLuaSprite('deathBlack', true)


        runTimer('restartAfterDeath', Time)
    end

    return Function_Stop
end

function onPause()

    if health or getProperty('health') <= 0 then
        return Function_Stop
    end

    return Function_Continue
end

function onTimerCompleted(tag)
    if tag == 'restartAfterDeath' then
        restartSong(true)
    end
end