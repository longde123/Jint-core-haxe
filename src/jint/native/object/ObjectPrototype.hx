package jint.native.object;
using StringTools;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
class ObjectPrototype extends jint.native.object.ObjectInstance
{
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    public static function CreatePrototypeObject(engine:jint.Engine, objectConstructor:jint.native.object.ObjectConstructor):jint.native.object.ObjectPrototype
    {
        var obj:jint.native.object.ObjectPrototype = new jint.native.object.ObjectPrototype(engine);
        obj.FastAddProperty("constructor", objectConstructor, true, false, true);
        return obj;
    }
    public function Configure():Void
    {
        FastAddProperty("toString", new jint.runtime.interop.ClrFunctionInstance(Engine, ToObjectString), true, false, true);
        FastAddProperty("toLocaleString", new jint.runtime.interop.ClrFunctionInstance(Engine, ToLocaleString), true, false, true);
        FastAddProperty("valueOf", new jint.runtime.interop.ClrFunctionInstance(Engine, ValueOf), true, false, true);
        FastAddProperty("hasOwnProperty", new jint.runtime.interop.ClrFunctionInstance(Engine, __HasOwnProperty, 1), true, false, true);
        FastAddProperty("isPrototypeOf", new jint.runtime.interop.ClrFunctionInstance(Engine, IsPrototypeOf, 1), true, false, true);
        FastAddProperty("propertyIsEnumerable", new jint.runtime.interop.ClrFunctionInstance(Engine, PropertyIsEnumerable, 1), true, false, true);
    }
    private function PropertyIsEnumerable(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var p:String = jint.runtime.TypeConverter.toString(arguments[0]);
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObject);
        var desc:jint.runtime.descriptors.PropertyDescriptor = o.GetOwnProperty(p);
        if (desc == jint.runtime.descriptors.PropertyDescriptor.Undefined)
        {
            return false;
        }
        return desc.Enumerable!=null && desc.Enumerable;
    }
    private function ValueOf(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObject);
        return o;
    }
    private function IsPrototypeOf(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var arg:jint.native.JsValue = arguments[0];
        if (!arg.IsObject())
        {
            return false;
        }
        var v:jint.native.object.ObjectInstance = arg.AsObject();
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObject);
        while (true)
        {
            v = v.Prototype;
            if (v == null)
            {
                return false;
            }
            if (o == v)
            {
                return true;
            }
        }
    }
    private function ToLocaleString(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObject);
        var toString:jint.native.ICallable = o.Get("toString").TryCast(jint.native.ICallable,function (x:jint.native.JsValue):Void
        {
            throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        );
        return toString.Call(o, jint.runtime.Arguments.Empty);
    }
    public function ToObjectString(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        if (thisObject.Equals(jint.native.Undefined.Instance))
        {
            return "[object Undefined]";
        }
        if (thisObject.Equals(jint.native.Null.Instance))
        {
            return "[object Null]";
        }
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObject);
        return "[object " + o.JClass + "]";
    }
    public function __HasOwnProperty(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var p:String = jint.runtime.TypeConverter.toString(arguments[0]);
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObject);
        var desc:jint.runtime.descriptors.PropertyDescriptor = o.GetOwnProperty(p);
        return desc != jint.runtime.descriptors.PropertyDescriptor.Undefined;
    }
}
