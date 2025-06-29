package;

class Player extends FlxSprite {
    var velocityMovement:Array<Float> = [0, 0];
    var currentPos:Array<Float> = [0, 0];
    final key:Array<FlxKey> = [LEFT, DOWN, UP, RIGHT, A, S, W, D];

    var jumped:Bool = false;
    var copyJump:FlxSprite = new FlxSprite();
    
    public function new() {
        super();
        makeGraphic(32, 32, 0xFF00FF00);
    }
    
    public function checkMovement() {
        var i:Int = 0;

        for (k in key) {
            if (FlxG.keys.anyPressed([k])) {
                switch(i % 4) {
                    case 0: velocityMovement[0] -= 0.5;
                    case 1: velocityMovement[1] += 0.5;
                    case 2: velocityMovement[1] -= 0.5;
                    case 3: velocityMovement[0] += 0.5;
                }
            }

            i++;
        }

        if (FlxG.keys.justPressed.SPACE) {
            jumped = true;
            copyJump.y = 0;
            copyJump.acceleration.y = 60;
            copyJump.velocity.y = -200;
        } else if (jumped && copyJump.y <= 0) {
            jumped = false;
        }

        velocityMovement[0] /= 1.15;
        velocityMovement[1] /= 1.15;
        currentPos[0] += velocityMovement[0];
        currentPos[1] += velocityMovement[1];
        x = currentPos[0];
        y = currentPos[1] + copyJump.y;
    }
}