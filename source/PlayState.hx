package;

class PlayState extends FlxState {
	var player:Player = new Player();

	override public function create() {
		super.create();

		add(player);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		player.checkMovement();
	}
}
