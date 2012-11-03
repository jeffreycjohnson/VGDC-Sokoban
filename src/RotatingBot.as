package  
{
	import org.flixel.*;
	
	/**
	 * A PatrolBot that stands still and rotates clockwise or CC at a constant speed (not through ticks).
	 */
	public class RotatingBot extends PatrolBot
	{
		private var rotateSpeed:Number;
		
		public function RotatingBot(x:int, y:int, rotateSpeed:Number, visionAngle:Number, visionRadius:int) 
		{
			super(x, y, 50, visionAngle, visionRadius, "cone");
			this.rotateSpeed = rotateSpeed;
			loadGraphic(Assets.ROTATINGBOT, false, false, 16, 16);
		}
		
		public function clone():RotatingBot
		{
			return new RotatingBot(x, y, rotateSpeed, visionAngle, _visionRadius);
		}
		
		override public function update():void
		{
			super.update();
			_theta += rotateSpeed;
			(FlxG.state as PlayState).updateDetectedNext = true;
		}
		
	}

}