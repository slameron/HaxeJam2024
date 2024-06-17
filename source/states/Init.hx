package states;

import flash.Lib;
import haxe.CallStack;
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
#if newgrounds
import io.newgrounds.NG;
import io.newgrounds.components.AppComponent;
#end

class Init extends FlxState
{
	public static var controls:util.Controls;

	public static var achievements:util.Achievements;

	override public function create()
	{
		initSave();

		FlxG.log.redirectTraces = true;
		FlxG.keys.preventDefaultKeys = [UP, DOWN];
		controls = new util.Controls();

		achievements = new Achievements();

		Application.current.meta.set('nightly', '');
		Application.current.meta.set('version', '0.1.0');
		Application.current.meta.set('title', 'Wizworld');

		#if (desktop)
		FlxG.fullscreen = FlxG.save.data.fullscreen;
		#end
		FlxG.sound.volume = FlxG.save.data.masterVolume;

		#if mobile
		@:privateAccess
		FlxG.game.soundTray = Type.createInstance(FlxG.game._customSoundTray, []);
		#end

		FlxG.game.soundTray.volumeUpSound = 'assets/sounds/volUp';
		FlxG.game.soundTray.volumeDownSound = 'assets/sounds/volDown';

		openfl.Lib.current.stage.application.onExit.add(function(code)
		{
			FlxG.save.data.masterVolume = FlxG.sound.volume;
			FlxG.save.flush();
		});

		FlxG.switchState(new states.Title(false));
	}

	function initSave()
	{
		FlxG.save.bind('Wizworld', 'slameron');

		if (FlxG.save.data.fullscreen == null)
			FlxG.save.data.fullscreen = false;

		if (FlxG.save.data.masterVolume == null)
			FlxG.save.data.masterVolume = 1;
		if (FlxG.save.data.musicVolume == null)
			FlxG.save.data.musicVolume = .5;
		if (FlxG.save.data.soundVolume == null)
			FlxG.save.data.soundVolume = 1;

		if (FlxG.save.data.slimeKills == null)
			FlxG.save.data.slimeKills = 0;
		if (FlxG.save.data.skeletonKills == null)
			FlxG.save.data.skeletonKills = 0;
		if (FlxG.save.data.bossKills == null)
			FlxG.save.data.bossKills = 0;
		if (FlxG.save.data.playerAdvantages == null)
			FlxG.save.data.playerAdvantages = 0;

		FlxG.save.flush();
	}
}
