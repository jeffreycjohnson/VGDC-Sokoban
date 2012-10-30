package  
{
	/**
	 * Wall sprite (that doesn't move).
	 */
	import org.flixel.*;
	
	public class Wall extends FlxSprite
	{
		
		public function Wall(x:int, y:int) 
		{
			super(x, y);
			loadGraphic(Assets.WALL, false, true, 16, 16);
		}
		
	}

}