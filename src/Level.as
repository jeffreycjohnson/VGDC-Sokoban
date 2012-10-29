package  
{
	import flash.utils.ByteArray;
	
	public class Level 
	{
		public var name:String;
		public var playerx:int;
		public var playery:int;
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
			// read our xml file
			var bytes:ByteArray = new xmlData;
			var xml:XML = XML(bytes.readUTFBytes(bytes.length));
			var node:XML;
			
			// Load the level name
			name = xml.@Name;
			
			// Load width and height
			width = xml.@width / PlayState.TILESIZE;
			height = xml.@height / PlayState.TILESIZE;
			
			// set up arrays to null
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
				
				levelArray[x][y] = id;
				floorArray[x][y] = 0;
				if (id == 3) {
					levelArray[x][y] = 0;
					floorArray[x][y] = 1;
				}
				else if (id == 4)
				{
					levelArray[x][y] = 0;
					playerx = x;
					playery = y;
				}
			}
			
			// Load data from EntityLayer
			for each (node in xml.EntityLayer.PatrolBot)
			{
				var b:String = node.@Behavior;
				var x:int = node.@x;
				var y:int = node.@y;
				var ts:int = node.@Movespeed;
				var vt:String = node.@VisionType;
				var vr:int = node.@VisionRadius;
				
				var addme:PatrolBot;
				
				if (b == "pace horizontal") addme = new PaceBot(x, y, ts, vt, vr, "horizontal");
				else if (b == "pace vertical") addme = new PaceBot(x, y, ts, vt, vr, "vertical");
				entitiesArray.push( addme );
			}
			
		}
		
	}

}