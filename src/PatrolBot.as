package  
{
	import org.flixel.*;
	
	/**
	 * A robot that patrols around the level and has a vision radius the player must avoid. Patterns defined in subclasses.
	 */
	public class PatrolBot extends MovingSprite
	{
		protected var tickSpeed:int;
		
		protected var tickCount:int = 0;
		protected var _visionType:String;
		protected var _visionRadius:int;
		protected var _theta:Number;
		protected var direction:String;
		
		public function get visionType():String { return _visionType; }
		public function get visionRadius():int { return _visionRadius; };
		public function get theta():int { return _theta; };
		public function get visionAngle():int { return Math.PI / 3 };
		
		public function PatrolBot(x:int, y:int, tickSpeed:int, visionType:String, visionRadius:int ) 
		{
			super(x, y);
			this.tickSpeed = tickSpeed;
			if (tickSpeed < moveTime) tickSpeed = moveTime + 2; // just in case ... ?
			_visionType = visionType;
			_visionRadius = visionRadius;
			_theta = 0;
			loadGraphic(Assets.PATROL, false, true, 16, 16);
		}
		
		public function clonePatrolBot():PatrolBot
		{
			return new PatrolBot(x, y, tickSpeed, visionType, visionRadius);
		}
		
		override public function update():void
		{
			super.update();
			
			tickCount++;
			if (tickCount == tickSpeed)
			{
				tickCount = 0;
				tick();
			}
			
			// if we moved last tick, update
			if (movedLast)
			{
				(FlxG.state as PlayState).updateDetected();
				movedLast = false;
			}
		}
		
		protected function tick():void { }
		
		protected function turnTo(newdir:String):void
		{
			// TODO: take half of movespeed to turn.
			// TODO: call updateDetected while turning.
			//trace("turning to " + newdir);
			direction = newdir;
		}
		
		protected function turnAround():void
		{
			if (direction == Dir.NORTH) turnTo(Dir.SOUTH);
			else if (direction == Dir.SOUTH) turnTo(Dir.NORTH);
			else if (direction == Dir.EAST) turnTo(Dir.WEST);
			else if (direction == Dir.WEST) turnTo(Dir.EAST);
		}
		
	}

}