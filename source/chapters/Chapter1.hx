package chapters;

import util.Entering;
import util.Battle;
import flixel.util.FlxTimer;
import haxe.Timer;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import util.Dialogue;

class Chapter1_1 extends FlxState {
    var player:Player = new Player();
    var up:Entering = null;

    override function create() {
        super.create();

        if (FlxG.save.data.c1_1.done == null) {
            FlxG.save.data.c1_1.done = false;
        }

        var house:FlxSprite = new FlxSprite().loadGraphic("assets/images/world/house/0.png");
        house.antialiasing = false;
        house.scale.set(10, 10);
        house.updateHitbox();
        house.screenCenter();
        add(house);

        player.x = FlxG.save.data.c1_1.done ? 530 : 86;
        player.posY = 196;
        player.checkMovement();
        player.cutscene = !FlxG.save.data.c1_1.done;
        add(player);

        up = new Entering({
            x: 551,
            y: 133,
            closeTo: 75,
            switchTo: Chapter1_2.new,
            player: player,
            state: this,
            dialogue: !FlxG.save.data.c1_1.done ? new Dialogue([{
                dID: "shocked1",
                char: player
            }, {
                dID: "shocked2",
                char: player
            }]) : null,
            fadeOutMusic: !FlxG.save.data.c1_1.done
        });
        add(up);

        FlxG.camera.flash(0xFF000000, 2, function() {
            if (!FlxG.save.data.c1_1.done) {
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
            }
        });

        if (!FlxG.save.data.c1_1.done) {
            player.playSound("yawn");
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        player.checkMovement();
        up.checkMovement();
    }
}

class Chapter1_2 extends FlxState {
    var player:Player = new Player();
    var outside:FlxSprite = new FlxSprite().loadGraphic("assets/images/world/houseOutside/0.png");
    var noobs:Array<FlxSprite> = [];
    var noobsCopy:Array<FlxSprite> = [];

    var jumped:Bool = false;
    var readyToAttack:Bool = false;

    var house:Entering = null;
    var woods:Entering = null;

    override function create() {
        super.create();

        if (FlxG.save.data.c1_2.done == null) {
            FlxG.save.data.c1_2.done = false;
        }

        outside.antialiasing = false;
        outside.scale.set(10, 10);
        outside.updateHitbox();
        outside.screenCenter();
        add(outside);

        if (!FlxG.save.data.c1_2.done) {
            for (i in 0...2) {
                noobs.push(new FlxSprite().makeGraphic(28, 28, 0xFFFF0000));
                noobs[i].x = 220 + (70 * i);
                noobs[i].y = 222;
                add(noobs[i]);
            }
        }

        if (!FlxG.save.data.c1_2.done) {
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
        } else {
            FlxG.camera.flash(0xFF000000);
        }

        player.x = 40;
        player.posY = FlxG.save.data.c1_2.done ? 226 : 186;
        player.cutscene = !FlxG.save.data.c1_2.done;
        player.checkMovement();
        add(player);

        // Replace: noobsCopy = noobs;
        noobsCopy = [for (noob in noobs) {
            var copy = new FlxSprite(noob.x, noob.y).makeGraphic(28, 28, 0xFFFF0000);
            copy.visible = false;
            copy.x += 200;
            add(copy);
            copy;
        }];

        house = new Entering({
            x: 11,
            y: 170,
            closeTo: 70,
            switchTo: Chapter1_1.new,
            player: player,
            state: this
        });
        add(house);

        woods = new Entering({
            x: 580,
            y: 170,
            closeTo: 70,
            switchTo: Chapter1_3.new,
            player: player,
            state: this
        });
        add(woods);

        FlxG.save.data.c1_1.done = true;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        player.checkMovement();
        house.checkMovement();
        woods.checkMovement();

        if (jumped) {
            player.jump(false, -60);

            if (FlxG.overlap(player, noobs[0]) && readyToAttack) {
                var battle = new Battle({
                    enemyData: [{
                        hp: 8,
                        enemy: noobs[0],
                        name: "Gang I"
                    }, {
                        hp: 8,
                        enemy: noobs[1],
                        name: "Gang II"
                    }],
                    background: "houseOut",
                    extraDialogues: new Dialogue([{
                        dID: "battleEnemy1",
                        char: noobs[0]
                    }, {
                        dID: "battleEnemy2",
                        char: player
                    }]),
                    startASYourTurn: true
                });

                battle.closeCallback = function() {
                    new FlxTimer().start(0.1, e -> {
                        player.lockedVM = 0;
                        player.posY = 226;
                        player.resetJump();

                        for (noob in noobsCopy) {
                            noob.visible = true;
                        }

                        var shock = new Dialogue([{
                            dID: "battleEnemy3",
                            char: noobsCopy[0]
                        }, {
                            dID: "battleEnemy4",
                            char: noobsCopy[1]
                        }, {
                            dID: "battleEnemy5",
                            char: noobsCopy[0]
                        }]);

                        shock.closeCallback = function() {
                            var i:Int = 0;
                            for (noo in noobsCopy) {
                                FlxTween.tween(noo, {x: noo.x + 240}, 2, {onComplete: e -> {
                                    i++;
                                    if (i == 2) {
                                        var state = new Dialogue([{
                                            dID: "battleEnemy6",
                                            char: player
                                        }, {
                                            dID: "battleEnemy7",
                                            char: player
                                        }, {
                                            dID: "battleEnemy8",
                                            char: player
                                        }]);

                                        state.closeCallback = function() {
                                            FlxG.sound.playMusic("assets/music/plains.ogg");
                                            player.cutscene = false;
                                            jumped = false;
                                            FlxG.save.data.c1_2.done = true;
                                        }

                                        openSubState(state);
                                    }

                                    noo.destroy();
                                }});
                            }
                        }

                        openSubState(shock);
                    });
                };

                openSubState(battle);
            }
        }
    }
}

class Chapter1_3 extends FlxState {
    var player:Player = new Player();
    var enemy:FlxSprite = new FlxSprite().makeGraphic(128, 8, 0xFFFF0000);

    override function create() {
        super.create();

        if (FlxG.save.data.c1_3.done == null) {
            FlxG.save.data.c1_3.done = false;
        }

        player.x = 40;
        player.posY = 226;
        player.checkMovement();
        add(player);

        enemy.x = 320;
        enemy.y = 226;
        add(enemy);
    }

    override function update(elapsed:Float) {
        player.checkMovement();

        if (FlxG.overlap(player, enemy)) {
            openSubState(new Battle({
                enemyData: [{
                    hp: 8,
                    enemy: enemy,
                    name: "Enemy"
                }],
                background: "houseOut",
                startASYourTurn: true,
                extraDialogues: new Dialogue([{
                    dID: "battleEnemy9",
                    char: enemy
                }, {
                    dID: "battleEnemy10",
                    char: player
                }, {
                    dID: "battleEnemy11",
                    char: player
                }]),
                battleMusic: "weird"
            }));
        }

        super.update(elapsed);
    }
}