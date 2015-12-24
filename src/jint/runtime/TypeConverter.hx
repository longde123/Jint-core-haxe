package jint.runtime;
using StringTools;
import jint.native.AbstractJsValue;
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
            if (n==(0) || Cs2Hx.IsNaN(n))
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
				//(!s.StartsWith("0x", StringComparison.OrdinalIgnoreCase))
                if ( !s.toLowerCase().startsWith("0x"))
                {
                    var start:Int = s.charCodeAt(0);
                    if (start != 43 && start != 45 && start != 46 && !system.Cs2Hx.IsDigit(start))
                    {
                        return Math.NaN;
                    }
					/*
                        double n = Double.Parse(s,
                            NumberStyles.AllowDecimalPoint | NumberStyles.AllowLeadingSign |
                            NumberStyles.AllowLeadingWhite | NumberStyles.AllowTrailingWhite |
                            NumberStyles.AllowExponent, CultureInfo.InvariantCulture);
							*/
                    var n:Float = Std.parseFloat(s);
                    if (system.Cs2Hx.StartsWith(s, "-") && n==(0))
                    {
                        return -0.0;
                    }
                    return n;
                }
				//  int i = int.Parse(s.Substring(2), NumberStyles.HexNumber, CultureInfo.InvariantCulture);
                var i:Int = Std.parseInt(s.substr(2) );
                return i;
            }
            catch (__ex:Dynamic)
            {
                return s.startsWith("-") ? Math.NEGATIVE_INFINITY : Math.POSITIVE_INFINITY;
            }
           
            return Math.NaN;
          
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
        if (number==(0) || Cs2Hx.IsInfinity(number))
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
            var primitive:jint.native.IPrimitiveInstance = value.TryCast(jint.native.IPrimitiveInstance);
            if (primitive != null)
            {
                return primitive.JType;
            }
            return jint.runtime.Types.Object;
        } 
        return value.GetJType();
    }
    public static function CheckObjectCoercible(engine:jint.Engine, o:jint.native.JsValue):Void
    {
        if (o.Equals(jint.native.Undefined.Instance) || o.Equals(jint.native.Null.Instance))
        {
            throw new jint.runtime.JavaScriptException().Creator(engine.TypeError);
        }
    }
 
    public static function TypeIsNullable(type:Class<Dynamic>):Bool
    { 
		//todo
        return type==null;
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
