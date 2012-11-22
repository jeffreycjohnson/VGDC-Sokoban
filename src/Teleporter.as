package {
	
	import org.flixel.*;
	
	public class Teleporter extends FlxSprite
	{
		
		private var size:Number;
		
		public function Teleporter(x:int, y:int)
		{
			super(x, y);
			loadGraphic(Assets.TELEPORTER, false, false, 48, 48);
			size = .1;
			grow();
		}
		
		override public function update():void {
			super.update();
			angle -= 10;
			while (angle >= 90) angle -= 90;
			while (angle < 0) angle += 90;
		}
		
		public function grow():void
		{
			scale = new FlxPoint(size, size);
			size *= 1.1;
		}
		
		public function resetSize():void
		{
			size = .1;
			grow();
		}
	}
}