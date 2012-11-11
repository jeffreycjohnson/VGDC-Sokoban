package  
{
	import org.flixel.*;
	
	/**
	 * A FlxSprite that can be told to move up, down, left, or right.
	 */
	public class MovingSprite extends FlxSprite
	{
		protected const tileSize:int = PlayState.TILESIZE;
		
		protected var gridX:int; // x index in the level array
		protected var gridY:int; // y index in the level array
		public function get getGridX():int { return gridX; };
		public function get getGridY():int { return gridY; };
		
		protected const moveTime:int = 6; // how many ticks it takes to move 1 tile
		protected const moveSpeed:Number = PlayState.TILESIZE / moveTime;
		
		protected var moving:Boolean;
		protected var movedLast:Boolean; // used in PatrolBot.update()
		protected var move_xo:int; // direction of movement
		protected var move_yo:int; // direction of movement
		protected var moveCount:int;
		
		public function MovingSprite(x:int, y:int) 
		{
			super(x, y);
			moving = false;
			gridX = (x - PlayState.XOFFSET) / PlayState.TILESIZE;
			gridY = (y - PlayState.YOFFSET) / PlayState.TILESIZE;
		}
		
		override public function update():void
		{
			// if we are supposed to be moving, then move.
			if (moving)
			{
				x += move_xo * moveSpeed;
				y += move_yo * moveSpeed;
				moveCount++;
				movedLast = true;
				// if we are done moving, then stop moving.
				if (moveCount >= moveTime)
				{
					//x = (int)((x + tileSize / 2) / tileSize) * tileSize;
					//y = (int)((y + tileSize / 2) / tileSize) * tileSize; // no need to snap?
					moving = false;
				}
			}
		}
		
		public function move(xo:int, yo:int):void
		{
			gridX += xo;
			gridY += yo;
			
			moving = true;
			move_xo = xo;
			move_yo = yo;
			moveCount = 0;
			
			(FlxG.state as PlayState).updateDetectedNext = true; // added to reflect changes if a block is pushed into a vision area.
		}
				
		public function isMoving():Boolean
		{
			return moving;
		}
		
		public function updateGridValues():void
		{
			// used only in loadLevel after we move the sprite by the offset, we need to re-set these values.
			gridX = (x - PlayState.XOFFSET) / PlayState.TILESIZE;
			gridY = (y - PlayState.YOFFSET) / PlayState.TILESIZE;
		}
	}

}