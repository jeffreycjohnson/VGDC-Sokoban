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
		
		protected var _lastXo:int; // used in updateDetected so that the square it was at last doesn't get highlighted.
		protected var _lastYo:int;
		public function get lastXo():int { return _lastXo; }
		public function get lastYo():int { return _lastYo; }
		
		protected var movingLast:Boolean = false; // corresponds to the moving boolean. detects if we need to change idle to walking animation, or vice versa.
		
		public function PatrolBot(x:int, y:int, tickSpeed:int, visionAngle:Number, visionRadius:int, visionType:String ) 
		{
			super(x, y);
			this.tickSpeed = tickSpeed;
			if (tickSpeed < moveTime) tickSpeed = moveTime;
			if (tickSpeed < turnTime) tickSpeed = turnTime;
			_visionAngle = visionAngle;
			_visionRadius = visionRadius+1;
			_visionType = visionType;
			loadGraphic(Assets.PATROLBOT1, true, false, 16, 16);
			createAnimations();
			
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
			
			while (_theta >= 2 * Math.PI) _theta -= 2 * Math.PI;
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
					FlxG.play(Assets.SOUND_ROBOTSTEP);
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
			
			// if turning
			if (turning)
			{
				var adj:Number = _theta - Math.PI / 2;
				while (adj >= 2 * Math.PI) adj -= 2 * Math.PI;
				while (adj < 0) adj += 2 * Math.PI;
				
				if (adj > 7 * Math.PI / 4 || adj < Math.PI / 4) direction = Dir.EAST;
				else if (adj > Math.PI / 4 && adj < 3 * Math.PI / 4) direction = Dir.NORTH;
				else if (adj > 3 * Math.PI / 4 && adj < 5 * Math.PI / 4) direction = Dir.WEST;
				else if (adj > 5 * Math.PI / 4 && adj < 7 * Math.PI / 4) direction = Dir.SOUTH;
				
			}
			var dir:String = "_";
			if (direction == Dir.NORTH) dir += "up";
			else if (direction == Dir.SOUTH) dir += "down";
			else if (direction == Dir.EAST) dir += "right";
			else if (direction == Dir.WEST) dir += "left";
			
			if (moving && !movingLast)
			{
				movingLast = true;
				play("walk" + dir);
				
			}
			else if (!moving && movingLast)
			{
				movingLast = false;
				play("idle" + dir);
			}
			else if (turning)
			{
				play("idle" + dir);
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
			
			_lastXo = 0;
			_lastYo = 0;
			
			FlxG.play(Assets.SOUND_ROBOTSTEP);
			
		}
		
		protected function tick():void { }
		
		override public function move(xo:int, yo:int):void
		{
			super.move(xo, yo);
			_lastXo = xo;
			_lastYo = yo;
			FlxG.play(Assets.SOUND_ROBOTSTEP);
		}
		
		protected function createAnimations():void
		{
			addAnimation("idle_down", [0]);
			addAnimation("walk_down", [0, 0], 30);
			
			addAnimation("idle_up", [3]);
			addAnimation("walk_up", [3, 3], 30);
			
			addAnimation("idle_right", [6]);
			addAnimation("walk_right", [6, 6], 30);
			
			addAnimation("idle_left", [9]);
			addAnimation("walk_left", [9, 9], 30);
		}
		
		
	}

}