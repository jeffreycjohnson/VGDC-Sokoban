package  
{
	import org.flixel.*;
	
	public class MovingSprite extends FlxSprite
	{
		protected const moveSpeed:Number = 3; // how many pixels per update we go.
		protected const moveTime:Number = PlayState.TILESIZE / moveSpeed; // how many updates we go through to move one tile.
		private const tileSize:int = PlayState.TILESIZE;
		
		private var moving:Boolean;
		private var move_xo:int; // direction of movement
		private var move_yo:int; // direction of movement
		private var moveCount:int;
		
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
				x += move_xo * moveSpeed;
				y += move_yo * moveSpeed;
				moveCount++;
				// if we are done moving, then stop moving and snap to the nearest tile.
				if (moveCount >= moveTime)
				{
					x = (int)((x + tileSize / 2) / tileSize) * tileSize;
					y = (int)((y + tileSize / 2) / tileSize) * tileSize;
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
			moveCount = 0;
		}
				
		public function isMoving():Boolean
		{
			return moving;
		}
		
	}

}