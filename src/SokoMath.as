package  
{
	/**
	 * Stores some math functions.
	 */
	public class SokoMath 
	{
		public static function distance(a:Number, b:Number, x:Number, y:Number ):Number
		{
			return Math.sqrt( (a - x) * (a - x) + (b - y) * (b - y) );
		}
		
	}

}