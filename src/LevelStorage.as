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
		
		[Embed(source = "../levels/level_666.oel", mimeType = "application/octet-stream")] public static const level_10:Class;
		[Embed(source = "../levels/level_99.oel", mimeType = "application/octet-stream")] public static const level_11:Class;
		
		public static var chapterLengths:Array = [5, 2]; // as of now, you have to change this manually, but it should be possible to have it dynamically calculated.
		
		public static var chapterNames:Array = ["Introduction", "Test Chapter2"]; // can use this in level select
		
		public static var levels:Array = [];
		
		
		// TODO: Remove this function and all references to it. Instead, use the one below.
		public static function getLevelString(index:int):String
		{
			var s:String = "level_";
			if (index < 10) s += "0";
			s += index.toString();
			return s;
			
		}
		
		public static function getLevelString2(x:int, y:int):String
		{
			return "level_" + x.toString() + y.toString();
		}
	}

}