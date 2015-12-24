package jint.native.regexp;
using StringTools;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
class RegExpPrototype extends jint.native.regexp.RegExpInstance
{
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    public static function CreatePrototypeObject(engine:jint.Engine, regExpConstructor:jint.native.regexp.RegExpConstructor):jint.native.regexp.RegExpPrototype
    {
        var obj:jint.native.regexp.RegExpPrototype = new jint.native.regexp.RegExpPrototype(engine);
        obj.Prototype = engine.JObject.PrototypeObject;
        obj.Extensible = true;
        obj.FastAddProperty("constructor", regExpConstructor, true, false, true);
        return obj;
    }
    public function Configure():Void
    {
        FastAddProperty("toString", new jint.runtime.interop.ClrFunctionInstance(Engine, ToRegExpString), true, false, true);
        FastAddProperty("exec", new jint.runtime.interop.ClrFunctionInstance(Engine, Exec, 1), true, false, true);
        FastAddProperty("test", new jint.runtime.interop.ClrFunctionInstance(Engine, Test, 1), true, false, true);
        FastAddProperty("global", false, false, false, false);
        FastAddProperty("ignoreCase", false, false, false, false);
        FastAddProperty("multiline", false, false, false, false);
        FastAddProperty("source", "(?:)", false, false, false);
        FastAddProperty("lastIndex", 0, true, false, false);
    }
    private function ToRegExpString(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var regExp:jint.native.regexp.RegExpInstance = thisObj.TryCast();
        return "/" + regExp.Source + "/" + (system.Cs2Hx.StringContains(regExp.Flags, "g") ? "g" : "") + (system.Cs2Hx.StringContains(regExp.Flags, "i") ? "i" : "") + (system.Cs2Hx.StringContains(regExp.Flags, "m") ? "m" : "");
    }
    private function Test(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var r:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        if (r.JClass != "RegExp")
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        var match:jint.native.JsValue = Exec(r, arguments);
        return !match.Equals(jint.native.Null.Instance);
    }
    public function Exec(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var R:jint.native.regexp.RegExpInstance = cast(jint.runtime.TypeConverter.ToObject(Engine, thisObj), jint.native.regexp.RegExpInstance);
        if (R == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        var s:String = jint.runtime.TypeConverter.toString(jint.runtime.Arguments.At(arguments, 0));
        var length:Int = s.length;
        var lastIndex:Float = jint.runtime.TypeConverter.ToNumber(R.Get("lastIndex"));
        var i:Float = jint.runtime.TypeConverter.ToInteger(lastIndex);
        var global:Bool = R.Global;
        if (!global)
        {
            i = 0;
        }
        if (R.Source == "(?:)")
        {
            var aa:jint.native.object.ObjectInstance = InitReturnValueArray(Engine.JArray.Construct(jint.runtime.Arguments.Empty), s, 1, 0);
            aa.DefineOwnProperty("0", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean("", new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), true);
            return aa;
        }
        var r:system.text.regularexpressions.Match = null;
        if (i < 0 || i > length)
        {
            R.Put("lastIndex", 0, true);
            return jint.native.Null.Instance;
        }
        r = R.Match(s, i);
        if (!r.Success)
        {
            R.Put("lastIndex", 0, true);
            return jint.native.Null.Instance;
        }
        var e:Int = r.Index + r.Length;
        if (global)
        {
            R.Put("lastIndex", e, true);
        }
        var n:Int = r.Groups.Count;
        var matchIndex:Int = r.Index;
        var a:jint.native.object.ObjectInstance = InitReturnValueArray(Engine.JArray.Construct(jint.runtime.Arguments.Empty), s, n, matchIndex);
        { //for
            var k:Int = 0;
            while (k < n)
            {
                var group:system.text.regularexpressions.Group = r.Groups.GetValue_Int32(k);
                var value:jint.native.JsValue = group.Success ? group.Value : jint.native.Undefined.Instance;
                a.DefineOwnProperty(Std.string(k), new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(value, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), true);
                k++;
            }
        } //end for
        return a;
    }
    private static function InitReturnValueArray(array:jint.native.object.ObjectInstance, inputValue:String, lengthValue:Int, indexValue:Int):jint.native.object.ObjectInstance
    {
        array.DefineOwnProperty("index", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(indexValue, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), true);
        array.DefineOwnProperty("input", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(inputValue, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), true);
        array.DefineOwnProperty("length", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(lengthValue, new Nullable_Bool(false), new Nullable_Bool(false), new Nullable_Bool(false)), true);
        return array;
    }
}
