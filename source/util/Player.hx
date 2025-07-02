package util;

class Player extends FlxSprite {
    var velocityMovement:Array<Float> = [0, 0];
    var currentPos:Array<Float> = [0, 0];

    var jumpY:Float = 0;
    var jumpHeight:Float = 0;
    var jumped:Bool = false;
    
    public function new() {
        super();
        makeGraphic(32, 32, 0xFF00FF00);
    }
    
    public function checkMovement() {
        var i:Int = 0;
        for (k in [LEFT, DOWN, UP, RIGHT, A, S, W, D]) {
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
            jumpHeight = 8;
        } else if (jumped) {
            jumpHeight -= .5;
            jumpY += jumpHeight;

            if (jumpY < 0) {
                jumped = false;
            }
        }

        velocityMovement[0] /= 1.15;
        velocityMovement[1] /= 1.15;
        currentPos[0] += velocityMovement[0];
        currentPos[1] += velocityMovement[1];
        x = currentPos[0];
        y = currentPos[1] - jumpY;
    }
}