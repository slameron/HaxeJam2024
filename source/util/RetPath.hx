package util;

class RetPath
{
	static inline var _extension:String = #if (desktop || mobile) '.ogg' #else '.mp3' #end;

	public static inline function sound(key:String):String
		return 'assets/sounds/$key$_extension';

	public static inline function music(key:String):String
		return 'assets/music/$key$_extension';
}
