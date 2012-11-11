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
			loadGraphic(Assets.WALL, false, false, 16, 16);
			addAnimation("default", [7]);
			play("default");
		}
		
	}

}