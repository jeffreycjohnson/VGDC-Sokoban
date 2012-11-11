package  
{
	import org.flixel.*;
	
	/**
	 * large FlxSprite consisting of a repeating background. It fills up the screen-space outside of the level itself.
	 * I did it this way because adding a shitton of FlxSprites to the state makes it lag a lot.
	 */
	public class WindowBackground extends FlxSprite
	{
		private const TILESIZE:int = PlayState.TILESIZE;
		
		public function WindowBackground(x:int, y:int, numTilesX:int, numTilesY:int) 
		{
			super(x, y);
			makeGraphic(numTilesX * TILESIZE, numTilesY * TILESIZE, 0xFFFF0000);
			var template:FlxSprite = new WindowTile();
			for (var i:int = 0; i < numTilesX; i++) {
				for (var j:int = 0; j < numTilesY; j++) {
					stamp(template, i * TILESIZE, j * TILESIZE);
				}
			}
		}
		
	}

}