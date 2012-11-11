package  
{
	import org.flixel.*;
	
	[SWF(width="800", height="600", frameRate = "60", backgroundColor="#000000")]
	
	/**
	 * Entry point into the game.
	 */
	public class Main extends FlxGame
	{
		public static const PIXEL:int = 2;
		public static const WIDTH:int = 800/PIXEL;
		public static const HEIGHT:int = 600/PIXEL;
		
		public function Main()
		{
			super(WIDTH, HEIGHT, MainMenu, PIXEL, 60, 60, true);
			//super(50, 50, PlayState, 2, 60, 60, true);
			forceDebugger = true;
		}
	}

}