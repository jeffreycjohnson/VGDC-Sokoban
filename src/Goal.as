package  
{
	import org.flixel.*;
	
	/**
	 * Sprite for a block goal.
	 */
	public class Goal extends FlxSprite
	{
		
		public function Goal(x:int, y:int) 
		{
			super(x, y);
			loadGraphic(Assets.GOAL, false, true, 16, 16);
		}
		
	}

}