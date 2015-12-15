package jint.native.functions;
using StringTools;
import system.*;
import anonymoustypes.*;

class FunctionInstance extends jint.native.object.ObjectInstance implements jint.native.ICallable
{
    private var _engine:jint.Engine;
    public function new(engine:jint.Engine, parameters:Array<String>, scope:jint.runtime.environments.LexicalEnvironment, strict:Bool)
    {
        super(engine);
        _engine = engine;
        FormalParameters = parameters;
        Scope = scope;
        Strict = strict;
    }
    public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return throw new Exception("Abstract item called");
    }
    public var Scope:jint.runtime.environments.LexicalEnvironment;
    public var FormalParameters:Array<String>;
    public var Strict:Bool;
    public function HasInstance(v:jint.native.JsValue):Bool
    {
        var vObj:jint.native.object.ObjectInstance = v.TryCast();
        if (vObj == null)
        {
            return false;
        }
        var po:jint.native.JsValue = Get("prototype");
        if (!po.IsObject())
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(_engine.TypeError, Cs2Hx.Format("Function has non-object prototype '{0}' in instanceof check", jint.runtime.TypeConverter.toString(po)));
        }
        var o:jint.native.object.ObjectInstance = po.AsObject();
        if (o == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(_engine.TypeError);
        }
        while (true)
        {
            vObj = vObj.Prototype;
            if (vObj == null)
            {
                return false;
            }
            if (vObj == o)
            {
                return true;
            }
        }
    }
    override public function get_Class():String
    {
        return "Function";
    }

    override public function Get(propertyName:String):jint.native.JsValue
    {
        var v:jint.native.JsValue = super.Get(propertyName);
        var f:jint.native.functions.FunctionInstance = v.As();
        if (propertyName == "caller" && f != null && f.Strict)
        {
            return throw new jint.runtime.JavaScriptException().Creator(_engine.TypeError);
        }
        return v;
    }
}
