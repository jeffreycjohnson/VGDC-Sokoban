package  
{
	/**
	 * Stores all the art and music assets for public access.
	 */
	public class Assets 
	{
		[Embed(source = "../assets/wall.png")] public static var WALL:Class;
		[Embed(source = "../assets/floor.png")] public static var FLOOR:Class;
		[Embed(source = "../assets/goal.png")] public static var GOAL:Class;
		
		[Embed(source = "../assets/player.png")] public static var PLAYER_SPRITE:Class;
		[Embed(source = "../assets/block.png")] public static var BLOCK:Class;
		[Embed(source = "../assets/patrol1.png")] public static var PATROL:Class;
		[Embed(source = "../assets/patrol2.png")] public static var PATROL_HIGHLIGHT:Class;
	}

}