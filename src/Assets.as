package  
{
	import flash.utils.Dictionary;
	/**
	 * Stores all the art and music assets for public access.
	 */
	public class Assets 
	{
		// level layout
		[Embed(source = "../assets/tileset_storage.png")] public static var TILESET_STORAGE:Class;
		[Embed(source = "../assets/tileset_factory.png")] public static var TILESET_FACTORY:Class;
		[Embed(source = "../assets/tileset_office.png")] public static var TILESET_OFFICE:Class;
		[Embed(source = "../assets/window.png")] public static var WINDOW:Class;
		[Embed(source = "../assets/block.png")] public static var BLOCK:Class;
		[Embed(source = "../assets/extratiles_solid.png")] public static var EXTRA_SOLID:Class;
		[Embed(source = "../assets/extratiles_transparent.png")] public static var EXTRA_TRANSPARENT:Class;
		
		// moving level objects
		[Embed(source = "../assets/player.png")] public static var PLAYER:Class;
		[Embed(source = "../assets/patrolbot1.png")] public static var PATROLBOT1:Class;
		[Embed(source = "../assets/rotatingbot.png")] public static var ROTATINGBOT:Class;
		[Embed(source = "../assets/laser.png")] public static var LASER:Class;
		[Embed(source = "../assets/patrolhighlight.png")] public static var PATROL_HIGHLIGHT:Class;
		
		// technical
		[Embed(source = "../assets/button.png")] public static var BUTTON:Class;
		[Embed(source = "../assets/background.png")] public static var BG:Class;
		[Embed(source = "../assets/background2.png")] public static var BG2:Class;
		[Embed(source = "../assets/gratebg.png")] public static var GRATE_BG:Class;
		[Embed(source = "../assets/blockcounter.png")] public static var BLOCK_COUNTER:Class;
		[Embed(source = "../assets/border.png")] public static var BORDER:Class;
		[Embed(source = "../assets/portal2.png")] public static var TELEPORTER:Class;
		[Embed(source = "../assets/medal.png")] public static var MEDAL:Class;
		[Embed(source = "../assets/dialoguebox.png")] public static var DIALOGUE_BOX:Class;
		
		// title letters
		[Embed(source = "../assets/title/n.png")] public static var TITLE_N:Class;
		[Embed(source = "../assets/title/a.png")] public static var TITLE_A:Class;
		[Embed(source = "../assets/title/b.png")] public static var TITLE_B:Class;
		[Embed(source = "../assets/title/o.png")] public static var TITLE_O:Class;
		[Embed(source = "../assets/title/k.png")] public static var TITLE_K:Class;
		[Embed(source = "../assets/title/s.png")] public static var TITLE_S:Class;
		public static const TITLE_LETTERS:Array = [TITLE_N,TITLE_A,TITLE_B,TITLE_O,TITLE_K,TITLE_O,TITLE_S];
		
		// fonts
		[Embed(source = "../assets/FreePixel.ttf", fontFamily = "PIXEL", embedAsCFF = "false")] public static var FONT_VISITOR:String;
		
		// sounds
		[Embed(source = "../assets/sound/step.mp3")] public static var SOUND_STEP:Class;
		[Embed(source = "../assets/sound/step.mp3")] public static var SOUND_ROBOTSTEP:Class;
		[Embed(source = "../assets/sound/moveblock.mp3")] public static var SOUND_MOVEBLOCK:Class;
		[Embed(source = "../assets/sound/text.mp3")] public static var SOUND_TEXT:Class;
		[Embed(source = "../assets/sound/title.mp3")] public static var SOUND_TITLE:Class;
		[Embed(source = "../assets/sound/teleport.mp3")] public static var SOUND_TELEPORT:Class;
		[Embed(source = "../assets/sound/detected.mp3")] public static var SOUND_DETECTED:Class;
	}

}