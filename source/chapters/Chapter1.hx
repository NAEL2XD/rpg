package chapters;

import flixel.util.FlxTimer;
import util.Dialogue;

class Chapter1_1 extends FlxState {
    var sprite:FlxSprite = new FlxSprite(240, 160).makeGraphic(16, 16);

    override function create() {
        new FlxTimer().start(1, e -> {
            openSubState(new Dialogue(["test1", "test2"], sprite));
        });

        add(sprite);
        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}