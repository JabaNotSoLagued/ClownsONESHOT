function onCreate()
	setProperty('skipCountdown', true)

      makeLuaSprite('bl', nil, 0, 0)
      makeGraphic('bl', 2000, 1000, '000000')
      setObjectCamera('bl', 'other')
	addLuaSprite('bl', true)

	doTweenAlpha('bl', 'bl', 0, 7)


end