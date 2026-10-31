local firstLyricsAppear = true
local lyricsColor = 'ffffff' 

function onCreatePost()
    makeLuaText('lyrics', '', 1250, 0, 580)

    setTextAlignment('lyrics', 'center')
    setTextSize('lyrics', 35)
    setTextFont('lyrics', 'spooky.ttf')
    setTextBorder('lyrics', 5.67, '000000')

    setObjectCamera('lyrics', 'other')
    setObjectCamera('lyrics', 'camOther')

    setScrollFactor('lyrics', 0, 0)
    setProperty('lyrics.alpha', 0)

    addLuaText('lyrics')
end

function onEvent(name, value1, value2)
    if name == 'lyrics' then

        if value1 == '' then
            doTweenAlpha('lyricsFadeOut', 'lyrics', 0, 0.45, 'quadOut')

        else
            setTextString('lyrics', value1)

            if firstLyricsAppear then
                setProperty('lyrics.alpha', 0)
                doTweenAlpha('lyricsFadeIn', 'lyrics', 1, 0.5, 'quadOut')
                firstLyricsAppear = false
            else
                setProperty('lyrics.alpha', 1)
            end
        end

        if value2 ~= '' then
            lyricsColor = value2
        else
            lyricsColor = 'ffffff' 
        end

        setTextColor('lyrics', lyricsColor)
    end
end
