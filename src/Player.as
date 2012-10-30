package  
{
	import org.flixel.*;
	
	/**
	 * Player that the user controls.
	 */
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
			// in the future, can put useful stuff here rather than in the main game loop
			// e.g. picking up keys
		}
		
	}

}