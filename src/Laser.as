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
			super(x, y, 5, 0, 20, "straight");
			
			this.type = type;
			if (type == "right")
			{
				loadRotatedGraphic(Assets.LASER, 4, 3);
				direction = Dir.EAST;
				_theta = 0 + Math.PI / 2;
			}
			else if (type == "down")
			{
				loadRotatedGraphic(Assets.LASER, 4, 0);
				direction = Dir.SOUTH;
				_theta = 3 * Math.PI / 2 + Math.PI / 2;
			}
			else if (type == "left")
			{
				loadRotatedGraphic(Assets.LASER, 4, 1);
				direction = Dir.WEST;
				_theta = 0 + 3 * Math.PI / 2;
			}
			else if (type == "up")
			{
				loadRotatedGraphic(Assets.LASER, 4, 2);
				direction = Dir.NORTH;
				_theta = Math.PI / 2 + Math.PI / 2;
			}
		}
		
		public function clone():Laser
		{
			return new Laser(x, y, type);
		}
		
		override protected function tick():void
		{
			(FlxG.state as PlayState).updateDetectedNext = true;
		}
	}

}