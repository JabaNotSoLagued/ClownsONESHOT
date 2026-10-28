
package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.sound.FlxSound;

class TitleState extends MusicBeatState
{
    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
    public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
    public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
    public static var initialized:Bool = false;
    public static var closedState:Bool = false;

    var ohyeah:FlxSprite;
    var tape:FlxSprite;
    var prompt:FlxText;
    var black:FlxSprite;

    var started:Bool = false;
    var transitioning:Bool = false;
    var skippedIntro:Bool = false;

    var tapeFloatTween:FlxTween;
    var introTimer:FlxTimer;

    override public function create():Void
    {
        Paths.clearStoredMemory();
        super.create();
        Paths.clearUnusedMemory();

        if (!initialized)
            ClientPrefs.loadPrefs();

        Language.reloadPhrases();

        persistentUpdate = true;
        persistentDraw = true;
        FlxG.mouse.visible = false;

        if (FlxG.save.data.weekCompleted == null)
            FlxG.save.data.weekCompleted = [];

        if (FlxG.save.data.flashing == null && !FlashingState.leftState)
        {
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;
            MusicBeatState.switchState(new FlashingState());
            return;
        }

        startIntro();
    }

    function startIntro():Void
    {
        if (FlxG.sound.music != null)
            FlxG.sound.music.stop();

        ohyeah = new FlxSprite();
        ohyeah.loadGraphic(Paths.image('ohyeah'));
        ohyeah.setGraphicSize(300, 300);
        ohyeah.updateHitbox();
        ohyeah.antialiasing = ClientPrefs.data.antialiasing;
        ohyeah.screenCenter();
        ohyeah.alpha = 0;
        add(ohyeah);

        tape = new FlxSprite();
        tape.loadGraphic(Paths.image('tape'));
        tape.setGraphicSize(Std.int(FlxG.width * 0.48));
        tape.updateHitbox();
        tape.antialiasing = ClientPrefs.data.antialiasing;
        tape.screenCenter();
        tape.y -= 30;
        tape.alpha = 0;
        add(tape);

        prompt = new FlxText(0, tape.y + tape.height + 35, FlxG.width, 'PRESS SPACE TO START', 24);
        prompt.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        prompt.borderSize = 2;
        prompt.antialiasing = ClientPrefs.data.antialiasing;
        prompt.alpha = 0;
        add(prompt);

        black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        black.scrollFactor.set();
        black.alpha = 1;
        add(black);

        FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
        FlxG.sound.music.fadeIn(2, 0, 0.7);

        introTimer = new FlxTimer().start(0.8, function(timer:FlxTimer)
        {
            FlxTween.tween(black, {alpha: 0}, 1.2, {
                ease: FlxEase.quadOut,
                onComplete: function(tween:FlxTween)
                {
                    FlxTween.tween(ohyeah, {alpha: 1}, 0.8, {
                        ease: FlxEase.quadOut,
                        onComplete: function(tween:FlxTween)
                        {
                            introTimer = new FlxTimer().start(1.4, function(timer:FlxTimer)
                            {
                                FlxTween.tween(ohyeah, {alpha: 0}, 0.9, {
                                    ease: FlxEase.quadInOut,
                                    onComplete: function(tween:FlxTween)
                                    {
                                        FlxTween.tween(tape, {alpha: 1}, 1.8, {
                                            ease: FlxEase.quadOut,
                                            onComplete: function(tween:FlxTween)
                                            {
                                                startTapeFloat();

                                                FlxTween.tween(prompt, {alpha: 1}, 1, {
                                                    ease: FlxEase.quadOut
                                                });
                                            }
                                        });
                                    }
                                });
                            });
                        }
                    });
                }
            });
        });

        initialized = true;
    }

    function startTapeFloat():Void
    {
        if (transitioning || started)
            return;

        var baseY:Float = tape.y;

        tapeFloatTween = FlxTween.tween(tape, {y: baseY - 4}, 2.2, {
            ease: FlxEase.sineInOut,
            onComplete: function(tween:FlxTween)
            {
                if (!transitioning && !started)
                {
                    tapeFloatTween = FlxTween.tween(tape, {y: baseY + 4}, 2.2, {
                        ease: FlxEase.sineInOut,
                        onComplete: function(tween:FlxTween)
                        {
                            startTapeFloat();
                        }
                    });
                }
            }
        });
    }

    function beginGame():Void
    {
        if (started || transitioning)
            return;

        started = true;
        transitioning = true;
        closedState = true;

        if (introTimer != null)
            introTimer.cancel();

        if (tapeFloatTween != null)
            tapeFloatTween.cancel();

        FlxTween.cancelTweensOf(prompt);
        FlxTween.cancelTweensOf(tape);
        FlxTween.cancelTweensOf(ohyeah);

        FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

        FlxTween.tween(prompt, {alpha: 0}, 0.25, {
            ease: FlxEase.quadIn
        });

        FlxTween.tween(tape, {y: FlxG.height + tape.height}, 1.15, {
            ease: FlxEase.quadIn
        });

        if (FlxG.sound.music != null)
            FlxG.sound.music.fadeOut(1.5, 0);

        FlxTween.tween(black, {alpha: 1}, 1.5, {
            ease: FlxEase.quadIn,
            onComplete: function(tween:FlxTween)
            {
                if (FlxG.sound.music != null)
                    FlxG.sound.music.stop();

                MusicBeatState.switchState(new MainMenuState());
            }
        });
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!started && !transitioning && FlxG.keys.justPressed.SPACE)
            beginGame();

        if (!started && !transitioning && FlxG.keys.justPressed.ENTER)
            beginGame();
    }

    public function skipIntro():Void
    {
        skippedIntro = true;

        if (black != null)
            black.alpha = 0;
    }

    override function beatHit():Void
    {
        super.beatHit();
    }

    override function destroy():Void
    {
        if (introTimer != null)
            introTimer.cancel();

        if (tapeFloatTween != null)
            tapeFloatTween.cancel();

        super.destroy();
    }
}
