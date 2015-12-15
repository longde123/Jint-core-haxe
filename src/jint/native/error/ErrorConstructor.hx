package jint.native.error;
using StringTools;
import system.*;
import anonymoustypes.*;

class ErrorConstructor extends jint.native.functions.FunctionInstance implements jint.native.IConstructor
{
    private var _name:String;
    public function new(engine:jint.Engine)
    {
        super(engine, null, null, false);
    }
    public static function CreateErrorConstructor(engine:jint.Engine, name:String):jint.native.error.ErrorConstructor
    {
        var obj:jint.native.error.ErrorConstructor = new jint.native.error.ErrorConstructor(engine);
        obj.Extensible = true;
        obj._name = name;
        obj.Prototype = engine.JFunction.PrototypeObject;
        obj.PrototypeObject = jint.native.error.ErrorPrototype.CreatePrototypeObject(engine, obj, name);
        obj.FastAddProperty("length", 1, false, false, false);
        obj.FastAddProperty("prototype", obj.PrototypeObject, false, false, false);
        return obj;
    }
    public function Configure():Void
    {
    }
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return Construct(arguments);
    }
    public function Construct(arguments:Array<jint.native.JsValue>):jint.native.object.ObjectInstance
    {
        var instance:jint.native.error.ErrorInstance = new jint.native.error.ErrorInstance(Engine, _name);
        instance.Prototype = PrototypeObject;
        instance.Extensible = true;
        if (!jint.runtime.Arguments.At(arguments, 0).Equals(jint.native.Undefined.Instance))
        {
            instance.Put("message", jint.runtime.TypeConverter.toString(jint.runtime.Arguments.At(arguments, 0)), false);
        }
        return instance;
    }
    public var PrototypeObject:jint.native.error.ErrorPrototype;
}
