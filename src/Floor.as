package  
{
	import org.flixel.*;
	
	/**
	 * Sprite for the floor.
	 */
	public class Floor extends FlxSprite
	{
		
		public function Floor(x:int, y:int, type:String) 
		{
			super(x, y);
			loadGraphic(Assets.FLOOR, true, false, 16, 16);
			createAnimations();
			
			play(type);
		}
		
		public function createAnimations():void
		{
			addAnimation("normal", [0]);
			addAnimation("goal", [1]);
		}
	}

}