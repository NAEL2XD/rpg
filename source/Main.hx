package;

import chapters.Chapter1.Chapter1_1;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {
	public function new() {
		super();
		
		addChild(new FlxGame(640, 320, Chapter1_1, 60, 60, true));

		FlxG.autoPause = false;
	}
}