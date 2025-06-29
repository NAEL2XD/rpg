package;

class PlayState extends FlxState {
	var player:Player = new Player();
 
	override public function create() {
		add(player);
		super.create();
	}

	override public function update(elapsed:Float) {
		player.checkMovement();
		super.update(elapsed);
	}
}
