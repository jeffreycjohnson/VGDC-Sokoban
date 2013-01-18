package  
{
	
	import flash.net.SharedObject;
	import org.flixel.*;
	import mx.collections.ListCollectionView;
	import mx.utils.ObjectUtil;
	import flash.system.System;
	
	/**
	 * The class which contains the game loop and stores important data.
	 */
	public class PlayState extends FlxState
	{	
		
		
		/* Data structures */
		
		// holds the values of what kind of stuff we have at each grid space
		public var level:Array;
		/* 0 = empty
		 * 1 = wall
		 * 2 = block
		 * 4 = player
		 * 5 = patrolbot
		 * 6 = window
		 */
		
		// holds what type of floor there is at each grid space.
		private var floor:Array;
		/* 0 = plain floor
		 * 1 = goal
		 */
		
		// holds MovingSprites we need to access by their position in the array.
		private var entities:Array;
		
		// holds all entities with vision that affects which squares are "detected".
		private var patrollers:Vector.<PatrolBot>;
		
		// holds the highlightable squares that appear when something is detected by a patroller.
		private var detected:Array;
		
		// holds block symbols at bottom of toolbar
		private var blockCounters:Array;
		
		
		/* Single values */
		
		public static const TILESIZE:int = 16; // width of a tile in pixels
		public static const TOOLBAR_HEIGHT:int = 48;
		
		public static var XOFFSET:int;
		public static var YOFFSET:int;
		
		private var fading:Boolean = false;
		private const fadeRateConst:Number = 1 / 15; // 1 divided by how many ticks the fade is
		private var fadeRate:Number;
		private var fadeOverlay:FlxSprite;
		
		public static var startChapter:int;
		public static var startLevel:int;
		private var chapterIndex:int; // range 0-9
		private var levelIndex:int; // range 0-9
		
		private var moveCount:int; // how many moves the player has done
		public static var maxLevel:SharedObject; // tracks th players progress
		public static var minMoves:SharedObject;
		
		private var goalNumber:int; // total number of goals
		private var goalCount:int  // goals achieved so far
		private var godMode:Boolean = false;
		
		private var tileset:Class; // current tileset image
		
		private var buttonNext:Button;
		private var buttonMenu:Button;
		private var buttonRestart:Button;
		private var nextLevelText:FlxText;
		private var toMenuText:FlxText;
		private var restartText:FlxText;
		
		private var player:Player;
		private var px:int; // player x
		private var py:int; // player y
		
		private var moveText:FlxText;
		private var levelNumberText:FlxText;
		private var levelNameText:FlxText;
		//private var godModeText:FlxText;
		
		// whether or not we should update detected at the end of the tick
		private var _updateDetectedNext:Boolean;
		public function set updateDetectedNext(b:Boolean):void { _updateDetectedNext = b; };
		
		private var gameLocked:Boolean; // if true, then the player can't move and moving game stuff doesn't update.
		
		// defeating the player
		private var defeatNext:Boolean = false;
		private var defeated:Boolean;
		private var defeatCount:int;
		private const defeatTime:int = 60;
		
		// Level scrolling transition stuff
		private var curG:FlxGroup; // current group
		private var prevG:FlxGroup; // previous group
		private var guiG:FlxGroup; // gui elements
		private var scrolling:Boolean;
		private var scrollDir:int;
		private var scrollCount:int;
		private const scrollTime:int = 50;
		private const scrollSpeed:int = 8; // scrolltime * scrollSpeed MUST equal Main.WIDTH
		
		// teleporter
		private var portal:Teleporter;
		private var teleporting:Boolean;
		private var teleportCount:int;
		public static const teleportTime:int = 60;
		
		// victorying the player
		private var victoried:Boolean;
		
		// displaying text
		// much of this is done very sloppily and in a roundabout way, but it will probably not
		// need to be touched again significantly. If it does, I will do it.
		// the rest of the text code is probably not worth reading, seriously. It's bad.
		private var texting:Boolean;
		private var shouldText:Boolean;  // should text as soon as the level officially starts
		private var writingText:Boolean; // as opposed to finished writing text
		private var textCount:int;
		private var textSpeed:int = 3;
		private var dialogueString:String;
		private var dialogueStringArray:Array;
		private var dialogueText:FlxText;
		private var dialogueTextArray:Array;
		private var textG:FlxGroup;
		private var dialogueIndex:int;
		private var dialogueBox:FlxSprite;
		private var dialogueEnterText:FlxText;
		private const textPt:FlxPoint = new FlxPoint(17, 165);
		private var textFadeVelocity:Number;
		private const textFadeAccel:Number = -0.005;
		
		
		// TODO: possibly add in parameters for which level to start on?
		public function PlayState()
		{
			levelIndex = startLevel;
			chapterIndex = startChapter;
		}
		
		override public function create():void
		{
			portal = new Teleporter(0, 0);
			portal.alpha = 0;
			
			// create fade overlay object
			fadeOverlay = new FlxSprite(0, 0);
			fadeOverlay.makeGraphic(Main.WIDTH, Main.HEIGHT, 0xff000000);
			
			// to start us off, let's load the start level.
			fadeOverlay.alpha = 0;
			loadLevel(startChapter, startLevel);
			
			loadGUI(); // create the gui once and only once this PlayState
			updateLevelGUI();
			updateDetectedNext = true;
			add(curG);
			add(guiG);
		}
		
		override public function update():void
		{
			/* scrolling, teleporting, texting, fading, defeated */
			{
			
			// Scrolling between levels
			if (scrolling)
			{
				scrollCount++;
				NaboUtil.moveGroup(curG, scrollSpeed*scrollDir);
				NaboUtil.moveGroup(prevG, scrollSpeed * scrollDir);
				if (scrollCount == int(scrollTime / 2)) updateLevelGUI();
				if (scrollCount == scrollTime)
				{
					scrolling = false;
					remove(prevG);
				}
				return;
			}
			
			// Teleporter animation playing
			else if (teleporting)
			{
				teleportCount++;
				if (teleportCount == int(teleportTime / 2))
				{
					portal.startShrinking();
					player.kill();
				}
				if (teleportCount == teleportTime)
				{
					teleporting = false;
					remove(portal);
					victory();
				}
			}
			
			// Text being written, or waiting for player to press enter
			else if (texting)
			{
				
				// destroy the text and go to the game.
				if (FlxG.keys.justPressed("ENTER") && !writingText)
				{
					FlxG.play(Assets.SOUND_TEXT);
					texting = false;
					dialogueBox.kill();
					dialogueEnterText.kill();
					//for (var i:int = 0; i < dialogueTextArray.length; i++)
					//{
					//	(FlxBasic)(dialogueTextArray[i]).kill();
					//}
					textG.kill();
				}
				
				
				// write the current string, and switch to next or -press enter- if we need to.
				// also skip to -press enter- if Enter key is pressed.
				if (writingText)
				{
					textCount++;
					if (textCount % textSpeed == 0)
					{
						dialogueText.text = dialogueString.substr(0, textCount / textSpeed);
						if (dialogueText.text.charAt(dialogueText.text.length - 1) != " ") FlxG.play(Assets.SOUND_TEXT);
					}
					
					if (textCount/textSpeed >= dialogueString.length)
					{
						if (dialogueIndex < dialogueStringArray.length-1) addTextNext();
						else addTextEnter();
					}
					
					if (FlxG.keys.justPressed("ENTER"))
					{
						// write out the rest of the text
						dialogueText.text = dialogueString;
						dialogueIndex++;
						while (dialogueIndex < dialogueStringArray.length)
						{
							dialogueText = new FlxText(textPt.x, textPt.y + 15 * dialogueIndex, 1000, dialogueStringArray[dialogueIndex]);
							dialogueText.setFormat("PIXEL", 16, 0xffffffff, "left");
							curG.add(dialogueText);
							//dialogueTextArray.concat(dialogueText);
							textG.add(dialogueText);
							dialogueIndex++;
						}
						addTextEnter();
					}
				}
				// make the -press enter- text flash
				else
				{
					textFadeVelocity += textFadeAccel;
					dialogueEnterText.alpha += textFadeVelocity;
					if (dialogueEnterText.alpha == 0) textFadeVelocity *= -1;
				}
				return;
			}
			
			// Fading out and in
			else if (fading)
			{
				fadeOverlay.alpha += fadeRate;
				if (fadeOverlay.alpha == 1)
				{
					fadeRate *= -1;
					clear();
					loadLevel(chapterIndex, levelIndex);
					add(curG);
					add(fadeOverlay);
					add(guiG);
					updateLevelGUI();
				}
				else if (fadeOverlay.alpha == 0)
				{
					fading = false;
					fadeRate = 0;
					remove(fadeOverlay);
				}
				return;
			}
			
			// Victoried (intercept keyboard shortcut goodness
			else if (victoried) 
			{
				if (FlxG.keys.justReleased("LEFT")) {
					toMenu();
				}
				else if (FlxG.keys.justReleased("UP")) {
					restart();
				}
				else if (FlxG.keys.justReleased("RIGHT") && levelIndex < LevelStorage.chapterLengths[chapterIndex] - 1) {
					nextLevel();
				}
			}
			
			// Defeated (waiting)
			else if (defeated)
			{
				defeatCount++;
				if (defeatCount == defeatTime)
				{
					defeated = false;
					fadeLevel(chapterIndex, levelIndex);
				}
				return;
			}
			
			// Start texting now that the level is officially started for the first time
			if (shouldText)
			{
				shouldText = false;
				texting = true;
				writingText = true;
				dialogueIndex = 0;
				dialogueText = new FlxText(textPt.x, textPt.y, 1000, "");
				dialogueText.setFormat("PIXEL", 16, 0xffffffff, "left");
				dialogueBox = new FlxSprite(110, 187, Assets.DIALOGUE_BOX);
				dialogueBox.scale = new FlxPoint(2.1, 2.1);
				dialogueTextArray = [];
				textG = new FlxGroup();
				//dialogueTextArray.concat(dialogueText);
				textG.add(dialogueText);
				curG.add(dialogueBox);
				curG.add(dialogueText);
			}
			
			}
			
			/* R, PgUp, PgDn, Esc */
			if (!gameLocked) {
			if (FlxG.keys.justPressed("R"))
			{
				fadeLevel(chapterIndex, levelIndex);
			}
			else if (FlxG.keys.justPressed("PAGEUP") && (Main.debug || chapterIndex * 10 + levelIndex > maxLevel.data.value))
			{
				if (levelIndex < LevelStorage.chapterLengths[chapterIndex] - 1)
					nextLevel();//scrollLevel(1);//switchLevel(chapterIndex, levelIndex + 1);
				
			}
			else if (FlxG.keys.justPressed("PAGEDOWN"))
			{
				if (levelIndex > 0)
					prevLevel();//scrollLevel( -1);//switchLevel(chapterIndex, levelIndex - 1);
			}
			else if (FlxG.keys.justPressed("ESCAPE")) toMenu();
			
			}
			
			/* player movement */
			if (!gameLocked) {
			
			// calculate movement values
			var xo:int = 0; // x offset (1 or -1)
			var yo:int = 0; // y offset (1 or -1)
			
			// Toggle GodMode
			if (FlxG.keys.justPressed("G"))
			{
				//godMode = !godMode;
				//updateGodModeText();
			}
			
			if (FlxG.keys.justPressed("RIGHT")) xo = 1;
			else if (FlxG.keys.justPressed("LEFT")) xo = -1;
			else if (FlxG.keys.justPressed("DOWN")) yo = 1;
			else if (FlxG.keys.justPressed("UP")) yo = -1;
			
			var next:int = level[px + xo][py + yo]; // the tile right in front of player
			var next2:int = next != 1 ? level[px + 2 * xo][py + 2 * yo] : 0; // the tile 2 blocks in front of player
			
			var x_next:int = px + xo;
			var y_next:int = py + yo;
			var x_next2:int = px + 2 * xo;
			var y_next2:int = py + 2 * yo;			
			
			// consider moving the player if either xo or yo is nonzero, and the player isn't already moving, AND he's not in a detected square, just to be sure.
			if (xo != yo && !player.isMoving() && (!(Detected(detected[px][py]).alive) || godMode))
			{
				// always turn, even if can't walk! it looks better, think any top-down rpg
				player.updateDirection(xo, yo);					
				
				// case 1 - moving forward into empty space
				if (next == 0)
				{
					level[px][py] = 0;
					level[x_next][y_next] = 4;
					px += xo;
					py += yo;
					
					player.move(xo, yo);
					FlxG.play(Assets.SOUND_STEP);
					
					moveCount++;
					updateMoveText();
				}
				
				// case 2 - pushing block
				else if (next == 2 && next2 == 0)
				{
					
					level[px][py] = 0;
					level[x_next][y_next] = 4;
					level[x_next2][y_next2] = 2;
					entities[x_next2][y_next2] = entities[x_next][y_next];
					px += xo;
					py += yo;
					
					entities[x_next][y_next].move(xo, yo);
					player.move(xo, yo);
					FlxG.play(Assets.SOUND_MOVEBLOCK);
					
					moveCount++;
					updateMoveText();
					
					var b:Block = (Block)(entities[x_next2][y_next2]);
					// now we change the goal count if necessary
					if (b.isCharged() && floor[x_next][y_next] == 0 && floor[x_next2][y_next2] == 1)
					{
						goalCount++;
						updateBlockCounters();
						b.power(true);
					}
					else if (b.isCharged() && floor[x_next][y_next] == 1 && floor[x_next2][y_next2] == 0)
					{
						goalCount--;
						updateBlockCounters();
						b.power(false);
					}
				}
				// TODO: other cases (?)
			}
			
			}
			
			// if we should update the detecteds this tick, then do so.
			if (_updateDetectedNext) 
			{
				updateDetected();
				_updateDetectedNext = false;
			}
			
			// if we should defeat the player, do so now. (do this at the end of update to update everything else before we do this)
			if (defeatNext)
			{
				defeatNext = false;
				defeat();
			}
			
			// finally, update all objects we have added to our FlxState.
			super.update();
			
			
			// trace level array (for debugging)
			/*
			for (var y:int = 0; y < level[0].length; y++) {
				var s:String = "";
				for (var x:int = 0; x < level.length; x++) {
					s += level[x][y] + " ";
				}
				trace(s);
			}
			trace();
			*/
			
		}
		
		// fade to black, then fade in to the next level
		private function fadeLevel(chapter:int, level:int):void
		{
			fading = true;
			fadeRate = fadeRateConst;
			clear();
			add(curG);
			add(fadeOverlay);
			add(guiG);
			
			chapterIndex = chapter;
			levelIndex = level;
			
			
			// least moves (needed?)
			if (levelIndex < LevelStorage.chapterLengths[chapterIndex] - 1)
				minMoves = SharedObject.getLocal((chapterIndex * 10 + levelIndex +  1).toString());
			else if (levelIndex == LevelStorage.chapterLengths[chapterIndex] - 1 && chapterIndex < LevelStorage.chapterLengths.length - 1)
				minMoves = SharedObject.getLocal(((chapterIndex + 1) * 10).toString());
			
			// Make sure that no level that is unlocked is null so that the levelSelect does not lag
			if (minMoves.data.value == null)
			{
				minMoves.data.value = 0;
				minMoves.flush();
			}
			minMoves.close();
			
			if (maxLevel.data.value == null || levelIndex + chapterIndex * 10 > maxLevel.data.value)
			{
				maxLevel.data.value = levelIndex + chapterIndex * 10;
				maxLevel.flush();
			}
		}
		
		//scroll right (dir=1) or left (dir=-1) to the next level
		private function scrollLevel(dir:int):void
		{
			scrolling = true;
			scrollDir = -dir;
			scrollCount = 0;
			levelIndex += dir;
			
			// clear stage, and assign groups to correct stuff
			clear();
			prevG = curG;
			loadLevel(chapterIndex, levelIndex);
			
			// move current group by appropriate offset
			NaboUtil.moveGroup(curG, Main.WIDTH*-scrollDir);
			
			add(curG);
			add(prevG);
			add(guiG);
		}
		
		// load the level at the given index to curG.
		private function loadLevel(chapter:int, index:int):void
		{
			// reset internal (non-visible) data values
			levelIndex = index;
			level = [];
			floor = [];
			entities = [];
			detected = [];
			patrollers = new Vector.<PatrolBot>;
			goalNumber = goalCount = 0;
			moveCount = 0;
			gameLocked = false;
			var i:int = 0;
			var j:int = 0;
			
			// load level from file and set values from it.
			var thisLevel:Level = LevelStorage.levels[chapter][index];
			px = thisLevel.playerX;
			py = thisLevel.playerY;
			//tileset = thisLevel.tileset;
			if (chapterIndex == 0) tileset = Assets.TILESET_STORAGE;
			else if (chapterIndex == 1) tileset = Assets.TILESET_FACTORY;
			else if (chapterIndex == 2) tileset = Assets.TILESET_OFFICE;
			else if (chapterIndex == 3) tileset = Assets.TILESET_FACTORY;
			goalCount += thisLevel.blocksActive;
			if (thisLevel.levelInfo != "")
			{
				shouldText = true;
				textCount = 0;
				dialogueStringArray = thisLevel.levelInfo.split("|");
				for (i = 0; i < dialogueStringArray.length; i++)
				{
					dialogueStringArray[i] += "       ";
				}
				dialogueString = dialogueStringArray[0];
			}
			
			XOFFSET = (Main.WIDTH - TILESIZE * thisLevel.width) / 2;
			YOFFSET = ((Main.HEIGHT - TOOLBAR_HEIGHT) - TILESIZE * thisLevel.height) / 2;
			
			// clear our current group
			curG = new FlxGroup();
			
			// add a repeating background object alligned with the level.
			
			var numTilesX:int = (int)(XOFFSET / TILESIZE);
			if (XOFFSET % TILESIZE != 0) numTilesX++;
			var numTilesY:int = (int)(YOFFSET / TILESIZE);
			if (YOFFSET % TILESIZE != 0 ) numTilesY++;
			var startX:int = XOFFSET - numTilesX * TILESIZE;
			var startY:int = YOFFSET - numTilesY * TILESIZE;
			if (tileset == Assets.TILESET_STORAGE)
				curG.add(new TiledBackground(startX, startY, numTilesX * 2 + thisLevel.width, numTilesY * 2 + thisLevel.height, TiledBackground.TILESET_1));
			else if (tileset == Assets.TILESET_FACTORY)
				curG.add(new TiledBackground(startX, startY, numTilesX * 2 + thisLevel.width, numTilesY * 2 + thisLevel.height, TiledBackground.TILESET_2));
			else if (tileset == Assets.TILESET_OFFICE)
				curG.add(new TiledBackground(startX, startY, numTilesX * 2 + thisLevel.width, numTilesY * 2 + thisLevel.height, TiledBackground.TILESET_3));
			
			// cycle through the level data.
			
			var xAbs:int;
			var yAbs:int;
			for (i = 0; i < thisLevel.width; i++)
			{
				level[i] = [];
				floor[i] = [];
				entities[i] = [];
				detected[i] = [];
				
				for (j = 0; j < thisLevel.height; j++)
				{
					// 1 - load data from thislevel into our level and floor arrays
					
					level[i][j] = thisLevel.levelArray[i][j];
					floor[i][j] = thisLevel.floorArray[i][j];
					
					// 2 - add the necessary static graphics objects.
					
					xAbs = i * TILESIZE + XOFFSET;
					yAbs = j * TILESIZE + YOFFSET;
					
					// goal-floor
					if (floor[i][j] == 1) {
						curG.add( new Floor(xAbs, yAbs, "goal", tileset));
						goalNumber++;
					}
					// empty-floor
					else curG.add( new Floor(xAbs, yAbs, "normal", tileset));
					
				}
			}
			
			
			
			// cycle through the small 8x8 tile data.
			
			var corners:Array = [];
			var smallWidth:int = thisLevel.width * 2 + 2;
			var smallHeight:int = thisLevel.height * 2 + 2;
			for (i = 0; i < smallWidth; i++) {
				corners[i] = [];
				for (j = 0; j < smallHeight; j++) {
					
					var lx:int = (int)((i - 1) / 2);
					var ly:int = (int)((j - 1) / 2);
					if (i == 0 || i == smallWidth - 1 || j == 0 || j == smallHeight - 1 ) corners[i][j] = 1;
					else corners[i][j] = (level[lx][ly]);
				}
			}
			
			for (i = 1; i < smallWidth-1; i++) {
				for (j = 1; j < smallHeight - 1; j++) {
					xAbs = (i - 1)  * TILESIZE / 2 + XOFFSET;
					yAbs = (j - 1)  * TILESIZE / 2 + YOFFSET;
					if (corners[i][j] == 1)
					{
						var guy:EdgedMaterial = new EdgedMaterial(xAbs, yAbs, tileset);
						guy.updateSprite(corners, i, j);
						if (guy.needsBacking()) {
							var guy2:EdgedMaterial = new EdgedMaterial(xAbs, yAbs, tileset);
							guy2.updateSpriteSolid(i, j);
							curG.add(guy2);
						}
						curG.add(guy);
					}
					else if (corners[i][j] == 6) {
						var girl:EdgedMaterial = new EdgedMaterial(xAbs, yAbs, Assets.WINDOW);
						girl.updateSprite(corners, i, j);
						if (girl.needsBacking()) {
							var girl2:EdgedMaterial = new EdgedMaterial(xAbs, yAbs, Assets.WINDOW);
							girl2.updateSpriteSolid(i, j);
							curG.add(girl2);
						}
						curG.add(girl);
					}
				}
			}
			
			// Cycle through extra tiles
			for (i = 0; i < thisLevel.extraTiles.length; i++)
			{
				var gal:IdleGraphic = (IdleGraphic)(thisLevel.extraTiles[i]).clone();
				if (gal.isSolid()) level[gal.x / TILESIZE][gal.y / TILESIZE] = 1;
				gal.x += XOFFSET;
				gal.y += YOFFSET;
				curG.add(gal);
			}
			
						
			// cycle through the entity data.
			
			for (i = 0; i < thisLevel.entitiesArray.length; i++)
			{
				var newGuy:FlxSprite = (FlxSprite)(thisLevel.entitiesArray[i]);
				var x:int = newGuy.x / TILESIZE;
				var y:int = newGuy.y / TILESIZE;
				var specificGuy:FlxSprite;
				
				if (newGuy is Block)
				{
					specificGuy = (Block)(newGuy).clone();
				}
				else if (newGuy is PaceBot)
				{
					specificGuy = (PaceBot)(newGuy).clone();
					patrollers.push(specificGuy);
				}
				else if (newGuy is Laser)
				{
					specificGuy = (Laser)(newGuy).clone();
					patrollers.push(specificGuy);
				}
				else if (newGuy is RotatingBot)
				{
					specificGuy = (RotatingBot)(newGuy).clone();
					patrollers.push(specificGuy);
				}
				else if (newGuy is PatrolBot)
				{
					specificGuy = (PatrolBot)(newGuy).clonePatrolBot();
					patrollers.push(specificGuy);
				}
				
				specificGuy.x += XOFFSET;
				specificGuy.y += YOFFSET;
				((MovingSprite)(specificGuy)).updateGridValues();
				
				// add each entity to the FlxState, and also to it's place in the entitites array.
				curG.add(specificGuy);
				entities[x][y] = specificGuy;
			}
			
			
			// create player
			player = new Player(px * TILESIZE + XOFFSET, py * TILESIZE + YOFFSET);
			curG.add(player);
			
			// cycle through detected here to add them on top of everything
			for (i = 0; i < level.length; i++) {
				for (j = 0; j < level[i].length; j++) {
					detected[i][j] = new Detected(i * TILESIZE + XOFFSET, j * TILESIZE + YOFFSET);
					curG.add(detected[i][j]);
				}
			}
			
			// update Detecteds for the first time
			updateDetected();
			
		}
		
		// create all the gui objects and add them to guiG.
		private function loadGUI():void
		{
			const SECTION1_WIDTH:int = 200;
			const HEIGHT1:int = Main.HEIGHT - 46;
			const HEIGHT2:int = Main.HEIGHT - 26;
			const color:uint = 0xffffffff;
			guiG = new FlxGroup();
			
			guiG.add(new TiledBackground(0, Main.HEIGHT - TOOLBAR_HEIGHT, Main.WIDTH / TILESIZE, TOOLBAR_HEIGHT / TILESIZE, TiledBackground.MENU_1));
			guiG.add(new TiledBackground(-8, Main.HEIGHT - TOOLBAR_HEIGHT - 8, Main.WIDTH / TILESIZE + 1, 1, TiledBackground.BORDER_1));
			
			moveText = new FlxText(Main.WIDTH - 135, HEIGHT1, 135, "");
			updateMoveText();
			moveText.setFormat("PIXEL", 16, color, "left");
			guiG.add(moveText);
			
			levelNumberText = new FlxText(50, HEIGHT1, 600, (chapterIndex + 1) + "-" + (levelIndex + 1));
			levelNumberText.setFormat("PIXEL", 16, color, "left");
			guiG.add(levelNumberText);
			
			levelNameText = new FlxText(5, HEIGHT2, 300, "Placeholder");//thisLevel.name.toUpperCase());
			levelNameText.setFormat("PIXEL", 16, color, "left");
			guiG.add(levelNameText);
			
			/*
			godModeText = new FlxText(5, 50, 100, "");
			updateGodModeText();
			add(godModeText);
			
			add(new FlxText(5, 20, 150, "Name: " + thisLevel.name));
			add(new FlxText(130, 5, 200, "Sokoban Game v0.2\nArrow keys = move\nR = restart\nPgDn/Up = switch levels"));
			add(new FlxText(5, 35, 250, thisLevel.levelInfo));
			*/
		}
		
		private function updateLevelGUI():void
		{
			var thisLevel:Level = LevelStorage.levels[chapterIndex][levelIndex];
			
			levelNumberText.text = (chapterIndex + 1) + "-" + (levelIndex + 1);
			//levelNameText.text = thisLevel.name.toUpperCase();
			levelNameText.text = thisLevel.name;
			updateMoveText();
			levelNameText.x = 5;
			if (levelNameText.text.length < 15) levelNameText.x += (15 - levelNameText.text.length) * 3.7;
			
			const startX:int = 170;
			const startY:int = Main.HEIGHT - 42;
			const cols:int = 3;
			if (blockCounters != null) for (var n:int = 0; n < blockCounters.length; n++) guiG.remove(blockCounters[n]);
			blockCounters = [];
			for (var i:int = 0; i < goalNumber; i++)
			{
				var x:int = startX + (i % cols) * 24;
				var y:int = startY + (int)(i / cols) * 20;
				blockCounters[i] = new BlockCounter(x, y);
				guiG.add( (BlockCounter)(blockCounters[i]));
			}
			updateBlockCounters();
		}
		
		private function updateDetected():void
		{
			// TODO: reformat this method to make it more understandable / readable?
			
			var i:int = 0;
			var x:int = 0;
			var y:int = 0;
			
			// first, blank out our array of Detecteds.
			for (x = 0; x < detected.length; x++)
			{
				for (y = 0; y < detected[0].length; y++)
				{
					// decrement all tiles so that they dont become visible after multiple passes
					(Detected)(detected[x][y]).kill();
				}
			}
			
			// now cycle through our patrollers, reviving any Detecteds they see.
			for (i = 0; i < patrollers.length; i++)
			{
				var guy:PatrolBot = patrollers[i];
				var sourceX:int = guy.x + guy.width / 2;
				var sourceY:int = guy.y + guy.height / 2;
				var radius:Number = guy.visionRadius;
				
				var sparedX1:int = guy.getGridX;
				var sparedY1:int = guy.getGridY;
				var sparedX2:int = sparedX1 - guy.lastXo;
				var sparedY2:int = sparedY1 - guy.lastYo;
				
				var minTheta:Number = guy.theta - guy.visionAngle / 2;
				var maxTheta:Number = guy.theta + guy.visionAngle / 2;
				
				var det:Detected;
				var detX:int;
				var detY:int;
					
				var hyp:Number;
				var run:Number;
				var rise:Number;
				
				var absX:Number;
				var absY:Number;
				
				var gridX:int;
				var gridY:int;
				var oldGridX:int;
				var oldGridY:int;
				
				var pc:int;
				
				// cone vision (the basic type we should mostly use). Could reorganize this section later.
				if (guy.visionType == "cone")
				{
					var lineAngle:Number = 0.1; // radians between lines
					var pointDist:Number = 8; // distance between points
					var extraPoints:int = 12 / pointDist;
					
					var lineNum:int = (maxTheta - minTheta) / lineAngle; // number of lines to draw
					var pointNum:int = radius / pointDist; // number of points to test on each line
					
					// calculate initial offset and move by it.
					//sourceX += (TILESIZE) * (Math.sin(guy.theta));
					//sourceY += (TILESIZE) * (Math.cos(guy.theta));
					//trace(15 * (Math.sin(guy.theta)));
					
					var theta:Number = minTheta;
					var deltaTheta:Number = (maxTheta - minTheta) / lineNum;
					
					
					// cycle through all lines
					for (var lc:int = 0; lc <= lineNum; lc++)
					{
						if (lc > 0) theta += deltaTheta;
						
						// calculate slope
						run = pointDist * Math.cos(theta);
						rise = pointDist * Math.sin(theta);
						
						absX = sourceX;
						absY = sourceY;
						
						// cycle through all points
						for (pc = 0; pc < pointNum; pc++)
						{
							oldGridX = (int)((absX - XOFFSET) / TILESIZE);
							oldGridY = (int)((absY - YOFFSET) / TILESIZE);
							absX += rise;
							absY += run;
							gridX = (int)((absX - XOFFSET) / TILESIZE);
							gridY = (int)((absY - YOFFSET) / TILESIZE);
							
							// break the line if out of bounds, or if we're inside a non-transparent tile.
							if (gridX >= level.length || gridY >= level[0].length || gridX < 0 || gridY < 0) break;
							
							var spared:Boolean = (gridX == sparedX1 && gridY == sparedY1) || (gridX == sparedX2 && gridY == sparedY2);
							if ( !( level[gridX][gridY] == 0 || level[gridX][gridY] == 4 || level[gridX][gridY] == 6 ) && !spared ) break;
							
							// break if it tries to go between 2 diagonally placed blocks
							if ((level[oldGridX][gridY] != 0 && level[oldGridX][gridY] != 4 && level[oldGridX][gridY] != 6) && 
								(level[gridX][oldGridY] != 0 && level[gridX][oldGridY] != 4 && level[gridX][oldGridY] != 6) && !spared) break;
							
							// if the point is significantly contained and isn't overlapping a patrolbot,
							det = detected[gridX][gridY];
							
							// if the point is significantly contained, and either is spared or doesn't overlap a patrolbot, consider reviving it.
							if (det.significantlyContains(absX, absY) &&
							( /*spared || */(level[gridX][gridY] != 5 && level[gridX + guy.lastXo][gridY + guy.lastYo] != 5)) )
							{
								det.revive();
							}
							
							// kill the player if he is detected
							if (gridX == px && gridY == py && det.alive && !godMode && !player.isMoving() && !victoried && !fading && !scrolling && !teleporting) defeatNext = true;
						}
					}
				}
				else if (guy.visionType == "line")
				{
					var angle:Number = int((guy.theta + 0.1) / (Math.PI / 2));
					trace(angle);
					var xvel:int = 0;
					var yvel:int = 0;
					if (angle == 0 || angle == 4) yvel = 1;
					else if (angle == 1) xvel = 1;
					else if (angle == 2) yvel = -1;
					else if (angle == 3) xvel = -1;
					x = guy.getGridX;
					y = guy.getGridY;
					x + xvel;
					y += yvel;
					while (level[x][y] == 0 || level[x][y] == 6 || level[x][y] == 4)
					{
						Detected(detected[x][y]).revive();
						x += xvel;
						y += yvel;
						// kill the player if he is detected
							if (level[x][y] == 4 && !godMode && !player.isMoving() && !victoried && !fading && !scrolling && !teleporting) defeatNext = true;
					}
				}
			}
		}
		
		private function defeat():void
		{
			gameLocked = true;
			defeated = true;
			defeatCount = 0;
			var detBox:FlxSprite = new FlxSprite(168, 97, Assets.DETECTED_BOX);
			detBox.scale = new FlxPoint(1.6, 1.6);
			add(detBox);
			add(new FlxText(175, 100, 150, "Detected!"));
			FlxG.play(Assets.SOUND_DETECTED);
		}
		
		private function victory():void
		{
			// declare victory
			victoried = true;
			
			// Update the minimum number of moves
			minMoves = SharedObject.getLocal((chapterIndex * 10 + levelIndex).toString());
			if (minMoves.data.value == null || minMoves.data.value == 0 || minMoves.data.value > moveCount)
			{
				minMoves.data.value = moveCount;
				minMoves.flush();
			}
			minMoves.close();
			
			// add gui stuff
			var completeBox:FlxSprite = new FlxSprite(120, 65, Assets.COMPLETE_BOX);
			completeBox.scale = new FlxPoint(2.1, 2.1);
			add(completeBox);
			
			add(new FlxText(160, 50, 100, "Level Completed!"));
			if (levelIndex == LevelStorage.chapterLengths[chapterIndex]-1) add(new FlxText(160, 60, 100, "Chapter Completed!! :D"));
			
			add(buttonMenu = new Button(40, 100, 0, 0, toMenu, .75, 1));
			add(buttonRestart = new Button(140, 100, 0, 0, restart, .75, 1));
			if (levelIndex < LevelStorage.chapterLengths[chapterIndex]-1)
				add(buttonNext = new Button(240, 100, 0, 0, nextLevel, .75, 1));
						
			add(toMenuText = new FlxText(85, 105, 100, "Menu [<-]"));
			add(toMenuText = new FlxText(175, 105, 100, "Retry [^]"));
			if (levelIndex < LevelStorage.chapterLengths[chapterIndex]-1)
				add(nextLevelText = new FlxText(275, 105, 100, "Next [->]"));
		}
		
		private function updateMoveText():void
		{
			const pad:int = 4;
			moveText.text = "Moves: ";
			
			var x:int = 1;
			for (var i:int = 0; i < pad - 1; i++)
			{
				x *= 10;
				if (moveCount < x) moveText.text += "0";
			}
			moveText.text += moveCount;
		}
		
		private function updateBlockCounters():void
		{
			for (var i:int = 0; i < blockCounters.length; i++)
			{
				if (i < goalCount) (BlockCounter)(blockCounters[i]).changeAnimation(true);
				else (BlockCounter)(blockCounters[i]).changeAnimation(false);
			}
			if (goalCount == goalNumber)
			{
				FlxG.play(Assets.SOUND_TELEPORT);
				teleporting = true;
				gameLocked = true;
				teleportCount = 0;
				portal.startAnimation();
				portal.x = px * TILESIZE + XOFFSET - 16;
				portal.y = py * TILESIZE + YOFFSET - 16;
				add(portal);
			}
		}
		
		/*private function updateGodModeText():void
		{
			if (godMode) godModeText.text = "Godmode: ON";
			else godModeText.text = "Godmode: OFF";
		}*/
		
		private function toMenu():void
		{
			victoried = false;
			
			FlxG.fade(0x00000000, 0.25, function ():void 
			{
				FlxG.switchState(new MainMenu);
			});
		}
		
		private function nextLevel():void
		{
			victoried = false;
			scrollLevel(1);
		}
		
		private function prevLevel():void
		{
			victoried = false;
			scrollLevel(-1);
		}
		
		private function restart():void
		{
			victoried = false;
			fadeLevel(chapterIndex, levelIndex);
		}
		
		// these two are used in displayin the dialogue text
		private function addTextNext():void
		{
			dialogueIndex++;
			textCount = 0;
			dialogueText = new FlxText(textPt.x, textPt.y + 15 * dialogueIndex, 1000, "");
			dialogueText.setFormat("PIXEL", 16, 0xffffffff, "left");
			curG.add(dialogueText);
			//dialogueTextArray.concat(dialogueText);
			textG.add(dialogueText);
			dialogueString = dialogueStringArray[dialogueIndex];
		}
		
		private function addTextEnter():void
		{
			writingText = false;
			dialogueEnterText = new FlxText(260, 208, 1000, "- press enter -");
			dialogueEnterText.setFormat("PIXEL", 16, 0xffffffff, "left");
			//dialogueTextArray.concat(dialogueEnterText);
			textG.add(dialogueText);
			curG.add(dialogueEnterText);
			textFadeVelocity = 0.05;
		}
	}

}