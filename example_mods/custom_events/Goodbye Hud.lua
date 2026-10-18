function onEvent(name,value1,value2)
	if name == 'Goodbye Hud' then
		doTweenAlpha('hudalpha', 'camHUD', tonumber(value1), tonumber(value2), 'linear');
	end
end