package util;

import haxe.Json;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class Save
{
	public static function exists(file:String, folder:String = ''):Bool
	{
		#if sys
		var paths:Array<String> = ['cloud', ''];

		for (path in paths)
			if (FileSystem.exists('save/${path != '' ? '$path/' : path}${folder != '' ? '$folder/' : ''}$file.json'))
				return true;
		#else
		if (FlxG.save.data.saveDataMap == null)
		{
			FlxG.save.data.saveDataMap = ["SaveDataGoesHere" => "SaveDataGoesHere"];
			FlxG.save.flush();
		}
		var dataMap:Map<String, String> = FlxG.save.data.saveDataMap;
		if (dataMap.exists(file))
			return true;
		#end

		return false;
	}

	public static function load(file:String, folder:String = ''):Dynamic
	{
		#if sys
		var paths:Array<String> = ['cloud', ''];

		for (path in paths)
			if (FileSystem.exists('save/${path != '' ? '$path/' : path}${folder != '' ? '$folder/' : ''}$file.json'))
				return haxe.Json.parse(File.getContent('save/${path != '' ? '$path/' : path}${folder != '' ? '$folder/' : ''}$file.json'));
		#else
		if (FlxG.save.data.saveDataMap == null)
		{
			FlxG.save.data.saveDataMap = ["SaveDataGoesHere" => "SaveDataGoesHere"];
			FlxG.save.flush();
		}
		var daJsonMap:Map<String, String> = FlxG.save.data.saveDataMap;
		if (daJsonMap.exists(file))
			return Json.parse(daJsonMap.get(file));
		#end

		return null;
	}

	public static function save(json:Dynamic, filename:String, cloud:Bool = false, folder:String = '')
	{
		#if sys
		var jsonString = Json.stringify(json, '\t');
		try
		{
			File.saveContent('save/${cloud ? 'cloud/' : ''}${folder != '' ? '$folder/' : ''}$filename.json', jsonString);
		}
		catch (e)
			trace(e);
		#else
		if (FlxG.save.data.saveDataMap == null)
		{
			FlxG.save.data.saveDataMap = ["SaveDataGoesHere" => "SaveDataGoesHere"];
			FlxG.save.flush();
		}
		var daJsonMap:Map<String, String> = FlxG.save.data.saveDataMap;
		daJsonMap.set(filename, Json.stringify(json, '\t'));
		FlxG.save.data.saveDataMap = daJsonMap;
		FlxG.save.flush();
		#end
	}
}
