package  
{
	import org.flixel.*;
	
	[SWF(width="640", height="480", backgroundColor="#000000")]
	
	public class Main extends FlxGame
	{
		public static const pixel:int = 2;
		public static const w:int = 640/pixel;
		public static const h:int = 480/pixel;
		
		public function Main()
		{
			super(w, h, PlayState, pixel, 60, 60);
			forceDebugger = true;
		}
	}

}