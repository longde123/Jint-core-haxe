package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
  

 
import test.parser.JavascriptParserTests;



/**
 * ...
 * @author paling
 */

class Main 
{
	 
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
	 Constructors.init();
		   var r = new haxe.unit.TestRunner();
			r.add(new JavascriptParserTests());
			// add other TestCases here

			// finally, run the tests
			
			
			r.run();
	}
	
}