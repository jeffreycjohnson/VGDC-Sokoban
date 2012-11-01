package  
{
	import org.flixel.*;
	
	/**
	 * A red-transparent tile which represents where a PatrolBot can see.
	 */
	public class Detected extends FlxSprite
	{
		
		public function Detected(x:int, y:int) 
		{
			super(x, y);
			loadGraphic(Assets.PATROL_HIGHLIGHT, false, true, 16, 16);
		}
		
		/* Returns true if the point is within a hitbox 90% of the size. */
		public function significantlyContains(pointX:Number, pointY:Number):Boolean
		{
			var size:Number = 0.9;
			var border:Number = width - width * size;
			return ( (pointX > x + border) && (pointY > y + border) && (pointX < x + width - border) && (pointY < y + width - border) );
		}
		
	}

}