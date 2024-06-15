package util;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.ui.FlxVirtualPad;
import haxe.Json;

using StringTools;

#if sys
import sys.FileSystem;
#end

class Controls
{
	public var lastInput:String = #if mobile 'touch' #else 'keyboard' #end;

	public var controller(get, never):FlxGamepad;
	public var controllerType(get, never):String;

	public var virtualPad:ControllerPad;

	var vpadCam:FlxCamera;

	function get_controllerType()
	{
		var type:Null<String> = null;

		if (controller != null)
			#if steam
			if (Steam.active)
				switch (Steam.controllers.getInputTypeForControllerIndex(0))
				{
					case 'PS4 Controller' | 'PS5 Controller':
						type = 'playstation';
					case 'Xbox 360 Controller' | 'Xbox One Controller' | 'Steam Deck':
						type = 'xbox';

					default:
						type = 'xbox';
				}
			else
				switch (controller.detectedModel)
				{
					case PS4 | PSVITA:
						type = 'playstation';
					case XINPUT:
						type = 'xbox';
					case SWITCH_PRO:
						type = 'switch';

					default:
						type = 'xbox';
				}
			#else
			switch (controller.detectedModel)
			{
				case PS4 | PSVITA:
					type = 'playstation';
				case XINPUT:
					type = 'xbox';
				case SWITCH_PRO:
					type = 'switch';

				default:
					type = 'xbox';
			}
			#end
		return type;
	}

	function get_controller():FlxGamepad
	{
		return FlxG.gamepads.firstActive != null ? FlxG.gamepads.firstActive : FlxG.gamepads.getByID(0);
	}

	var defaultBinds:Map<String, Array<FlxKey>> = [
		// In game
		'left' => [A, LEFT],
		'right' => [D, RIGHT],
		'up' => [W, UP],
		'down' => [S, DOWN],
		'interact' => [E],
		'jump' => [SPACE],
		// Menu
		'menu_left' => [A, LEFT],
		'menu_right' => [D, RIGHT],
		'menu_up' => [W, UP],
		'menu_down' => [S, DOWN],
		'menu_accept' => [SPACE, ENTER],
		'menu_back' => [ESCAPE, BACKSPACE],
		'pause' => [ESCAPE, P]
	];

	var defaultControllerBinds:Map<String, Array<FlxGamepadInputID>> = [
		// In game
		'left' => [LEFT_STICK_DIGITAL_LEFT, DPAD_LEFT],
		'right' => [LEFT_STICK_DIGITAL_RIGHT, DPAD_RIGHT],
		'up' => [LEFT_STICK_DIGITAL_UP, DPAD_UP],
		'down' => [LEFT_STICK_DIGITAL_DOWN, DPAD_DOWN],
		'interact' => [X],
		'jump' => [A],
		// Menu
		'menu_left' => [LEFT_STICK_DIGITAL_LEFT, DPAD_LEFT],
		'menu_right' => [LEFT_STICK_DIGITAL_RIGHT, DPAD_RIGHT],
		'menu_up' => [LEFT_STICK_DIGITAL_UP, DPAD_UP],
		'menu_down' => [LEFT_STICK_DIGITAL_DOWN, DPAD_DOWN],
		'menu_accept' => [A],
		'menu_back' => [B],
		'pause' => [START]
	];

	var userBinds:Map<String, Array<FlxKey>> = [];
	var userControllerBinds:Map<String, Array<FlxGamepadInputID>> = [];
	var blocking:Map<String, Bool> = [];
	var holdTime:Map<String, Float> = [];

	public function new()
	{
		trace(Save.exists('controls'));
		if (Save.exists('controls'))
			loadBinds();
		else
			resetBinds();
		#if sys
		trace(Sys.getCwd());
		trace(FileSystem.exists('${Sys.getCwd()}/save/cloud/controls.json'));
		#end
	}

	public function setupVirtualPad(context:String = 'menu'):ControllerPad
	{
		if (virtualPad != null)
		{
			virtualPad.destroy();
			virtualPad = null;
		}

		if (vpadCam != null)
		{
			FlxG.cameras.remove(vpadCam);
			vpadCam = null;
		}

		vpadCam = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		vpadCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(vpadCam, false);
		switch (context)
		{
			case 'menu':
				virtualPad = new ControllerPad('menu');
			case 'game':
				virtualPad = new ControllerPad('game');

			default:
				virtualPad = new ControllerPad('menu');
		}

		virtualPad.cameras = [vpadCam];

		return virtualPad;
	}

	public function update(elapsed:Float)
	{
		FlxG.watch.addQuick('Controller Variety', controller != null ? 'model ${controller.detectedModel} name 
		${controller.name} type ${controllerType}' : 'null');

		#if FLX_KEYBOARD
		if (FlxG.keys.getIsDown().length > 0)
			lastInput = 'keyboard';
		#end

		if (controller != null)
			if (controller.anyButton(PRESSED))
				lastInput = 'controller';

		FlxG.watch.addQuick('lastInput', lastInput);
		for (bind in userBinds.keys())
			if (pressed(bind))
				if (holdTime.exists(bind))
					holdTime.set(bind, holdTime[bind] + elapsed);
				else
					holdTime.set(bind, elapsed);
			else if (justReleased(bind))
				holdTime.remove(bind);
	}

	/**
	 * Checks how long the given input has been held down.
	 * @param input The name of the control you want to check, i.e. `'sneak'`
	 * @return Returns the amount of time (in seconds) the control has been held down. Will return 0 if the control is wrong or not currently being held down.
	 */
	public function heldTime(input:String):Float
	{
		if (holdTime.exists(input))
			return holdTime.get(input);
		return 0;
	}

	public function justPressed(input:String):Bool
	{
		if (blocking.exists(input))
		{
			blocking.remove(input);
			return false;
		}
		#if FLX_KEYBOARD
		if (userBinds.exists(input))
		{
			if (FlxG.keys.anyJustPressed(userBinds.get(input)))
			{
				blocking.set(input, true);
				new FlxTimer().start(.01, tmr -> blocking.remove(input));
				return true;
			}
		}
		#end
		if (userControllerBinds.exists(input))
		{
			if (controller != null)
				if (controller.anyJustPressed(userControllerBinds.get(input)))
				{
					blocking.set(input, true);
					new FlxTimer().start(.01, tmr -> blocking.remove(input));
					return true;
				}
		}
		return false;
	}

	public function pressed(input:String):Bool
	{
		var ret = false;
		#if FLX_KEYBOARD
		if (userBinds.exists(input))
			ret = FlxG.keys.anyPressed(userBinds.get(input));
		#end

		if (controller != null)
			if (userControllerBinds.exists(input))
				ret = ret == true ? true : controller.anyPressed(userControllerBinds.get(input));
		return ret;
	}

	public function justReleased(input:String):Bool
	{
		var ret = false;
		#if FLX_KEYBOARD
		if (userBinds.exists(input))
			ret = FlxG.keys.anyJustReleased(userBinds.get(input));
		#end

		if (controller != null)
			if (userControllerBinds.exists(input))
				ret = ret == true ? true : controller.anyJustReleased(userControllerBinds.get(input));
		return ret;
	}

	public function any():Bool
	{
		#if FLX_KEYBOARD
		for (bind in userBinds.keys())
			if (FlxG.keys.anyPressed(userBinds.get(bind)))
				return true;
		#end
		for (bind in userBinds.keys())
			if (controller != null)
				if (controller.anyPressed(userControllerBinds.get(bind)))
					return true;
		return false;
	}

	public function anyCtrl():Bool
	{
		for (bind in userControllerBinds.keys())
			if (controller != null)
				if (controller.anyPressed(userControllerBinds.get(bind)))
					return true;
		return false;
	}

	public function allOf(inputs:Array<String>):Bool
	{
		var ret = true;
		#if FLX_KEYBOARD
		for (input in inputs)
			if (userBinds.exists(input))
				if (!FlxG.keys.anyPressed(userBinds.get(input)))
				{
					ret = false;
					break;
				}
		#end
		return ret;
	}

	public function noneOf(inputs:Array<String>):Bool
	{
		var ret = true;
		#if FLX_KEYBOARD
		for (input in inputs)
			if (userBinds.exists(input))
				if (FlxG.keys.anyPressed(userBinds.get(input)))
				{
					ret = false;
					break;
				}
		#end
		return ret;
	}

	#if FLX_KEYBOARD
	public function changeBind(input:String, newKey:Array<FlxKey>)
	{
		userBinds.set(input, newKey);
		saveBinds();
	}
	#end

	public function resetBinds()
	{
		userBinds = defaultBinds;
		userControllerBinds = defaultControllerBinds;
		saveBinds();
	}

	public function saveBinds()
		Save.save(bindsToJson(), 'controls', true);

	public function loadBinds()
	{
		var json = Save.load('controls');
		var binds:Array<Dynamic> = json.binds;
		#if FLX_KEYBOARD
		for (bind in binds)
		{
			var input:String = bind.input;
			var keys:Array<String> = bind.keys;
			var daKeys:Array<FlxKey> = [for (key in keys) FlxKey.fromString(key)];
			userBinds.set(input, daKeys);
		}

		for (key in defaultBinds.keys())
			if (!userBinds.exists(key))
				userBinds.set(key, defaultBinds[key]);
		#end

		var ctrlbinds:Array<Dynamic> = json.ctrlbinds;
		for (bind in ctrlbinds)
		{
			var input:String = bind.input;
			var keys:Array<String> = bind.keys;
			var daKeys:Array<FlxGamepadInputID> = [for (key in keys) FlxGamepadInputID.fromString(key)];
			userControllerBinds.set(input, daKeys);
		}
		for (key in defaultControllerBinds.keys())
			if (!userControllerBinds.exists(key))
				userControllerBinds.set(key, defaultControllerBinds[key]);
		saveBinds();
	}

	public function bindsToJson():Dynamic
	{
		var binds = [];
		var ctrlbinds = [];
		#if FLX_KEYBOARD
		for (bind in userBinds.keys())
		{
			var keys = [];
			for (key in userBinds[bind])
				keys.push(key.toString());
			binds.push({
				input: bind,
				keys: keys
			});
		}
		#end

		for (bind in userControllerBinds.keys())
		{
			var keys = [];
			for (key in userControllerBinds[bind])
				keys.push(key.toString());
			ctrlbinds.push({
				input: bind,
				keys: keys
			});
		}
		var json:{binds:Array<{input:String, keys:Array<String>}>, ctrlbinds:Array<{input:String, keys:Array<String>}>} = {
			binds: binds,
			ctrlbinds: ctrlbinds
		};
		return json;
	}

	public function getPrompt(control:String = 'default', ?font:Bool = false)
	{
		var data = {keyboard: 'mouse', controller: 'rstick_neutral'}
		if (control == 'default')
			return data;

		if (userBinds.exists(control))
			data.keyboard = userBinds[control][0].toString().toLowerCase();
		if (userControllerBinds.exists(control))
			data.controller = userControllerBinds[control][0].toString()
				.replace('LEFT_STICK_DIGITAL', 'lstick')
				.replace('RIGHT_STICK_DIGITAL', 'rstick')
				.toLowerCase();

		if (controllerType == 'playstation' && font)
		{
			data.controller = switch (data.controller)
			{
				case 'a': '£';
				case 'b': '¢';
				case 'x': '¤';
				case 'y': '€';
				default: data.controller;
			}
		}

		if (FlxG.onMobile)
		{
			data.controller = switch (data.controller)
			{
				case 'a': '¥';
				case 'b': 'X';

				default: data.controller;
			}
		}
		return data;
	}
}
