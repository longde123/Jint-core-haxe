package jint.native.functions;
using StringTools;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
class FunctionPrototype extends jint.native.functions.FunctionInstance
{
    public function new(engine:jint.Engine)
    {
        super(engine, null, null, false);
    }
    public static function CreatePrototypeObject(engine:jint.Engine):jint.native.functions.FunctionPrototype
    {
        var obj:jint.native.functions.FunctionPrototype = new jint.native.functions.FunctionPrototype(engine);
        obj.Extensible = true;
        obj.Prototype = engine.JObject.PrototypeObject;
        obj.FastAddProperty("length", 0, false, false, false);
        return obj;
    }
    public function Configure():Void
    {
        FastAddProperty("constructor", Engine.JFunction, true, false, true);
        FastAddProperty("toString", new jint.runtime.interop.ClrFunctionInstance(Engine, __ToString), true, false, true);
        FastAddProperty("apply", new jint.runtime.interop.ClrFunctionInstance(Engine, Apply, 2), true, false, true);
        FastAddProperty("call", new jint.runtime.interop.ClrFunctionInstance(Engine, CallImpl, 1), true, false, true);
        FastAddProperty("bind", new jint.runtime.interop.ClrFunctionInstance(Engine, Bind, 1), true, false, true);
    }
    private function Bind(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var target:jint.native.ICallable = thisObj.TryCast(jint.native.ICallable,function (x:jint.native.JsValue):Void
        {
            throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        );
        var thisArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var f:jint.native.functions.BindFunctionInstance = new jint.native.functions.BindFunctionInstance(Engine);
        f.TargetFunction = thisObj;
        f.BoundThis = thisArg;
		// arguments.Skip(1).ToArray();
        f.BoundArgs =[ for( i in 1...arguments.length) arguments[i]];
        f.Prototype = Engine.JFunction.PrototypeObject;
        var o:jint.native.functions.FunctionInstance = (Std.is(target, jint.native.functions.FunctionInstance) ? cast(target, jint.native.functions.FunctionInstance) : null);
        if (o != null)
        {
            var l:Float = jint.runtime.TypeConverter.ToNumber(o.Get("length")) - (arguments.length - 1);
            f.FastAddProperty("length", system.MathCS.Max_Double_Double(l, 0), false, false, false);
        }
        else
        {
            f.FastAddProperty("length", 0, false, false, false);
        }
        var thrower:jint.native.functions.FunctionInstance = Engine.JFunction.ThrowTypeError;
        f.DefineOwnProperty("caller", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_JsValue_NullableBoolean_NullableBoolean(thrower, thrower, (false), (false)), false);
        f.DefineOwnProperty("arguments", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_JsValue_NullableBoolean_NullableBoolean(thrower, thrower, (false), (false)), false);
        return f;
    }
    public function __ToString(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var func:jint.native.functions.FunctionInstance = thisObj.TryCast(jint.native.functions.FunctionInstance);
        if (func == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "Function object expected.");
        }
        return  "function() {{ ... }}" ;
    }
    public function Apply(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var func:jint.native.ICallable = thisObject.TryCast(jint.native.ICallable);
        var thisArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var argArray:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 1);
        if (func == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        if (argArray.Equals(jint.native.Null.Instance) || argArray.Equals(jint.native.Undefined.Instance))
        {
            return func.Call(thisArg, jint.runtime.Arguments.Empty);
        }
        var argArrayObj:jint.native.object.ObjectInstance = argArray.TryCast(jint.native.object.ObjectInstance);
        if (argArrayObj == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        var len:Float = argArrayObj.Get("length").AsNumber();
        var n:Int = jint.runtime.TypeConverter.ToUint32(len);
        var argList:Array<jint.native.JsValue> = new Array<jint.native.JsValue>();
        { //for
            var index:Int = 0;
            while (index < n)
            {
                var indexName:String = Std.string(index);
                var nextArg:jint.native.JsValue = argArrayObj.Get(indexName);
                argList.push(nextArg);
                index++;
            }
        } //end for
        return func.Call(thisArg, system.Cs2Hx.ToArray(argList));
    }
    public function CallImpl(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var func:jint.native.ICallable = thisObject.TryCast(jint.native.ICallable);
        if (func == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
		//Skip(arguments, 1)
        return func.Call(jint.runtime.Arguments.At(arguments, 0), arguments.length == 0 ? arguments :  [ for ( i in 1...arguments.length) arguments[i]]);
    }
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return jint.native.Undefined.Instance;
    }
}
