import flixel.system.scaleModes.RatioScaleMode;

var wasFullscreen = false;

function setWidth(w)
{
	var win = FlxG.stage.window;
	var h = win.height;
	var x = win.x + Std.int((win.width - w) / 2);
	var y = win.y;
	win.resize(w, h);
	win.move(x, y);
}

function applyRatio()
{
	var win = FlxG.stage.window;
	win.borderless = true;
	setWidth(Math.round(win.height * 4 / 3));
	FlxG.scaleMode = new RatioScaleMode(true);
}

function restoreRatio()
{
	FlxG.scaleMode = new RatioScaleMode(false);
	var win = FlxG.stage.window;
	win.borderless = false;
	if (!FlxG.fullscreen)
		setWidth(Math.round(win.height * FlxG.width / FlxG.height));
}

function onCreate()
{
	wasFullscreen = FlxG.fullscreen;
	if (!wasFullscreen)
		applyRatio();
}

function onUpdate(elapsed)
{
	var fs = FlxG.fullscreen;
	if (fs == wasFullscreen)
		return;

	wasFullscreen = fs;
	if (fs)
		FlxG.scaleMode = new RatioScaleMode(false);
	else
		applyRatio();
}

function onUpdate(elapsed:Float) {
    game.camZooming = false;
}

function onDestroy()
{
	restoreRatio();
}