package  
{
	/**
	 * PatrolBot that goes in a straight horizontal or vertical line, turning around at walls.
	 */
	
	import org.flixel.*;
	 
	public class PaceBot extends PatrolBot
	{
		private var type:String; // "horizontal" or "vertical"
		
		public function PaceBot(x:int, y:int, ts:int, va:Number, vr:int, vt:String, type:String) 
		{
			super(x, y, ts, va, vr, vt);
			this.type = type;
			if (type == "horizontal")
			{
				direction = Dir.EAST;
				_theta = 0 + Math.PI / 2;
			}
			else if (type == "vertical")
			{
				direction = Dir.SOUTH;
				_theta = 3 * Math.PI / 2 + Math.PI / 2;
			}
		}
		
		public function clone():PaceBot
		{
			return new PaceBot(x, y, tickSpeed, _visionAngle, _visionRadius, _visionType, type);
		}
		
		override protected function tick():void
		{
			var xo:int = 0;
			var yo:int = 0;
			if (direction == Dir.NORTH) yo = -1;
			else if (direction == Dir.SOUTH) yo = 1;
			else if (direction == Dir.EAST) xo = 1;
			else if (direction == Dir.WEST) xo = -1;
			
			var x:int = x / PlayState.TILESIZE;
			var y:int = y / PlayState.TILESIZE;
			
			if ((FlxG.state as PlayState).level[x + xo][y + yo] == 0)
			{
				move(xo, yo);
				(FlxG.state as PlayState).level[x][y] = 0;
				(FlxG.state as PlayState).level[x + xo][y + yo] = 5;
			}
			else
			{
				turn(2);
			}
			
			
		}
	}

}