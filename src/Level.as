package  
{
	import flash.utils.ByteArray;
	
	/**
	 * Holds data for a level.
	 */
	public class Level 
	{
		public var name:String;
		public var playerX:int;
		public var playerY:int;
		public var width:int;
		public var height:int;
		
		public var levelArray:Array = [];
		public var floorArray:Array = [];
		public var entitiesArray:Array = [];
		
		public function Level(levelData:Class) 
		{
			generateMetadata(levelData);
		}
		
		private function generateMetadata(xmlData:Class):void
		{
			// Read our xml file
			var bytes:ByteArray = new xmlData;
			var xml:XML = XML(bytes.readUTFBytes(bytes.length));
			var node:XML;
			
			// Load the level name
			name = xml.@Name;
			
			// Load width and height
			width = xml.@width / PlayState.TILESIZE;
			height = xml.@height / PlayState.TILESIZE;
			
			// Set up arrays to null
			var i:int;
			for (i = 0; i < width; i++)
			{
				levelArray[i] = [];
				floorArray[i] = [];
			}
			
			
			// Load data from MainLayer
			for each (node in xml.MainLayer.tile)
			{
				var x:int = node.@x;
				var y:int = node.@y;
				var id:int = node.@id;

				// by default, load the present value to level and 0 to floor.
				levelArray[x][y] = id;
				floorArray[x][y] = 0;
				
				
				// special cases:
				
				// block
				if (id == 2) {
					entitiesArray.push( new Block(x * PlayState.TILESIZE, y * PlayState.TILESIZE));
				}
				// goal-floor
				if (id == 3) {
					levelArray[x][y] = 0;
					floorArray[x][y] = 1;
				}
				// player
				else if (id == 4)
				{
					playerX = x;
					playerY = y;
				}
			}
			
			
			// Load data from EntityLayer
			for each (node in xml.EntityLayer.PatrolBot)
			{
				var b:String = node.@Behavior;
				x = node.@x;
				y = node.@y;
				var ts:int = node.@Movespeed;
				var vt:String = node.@VisionType;
				var vr:int = node.@VisionRadius;
				
				var addMe:PatrolBot;
				if (b == "pace horizontal") addMe = new PaceBot(x, y, ts, vt, vr, "horizontal");
				else if (b == "pace vertical") addMe = new PaceBot(x, y, ts, vt, vr, "vertical");
				else if (b == "no behavior") addMe = new PatrolBot(x, y, ts, vt, vr);
				entitiesArray.push( addMe );
				
				levelArray[x/PlayState.TILESIZE][y/PlayState.TILESIZE] = 5;
			}
			// add more entity types here (e.g. laser emitters, keys, etc.
			
			
		}
		
	}

}