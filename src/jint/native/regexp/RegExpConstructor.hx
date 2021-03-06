package jint.native.regexp;
using StringTools;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
class RegExpConstructor extends jint.native.functions.FunctionInstance implements jint.native.IConstructor
{
    public function new(engine:jint.Engine)
    {
        super(engine, null, null, false);
    }
    public static function CreateRegExpConstructor(engine:jint.Engine):jint.native.regexp.RegExpConstructor
    {
        var obj:jint.native.regexp.RegExpConstructor = new jint.native.regexp.RegExpConstructor(engine);
        obj.Extensible = true;
        obj.Prototype = engine.JFunction.PrototypeObject;
        obj.PrototypeObject = jint.native.regexp.RegExpPrototype.CreatePrototypeObject(engine, obj);
        obj.FastAddProperty("length", 2, false, false, false);
        obj.FastAddProperty("prototype", obj.PrototypeObject, false, false, false);
        return obj;
    }
    public function Configure():Void
    {
    }
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var pattern:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var flags:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 1);
        if (!pattern.Equals(jint.native.Undefined.Instance) && flags.Equals(jint.native.Undefined.Instance) && jint.runtime.TypeConverter.ToObject(Engine, pattern).JClass == "Regex")
        {
            return pattern;
        }
        return Construct(arguments);
    }
    public function Construct(arguments:Array<jint.native.JsValue>):jint.native.object.ObjectInstance
    {
        var p:String;
        var f:String;
        var pattern:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var flags:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 1);
        var r:jint.native.regexp.RegExpInstance = pattern.TryCast(jint.native.regexp.RegExpInstance);
        if (flags.Equals(jint.native.Undefined.Instance) && r != null)
        {
            return r;
        }
        else if (!flags.Equals(jint.native.Undefined.Instance) && r != null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        else
        {
            if (pattern.Equals(jint.native.Undefined.Instance))
            {
                p = "";
            }
            else
            {
                p = jint.runtime.TypeConverter.toString(pattern);
            }
            f = !flags.Equals(jint.native.Undefined.Instance) ? jint.runtime.TypeConverter.toString(flags) : "";
        }
        r = new jint.native.regexp.RegExpInstance(Engine);
        r.Prototype = PrototypeObject;
        r.Extensible = true;
        
        try
        {
            r.Value = new EReg(p, f);
        }
        catch (e:Dynamic)
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.SyntaxError, e.Message);
        }
        var s:String;
        s = p;
        if (system.Cs2Hx.IsNullOrEmpty(s))
        {
            s = "(?:)";
        }
        r.Flags = f;
        r.Source = s;
        r.FastAddProperty("global", r.Global, false, false, false);
        r.FastAddProperty("ignoreCase", r.IgnoreCase, false, false, false);
        r.FastAddProperty("multiline", r.Multiline, false, false, false);
        r.FastAddProperty("source", r.Source, false, false, false);
        r.FastAddProperty("lastIndex", 0, true, false, false);
        return r;
    }
    public function Construct_String(regExp:String):jint.native.regexp.RegExpInstance
    {
        var r:jint.native.regexp.RegExpInstance = new jint.native.regexp.RegExpInstance(Engine);
        r.Prototype = PrototypeObject;
        r.Extensible = true;
        if (regExp.charCodeAt(0) != 47)
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.SyntaxError, "Regexp should start with slash");
        }
        var lastSlash:Int = regExp.lastIndexOf("/");
        var pattern:String = regExp.substr(1, lastSlash - 1).replace("\\/", "/");
        var flags:String = regExp.substr(lastSlash + 1);
       
        try
        {
            r.Value = new EReg(pattern, flags);
        }
        catch (e:Dynamic)
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.SyntaxError, e.Message);
        }
        r.Flags = flags;
        r.Source = system.Cs2Hx.IsNullOrEmpty(pattern) ? "(?:)" : pattern;
        r.FastAddProperty("global", r.Global, false, false, false);
        r.FastAddProperty("ignoreCase", r.IgnoreCase, false, false, false);
        r.FastAddProperty("multiline", r.Multiline, false, false, false);
        r.FastAddProperty("source", r.Source, false, false, false);
        r.FastAddProperty("lastIndex", 0, true, false, false);
        return r;
    }
   
    public var PrototypeObject:jint.native.regexp.RegExpPrototype;
}
