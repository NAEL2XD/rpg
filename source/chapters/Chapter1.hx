package chapters;

import haxe.Timer;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import util.Dialogue;

class Chapter1_1 extends FlxState {
    var player:Player = new Player();
    var up:FlxSprite = new FlxSprite().loadGraphic("assets/images/up.png");

    override function create() {
        var house:FlxSprite = new FlxSprite().loadGraphic("assets/images/world/house/0.png");
        house.antialiasing = false;
        house.scale.set(10, 10);
        house.updateHitbox();
        house.screenCenter();
        add(house);

        player.x = 86;
        player.posY = 196;
        player.limitXPos = [0, 616];
        player.checkMovement();
        player.cutscene = true;
        player.playSound("yawn");
        add(player);

        up.x = 551;
        up.y = 131;
        up.scale.set(1.5, 1.5);
        up.updateHitbox();
        add(up);

        FlxG.camera.flash(0xFF000000, 2, function() {
            var state = new Dialogue([{
                dID: "houseWake1",
                char: player
            }, {
                dID: "houseWake2",
                char: player
            }, {
                dID: "houseWake3",
                char: player
            }]);

            state.closeCallback = function() {
                player.cutscene = false;
                FlxG.sound.playMusic("assets/music/plains.ogg");
            }

            openSubState(state);
        });

        super.create();
    }

    override function update(elapsed:Float) {
        player.checkMovement();

        up.alpha = 1.5 - (FlxMath.distanceBetween(player, up) / 100);
        up.y = 133 + (Math.sin(Timer.stamp()) * 4);
        if (!player.cutscene) {
            if (FlxMath.distanceBetween(player, up) < 50 && FlxG.keys.justPressed.UP) {
                FlxG.sound.play("assets/sounds/door_open.ogg");
                player.cutscene = false;

                var black:FlxSprite = new FlxSprite().makeGraphic(640, 360, 0xFF000000);
                black.alpha = 0;
                FlxTween.tween(black, {alpha: 1}, 1, {onComplete: e -> {
                    var snd:FlxSound = FlxG.sound.load("assets/sounds/door_close.ogg");
                    snd.onComplete = function() {
                        var state = new Dialogue([{
                            dID: "shocked",
                            char: player
                        }]);
                    
                        openSubState(state);
                    };
                    snd.play();
                }});
                add(black);

                FlxTween.num(FlxG.sound.music.volume, 0, 1, {}, e -> {
                    FlxG.sound.music.volume = e;
                });
            }
        }

        super.update(elapsed);
    }
}