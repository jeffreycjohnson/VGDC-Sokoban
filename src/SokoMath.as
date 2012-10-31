package  
{
	import flash.system.System;
	/**
	 * Stores some useful math functions.
	 */
	public class SokoMath 
	{
		public static function distance(a:Number, b:Number, x:Number, y:Number ):Number
		{
			return Math.sqrt( (a - x) * (a - x) + (b - y) * (b - y) );
		}
		
		public static function angleBetweenPoints(originX:Number, originY:Number, pointX:Number, pointY:Number):Number
		{
			var dx:Number = pointX - originX;
			var dy:Number = pointY - originY;
			var theta:Number = Math.atan2(dy, dx);
			//return Math.atan(dy / dx);
			return theta;
		}
		
		public static function angleIsBetween(theta:Number, minTheta:Number, maxTheta:Number):Boolean
		{
			//if (minTheta < 0) minTheta += Math.PI * 2;
			//if (maxTheta < 0) maxTheta += Math.PI * 2;
			//if (theta < 0) theta += Math.PI * 2;
			
			//if (maxTheta < minTheta) maxTheta += Math.PI * 2;
			
			return (theta > minTheta && theta < maxTheta);
		}
		
	}

}