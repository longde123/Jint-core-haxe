package jint.native.functions;
using StringTools;
using jint.native.StaticJsValue;
import system.*;
import anonymoustypes.*;

class ThrowTypeError extends jint.native.functions.FunctionInstance
{ 
    public function new(engine:jint.Engine)
    {
        super(engine, [  ], engine.GlobalEnvironment, false);
        _engine = engine; 
        DefineOwnProperty("length", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(0,  false, false, false), false);
        Extensible = false;
    }
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return throw new jint.runtime.JavaScriptException().Creator(_engine.TypeError);
    }
}
