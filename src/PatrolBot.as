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
		protected var visionType:String;
		protected var visionRadius:int;
		
     // public var angle:Number;    // This actually exists! It's defined in FlxObject.
		protected var direction:String;
				
		public function PatrolBot(x:int, y:int, tickSpeed:int, visionType:String, visionRadius:int ) 
		{
			super(x, y);
			this.tickSpeed = tickSpeed;
			if (tickSpeed < moveTime) tickSpeed = moveTime + 2; // just in case ... ?
			this.visionType = visionType;
			this.visionRadius = visionRadius;			
			loadGraphic(Assets.PATROL, false, true, 16, 16);
		}
		/*
		public function clone():PatrolBot
		{
			return new PatrolBot(x, y, tickspeed, visiontype, visionradius);
		}
		*/
		override public function update():void
		{
			tickCount++;
			if (tickCount == tickSpeed)
			{
				tickCount = 0;
				tick();
			}
			
			super.update();
			
			// if we moved last tick, update
			if (moving) (FlxG.state as PlayState).updateDetected();
		}
		
		protected function tick():void { }
		
		protected function turnTo(newdir:String):void
		{
			// TODO: take half of movespeed to turn.
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