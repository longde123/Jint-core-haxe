package jint.runtime.interop;
using StringTools;
import system.*;
import anonymoustypes.*;

class GetterFunctionInstance extends jint.native.functions.FunctionInstance
{
    private var _getter:(jint.native.JsValue -> jint.native.JsValue);
    public function new(engine:jint.Engine, getter:(jint.native.JsValue -> jint.native.JsValue))
    {
        super(engine, null, null, false);
        _getter = getter;
    }
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return _getter(thisObject);
    }
}
