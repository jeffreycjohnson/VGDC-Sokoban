package  
{
	import flash.events.Event;
	import flash.net.URLLoader;
	
	/**
	 * Stores the levels for access by PlayState in begin().
	 */
	public class LevelStorage 
	{
		[Embed(source = "../levels/level_10.oel", mimeType = "application/octet-stream")] public static const level_00:Class;
		[Embed(source = "../levels/level_11.oel", mimeType = "application/octet-stream")] public static const level_01:Class;
		[Embed(source = "../levels/level_12.oel", mimeType = "application/octet-stream")] public static const level_02:Class;
		[Embed(source = "../levels/level_13.oel", mimeType = "application/octet-stream")] public static const level_03:Class;
		[Embed(source = "../levels/level_14.oel", mimeType = "application/octet-stream")] public static const level_04:Class;
		//[Embed(source = "../levels/level_07.oel", mimeType = "application/octet-stream")] public static const level_04:Class;
		//[Embed(source = "../levels/level_99.oel", mimeType = "application/octet-stream")] public static const level_05:Class;
		//[Embed(source = "../levels/level_03.oel", mimeType = "application/octet-stream")] public static const level_06:Class;
		//[Embed(source = "../levels/level_666.oel", mimeType = "application/octet-stream")] public static const level_07:Class;
		
		public static var levels:Array = [];
		
		public static function getLevelString(index:int):String
		{
			var s:String = "level_";
			if (index < 10) s += "0";
			s += index.toString();
			return s;
			
		}
	}

}