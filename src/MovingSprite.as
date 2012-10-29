package  
{
	import org.flixel.*;
	
	public class MovingSprite extends FlxSprite
	{
		protected const movespeed:Number = 3; // how many pixels per update we go.
		protected const movetime:Number = PlayState.TILESIZE / movespeed; // how many updates we go through to move one tile.
		private const tilesize:int = PlayState.TILESIZE;
		
		private var moving:Boolean;
		private var move_xo:int; // direction of movement
		private var move_yo:int; // direction of movement
		private var movecount:int;
		
		public function MovingSprite(x:int, y:int) 
		{
			super(x, y);
			moving = false;
		}
		
		override public function update():void
		{
			// if we are supposed to be moving, then move.
			if (moving)
			{
				x += move_xo * movespeed;
				y += move_yo * movespeed;
				movecount++;
				// if we are done moving, then stop moving and snap to the nearest tile.
				if (movecount >= movetime)
				{
					x = (int)((x + tilesize / 2) / tilesize) * tilesize;
					y = (int)((y + tilesize / 2) / tilesize) * tilesize;
					moving = false;
				}
			}
		}
		
		public function move(xo:int, yo:int):void
		{
			// set our new destination and start moving
			moving = true;
			move_xo = xo;
			move_yo = yo;
			movecount = 0;
		}
				
		public function isMoving():Boolean
		{
			return moving;
		}
		
	}

}