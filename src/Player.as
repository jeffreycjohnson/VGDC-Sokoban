package  
{
	import org.flixel.*;
	
	public class Player extends MovingSprite
	{
		
		public function Player(x:int, y:int)
		{
			super(x, y);
			loadGraphic(Assets.PLAYER_SPRITE, false, true, 16, 16);
		}
		
		override public function update():void
		{
			super.update();
		}
		
	}

}