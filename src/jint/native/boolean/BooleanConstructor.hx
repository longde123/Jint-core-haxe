package jint.native.boolean;
using StringTools;
import system.*;
import anonymoustypes.*;

class BooleanConstructor extends jint.native.functions.FunctionInstance implements jint.native.IConstructor
{
    public function new(engine:jint.Engine)
    {
        super(engine, null, null, false);
    }
    public static function CreateBooleanConstructor(engine:jint.Engine):jint.native.boolean.BooleanConstructor
    {
        var obj:jint.native.boolean.BooleanConstructor = new jint.native.boolean.BooleanConstructor(engine);
        obj.Extensible = true;
        obj.Prototype = engine.Function.PrototypeObject;
        obj.PrototypeObject = jint.native.boolean.BooleanPrototype.CreatePrototypeObject(engine, obj);
        obj.FastAddProperty("length", 1, false, false, false);
        obj.FastAddProperty("prototype", obj.PrototypeObject, false, false, false);
        return obj;
    }
    public function Configure():Void
    {
    }
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        if (arguments.length == 0)
        {
            return false;
        }
        return jint.runtime.TypeConverter.ToBoolean(arguments[0]);
    }
    public function Construct(arguments:Array<jint.native.JsValue>):jint.native.object.ObjectInstance
    {
        return Construct_Boolean(jint.runtime.TypeConverter.ToBoolean(jint.runtime.Arguments.At(arguments, 0)));
    }
    public var PrototypeObject:jint.native.boolean.BooleanPrototype;
    public function Construct_Boolean(value:Bool):jint.native.boolean.BooleanInstance
    {
        var instance:jint.native.boolean.BooleanInstance = new jint.native.boolean.BooleanInstance(Engine);
        instance.Prototype = PrototypeObject;
        instance.PrimitiveValue = value;
        instance.Extensible = true;
        return instance;
    }
}
