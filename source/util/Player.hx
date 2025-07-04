package util;

class Player extends FlxSprite {
    public var cutscene:Bool = false;
    public var posY:Float = 0;
    public var limitXPos:Array<Float> = [0, 616];
    public var lockedVM:Float = 0;
    public var jumpLow:Float = 0;
    public var inBattle:Bool = false;

    var velocityMovement:Float = 0;

    var jumpY:Float = 0;
    var jumpHeight:Float = 0;
    var jumped:Bool = false;
    
    public function new() {
        super();
        makeGraphic(24, 24, 0xFF00FF00);
    }
    
    public function checkMovement() {
        if (inBattle) {
            return;
        }

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

            jump();
        }

        if (x < limitXPos[0]) {
            x = limitXPos[0];
        } else if (x > limitXPos[1]) {
            x = limitXPos[1];
        }

        velocityMovement /= 1.15;
        x += velocityMovement + lockedVM;
        y = posY - jumpY;
    }

    public function jump(?force:Bool = false, ?lowAmount:Float = 0) {
        if (inBattle) {
            lowAmount = -120;
        }

        jumpLow = lowAmount;

        if ((FlxG.keys.justPressed.SPACE && !jumped) || force) {
            jumped = true;
            jumpHeight = 8;
            
            playSound("jump");
        } else if (jumped) {
            jumpHeight -= .5;
            jumpY += jumpHeight;
        
            if (jumpY < jumpLow) {
                jumpY = jumpLow;
                jumped = false;
            }
        }
    }

    public function playSound(name:String) {
        FlxG.sound.play('assets/sounds/player/$name.ogg');
    }
}