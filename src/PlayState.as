package  
{
	//The class which contains the game loop and major stuff.
		
	import org.flixel.*;
	import mx.collections.ListCollectionView;
	import mx.utils.ObjectUtil;
	
	public class PlayState extends FlxState
	{
		// width of a tile in pixels
		public static const TILESIZE:int = 16;
		
		/* GENERAL STUFF */
		
		// holds the values of what kind of stuff we have at each grid space
		/* 0 = empty
		 * 1 = wall
		 * 2 = block
		 * 4 = player
		 * 5 = patrolbot
		 */
		public static var level:Array = [];
		
		/* holds what type of floor there is at each grid space.
		 * 0 = plain floor
		 * 1 = goal
		 */
		private var floor:Array = []; //NOTE: Why can't this be combined with level array? Just make floors a penetratable block
		
		// holds MovingSprites we need to access by their position in the array.
		private var entities:Array = [];
		
		// store the player and his coordinates for ease of access.
		private var player:Player;

		/*
		NOTE: Better if player vars kept in Player class?
		*/

		private var px:int;
		private var py:int;
		
		/* COUNTS */
		
		// which level we're currently on
		private var levelIndex:int;
		
		// how many moves the player has done
		private var moveCount:int;
		
		// Counts of "goals": places where you have to try to move the blocks to
		private var goalNumber:int; // total number of goals
		private var goalCount:int  // goals achieved so far
		
		// texts that display information
		private var goalText:FlxText;
		private var moveText:FlxText;
		
		override public function create():void
		{
			// push all things we "Embed"-ed in LevelStorage to an array levels[].
			var i:int = 0;
			while (LevelStorage[getLevelString(i)] != null)
			{
				LevelStorage.levels[i] = new Level(LevelStorage[getLevelString(i)]);
				i++;
			}
			
			// to start us off, let's load level 0.
			loadLevel(0);
		}
		
		override public function update():void
		{
			// calculate movement values
			
			var xo:int = 0; // x offset (1 or -1)
			var yo:int = 0; // y offset (1 or -1)
			
			if (FlxG.keys.justPressed("RIGHT")) xo = 1;
			if (FlxG.keys.justPressed("LEFT")) xo = -1;
			if (FlxG.keys.justPressed("DOWN")) yo = 1;
			if (FlxG.keys.justPressed("UP")) yo = -1;
			
			var next:int = level[px + xo][py + yo]; // the tile right in front of player

			/*
			NOTE: could be simplified to next2:int = next != 1 ? level[px + 2 * xo][py + 2 * yo] : 0;
			Either way if next == 1, then next2 isn't explicitly initialized, which you should avoid happening
			*/			
			var next2:int;
			if (next != 1) next2 = level[px + 2 * xo][py + 2 * yo]; // the tile 2 blocks in front of player
			
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
					player.move(xo, yo);
					level[px][py] = 0;
					level[x_next][y_next] = 1;
					px += xo;
					py += yo;
					moveCount++;
					updateMoveText();
				}
				
				// case 2 - pushing block
				else if (next == 2 && next2 == 0)
				{
					entities[x_next][y_next].move(xo, yo);
					player.move(xo, yo);
					
					level[px][py] = 0;
					level[x_next][y_next] = 1;
					level[x_next2][y_next2] = 2;
					entities[x_next2][y_next2] = entities[x_next][y_next];
					px += xo;
					py += yo;
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
			
			// if R key is pressed, reset
			if (FlxG.keys.justPressed("R"))
			{
				loadLevel(levelIndex);
			}
			
			// if PgDown or PgUp is pressed, switch levels
			if (FlxG.keys.justPressed("PAGEUP"))
			{
				if (levelIndex < LevelStorage.levels.length - 1) loadLevel(levelIndex + 1);
			}
			else if (FlxG.keys.justPressed("PAGEDOWN"))
			{
				if (levelIndex > 0) loadLevel(levelIndex - 1);
			}
			
			// finally, update all objects we have added to our FlxState.
			super.update();
		}
		
		private function loadLevel(index:int):void
		{
			// standard stuff.
			levelIndex = index;
			clear();
			level = [];
			floor = [];
			entities = [];
			goalNumber = goalCount = 0;
			moveCount = 0;
			var i:int = 0;
			var j:int = 0;
			
			var thisLevel:Level = LevelStorage.levels[levelIndex];
			px = thisLevel.playerX;
			py = thisLevel.playerY;
			
			
			// cycle through the level data.
			for (i = 0; i < thisLevel.width; i++)
			{
				level[i] = [];
				floor[i] = [];
				entities[i] = [];
				for (j = 0; j < thisLevel.height; j++)
				{
					// 1 - load data from thislevel into our level, floor, and entity arrays.
					
					level[i][j] = thisLevel.levelArray[i][j];
					floor[i][j] = thisLevel.floorArray[i][j];
					
					// 2 - add the necessary static graphics objects.
					
					// wall
					if (level[i][j] == 1) add( new Wall(i * TILESIZE, j * TILESIZE));
					// goal-floor
					else if (floor[i][j] == 1) {
						add( new Goal(i * TILESIZE, j * TILESIZE));
						goalNumber++;
					}
					// empty-floor
					else add( new Floor(i * TILESIZE, j * TILESIZE));
					
					// 3 - add blocks ON TOP OF the graphics objects.
					if (level[i][j] == 2) {
						entities[i][j] = new Block(i * TILESIZE, j * TILESIZE);
						add(entities[i][j]);
					}
					
				}
			}
			
			
			// cycle through the entity data.
			for (i = 0; i < thisLevel.entitiesArray.length; i++)
			{
				var x:int = (FlxSprite)(thisLevel.entitiesArray[i]).x/TILESIZE;
				var y:int = (FlxSprite)(thisLevel.entitiesArray[i]).y/TILESIZE;
				if (thisLevel.entitiesArray[i] is PaceBot)
				{
					var newguy:PaceBot = (PaceBot)(thisLevel.entitiesArray[i]).clone()
					add(newguy);
					entities[x][y] = newguy;
					level[x][y] = 5;
				}
			}
			
			// create player
			player = new Player(px * TILESIZE, py * TILESIZE);
			add(player);
			
			
			// create various GUI-entities
			loadGUI(thisLevel);
		}
		
		private function loadGUI(thisLevel:Level):void
		{
			goalText = new FlxText(180, 5, 150, "");
			add(goalText);
			updateGoalText();
			moveText = new FlxText(10, 200, 100, "");
			add(moveText);
			updateMoveText();
			add(new FlxText(180, 25, 150, "Level " + levelIndex));
			add(new FlxText(180, 45, 150, "Name: " + thisLevel.name));
			add(new FlxText(180, 65, 200, "Sokoban Game v0.1\nArrow keys = move\nR = restart\nPgDown/Up = switch levels"));
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