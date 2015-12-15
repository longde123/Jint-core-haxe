package jint.runtime.interop;
using StringTools;
import system.*;
import anonymoustypes.*;

class SetterFunctionInstance extends jint.native.functions.FunctionInstance
{
    private var _setter:(jint.native.JsValue -> jint.native.JsValue -> Void);
    public function new(engine:jint.Engine, setter:(jint.native.JsValue -> jint.native.JsValue -> Void))
    {
        super(engine, null, null, false);
        _setter = setter;
    }
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        _setter(thisObject, arguments[0]);
        return jint.native.Null.Instance;
    }
}
