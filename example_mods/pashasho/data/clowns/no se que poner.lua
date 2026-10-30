local originalWidth = 1920
local originalHeight = 1080


function onCreate()
    
    setPropertyFromClass(
        'openfl.Lib',
        'application.window.width',
        originalWidth
    )

    setPropertyFromClass(
        'openfl.Lib',
        'application.window.height',
        originalHeight
    )

    local screenWidth = getPropertyFromClass(
        'openfl.Lib',
        'application.window.display.currentMode.width'
    )

    local screenHeight = getPropertyFromClass(
        'openfl.Lib',
        'application.window.display.currentMode.height'
    )

    local x = (screenWidth - originalWidth) / 2
    local y = (screenHeight - originalHeight) / 2

    setPropertyFromClass(
        'openfl.Lib',
        'application.window.x',
        x
    )

    setPropertyFromClass(
        'openfl.Lib',
        'application.window.y',
        y
    )
end
