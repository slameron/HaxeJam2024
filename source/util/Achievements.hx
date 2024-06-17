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
		achievementsList.push('Strong Man');
		achievements.set('Strong Man', {
			image: 'assets/images/achievements/strongman.png',
			lockedDesc: 'Defeat an enemy in one hit.',
			unlockedDesc: 'Defeated an enemy in one hit.',
			hidden: false,
			difficulty: 1,
		});
		achievementsList.push('Advantage Seeker');
		achievements.set('Advantage Seeker', {
			image: 'assets/images/achievements/advantageseeker.png',
			lockedDesc: 'Engage 10 battles with Player Advantage.',
			unlockedDesc: 'Engaged 10 battles with Player Advantage.',
			hidden: false,
			difficulty: 1,
		});
		achievementsList.push('Slime Slaughterer');
		achievements.set('Slime Slaughterer', {
			image: 'assets/images/achievements/slimeslaughterer.png',
			lockedDesc: 'Kill 15 slimes.',
			unlockedDesc: 'Killed 15 slimes.',
			hidden: false,
			difficulty: 1,
		});
		achievementsList.push('Skeleton Slayer');
		achievements.set('Skeleton Slayer', {
			image: 'assets/images/achievements/skeletonslayer.png',
			lockedDesc: 'Kill 15 skeletons.',
			unlockedDesc: 'Killed 15 skeletons.',
			hidden: false,
			difficulty: 1,
		});
		achievementsList.push('Wizworld Champion');
		achievements.set('Wizworld Champion', {
			image: 'assets/images/achievements/wizworldchampion.png',
			lockedDesc: 'Defeat the final boss.',
			unlockedDesc: 'Defeated the final boss.',
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
