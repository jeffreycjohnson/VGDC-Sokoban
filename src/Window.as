package  
{
	
	public class Window extends Wall 
	{
		
		public function Window(x:int, y:int) 
		{
			super.super(x, y);
			
			loadGraphic(Assets.WINDOW, false, false, 8, 8);
			createAnimations();
			
			play("center1");
			
		}
		
	}

}