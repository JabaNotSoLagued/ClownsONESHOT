function onCreate()
    setPropertyFromClass('openfl.Lib', 'application.window.borderless', true)
end

function restoreWindow()
    setPropertyFromClass('openfl.Lib', 'application.window.borderless', false)
end

function onEndSong()
    restoreWindow()
    return Function_Continue
end

function onDestroy()
    restoreWindow()
end