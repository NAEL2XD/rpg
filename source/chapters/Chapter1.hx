package chapters;

import util.Battle;
import flixel.util.FlxTimer;
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
            }, {
                dID: "houseWake4",
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
            if (FlxMath.distanceBetween(player, up) < 80 && FlxG.keys.anyJustPressed([Z, W, UP])) {
                FlxG.sound.play("assets/sounds/door_open.ogg");
                player.cutscene = true;

                var black:FlxSprite = new FlxSprite().makeGraphic(640, 360, 0xFF000000);
                black.alpha = 0;
                FlxTween.tween(black, {alpha: 1}, 1, {onComplete: e -> {
                    var snd:FlxSound = FlxG.sound.load("assets/sounds/door_close.ogg");
                    snd.onComplete = function() {
                        var state = new Dialogue([{
                            dID: "shocked1",
                            char: player
                        }, {
                            dID: "shocked2",
                            char: player
                        }]);
                    
                        state.closeCallback = function() {
                            FlxG.switchState(Chapter1_2.new);
                        }
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

class Chapter1_2 extends FlxState {
    var player:Player = new Player();
    var outside:FlxSprite = new FlxSprite().loadGraphic("assets/images/world/houseOutside/0.png");
    var noobs:Array<FlxSprite> = [];
    
    var jumped:Bool = false;
    var readyToAttack:Bool = false;

    override function create() {
        outside.antialiasing = false;
        outside.scale.set(10, 10);
        outside.updateHitbox();
        outside.screenCenter();
        add(outside);

        for (i in 0...2) {
            noobs.push(new FlxSprite().makeGraphic(28, 28, 0xFF000000));
            noobs[i].x = 220 + (70 * i);
            noobs[i].y = 222;
            add(noobs[i]);
        }

        FlxG.sound.playMusic("assets/music/serious.ogg");

        FlxG.camera.flash(0xFF000000, 2, function() {
            var state = new Dialogue([{
                dID: "houseEnemyApproach1",
                char: player
            }, {
                dID: "houseEnemyApproach2",
                char: noobs[0]
            }, {
                dID: "houseEnemyApproach3",
                char: noobs[1]
            }, {
                dID: "houseEnemyApproach4",
                char: player
            }, {
                dID: "houseEnemyApproach5",
                char: noobs[0]
            }, {
                dID: "houseEnemyApproach6",
                char: player
            }, {
                dID: "houseEnemyApproach7",
                char: noobs[1]
            }, {
                dID: "houseEnemyApproach8",
                char: player
            }, {
                dID: "houseEnemyApproach9",
                char: noobs[0]
            }]);

            state.closeCallback = function() {
                player.lockedVM = 5.25;
                player.jump(true);

                readyToAttack = true;
                jumped = true;
            }

            openSubState(state);
        });

        player.x = 40;
        player.posY = 186;
        player.cutscene = true;
        player.limitXPos = [0, 616];
        player.checkMovement();
        add(player);

        super.create();
    }

    override function update(elapsed:Float) {
        player.checkMovement();

        if (jumped) {
            player.jump(false, -60);

            if (FlxG.overlap(player, noobs[0]) && readyToAttack) {
                openSubState(new Battle({
                    enemyData: [{
                        hp: 5,
                        enemy: noobs[0],
                        name: "Gang I"
                    }, {
                        hp: 5,
                        enemy: noobs[1],
                        name: "Gang II"
                    }],
                    background: "houseOut",
                    extraDialogues: new Dialogue([{
                        dID: "battleEnemy1",
                        char: noobs[0]
                    }])
                }));
            }
        }

        super.update(elapsed);
    }
}