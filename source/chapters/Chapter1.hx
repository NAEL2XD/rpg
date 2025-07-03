package chapters;

import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import util.Dialogue;

class Chapter1_1 extends FlxState {
    var sprite:FlxSprite = new FlxSprite(240, 160).makeGraphic(16, 16);

    override function create() {
        new FlxTimer().start(1, e -> {
            var state = new Dialogue([{
                dID: "test1",
                char: sprite
            }, {
                dID: "test2",
                char: sprite
            }, {
                dID: "test3",
                char: sprite
            }]);

            state.closeCallback = function() {
                var spriteMonster:FlxSprite = new FlxSprite();
                spriteMonster.makeGraphic(24, 24, 0xFFFF0000);
                spriteMonster.x = 480;
                FlxTween.tween(spriteMonster, {x: 280}, 2, {onComplete: e -> {
                    new Dialogue([{
                        dID: "test4",
                        char: spriteMonster
                    }, {
                        dID: "test5",
                        char: sprite
                    }, {
                        dID: "test6",
                        char: spriteMonster
                    }, {
                        dID: "test7",
                        char: sprite
                    }]);
                }});
                add(spriteMonster);
            }
        });

        add(sprite);
        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}