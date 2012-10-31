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
			
			// if we moved or turned last tick, update detected.
			if (movedLast)
			{
				(FlxG.state as PlayState).updateDetected();
				movedLast = false;
			}
			if (turnedLast)
			{
				(FlxG.state as PlayState).updateDetected();
				turnedLast = false;
			}
			
		}
		
		protected function tick():void { }
		
		
	}

}