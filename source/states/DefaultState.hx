package states;

import flixel.FlxCamera;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

class DefaultState extends FlxState
{
	var controls(get, null):util.Controls;
	var transitioning:Bool = false;
	var shouldRet:Bool;

	function get_controls()
		return states.Init.controls;

	var achievements(get, null):util.Achievements;

	function get_achievements()
		return states.Init.achievements;

	public var achievementPopups:Array<String> = [];

	var popup:AchievementPopup;
	var popupCam:FlxCamera;

	override function update(elapsed:Float)
	{
		shouldRet = false;
		Sound.updateSounds(elapsed);
		controls.update(elapsed);
		for (popup in PopUpUI.popups)
			popup.update(elapsed);
		if (PopUpUI.popups.length > 0)
			shouldRet = true;

		if (achievementPopups.length > 0)
		{
			if (popup == null)
			{
				var ach = achievementPopups.shift();
				popup = new AchievementPopup(ach, achievements.achievements.get(ach).image);
				add(popup);
				popupCam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
				FlxG.cameras.add(popupCam, false);
				popupCam.bgColor = FlxColor.TRANSPARENT;
				popup.cameras = [popupCam];
			}
			else if (!popup.alive)
			{
				remove(popup);
				popup = null;
				FlxG.cameras.remove(popupCam);
			}
		}

		if (popup != null)
			if (!popup.alive)
			{
				remove(popup);
				popup = null;
				FlxG.cameras.remove(popupCam);
			}

		if (shouldRet)
			return;
		super.update(elapsed);
	}

	override public function draw()
	{
		super.draw();
		for (popup in PopUpUI.popups)
			popup.draw();
	}

	// set the false to true when it works
	override public function new(transition:Bool = false)
	{
		super();

		if (transition)
		{
			tempSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
			tempSprite.pixels.draw(FlxG.camera.canvas);

			tempSprite2 = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
			tempSprite2.pixels.draw(tempSprite.pixels, new Matrix(1, 0, 0, 1, 0, -FlxG.height / 2));
		}
	}

	public function postCreate()
	{
		if (FlxG.onMobile)
		{
			add(controls.setupVirtualPad('menu'));
		}
	}

	override public function create()
	{
		if (tempSprite != null)
		{
			transitioning = true;
			var top = new FlxSprite(0, 0).makeGraphic(FlxG.camera.width, Std.int(FlxG.camera.height / 2), FlxColor.TRANSPARENT);
			top.pixels.draw(tempSprite.pixels, null, null, null, new Rectangle(0, 0, FlxG.width, FlxG.height / 2));
			add(top);

			var bottom = new FlxSprite(0, Std.int(FlxG.height / 2)).makeGraphic(FlxG.camera.width, Std.int(FlxG.camera.height / 2), FlxColor.TRANSPARENT);
			bottom.pixels.draw(tempSprite2.pixels, null, null, null, new Rectangle(0, 0, FlxG.width, FlxG.height / 2));
			add(bottom);

			FlxTween.tween(top, {y: 0 - top.height}, .5, {ease: FlxEase.smootherStepInOut, onComplete: twn -> remove(top).destroy()});
			FlxTween.tween(bottom, {y: FlxG.height}, .5, {
				ease: FlxEase.smootherStepInOut,
				onComplete: twn ->
				{
					remove(bottom).destroy();
					transitioning = false;
				}
			});

			tempSprite = tempSprite2 = null;
		}
	}

	var tempSprite:FlxSprite;
	var tempSprite2:FlxSprite;
}
