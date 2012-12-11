package {
	
	import org.flixel.*;
	
	/**
	 * A Class to hold the portal graphic for changing levels
	 */
	public class Teleporter extends FlxSprite
	{
		
		private var size:Number;
		private var growing:Boolean;
		
		private const growSpeed:Number = 1.08;
		private const spinSpeed:Number = 10;
		private const fadeSpeed:Number = 2 / PlayState.teleportTime;
		
		public function Teleporter(x:int, y:int)
		{
			super(x, y);
			loadGraphic(Assets.TELEPORTER, false, false, 48, 48);
			size = .1;
			grow();
		}
		
		override public function update():void {
			super.update();
			
			angle -= spinSpeed;
			while (angle >= 90) angle -= 90;
			while (angle < 0) angle += 90;
			
			if (growing) grow();
			else shrink();
			
			if (growing) alpha += fadeSpeed;
			else alpha -= fadeSpeed;
		}
		
		private function grow():void
		{
			scale = new FlxPoint(size, size);
			size *= growSpeed;
		}
		
		private function shrink():void
		{
			scale = new FlxPoint(size, size);
			size *= (2-growSpeed)
		}
		
		public function startAnimation():void
		{
			size = .1;
			growing = true;
			alpha = 0;
		}
		
		public function startShrinking():void
		{
			growing = false;
		}
	}
}