function onBeatHit()
    if curBeat == 204 then
        setPropertyFromClass('lime.app.Application', 'current.window.fullscreen', true)
    end
end