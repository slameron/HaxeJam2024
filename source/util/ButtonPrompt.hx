package util;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import lime.utils.Assets;

class ButtonPrompt extends FlxSprite
{
	var keyboard:FlxSprite;
	var controller:FlxSprite;

	public var text:Text;

	var controls(get, never):Controls;

	function get_controls():Controls
		return Init.controls;

	var iconScale:Float = 4;

	public var w(get, never):Float;

	function get_w():Float
	{
		if (text != null)
			if (keyboard.visible)
				return text.width + keyboard.width + 5;
			else
				return text.width + controller.width + 5;

		return keyboard.visible ? keyboard.width : controller.width;
	}

	public var h(get, never):Float;

	function get_h():Float
	{
		if (text != null)
			if (keyboard.visible)
				return keyboard.height > text.height ? keyboard.height : text.height;
			else
				return controller.height > text.height ? controller.height : text.height;

		return keyboard.visible ? keyboard.height : controller.height;
	}

	public function new(x:Int, y:Int, data:{keyboard:String, controller:String}, ?iconScale = 4, ?text:String, ?textSize:Int = 8)
	{
		super(x, y);
		if (text != null)
		{
			this.text = new Text(x, y, 0, text, textSize);
		}

		this.iconScale = iconScale;

		makeGraphic(16, 16, FlxColor.TRANSPARENT);
		scale.set(iconScale, iconScale);
		updateHitbox();

		keyboard = new FlxSprite(x, y);
		if (data.keyboard == 'null')
			keyboard.makeGraphic(16, 16, FlxColor.TRANSPARENT);
		else
			keyboard.loadGraphic('assets/images/prompts/${data.keyboard}.png');
		keyboard.scale.set(iconScale, iconScale);
		keyboard.updateHitbox();

		var controllerPath = 'assets/images/prompts/${controls.controllerType != null ? controls.controllerType + '_' : ''}${data.controller}.png';
		if (!Assets.exists(controllerPath))
			controllerPath = 'assets/images/prompts/${data.controller}.png';
		controller = new FlxSprite(x, y, controllerPath);
		controller.scale.set(iconScale, iconScale);
		controller.updateHitbox();

		keyboard.visible = controller.visible = false;

		// this.text.origin.set(width / 2, height / 2);
		// origin.set(x - width / 2, height / 2);
		// controller.origin.set(controller.x - width / 2, height / 2);

		FlxG.gamepads.deviceConnected.add(gamepad ->
		{
			var controllerPath = 'assets/images/prompts/${controls.controllerType != null ? controls.controllerType + '_' : ''}${data.controller}.png';
			if (!Assets.exists(controllerPath))
				controllerPath = 'assets/images/prompts/${data.controller}.png';
			controller.loadGraphic(controllerPath);
			controller.scale.set(iconScale, iconScale);
			controller.updateHitbox();
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		keyboard.visible = controls.lastInput == 'keyboard';
		controller.visible = controls.lastInput == 'controller';
	}

	override public function draw()
	{
		if (controller.visible)
			controller.draw();
		if (keyboard.visible)
			keyboard.draw();
		if (text != null)
			if (text.visible)
				text.draw();
	}

	override function setPosition(x:Float = 0, y:Float = 0)
	{
		super.setPosition(x, y);

		if (text != null)
			text.setPosition(x, y);

		keyboard.setPosition(x, y #if !web + (text != null ? text.height / 2 - keyboard.height / 2 : 0) #end);
		controller.setPosition(x, y #if !web + (text != null ? text.height / 2 - controller.height / 2 : 0) #end);

		if (text != null)
		{
			keyboard.x += text.width + 5;
			controller.x += text.width + 5;
		}
	}
}
