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
		
		protected var _visionAngle:Number;
		protected var _visionRadius:int;
		protected var _visionType:String;
		
		public function get visionAngle():Number { return _visionAngle; };
		public function get visionRadius():int { return _visionRadius; };
		public function get visionType():String { return _visionType; }
		public function get theta():Number { return _theta; };
		
		protected const turnTime:int = 12; // how many ticks it takes to turn PI/2 radians
		protected const turnSpeed:Number = Math.PI / 2 / turnTime;
		
		protected var turning:Boolean;
		protected var turnedLast:Boolean; // used in PatrolBot.update()
		protected var turnDir:int; // direction of turn
		protected var turnCount:int;
		protected var _theta:Number;
		protected var direction:String;
		
		public function PatrolBot(x:int, y:int, tickSpeed:int, visionAngle:Number, visionRadius:int, visionType:String ) 
		{
			super(x, y);
			this.tickSpeed = tickSpeed;
			if (tickSpeed < moveTime) tickSpeed = moveTime;
			if (tickSpeed < turnTime) tickSpeed = turnTime;
			_visionAngle = visionAngle;
			_visionRadius = visionRadius+1;
			_visionType = visionType;
			_theta = 0 + Math.PI / 2;
			loadGraphic(Assets.PATROL, false, true, 16, 16);
			
			(FlxG.state as PlayState).updateDetectedNext = true;
		}
		
		public function clonePatrolBot():PatrolBot
		{
			return new PatrolBot(x, y, tickSpeed, _visionAngle, _visionRadius, _visionType);
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
			
			while (_theta > 2 * Math.PI) _theta -= 2 * Math.PI;
			while (_theta < 0) _theta += 2 * Math.PI;
			
			// if we are supposed to be turning, then turn.
			if (turning)
			{
				_theta += turnDir * turnSpeed;
				turnCount++;
				turnedLast = true;
				// if we are done turning, then stop turning. (no need to snap, I don't think. it's precice enough.)
				if (turnCount >= turnTime)
				{
					turning = false;
				}
			}
			
			// if we moved or turned last tick, update detected.
			if (movedLast)
			{
				(FlxG.state as PlayState).updateDetectedNext = true;
				movedLast = false;
			}
			if (turnedLast)
			{
				(FlxG.state as PlayState).updateDetectedNext = true;
				turnedLast = false;
			}
			
		}
		
		protected function turn(td:int):void
		{
			// Note: td stands for the number of positive 90degree rotations to do. (you can supply negative numbers as well)
			// 1 - do the actual turning
			turning = true;
			turnDir = td;
			turnCount = 0;
			(FlxG.state as PlayState).updateDetectedNext = true;
			
			// 2 - set the new direction
			var order:Array = [Dir.SOUTH, Dir.WEST, Dir.NORTH, Dir.EAST, Dir.SOUTH, Dir.WEST, Dir.NORTH, Dir.EAST];
			var index:int;
			if (direction == Dir.NORTH) index = 2;
			else if (direction == Dir.EAST) index = 3;
			else if (direction == Dir.SOUTH) index = 4;
			else if (direction == Dir.WEST) index = 5;
			direction = order[index + turnDir];
		}
		
		protected function tick():void { }
		
		
	}

}