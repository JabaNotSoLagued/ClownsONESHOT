function boundTo(value, min, max)
    return math.max(min, math.min(max, value))
end

function math.lerp(from, to, i)
    return from + (to - from) * i
end

local Chromacrap = 0
local chromaDuration = 0

function setChrome(chromeOffset)
    setShaderFloat("guyShader", "rOffset", chromeOffset)
    setShaderFloat("guyShader", "gOffset", 0.0)
    setShaderFloat("guyShader", "bOffset", chromeOffset * -1)
end

function onCreatePost()
    if shadersEnabled then

        initLuaShader("guy")

        makeLuaSprite("guyShader")
        makeGraphic("guyShader", screenWidth, screenHeight)

        setSpriteShader("guyShader", "guy")

        -- pixel effect bye bye!
        setShaderFloat("guyShader", "size", 0.0)

        addHaxeLibrary("ShaderFilter", "openfl.filters")

        runHaxeCode([[
            var shader = game.getLuaObject("guyShader").shader;

            game.camGame.setFilters([new ShaderFilter(shader)]);
            game.camHUD.setFilters([new ShaderFilter(shader)]);
        ]])
    end
end

function onEvent(n, v1, v2)

    if n == 'Chromatic Aberration' then
        Chromacrap = Chromacrap + tonumber(v1)
        chromaDuration = tonumber(v2)
    end
end

function onUpdate(elapsed)

    if shadersEnabled then

        if chromaDuration > 0 then
            local decaySpeed = elapsed / chromaDuration
            Chromacrap = math.lerp(Chromacrap, 0, decaySpeed)
        else
            Chromacrap = math.lerp(Chromacrap, 0, 1)
        end

        setChrome(Chromacrap)
    end
end
