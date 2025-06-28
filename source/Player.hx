package;

class Player extends FlxSprite {
    public function new() {
        super();
        makeGraphic(32, 32, 0xFF00FF00);
    }

    public function checkMovement() {
        final key:Array<FlxKey> = [LEFT, DOWN, UP, RIGHT];

        velocity.x = 0;
        velocity.y = 0;

        var i:Int = 0;
        for (k in key) {
            if (FlxG.keys.anyPressed([k])) {
                switch(i) {
                    case 0:  velocity.x -= 4;
                    case 1:  velocity.y -= 4;
                    case 2:    velocity.y += 4;
                    case 3: velocity.x += 4;
                }
            }

            i++;
        }
    }
}