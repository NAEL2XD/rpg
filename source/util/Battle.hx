package util;

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
    
    var player:Player = new Player();

    var isYourTurn:Bool = false;
    var turnLeftTillOpponent:Int = 1;

    public function new(battleData:BattleMetadata) {
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

                    player.x = 40;
                    player.y = 235;
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

                    k = 0;
                    for (m in pos) {
                        FlxTween.tween(transitions[k], {alpha: 0, x: m[0], y: m[0]}, 1.2, {onComplete: e -> {
                            if (m[0] == -640) {
                                if (battle.extraDialogues != null) {
                                    openSubState(battle.extraDialogues);
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

        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}