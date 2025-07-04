package;

import chapters.Chapter1.Chapter1_1;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {
	var startOver:Bool = true;
	public function new() {
		super();
		
		FlxG.save.bind("rpg");
		trace(FlxG.save.status);

		if (startOver) {
			FlxG.save.data.c1_1 = {};
			FlxG.save.data.c1_2 = {};
		}
		
		addChild(new FlxGame(640, 320, Chapter1_1, 60, 60, true));
		
		FlxG.autoPause     = false;
		FlxG.mouse.visible = false;
	}
}