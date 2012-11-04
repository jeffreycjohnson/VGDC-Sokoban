package  
{
	/**
	 * Wall sprite (that doesn't move).
	 */
	import org.flixel.*;
	
	public class Wall extends FlxSprite
	{
		private var xx:int;
		private var yy:int;
		
		public function Wall(x:int, y:int) 
		{
			super(x, y);
			loadGraphic(Assets.WALL, false, false, 8, 8);
			createAnimations();
			
			play("center1");
		}
		
		public function updateSprite(corners:Array, x:int, y:int):void
		{
			var xx:int = x;
			var yy:int = y;
			
			var ref:String;
			
			var top:Boolean = corners[xx][yy-1];
			var bottom:Boolean = corners[xx][yy+1];
			var left:Boolean = corners[xx-1][yy];
			var right:Boolean = corners[xx+1][yy];
			
			var topleft:Boolean = corners[xx-1][yy-1];
			var topright:Boolean = corners[xx+1][yy-1];
			var bottomleft:Boolean = corners[xx-1][yy+1];
			var bottomright:Boolean = corners[xx+1][yy+1];
			
			// outside corners
			if (!top && !left) ref = "topleft";
			else if (!top && !right) ref = "topright";
			else if (!bottom && !left) ref = "bottomleft";
			else if (!bottom && !right) ref = "bottomright";
			
			// edges
			else if (!top) {
				if (xx % 2 == 1) ref = "top1";
				else ref = "top2";
			}
			else if (!bottom) {
				if (xx % 2 == 1) ref = "bottom1";
				else ref = "bottom2";
			}
			else if (!right) {
				if (yy % 2 == 1) ref = "right1";
				else ref = "right2";
			}
			else if (!left) {
				if (yy % 2 == 1) ref = "left2";
				else ref = "left2";
			}
			
			// inside corners
			else if (!bottomright) ref = "insidecorner1";
			else if (!bottomleft) ref = "insidecorner2";
			else if (!topright) ref = "insidecorner3";
			else if (!topleft) ref = "insidecorner4";
			
			// center
			else if (top && bottom && left && right) {
				if (yy % 2 == 1) {
					if (xx % 2 == 1) ref = "center1";
					else ref = "center2";
				}
				else {
					if (xx % 2 == 1) ref = "center3";
					else ref = "center4";
				}
			}
			
			//trace(xx, yy, ref);
			play(ref);
		}
		
		private function createAnimations():void
		{
			addAnimation("topleft", [0]);
			addAnimation("top1", [1]);
			addAnimation("top2", [2]);
			addAnimation("topright", [3]);
			
			addAnimation("left1", [4]);
			addAnimation("center1", [5]);
			addAnimation("center2", [6]);
			addAnimation("right1", [7]);
			
			addAnimation("left2", [8]);
			addAnimation("center3", [9]);
			addAnimation("center4", [10]);
			addAnimation("right2", [11]);
			
			addAnimation("bottomleft", [12]);
			addAnimation("bottom1", [13]);
			addAnimation("bottom2", [14]);
			addAnimation("bottomright", [15]);
			
			addAnimation("insidecorner1", [16]);
			addAnimation("insidecorner2", [17]);
			addAnimation("insidecorner3", [20]);
			addAnimation("insidecorner4", [21]);
		}
		
	}

}