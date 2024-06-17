package objects;

class AchievementPopup extends FlxSprite
{
	var nameText:Text;

	override public function new(name:String, image:String)
	{
		super(0, 0);

		loadGraphic(image);

		var s = (1 * FlxG.height) / 720;
		scale.set(s, s);
		updateHitbox();
		nameText = new Text(0, 0, FlxG.width, name, Std.int((48 * FlxG.height) / 720));
		nameText.addLabel('${#if newgrounds 'Medal' #else 'Achievement' #end} Unlocked!', Std.int((32 * FlxG.height) / 720), true, true);
		nameText.alignment = CENTER;
		nameText.bound = FlxPoint.get(0, FlxG.height);
		setPosition(FlxG.width / 2 - width / 2, 0 - height - nameText.height - 20);
		nameText.setPosition(0, y + height + 20);

		FlxTween.tween(this, {y: 20}, 1, {
			ease: FlxEase.smootherStepInOut,
			onComplete: twn -> FlxTween.tween(this, {y: 0 - height - nameText.height - 20}, 1, {
				ease: FlxEase.smootherStepInOut,
				startDelay: 3,
				onComplete: twn ->
				{
					kill();
				}
			})
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		nameText.update(elapsed);
		nameText.cameras = cameras;
		@:privateAccess nameText.labelText.cameras = cameras;
	}

	override public function kill()
	{
		super.kill();
		nameText.kill();
	}

	override public function draw()
	{
		super.draw();
		if (nameText.visible)
		{
			nameText.setPosition(0, y + height + 20);
			nameText.draw();
		}
	}
}
