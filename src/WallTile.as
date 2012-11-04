package  
{
	import org.flixel.*;
	
	/**
	 * 16x16 repeating wall graphic. used in WallBackground.
	 */
	public class WallTile extends FlxSprite
	{
		
		public function WallTile() 
		{
			super();
			loadGraphic(Assets.WALLREPEAT, false, false, 16, 16);
		}
		
	}

}