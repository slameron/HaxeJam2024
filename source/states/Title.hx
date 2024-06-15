package states;

import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;

class Title extends DefaultState
{
	var slamerontext:Text;

	override public function create()
	{
		super.create();

		#if FLX_MOUSE FlxG.mouse.visible = false; #end
		if (Sound.menuMusic == null)
			Sound.menuMusic = Sound.playMusic('serenity-fato_shadow');

		slamerontext = new Text(0, 0, 0, 'a game by slameron', Std.int((48 * FlxG.height) / 720));
		slamerontext.screenCenter();
		add(slamerontext);
		slamerontext.alpha = 0;

		FlxTween.tween(slamerontext, {alpha: 1}, 1, {
			ease: FlxEase.smootherStepInOut,
			onComplete: twn -> FlxTween.tween(slamerontext, {alpha: 0}, 1, {
				ease: FlxEase.smootherStepInOut,
				startDelay: 3,
				onComplete: twn ->
				{
					FlxG.switchState(new MenuState());
				}
			})
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (controls.justPressed('menu_accept'))
			FlxG.switchState(new MenuState());
	}
}
