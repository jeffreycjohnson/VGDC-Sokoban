package  
{
	import org.flixel.*;
	
	/**
	 * Letter of the NABOKOS text on the title screen, that fades in and scales itself down.
	 */
	public class TitleLetter extends FlxSprite
	{
		
		private static const actionTime:Number = 30; // how many ticks it takes to fade and scale
		private static const fadeRate:Number = 1 / actionTime;
		private static const startScale:Number = 3;
		private static const endScale:Number = 2;
		private static const scaleRate:Number = (startScale-endScale) / actionTime;
		
		private var actionCount:int = 0;
		
		public function TitleLetter(x:int, y:int, graphic:Class) 
		{
			super(x, y);
			loadGraphic(graphic);
			scale.x = startScale;
			scale.y = startScale;
			alpha = 0;
		}
		
		override public function update():void
		{
			// translate by the offset caused by shrinking.
			// im not exactly sure why, but this code does not work inside the constructor.
			if (actionCount == 0)
			{
				x += (startScale - endScale) * width / 2;
				y += (startScale - endScale) * height / 2;
			}
			if (actionCount < actionTime)
			{
				scale.x -= scaleRate;
				scale.y -= scaleRate;
				alpha += fadeRate;
				actionCount++;
			}
			if (actionCount == actionTime)
			{
				FlxG.play(Assets.SOUND_TITLE);
				actionCount++;
			}
		}
		
	}

}