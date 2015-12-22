package jint.native;
using StringTools;
import system.*;
import anonymoustypes.*;
 
abstract  JsValue(AbstractJsValue) from AbstractJsValue to AbstractJsValue {
	   public static var Undefined:jint.native.AbstractJsValue;
    public static var Null:jint.native.AbstractJsValue;
    public static var False:jint.native.AbstractJsValue;
    public static var True:jint.native.AbstractJsValue;
  inline function new(v:AbstractJsValue) {
    this = v;
  }
    @:to
  public function toAbstractJsValue() {
    return this;
  }
  @:from 
	public static function op_Explicit_Creator_Double(value:Float):JsValue
	{
		return new JsValue(new jint.native.AbstractJsValue().Creator_Double(value));
	}
	@:from
	public static function op_Explicit_Creator(value:Bool):JsValue
	{
		return  new JsValue(new jint.native.AbstractJsValue().Creator(value));
	}
	@:from
	public static function op_Explicit_Creator_String(value:String):JsValue
	{
		return  new JsValue(new jint.native.AbstractJsValue().Creator_String(value));
	}
	@:from
	public static function op_Explicit_Creator_ObjectInstance(value:jint.native.object.ObjectInstance):JsValue
	{
		return  new JsValue(new jint.native.AbstractJsValue().Creator_ObjectInstance(value));
	}

} 
 