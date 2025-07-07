package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {
	var startOver:Bool = true;
	public function new() {
		super();
		
		FlxG.save.bind("rpg");
		trace(FlxG.save.status);

		if (startOver || FlxG.save.data.player == null) {
			FlxG.save.data.player = {};
			FlxG.save.data.player.HP = 10;
			FlxG.save.data.player.maxHP = 10;

			FlxG.save.data.c1_1 = {};
			FlxG.save.data.c1_2 = {};
			FlxG.save.data.c1_3 = {};
		}
		
		addChild(new FlxGame(640, 320, Debug, 60, 60, true));
		
		FlxG.autoPause     = false;
		FlxG.mouse.visible = false;
	}
}