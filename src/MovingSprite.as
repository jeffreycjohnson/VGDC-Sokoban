package  
{
	import org.flixel.*;
	
	/**
	 * A FlxSprite that can be told to move up, down, left, or right.
	 */
	public class MovingSprite extends FlxSprite
	{
		protected const tileSize:int = PlayState.TILESIZE;
		
		protected const moveTime:int = 6; // how many ticks it takes to move 1 tile
		protected const moveSpeed:Number = PlayState.TILESIZE / moveTime;
		
		protected const turnTime:int = 11; // how many ticks it takes to turn PI/2 radians
		protected const turnSpeed:Number = Math.PI / 2 / turnTime;
		
		protected var moving:Boolean;
		protected var movedLast:Boolean; // used in PatrolBot.update()
		protected var move_xo:int; // direction of movement
		protected var move_yo:int; // direction of movement
		protected var moveCount:int;
		
		protected var turning:Boolean;
		protected var turnedLast:Boolean; // used in PatrolBot.update()
		protected var turnDir:int; // direction of turn
		protected var turnCount:int;
		protected var _theta:Number;
		protected var direction:String;
		
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
				movedLast = true;
				// if we are done moving, then stop moving and snap to the nearest tile.
				if (moveCount >= moveTime)
				{
					x = (int)((x + tileSize / 2) / tileSize) * tileSize;
					y = (int)((y + tileSize / 2) / tileSize) * tileSize;
					moving = false;
				}
			}
			
			// if we are supposed to be turning, then turn.
			if (turning)
			{
				_theta += turnDir * turnSpeed;
				turnCount++;
				turnedLast = true;
				// if we are done turning, then stop turnig and snap to the nearest PI/2 radians.
				if (turnCount >= turnTime)
				{
					// the following line was intended to snap the angle to the nearest PI/2 radians, but it doesn't work,
					// and everything seems to work fine without it. but it might be useful later.
					//_theta = (int)((_theta + Math.PI / 4) / Math.PI / 2) * Math.PI / 2;
					turning = false;
				}
			}
		}
		
		public function move(xo:int, yo:int):void
		{
			moving = true;
			move_xo = xo;
			move_yo = yo;
			moveCount = 0;
			(FlxG.state as PlayState).updateDetected(); // added to reflect changes if a block is pushed into a vision area.
		}
				
		public function isMoving():Boolean
		{
			return moving;
		}
		
		protected function turn(td:int):void
		{
			// TODO: break up turn() between MovingSprite and PatrolBot
			// movingsprite handles direction, and patrolbot handles _theta
			
			// note: td should be -2, -1, 1, or 2.
			// (these stand for the number of 90degree rotations you make)
			
			// 1 - do the actual turning
			turning = true;
			turnDir = td;
			turnCount = 0;
			(FlxG.state as PlayState).updateDetected();
			
			// 2 - set the new direction
			var order:Array = [Dir.SOUTH, Dir.WEST, Dir.NORTH, Dir.EAST, Dir.SOUTH, Dir.WEST, Dir.NORTH, Dir.EAST];
			var index:int;
			if (direction == Dir.NORTH) index = 2;
			else if (direction == Dir.EAST) index = 3;
			else if (direction == Dir.SOUTH) index = 4;
			else if (direction == Dir.WEST) index = 5;
			direction = order[index + turnDir];
		}
	}

}