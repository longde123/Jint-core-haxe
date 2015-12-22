package jint.runtime;
using StringTools;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
class TypeConverter
{
    public static function ToPrimitive(input:jint.native.JsValue, preferredType:Int = jint.runtime.Types.None):jint.native.JsValue
    {
        if (input.Equals(jint.native.Null.Instance) || input.Equals(jint.native.Undefined.Instance))
        {
            return input;
        }
        if (input.IsPrimitive())
        {
            return input;
        }
        return input.AsObject().DefaultValue(preferredType);
    }
    public static function ToBoolean(o:jint.native.JsValue):Bool
    {
        if (o.IsObject())
        {
            return true;
        }
        if (o.Equals(jint.native.Undefined.Instance) || o.Equals(jint.native.Null.Instance))
        {
            return false;
        }
        if (o.IsBoolean())
        {
            return o.AsBoolean();
        }
        if (o.IsNumber())
        {
            var n:Float = o.AsNumber();
            if (n.Equals_Double(0) || Cs2Hx.IsNaN(n))
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        if (o.IsString())
        {
            var s:String = o.AsString();
            if (system.Cs2Hx.IsNullOrEmpty(s))
            {
                return false;
            }
            else
            {
                return true;
            }
        }
        return true;
    }
    public static function ToNumber(o:jint.native.JsValue):Float
    {
        if (o.IsNumber())
        {
            return o.AsNumber();
        }
        if (o.IsObject())
        {
            var p:jint.native.IPrimitiveInstance = cast(o.AsObject(), jint.native.IPrimitiveInstance);
            if (p != null)
            {
                o = p.PrimitiveValue;
            }
        }
        if (o.Equals(jint.native.Undefined.Instance))
        {
            return Math.NaN;
        }
        if (o.Equals(jint.native.Null.Instance))
        {
            return 0;
        }
        if (o.IsBoolean())
        {
            return o.AsBoolean() ? 1 : 0;
        }
        if (o.IsString())
        {
            var s:String = system.Cs2Hx.Trim(o.AsString());
            if (system.Cs2Hx.IsNullOrEmpty(s))
            {
                return 0;
            }
            if (system.Cs2Hx.Equals_String("+Infinity", s) || system.Cs2Hx.Equals_String("Infinity", s))
            {
				
                return Math.POSITIVE_INFINITY;
            }
            if (system.Cs2Hx.Equals_String("-Infinity", s))
            {
                return Math.NEGATIVE_INFINITY;
            }
            try
            {
                if (!system.Cs2Hx.StartsWith_String_StringComparison(s, "0x", system.StringComparison.OrdinalIgnoreCase))
                {
                    var start:Int = s.charCodeAt(0);
                    if (start != 43 && start != 45 && start != 46 && !system.Cs2Hx.IsDigit(start))
                    {
                        return Math.NaN;
                    }
                    var n:Float = system.Double.Parse_String_NumberStyles_IFormatProvider(s, system.globalization.NumberStyles.AllowDecimalPoint | system.globalization.NumberStyles.AllowLeadingSign | system.globalization.NumberStyles.AllowLeadingWhite | system.globalization.NumberStyles.AllowTrailingWhite | system.globalization.NumberStyles.AllowExponent, system.globalization.CultureInfo.InvariantCulture);
                    if (system.Cs2Hx.StartsWith(s, "-") && n.Equals_Double(0))
                    {
                        return -0.0;
                    }
                    return n;
                }
                var i:Int = Std.parseInt(s.substr(2), system.globalization.NumberStyles.HexNumber, system.globalization.CultureInfo.InvariantCulture);
                return i;
            }
            catch (__ex:system.OverflowException)
            {
                return system.Cs2Hx.StartsWith(s, "-") ? Math.NEGATIVE_INFINITY : Math.POSITIVE_INFINITY;
            }
            catch (__ex:Dynamic)
            {
                return Math.NaN;
            }
        }
        return ToNumber(ToPrimitive(o, jint.runtime.Types.Number));
    }
    public static function ToInteger(o:jint.native.JsValue):Float
    {
        var number:Float = ToNumber(o);
        if (Cs2Hx.IsNaN(number))
        {
            return 0;
        }
        if (number.Equals_Double(0) || Cs2Hx.IsInfinity(number))
        {
            return number;
        }
        return number;
    }
    public static function ToInt32(o:jint.native.JsValue):Int
    {
        return Std.int(ToNumber(o));
    }
    public static function ToUint32(o:jint.native.JsValue):Int
    {
        return Std.int(ToNumber(o));
    }
    public static function ToUint16(o:jint.native.JsValue):Int
    {
        return Std.int(ToNumber(o));
    }
    public static function toString(o:jint.native.JsValue):String
    {
        if (o.IsObject())
        {
            var p:jint.native.IPrimitiveInstance = cast(o.AsObject(), jint.native.IPrimitiveInstance);
            if (p != null)
            {
                o = p.PrimitiveValue;
            }
        }
        if (o.IsString())
        {
            return o.AsString();
        }
        if (o.Equals(jint.native.Undefined.Instance))
        {
            return jint.native.Undefined.Text;
        }
        if (o.Equals(jint.native.Null.Instance))
        {
            return jint.native.Null.Text;
        }
        if (o.IsBoolean())
        {
            return o.AsBoolean() ? "true" : "false";
        }
        if (o.IsNumber())
        {
            return jint.native.number.NumberPrototype.ToNumberString(o.AsNumber());
        }
        return toString(ToPrimitive(o, jint.runtime.Types.String));
    }
    public static function ToObject(engine:jint.Engine, value:jint.native.JsValue):jint.native.object.ObjectInstance
    {
        if (value.IsObject())
        {
            return value.AsObject();
        }
        if (value.Equals(jint.native.Undefined.Instance))
        {
            return throw new jint.runtime.JavaScriptException().Creator(engine.TypeError);
        }
        if (value.Equals(jint.native.Null.Instance))
        {
            return throw new jint.runtime.JavaScriptException().Creator(engine.TypeError);
        }
        if (value.IsBoolean())
        {
            return engine.JBoolean.Construct_Boolean(value.AsBoolean());
        }
        if (value.IsNumber())
        {
            return engine.JNumber.Construct_Double(value.AsNumber());
        }
        if (value.IsString())
        {
            return engine.JString.Construct_String(value.AsString());
        }
        return throw new jint.runtime.JavaScriptException().Creator(engine.TypeError);
    }
    public static function GetPrimitiveType(value:jint.native.JsValue):Int
    {
        if (value.IsObject())
        {
            var primitive:jint.native.IPrimitiveInstance = value.TryCast();
            if (primitive != null)
            {
                return primitive.Type;
            }
            return jint.runtime.Types.Object;
        }
        return value.Type;
    }
    public static function CheckObjectCoercible(engine:jint.Engine, o:jint.native.JsValue):Void
    {
        if (o.Equals(jint.native.Undefined.Instance) || o.Equals(jint.native.Null.Instance))
        {
            throw new jint.runtime.JavaScriptException().Creator(engine.TypeError);
        }
    }
 
    public static function TypeIsNullable(type:system.TypeCS):Bool
    {
        return !type.IsValueType;
    }
    public static function ToString_Double_String_CultureInfo(x:Float, p:String, cultureInfo:Date):String
    {
        return throw new system.NotImplementedException();
    }
    public static function ToString_Int32_String(p1:Int, p2:String):String
    {
        return throw new system.NotImplementedException();
    }
    public static function ToString_Double_String(m:Float, p:String):String
    {
        return throw new system.NotImplementedException();
    }
    public static function ToString_Int32_CultureInfo(p:Int, cultureInfo:Date):String
    {
        return throw new system.NotImplementedException();
    }
    public function new()
    {
    }
}
