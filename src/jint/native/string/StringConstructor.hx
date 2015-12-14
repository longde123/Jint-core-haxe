package jint.native.string;
using StringTools;
import system.*;
import anonymoustypes.*;

class StringConstructor extends jint.native.function.FunctionInstance implements jint.native.IConstructor
{
    public function new(engine:jint.Engine)
    {
        super(engine, null, null, false);
    }
    public static function CreateStringConstructor(engine:jint.Engine):jint.native.string.StringConstructor
    {
        var obj:jint.native.string.StringConstructor = new jint.native.string.StringConstructor(engine);
        obj.Extensible = true;
        obj.Prototype = engine.Function.PrototypeObject;
        obj.PrototypeObject = jint.native.string.StringPrototype.CreatePrototypeObject(engine, obj);
        obj.FastAddProperty("length", 1, false, false, false);
        obj.FastAddProperty("prototype", obj.PrototypeObject, false, false, false);
        return obj;
    }
    public function Configure():Void
    {
        FastAddProperty("fromCharCode", new jint.runtime.interop.ClrFunctionInstance(Engine, FromCharCode, 1), true, false, true);
    }
    private static function FromCharCode(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var chars:Array<Int> = [  ];
        { //for
            var i:Int = 0;
            while (i < chars.length)
            {
                chars[i] = jint.runtime.TypeConverter.ToUint16(arguments[i]);
                i++;
            }
        } //end for
        return new String(chars);
    }
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        if (arguments.length == 0)
        {
            return "";
        }
        return jint.runtime.TypeConverter.toString(arguments[0]);
    }
    public function Construct(arguments:Array<jint.native.JsValue>):jint.native.object.ObjectInstance
    {
        return Construct_String(arguments.length > 0 ? jint.runtime.TypeConverter.toString(arguments[0]) : "");
    }
    public var PrototypeObject:jint.native.string.StringPrototype;
    public function Construct_String(value:String):jint.native.string.StringInstance
    {
        var instance:jint.native.string.StringInstance = new jint.native.string.StringInstance(Engine);
        instance.Prototype = PrototypeObject;
        instance.PrimitiveValue = value;
        instance.Extensible = true;
        instance.FastAddProperty("length", value.length, false, false, false);
        return instance;
    }
}
