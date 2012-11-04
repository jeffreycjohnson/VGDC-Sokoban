package  
{
		
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
		 * 6 = laser
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
		private var previouslyDetected:Array;
		
		// TODO: refactor the name "detected" to something more intuitive?
		
		
		
		/* Single values */
		
		public static const TILESIZE:int = 16; // width of a tile in pixels
		public static var XOFFSET:int;
		public static var YOFFSET:int;
		
		private var locked:Boolean = false;
		private const fadeRateConst:Number = 1 / 20; // 1 divided by how many ticks the fade is
		private var fadeRate:Number;
		private var fadeOverlay:FlxSprite;
		
		private var levelIndex:int; // which level we're currently on
		private var moveCount:int; // how many moves the player has done
		
		private var goalNumber:int; // total number of goals
		private var goalCount:int  // goals achieved so far
		private var defeated:Boolean = false;
		private var godMode:Boolean = false;
		
		private var player:Player;
		private var px:int; // player x
		private var py:int; // player y
		
		private var goalText:FlxText;
		private var moveText:FlxText;
		
		// whether or not we should update detected at the end of the tick
		private var _updateDetectedNext:Boolean;
		public function set updateDetectedNext(b:Boolean):void { _updateDetectedNext = b; };
		
		
		
		override public function create():void
		{
			// push all things we "Embed"-ed in LevelStorage to an array levels[].
			var i:int = 0;
			while (LevelStorage[getLevelString(i)] != null)
			{
				LevelStorage.levels[i] = new Level(LevelStorage[getLevelString(i)]);
				i++;
			}
			
			// create fade overlay object
			fadeOverlay = new FlxSprite(0, 0);
			fadeOverlay.makeGraphic(Main.WIDTH, Main.HEIGHT, 0xff000000);
			fadeOverlay.alpha = 0;
			add(fadeOverlay);
			
			// to start us off, let's load level 0.
			fadeOverlay.alpha = 1;
			switchLevel(0);
		}
		
		override public function update():void
		{
			
			// if we're fading in or out between levels
			if (locked)
			{
				fadeOverlay.alpha += fadeRate;
				if (fadeOverlay.alpha == 1)
				{
					fadeRate *= -1;
					loadLevel(levelIndex);
					add(fadeOverlay);
				}
				else if (fadeOverlay.alpha == 0)
				{
					locked = false;
					fadeRate = 0;
				}
				return;
			}
			
			
			
			// calculate movement values
			
			var xo:int = 0; // x offset (1 or -1)
			var yo:int = 0; // y offset (1 or -1)
			
			//Toggle GodMode
			if (FlxG.keys.justPressed("G"))
			{
				if (godMode) godMode = false;
				else godMode = true;
			}
			
			// dont let the player keep moving if he loses
			if (!defeated)
			{
				if (FlxG.keys.justPressed("RIGHT")) xo = 1;
				if (FlxG.keys.justPressed("LEFT")) xo = -1;
				if (FlxG.keys.justPressed("DOWN")) yo = 1;
				if (FlxG.keys.justPressed("UP")) yo = -1;
				
				var next:int = level[px + xo][py + yo]; // the tile right in front of player
				var next2:int = next != 1 ? level[px + 2 * xo][py + 2 * yo] : 0; // the tile 2 blocks in front of player
				
				var x_next:int = px + xo;
				var y_next:int = py + yo;
				var x_next2:int = px + 2 * xo;
				var y_next2:int = py + 2 * yo;			
				
				// consider moving the player if either xo or yo is nonzero, and the player isn't already moving.
				if (xo != yo && !player.isMoving())
				{
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
						
						// now we change the goal count if necessary
						if (floor[x_next][y_next] == 0 && floor[x_next2][y_next2] == 1)
						{
							goalCount++;
							updateGoalText();
						}
						else if (floor[x_next][y_next] == 1 && floor[x_next2][y_next2] == 0)
						{
							goalCount--;
							updateGoalText();
						}
					}
					// TODO: other cases (?)
				}
			}
			
			// if R key is pressed, reset
			if (FlxG.keys.justPressed("R"))
			{
				switchLevel(levelIndex);
			}
			
			// if PgDown or PgUp is pressed, switch levels
			if (FlxG.keys.justPressed("PAGEUP"))
			{
				if (levelIndex < LevelStorage.levels.length - 1) switchLevel(levelIndex + 1);
			}
			else if (FlxG.keys.justPressed("PAGEDOWN"))
			{
				if (levelIndex > 0) switchLevel(levelIndex - 1);
			}
			
			// pause when the player loses
			if (!defeated)
			{
				// finally, update all objects we have added to our FlxState.
				super.update();
				
				// if we should update the detecteds this tick, then do so.
				if (_updateDetectedNext) 
				{
					updateDetected();
					_updateDetectedNext = false;
				}
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
		
		private function switchLevel(index:int):void
		{
			locked = true;
			fadeRate = fadeRateConst;
			levelIndex = index;
			defeated = false;
		}
		
		private function loadLevel(index:int):void
		{
			// standard stuff.
			levelIndex = index;
			clear();
			level = [];
			floor = [];
			entities = [];
			detected = [];
			previouslyDetected = [];
			patrollers = new Vector.<PatrolBot>;
			goalNumber = goalCount = 0;
			moveCount = 0;
			var i:int = 0;
			var j:int = 0;
			
			var thisLevel:Level = LevelStorage.levels[levelIndex];
			px = thisLevel.playerX;
			py = thisLevel.playerY;
			
			XOFFSET = (Main.WIDTH - TILESIZE * thisLevel.width) / 2;
			YOFFSET = (Main.HEIGHT - TILESIZE * thisLevel.height) / 2;
			
			var xAbs:int;
			var yAbs:int;
			// cycle through the level data.
			for (i = 0; i < thisLevel.width; i++)
			{
				level[i] = [];
				floor[i] = [];
				entities[i] = [];
				detected[i] = [];
				previouslyDetected[i] = [];
				
				for (j = 0; j < thisLevel.height; j++)
				{
					// 1 - load data from thislevel into our level and floor arrays
					
					level[i][j] = thisLevel.levelArray[i][j];
					floor[i][j] = thisLevel.floorArray[i][j];
					
					// 2 - add the necessary static graphics objects.
					// TODO: in the future when we have graphics for the edges, corners, etc, add them here. I've done this before, it's not too complex.
					
					xAbs = i * TILESIZE + XOFFSET;
					yAbs = j * TILESIZE + YOFFSET;
					
					// goal-floor
					if (floor[i][j] == 1) {
						add( new Goal(xAbs, yAbs));
						goalNumber++;
					}
					// empty-floor
					else add( new Floor(xAbs, yAbs));
					
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
					if (i == 0 || i == smallWidth - 1 || j == 0 || j == smallHeight - 1 ) corners[i][j] = true;
					else corners[i][j] = (level[lx][ly] == 1);
				}
			}
			for (j = 0; j < smallHeight; j++) {
				var s:String = "";
				for (i = 0; i < smallWidth; i++) {
					if (corners[i][j]) s += "1 ";
					else s += "0 ";
				}
				//trace(s);
			}
			for (i = 1; i < smallWidth-1; i++) {
				for (j = 1; j < smallHeight - 1; j++) {
					xAbs = (i - 1)  * TILESIZE / 2 + XOFFSET;
					yAbs = (j - 1)  * TILESIZE / 2 + YOFFSET;
					if (corners[i][j])
					{
						var guy:Wall = new Wall(xAbs, yAbs);
						guy.updateSprite(corners, i, j);
						add(guy);
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
				for (j = 0; j < level.length; j++) {
					previouslyDetected[i][j] = 0;
					detected[i][j] = new Detected(i * TILESIZE + XOFFSET, j * TILESIZE + YOFFSET);
					add(detected[i][j]);
				}
			}
			
			// update Detecteds for the first time
			updateDetected();
			
			
			// create various GUI-entities
			loadGUI(thisLevel);
			defeated = false;
		}
		
		private function loadGUI(thisLevel:Level):void
		{
			goalText = new FlxText(5, 5, 150, "");
			add(goalText);
			updateGoalText();
			
			moveText = new FlxText(5, Main.HEIGHT-15, 100, "");
			add(moveText);
			updateMoveText();
			
			add(new FlxText(5, 25, 150, "Level " + levelIndex));
			add(new FlxText(5, 45, 150, "Name: " + thisLevel.name));
			add(new FlxText(5, 65, 200, "Sokoban Game v0.2\nArrow keys = move\nR = restart\nPgDn/Up = switch levels"));
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
					previouslyDetected[x][y] --;
					if (previouslyDetected[x][y] < 0) previouslyDetected[x][y] = 0;
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
				
				var pc:int;
				
				// cone vision (the basic type we should mostly use). Could reorganize this section later.
				if (guy.visionType == "cone")
				{
					var lineAngle:Number = 0.15; // radians between lines
					var pointDist:Number = 0.5; // distance between points
					
					var lineNum:int = (maxTheta - minTheta) / lineAngle; // number of lines to draw
					var pointNum:int = radius / pointDist; // number of points to test on each line
					
					var theta:Number = minTheta;
					var deltaTheta:Number = (maxTheta - minTheta) / lineNum;
					
					// cycle through all lines
					for (var lc:int = 0; lc <= lineNum; lc++)
					{
						if (lc > 0) theta += deltaTheta;
						
						// calculate slope
						hyp = radius / pointNum;
						run = hyp * Math.cos(theta);
						rise = hyp * Math.sin(theta);
						
						absX = sourceX;
						absY = sourceY;
						// TODO: start a few points ahead, outside of the starting square?
						
						// cycle through all points
						for (pc = 0; pc < pointNum; pc++)
						{
							absX += rise;
							absY += run;
							gridX = (int)((absX - XOFFSET) / TILESIZE);
							gridY = (int)((absY - YOFFSET) / TILESIZE);
							
							// since all tiles are decrements, increments ones in the path twice
							previouslyDetected[gridX][gridY] += 2;
							
							// break if out of bounds
							if (gridX >= level.length || gridY >= level[0].length || gridX < 0 || gridY < 0)
							{
								break;					
							}
							
							// break if tile is solid
							if (level[gridX][gridY] != 0 && level[gridX][gridY] != 4 && level[gridX][gridY] != 5 && level[gridX][gridY] != 6)
							{
								break;					
							}
							
							// only count tiles that are detected 3 times in a row as detected to prevent seeing though corners
							if (previouslyDetected[gridX][gridY] < 3)
							{
								break;
							}
							
							// else, revive the tile.
							det = detected[gridX][gridY];
							if (det.significantlyContains(absX, absY) && !(level[gridX][gridY] == 5 && !guy.isMoving())) det.revive();
							
							// kill the player if he is detected
							if (gridX == px && gridY == py && !godMode) defeat();
						}
					}
				}
				else if (guy.visionType == "straight")
				{
					run = radius * Math.cos(guy.theta);
					rise = radius * Math.sin(guy.theta);
					
					absX = sourceX;
					absY = sourceY;
					
					// cycle through all points
					for (pc = 0; pc < pointNum; pc++)
					{
						// without the / 2 the points are too spread out for large radius
						absX += rise / 2;
						absY += run / 2;
						gridX = (int)((absX - XOFFSET) / TILESIZE);
						gridY = (int)((absY - YOFFSET) / TILESIZE);
						
						// since all tiles are decrements, increments ones in the path twice
						previouslyDetected[gridX][gridY] += 2;
						
						// break if out of bounds
						if (gridX >= level.length || gridY >= level[0].length || gridX < 0 || gridY < 0)
						{
							break;					
						}				
						
						// break if tile is solid
						if (level[gridX][gridY] != 0 && level[gridX][gridY] != 4 && level[gridX][gridY] != 5 && level[gridX][gridY] != 6)
						{
							break;					
						}
						
						// only count tiles that are detected 3 times in a row as detected to prevent seeing though corners
						if (previouslyDetected[gridX][gridY] < 3)
						{
							break;
						}
						
						// else, revive the tile.
						det = detected[gridX][gridY];
						if (det.significantlyContains(absX, absY) && !(level[gridX][gridY] == 5 && !guy.isMoving())) det.revive();
						
						// kill the player if he is detected
						if (gridX == px && gridY == py && !godMode) defeat();
					}
				}
			}
		}
		
		// sets the defeated flag which pauses the game
		private function defeat():void
		{
			defeated = true;
			add(new FlxText(150, 30, 150, "You Lose!"));
			add(new FlxText(150, 50, 150, "Press R to Try Again."));
		}
		
		private function updateGoalText():void
		{
			goalText.text = "Blocks: " + goalCount + " / " + goalNumber;
			if (goalCount == goalNumber) goalText.text = goalText.text + "\nCongrats!";
		}
		
		private function updateMoveText():void
		{
			moveText.text = "Moves: " + moveCount;
		}
		
		private function getLevelString(index:int):String
		{
			var s:String = "level_";
			if (index < 10) s += "0";
			s += index.toString();
			return s;
			
		}
		
	}

}