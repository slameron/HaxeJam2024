package util;

import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class ControllerPad extends FlxTypedGroup<FlxSprite>
{
	public var joystickRun:ControllerButton;
	public var joystickButtonRun:ControllerButton;
	public var joystickShoot:ControllerButton;
	public var joystickButtonShoot:ControllerButton;
	public var buttonDash:ControllerButton;
	public var buttonUp:ControllerButton;
	public var buttonDown:ControllerButton;
	public var buttonLeft:ControllerButton;
	public var buttonRight:ControllerButton;
	public var buttonAccept:ControllerButton;
	public var buttonBack:ControllerButton;
	public var buttonPause:ControllerButton;

	var runJPP:FlxPoint;
	var shootJPP:FlxPoint;

	var context:String;

	override public function new(context:String = 'menu')
	{
		super();
		this.context = context;
		switch (context)
		{
			case 'game':
				joystickRun = new ControllerButton();
				joystickRun.loadGraphic('assets/images/mobile/joystick.png');
				joystickRun.scale.set(3.5, 3.5);
				joystickRun.updateHitbox();
				add(joystickRun);
				joystickButtonRun = new ControllerButton();
				joystickButtonRun.loadGraphic('assets/images/mobile/run.png');
				joystickButtonRun.scale.set(1.25, 1.25);
				joystickRun.updateHitbox();
				add(joystickButtonRun);
				joystickShoot = new ControllerButton();
				joystickShoot.loadGraphic('assets/images/mobile/joystick.png');
				joystickShoot.scale.set(3.5, 3.5);
				joystickShoot.updateHitbox();
				add(joystickShoot);
				joystickButtonShoot = new ControllerButton();
				joystickButtonShoot.loadGraphic('assets/images/mobile/shoot.png');
				joystickButtonShoot.scale.set(1.25, 1.25);
				joystickButtonShoot.updateHitbox();
				add(joystickButtonShoot);

				buttonDash = new ControllerButton();
				buttonDash.loadGraphic('assets/images/mobile/dash.png');
				buttonDash.scale.set(1.75, 1.75);
				buttonDash.updateHitbox();
				add(buttonDash);

				buttonPause = new ControllerButton();
				buttonPause.loadGraphic('assets/images/mobile/pause.png');
				add(buttonPause);

				joystickRun.setPosition(25, FlxG.height - joystickRun.height - 25);
				joystickButtonRun.setPosition(joystickRun.x
					+ joystickRun.width / 2
					- joystickButtonRun.width / 2,
					joystickRun.y
					+ joystickRun.height / 2
					- joystickButtonRun.height / 2);
				joystickShoot.setPosition(FlxG.width - joystickShoot.width - 25, FlxG.height - joystickShoot.height - 25);
				joystickButtonShoot.setPosition(joystickShoot.x
					+ joystickShoot.width / 2
					- joystickButtonShoot.width / 2,
					joystickShoot.y
					+ joystickShoot.height / 2
					- joystickButtonShoot.height / 2);

				buttonDash.setPosition(FlxG.width - buttonDash.width - 50, joystickShoot.y - buttonDash.height - 20);

				buttonPause.setPosition(FlxG.width - buttonPause.width - 20, 20);

			case 'menu':
				buttonUp = new ControllerButton();
				buttonUp.loadGraphic('assets/images/mobile/up.png');
				add(buttonUp);
				buttonDown = new ControllerButton();
				buttonDown.loadGraphic('assets/images/mobile/down.png');
				add(buttonDown);
				buttonLeft = new ControllerButton();
				buttonLeft.loadGraphic('assets/images/mobile/left.png');
				add(buttonLeft);
				buttonRight = new ControllerButton();
				buttonRight.loadGraphic('assets/images/mobile/right.png');
				add(buttonRight);
				buttonAccept = new ControllerButton();
				buttonAccept.loadGraphic('assets/images/mobile/accept.png');
				add(buttonAccept);
				buttonBack = new ControllerButton();
				buttonBack.loadGraphic('assets/images/mobile/back.png');
				add(buttonBack);

				var buttons = [buttonUp, buttonDown, buttonLeft, buttonRight, buttonAccept, buttonBack];

				for (button in buttons)
				{
					button.scale.set(1.75, 1.75);
					button.updateHitbox();
				}
				buttonLeft.setPosition(50, FlxG.height - buttonLeft.height - 10);
				buttonDown.setPosition(buttonLeft.x + buttonLeft.width + 5, buttonLeft.y);
				buttonRight.setPosition(buttonDown.x + buttonDown.width + 5, buttonLeft.y);
				buttonUp.setPosition(buttonDown.x, buttonLeft.y - buttonUp.height - 5);

				buttonBack.setPosition(FlxG.width - 50 - buttonBack.width, FlxG.height - buttonBack.height - 10);
				buttonAccept.setPosition(buttonBack.x - buttonAccept.width - 5, buttonBack.y);
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		#if FLX_TOUCH
		var buttons = [
			buttonUp, buttonDown, buttonLeft, buttonRight, buttonAccept, buttonBack, buttonDash, buttonPause, joystickButtonShoot, joystickButtonRun
		];
		for (button in buttons)
		{
			if (button == null)
				continue;
			var shouldRel:Bool = false;
			var shouldPress:Bool = false;

			var touched:Bool = false;
			for (touch in FlxG.touches.list)
			{
				if (touch.overlaps(button, cameras[0]))
				{
					button.justPressed = touch.justPressed;
					button.pressed = true;
					touched = true;
					break;
				}
				else
				{
					shouldRel = button.pressed ? true : false;
					shouldPress = false;
				}
			}
			if (!touched)
			{
				button.justReleased = shouldRel;
				button.pressed = shouldPress;
			}
		}
		if (context == 'game')
		{
			joystickRun.setPosition(25, FlxG.height - joystickRun.height - 25);
			joystickButtonRun.setPosition(joystickRun.x
				+ joystickRun.width / 2
				- joystickButtonRun.width / 2,
				joystickRun.y
				+ joystickRun.height / 2
				- joystickButtonRun.height / 2);
			joystickShoot.setPosition(FlxG.width - joystickShoot.width - 25, FlxG.height - joystickShoot.height - 25);
			joystickButtonShoot.setPosition(joystickShoot.x
				+ joystickShoot.width / 2
				- joystickButtonShoot.width / 2,
				joystickShoot.y
				+ joystickShoot.height / 2
				- joystickButtonShoot.height / 2);

			for (touch in FlxG.touches.list)
			{
				if (touch.screenX > FlxG.width / 2)
				{
					if (touch.justReleased)
						shootJPP = null;
					if (buttonDash?.pressed || buttonPause?.pressed)
						if (shootJPP == null)
							return;

					if (touch.justPressed || shootJPP == null)
					{
						shootJPP = touch.getScreenPosition(cameras[0]);
						if (joystickShoot.centerPoint != null)
						{
							joystickShoot.centerPoint.destroy();
							joystickShoot.centerPoint = null;
						}
						joystickShoot.centerPoint = new FlxSprite(shootJPP.x, shootJPP.y).makeGraphic(1, 1);
					}
					if (shootJPP != null)
						centerOnPoint(joystickShoot, shootJPP);

					centerOnPoint(joystickButtonShoot, touch.getScreenPosition(cameras[0]));
					if (joystickButtonShoot.centerPoint != null)
					{
						joystickButtonShoot.centerPoint.destroy();
						joystickButtonShoot.centerPoint = null;
					}
					joystickButtonShoot.centerPoint = new FlxSprite(touch.getScreenPosition(cameras[0]).x,
						touch.getScreenPosition(cameras[0]).y).makeGraphic(1, 1);
				}

				if (touch.screenX < FlxG.width / 2)
				{
					if (touch.justReleased)
						runJPP = null;
					if (touch.justPressed || runJPP == null)
					{
						runJPP = touch.getScreenPosition(cameras[0]);
						if (joystickRun.centerPoint != null)
						{
							joystickRun.centerPoint.destroy();
							joystickRun.centerPoint = null;
						}
						joystickRun.centerPoint = new FlxSprite(runJPP.x, runJPP.y).makeGraphic(1, 1);
					}
					if (runJPP != null)
						centerOnPoint(joystickRun, runJPP);
					centerOnPoint(joystickButtonRun, touch.getScreenPosition(cameras[0]));

					if (joystickButtonRun.centerPoint != null)
					{
						joystickButtonRun.centerPoint.destroy();
						joystickButtonRun.centerPoint = null;
					}
					joystickButtonRun.centerPoint = new FlxSprite(touch.getScreenPosition(cameras[0]).x,
						touch.getScreenPosition(cameras[0]).y).makeGraphic(1, 1);
				}
			}
		}
		#end
	}

	function centerOnPoint(object:FlxObject, point:FlxPoint)
	{
		object.setPosition(point.x - (object.width / 2), point.y - (object.height / 2));
	}

	public function getAngleFromStick(stick:String = 'run'):Float
	{
		if (context != 'game')
			return 0;

		var angle:Float = 0;
		switch (stick)
		{
			case 'run':
				if (joystickButtonRun?.centerPoint != null && joystickRun?.centerPoint != null)
					angle = FlxAngle.angleBetween(joystickRun?.centerPoint, joystickButtonRun?.centerPoint, true);

			case 'shoot':
				if (joystickButtonShoot?.centerPoint != null && joystickShoot?.centerPoint != null)
					angle = FlxAngle.angleBetween(joystickShoot?.centerPoint, joystickButtonShoot?.centerPoint, true);
		}

		return angle;
	}
}

class ControllerButton extends FlxSprite
{
	public var justPressed:Bool;
	public var pressed:Bool;
	public var justReleased:Bool;

	public var centerPoint:FlxSprite;
}
