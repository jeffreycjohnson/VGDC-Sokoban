package  
{
	/**
	 * Laser that sees in a straight horizontal or vertical line, and does not move.
	 */
	
	import org.flixel.*;
	 
	public class Laser extends PatrolBot
	{
		private var type:String; // "left", "right", "up", or "down"
		
		public function Laser(x:int, y:int, type:String) 
		{
			super(x, y, 100, 0, 20, "straight");
			// TODO: Give the graphic the correct orientation
			loadGraphic(Assets.LASER, false, true, 8, 16);
			this.type = type;
			if (type == "right")
			{
				direction = Dir.EAST;
				_theta = 0 + Math.PI / 2;
			}
			else if (type == "down")
			{
				direction = Dir.SOUTH;
				_theta = 3 * Math.PI / 2 + Math.PI / 2;
			}
			if (type == "left")
			{
				direction = Dir.WEST;
				_theta = 0 + 3 * Math.PI / 2;
			}
			else if (type == "up")
			{
				direction = Dir.NORTH;
				_theta = Math.PI / 2 + Math.PI / 2;
			}
		}
		
		public function clone():Laser
		{
			return new Laser(x, y, type);
		}
	}

}