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
			if (type == TiledBackground.TILESET_1)
			{
				loadGraphic(Assets.TILESET_STORAGE, false, false, 16, 16);
				addAnimation("default", [5]);
				play("default");
			}
			else if (type == TiledBackground.TILESET_2)
			{
				loadGraphic(Assets.TILESET_FACTORY, false, false, 16, 16);
				addAnimation("default", [5]);
				play("default");
			}
			else if (type == TiledBackground.TILESET_3)
			{
				loadGraphic(Assets.TILESET_OFFICE, false, false, 16, 16);
				addAnimation("default", [5]);
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