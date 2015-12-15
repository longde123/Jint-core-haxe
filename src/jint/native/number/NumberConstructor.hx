package jint.native.number;
using StringTools;
import system.*;
import anonymoustypes.*;

class NumberConstructor extends jint.native.functions.FunctionInstance implements jint.native.IConstructor
{
    public function new(engine:jint.Engine)
    {
        super(engine, null, null, false);
    }
    public static function CreateNumberConstructor(engine:jint.Engine):jint.native.number.NumberConstructor
    {
        var obj:jint.native.number.NumberConstructor = new jint.native.number.NumberConstructor(engine);
        obj.Extensible = true;
        obj.Prototype = engine.Function.PrototypeObject;
        obj.PrototypeObject = jint.native.number.NumberPrototype.CreatePrototypeObject(engine, obj);
        obj.FastAddProperty("length", 1, false, false, false);
        obj.FastAddProperty("prototype", obj.PrototypeObject, false, false, false);
        return obj;
    }
    public function Configure():Void
    {
        FastAddProperty("MAX_VALUE", 3.4028235e+38, false, false, false);
        FastAddProperty("MIN_VALUE", 4.94065645841247E-324, false, false, false);
        FastAddProperty("NaN", Math.NaN, false, false, false);
        FastAddProperty("NEGATIVE_INFINITY", 负无穷大, false, false, false);
        FastAddProperty("POSITIVE_INFINITY", 正无穷大, false, false, false);
    }
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        if (arguments.length == 0)
        {
            return 0d;
        }
        return jint.runtime.TypeConverter.ToNumber(arguments[0]);
    }
    public function Construct(arguments:Array<jint.native.JsValue>):jint.native.object.ObjectInstance
    {
        return Construct_Double(arguments.length > 0 ? jint.runtime.TypeConverter.ToNumber(arguments[0]) : 0);
    }
    public var PrototypeObject:jint.native.number.NumberPrototype;
    public function Construct_Double(value:Float):jint.native.number.NumberInstance
    {
        var instance:jint.native.number.NumberInstance = new jint.native.number.NumberInstance(Engine);
        instance.Prototype = PrototypeObject;
        instance.PrimitiveValue = value;
        instance.Extensible = true;
        return instance;
    }
}
