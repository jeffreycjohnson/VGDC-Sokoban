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
		public static const WIDTH:int = 640/PIXEL;
		public static const HEIGHT:int = 480/PIXEL;
		
		public function Main()
		{
			super(WIDTH, HEIGHT, PlayState, PIXEL, 60, 60);
			forceDebugger = true;
		}
	}

}