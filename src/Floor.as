package  
{
	import org.flixel.*;
	
	public class Floor extends FlxSprite
	{
		
		public function Floor(x:int, y:int) 
		{
			super(x, y);
			loadGraphic(Assets.FLOOR, false, true, 16, 16);
		}
		
	}

}