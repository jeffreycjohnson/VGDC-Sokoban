package  
{
	import flash.events.Event;
	import flash.net.URLLoader;
	
	public class LevelStorage 
	{
		[Embed(source = "../levels/level_00.oel", mimeType = "application/octet-stream")] public static const level_00:Class;
		[Embed(source = "../levels/level_01.oel", mimeType = "application/octet-stream")] public static const level_01:Class;
		
		public static var levels:Array = [];
	}

}