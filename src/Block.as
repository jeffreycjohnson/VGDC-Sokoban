package  
{
	
	
	import org.flixel.*;
	
	public class Block extends MovingSprite
	{
		
		public function Block(x:int, y:int) 
		{
			super(x, y);
			loadGraphic(Assets.BLOCK, false, true, 16, 16);
		}
		
		override public function update():void
		{
			super.update();
		}
	}

}