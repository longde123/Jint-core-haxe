package jint.native.date;
using StringTools;
import system.*;
import anonymoustypes.*;

class DateConstructor extends jint.native.functions.FunctionInstance implements jint.native.IConstructor
{
    public static var Epoch:system.DateTime;
    public function new(engine:jint.Engine)
    {
        super(engine, null, null, false);
    }
    public static function CreateDateConstructor(engine:jint.Engine):jint.native.date.DateConstructor
    {
        var obj:jint.native.date.DateConstructor = new jint.native.date.DateConstructor(engine);
        obj.Extensible = true;
        obj.Prototype = engine.Function.PrototypeObject;
        obj.PrototypeObject = jint.native.date.DatePrototype.CreatePrototypeObject(engine, obj);
        obj.FastAddProperty("length", 7, false, false, false);
        obj.FastAddProperty("prototype", obj.PrototypeObject, false, false, false);
        return obj;
    }
    public function Configure():Void
    {
        FastAddProperty("parse", new jint.runtime.interop.ClrFunctionInstance(Engine, Parse, 1), true, false, true);
        FastAddProperty("UTC", new jint.runtime.interop.ClrFunctionInstance(Engine, Utc, 7), true, false, true);
        FastAddProperty("now", new jint.runtime.interop.ClrFunctionInstance(Engine, Now, 0), true, false, true);
    }
    private function Parse(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var result:CsRef<system.DateTime> = new CsRef<system.DateTime>(null);
        var date:String = jint.runtime.TypeConverter.toString(jint.runtime.Arguments.At(arguments, 0));
        if (!system.DateTime.TryParseExact_String__IFormatProvider_DateTimeStyles_DateTime(date, [ "yyyy-MM-ddTHH:mm:ss.FFF", "yyyy-MM-ddTHH:mm:ss", "yyyy-MM-ddTHH:mm", "yyyy-MM-dd", "yyyy-MM", "yyyy" ], system.globalization.CultureInfo.InvariantCulture, system.globalization.DateTimeStyles.AdjustToUniversal | system.globalization.DateTimeStyles.AssumeUniversal, result))
        {
            if (!system.DateTime.TryParseExact_String__IFormatProvider_DateTimeStyles_DateTime(date, [ "ddd MMM dd yyyy HH:mm:ss 'GMT'K", "ddd MMM dd yyyy", "HH:mm:ss 'GMT'K", "yyyy-M-dTH:m:s.FFFK", "yyyy/M/dTH:m:s.FFFK", "yyyy-M-dTH:m:sK", "yyyy/M/dTH:m:sK", "yyyy-M-dTH:mK", "yyyy/M/dTH:mK", "yyyy-M-d H:m:s.FFFK", "yyyy/M/d H:m:s.FFFK", "yyyy-M-d H:m:sK", "yyyy/M/d H:m:sK", "yyyy-M-d H:mK", "yyyy/M/d H:mK", "yyyy-M-dK", "yyyy/M/dK", "yyyy-MK", "yyyy/MK", "yyyyK", "THH:mm:ss.FFFK", "THH:mm:ssK", "THH:mmK", "THHK" ], system.globalization.CultureInfo.InvariantCulture, system.globalization.DateTimeStyles.AdjustToUniversal, result))
            {
                if (!system.DateTime.TryParse_String_IFormatProvider_DateTimeStyles_DateTime(date, Engine.Options.GetCulture(), system.globalization.DateTimeStyles.AdjustToUniversal, result))
                {
                    if (!system.DateTime.TryParse_String_IFormatProvider_DateTimeStyles_DateTime(date, system.globalization.CultureInfo.InvariantCulture, system.globalization.DateTimeStyles.AdjustToUniversal, result))
                    {
                        return Math.NaN;
                    }
                }
            }
        }
        return FromDateTime(result.Value);
    }
    private function Utc(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return TimeClip(ConstructTimeValue(arguments, true));
    }
    private function Now(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return system.MathCS.Floor_Double((system.DateTime.UtcNow - Epoch).TotalMilliseconds);
    }
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return PrototypeObject.toString(Construct(jint.runtime.Arguments.Empty), jint.runtime.Arguments.Empty);
    }
    public function Construct(arguments:Array<jint.native.JsValue>):jint.native.object.ObjectInstance
    {
        if (arguments.length == 0)
        {
            return Construct_DateTime(system.DateTime.UtcNow);
        }
        else if (arguments.length == 1)
        {
            var v:jint.native.JsValue = jint.runtime.TypeConverter.ToPrimitive(arguments[0]);
            if (v.IsString())
            {
                return Construct_Double(Parse(jint.native.Undefined.Instance, jint.runtime.Arguments.From([ v ])).AsNumber());
            }
            return Construct_Double(jint.runtime.TypeConverter.ToNumber(v));
        }
        else
        {
            return Construct_Double(ConstructTimeValue(arguments, false));
        }
    }
    private function ConstructTimeValue(arguments:Array<jint.native.JsValue>, useUtc:Bool):Float
    {
        if (arguments.length < 2)
        {
            return throw new system.ArgumentOutOfRangeException("arguments", "There must be at least two arguments.");
        }
        var y:Float = jint.runtime.TypeConverter.ToNumber(arguments[0]);
        var m:Int = Std.int(jint.runtime.TypeConverter.ToInteger(arguments[1]));
        var dt:Int = arguments.length > 2 ? Std.int(jint.runtime.TypeConverter.ToInteger(arguments[2])) : 1;
        var h:Int = arguments.length > 3 ? Std.int(jint.runtime.TypeConverter.ToInteger(arguments[3])) : 0;
        var min:Int = arguments.length > 4 ? Std.int(jint.runtime.TypeConverter.ToInteger(arguments[4])) : 0;
        var s:Int = arguments.length > 5 ? Std.int(jint.runtime.TypeConverter.ToInteger(arguments[5])) : 0;
        var milli:Int = arguments.length > 6 ? Std.int(jint.runtime.TypeConverter.ToInteger(arguments[6])) : 0;
        { //for
            var i:Int = 2;
            while (i < arguments.length)
            {
                if (Cs2Hx.IsNaN(jint.runtime.TypeConverter.ToNumber(arguments[i])))
                {
                    return Math.NaN;
                }
                i++;
            }
        } //end for
        if ((!Cs2Hx.IsNaN(y)) && (0 <= jint.runtime.TypeConverter.ToInteger(y)) && (jint.runtime.TypeConverter.ToInteger(y) <= 99))
        {
            y += 1900;
        }
        var finalDate:Float = jint.native.date.DatePrototype.MakeDate(jint.native.date.DatePrototype.MakeDay(y, m, dt), jint.native.date.DatePrototype.MakeTime(h, min, s, milli));
        return useUtc ? finalDate : PrototypeObject.Utc(finalDate);
    }
    public var PrototypeObject:jint.native.date.DatePrototype;
    public function Construct_DateTimeOffset(value:system.DateTimeOffset):jint.native.date.DateInstance
    {
        return Construct_DateTime(value.UtcDateTime);
    }
    public function Construct_DateTime(value:system.DateTime):jint.native.date.DateInstance
    {
        var instance:jint.native.date.DateInstance = new jint.native.date.DateInstance(Engine);
        return instance;
    }
    public function Construct_Double(time:Float):jint.native.date.DateInstance
    {
        var instance:jint.native.date.DateInstance = new jint.native.date.DateInstance(Engine);
        return instance;
    }
    public static function TimeClip(time:Float):Float
    {
        if (Cs2Hx.IsInfinity(time) || Cs2Hx.IsNaN(time))
        {
            return Math.NaN;
        }
        if (system.MathCS.Abs_Double(time) > 8640000000000000)
        {
            return Math.NaN;
        }
        return jint.runtime.TypeConverter.ToInteger(time);
    }
    public function FromDateTime(dt:system.DateTime):Float
    {
        var convertToUtcAfter:Bool = (dt.Kind == system.DateTimeKind.Unspecified);
        var dateAsUtc:system.DateTime = dt.Kind == system.DateTimeKind.Local ? dt.ToUniversalTime() : system.DateTime.SpecifyKind(dt, system.DateTimeKind.Utc);
        var result:Float = (dateAsUtc - Epoch).TotalMilliseconds;
        if (convertToUtcAfter)
        {
            result = PrototypeObject.Utc(result);
        }
        return system.MathCS.Floor_Double(result);
    }
    public static function cctor():Void
    {
        Epoch = new system.DateTime(1970, 1, 1, 0, 0, 0, system.DateTimeKind.Utc);
    }
}
