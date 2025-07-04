package util;

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
    name:String
}

typedef BattleMetadata = {
    enemyData:Array<BattleEnemies>,
    background:String,
    extraDialogues:Dialogue,
    startASYourTurn:Bool
}

class Battle extends FlxSubState {
    var oldSongPos:Float = 0;

    var transitions:Array<FlxSprite> = [];
    
    var player:Player = new Player();
    var playerRememberPos:Array<Float> = [];
    
    var battle:BattleMetadata = null; 
    var battleInProgress:Bool = true;
    var battleChosen:Bool = false;
    var battleWhoToBattle:Int = 0;
    var cutscene:Bool = true;
    var isYourTurn:Bool = false;
    var opponentName:FlxText = new FlxText(8, 8, 640).setFormat("assets/fonts/main.ttf", 24);
    var turnLeftTillOpponent:Int = 1;
    
    var blocks:Array<FlxSprite> = [];
    var blocksShowedUp:Bool = false;
    var blockIndex:Int = 0;

    var action:FlxSound = FlxG.sound.load("assets/sounds/action_s.ogg");

    public function new(battleData:BattleMetadata) {
        blocks = [];
        cutscene = true;
        battleInProgress = true;
        battleChosen = false;

        opponentName.visible = false;

        battle = battleData;
        super(0);
    }

    override function create() {
        if (FlxG.sound.music != null) {
            oldSongPos = FlxG.sound.music.time;
            FlxG.sound.music.destroy();
        }

        FlxG.sound.play("assets/sounds/player/hereWeGo.ogg");
        
        new FlxTimer().start(0.9, e -> {
            FlxG.sound.playMusic("assets/music/battle.ogg");
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
                    var bg:FlxSprite = new FlxSprite().loadGraphic('assets/images/battleBGs/${battle.background}.png');
                    bg.antialiasing = false;
                    bg.scale.set(10, 10);
                    bg.updateHitbox();
                    bg.screenCenter();
                    insert(index, bg);

                    player.x = 70;
                    player.posY = 235;
                    player.inBattle = true;
                    insert(index + 1, player);

                    l = battle.enemyData.length-1;
                    var k:Int = 0;
                    final pos2:Array<Array<Array<Float>>> = [
                        [[480, 235]],
                        [[480, 200], [480, 270]]
                    ];

                    for (e in battle.enemyData) {
                        e.enemy.x = pos2[l][k][0];
                        e.enemy.y = pos2[l][k][1];
                        insert(index + 1, e.enemy);
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
                        FlxTween.tween(transitions[k], {alpha: 0, x: m[0], y: m[0]}, 1.2, {onComplete: e -> {
                            if (m[0] == -640) {
                                if (battle.extraDialogues != null) {
                                    var state = battle.extraDialogues;

                                    state.closeCallback = function() {
                                        cutscene = false;
                                        battleInProgress = false;
                                    };

                                    openSubState(state);
                                } else {
                                    cutscene = false;
                                    battleInProgress = false;
                                }
                            }
                        }});
                        
                        k++;
                    }

                    isYourTurn = battle.startASYourTurn;

                    add(opponentName);
                }
            }});

            add(transitions[l]);
        }

        cutscene = true;

        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        player.checkMovement();

        if (cutscene) {
            return;
        }

        opponentName.visible = battleChosen;
        if (battleChosen) {
            var data:BattleEnemies = battle.enemyData[battleWhoToBattle];
            opponentName.text = '${data.name} | ${data.hp} HP';

            function change(scroll:Int, ?playSound:Bool = true) {
                action.play(true);
                battleWhoToBattle += scroll;

                var ind:Int = 0;
                for (enemy in battle.enemyData) {
                    FlxSpriteUtil.setBrightness(cast(enemy.enemy, FlxSprite), ind == battleWhoToBattle ? 0.5 : 0);
                    ind++;
                }
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
            }
        } else if (!battleInProgress) {
            if (isYourTurn) {
                function change(scroll:Int) {
                    action.play(true);
                    blockIndex += scroll;

                    var ind:Int = 0;
                    for (block in blocks) {
                        FlxTween.tween(block, {x: 71 + (36 * (blockIndex + ind)), alpha: 1}, 0.25);
                        ind++;
                    }
                }

                if (!blocksShowedUp) {
                    var index:Int = 0;

                    for (block in blocks) {
                        block.x = 107 + (index * 36);
                        block.y = 178;
                        FlxTween.tween(block, {x: block.x - 36, alpha: 1}, 0.66, {ease: FlxEase.sineOut});
                    }

                    blocksShowedUp = true;
                }

                if (FlxG.keys.anyJustPressed([Q, A, LEFT]) && blockIndex != 0) {
                    change(-1);
                } else if (FlxG.keys.anyJustPressed([D, RIGHT]) && blockIndex != blocks.length - 1) {
                    change(1);
                } else if (FlxG.keys.justPressed.SPACE) {
                    FlxG.sound.play("assets/sounds/action_c.ogg");
                    player.jump(true);

                    for (block in blocks) {
                        FlxTween.tween(block, {alpha: 0}, 0.25, {ease: FlxEase.linear});
                    }

                    blocksShowedUp = false;
                    battleChosen = true;
                    battleWhoToBattle = 0;
                }
            }
        }
    }
}