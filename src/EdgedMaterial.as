package  
{
	import org.flixel.*;
	
	/**
	 * Superclass for Wall and Window, which have edge / corner graphics.
	 */
	public class EdgedMaterial extends FlxSprite
	{
		private var source:Class;
		private var _needsBacking:Boolean;
		private var _canBeRemoved:Boolean;
		public static const WALL:int = 1;
		public static const WINDOW:int = 6;
		
		public function EdgedMaterial(x:int, y:int, source:Class) 
		{
			super(x, y);
			this.source = source;
			loadGraphic(source, false, false, 8, 8);
			createAnimations();
			play("center1");
		}
		
		public function updateSprite(corners:Array, xx:int, yy:int):void
		{
			var ref:String;
			var id:int;
			if (source == Assets.WINDOW) id = WINDOW;
			else id = WALL;
			
			var top:Boolean = corners[xx][yy-1] == id;
			var bottom:Boolean = corners[xx][yy+1] == id;
			var left:Boolean = corners[xx-1][yy] == id;
			var right:Boolean = corners[xx+1][yy] == id;
			
			var topleft:Boolean = corners[xx-1][yy-1] == id;
			var topright:Boolean = corners[xx+1][yy-1] == id;
			var bottomleft:Boolean = corners[xx-1][yy+1] == id;
			var bottomright:Boolean = corners[xx+1][yy+1] == id;
			
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
				if (yy % 2 == 1) ref = "left1";
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
			
			play(ref);
			
			_needsBacking = !(ref == "center1" || ref == "center2" || ref == "center3" || ref == "center4");
			_canBeRemoved = (ref == "center1" || ref == "center2" || ref == "center3" || ref == "center4");
		}
		
		public function updateSpriteSolid(xx:int, yy:int):void
		{
			var ref:String;
			
			if (yy % 2 == 1) {
				if (xx % 2 == 1) ref = "center1";
				else ref = "center2";
			}
			else {
				if (xx % 2 == 1) ref = "center3";
				else ref = "center4";
			}
			
			play(ref);
		}
		
		protected function createAnimations():void
		{
			addAnimation("topleft", [0]);
			addAnimation("top1", [1]);
			addAnimation("top2", [2]);
			addAnimation("topright", [3]);
			
			addAnimation("left1", [4]);
			//addAnimation("center1", [5]);
			//addAnimation("center2", [6]);
			addAnimation("right1", [7]);
			
			addAnimation("left2", [8]);
			//addAnimation("center3", [9]);
			//addAnimation("center4", [10]);
			addAnimation("right2", [11]);
			
			addAnimation("bottomleft", [12]);
			addAnimation("bottom1", [13]);
			addAnimation("bottom2", [14]);
			addAnimation("bottomright", [15]);
			
			addAnimation("insidecorner1", [16]);
			addAnimation("insidecorner2", [17]);
			addAnimation("insidecorner3", [20]);
			addAnimation("insidecorner4", [21]);
			
			addAnimation("center1", [18]);
			addAnimation("center2", [19]);
			addAnimation("center3", [22]);
			addAnimation("center4", [23]);
		}
		
		// whether or not we should draw a thing behind this one.
		public function needsBacking():Boolean
		{
			return _needsBacking;
		}
		
		// not used for now
		public function canBeRemoved():Boolean
		{
			return _canBeRemoved;
		}
		
	}

}