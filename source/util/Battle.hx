package util;

import haxe.Timer;
import flixel.sound.FlxSound;
import flixel.util.FlxSpriteUtil;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import util.Dialogue;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

typedef BattleEnemies = {
    hp:Int,
    enemy:FlxObject,
    name:String,
    damage:Int,
    defense:Int,
    ?defeated:Bool,
    ?enemyID:Int,
    ?nextTurn:Int
}

typedef BattleMetadata = {
    enemyData:Array<BattleEnemies>,
    background:String,
    startASYourTurn:Bool,
    ?extraDialogues:Dialogue,
    ?battleStart:String,
    ?battleMusic:String,
    ?battleEnd:String,
}

class Battle extends FlxSubState {
    var transitions:Array<FlxSprite> = [];
    var bg:FlxSprite = new FlxSprite();
    
    var player:Player = new Player();
    var playerRememberPos:Array<Float> = [];
    var playerCanControl:Bool = false;
    var playerPressTime:Float = 0;
    var playerDidPress:Bool = false;
    var playerHPStuff:Array<FlxSprite> = [];
    var playerHPText:FlxText = new FlxText(10, 10, 640).setFormat("assets/fonts/hp.ttf", 20);
    
    var battle:BattleMetadata = null; 
    var battleInProgress:Bool = true;
    var battleChosen:Bool = false;
    var battleWhoToBattle:Int = 0;
    var battleResults:Bool = false;
    var battleEnemiesX:Array<Float> = [];

    var cutscene:Bool = true;
    var isYourTurn:Bool = false;
    var opponentName:FlxText = new FlxText(8, 8, 640).setFormat("assets/fonts/main.ttf", 24);
    var canPressToExit:Bool = false;
    
    var blocks:Array<FlxSprite> = [];
    var blocksShowedUp:Bool = false;
    var blockIndex:Int = 0;
    var blocksMoved:Bool = false;

    var win:FlxSound = null;
    var begin:FlxSound = null;

    var action:FlxSound = FlxG.sound.load("assets/sounds/action_s.ogg");

    public function new(battleData:BattleMetadata) {
        blocks = [];
        playerHPStuff = [];

        cutscene = true;
        battleInProgress = true;
        battleChosen = false;
        playerCanControl = false;
        playerDidPress = false;
        battleResults = false;
        canPressToExit = false;

        opponentName.visible = false;

        battle = battleData;

        super(0);
    }

    override function create() {
        super.create();

        if (FlxG.sound.music != null) {
            FlxG.sound.music.destroy();
        }

        FlxG.sound.play("assets/sounds/player/hereWeGo.ogg");
        
        new FlxTimer().start(0.9, e -> {
            win   = FlxG.sound.load('assets/music/battle/${battle.battleEnd == null ? "battleWin" : battle.battleEnd}.ogg');
            begin = FlxG.sound.load('assets/music/battle/${battle.battleMusic == null ? "battleLoop" : battle.battleMusic}.ogg');
            var start:FlxSound = FlxG.sound.load('assets/music/battle/${battle.battleStart == null ? "battleStart" : battle.battleStart}.ogg');

            start.play();
            start.onComplete = function() {
                begin.looped = true;
                begin.play();
            };
        });

        final pos:Array<Array<Int>> = [[0, -360], [640, 0], [0, 360], [-640, 0]];
        for (i in pos) {
            var l:Int = transitions.length;
            transitions.push(new FlxSprite().makeGraphic(640, 360, 0xFF000000));
            transitions[l].alpha = 0;
            transitions[l].x = i[0];
            transitions[l].y = i[1];

            FlxTween.tween(transitions[l], {alpha: 1, x: 0, y: 0}, 1.2, {onComplete: e -> {
                if (l == 3) {
                    final index:Int = members.indexOf(transitions[0]);
                    bg.loadGraphic('assets/images/battleBGs/${battle.background}.png');
                    bg.antialiasing = false;
                    bg.scale.set(10, 10);
                    bg.updateHitbox();
                    bg.screenCenter();
                    insert(index, bg);

                    player.x = 70;
                    player.posY = 235;
                    player.inBattle = true;
                    playerRememberPos = [70, 235];
                    insert(index + 1, player);

                    l = battle.enemyData.length-1;
                    var k:Int = 0;
                    final pos2:Array<Array<Array<Float>>> = [
                        [[480, 235]],
                        [[480, 200], [480, 270]]
                    ];

                    isYourTurn = battle.startASYourTurn;
                    for (e in battle.enemyData) {
                        e.enemyID = k;
                        e.enemy.x = pos2[l][k][0];
                        e.enemy.y = pos2[l][k][1];
                        e.enemy.visible = true;
                        e.nextTurn = k+1 + (isYourTurn ? 1 : 0);
                        insert(index + 1, e.enemy);
                        battleEnemiesX.push(e.enemy.x);
                        k++;
                    }

                    final blockName:Array<String> = ["jump"];
                    for (block in blockName) {
                        final n:Int = blocks.length;
                        blocks.push(new FlxSprite().loadGraphic('assets/images/$block.png'));
                        blocks[n].alpha = 0;
                        blocks[n].scale.set(1.6, 1.6);
                        add(blocks[n]);
                    }

                    k = 0;
                    for (m in pos) {
                        FlxTween.tween(transitions[k], {alpha: 0, x: m[0], y: m[1]}, 1.2, {onComplete: e -> {
                            if (m[0] == -640) {
                                function start() {
                                    cutscene = false;
                                    battleInProgress = false;
                                    nextTurn();
                                }

                                if (battle.extraDialogues != null) {
                                    var state = battle.extraDialogues;
                                    state.closeCallback = function() {
                                        start();
                                    };

                                    openSubState(state);
                                } else {
                                    start();
                                }
                            }
                        }});
                        
                        k++;
                    }

                    for (h in 0...2) {
                        var hpStuff:FlxSprite = new FlxSprite().makeGraphic(72 - (h * 4), 28 - (h * 4), h == 0 ? 0xFF000000 : 0xFFFF0000);
                        hpStuff.x = 8 + (h * 2);
                        hpStuff.y = 8 + (h * 2);
                        playerHPStuff.push(hpStuff);
                        insert(index + (2 + h), playerHPStuff[h]);
                    }

                    playerHPText.x = 12;
                    playerHPText.y = 10;
                    insert(index + 4, playerHPText);

                    opponentName.scale.set(0.6, 0.6);
                    opponentName.updateHitbox();
                    add(opponentName);
                }
            }});

            add(transitions[l]);
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        player.checkMovement();

        playerHPText.text = '${FlxG.save.data.player.HP} / ${FlxG.save.data.player.maxHP}';

        if (cutscene) {
            return;
        }

        opponentName.visible = battleChosen;
        if (battleChosen) {
            var data:BattleEnemies = battle.enemyData[battleWhoToBattle];
            opponentName.text = data.name;
            opponentName.x = data.enemy.x - (data.enemy.width / 2);
            opponentName.y = (data.enemy.y - 12) + (Math.sin(Timer.stamp()) * 4);

            function change(scroll:Int, ?playSound:Bool = true) {
                action.play(true);
                battleWhoToBattle += scroll;
            }

            var ind:Int = 0;
            for (enemy in battle.enemyData) {
                FlxSpriteUtil.setBrightness(cast(enemy.enemy, FlxSprite), ind == battleWhoToBattle ? 0.5 : 0);
                ind++;
            }

            if (FlxG.keys.anyJustPressed([Q, A, LEFT]) && battleWhoToBattle != 0) {
                change(-1);
            } else if (FlxG.keys.anyJustPressed([D, RIGHT]) && battleWhoToBattle != battle.enemyData.length - 1) {
                change(1);
            } else if (FlxG.keys.anyJustPressed([BACKSPACE, ESCAPE])) {
                for (enemy in battle.enemyData) {
                    FlxSpriteUtil.setBrightness(cast(enemy.enemy, FlxSprite), 0);
                }

                battleChosen = false;
            } else if (FlxG.keys.justPressed.SPACE) {
                for (enemy in battle.enemyData) {
                    FlxSpriteUtil.setBrightness(cast(enemy.enemy, FlxSprite), 0);
                }

                battleChosen = false;
                battleInProgress = true;
                
                FlxG.sound.play("assets/sounds/action_c.ogg");
                
                FlxTween.tween(player, {x: data.enemy.x - 60, posY: data.enemy.y}, 0.8, {onComplete: e -> {
                    playerCanControl = true;
                    playerDidPress = false;
                    switch(blockIndex) {
                        case 0: // Jump
                            player.jump(true, 0, 12);
                            FlxTween.tween(player, {x: data.enemy.x}, 0.5);
                            playerPressTime = Timer.stamp() + .76;

                            new FlxTimer().start(.76, e -> {
                                if (playerCanControl) {
                                    battle.enemyData[battleWhoToBattle] = dealDamage(battle.enemyData[battleWhoToBattle], 2);
                                    playerTurnJump();
                                    playerCanControl = false;
                                }
                            });
                    }
                }});
            }
        } else if (!battleInProgress) {
            if (isYourTurn) {
                if (battle.enemyData.length == 0) {
                    if (!battleResults) {
                        begin.stop();
                        win.play();

                        var white:FlxSprite = new FlxSprite().makeGraphic(999, 999);
                        white.alpha = 0;
                        FlxTween.tween(white, {alpha: 0.4}, 0.6);
                        insert(members.indexOf(bg) + 1, white);

                        FlxTween.tween(player, {x: 308}, 0.6);

                        var text:FlxText = new FlxText(0, 0, 640, "Battle Results").setFormat("assets/fonts/main.ttf", 32, 0xFF000000, CENTER);
                        text.y = -64;
                        FlxTween.tween(text, {y: 24}, 0.6, {onComplete: e -> {
                            canPressToExit = true;
                        }});
                        add(text);

                        battleResults = true;
                    } else if (canPressToExit && FlxG.keys.justPressed.SPACE) {
                        FlxTween.tween(begin, {volume: 0}, 1.2);

                        for (l in 0...4) {
                            FlxTween.tween(transitions[l], {alpha: 1, x: 0, y: 0}, 1.2, {onComplete: e -> {
                                if (l == 3) {
                                    close();
                                }
                            }});
                        }
                    }
                } else {
                    function change(scroll:Int) {
                        action.play(true);
                        blockIndex += scroll;
                        blocksMoved = false;

                        var ind:Int = 0;
                        for (block in blocks) {
                            FlxTween.tween(block, {x: 71 + (36 * (blockIndex + ind)), alpha: 1}, 0.2, {onComplete: e -> {
                                blocksMoved = true;
                            }});
                            ind++;
                        }
                    }

                    if (!blocksShowedUp) {
                        var index:Int = 0;

                        for (block in blocks) {
                            block.x = 107 + (index * 36);
                            block.y = 178;
                            FlxTween.tween(block, {x: block.x - 36, alpha: 1}, 0.66, {ease: FlxEase.sineOut, onComplete: e -> {
                                blocksMoved = true;

                                if (battleChosen) {
                                    block.alpha = 0;
                                }
                            }});
                        }

                        blocksShowedUp = true;
                    }

                    if (blocksMoved) {
                        if (FlxG.keys.anyJustPressed([Q, A, LEFT]) && blockIndex != 0) {
                            change(-1);
                        } else if (FlxG.keys.anyJustPressed([D, RIGHT]) && blockIndex != blocks.length - 1) {
                            change(1);
                        } else if (FlxG.keys.justPressed.SPACE) {
                            FlxG.sound.play("assets/sounds/action_c.ogg");
                            player.jump(true, 0, 6.5);

                            for (block in blocks) {
                                FlxTween.tween(block, {alpha: 0}, 0.25, {ease: FlxEase.linear});
                            }

                            blocksShowedUp = false;
                            battleChosen = true;
                            blocksMoved = false;
                            battleWhoToBattle = 0;
                        }
                    }
                }
            }
        }

        if (playerCanControl && !playerDidPress) {
            switch(blockIndex) {
                case 0: // Jump
                    if (FlxG.keys.justPressed.SPACE && playerPressTime - Timer.stamp() < 0.075) {
                        playerCanControl = false;
                        playerTurnJump();
                        rating(1);
                        battle.enemyData[battleWhoToBattle] = dealDamage(battle.enemyData[battleWhoToBattle], 3);
                    }
            }

            if (FlxG.keys.justPressed.SPACE) {
                playerDidPress = true;
            }
        }

        for (enemy in battle.enemyData) {
            if (enemy.defeated) {
                battle.enemyData.remove(enemy);
            }
        }
    }

    function dealDamage(to:BattleEnemies, loseHp:Int, ?isPlayer:Bool = false):BattleEnemies {
        final lucky:Bool = FlxG.random.bool(10);

        if (!isPlayer) {
            loseHp -= to.defense;
            loseHp = loseHp < 0 ? 0 : loseHp;
        } else {
            loseHp = to.damage;
        }

        final goY:Int = (loseHp < 18 ? 18 : loseHp) - 18;
        if (lucky && !isPlayer) {
            FlxG.sound.play("assets/sounds/LuckyHit.ogg");

            var lucky:FlxSprite = new FlxSprite().loadGraphic("assets/images/lucky.png");
            lucky.scale.set(0.7, 0.7);
            lucky.updateHitbox();
            lucky.x = to.enemy.x - 18;
            lucky.y = to.enemy.y - 44 - goY;
            FlxTween.tween(lucky, {x: lucky.x + 24, y: lucky.y - 36}, 1.2, {ease: FlxEase.sineOut, onComplete: e -> {
                FlxTween.tween(lucky, {"scale.y": 1.4, alpha: 0}, 0.4, {onComplete: e -> {
                    lucky.destroy();
                }});
            }});
            add(lucky);

            loseHp = Std.int(loseHp * 1.75);
        }

        var damage:FlxText = new FlxText((isPlayer ? player.x : to.enemy.x) + 4, (isPlayer ? player.y : to.enemy.y) - 24 - goY, 640, '${loseHp}').setFormat("assets/fonts/hpDeal.ttf", loseHp < 18 ? 18 : loseHp, isPlayer ? 0xFFFF0000 : lucky ? 0xFF31c694 : 0xFFFF9100, LEFT, OUTLINE, isPlayer ? 0xFFA30000 : lucky ? 0xFF21ad73 : 0xFFBD5500);
        damage.scale.set(1.4, 1.4);
        damage.updateHitbox();
        FlxTween.tween(damage, {x: damage.x + 24, y: damage.y - 36}, 1.2, {ease: FlxEase.sineOut, onComplete: e -> {
            FlxTween.tween(damage, {"scale.y": 2.4, alpha: 0}, 0.4, {onComplete: e -> {
                damage.destroy();
            }});
        }});
        add(damage);

        if (!isPlayer) {
            to.hp -= loseHp;
            if (to.hp < 1) {
                final old:FlxObject = to.enemy;
                for (i in 0...100) {
                    new FlxTimer().start(0.003 * i, e -> {
                        var a:FlxSprite = new FlxSprite().makeGraphic(Std.int(old.width), Std.int(old.height), FlxG.random.color(0xFF000000, 0xFFFFFFFF));
                        a.x = old.x;
                        a.y = old.y;
                        a.acceleration.y = 500;
                        a.velocity.x = FlxG.random.float(-80, 80);
                        a.velocity.y = FlxG.random.float(-200, -350);
                        FlxTween.tween(a, {angle: FlxG.random.float(-60, 60), alpha: 0, "scale.x": 0, "scale.y": 0}, 0.8, {onComplete: e -> {
                            a.destroy();
                        }});
                        add(a);
                    });
                }
    
                to.enemy.visible = false;
                to.defeated = true;
                
                FlxG.sound.play("assets/sounds/enemyDefeat.ogg");
            } else {
                to.enemy.x += 8;
                FlxTween.cancelTweensOf(to.enemy);
                FlxTween.tween(to.enemy, {x: battleEnemiesX[to.enemyID]}, 0.4, {ease: FlxEase.cubeOut});
                FlxG.sound.play("assets/sounds/enemyDamage.ogg");
            }
        } else {
            for (i in 0...loseHp) {
                new FlxTimer().start((1 / loseHp) * i, e -> {
                    FlxG.save.data.player.HP--;
                });
            }

            FlxG.sound.play("assets/sounds/enemyDamage.ogg");
        }

        return to;
    }

    function playerTurnJump() {
        player.jump(true, 0, 9);

        FlxTween.tween(player, {x: 200}, 0.8, {onComplete: e -> {
            FlxTween.tween(player, {x: playerRememberPos[0], posY: playerRememberPos[1]}, 0.7, {onComplete: e -> {
                nextTurn();
            }});
        }});
    }

    function rating(id:Int) {
        var sprite:FlxSprite = new FlxSprite();
        sprite.y = 60;
        sprite.angle = FlxG.random.float(-4, 4);

        switch(id) {
            case 1: {
                sprite.loadGraphic("assets/images/good.png");
                sprite.scale.set(2.4, 2.4);
                sprite.updateHitbox();
                sprite.x = 640;
                FlxG.sound.play("assets/sounds/rating/good.ogg");
            }
        }

        new FlxTimer().start(1.2, e -> {
            FlxTween.tween(sprite, {"scale.x": 0, "scale.y": 0}, 0.25, {onComplete: e -> {
                sprite.destroy();
            }});
        });

        FlxTween.tween(sprite, {x: sprite.x - sprite.width - 14}, 0.1);
        sprite.antialiasing = false;
        add(sprite);
    }

    function nextTurn() {
        var canBeYourTurn:Bool = true;

        for (enemy in battle.enemyData) {
            enemy.nextTurn--;
            if (enemy.nextTurn == 0) {
                canBeYourTurn = false;

                final remPos:Array<Float> = [enemy.enemy.x, enemy.enemy.y];
                enemy.nextTurn = battle.enemyData.length;

                FlxTween.tween(enemy.enemy, {x: playerRememberPos[0] + 8, y: playerRememberPos[1]}, 1, {onComplete: e -> {
                    dealDamage(enemy, 1, true);
                    FlxTween.tween(enemy.enemy, {x: remPos[0], y: remPos[1]}, 1, {onComplete: e -> {
                        battleInProgress = false;
                        isYourTurn = true;
                    }});
                }});
            }
        }

        isYourTurn = canBeYourTurn;
        battleInProgress = !canBeYourTurn;
    }
}