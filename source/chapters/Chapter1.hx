package chapters;

import util.Dialogue;

class Chapter1_1 extends FlxState {
    var player:Player = new Player();
    var up:FlxSprite = new FlxSprite().loadGraphic("assets/images/up.png");

    override function create() {
        var house:FlxSprite = new FlxSprite().loadGraphic("assets/images/world/house/0.png");
        house.antialiasing = false;
        house.scale.set(10, 10);
        house.updateHitbox();
        house.screenCenter();
        add(house);

        player.x = 86;
        player.posY = 196;
        player.limitXPos = [0, 616];
        player.checkMovement();
        player.cutscene = true;
        player.playSound("yawn");
        add(player);

        FlxG.camera.flash(0xFF000000, 2, function() {
            var state = new Dialogue([{
                dID: "houseWake1",
                char: player
            }, {
                dID: "houseWake2",
                char: player
            }, {
                dID: "houseWake3",
                char: player
            }]);

            state.closeCallback = function() {
                player.cutscene = false;
                FlxG.sound.playMusic("assets/music/plains.ogg");
            }

            openSubState(state);
        });

        super.create();
    }

    override function update(elapsed:Float) {
        //player.checkMovement();
        super.update(elapsed);
    }
}