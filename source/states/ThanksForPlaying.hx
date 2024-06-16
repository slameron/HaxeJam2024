package states;

class ThanksForPlaying extends DefaultState
{
	override public function create()
	{
		super.create();

		var clicktext = new Text(0, 0, FlxG.width, 'Thank you for playing!', Std.int((64 * FlxG.height) / 720));
		clicktext.screenCenter(Y);
		clicktext.alignment = CENTER;
		add(clicktext);
		var clicktext2 = new Text(0, 0, FlxG.width, 'Press space or enter to go back to the menu', Std.int((32 * FlxG.height) / 720));
		clicktext2.screenCenter(Y);
		clicktext2.y += 100;
		clicktext2.alignment = CENTER;
		add(clicktext2);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		#if FLX_MOUSE
		if (FlxG.mouse.justPressed)
		#elseif FLX_TOUCH
		if (FlxG.touches.list.length > 0)
		#end
		FlxG.switchState(new MenuState());

		if (controls.justPressed('menu_accept'))
			FlxG.switchState(new MenuState());
	}
}
