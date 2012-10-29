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
		 * 5 = bot
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
		private var levelindex:int;
		
		// how many moves the player has done
		private var movecount:int;
		
		// Counts of "goals": places where you have to try to move the blocks to
		private var goalnumber:int; // total number of goals
		private var goalcount:int  // goals achieved so far
		
		// texts that display information
		private var goaltext:FlxText;
		private var movetext:FlxText;
		
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
					movecount++;
					updatemovetext();
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
					movecount++;
					updatemovetext();
					
					// now we change the goal count if necessary
					if (floor[x_next][y_next] == 0 && floor[x_next2][y_next2] == 1)
					{
						goalcount++;
						updategoaltext();
					}
					else if (floor[x_next][y_next] == 1 && floor[x_next2][y_next2] == 0)
					{
						goalcount--;
						updategoaltext();
					}
				}
				// TODO: other cases (?)
			}
			
			// if R keys is pressed, reset
			if (FlxG.keys.justPressed("R"))
			{
				create();
			}
			
			// if PgDown or PgUp is pressed, switch levels
			if (FlxG.keys.justPressed("PAGEUP"))
			{
				if (levelindex < LevelStorage.levels.length - 1) loadLevel(levelindex + 1);
			}
			else if (FlxG.keys.justPressed("PAGEDOWN"))
			{
				if (levelindex > 0) loadLevel(levelindex - 1);
			}
			
			// finally, update all objects we have added to our FlxState.
			super.update();
		}
		
		private function loadLevel(index:int):void
		{
			// standard stuff.
			levelindex = index;
			var thislevel:Level = LevelStorage.levels[levelindex];
			clear();
			goalnumber = goalcount = 0;
			movecount = 0;
			var i:int = 0;
			var j:int = 0;			
			
			// load data from the Level thislevel.
			for (i = 0; i < thislevel.width; i++) {
				level[i] = [];
				floor[i] = [];
				for (j = 0; j < thislevel.height; j++) {
					level[i][j] = thislevel.levelArray[i][j];
					floor[i][j] = thislevel.floorArray[i][j];
				}
			}
			px = thislevel.playerx;
			py = thislevel.playery;
			
			// add wall and floor graphics
			for (i = 0; i < level.length; i++)
			{
				for (j = 0; j < level[0].length; j++)
				{
					// add wall graphics
					if (level[i][j] == 1) add( new Wall(i * TILESIZE, j * TILESIZE));
					
					// add goal floor graphics
					else if (floor[i][j] == 1) {
						add( new Goal(i * TILESIZE, j * TILESIZE));
						goalnumber++;
					}
					
					// add empty floor graphics
					else add( new Floor(i * TILESIZE, j * TILESIZE));
				}
			}
			
			/*
			NOTE: Lotta looping over the same data, perhaps combine?
			*/
			
			// initialize entities[][]
			for (i = 0; i < level.length; i++)
			{
				entities[i] = [];
			}
			
			
			// add blocks, etc. to entities[][]
			for (i = 0; i < level.length; i++)
			{
				for (j = 0; j < level.length; j++)
				{
					if (level[i][j] == 2) {
						entities[i][j] = new Block(i * TILESIZE, j * TILESIZE);
						add(entities[i][j]);
					}
					// TODO: add different kinds of entities here. (that are loaded from MainLayer)
				}
			}
			
			
			// load entities from EntityLayer
			for (i = 0; i < thislevel.entitiesArray.length; i++)
			{
				if (thislevel.entitiesArray[i] is PaceBot)
				{
					add( (PaceBot)(thislevel.entitiesArray[i]).clone() )
					// TODO: set array value when adding patrolbot. also add it to entities[][]?
				}
			}
			
			// create player
			player = new Player(px * TILESIZE, py * TILESIZE);
			add(player);
			
			
			// create texts
			// NOTE: Text isn't related to making the level, put in own function
			goaltext = new FlxText(180, 5, 150, "");
			add(goaltext);
			updategoaltext();
			movetext = new FlxText(10, 200, 100, "");
			add(movetext);
			updatemovetext();
			add(new FlxText(180, 25, 150, "Level " + levelindex));
			add(new FlxText(180, 45, 150, "Name: " + thislevel.name));
			add(new FlxText(180, 65, 200, "Sokoban Game v0.1\nArrow keys = move\nR = restart\nPgDown/Up = switch levels"));
		}
		
		private function updategoaltext():void
		{
			goaltext.text = "Blocks: " + goalcount + " / " + goalnumber;
			if (goalcount == goalnumber) goaltext.text = goaltext.text + "\nCongrats!";
		}
		
		private function updatemovetext():void
		{
			movetext.text = "Moves: " + movecount;
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