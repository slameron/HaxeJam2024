package util;

import flixel.FlxObject;
#if (flixel <= version('5.3.0'))
import flixel.system.FlxSound;
#else
import flixel.sound.FlxSound;
#end

class Sound
{
	public static var panRadius:Float = 150;

	static var sounds:Array<FlxSound> = [];
	static var musics:Array<FlxSound> = [];

	public static var menuMusic:FlxSound;
	public static var gameMus:FlxSound;

	public static function play(key:String, ?source:FlxObject, ?playa:FlxObject):FlxSound
	{
		var newSound = new FlxSound().loadEmbedded(RetPath.sound(key));
		newSound.volume = FlxG.save.data.soundVolume * FlxG.save.data.masterVolume;
		if (key == 'fire_shotgun')
			newSound.volume *= .4;

		if (source != null)
			newSound.proximity(source.x + source.width / 2, source.y + source.height / 2, playa, panRadius, true);

		newSound.autoDestroy = true;
		newSound.onComplete = () -> sounds.remove(newSound);
		newSound.play();

		sounds.push(newSound);

		updateSounds(0);

		return newSound;
	}

	public static function playMusic(key:String):FlxSound
	{
		var newSound = new FlxSound().loadEmbedded(RetPath.music(key), true);
		newSound.volume = FlxG.save.data.musicVolume * FlxG.save.data.masterVolume;
		newSound.play();
		newSound.update(0);
		// newSound.persist = true;

		musics.push(newSound);

		return newSound;
	}

	public static function updateSounds(elapsed:Float)
	{
		for (sound in sounds)
			sound.update(elapsed);

		for (sound in musics)
			if (sound != null)
				sound.update(elapsed);
	}
}
