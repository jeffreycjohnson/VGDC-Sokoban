package  
{
	/**
	 * Stores all the art and music assets for public access.
	 */
	public class Assets 
	{
		// level layout
		[Embed(source = "../assets/wall.png")] public static var WALL:Class;
		[Embed(source = "../assets/window.png")] public static var WINDOW:Class;
		[Embed(source = "../assets/floor.png")] public static var FLOOR:Class;
		[Embed(source = "../assets/block.png")] public static var BLOCK:Class;
		
		// moving level objects
		[Embed(source = "../assets/player.png")] public static var PLAYER:Class;
		[Embed(source = "../assets/patrolbot1.png")] public static var PATROLBOT1:Class;
		[Embed(source = "../assets/rotatingbot.png")] public static var ROTATINGBOT:Class;
		[Embed(source = "../assets/laser.png")] public static var LASER:Class;
		[Embed(source = "../assets/patrol2.png")] public static var PATROL_HIGHLIGHT:Class;
		
		// technical
		[Embed(source = "../assets/button.png")] public static var BUTTON:Class;
		[Embed(source = "../assets/background.png")] public static var BG:Class;
		[Embed(source = "../assets/gratebg.png")] public static var GRATE_BG:Class;
		[Embed(source = "../assets/blockcounter.png")] public static var BLOCK_COUNTER:Class;

		
		// fonts
		[Embed(source="../assets/visitor.ttf", fontFamily="PIXEL", embedAsCFF="false")] public	static var FONT_VISITOR:String;
	}

}