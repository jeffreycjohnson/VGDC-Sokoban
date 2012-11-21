package  
{
	import org.flixel.*;
	
	/**
	 * A PatrolBot that stands still and rotates clockwise or CC at a constant speed (not through ticks).
	 */
	public class RotatingBot extends PatrolBot
	{
		private var rotateSpeed:Number;
						
		public function RotatingBot(x:int, y:int, rotateSpeed:Number, visionAngle:Number, visionRadius:int, initAngle:Number) 
		{
			super(x, y, 50, visionAngle, visionRadius, "cone");
			
			//trace("Oooh");
			//trace(initAngle * Math.PI / 180);
			
			this.rotateSpeed = rotateSpeed;
			_theta = +initAngle * Math.PI / 180;
			loadGraphic(Assets.ROTATINGBOT, false, false, 16, 16);
		}
		
		public function clone():RotatingBot
		{
			// we turn theta back into degrees so the constructor can turn it back into radians
			// sketchy i know
			return new RotatingBot(x, y, rotateSpeed, visionAngle, _visionRadius, _theta * (180 / Math.PI));
		}
		
		override public function update():void
		{
			super.update();
			this._theta += rotateSpeed;
			(FlxG.state as PlayState).updateDetectedNext = true;
		}
		
	}

}