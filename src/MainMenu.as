package  
{
	import org.flixel.*;
	import flash.system.System;
	
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

		override public function create():void
		{
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

		private function play():void
		{
			FlxG.switchState(new PlayState);
		}

		private function controlsHelp():void
		{
			FlxG.switchState(new PlayState);
		}

		private function levelsDisplay():void
		{
			FlxG.switchState(new PlayState);
		}

		private function credits():void
		{
			FlxG.switchState(new PlayState);
		}
	}

}