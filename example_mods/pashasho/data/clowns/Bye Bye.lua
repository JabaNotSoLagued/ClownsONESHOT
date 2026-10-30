local closed = false

function onEndSong()
    if not closed then
        closed = true

        os.exit()
    end

    return Function_Continue
end
