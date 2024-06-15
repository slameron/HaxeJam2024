package states;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;

class DefaultSubstate extends FlxSubState
{
	var subCam:FlxCamera;

	var controls(get, null):Controls;

	function get_controls():Controls
		return Init.controls;

	var achievements(get, null):util.Achievements;

	function get_achievements()
		return states.Init.achievements;

	override function add(ob:FlxBasic):FlxBasic
	{
		super.add(ob);

		ob.cameras = [subCam];
		return (ob);
	}

	var canEsc:Bool = true;
	var shouldRet:Bool;

	public function new()
	{
		super();

		subCam = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		subCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(subCam, false);

		bg = new FlxBackdrop(FlxGridOverlay.create(Std.int((64 * FlxG.height) / 720), Std.int((64 * FlxG.height) / 720),
			Std.int((64 * FlxG.height) / 720) * 8, Std.int((64 * FlxG.height) / 720) * 16, true, 0xff000000, 0xFF2F2F2F)
			.pixels);
		bg.velocity.set(30, 30);
		add(bg);
		bg.alpha = 0;
		FlxTween.tween(bg, {"alpha": .5}, .5, {ease: FlxEase.smootherStepInOut});
	}

	override public function create() {}

	var bg:FlxBackdrop;

	public function postCreate()
	{
		if (FlxG.onMobile)
		{
			add(controls.setupVirtualPad('menu'));
		}
	}

	override function update(elapsed:Float)
	{
		shouldRet = false;
		controls.update(elapsed);
		Sound.updateSounds(elapsed);
		for (popup in PopUpUI.popups)
			popup.update(elapsed);
		if (PopUpUI.popups.length > 0)
		{
			shouldRet = true;
			return;
		}
		@:privateAccess
		if (cast(FlxG.state, DefaultState).popup != null)
			cast(FlxG.state, DefaultState).popup.update(elapsed);

		if (canEsc)
			if (controls.justPressed('menu_back'))
				new FlxTimer().start(.05, tmr -> close());

		super.update(elapsed);
	}

	override public function draw()
	{
		super.draw();
		for (popup in PopUpUI.popups)
			popup.draw();
	}

	var closing:Bool = false;

	override public function close()
	{
		if (closing)
			return;

		closing = true;
		FlxG.log.add("");

		subCam.bgColor = FlxColor.TRANSPARENT;
		forEach(obj ->
		{
			if (!obj.cameras.contains(subCam))
				return;
			if (Std.isOfType(obj, FlxSprite))
				FlxTween.tween(obj, {'alpha': 0}, .5, {ease: FlxEase.smootherStepInOut});

			new FlxTimer().start(.55, tmr -> superClose());
		});

		forEachOfType(FlxTypedGroup, grp ->
		{
			grp.forEach(obj2 ->
			{
				if (Std.isOfType(obj2, FlxSprite))
					obj2.visible = false;
			});
		});
	}

	public function superClose()
	{
		// FlxG.cameras.remove(subCam, true);
		super.close();
	}
}
