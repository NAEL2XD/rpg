package chapters;

import util.Dialogue;

class Chapter1_1 extends FlxState {
    var sprite:FlxSprite = new FlxSprite(240, 160);

    override function create() {
        openSubState(new Dialogue("test1", sprite));
        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}