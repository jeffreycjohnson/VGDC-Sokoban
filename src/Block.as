package  
{
	/**
	 * A block pushable by the player.
	 */
	import org.flixel.*;
	
	public class Block extends MovingSprite
	{
		
		public function Block(x:int, y:int) 
		{
			super(x, y);
			loadGraphic(Assets.BLOCK, true, false, 16, 16);
			createAnimations();
			play("inactive");
		}
		
		public function clone():Block
		{
			return new Block(x, y);
		}
		
		override public function update():void
		{
			super.update();
		}
		
		public function power(b:Boolean):void
		{
			if (b) play("active");
			else play("inactive");
		}
		
		private function createAnimations():void
		{
			addAnimation("inactive", [0]);
			addAnimation("active", [1]);
		}
	}

}