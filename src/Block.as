package  
{
	/**
	 * A block pushable by the player.
	 */
	import org.flixel.*;
	
	public class Block extends MovingSprite
	{
		private var startActive:Boolean;
		private var charged:Boolean; // whether or not this block activates goals.
		
		public function Block(x:int, y:int, charged:Boolean, active:Boolean) 
		{
			super(x, y);
			loadGraphic(Assets.BLOCK, true, false, 16, 16);
			createAnimations();
			this.charged = charged;
			startActive = active;
			if (charged)
			{
				if (startActive) play("active");
				else play ("inactive");
			}
			else play("uncharged");
		}
		
		public function clone():Block
		{
			return new Block(x, y, charged, startActive);
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
		
		public function isCharged():Boolean
		{
			return charged;
		}
		
		private function createAnimations():void
		{
			addAnimation("inactive", [0]);
			addAnimation("active", [1]);
			addAnimation("uncharged", [2]);
		}
	}

}