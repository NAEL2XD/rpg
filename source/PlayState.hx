package;

class PlayState extends FlxState {
	public static var copyJump:FlxSprite = new FlxSprite();
	var player:Player = new Player();

	override public function create() {
		add(player);

		copyJump.makeGraphic(0, 0);
        add(copyJump);
		
		super.create();
	}

	override public function update(elapsed:Float) {
		player.checkMovement();
		super.update(elapsed);
	}
}
