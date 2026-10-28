function onBeatHit()
    if curBeat == 1 then
        setPropertyFromClass('lime.app.Application', 'current.window.fullscreen', false)
    end


    if curBeat == 202 then
        setPropertyFromClass('lime.app.Application', 'current.window.fullscreen', true)
    end

     if curBeat == 219 then
        setPropertyFromClass('lime.app.Application', 'current.window.fullscreen', false)
    end
end