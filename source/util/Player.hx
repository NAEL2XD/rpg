package util;

class Player extends FlxSprite {
    public var cutscene:Bool = false;
    public var posY:Float = 0;
    public var limitXPos:Array<Float> = [0, 0];

    var velocityMovement:Float = 0;

    var jumpY:Float = 0;
    var jumpHeight:Float = 0;
    var jumped:Bool = false;
    
    public function new() {
        super();
        makeGraphic(24, 24, 0xFF00FF00);
    }
    
    public function checkMovement() {
        if (!cutscene) {
            var i:Int = 0;
            for (k in [LEFT, RIGHT, A, D]) {
                if (FlxG.keys.anyPressed([k])) {
                    switch(i % 2) {
                        case 0: velocityMovement -= 0.5;
                        case 1: velocityMovement += 0.5;
                    }
                }

                i++;
            }

            if (FlxG.keys.justPressed.SPACE && !jumped) {
                jumped = true;
                jumpHeight = 8;
                
                playSound("jump");
            } else if (jumped) {
                jumpHeight -= .5;
                jumpY += jumpHeight;
            
                if (jumpY < 0) {
                    jumpY = 0;
                    jumped = false;
                }
            }
        }

        if (x < limitXPos[0]) {
            x = limitXPos[0];
        } else if (x > limitXPos[1]) {
            x = limitXPos[1];
        }

        velocityMovement /= 1.15;
        x += velocityMovement;
        y = posY - jumpY;
    }

    public function playSound(name:String) {
        FlxG.sound.play('assets/sounds/player/$name.ogg');
    }
}