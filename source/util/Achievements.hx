package util;

import flixel.FlxCamera;
#if newgrounds
import io.newgrounds.NG;
#end

class Achievements
{
	public var save:Map<String,
		{
			unlocked:Bool,
			?unlockTime:String
		}> = [];

	public var achievementsList:Array<String> = [];
	public var achievements:Map<String,
		{
			image:String,
			lockedDesc:String,
			unlockedDesc:String,
			hidden:Bool,
			difficulty:Int,
			?ngid:Int,
			?steamid:String
		}> = [];

	public function new()
	{
		initAchievements();

		if (FlxG.save.data.achievements != null)
			saveData();
	}

	function initAchievements()
	{
		achievementsList.push('Sample Achievement 1');
		achievements.set('Sample Achievement 1', {
			image: 'assets/images/achievements/locked.png',
			lockedDesc: 'Wait one million years to unlock this achievement.',
			unlockedDesc: 'Unlocked Sample Achievement.',
			hidden: false,
			difficulty: 1,
		});
		achievementsList.push('Sample Achievement 2');
		achievements.set('Sample Achievement 2', {
			image: 'assets/images/achievements/locked.png',
			lockedDesc: 'Wait two million years to unlock this achievement.',
			unlockedDesc: 'Unlocked Sample Achievement.',
			hidden: false,
			difficulty: 1,
		});
		achievementsList.push('Sample Achievement 3');
		achievements.set('Sample Achievement 3', {
			image: 'assets/images/achievements/locked.png',
			lockedDesc: 'Wait three million years to unlock this achievement.',
			unlockedDesc: 'Unlocked Sample Achievement.',
			hidden: false,
			difficulty: 1,
		});
		achievementsList.push('Sample Achievement 4');
		achievements.set('Sample Achievement 4', {
			image: 'assets/images/achievements/locked.png',
			lockedDesc: 'Wait four million years to unlock this achievement.',
			unlockedDesc: 'Unlocked Sample Achievement.',
			hidden: false,
			difficulty: 1,
		});
		achievementsList.push('Sample Achievement 5');
		achievements.set('Sample Achievement 5', {
			image: 'assets/images/achievements/locked.png',
			lockedDesc: 'Wait five million years to unlock this achievement.',
			unlockedDesc: 'Unlocked Sample Achievement.',
			hidden: false,
			difficulty: 1,
		});
		achievementsList.push('Sample Achievement 6');
		achievements.set('Sample Achievement 6', {
			image: 'assets/images/achievements/locked.png',
			lockedDesc: 'Wait six million years to unlock this achievement.',
			unlockedDesc: 'Unlocked Sample Achievement.',
			hidden: false,
			difficulty: 1,
		});

		for (i in achievementsList)
			save.set(i, {unlocked: false, unlockTime: null});
	}

	function saveData()
	{
		var s:Map<String, {unlocked:Bool, ?unlockTime:String}> = FlxG.save.data.achievements;

		for (i in achievementsList)
		{
			if (s.exists(i))
			{
				save.get(i).unlocked = s.get(i).unlocked;
				save.get(i).unlockTime = s.get(i).unlockTime;
			}

			// Unlock medals if they are locally unlocked
			#if newgrounds
			var id = achievements.get(i).ngid;
			if (id == null)
				continue;
			if (!NG.core.medals.get(id).unlocked && save.get(i).unlocked)
				NG.core.medals.get(id).sendUnlock(callback ->
				{
					trace(callback);
				});
			#end
		}
		FlxG.save.data.achievements = save;
		FlxG.save.flush();
	}

	public function unlock(achievement:String)
	{
		if (save.get(achievement).unlocked)
			return;

		#if newgrounds
		var id = achievements.get(achievement).ngid;
		if (id != null)
			NG.core.medals.get(id).sendUnlock(callback ->
			{
				trace(callback);
			});
		#end

		#if steam
		#end

		save.get(achievement).unlocked = true;
		save.get(achievement).unlockTime = Date.now().toString();

		FlxG.save.data.achievements = save;
		FlxG.save.flush();

		cast(FlxG.state, DefaultState).achievementPopups.push(achievement);
	}
}
