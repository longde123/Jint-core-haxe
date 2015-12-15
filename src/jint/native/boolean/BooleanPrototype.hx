package jint.native.boolean;
using StringTools;
import system.*;
import anonymoustypes.*;

class BooleanPrototype extends jint.native.boolean.BooleanInstance
{
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    public static function CreatePrototypeObject(engine:jint.Engine, booleanConstructor:jint.native.boolean.BooleanConstructor):jint.native.boolean.BooleanPrototype
    {
        var obj:jint.native.boolean.BooleanPrototype = new jint.native.boolean.BooleanPrototype(engine);
        obj.Prototype = engine.JObject.PrototypeObject;
        obj.PrimitiveValue = false;
        obj.Extensible = true;
        obj.FastAddProperty("constructor", booleanConstructor, true, false, true);
        return obj;
    }
    public function Configure():Void
    {
        FastAddProperty("toString", new jint.runtime.interop.ClrFunctionInstance(Engine, ToBooleanString), true, false, true);
        FastAddProperty("valueOf", new jint.runtime.interop.ClrFunctionInstance(Engine, ValueOf), true, false, true);
    }
    private function ValueOf(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var B:jint.native.JsValue = thisObj;
        if (B.IsBoolean())
        {
            return B;
        }
        else
        {
            var o:jint.native.boolean.BooleanInstance = B.TryCast();
            if (o != null)
            {
                return o.PrimitiveValue;
            }
            else
            {
                return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
            }
        }
    }
    private function ToBooleanString(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var b:jint.native.JsValue = ValueOf(thisObj, jint.runtime.Arguments.Empty);
        return b.AsBoolean() ? "true" : "false";
    }
}
