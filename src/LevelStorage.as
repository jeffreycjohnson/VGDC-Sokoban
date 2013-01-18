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
		[Embed(source = "../levels/level_78.oel", mimeType = "application/octet-stream")] public static const level_04:Class;
		[Embed(source = "../levels/level_17.oel", mimeType = "application/octet-stream")] public static const level_05:Class;
		[Embed(source = "../levels/level_76.oel", mimeType = "application/octet-stream")] public static const level_06:Class;
		[Embed(source = "../levels/level_18.oel", mimeType = "application/octet-stream")] public static const level_07:Class;
		[Embed(source = "../levels/level_79.oel", mimeType = "application/octet-stream")] public static const level_08:Class;
		[Embed(source = "../levels/level_80.oel", mimeType = "application/octet-stream")] public static const level_09:Class;
		
		[Embed(source = "../levels/level_19.oel", mimeType = "application/octet-stream")] public static const level_10:Class;
		[Embed(source = "../levels/level_roundtrip.oel", mimeType = "application/octet-stream")] public static const level_11:Class;
		[Embed(source = "../levels/level_slots.oel", mimeType = "application/octet-stream")] public static const level_12:Class;
		[Embed(source = "../levels/level_fourcorners.oel", mimeType = "application/octet-stream")] public static const level_13:Class;
		[Embed(source = "../levels/level_componentwise.oel", mimeType = "application/octet-stream")] public static const level_14:Class;
		[Embed(source = "../levels/level_shield.oel", mimeType = "application/octet-stream")] public static const level_15:Class;
		
		[Embed(source = "../levels/level_notsouseless.oel", mimeType = "application/octet-stream")] public static const level_20:Class;
		[Embed(source = "../levels/level_hunter4.oel", mimeType = "application/octet-stream")] public static const level_21:Class;
		[Embed(source = "../levels/level_columnblocker.oel", mimeType = "application/octet-stream")] public static const level_22:Class;
		[Embed(source = "../levels/level_thirdwheel.oel", mimeType = "application/octet-stream")] public static const level_23:Class;
		[Embed(source = "../levels/level_warehouse.oel", mimeType = "application/octet-stream")] public static const level_24:Class;
		[Embed(source = "../levels/level_99.oel", mimeType = "application/octet-stream")] public static const level_25:Class;
		
		[Embed(source = "../levels/level_666.oel", mimeType = "application/octet-stream")] public static const level_30:Class;
		[Embed(source = "../levels/level_graphicstest.oel", mimeType = "application/octet-stream")] public static const level_31:Class;
		[Embed(source = "../levels/level_75.oel", mimeType = "application/octet-stream")] public static const level_32:Class;
		[Embed(source = "../levels/level_77.oel", mimeType = "application/octet-stream")] public static const level_33:Class;
		
		public static var chapterLengths:Array = [10, 6, 6, 4]; // change this manually !!
		public static var chapterNames:Array = ["Underground Silo", "Development Lab", "Headquarters", "Extra Levels"];
		public static var minMoves:Array = [[100, 100, 100, 100, 100, 100, 100, 100, 100, 100],
											[100, 100, 100, 100, 100, 100, 100, 100, 100, 100],
											[100, 100, 100, 100, 100, 100, 100, 100, 100, 100],
											[100, 100, 100, 100, 100, 100, 100, 100, 100, 100]];
		public static var levels:Array = [];
		
		public static function getLevelString(x:int, y:int):String
		{
			return "level_" + x.toString() + y.toString();
		}
	}

}