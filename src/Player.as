package  
{
	import org.flixel.*;
	
	/**
	 * Player that the user controls.
	 */
	public class Player extends MovingSprite
	{
		private var movingLast:Boolean = false; // corresponds to the moving boolean. detects if we need to change idle to walking animation, or vice versa.
		private var direction:String;
		
		public function Player(x:int, y:int)
		{
			super(x, y);
			loadGraphic(Assets.PLAYER, true, false, 16, 16);
			
			createAnimations();
			play("idle_down");
			direction = Dir.SOUTH;
		}
		
		override public function update():void
		{
			super.update();
			
			// idle and walking animations
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
			
			// in the future, can put useful stuff here rather than in the main game loop
			// e.g. picking up keys
		}
		
		public function updateDirection(xo:int, yo:int):void 
		{
			super.move(0, 0);
			
			if (xo == 1) direction = Dir.EAST;
			else if (xo == -1) direction = Dir.WEST;
			else if (yo == 1) direction = Dir.SOUTH;
			else if (yo == -1) direction = Dir.NORTH;
		}
		
		private function createAnimations():void
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