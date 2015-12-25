package jint.native;
using StringTools;
import system.*;
import anonymoustypes.*;
 
abstract  JsValue(AbstractJsValue) from AbstractJsValue to AbstractJsValue {
	public static var Undefined:jint.native.AbstractJsValue;
    public static var Null:jint.native.AbstractJsValue;
    public static var False:jint.native.AbstractJsValue;
    public static var True:jint.native.AbstractJsValue;
	public static function cctor():Void
    {
        Undefined = new jint.native.AbstractJsValue().Creator_Types(jint.runtime.Types.Undefined);
        Null = new jint.native.AbstractJsValue().Creator_Types(jint.runtime.Types.Null);
        False = new jint.native.AbstractJsValue().Creator(false);
        True = new jint.native.AbstractJsValue().Creator(true);
    }
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
	public static function FromObject(engine:jint.Engine, value:Dynamic):jint.native.JsValue
    {
        if (value == null)
        {
            return Null;
        }
        for (converter in engine.Options.GetObjectConverters())
        {
            var result:jint.native.AbstractJsValue = (null);
            if (converter.TryConvert(value, result))
            {
                return result;
            }
        }
        
            if(Std.is(value, Bool))
                return new jint.native.AbstractJsValue().Creator(value);
             if(Std.is(value,Int))
                return new jint.native.AbstractJsValue().Creator_Double(value);
             if (Std.is(value, String)){
			 
			    var regex:String = value;  //EReg
				if (regex != null&&  (regex.charCodeAt(0) == 47))
				{
					var jsRegex:jint.native.regexp.RegExpInstance = engine.JRegExp.Construct_String(system.Cs2Hx.Trim_(regex, [ 47 ]));
					return jsRegex;
				}
                return new jint.native.AbstractJsValue().Creator_String(value.toString());
			 }
              if(Std.is(value,Date))
                return engine.JDate.Construct_DateTime(value); 
              if(Std.is(value,Float))
                return new jint.native.AbstractJsValue().Creator_Double(value); 
             if(Std.is(value,String))
                return new jint.native.AbstractJsValue().Creator_String(value);
              if(Std.is(value, Dynamic)||  Std.is(value, Null))
                return throw new system.ArgumentOutOfRangeException();
       
        if (Std.is(value, Date))
        {
        //    return engine.JDate.Construct_DateTimeOffset(value);
        }
        var instance:jint.native.object.ObjectInstance = (Std.is(value, jint.native.object.ObjectInstance) ? cast(value, jint.native.object.ObjectInstance) : null);
        if (instance != null)
        {
            return new jint.native.AbstractJsValue().Creator_ObjectInstance(instance);
        }
        if (Std.is(value, jint.native.AbstractJsValue))
        {
            return value;
        }
        var array:Array<Dynamic> = cast(value);
        if (array != null)
        {
            var jsArray:jint.native.object.ObjectInstance = engine.JArray.Construct(jint.runtime.Arguments.Empty);
            for (item in array)
            {
                var jsItem:jint.native.AbstractJsValue = FromObject(engine, item);
                engine.JArray.PrototypeObject.Push(jsArray, jint.runtime.Arguments.From([ jsItem ]));
            }
            return jsArray;
        }
   
		//Delegate
        var d = value;
        if (d != null)
        {
            return new jint.runtime.interop.DelegateWrapper(engine, d,null);
        }
        if (Reflect.isEnumValue(value))
        {
            return new jint.native.AbstractJsValue().Creator_Double(value);
        }
        return new jint.runtime.interop.ObjectWrapper(engine, value);
    }
} 
 