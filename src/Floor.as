package  
{
	import org.flixel.*;
	
	/**
	 * Sprite for the floor.
	 */
	public class Floor extends FlxSprite
	{
		
		public function Floor(x:int, y:int, type:String, source:Class) 
		{
			super(x, y);
			loadGraphic(source, true, false, 16, 16);
			createAnimations();
			
			play(type);
		}
		
		public function createAnimations():void
		{
			addAnimation("normal", [6]);
			addAnimation("goal", [7]);
		}
	}

}