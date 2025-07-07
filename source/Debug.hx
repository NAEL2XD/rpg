package;

import flixel.text.FlxText;
import util.Battle;
import chapters.Chapter1.Chapter1_1;

class Debug extends FlxState {
    var enemy:FlxSprite = new FlxSprite().makeGraphic(32, 32, 0xFFFF0000); 
    var choice:Int = 0;
    var texts:Array<FlxText> = [];
    var lists:Array<Array<Dynamic>> = [];

    override function create() {
        super.create();

        lists = [
            ["Chapter 0", Chapter1_1.new, true],
            ["Battle Test", new Battle({
                enemyData: [{
                    hp: 10,
                    enemy: enemy,
                    name: "Test",
                    damage: 1
                }],
                background: "houseOut",
                startASYourTurn: false
            }), false]
        ];

        var times:Int = 0;
        for (list in lists) {
            texts.push(new FlxText(8, 8 + (times * 16), 640, list[0], 16));
            add(texts[times]);
            times++;
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.keys.justPressed.Z && choice != 0) {
            choice--;
        } else if (FlxG.keys.justPressed.S && choice != lists.length-1) {
            choice++;
        } else if (FlxG.keys.justPressed.ENTER) {
            if (lists[choice][2]) {
                FlxG.switchState(lists[choice][1]);
            } else {
                openSubState(lists[choice][1]);
            }
        }

        var i:Int = 0;
        for (text in texts) {
            text.color = i == choice ? 0xFFFFFF00 : 0xFFFFFFFF;
            i++;
        }
    }
}