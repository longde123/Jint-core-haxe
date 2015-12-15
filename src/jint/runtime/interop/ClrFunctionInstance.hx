package jint.runtime.interop;
using StringTools;
import system.*;
import anonymoustypes.*;

class ClrFunctionInstance extends jint.native.functions.FunctionInstance
{
    private var _func:(jint.native.JsValue -> Array<jint.native.JsValue> -> jint.native.JsValue);
    public function new(engine:jint.Engine, func:(jint.native.JsValue -> Array<jint.native.JsValue> -> jint.native.JsValue), length:Int = 0)
    {
        super(engine, null, null, false);
        _func = func;
        Prototype = engine.Function.PrototypeObject;
        FastAddProperty("length", length, false, false, false);
        Extensible = true;
    }
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        try
        {
            var result:jint.native.JsValue = _func(thisObject, arguments);
            return result;
        }
        catch (__ex:system.InvalidCastException)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
    }
}
