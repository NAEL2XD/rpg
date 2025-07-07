package;

import flixel.text.FlxText;
import util.Battle;
import chapters.Chapter1.Chapter1_1;

class Debug extends FlxState {
    var choice:Int = 0;
    var texts:Array<FlxText> = [];
    var lists:Array<Array<Dynamic>> = [
        ["Chapter 0", Chapter1_1.new],
        ["Battle Test", new Battle({
            enemyData: [{
                hp: 10,
                enemy: new FlxSprite().makeGraphic(32, 32, 0xFFFF0000),
                name: "Test",
                damage: 1
            }],
            background: "",
            startASYourTurn: false
        })]
    ];

    override function create() {
        super.create();

        var times:Int = 0;
        for (list in lists) {
            texts.push(new FlxText(8, 8 + (times * 16), 640, list[0], 16));
            add(texts[times]);
            times++;
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.keys.justPressed.S && choice != 0) {
            choice--;
        } else if (FlxG.keys.justPressed.Z && choice != lists.length) {
            choice++;
        } else if (FlxG.keys.justPressed.ENTER) {
            openSubState(lists[choice][1]);
        }

        var i:Int = 0;
        for (text in texts) {
            text.color = i == choice ? 0xFFFFFF00 : 0xFFFFFFFF;
            i++;
        }
    }
}