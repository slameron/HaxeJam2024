package states;

class ClickState extends FlxState
{
	override public function create()
	{
		super.create();

		var clicktext = new Text(0, 0, 0, '${FlxG.onMobile ? 'touch' : 'click'} anywhere to start', Std.int((64 * FlxG.height) / 720));
		clicktext.screenCenter();
		add(clicktext);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		#if FLX_MOUSE
		if (FlxG.mouse.justPressed)
		#elseif FLX_TOUCH
		if (FlxG.touches.list.length > 0)
		#end
		FlxG.switchState(new Init());
	}
}
