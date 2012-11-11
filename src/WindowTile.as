package  
{
	import org.flixel.*;
	
	/**
	 * 16x16 repeating Window graphic. used in WindowBackground.
	 */
	public class WindowTile extends FlxSprite
	{
		
		public function WindowTile() 
		{
			super();
			loadGraphic(Assets.WINDOW, false, false, 16, 16);
			addAnimation("default", [7]);
			play("default");
		}
		
	}

}