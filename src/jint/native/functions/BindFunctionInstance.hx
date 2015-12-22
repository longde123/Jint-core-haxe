package jint.native.functions;
using StringTools;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
class BindFunctionInstance extends jint.native.functions.FunctionInstance implements jint.native.IConstructor
{
    public function new(engine:jint.Engine)
    {
        super(engine, [  ], null, false);
    }
    public var TargetFunction:jint.native.JsValue;
    public var BoundThis:jint.native.JsValue;
    public var BoundArgs:Array<jint.native.JsValue>;
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var f:jint.native.functions.FunctionInstance = TargetFunction.TryCast(FunctionInstance,function (x:jint.native.JsValue):Void
        {
            throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        );
        return f.Call(BoundThis, BoundArgs.concat( arguments) );
    }
    public function Construct(arguments:Array<jint.native.JsValue>):jint.native.object.ObjectInstance
    {
        var target:jint.native.IConstructor = TargetFunction.TryCast(IConstructor,function (x:jint.native.JsValue):Void
        {
            throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        );
        return target.Construct(BoundArgs.concat( arguments));
    }
    override public function HasInstance(v:jint.native.JsValue):Bool
    {
        var f:jint.native.functions.FunctionInstance = TargetFunction.TryCast(FunctionInstance,function (x:jint.native.JsValue):Void
        {
            throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        );
        return f.HasInstance(v);
    }
}
