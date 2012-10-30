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
		
	}

}