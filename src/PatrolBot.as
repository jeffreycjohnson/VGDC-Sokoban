package  
{
	import org.flixel.*;
		
	public class PatrolBot extends MovingSprite
	{
		protected var tickspeed:int;
		
		protected var tickcount:int = 0;
		protected var visiontype:String;
		protected var visionradius:int;
		
     // public var angle:Number;    // This actually exists! It's defined in FlxObject.
		protected var direction:String;
		
		
		public function PatrolBot(x:int, y:int, tickspeed:int, visiontype:String, visionradius:int ) 
		{
			this.tickspeed = tickspeed;
			if (tickspeed < movetime) tickspeed = movetime + 2; // just in case ... ?
			this.visiontype = visiontype;
			this.visionradius = visionradius;
			super(x, y);
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
			tickcount++;
			if (tickcount == tickspeed)
			{
				tickcount = 0;
				tick();
			}
			super.update();
		}
		
		protected function tick():void { }
		
		protected function turnTo(newdir:String):void
		{
			// TODO: take half of movespeed to turn.
			trace("turning to " + newdir);
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