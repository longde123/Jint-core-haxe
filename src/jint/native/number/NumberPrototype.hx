package jint.native.number;
using StringTools;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
class NumberPrototype extends jint.native.number.NumberInstance
{
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    public static function CreatePrototypeObject(engine:jint.Engine, numberConstructor:jint.native.number.NumberConstructor):jint.native.number.NumberPrototype
    {
        var obj:jint.native.number.NumberPrototype = new jint.native.number.NumberPrototype(engine);
        obj.Prototype = engine.JObject.PrototypeObject;
        obj.PrimitiveValue = 0;
        obj.Extensible = true;
        obj.FastAddProperty("constructor", numberConstructor, true, false, true);
        return obj;
    }
    public function Configure():Void
    {
        FastAddProperty("toString", new jint.runtime.interop.ClrFunctionInstance(Engine, ToNumberString_JsValue_), true, false, true);
        FastAddProperty("toLocaleString", new jint.runtime.interop.ClrFunctionInstance(Engine, ToLocaleString), true, false, true);
        FastAddProperty("valueOf", new jint.runtime.interop.ClrFunctionInstance(Engine, ValueOf), true, false, true);
        FastAddProperty("toFixed", new jint.runtime.interop.ClrFunctionInstance(Engine, ToFixed, 1), true, false, true);
        FastAddProperty("toExponential", new jint.runtime.interop.ClrFunctionInstance(Engine, ToExponential), true, false, true);
        FastAddProperty("toPrecision", new jint.runtime.interop.ClrFunctionInstance(Engine, ToPrecision), true, false, true);
    }
    private function ToLocaleString(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        if (!thisObject.IsNumber() && (thisObject.TryCast(jint.native.number.NumberInstance) == null))
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        var m:Float = jint.runtime.TypeConverter.ToNumber(thisObject);
        if (Cs2Hx.IsNaN(m))
        {
            return "NaN";
        }
        if (m==(0))
        {
            return "0";
        }
        if (m < 0)
        {
            return "-" + ToLocaleString(-m, arguments);
        }
        if (Cs2Hx.IsPositiveInfinity(m) || m >= 3.4028235e+38)
        {
            return "Infinity";
        }
        if (Cs2Hx.IsNegativeInfinity(m) || m <= -3.4028235e+38)
        {
            return "-Infinity";
        }
        return jint.runtime.TypeConverter.ToString_Double_String_CultureInfo(m, "n", Engine.Options.GetCulture());
    }
    private function ValueOf(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var number:jint.native.number.NumberInstance = thisObj.TryCast(jint.native.number.NumberInstance);
        if (number == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        return number.PrimitiveValue;
    }
    private static inline var Ten21:Float = 1e21;
    private function ToFixed(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var f:Int = Std.int(jint.runtime.TypeConverter.ToInteger(jint.runtime.Arguments.At__Int32_JsValue(arguments, 0, 0)));
        if (f < 0 || f > 20)
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.RangeError, "fractionDigits argument must be between 0 and 20");
        }
        var x:Float = jint.runtime.TypeConverter.ToNumber(thisObj);
        if (Cs2Hx.IsNaN(x))
        {
            return "NaN";
        }
        if (x >= Ten21)
        {
            return ToNumberString(x);
        }
        return jint.runtime.TypeConverter.ToString_Double_String(x, "f" + f);
    }
    private function ToExponential(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var f:Int = Std.int(jint.runtime.TypeConverter.ToInteger(jint.runtime.Arguments.At__Int32_JsValue(arguments, 0, 16)));
        if (f < 0 || f > 20)
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.RangeError, "fractionDigits argument must be between 0 and 20");
        }
        var x:Float = jint.runtime.TypeConverter.ToNumber(thisObj);
        if (Cs2Hx.IsNaN(x))
        {
            return "NaN";
         }
       //todo var format:String =("#."+ new String(48, f)+"e+0");
        return  x ;
    }
    private function ToPrecision(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var x:Float = jint.runtime.TypeConverter.ToNumber(thisObj);
        if (jint.runtime.Arguments.At(arguments, 0).Equals(jint.native.Undefined.Instance))
        {
            return jint.runtime.TypeConverter.toString(x);
        }
        var p:Float = jint.runtime.TypeConverter.ToInteger(jint.runtime.Arguments.At(arguments, 0));
        if (Cs2Hx.IsInfinity(x) || Cs2Hx.IsNaN(x))
        {
            return jint.runtime.TypeConverter.toString(x);
        }
        if (p < 1 || p > 21)
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.RangeError, "precision must be between 1 and 21");
        }
        var str:String = jint.runtime.TypeConverter.ToString_Double_String(x, "e23" );
        var decimals:Int = 0;//todo system.Cs2Hx.IndexOfAny(str, [ 46, 101 ]);
        decimals = decimals == -1 ? str.length : decimals;
        p -= decimals;
        p = p < 1 ? 1 : p;
        return jint.runtime.TypeConverter.ToString_Double_String(x, "f" + p);
    }
    private function ToNumberString_JsValue_(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        if (!thisObject.IsNumber() && (thisObject.TryCast(jint.native.number.NumberInstance) == null))
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        var radix:Int = jint.runtime.Arguments.At(arguments, 0).Equals(jint.native.JsValue.Undefined) ? 10 : Std.int(jint.runtime.TypeConverter.ToInteger(jint.runtime.Arguments.At(arguments, 0)));
        if (radix < 2 || radix > 36)
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.RangeError, "radix must be between 2 and 36");
        }
        var x:Float = jint.runtime.TypeConverter.ToNumber(thisObject);
        if (Cs2Hx.IsNaN(x))
        {
            return "NaN";
        }
        if (x==(0))
        {
            return "0";
        }
        if (Cs2Hx.IsPositiveInfinity(x) || x >= 3.4028235e+38)
        {
            return "Infinity";
        }
        if (x < 0)
        {
            return "-" + ToNumberString_JsValue_(-x, arguments);
        }
        if (radix == 10)
        {
            return ToNumberString(x);
        }
        var integer:Float = x;
        var fraction:Float = x - integer;
        var result:String = ToBase(integer, radix);
        if (fraction!=(0))
        {
            result += "." + ToFractionBase(fraction, radix);
        }
        return result;
    }
    public static function ToBase(n:Float, radix:Int):String
    {
        var digits:String = "0123456789abcdefghijklmnopqrstuvwxyz";
        if (n == 0)
        {
            return "0";
        }
        var result:system.text.StringBuilder = new system.text.StringBuilder();
        while (n > 0)
        {
            var digit:Int = Std.int(n % radix);
            n = n / radix;
            result.Insert_Int32_String(0, Cs2Hx.CharToString(digits.charCodeAt(digit)));
        }
        return result.toString();
    }
    public static function ToFractionBase(n:Float, radix:Int):String
    {
        var digits:String = "0123456789abcdefghijklmnopqrstuvwxyz";
        if (n==(0))
        {
            return "0";
        }
        var result:system.text.StringBuilder = new system.text.StringBuilder();
        while (n > 0 && result.Length < 50)
        {
            var c:Float = n * radix;
            var d:Int = Std.int(c);
            n = c - d;
            result.Append(Cs2Hx.CharToString(digits.charCodeAt(d)));
        }
        return result.toString();
    }
    public static function ToNumberString(m:Float):String
    {
        if (Cs2Hx.IsNaN(m))
        {
            return "NaN";
        }
        if (m==(0))
        {
            return "0";
        }
        if (Cs2Hx.IsPositiveInfinity(m) || m >= 3.4028235e+38)
        {
            return "Infinity";
        }
        if (m < 0)
        {
            return "-" + ToNumberString(-m);
        }
        //todo v8 Fast Dtoa
       
        var s:String = null;
        var rFormat:String = jint.runtime.TypeConverter.ToString_Double_String(m, "r");
        if (rFormat.indexOf("e", system.StringComparison.OrdinalIgnoreCase) == -1)
        {
            s = system.Cs2Hx.TrimEnd(system.Cs2Hx.TrimStart(rFormat.replace(".", ""), [ 48 ]), [ 48 ]);
        }
        var format:String = "0.00000000000000000e0";
        var parts:Array<String> = system.Cs2Hx.Split(jint.runtime.TypeConverter.ToString_Double_String_CultureInfo(m, format, null), [ 101 ]);
        if (s == null)
        {
            s = system.Cs2Hx.TrimEnd(parts[0], [ 48 ]).replace(".", "");
        }
        var n:Int = Std.parseInt(parts[1]) + 1;
        var k:Int = s.length;
        if (k <= n && n <= 21)
        {
            return s; //todo + new String(48, n - k);
        }
        if (0 < n && n <= 21)
        {
            return s.substr(0, n) + Cs2Hx.CharToString(46) + s.substr(n);
        }
        if (-6 < n && n <= 0)
        {
            return "0.";//todo  + new String(48, -n) + s;
        }
        if (k == 1)
        {
            return s + "e" + (n - 1 < 0 ? "-" : "+") + system.MathCS.Abs_Int32(n - 1);
        }
        return s.substr(0, 1) + "." + s.substr(1) + "e" + (n - 1 < 0 ? "-" : "+") + system.MathCS.Abs_Int32(n - 1);
    }
}
