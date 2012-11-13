package  
{
	import flash.system.System;
	/**
	 * Stores some useful math functions.
	 */
	public class SokoMath 
	{
		
		public static function angleBetweenPoints(originX:Number, originY:Number, pointX:Number, pointY:Number):Number
		{
			var dx:Number = pointX - originX;
			var dy:Number = pointY - originY;
			var theta:Number = Math.atan2(dy, dx);
			return theta;
		}
		
		public static function angleIsBetween(theta:Number, minTheta:Number, maxTheta:Number):Boolean
		{
			
			return (theta > minTheta && theta < maxTheta);
		}
		
	}

}