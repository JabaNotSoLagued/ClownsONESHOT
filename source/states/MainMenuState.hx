
package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import backend.Song;
import backend.Difficulty;
import backend.Highscore;
import options.OptionsState;
import #if sys sys.FileSystem #end;

#if sys
import sys.FileSystem;
#end

typedef MenuButton =
{
	var spr:FlxSprite;
	var name:String;
	var layer:Int;
	var cx:Float;
	var cy:Float;
}

typedef MenuLayer =
{
	var spr:FlxSprite;
	var depth:Float;
}

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '1.0.4';

	static final IMG_FOLDER:String = 'clowns/';
	static final SONG_NAME:String = 'clowns';
	static final MOD_FOLDER:String = 'pashasho';

	static final MAX_MOVE_X:Float = 26;
	static final MAX_MOVE_Y:Float = 14;
	static final BG_SCALE:Float = 1.06;
	static final SMOOTH:Float = 5;

	static final LAYER_ORDER:Array<Int> = [13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1];

	var layers:Array<MenuLayer> = [];
	var buttons:Array<MenuButton> = [];

	var camX:Float = 0;
	var camY:Float = 0;
	var selected:Bool = false;
	var hovered:MenuButton = null;
	var transition:FlxSprite;
	var flash:FlxSprite;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = persistentDraw = true;
		FlxG.mouse.visible = true;

		if (FlxG.sound.music == null)
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);

		for (num in LAYER_ORDER)
		{
			var spr:FlxSprite;

			switch (num)
			{
				case 9: spr = makeButton('story_mode', 'play', 9, 592, 310);
				case 7: spr = makeButton('credits', 'credits', 7, 408, 436);
				case 5: spr = makeButton('options', 'options', 5, 836, 320);
				default:
					spr = new FlxSprite(0, 0).loadGraphic(Paths.image(IMG_FOLDER + 'clowns' + num));
			}

			spr.antialiasing = ClientPrefs.data.antialiasing;
			spr.scale.set(BG_SCALE, BG_SCALE);

			layers.push({spr: spr, depth: (14 - num) / 13});
			add(spr);
		}

		flash = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		flash.scrollFactor.set();
		flash.alpha = 0;
		add(flash);

		transition = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		transition.scrollFactor.set();
		transition.alpha = 0;
		add(transition);

		super.create();
	}

	function makeButton(file:String, name:String, layerNum:Int, cx:Float, cy:Float):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite(0, 0);
		spr.frames = Paths.getSparrowAtlas(IMG_FOLDER + file);
		spr.animation.addByPrefix('idle', 'idle', 24, false);
		spr.animation.addByPrefix('press', 'press', 12, true);
		spr.animation.play('idle');
		spr.color = 0xFFB4B4B4;
		buttons.push({spr: spr, name: name, layer: layerNum, cx: cx, cy: cy});
		return spr;
	}

	function getHoveredButton():MenuButton
	{
		var p:FlxPoint = FlxPoint.get(FlxG.mouse.x, FlxG.mouse.y);
		var result:MenuButton = null;

		for (n in [5, 7, 9])
		{
			for (b in buttons)
			{
				if (result == null && b.layer == n && b.spr.pixelsOverlapPoint(p, 0x40, FlxG.camera))
					result = b;
			}
		}

		p.put();
		return result;
	}

	function findSongMod(songLower:String):String
	{
		#if sys
		var base:String = 'mods/' + MOD_FOLDER + '/data/' + songLower + '/';
		var jsonPath:String = base + songLower + '.json';

		if (FileSystem.exists(jsonPath))
			return MOD_FOLDER;

		if (FileSystem.exists(base + songLower + '-hard.json'))
			return MOD_FOLDER;

		var modsPath:String = Paths.mods(MOD_FOLDER + '/data/' + songLower + '/' + songLower + '.json');

		if (FileSystem.exists(modsPath))
			return MOD_FOLDER;
		#end

		return null;
	}

	function pressButton(b:MenuButton)
	{
		if (selected)
			return;

		selected = true;
		FlxG.sound.play(Paths.sound('confirmMenu'));
		b.spr.color = 0xFFFFFFFF;
		b.spr.animation.play('press', true);

		FlxTween.tween(flash, {alpha: 0.85}, 0.1, {
			ease: FlxEase.quadOut,
			onComplete: function(t:FlxTween)
			{
				FlxTween.tween(flash, {alpha: 0}, 0.2, {ease: FlxEase.quadIn});
			}
		});

		for (other in buttons)
		{
			if (other != b)
				FlxTween.tween(other.spr, {alpha: 0}, 0.35, {ease: FlxEase.quadIn});
		}

		FlxTween.tween(transition, {alpha: 1}, 0.65, {
			startDelay: 0.18,
			ease: FlxEase.quadIn,
			onComplete: function(t:FlxTween)
			{
				goTo(b.name);
			}
		});
	}

	function resetButtons()
	{
		selected = false;
		transition.alpha = 0;
		flash.alpha = 0;

		for (b in buttons)
		{
			b.spr.alpha = 1;
			b.spr.color = 0xFFB4B4B4;
			b.spr.animation.play('idle', true);
		}

		hovered = null;
	}

	function goTo(name:String)
	{
		switch (name)
		{
			case 'play':
				try
				{
					var songLower:String = Paths.formatToSongPath(SONG_NAME);
					var modDir:String = findSongMod(songLower);

					if (modDir == null)
					{
						trace('Song chart not found in mods/' + MOD_FOLDER + '/data/' + songLower + '/');
						resetButtons();
						return;
					}

					Mods.currentModDirectory = modDir;
					Difficulty.resetList();

					var diffIndex:Int = Difficulty.list.indexOf('hard');

					if (diffIndex < 0)
						diffIndex = Difficulty.list.indexOf('Hard');

					if (diffIndex < 0)
						diffIndex = 2;

					var songJson:String = songLower + '-hard';

					PlayState.SONG = Song.loadFromJson(songJson, songLower);
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = diffIndex;

					if (FlxG.sound.music != null)
						FlxG.sound.music.volume = 0;

					LoadingState.prepareToSong();
					LoadingState.loadAndSwitchState(new PlayState());
				}
				catch (e:Dynamic)
				{
					trace('ERROR loading song "' + SONG_NAME + '": ' + e);
					resetButtons();
				}

			case 'credits':
				MusicBeatState.switchState(new CreditsState());

			case 'options':
				OptionsState.onPlayState = false;
				MusicBeatState.switchState(new OptionsState());
		}
	}

	override function update(elapsed:Float)
	{
		var targetX:Float = (FlxG.mouse.x / FlxG.width - 0.5) * 2;
		var targetY:Float = (FlxG.mouse.y / FlxG.height - 0.5) * 2;

		var k:Float = Math.min(1, elapsed * SMOOTH);
		camX += (targetX - camX) * k;
		camY += (targetY - camY) * k;

		for (l in layers)
		{
			l.spr.x = -camX * MAX_MOVE_X * l.depth;
			l.spr.y = -camY * MAX_MOVE_Y * l.depth;
		}

		if (!selected)
		{
			var nowHover:MenuButton = getHoveredButton();

			if (nowHover != hovered)
			{
				if (hovered != null)
				{
					hovered.spr.color = 0xFFB4B4B4;
					hovered.spr.animation.play('idle', true);
				}

				if (nowHover != null)
				{
					nowHover.spr.color = 0xFFFFFFFF;
					nowHover.spr.animation.play('press', true);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}

				hovered = nowHover;
			}

			if (FlxG.mouse.justPressed && hovered != null)
				pressButton(hovered);

			if (FlxG.keys.justPressed.ESCAPE)
			{
				selected = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));

				FlxTween.tween(transition, {alpha: 1}, 0.5, {
					ease: FlxEase.quadIn,
					onComplete: function(t:FlxTween)
					{
						MusicBeatState.switchState(new TitleState());
					}
				});
			}
		}

		super.update(elapsed);
	}

	override function destroy()
	{
		FlxG.mouse.visible = false;
		super.destroy();
	}
}
