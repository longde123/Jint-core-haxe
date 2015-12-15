package jint.native.functions;
using StringTools;
import system.*;
import anonymoustypes.*;

class FunctionShim extends jint.native.functions.FunctionInstance
{
    public function new(engine:jint.Engine, parameters:Array<String>, scope:jint.runtime.environments.LexicalEnvironment)
    {
        super(engine, parameters, scope, false);
    }
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return jint.native.Undefined.Instance;
    }
}
