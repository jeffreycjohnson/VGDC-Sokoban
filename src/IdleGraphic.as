package  
{
	import org.flixel.*;
	
	/**
	 * 16x16 tile which comes from extratiles_*.png.
	 */
	public class IdleGraphic extends FlxSprite
	{
		private var _solid:Boolean;
		private var source:Class;
		private var id:int;
		
		public function IdleGraphic(x:int, y:int, source:Class, id:int, solid:Boolean) 
		{
			super(x, y);
			loadGraphic(source, false, false, 16, 16);
			addAnimation("hexagon", [id]);
			play("hexagon");
			this.source = source;
			this.id = id;
			_solid = solid;
		}
		
		public function isSolid():Boolean
		{
			return _solid;
		}
		
		public function clone():IdleGraphic
		{
			return new IdleGraphic(x, y, source, id, _solid);
		}
	}

}