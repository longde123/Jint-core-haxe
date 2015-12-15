package jint.native.global;
using StringTools;
import system.*;
import anonymoustypes.*;

class GlobalObject extends jint.native.object.ObjectInstance
{
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    public static function CreateGlobalObject(engine:jint.Engine):jint.native.global.GlobalObject
    {
        var global:jint.native.global.GlobalObject = new jint.native.global.GlobalObject(engine);
        global.Prototype = null;
        global.Extensible = true;
        return global;
    }
    public function Configure():Void
    {
        Prototype = Engine.JObject.PrototypeObject;
        FastAddProperty("Object", Engine.JObject, true, false, true);
        FastAddProperty("Function", Engine.JFunction, true, false, true);
        FastAddProperty("Array", Engine.JArray, true, false, true);
        FastAddProperty("String", Engine.JString, true, false, true);
        FastAddProperty("RegExp", Engine.JRegExp, true, false, true);
        FastAddProperty("Number", Engine.JNumber, true, false, true);
        FastAddProperty("Boolean", Engine.JBoolean, true, false, true);
        FastAddProperty("Date", Engine.JDate, true, false, true);
        FastAddProperty("Math", Engine.JMath, true, false, true);
        FastAddProperty("JSON", Engine.Json, true, false, true);
        FastAddProperty("Error", Engine.Error, true, false, true);
        FastAddProperty("EvalError", Engine.EvalError, true, false, true);
        FastAddProperty("RangeError", Engine.RangeError, true, false, true);
        FastAddProperty("ReferenceError", Engine.ReferenceError, true, false, true);
        FastAddProperty("SyntaxError", Engine.SyntaxError, true, false, true);
        FastAddProperty("TypeError", Engine.TypeError, true, false, true);
        FastAddProperty("URIError", Engine.UriError, true, false, true);
        FastAddProperty("NaN", Math.NaN, false, false, false);
        FastAddProperty("Infinity",  Math.POSITIVE_INFINITY, false, false, false);
        FastAddProperty("undefined", jint.native.Undefined.Instance, false, false, false);
        FastAddProperty("parseInt", new jint.runtime.interop.ClrFunctionInstance(Engine, ParseInt, 2), true, false, true);
        FastAddProperty("parseFloat", new jint.runtime.interop.ClrFunctionInstance(Engine, ParseFloat, 1), true, false, true);
        FastAddProperty("isNaN", new jint.runtime.interop.ClrFunctionInstance(Engine, IsNaN, 1), true, false, true);
        FastAddProperty("isFinite", new jint.runtime.interop.ClrFunctionInstance(Engine, IsFinite, 1), true, false, true);
        FastAddProperty("decodeURI", new jint.runtime.interop.ClrFunctionInstance(Engine, DecodeUri, 1), true, false, true);
        FastAddProperty("decodeURIComponent", new jint.runtime.interop.ClrFunctionInstance(Engine, DecodeUriComponent, 1), true, false, true);
        FastAddProperty("encodeURI", new jint.runtime.interop.ClrFunctionInstance(Engine, EncodeUri, 1), true, false, true);
        FastAddProperty("encodeURIComponent", new jint.runtime.interop.ClrFunctionInstance(Engine, EncodeUriComponent, 1), true, false, true);
    }
    public static function ParseInt(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var inputString:String = jint.runtime.TypeConverter.toString(jint.runtime.Arguments.At(arguments, 0));
        var s:String = system.Cs2Hx.Trim(inputString);
        var sign:Int = 1;
        if (!system.Cs2Hx.IsNullOrEmpty(s))
        {
            if (s.charCodeAt(0) == 45)
            {
                sign = -1;
            }
            if (s.charCodeAt(0) == 45 || s.charCodeAt(0) == 43)
            {
                s = s.substr(1);
            }
        }
        var stripPrefix:Bool = true;
        var radix:Int = arguments.length > 1 ? jint.runtime.TypeConverter.ToInt32(arguments[1]) : 0;
        if (radix == 0)
        {
            if (s.length >= 2 && system.Cs2Hx.StartsWith(s, "0x") || system.Cs2Hx.StartsWith(s, "0X"))
            {
                radix = 16;
            }
            else
            {
                radix = 10;
            }
        }
        else if (radix < 2 || radix > 36)
        {
            return Math.NaN;
        }
        else if (radix != 16)
        {
            stripPrefix = false;
        }
        if (stripPrefix && s.length >= 2 && system.Cs2Hx.StartsWith(s, "0x") || system.Cs2Hx.StartsWith(s, "0X"))
        {
            s = s.substr(2);
        }
        try
        {
            return sign * Parse(s, radix).AsNumber();
        }
        catch (__ex:Dynamic)
        {
            return Math.NaN;
        }
    }
    private static function Parse(number:String, radix:Int):jint.native.JsValue
    {
        if (number == "")
        {
            return Math.NaN;
        }
        var result:Float = 0;
        var pow:Float = 1;
        { //for
            var i:Int = number.length - 1;
            while (i >= 0)
            {
                var index:Float = Math.NaN;
                var digit:Int = number.charCodeAt(i);
                if (digit >= 48 && digit <= 57)
                {
                    index = digit - 48;
                }
                else if (digit >= 97 && digit <= 122)
                {
                    index = digit - 97 + 10;
                }
                else if (digit >= 65 && digit <= 90)
                {
                    index = digit - 65 + 10;
                }
                if (Cs2Hx.IsNaN(index) || index >= radix)
                {
                    return Parse(number.substr(0, i), radix);
                }
                result += index * pow;
                pow = pow * radix;
                i--;
            }
        } //end for
        return result;
    }
    public static function ParseFloat(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var inputString:String = jint.runtime.TypeConverter.toString(jint.runtime.Arguments.At(arguments, 0));
        var trimmedString:String = system.Cs2Hx.TrimStart(inputString);
        var sign:Int = 1;
        if (trimmedString.length > 0)
        {
            if (trimmedString.charCodeAt(0) == 45)
            {
                sign = -1;
                trimmedString = trimmedString.substr(1);
            }
            else if (trimmedString.charCodeAt(0) == 43)
            {
                trimmedString = trimmedString.substr(1);
            }
        }
        if (system.Cs2Hx.StartsWith(trimmedString, "Infinity"))
        {
            return sign * Math.POSITIVE_INFINITY;
        }
        if (system.Cs2Hx.StartsWith(trimmedString, "NaN"))
        {
            return Math.NaN;
        }
        var separator:Int = 0;
        var isNan:Bool = true;
        var number:system.Decimal = 0;
        var i:Int = 0;
        { //for
            while (i < trimmedString.length)
            {
                var c:Int = trimmedString.charCodeAt(i);
                if (c == 46)
                {
                    i++;
                    separator = 46;
                    break;
                }
                if (c == 101 || c == 69)
                {
                    i++;
                    separator = 101;
                    break;
                }
                var digit:Int = c - 48;
                if (digit >= 0 && digit <= 9)
                {
                    isNan = false;
                    number = number * 10 + digit;
                }
                else
                {
                    break;
                }
                i++;
            }
        } //end for
        var pow= 0.1;  //todo  system.Decimal 
        if (separator == 46)
        {
            { //for
                while (i < trimmedString.length)
                {
                    var c:Int = trimmedString.charCodeAt(i);
                    var digit:Int = c - 48;
                    if (digit >= 0 && digit <= 9)
                    {
                        isNan = false;
                        number += digit * pow;
                        pow *= 0.1;
                    }
                    else if (c == 101 || c == 69)
                    {
                        i++;
                        separator = 101;
                        break;
                    }
                    else
                    {
                        break;
                    }
                    i++;
                }
            } //end for
        }
        var exp:Int = 0;
        var expSign:Int = 1;
        if (separator == 101)
        {
            if (i < trimmedString.length)
            {
                if (trimmedString.charCodeAt(i) == 45)
                {
                    expSign = -1;
                    i++;
                }
                else if (trimmedString.charCodeAt(i) == 43)
                {
                    i++;
                }
            }
            { //for
                while (i < trimmedString.length)
                {
                    var c:Int = trimmedString.charCodeAt(i);
                    var digit:Int = c - 48;
                    if (digit >= 0 && digit <= 9)
                    {
                        exp = exp * 10 + digit;
                    }
                    else
                    {
                        break;
                    }
                    i++;
                }
            } //end for
        }
        if (isNan)
        {
            return Math.NaN;
        }
        { //for
            var k:Int = 1;
            while (k <= exp)
            {
                if (expSign > 0)
                {
                    number *= 10;
                }
                else
                {
                    number /= 10;
                }
                k++;
            }
        } //end for
        return jint.native.JsValue.op_Explicit_Float((sign * number));
    }
    public static function IsNaN(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var x:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        return Cs2Hx.IsNaN(x);
    }
    public static function IsFinite(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        if (arguments.length != 1)
        {
            return false;
        }
        var n:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        if (Cs2Hx.IsNaN(n) || Cs2Hx.IsInfinity(n))
        {
            return false;
        }
        return true;
    }
    private static var UriReserved:Array<Int>;
    private static var UriUnescaped:Array<Int>;
    private static inline var HexaMap:String = "0123456789ABCDEF";
    private static function IsValidHexaChar(c:Int):Bool
    {
        return c >= 48 && c <= 57 || c >= 97 && c <= 102 || c >= 65 && c <= 70;
    }
    public function EncodeUri(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var uriString:String = jint.runtime.TypeConverter.toString(jint.runtime.Arguments.At(arguments, 0));
        var unescapedUriSet:Array<Int> = system.linq.Enumerable.ToArray(system.linq.Enumerable.Concat(system.linq.Enumerable.Concat(UriReserved, UriUnescaped), [ 35 ]));
        return Encode(uriString, unescapedUriSet);
    }
    public function EncodeUriComponent(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var uriString:String = jint.runtime.TypeConverter.toString(jint.runtime.Arguments.At(arguments, 0));
        return Encode(uriString, UriUnescaped);
    }
    private function Encode(uriString:String, unescapedUriSet:Array<Int>):String
    {
        var strLen:Int = uriString.length;
        var r:system.text.StringBuilder = new system.text.StringBuilder(uriString.length);
        { //for
            var k:Int = 0;
            while (k < strLen)
            {
                var c:Int = uriString.charCodeAt(k);
                if (system.Array.IndexOf__T(unescapedUriSet, c) != -1)
                {
                    r.Append_Char(c);
                }
                else
                {
                    if (c >= 0xDC00 && c <= 0xDBFF)
                    {
                        return throw new jint.runtime.JavaScriptException().Creator(Engine.UriError);
                    }
                    var v:Int;
                    if (c < 0xD800 || c > 0xDBFF)
                    {
                        v = c;
                    }
                    else
                    {
                        k++;
                        if (k == strLen)
                        {
                            return throw new jint.runtime.JavaScriptException().Creator(Engine.UriError);
                        }
                        var kChar:Int = uriString.charCodeAt(k);
                        if (kChar < 0xDC00 || kChar > 0xDFFF)
                        {
                            return throw new jint.runtime.JavaScriptException().Creator(Engine.UriError);
                        }
                        v = (c - 0xD800) * 0x400 + (kChar - 0xDC00) + 0x10000;
                    }
                    var octets:haxe.io.Bytes;
                    if (v >= 0 && v <= 0x007F)
                    {
                        octets = [ v ];
                    }
                    else if (v <= 0x07FF)
                    {
                        octets = [ (0xC0 | (v >> 6)), (0x80 | (v & 0x3F)) ];
                    }
                    else if (v <= 0xD7FF)
                    {
                        octets = [ (0xE0 | (v >> 12)), (0x80 | ((v >> 6) & 0x3F)), (0x80 | (v & 0x3F)) ];
                    }
                    else if (v <= 0xDFFF)
                    {
                        return throw new jint.runtime.JavaScriptException().Creator(Engine.UriError);
                    }
                    else if (v <= 0xFFFF)
                    {
                        octets = [ (0xE0 | (v >> 12)), (0x80 | ((v >> 6) & 0x3F)), (0x80 | (v & 0x3F)) ];
                    }
                    else
                    {
                        octets = [ (0xF0 | (v >> 18)), (0x80 | (v >> 12 & 0x3F)), (0x80 | (v >> 6 & 0x3F)), (0x80 | (v >> 0 & 0x3F)) ];
                    }
                    { //for
                        var j:Int = 0;
                        while (j < octets.length)
                        {
                            var jOctet:Int = octets.get(j);
                            var x1:Int = HexaMap.charCodeAt(jOctet / 16);
                            var x2:Int = HexaMap.charCodeAt(jOctet % 16);
                            r.Append_Char(37).Append_Char(x1).Append_Char(x2);
                            j++;
                        }
                    } //end for
                }
                k++;
            }
        } //end for
        return r.toString();
    }
    public function DecodeUri(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var uriString:String = jint.runtime.TypeConverter.toString(jint.runtime.Arguments.At(arguments, 0));
        var reservedUriSet:Array<Int> = system.linq.Enumerable.ToArray(system.linq.Enumerable.Concat(UriReserved, [ 35 ]));
        return Decode(uriString, reservedUriSet);
    }
    public function DecodeUriComponent(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var componentString:String = jint.runtime.TypeConverter.toString(jint.runtime.Arguments.At(arguments, 0));
        var reservedUriComponentSet:Array<Int> = [  ];
        return Decode(componentString, reservedUriComponentSet);
    }
    public function Decode(uriString:String, reservedSet:Array<Int>):String
    {
        var strLen:Int = uriString.length;
        var R:system.text.StringBuilder = new system.text.StringBuilder(strLen);
        { //for
            var k:Int = 0;
            while (k < strLen)
            {
                var C:Int = uriString.charCodeAt(k);
                if (C != 37)
                {
                    R.Append_Char(C);
                }
                else
                {
                    var start:Int = k;
                    if (k + 2 >= strLen)
                    {
                        return throw new jint.runtime.JavaScriptException().Creator(Engine.UriError);
                    }
                    if (!IsValidHexaChar(uriString.charCodeAt(k + 1)) || !IsValidHexaChar(uriString.charCodeAt(k + 2)))
                    {
                        return throw new jint.runtime.JavaScriptException().Creator(Engine.UriError);
                    }
                    var B:Int = system.Convert.ToByte_String_Int32(Cs2Hx.CharToString(uriString.charCodeAt(k + 1)) + Cs2Hx.CharToString(uriString.charCodeAt(k + 2)), 16);
                    k += 2;
                    if ((B & 0x80) == 0)
                    {
                        C = B;
                        if (system.Array.IndexOf__T(reservedSet, C) == -1)
                        {
                            R.Append_Char(C);
                        }
                        else
                        {
                            R.Append(uriString.substr(start, k - start + 1));
                        }
                    }
                    else
                    {
                        var n:Int = 0;
                        { //for
                            while (((B << n) & 0x80) != 0)
                            {
                                n++;
                            }
                        } //end for
                        if (n == 1 || n > 4)
                        {
                            return throw new jint.runtime.JavaScriptException().Creator(Engine.UriError);
                        }
                        var Octets:haxe.io.Bytes = haxe.io.Bytes.alloc(n);
                        Octets.set(0, B);
                        if (k + (3 * (n - 1)) >= strLen)
                        {
                            return throw new jint.runtime.JavaScriptException().Creator(Engine.UriError);
                        }
                        { //for
                            var j:Int = 1;
                            while (j < n)
                            {
                                k++;
                                if (uriString.charCodeAt(k) != 37)
                                {
                                    return throw new jint.runtime.JavaScriptException().Creator(Engine.UriError);
                                }
                                if (!IsValidHexaChar(uriString.charCodeAt(k + 1)) || !IsValidHexaChar(uriString.charCodeAt(k + 2)))
                                {
                                    return throw new jint.runtime.JavaScriptException().Creator(Engine.UriError);
                                }
                                B = system.Convert.ToByte_String_Int32(Cs2Hx.CharToString(uriString.charCodeAt(k + 1)) + Cs2Hx.CharToString(uriString.charCodeAt(k + 2)), 16);
                                if ((B & 0xC0) != 0x80)
                                {
                                    return throw new jint.runtime.JavaScriptException().Creator(Engine.UriError);
                                }
                                k += 2;
                                Octets.set(j, B);
                                j++;
                            }
                        } //end for
                        R.Append(system.text.Encoding.UTF8.GetString__Int32_Int32(Octets, 0, Octets.length));
                    }
                }
                k++;
            }
        } //end for
        return R.toString();
    }
    public static function cctor():Void
    {
        UriReserved = [ 59, 47, 63, 58, 64, 38, 61, 43, 36, 44 ];
        UriUnescaped = [ 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 45, 95, 46, 33, 126, 42, 39, 40, 41 ];
    }
}
