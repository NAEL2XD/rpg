package chapters;

import flixel.util.FlxTimer;
import util.Dialogue;

class Chapter1_1 extends FlxState {
    var sprite:FlxSprite = new FlxSprite(240, 160).makeGraphic(16, 16);

    override function create() {
        add(sprite);
        super.create();
    }

    override function update(elapsed:Float) {
        new FlxTimer().start(1, e -> {
            openSubState(new Dialogue("test1", sprite));
        });
        super.update(elapsed);
    }
}