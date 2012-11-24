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
		
		public static var startChapter:int = 0;
		public static var startLevel:int = 0;
		private var chapterIndex:int; // range 0-9
		private var levelIndex:int; // range 0-9
		
		
		private var moveCount:int; // how many moves the player has done
		public static var maxLevel:SharedObject; // tracks th players progress
		public static var minMoves:SharedObject;
		
		private var goalNumber:int; // total number of goals
		private var goalCount:int  // goals achieved so far
		private var godMode:Boolean = false;
		
		private var locked:int = 0;
		private var defeatNext:Boolean = false;
		private var victory_marker:Boolean = false;
		private var portal:Teleporter;
		
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
		private var timeText:FlxText;
		private var godModeText:FlxText;
		
		// whether or not we should update detected at the end of the tick
		private var _updateDetectedNext:Boolean;
		public function set updateDetectedNext(b:Boolean):void { _updateDetectedNext = b; };
		
		
		// TODO: possibly add in parameters for which level to start on?
		public function PlayState()
		{
		}
		
		override public function create():void
		{
			portal = new Teleporter(0, 0);
			portal.alpha = 0;
			
			// create fade overlay object
			fadeOverlay = new FlxSprite(0, 0);
			fadeOverlay.makeGraphic(Main.WIDTH, Main.HEIGHT, 0xff000000);
			fadeOverlay.alpha = 0;
			add(fadeOverlay);
			
			// to start us off, let's load the start level.
			fadeOverlay.alpha = 1;
			switchLevel(startChapter, startLevel);
			(FlxG.state as PlayState).updateDetectedNext = true;
		}
		
		override public function update():void
		{
			
			// Fading between levels
			if (fading)
			{
				fadeOverlay.alpha += fadeRate;
				if (fadeRate < 0) portal.alpha -= fadeRate;
				if (fadeOverlay.alpha == 1)
				{
					fadeRate *= -1;
					loadLevel(chapterIndex, levelIndex);
					add(fadeOverlay);
				}
				else if (fadeOverlay.alpha == 0)
				{
					fading = false;
					fadeRate = 0;
				}
				return;
			}
			
			// Switching Levels
			if (FlxG.keys.justPressed("R"))
			{
				switchLevel(chapterIndex, levelIndex);
			}
			else if (FlxG.keys.justPressed("PAGEUP") && (Main.debug || chapterIndex * 10 + levelIndex > maxLevel.data.value))
			{
				// same chapter
				if (levelIndex < LevelStorage.chapterLengths[chapterIndex] - 1)
					switchLevel(chapterIndex, levelIndex + 1);
				// swtiching chapters
				else if (levelIndex == LevelStorage.chapterLengths[chapterIndex] - 1 && chapterIndex < LevelStorage.chapterLengths.length - 1)
					switchLevel(chapterIndex + 1, 0);
				
			}
			else if (FlxG.keys.justPressed("PAGEDOWN"))
			{
				// same chapter
				if (levelIndex > 0)
					switchLevel(chapterIndex, levelIndex - 1);
				// switching chapters
				else if (levelIndex == 0 && chapterIndex > 0)
					switchLevel(chapterIndex - 1, LevelStorage.chapterLengths[chapterIndex - 1] - 1);
			}
			else if (FlxG.keys.justPressed("ESCAPE")) FlxG.switchState(new MainMenu);
			
			// Locked state (don't do any game logic at all)
			if (locked)
			{
				locked--;
				portal.grow();
				// Show the end of level GUI
				if (victory_marker && !locked)
				{
					locked++;
					victory();
					super.update();
				}
				// we want to run a couple more update cycles so that the player finishes moving
				else if (victory_marker && locked > 65) true;
				
				// give them a moment to see their mistake then fade out
				else if (locked && locked < 60)
				{
					fadeOverlay.alpha += fadeRateConst / 4;
					return;
				}
				// restart level once we fade out
				else if (!locked && !victory_marker)
				{
					switchLevel(chapterIndex, levelIndex);
					return;
				}
				else return;
			}
			
			// calculate movement values
			
			var xo:int = 0; // x offset (1 or -1)
			var yo:int = 0; // y offset (1 or -1)
			
			// Toggle GodMode
			if (FlxG.keys.justPressed("G"))
			{
				godMode = !godMode;
				updateGodModeText();
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
					
					moveCount++;
					updateMoveText();
					
					var b:Block = (Block)(entities[x_next2][y_next2]);
					// now we change the goal count if necessary
					if (floor[x_next][y_next] == 0 && floor[x_next2][y_next2] == 1)
					{
						goalCount++;
						updateBlockCounters();
						b.power(true);
					}
					else if (floor[x_next][y_next] == 1 && floor[x_next2][y_next2] == 0)
					{
						goalCount--;
						updateBlockCounters();
						b.power(false);
					}
				}
				// TODO: other cases (?)
			}
			
			
			// finally, update all objects we have added to our FlxState.
			super.update();
			
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
			
			// Make the portal and set it it fade out and load the end of level GUI
			if (victory_marker && ! locked)
			{
				locked = 100;
				portal.resetSize();
				portal.x = px * TILESIZE + XOFFSET - 16;
				portal.y = py * TILESIZE + YOFFSET - 16;
				portal.alpha = 1;
				add(portal);
			}
			
			
			// trace array (for debugging)
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
		
		private function switchLevel(chapter:int, level:int):void
		{
			fading = true;
			fadeRate = fadeRateConst;
			
			chapterIndex = chapter;
			levelIndex = level;
			
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
		
		private function loadLevel(chapter:int, index:int):void
		{
			// standard stuff.
			levelIndex = index;
			clear();
			level = [];
			floor = [];
			entities = [];
			detected = [];
			patrollers = new Vector.<PatrolBot>;
			goalNumber = goalCount = 0;
			moveCount = 0;
			locked = 0;
			victory_marker = false;
			var i:int = 0;
			var j:int = 0;
			
			var thisLevel:Level = LevelStorage.levels[chapter][index];
			px = thisLevel.playerX;
			py = thisLevel.playerY;
			goalCount += thisLevel.blocksActive;
			
			XOFFSET = (Main.WIDTH - TILESIZE * thisLevel.width) / 2;
			YOFFSET = ((Main.HEIGHT - TOOLBAR_HEIGHT) - TILESIZE * thisLevel.height) / 2;
			
			
			
			// add a repeating background object alligned with the level.
			
			var numTilesX:int = (int)(XOFFSET / TILESIZE);
			if (XOFFSET % TILESIZE != 0) numTilesX++;
			var numTilesY:int = (int)(YOFFSET / TILESIZE);
			if (YOFFSET % TILESIZE != 0 ) numTilesY++;
			var startX:int = XOFFSET - numTilesX * TILESIZE;
			var startY:int = YOFFSET - numTilesY * TILESIZE;
			add(new TiledBackground(startX, startY, numTilesX * 2 + thisLevel.width, numTilesY * 2 + thisLevel.height, TiledBackground.LEVEL_1));
								
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
						add( new Floor(xAbs, yAbs, "goal"));
						goalNumber++;
					}
					// empty-floor
					else add( new Floor(xAbs, yAbs, "normal"));
					
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
						var guy:EdgedMaterial = new EdgedMaterial(xAbs, yAbs, EdgedMaterial.WALL);
						guy.updateSprite(corners, i, j);
						add(guy);
					}
					else if (corners[i][j] == 6) {
						var girl:EdgedMaterial = new EdgedMaterial(xAbs, yAbs, EdgedMaterial.WINDOW);
						girl.updateSprite(corners, i, j);
						add(girl);					
					}
				}
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
				add(specificGuy);
				entities[x][y] = specificGuy;
			}
			
			
			// create player
			player = new Player(px * TILESIZE + XOFFSET, py * TILESIZE + YOFFSET);
			add(player);
			
			// cycle through detected here to add them on top of everything
			for (i = 0; i < level.length; i++) {
				for (j = 0; j < level[i].length; j++) {
					detected[i][j] = new Detected(i * TILESIZE + XOFFSET, j * TILESIZE + YOFFSET);
					add(detected[i][j]);
				}
			}
			
			// update Detecteds for the first time
			updateDetected();
			
			
			// create various GUI-entities
			loadGUI(thisLevel);
		}
		
		// called at the end of loadLevel
		private function loadGUI(thisLevel:Level):void
		{
			const SECTION1_WIDTH:int = 200;
			const HEIGHT1:int = Main.HEIGHT - 46;
			const HEIGHT2:int = Main.HEIGHT - 26;
			const color:uint = 0xffffffff;
			
			add(new TiledBackground(0, Main.HEIGHT - TOOLBAR_HEIGHT, Main.WIDTH / TILESIZE, TOOLBAR_HEIGHT / TILESIZE, TiledBackground.MENU_1));
			add(new TiledBackground(-8, Main.HEIGHT - TOOLBAR_HEIGHT - 8, Main.WIDTH / TILESIZE + 1, 1, TiledBackground.BORDER_1));
			
			moveText = new FlxText(Main.WIDTH - 135, HEIGHT1, 135, "");
			updateMoveText();
			moveText.setFormat("PIXEL", 16, color, "left");
			add(moveText);
			
			timeText = new FlxText(Main.WIDTH - 135, HEIGHT2, 135, "");
			timeText.setFormat("PIXEL", 16, color, "left");
			updateTimeText();
			add(timeText);
			
			var levelNumberText:FlxText = new FlxText(50, HEIGHT1, 600, (chapterIndex + 1) + "-" + (levelIndex + 1));
			levelNumberText.setFormat("PIXEL", 16, color, "left");
			add(levelNumberText);
			
			var levelNameText:FlxText = new FlxText(5, HEIGHT2, 300, thisLevel.name.toUpperCase());
			levelNameText.setFormat("PIXEL", 16, color, "left");
			add(levelNameText);
			
			const startX:int = 170;
			const startY:int = Main.HEIGHT - 40;
			const cols:int = 3;
			blockCounters = [];
			for (var i:int = 0; i < goalNumber; i++)
			{
				var x:int = startX + (i % cols) * 24;
				var y:int = startY + (int)(i / cols) * 24;
				blockCounters[i] = new BlockCounter(x, y);
				add( (BlockCounter)(blockCounters[i]));
			}
			updateBlockCounters();
			
			/*
			godModeText = new FlxText(5, 50, 100, "");
			updateGodModeText();
			add(godModeText);
			
			
			
			add(new FlxText(5, 20, 150, "Name: " + thisLevel.name));
			add(new FlxText(130, 5, 200, "Sokoban Game v0.2\nArrow keys = move\nR = restart\nPgDn/Up = switch levels"));
			add(new FlxText(5, 35, 250, thisLevel.levelInfo));
			*/
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
					var lineAngle:Number = 0.15; // radians between lines
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
							if (gridX == px && gridY == py && det.alive && !godMode && !player.isMoving()) defeatNext = true;
						}
					}
				}
			}
		}
		
		private function defeat():void
		{
			locked = 90;
			add(new FlxText(182, 100, 150, "Detected!"));
		}
		
		private function victory():void
		{
			// Update the minimum number of moves
			minMoves = SharedObject.getLocal((chapterIndex * 10 + levelIndex).toString());
			if (minMoves.data.value == null || minMoves.data.value > moveCount)
			{
				minMoves.data.value = moveCount;
				minMoves.flush();
			}
			minMoves.close();
			
			clear();
			add(fadeOverlay);
			add(new FlxText(160, 50, 100, "Level Completed"));
			add(buttonRestart = new Button(40, 100, 0, 0, restart, .75, 1));
			add(buttonMenu = new Button(140, 100, 0, 0, toMenu, .75, 1));
			add(buttonNext = new Button(240, 100, 0, 0, nextLevel, .75, 1));
			add(toMenuText = new FlxText(85, 105, 100, "Restart"));
			add(toMenuText = new FlxText(175, 105, 100, "Main Menu"));
			add(nextLevelText = new FlxText(275, 105, 100, "Next Level"));
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
		
		private function updateTimeText():void
		{
			// TODO: this.
			timeText.text = "asdf";
		}
		
		private function updateBlockCounters():void
		{
			for (var i:int = 0; i < blockCounters.length; i++)
			{
				if (i < goalCount) (BlockCounter)(blockCounters[i]).changeAnimation(true);
				else (BlockCounter)(blockCounters[i]).changeAnimation(false);
			}
			if (goalCount == goalNumber) victory_marker = true;
		}
		
		private function updateGodModeText():void
		{
			//if (godMode) godModeText.text = "Godmode: ON";
			//else godModeText.text = "Godmode: OFF";
		}
		
		private function toMenu():void
		{
			FlxG.switchState(new MainMenu);
		}
		
		private function nextLevel():void
		{
			// same chapter
			if (levelIndex < LevelStorage.chapterLengths[chapterIndex] - 1)
				switchLevel(chapterIndex, levelIndex + 1);
			// swtiching chapters
			else if (levelIndex == LevelStorage.chapterLengths[chapterIndex] - 1 && chapterIndex < LevelStorage.chapterLengths.length - 1)
				switchLevel(chapterIndex + 1, 0);
		}
		
		private function restart():void
		{
			switchLevel(levelIndex, chapterIndex);
		}
	}

}