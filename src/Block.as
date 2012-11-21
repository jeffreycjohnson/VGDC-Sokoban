package  
{
	/**
	 * A block pushable by the player.
	 */
	import org.flixel.*;
	
	public class Block extends MovingSprite
	{
		private var startActive:Boolean;
		
		public function Block(x:int, y:int, active:Boolean) 
		{
			super(x, y);
			loadGraphic(Assets.BLOCK, true, false, 16, 16);
			createAnimations();
			startActive = active;
			if (startActive) play("active");
			else play ("inactive");
		}
		
		public function clone():Block
		{
			return new Block(x, y, startActive);
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