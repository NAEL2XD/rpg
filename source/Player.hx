package;

class Player extends FlxSprite {
    var velocityMovement:Array<Float> = [0, 0];
    final key:Array<FlxKey> = [LEFT, DOWN, UP, RIGHT, A, S, W, D];
    
    public function new() {
        super();
        makeGraphic(32, 32, 0xFF00FF00);
    }
    
    public function checkMovement() {
        var i:Int = 0;

        for (k in key) {
            if (FlxG.keys.anyPressed([k])) {
                trace("Pressed!");

                switch(i % 4) {
                    case 0: velocityMovement[0] -= 0.5;
                    case 1: velocityMovement[1] -= 0.5;
                    case 2: velocityMovement[1] += 0.5;
                    case 3: velocityMovement[0] += 0.5;
                }
            }

            if (i < 2) {
                if (velocityMovement[i] < 0) {
                    velocityMovement[i] = velocityMovement[i] > -4 ? -4 : velocityMovement[i];
                } else {
                    velocityMovement[i] = velocityMovement[i] < 4 ? -4 : velocityMovement[i];
                }
            }

            i++;
        }

        velocityMovement[0] /= 1.1;
        velocityMovement[1] /= 1.1;
        x += velocityMovement[0];
        y += velocityMovement[1];

        trace(velocityMovement);
    }
}