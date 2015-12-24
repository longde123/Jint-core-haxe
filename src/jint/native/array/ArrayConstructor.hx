package jint.native.array;
using StringTools;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
class ArrayConstructor extends jint.native.functions.FunctionInstance implements jint.native.IConstructor
{
    public function new(engine:jint.Engine)
    {
        super(engine, null, null, false);
    }
    public var PrototypeObject:jint.native.array.ArrayPrototype;
    public static function CreateArrayConstructor(engine:jint.Engine):jint.native.array.ArrayConstructor
    {
        var obj:jint.native.array.ArrayConstructor = new jint.native.array.ArrayConstructor(engine);
        obj.Extensible = true;
        obj.Prototype = engine.JFunction.PrototypeObject;
        obj.PrototypeObject = jint.native.array.ArrayPrototype.CreatePrototypeObject(engine, obj);
        obj.FastAddProperty("length", 1, false, false, false);
        obj.FastAddProperty("prototype", obj.PrototypeObject, false, false, false);
        return obj;
    }
    public function Configure():Void
    {
        FastAddProperty("isArray", new jint.runtime.interop.ClrFunctionInstance(Engine, IsArray, 1), true, false, true);
    }
    private function IsArray(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        if (arguments.length == 0)
        {
            return false;
        }
        var o:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        return o.IsObject() && o.AsObject().JClass == "Array";
    }
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return Construct(arguments);
    }
    public function Construct(arguments:Array<jint.native.JsValue>):jint.native.object.ObjectInstance
    {
        var instance:jint.native.array.ArrayInstance = new jint.native.array.ArrayInstance(Engine);
        instance.Prototype = PrototypeObject;
        instance.Extensible = true;
        if (arguments.length == 1 && jint.runtime.Arguments.At(arguments, 0).IsNumber())
        {
            var length:Int = jint.runtime.TypeConverter.ToUint32(jint.runtime.Arguments.At(arguments, 0));
            if (jint.runtime.TypeConverter.ToNumber(arguments[0])!=(length))
            {
                return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.RangeError, "Invalid array length");
            }
            instance.FastAddProperty("length", length, true, false, false);
        }
        else if (arguments.length == 1 && jint.runtime.Arguments.At(arguments, 0).IsObject() && jint.runtime.Arguments.At(arguments, 0).As(jint.runtime.interop.ObjectWrapper) != null)
        {
			var objectWrapper:jint.runtime.interop.ObjectWrapper = jint.runtime.Arguments.At(arguments, 0).As(jint.runtime.interop.ObjectWrapper);
            var enumerable:Array<Dynamic> =cast objectWrapper.Target;
            if (enumerable != null)
            {
                var jsArray:jint.native.object.ObjectInstance = Engine.JArray.Construct(jint.runtime.Arguments.Empty);
                for (item in enumerable)
                {
                    var jsItem:jint.native.JsValue = jint.native.JsValue.FromObject(Engine, item);
                    Engine.JArray.PrototypeObject.Push(jsArray, jint.runtime.Arguments.From([ jsItem ]));
                }
                return jsArray;
            }
        }
        else
        {
            instance.FastAddProperty("length", 0, true, false, false);
            PrototypeObject.Push(instance, arguments);
        }
        return instance;
	
    }
}
