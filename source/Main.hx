package;

import flixel.FlxG;
import flixel.FlxGame;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import lime.app.Application;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.UncaughtErrorEvent;
import util.*;
#if sys
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

class Main extends Sprite
{
	static var dateStarted:String;
	static var mainInstance:Main;
	static var game:FlxGame;

	public static function main()
	{
		dateStarted = Date.now().toString();
		@:privateAccess
		Lib.current.loaderInfo.uncaughtErrorEvents.__enabled = true;

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onError);
		#if cpp untyped __global__.__hxcpp_set_critical_error_handler(error); #end

		Lib.current.addChild(mainInstance = new Main());
	}

	public function new()
	{
		super();

		game = new FlxGame(1280, 720, #if web ClickState #else Init #end, 60, 60, true, false);
		addChild(game);
	}

	static function error(msg:String)
	{
		Discord.sendWebhookMessage(msg, Keys.crashWebhook, Application.current.meta.get('title'));
		#if sys Sys.exit(1); #end
	}

	static function onError(s:Dynamic)
	{
		var errMsg:String = "";
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		var stack:Array<String> = [];

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					stack.push(file + " (line " + line + ")");
					if (stack.length >= 15)
						break;
				default:
					#if sys
					Sys.println(stackItem);
					#end
			}
		}
		for (s in stack)
			errMsg += '$s\n';

		var system:String = '';

		#if mac
		system = 'MacOS';
		#elseif windows
		system = 'Windows';
		#elseif linux
		system = 'Linux';
		#elseif web
		system = 'Browser';
		#elseif ios
		system = 'iOS';
		#elseif android
		system = 'Android';
		#end
		#if steam
		system += ' via Steam';
		if (Steam.isSteamRunningOnSteamDeck())
			system += ' on Steam Deck';
		Steam.matchmaking.leaveLobby();
		#end
		#if newgrounds
		system += ' via Newgrounds';
		#end

		#if FLX_DEBUG
		system += ' on a debug build';
		#end

		var daState = FlxG.state != null ? Type.getClassName(Type.getClass(FlxG.state)) : 'No state';
		var logs:String = '';
		if (FlxG != null)
			if (FlxG.log != null)
				if (FlxG.log.logs != null)
					for (log in FlxG?.log?.logs)
						logs += '$log\n';
		errMsg = '**${Application.current.meta.get('title').toUpperCase()} CRASH**\n===========================\n\nUncaught Error: ${s.error}\nGame Version: v${Application.current.meta.get('version')}${Application.current.meta.get('nightly')!=''? '-${Application.current.meta.get('nightly')}': ''}\nRunning on $system\nStarted: $dateStarted\nCrashed: $dateNow\n\n===========================\n\nState: ${daState.substr(daState.lastIndexOf('.') + 1)}\nCall Stack:\n$errMsg\n===========================\n\nRecent Traces:\n$logs\n===========================';

		Discord.sendWebhookMessage(errMsg, Keys.crashWebhook, Application.current.meta.get('title'));

		var app:String = "smella";

		#if windows
		app += ".exe";
		#elseif mac
		app += '.app';
		#end
		#if sys
		if (FileSystem.exists(app))
			new Process(#if mac 'open ' + #end app, [errMsg]);
		else
		{
			var msgStr = 'You found a bug!\nThe crash log has been sent to the developer and it will be fixed as soon as possible.';

			#if FLX_DEBUG
			msgStr = errMsg;
			#end

			if (!Application.current.window.fullscreen)
				Application.current.window.alert(msgStr, "Oh brother, this game is broken!");
		}
		Sys.exit(0);
		#end
	}
}
