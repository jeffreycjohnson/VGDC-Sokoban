package  
{
	import flash.events.Event;
	import flash.net.URLLoader;
	
	/**
	 * Stores the levels for access by PlayState in begin().
	 */
	public class LevelStorage 
	{
		[Embed(source = "../levels/level_00.oel", mimeType = "application/octet-stream")] public static const level_00:Class;
		[Embed(source = "../levels/level_01.oel", mimeType = "application/octet-stream")] public static const level_01:Class;
		[Embed(source = "../levels/level_02.oel", mimeType = "application/octet-stream")] public static const level_02:Class;
		[Embed(source = "../levels/level_03.oel", mimeType = "application/octet-stream")] public static const level_03:Class;
		
		public static var levels:Array = [];
	}

}