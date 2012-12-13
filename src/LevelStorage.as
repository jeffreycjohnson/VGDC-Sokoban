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
		[Embed(source = "../levels/level_13.oel", mimeType = "application/octet-stream")] public static const level_02:Class;
		[Embed(source = "../levels/level_16.oel", mimeType = "application/octet-stream")] public static const level_03:Class;
		[Embed(source = "../levels/level_17.oel", mimeType = "application/octet-stream")] public static const level_04:Class;
		[Embed(source = "../levels/level_18.oel", mimeType = "application/octet-stream")] public static const level_05:Class;
		[Embed(source = "../levels/level_19.oel", mimeType = "application/octet-stream")] public static const level_06:Class;
		
		[Embed(source = "../levels/level_666.oel", mimeType = "application/octet-stream")] public static const level_10:Class;
		[Embed(source = "../levels/level_99.oel", mimeType = "application/octet-stream")] public static const level_11:Class;
		[Embed(source = "../levels/level_roundtrip.oel", mimeType = "application/octet-stream")] public static const level_12:Class;
		[Embed(source = "../levels/level_columnblocker.oel", mimeType = "application/octet-stream")] public static const level_13:Class;
		[Embed(source = "../levels/level_graphicstest.oel", mimeType = "application/octet-stream")] public static const level_14:Class;
		
		[Embed(source = "../levels/level_10.oel", mimeType = "application/octet-stream")] public static const level_20:Class;
		
		public static var chapterLengths:Array = [7, 5, 1]; // change this manually !!
		public static var chapterNames:Array = ["Introduction", "Test Chapter2", "Test Chapter3"];
		public static var minMoves:Array = [[100, 100, 100, 100, 100, 100, 100],
											[100, 100, 100, 100, 100],
											[100]];
		public static var levels:Array = [];
		
		public static function getLevelString(x:int, y:int):String
		{
			return "level_" + x.toString() + y.toString();
		}
	}

}