package util;

import haxe.Timer;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import util.Dialogue;
import flixel.math.FlxMath;
import flixel.util.typeLimit.NextState;

typedef EnteringData = {
    x:Float,
    y:Float,
    closeTo:Int,
    switchTo:NextState,
    player:Player,
    state:FlxState,
    ?dialogue:Dialogue,
    ?soundIfEnter:String,
    ?soundIfExit:String
}

class Entering extends FlxSprite {
    private var dataStr:EnteringData = null;
    private var snd:FlxSound = null;

    public function new(data:EnteringData) {
        super();

        loadGraphic("assets/images/up.png");

        x  = data.x;
        y  = data.y;
        dataStr = data;

        snd = FlxG.sound.load('assets/sounds/${data.dataStr == null ? "door_close" : data.dataStr}.ogg');

        scale.set(1.5, 1.5);
        updateHitbox();
    }

    public function checkMovement() {
        alpha = 1.5 - (FlxMath.distanceBetween(dataStr.player, this) / 100);
        y = 133 + (Math.sin(Timer.stamp()) * 4);
        
        if (FlxMath.distanceBetween(dataStr.player, this) < 80 && FlxG.keys.anyJustPressed([Z, W, UP])) {
            var black:FlxSprite = new FlxSprite().makeGraphic(640, 360, 0xFF000000);
            black.alpha = 0;
            FlxG.sound.load('assets/sounds/${dataStr.soundIfEnter == null ? "door_open" : dataStr.soundIfEnter}.ogg');
            FlxTween.tween(black, {alpha: 1}, 1, {onComplete: e -> {
                snd.onComplete = function() {
                    if (dataStr.dialogue != null) {
                        dataStr.dialogue.closeCallback = function() {
                            FlxG.switchState(dataStr.switchTo);
                        }
                        
                        dataStr.state.openSubState(dataStr.dialogue);
                    } else {
                        FlxG.switchState(dataStr.switchTo);
                    }
                };
                snd.play();
            }});

            dataStr.player.cutscene = true;
            dataStr.state.add(black);

            if (FlxG.sound.music != null) {
                FlxTween.num(FlxG.sound.music.volume, 0, 1, {}, e -> {
                    FlxG.sound.music.volume = e;
                });
            }
        }
    }
}