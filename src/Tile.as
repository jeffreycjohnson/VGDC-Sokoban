package  
{
	import org.flixel.*;
	
	/**
	 * 16x16 repeating graphic. used in TiledBackground.
	 */
	public class Tile extends FlxSprite
	{
		
		public function Tile(type:String) 
		{
			super();
			if (type == TiledBackground.LEVEL_1)
			{
				loadGraphic(Assets.WALL, false, false, 16, 16);
				addAnimation("default", [7]);
				play("default");
			}
			else if (type == TiledBackground.MENU_1)
			{
				loadGraphic(Assets.GRATE_BG, false, false, 16, 16);
			}
			else if (type == TiledBackground.BORDER_1)
			{
				loadGraphic(Assets.BORDER, false, false, 16, 16);
			}
		}
		
	}

}