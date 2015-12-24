package ;
abstract MyAbstract(TestA) from TestA to TestA {
  inline function new(i:TestA) {
    this = i;
  }

  @:from
  static public function fromString(s:String) {
	  var ta = new TestA();
	  ta.a = s;
    return new MyAbstract(ta);
  }

  @:to
  public function toTestA() {
    return  this ;
  }
} 

abstract ColorAbstract(Color) from Color to Color {
  inline function new(i:Color) {
    this = i;
  }

  @:from
  static public function fromRgb(rgb:Int) {
	  
    return new ColorAbstract(Color.Rgb(1,1,1));
  }
 
} 
enum Color {
  Red;
  Green;
  Blue;
  Rgb(r:Int, g:Int, b:Int);
}
class TestA
{
  public var a:String;
  public function new(){}
}
/**
 * ...
 * @author paling
 */
class TestAbstract
{
    static function main()
    {

    }
	inline static public function testColor(a:Color) {
 
		trace("Color", Color);

	} 
	
    inline static public function test(a:MyAbstract) {
		var self:TestA = a;
		trace("self", self.a);

	} 
	
}