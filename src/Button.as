package  
{
	import org.flixel.*;
	import flash.events.MouseEvent;
	
	/**
	 * A Button for the UI
	 */
	public class Button extends FlxSprite
	{
		private var index:int;
		
		public function Button(x:int, y:int, num:int) 
		{
			super(x, y);
			trace(num);
			loadGraphic(Assets.BUTTON, false, false, 32, 32);
			index = num;
		}
		
		override public function update():void
		{
			//Figure out if the button is highlighted or pressed or what
			// (ignore checkbox behavior for now).
			if(FlxG.mouse.visible)
			{
				if(cameras == null)
					cameras = FlxG.cameras;
				var camera:FlxCamera;
				var i:uint = 0;
				var l:uint = cameras.length;
				var offAll:Boolean = true;
				while(i < l)
				{
					camera = cameras[i++] as FlxCamera;
					FlxG.mouse.getWorldPosition(camera,_point);
					if(overlapsPoint(_point,true,camera))
					{
						if(FlxG.mouse.justPressed())
						{
							trace(PlayState.startLevel = index);
							FlxG.switchState(new PlayState);
						}
					}
				}
			}
		}
	}

}