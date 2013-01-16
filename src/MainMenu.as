package  
{
	import org.flixel.*;
	import flash.system.System;
	import flash.net.SharedObject;
	
	/**
	 * The class which contains main menu.
	 */
	public class MainMenu extends FlxState
	{
		private var startButton:FlxButton;
		private var controlsButton:FlxButton;
		private var levelsButton:FlxButton;
		private var creditsButton:FlxButton;
		
		private var title:FlxGroup = new FlxGroup();
		private var controls:FlxGroup = new FlxGroup();
		private var credits:FlxGroup = new FlxGroup();
		
		private var letters:Array = [];
		private var letterCount:int = 0;
		private var letterIndex:int = 0;
		private const letterRate:int = 12;
		private const letterStart:FlxPoint = new FlxPoint(60, 40);
		private const letterWidth:int = 40;
		
		public function MainMenu()
		{
		}
		
		// Load the background and all the buttons
		override public function create():void
		{			
			init();
			FlxG.flash(0x00000000, 0.25);
		}
		
		override public function update():void
		{
			super.update();
			// Add the letters to the scene gradually one by one
			if (letterIndex < letters.length)
			{
				letterCount++;
				if (letterCount % letterRate == 0)
				{
					add(letters[letterIndex]);
					letterIndex++;
				}
			}
			
			// recreate the main menu if they press escape
			if (FlxG.keys.justPressed("ESCAPE"))
			{
				createTitle();
			}
		}
		
		private function init():void
		{
			// push all things we "Embed"-ed in LevelStorage to an array levels[].
			
			var x:int; // chapter
			var y:int; // level
			if (LevelStorage.levels.length == 0)
			for (x = 0; x < LevelStorage.chapterLengths.length; x++)
			{
				LevelStorage.levels[x] = [];
				for (y = 0; y < LevelStorage.chapterLengths[x]; y++)
				{
					LevelStorage.levels[x][y] = new Level(LevelStorage[LevelStorage.getLevelString(x,y)]);
				}
			}
			
			PlayState.maxLevel = SharedObject.getLocal("Level");
			if (PlayState.maxLevel.data.value == null)
			{
				PlayState.maxLevel.data.value = 0;
				PlayState.maxLevel.flush();
			}
			
			add(new FlxSprite(0, 0, Assets.BG));
			
			// add appropriate elements to each FlxGroup
			
			title.add(new Button(Main.WIDTH / 2 - 66, 100, 0, 0, play, .75, .75));
			title.add(new Button(Main.WIDTH / 2 - 66, 150, 0, 0, createControls, .75, .75));
			title.add(new Button(Main.WIDTH / 2 - 66, 200, 0, 0, levelsDisplay, .75, .75));
			title.add(new Button(Main.WIDTH / 2 - 66, 250, 0, 0, createCredits, .75, .75));
			title.add(new FlxText(Main.WIDTH / 2 - 16, 105, 100, "Play"));
			title.add(new FlxText(Main.WIDTH / 2 - 24, 155, 100, "Controls"));
			title.add(new FlxText(Main.WIDTH / 2 - 20, 205, 100, "Levels"));
			title.add(new FlxText(Main.WIDTH / 2 - 22, 255, 100, "Credits"));
			
			// controls
			controls.add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 - 50, 250, "Use the Arrow Keys to Move."));
			controls.add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 - 30, 250, "Next Level: Page Up"));
			controls.add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 - 10, 250, "Previous Level: Page Down"));
			controls.add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 + 10, 250, "Reset Level: R"));
			controls.add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 + 30, 250, "Press Escape to Return to the Main Menu."));
			
			// credits
			credits.add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 - 50, 250, "Patrick Traynor"));
			credits.add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 - 30, 250, "Jeffrey Johnson"));
			credits.add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 - 10, 250, "Jason Lo"));
			credits.add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 + 10, 250, "Patrick Shin"));
			credits.add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 + 30, 250, "Press Escape to Return to the Main Menu."));
			
			// add letters of NABOKOS to the array
			for (var i:int = 0; i < "NABOKOS".length; i++) {
				letters.push(new TitleLetter(letterStart.x + i * letterWidth, letterStart.y, Assets.TITLE_LETTERS[i]));
			}
			
			// to start us off, let's add title
			createTitle();
		}
		
		private function createTitle():void
		{
			remove(controls);
			remove(credits);
			remove(title);
			add(title);
			letterCount = 0;
			letterIndex = 0;
		}
		
		private function createControls():void
		{
			remove(title);
			remove(controls);
			remove(credits);
			add(controls);
		}
		
		private function createCredits():void
		{
			remove(title);
			remove(controls);
			remove(credits);
			add(credits);
		}
		
		private function levelsDisplay():void
		{
			FlxG.switchState(new LevelSelect);
		}
		
		private function play():void
		{
			FlxG.switchState(new PlayState);
		}
	}

}