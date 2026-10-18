function onEvent(name, value1, value2)
    if name == 'MiddleScroll' then

        if value1 == 'quaver' then
            for i = 0, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'alpha', 1)
            end

            setPropertyFromGroup('strumLineNotes', 0, 'x', 92)
            setPropertyFromGroup('strumLineNotes', 1, 'x', 204)
            setPropertyFromGroup('strumLineNotes', 2, 'x', 316)
            setPropertyFromGroup('strumLineNotes', 3, 'x', 428)

            setPropertyFromGroup('strumLineNotes', 4, 'x', 732)
            setPropertyFromGroup('strumLineNotes', 5, 'x', 844)
            setPropertyFromGroup('strumLineNotes', 6, 'x', 956)
            setPropertyFromGroup('strumLineNotes', 7, 'x', 1068)

            return
        end

        noteTweenX("NoteMove1", 0, 410, value1, 'cubeInOut')
        noteTweenX("NoteMove2", 1, 520, value1, 'cubeInOut')
        noteTweenX("NoteMove3", 2, 630, value1, 'cubeInOut')
        noteTweenX("NoteMove4", 3, 740, value1, 'cubeInOut')
        noteTweenX("NoteMove5", 4, 410, value1, 'cubeInOut')
        noteTweenX("NoteMove6", 5, 520, value1, 'cubeInOut')
        noteTweenX("NoteMove7", 6, 630, value1, 'cubeInOut')
        noteTweenX("NoteMove8", 7, 740, value1, 'cubeInOut')

        noteTweenAlpha("NoteFade1", 0, 0, value2, 'cubeInOut')
        noteTweenAlpha("NoteFade2", 1, 0, value2, 'cubeInOut')
        noteTweenAlpha("NoteFade3", 2, 0, value2, 'cubeInOut')
        noteTweenAlpha("NoteFade4", 3, 0, value2, 'cubeInOut')
    end
end
