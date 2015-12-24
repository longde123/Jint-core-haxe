package jint.native.error;
using StringTools;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
class ErrorPrototype extends jint.native.error.ErrorInstance
{
    public function new(engine:jint.Engine, name:String)
    {
        super(engine, name);
    }
    public static function CreatePrototypeObject(engine:jint.Engine, errorConstructor:jint.native.error.ErrorConstructor, name:String):jint.native.error.ErrorPrototype
    {
        var obj:jint.native.error.ErrorPrototype = new jint.native.error.ErrorPrototype(engine, name);
        obj.FastAddProperty("constructor", errorConstructor, true, false, true);
        obj.FastAddProperty("message", "", true, false, true);
        if (name != "Error")
        {
            obj.Prototype = engine.Error.PrototypeObject;
        }
        else
        {
            obj.Prototype = engine.JObject.PrototypeObject;
        }
        return obj;
    }
    public function Configure():Void
    {
        FastAddProperty("toString", new jint.runtime.interop.ClrFunctionInstance(Engine, toString), true, false, true);
    }
    override public function toString(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var o:jint.native.object.ObjectInstance = thisObject.TryCast(jint.native.object.ObjectInstance);
        if (o == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        var name:String = jint.runtime.TypeConverter.toString(o.Get("name"));
        var msgProp:jint.native.JsValue = o.Get("message");
        var msg:String;
        if (msgProp.Equals(jint.native.Undefined.Instance))
        {
            msg = "";
        }
        else
        {
            msg = jint.runtime.TypeConverter.toString(msgProp);
        }
        if (name == "")
        {
            return msg;
        }
        if (msg == "")
        {
            return name;
        }
        return name + ": " + msg;
    }
}
