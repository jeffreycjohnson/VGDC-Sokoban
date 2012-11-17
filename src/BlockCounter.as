package  
{
	import org.flixel.*;
	
	/**
	 * Displays how many blocks have been moved into position.
	 */
	public class BlockCounter extends FlxSprite
	{
		
		public function BlockCounter(x:int, y:int) 
		{
			super(x, y);
			loadGraphic(Assets.BLOCK_COUNTER, false, false, 16, 16);
			createAnimations();
			play("false");
		}
		
		private function createAnimations():void
		{
			addAnimation("true", [0]);
			addAnimation("false", [1]);
		}
		
		public function changeAnimation(b:Boolean):void
		{
			if (b) play("true");
			else play("false");
		}
		
	}

}