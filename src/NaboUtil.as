package  
{
	import org.flixel.*;
	
	/**
	 * Hopefully useful functions
	 */
	public class NaboUtil 
	{
		// moves all the members from one group to another. This is very hackish.
		// Note: if you use remove() on the FlxGroup sometime before calling this method, this fails.
		public static function moveGroup(group:FlxGroup, xOffset:int, yOffset:int = 0):void
		{
			for (var i:int = 0; i < group.length; i++)
			{
				FlxSprite(group.members[i]).x += xOffset;
				FlxSprite(group.members[i]).y += yOffset;
			}
		}
	}

}