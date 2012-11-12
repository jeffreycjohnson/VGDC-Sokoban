package  
{
	import org.flixel.*;
	import flash.net.SharedObject;
	
	/**
	 * The class which contains the level select.
	 */
	public class LevelSelect extends FlxState
	{
		private var buttonArray:Array;
		private var chapterArray:Array;
		private var chapter:int = 0;
		
		public function LevelSelect()
		{
		}
		
		private function switchState():void
		{
			FlxG.switchState(new PlayState);
		}
		
		private function switchChapter():void
		{
			buttonArray[chapter].toggle();
			chapter = PlayState.startChapter;
			showButtons(chapter);
		}
		
		// Load the background and all the buttons
		override public function create():void
		{
			var i:int;
			var j:int;
			var x:int;
			var y:int;
			buttonArray = [];
			chapterArray = [];
			
			
			for (i = 0;  i < LevelStorage.chapterLengths.length; i++)
			{
				x = i * 64 + 120;
				y = 110;
				chapterArray[i] = new Button(x, y, i, 0, switchChapter, true);
				
				for (j = 0; j < 10 && j < LevelStorage.chapterLengths[i]; j++)
				{
					x = j % 5 * 64 + 50;
					y = (j - j % 5) / 5 * 48 + 180;
					buttonArray[i * 10 + j] = new Button(x, y, i, j, switchState);
				}
			}
			
			showButtons(0);
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
		
		private function showButtons(chapter:int):void
		{
			clear();
			add(new FlxSprite(0, 0, Assets.BG));
			add(new FlxText(160, 80, 100, "Chapter Select"));
			
			var x:int;
			var y:int;
			for (var i:int = 0;  i < LevelStorage.chapterLengths.length; i++)
			{
				add(chapterArray[i]);
				x = i * 64 + 132;
				y = 120;
				add(new FlxText(x, y, 10, i.toString()));
			}
			
			add(new FlxText(140, 160, 200, "Chapter " + chapter.toString() + ": " + LevelStorage.chapterNames[chapter]));
			
			for (var j:int = 0; j < 10 && buttonArray[chapter * 10 + j] != null && (chapter * 10 + j <= PlayState.maxLevel.data.value || Main.debug); j++)
			{
				add(buttonArray[chapter * 10 + j]);
				x = j % 5 * 64 + 62;
				y = (j - j % 5) / 5 * 48 + 190;
				add(new FlxText(x, y, 10, j.toString()));
			}
		}
	}

}