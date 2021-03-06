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
		private var state:String;
		private var _x:int;
		private var _y:int;
		
		public function Button(x:int, y:int, _chapter:int=0, _level:int=0, OnClick:Function=null, scaleX:Number=1, scaleY:Number=1, toggle:Boolean = false) 
		{
			super(x, y);
			loadGraphic(Assets.BUTTON, true, false, 128, 24);
			createAnimations();
			chapter = _chapter;
			level = _level;
			onUp = OnClick;
			toggleable = toggle;
			state = "up";
			_x = x + width * (1 - scaleX) / 2;
			_y = y + height * (1 - scaleY) / 2;
			width *= scaleX;
			height *= scaleY;
			scale = new FlxPoint(scaleX, scaleY);
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
				while(i < l)
				{
					camera = cameras[i++] as FlxCamera;
					FlxG.mouse.getWorldPosition(camera,_point);
					if(_point.x >= _x && _point.y >= _y && _point.x < _x + width && _point.y < _y + height)//(overlapsPoint(_point,true,camera))
					{
						if(FlxG.mouse.justReleased() && state != "up")
						{
							PlayState.startLevel = level;
							PlayState.startChapter = chapter;
							state = "up";
							onUp();
						}
						else if (FlxG.mouse.justPressed())
						{
							state = "down";
						}
						else if (!FlxG.mouse.pressed())
						{
							state = "over";
						}
					}
					else {
						if (!toggleable || state == "over") state = "off";
					}
					if (state != "up") play(state);
				}
			}
		}
		
		public function toggle(value:Boolean = true):void
		{
			if (value) state = "off";
			else state = "on";
			play(state);
		}
	}
}