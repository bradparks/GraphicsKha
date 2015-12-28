package;

import kha.Scheduler;
import kha.System;
import PolyK;
class Main 
{
	public static function main()
	{
		System.init("GraphicsKha", 1280, 720, initialized);
	}
	
	private static function initialized():Void 
	{
		var game = new GraphicsKha();
		System.notifyOnRender(game.render);
		Scheduler.addTimeTask(game.update, 0, 1 / 60);
	}
}