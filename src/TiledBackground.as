package  
{
	import org.flixel.*;
	
	/**
	 * large FlxSprite consisting of a repeating background. It fills up the screen-space outside of the level itself.
	 * I did it this way because adding a ton of FlxSprites to the state makes it lag a lot.
	 */
	public class TiledBackground extends FlxSprite
	{
		public static const TILESET_1:String = "a";
		public static const TILESET_2:String = "b";
		public static const TILESET_3:String = "c";
		public static const MENU_1:String = "d";
		public static const BORDER_1:String = "e";
		
		private const TILESIZE:int = PlayState.TILESIZE;
		
		public function TiledBackground(x:int, y:int, numTilesX:int, numTilesY:int, type:String) 
		{
			super(x, y);
			makeGraphic(numTilesX * TILESIZE, numTilesY * TILESIZE, 0x00ff0000);
			var template:FlxSprite = new Tile(type);
			for (var i:int = 0; i < numTilesX; i++) {
				for (var j:int = 0; j < numTilesY; j++) {
					stamp(template, i * TILESIZE, j * TILESIZE);
				}
			}
		}
		
	}

}