package  
{
	/**
	 * Stores all the art and music assets for public access.
	 */
	public class Assets 
	{
		// old
		[Embed(source = "../assets/wall.png")] public static var WALL:Class;
		[Embed(source = "../assets/floor.png")] public static var FLOOR:Class;
		[Embed(source = "../assets/goal.png")] public static var GOAL:Class;
		[Embed(source = "../assets/block.png")] public static var BLOCK:Class;
		[Embed(source = "../assets/patrol2.png")] public static var PATROL_HIGHLIGHT:Class;
		
		// new
		[Embed(source = "../assets/player.png")] public static var PLAYER:Class;
		[Embed(source = "../assets/patrolbot1.png")] public static var PATROLBOT1:Class;
		[Embed(source = "../assets/background.png")] public static var BG:Class;
		
		// non-animated new
		[Embed(source = "../assets/rotatingbot.png")] public static var ROTATINGBOT:Class;
		[Embed(source = "../assets/laser.png")] public static var LASER:Class;
		[Embed(source = "../assets/wallrepeat.png")] public static var WALLREPEAT:Class;
	}

}