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
		private var chapter:int = 0;
		private var chapterText:FlxText;
		private var buttonNext:Button;
		private var buttonPrev:Button;
		
		public function LevelSelect()
		{
		}
		
		private function play():void
		{
			FlxG.switchState(new PlayState);
		}
		
		private function switchChapter():void
		{
			clear();
			chapter = PlayState.startChapter;
			showButtons();
		}
		
		// Load the background and all the buttons
		override public function create():void
		{
			var i:int;
			var j:int;
			var x:int;
			var y:int;
			buttonArray = [];
			
			
			for (i = 0;  i < LevelStorage.chapterLengths.length; i++)
			{				
				for (j = 0; j < 10 && j < LevelStorage.chapterLengths[i]; j++)
				{
					x = (int)(j / 5) * 175 + 50;
					y = (j % 5) * 38 + 90;
					buttonArray[i * 10 + j] = new Button(x, y, i, j, play);
				}
			}
			
			showButtons();
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
		
		private function showButtons():void
		{
			add(new FlxSprite(0, 0, Assets.BG2));
			
			var x:int;
			var y:int;
			if (chapter > 0) {
				buttonPrev = new Button(5, 50, chapter - 1, 0, switchChapter);
				add(buttonPrev);
				add(new FlxText(47, 56, 100, "Previous"));
			}
			if (chapter < LevelStorage.chapterLengths.length - 1) {
				buttonNext = new Button(267, 50, chapter + 1, 0, switchChapter);
				add(buttonNext);
				add(new FlxText(318, 56, 100, "Next"));
			}
			
			add(new FlxText(130, 20, 200, "Chapter " + (chapter + 1).toString() + ": " + LevelStorage.chapterNames[chapter]));
			
			for (var j:int = 0; j < 10 && buttonArray[chapter * 10 + j] != null && (chapter * 10 + j <= PlayState.maxLevel.data.value || Main.debug); j++)
			{
				add(buttonArray[chapter * 10 + j]);
				x = (int)(j / 5) * 175 + 65;
				y = (j % 5) * 38 + 95;
				add(new FlxText(x, y, 100, (j + 1).toString() + ": " + LevelStorage.levels[chapter][j].name));
				var medal:Boolean = false;
				
				// Add the minimum number of moves
				PlayState.minMoves = SharedObject.getLocal((chapter * 10 + j).toString());
				if (PlayState.minMoves.data.value != null && PlayState.minMoves.data.value != 0)
				{
					add(new FlxText(x + 95, y, 50, PlayState.minMoves.data.value.toString()));
					if (PlayState.minMoves.data.value <= (Level(LevelStorage.levels[chapter][j])).minMoves) medal = true;
				}
				PlayState.minMoves.close();
				
				add(new MovesMedal(x + 113, y - 7, medal));
				var text:FlxText = new FlxText(x + 117, y - 4, 100, String(Level(LevelStorage.levels[chapter][j]).minMoves));
				text.color = 0xff202000;
				text.alpha = 0.7;
				if (!medal) add(text);
			}
		}
	}

}