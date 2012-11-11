package  
{
	import org.flixel.*;
	import flash.system.System;
	
	/**
	 * The class which contains the level select.
	 */
	public class LevelSelect extends FlxState
	{
		private var buttonArray:Array;
		
		public function LevelSelect()
		{
		}
		
		// Load the background and all the buttons
		override public function create():void
		{
			add(new FlxSprite(0, 0, Assets.BG));
			
			var i:int;
			var j:int;
			var x:int;
			var y:int;
			buttonArray = [];
			for (i = 0;  LevelStorage[LevelStorage.getLevelString(i * 10)] != null; i++ )
			{
				for (j = 0; j < 9 && LevelStorage[LevelStorage.getLevelString(i * 10 + j)] != null; j++)
				{
					x = j % 3 * 64 + 120;
					y = (j - j % 3) / 3 * 64 + 100;
					buttonArray[i * 10 + j] = new Button(x, y, i * 10 + j);
				}
			}
			for (j = 0; j < 9 && buttonArray[j] != null; j++)
			{
				add(buttonArray[j]);
				x = j % 3 * 64 + 132;
				y = (j - j % 3) / 3 * 64 + 110;
				add(new FlxText(x, y, 10, (j + 1).toString()));
			}
		}
		
		// Just recreate the main menu if they press escape
		override public function update():void
		{
			if (FlxG.keys.justPressed("ESCAPE"))
			{
				FlxG.switchState(new MainMenu);
			}
			super.update();
		}

		private function play(levelIndex:int):void
		{
			PlayState.startLevel = levelIndex;
			FlxG.switchState(new PlayState);
		}
	}

}