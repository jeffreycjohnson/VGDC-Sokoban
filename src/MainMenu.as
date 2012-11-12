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
		
		public function MainMenu()
		{
		}
		
		// Load the background and all the buttons
		override public function create():void
		{
			PlayState.maxLevel = SharedObject.getLocal("Level");
			if (PlayState.maxLevel.data.value == null)
			{
				PlayState.maxLevel.data.value = 0;
				PlayState.maxLevel.flush();
			}
			
			add(new FlxSprite(0, 0, Assets.BG));
			
			startButton = new FlxButton(Main.WIDTH / 2 - 40, Main.HEIGHT / 2 - 20, "Play", play);
			add(startButton);
			controlsButton = new FlxButton(Main.WIDTH / 2 - 40, Main.HEIGHT / 2 + 10, "Controls", controlsHelp);
			add(controlsButton);
			levelsButton = new FlxButton(Main.WIDTH / 2 - 40, Main.HEIGHT / 2 + 40, "Levels", levelsDisplay);
			add(levelsButton);
			creditsButton = new FlxButton(Main.WIDTH / 2 - 40, Main.HEIGHT / 2 + 70, "Credits", credits);
			add(creditsButton);
		}
		
		// Just recreate the main menu if they press escape
		override public function update():void
		{
			if (FlxG.keys.justPressed("ESCAPE"))
			{
				create();
			}
			super.update();
		}

		private function play():void
		{
			FlxG.switchState(new PlayState);
		}

		private function controlsHelp():void
		{
			//remove everything
			clear();
			
			// add background and text objects
			add(new FlxSprite(0, 0, Assets.BG));
			
			add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 - 50, 250, "Use the Arrow Keys to Move."));
			add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 - 30, 250, "Next Level: Page Up"));
			add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 - 10, 250, "Previous Level: Page Down"));
			add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 + 10, 250, "Reset Level: R"));
			add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 + 30, 250, "Press Escape to Return to the Main Menu."));
		}
		
		// TODO: switch to the levelsDisplay FlzState
		private function levelsDisplay():void
		{
			FlxG.switchState(new LevelSelect);
		}

		private function credits():void
		{
			//remove everything
			clear();
			
			// add background and text objects
			add(new FlxSprite(0, 0, Assets.BG));
			
			add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 - 50, 250, "Patrick Traynor"));
			add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 - 30, 250, "Jeffrey Johnson"));
			add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 - 10, 250, "Jason Lo"));
			add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 + 10, 250, "Patrick Shin"));
			add(new FlxText(Main.WIDTH / 2 - 100, Main.HEIGHT / 2 + 30, 250, "Press Escape to Return to the Main Menu."));
		}
	}

}