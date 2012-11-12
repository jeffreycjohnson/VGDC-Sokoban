package  
{
	import org.flixel.*;
	import flash.events.MouseEvent;
	
	/**
	 * A Button for the UI
	 */
	public class Button extends FlxSprite
	{
		private var chapter:int;
		private var level:int;
		private var onUp:Function;
		private var toggleable:Boolean;
		
		public function Button(x:int, y:int, _chapter:int=0, _level:int=0, OnClick:Function=null, toggle:Boolean = false) 
		{
			super(x, y);
			loadGraphic(Assets.BUTTON, true, false, 32, 32);
			createAnimations();
			chapter = _chapter;
			level = _level;
			onUp = OnClick;
			toggleable = toggle;
		}
		
		private function createAnimations():void
		{
			addAnimation("off", [0]);
			addAnimation("over", [1]);
			addAnimation("down", [2]);
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
						if(FlxG.mouse.justReleased())
						{
							PlayState.startLevel = level;
							PlayState.startChapter = chapter;
							onUp();
						}
						else if (FlxG.mouse.justPressed())
						{
							play("down");
						}
						else if (!FlxG.mouse.pressed())
						{
							play("over");
						}
					}
					else {
						if (!toggleable) play("off");
					}
				}
			}
		}
		
		public function toggle(state:Boolean = true):void
		{
			if (state) play("off");
			else play("on");
		}
	}
}