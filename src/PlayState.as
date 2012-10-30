package  
{
		
	import org.flixel.*;
	import mx.collections.ListCollectionView;
	import mx.utils.ObjectUtil;
	
	/**
	 * The class which contains the game loop and stores important data.
	 */
	public class PlayState extends FlxState
	{
		// width of a tile in pixels
		public static const TILESIZE:int = 16;
		
		// holds the values of what kind of stuff we have at each grid space
		public static var level:Array = [];
		/* 0 = empty
		 * 1 = wall
		 * 2 = block
		 * 4 = player
		 * 5 = patrolbot
		 */
		
		// holds what type of floor there is at each grid space.
		private var floor:Array = [];
		/* 0 = plain floor
		 * 1 = goal
		 */
		
		//NOTE: Why can't this be combined with level array? Just make floors a penetratable block
		// answer: At first, I just had level[][] and not floor[][]. But the problem was that when, for example,
		// the player walked over a goal tile, and then walked off of it, the game would not remember there
		// was ever a goal tile there, since it overwrote the value of the goaltile (used to be 3) to 4.
		// So I created floor[][] to forever remember if there was a goal at that space or not.
		
		// One work-around I implemented but then scrapped was to save special values, like for example "4 = player standing on goal"
		// and "5 = block standing on goal" but that wouldn't take kindly to many types of possible array values.
		// (I'm not sure how to communicate about this kind of thing via github, so you can delete this when you've read it.)
		
		// holds MovingSprites we need to access by their position in the array.
		private var entities:Array = [];
		
		// store the player and his coordinates for ease of access.
		private var player:Player;
		private var px:int;
		private var py:int;
		
		/*
		NOTE: Better if player vars kept in Player class?
		*/
		// Answer: I guess we could, but I like this way better, since Player is never going to use px or py.
		// We're only going to use and modify those values in PlayState.
		
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
					player.move(xo, yo);
					level[px][py] = 0;
					level[x_next][y_next] = 4;
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
					level[x_next][y_next] = 4;
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
					// 1 - load data from thislevel into our level and floor arrays
					
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
				}
				
				// add each entity to the FlxState, and also to it's place in the entitites array.
				add(specificGuy);
				entities[x][y] = specificGuy;
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
		
		public static function updateDetected():void
		{
			// this is a tough problem.
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