package  
{
	import org.flixel.*;
	
	/**
	 * A medal graphic that appears on the level select screen, showing if you have completed the least moves possible.
	 */
	public class MovesMedal extends FlxSprite
	{
		
		public function MovesMedal(x:int, y:int, active:Boolean) 
		{
			super(x, y);
			loadGraphic(Assets.MEDAL,false,false,24,24);
			addAnimation("inactive", [0]);
			addAnimation("active", [1]);
			if (active) play("active");
			else play("inactive");
		}
		
	}

}