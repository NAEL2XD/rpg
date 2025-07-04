package util;

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
    var battle:BattleMetadata = null;

    var transitions:Array<FlxSprite> = [];
    var blocks:Array<FlxSprite> = [];

    var player:Player = new Player();

    var isYourTurn:Bool = false;
    var turnLeftTillOpponent:Int = 1;
    var cutscene:Bool = true;
    var battleInProgress:Bool = true;
    var blocksShowedUp:Bool = false;
    var blockIndex:Int = 0;

    public function new(battleData:BattleMetadata) {
        blocks = [];
        cutscene = true;
        battleInProgress = true;

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
                    player.y = 235;
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
                }
            }});

            add(transitions[l]);
        }

        cutscene = true;

        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (cutscene) {
            return;
        }

        if (!battleInProgress) {
            if (isYourTurn) {
                function change(scroll:Int) {
                    FlxG.sound.play("assets/sounds/action_s.ogg");
                    blockIndex += scroll;

                    var ind:Int = 0;
                    for (block in blocks) {
                        FlxTween.tween(block, {x: 74 + (36 * (blockIndex + ind)), alpha: 1}, 0.25);
                        ind++;
                    }
                }

                if (!blocksShowedUp) {
                    var index:Int = 0;

                    for (block in blocks) {
                        block.x = 110 + (index * 36);
                        block.y = 180;
                        FlxTween.tween(block, {x: block.x - 36, alpha: 1}, 0.66, {ease: FlxEase.sineOut});
                    }

                    blocksShowedUp = true;
                }

                if (FlxG.keys.anyJustPressed([Q, A, LEFT]) && blockIndex != 0) {
                    change(-1);
                } else if (FlxG.keys.anyJustPressed([D, RIGHT]) && blockIndex != blocks.length - 1) {
                    change(1);
                }
            }
        }
    }

    function name() {
        
    }
}