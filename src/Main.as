package  
{
	import org.flixel.*;
	
	[SWF(width="640", height="480", backgroundColor="#000000")]
	
	/**
	 * Entry point into the game.
	 */
	public class Main extends FlxGame
	{
		public static const PIXEL:int = 2;
		public static const WIDTH:int = 700/PIXEL; // for some reason it doesn't go wider than a certain amt. between 320 and 350.
		public static const HEIGHT:int = 480/PIXEL;
		
		public function Main()
		{
			super(WIDTH, HEIGHT, PlayState, PIXEL, 60, 60);
			forceDebugger = true;
		}
	}

}