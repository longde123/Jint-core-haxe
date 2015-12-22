package jint.native.date;
using StringTools;
import system.*;
import anonymoustypes.*;

class DatePrototype extends jint.native.date.DateInstance
{
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    public static function CreatePrototypeObject(engine:jint.Engine, dateConstructor:jint.native.date.DateConstructor):jint.native.date.DatePrototype
    {
        var obj:jint.native.date.DatePrototype = new jint.native.date.DatePrototype(engine);
        obj.FastAddProperty("constructor", dateConstructor, true, false, true);
        return obj;
    }
    public function Configure():Void
    {
        FastAddProperty("toString", new jint.runtime.interop.ClrFunctionInstance(Engine, ToString, 0), true, false, true);
        FastAddProperty("toDateString", new jint.runtime.interop.ClrFunctionInstance(Engine, ToDateString, 0), true, false, true);
        FastAddProperty("toTimeString", new jint.runtime.interop.ClrFunctionInstance(Engine, ToTimeString, 0), true, false, true);
        FastAddProperty("toLocaleString", new jint.runtime.interop.ClrFunctionInstance(Engine, ToLocaleString, 0), true, false, true);
        FastAddProperty("toLocaleDateString", new jint.runtime.interop.ClrFunctionInstance(Engine, ToLocaleDateString, 0), true, false, true);
        FastAddProperty("toLocaleTimeString", new jint.runtime.interop.ClrFunctionInstance(Engine, ToLocaleTimeString, 0), true, false, true);
        FastAddProperty("valueOf", new jint.runtime.interop.ClrFunctionInstance(Engine, ValueOf, 0), true, false, true);
        FastAddProperty("getTime", new jint.runtime.interop.ClrFunctionInstance(Engine, GetTime, 0), true, false, true);
        FastAddProperty("getFullYear", new jint.runtime.interop.ClrFunctionInstance(Engine, GetFullYear, 0), true, false, true);
        FastAddProperty("getYear", new jint.runtime.interop.ClrFunctionInstance(Engine, GetYear, 0), true, false, true);
        FastAddProperty("getUTCFullYear", new jint.runtime.interop.ClrFunctionInstance(Engine, GetUTCFullYear, 0), true, false, true);
        FastAddProperty("getMonth", new jint.runtime.interop.ClrFunctionInstance(Engine, GetMonth, 0), true, false, true);
        FastAddProperty("getUTCMonth", new jint.runtime.interop.ClrFunctionInstance(Engine, GetUTCMonth, 0), true, false, true);
        FastAddProperty("getDate", new jint.runtime.interop.ClrFunctionInstance(Engine, GetDate, 0), true, false, true);
        FastAddProperty("getUTCDate", new jint.runtime.interop.ClrFunctionInstance(Engine, GetUTCDate, 0), true, false, true);
        FastAddProperty("getDay", new jint.runtime.interop.ClrFunctionInstance(Engine, GetDay, 0), true, false, true);
        FastAddProperty("getUTCDay", new jint.runtime.interop.ClrFunctionInstance(Engine, GetUTCDay, 0), true, false, true);
        FastAddProperty("getHours", new jint.runtime.interop.ClrFunctionInstance(Engine, GetHours, 0), true, false, true);
        FastAddProperty("getUTCHours", new jint.runtime.interop.ClrFunctionInstance(Engine, GetUTCHours, 0), true, false, true);
        FastAddProperty("getMinutes", new jint.runtime.interop.ClrFunctionInstance(Engine, GetMinutes, 0), true, false, true);
        FastAddProperty("getUTCMinutes", new jint.runtime.interop.ClrFunctionInstance(Engine, GetUTCMinutes, 0), true, false, true);
        FastAddProperty("getSeconds", new jint.runtime.interop.ClrFunctionInstance(Engine, GetSeconds, 0), true, false, true);
        FastAddProperty("getUTCSeconds", new jint.runtime.interop.ClrFunctionInstance(Engine, GetUTCSeconds, 0), true, false, true);
        FastAddProperty("getMilliseconds", new jint.runtime.interop.ClrFunctionInstance(Engine, GetMilliseconds, 0), true, false, true);
        FastAddProperty("getUTCMilliseconds", new jint.runtime.interop.ClrFunctionInstance(Engine, GetUTCMilliseconds, 0), true, false, true);
        FastAddProperty("getTimezoneOffset", new jint.runtime.interop.ClrFunctionInstance(Engine, GetTimezoneOffset, 0), true, false, true);
        FastAddProperty("setTime", new jint.runtime.interop.ClrFunctionInstance(Engine, SetTime, 1), true, false, true);
        FastAddProperty("setMilliseconds", new jint.runtime.interop.ClrFunctionInstance(Engine, SetMilliseconds, 1), true, false, true);
        FastAddProperty("setUTCMilliseconds", new jint.runtime.interop.ClrFunctionInstance(Engine, SetUTCMilliseconds, 1), true, false, true);
        FastAddProperty("setSeconds", new jint.runtime.interop.ClrFunctionInstance(Engine, SetSeconds, 2), true, false, true);
        FastAddProperty("setUTCSeconds", new jint.runtime.interop.ClrFunctionInstance(Engine, SetUTCSeconds, 2), true, false, true);
        FastAddProperty("setMinutes", new jint.runtime.interop.ClrFunctionInstance(Engine, SetMinutes, 3), true, false, true);
        FastAddProperty("setUTCMinutes", new jint.runtime.interop.ClrFunctionInstance(Engine, SetUTCMinutes, 3), true, false, true);
        FastAddProperty("setHours", new jint.runtime.interop.ClrFunctionInstance(Engine, SetHours, 4), true, false, true);
        FastAddProperty("setUTCHours", new jint.runtime.interop.ClrFunctionInstance(Engine, SetUTCHours, 4), true, false, true);
        FastAddProperty("setDate", new jint.runtime.interop.ClrFunctionInstance(Engine, SetDate, 1), true, false, true);
        FastAddProperty("setUTCDate", new jint.runtime.interop.ClrFunctionInstance(Engine, SetUTCDate, 1), true, false, true);
        FastAddProperty("setMonth", new jint.runtime.interop.ClrFunctionInstance(Engine, SetMonth, 2), true, false, true);
        FastAddProperty("setUTCMonth", new jint.runtime.interop.ClrFunctionInstance(Engine, SetUTCMonth, 2), true, false, true);
        FastAddProperty("setFullYear", new jint.runtime.interop.ClrFunctionInstance(Engine, SetFullYear, 3), true, false, true);
        FastAddProperty("setYear", new jint.runtime.interop.ClrFunctionInstance(Engine, SetYear, 1), true, false, true);
        FastAddProperty("setUTCFullYear", new jint.runtime.interop.ClrFunctionInstance(Engine, SetUTCFullYear, 3), true, false, true);
        FastAddProperty("toUTCString", new jint.runtime.interop.ClrFunctionInstance(Engine, ToUtcString, 0), true, false, true);
        FastAddProperty("toISOString", new jint.runtime.interop.ClrFunctionInstance(Engine, ToISOString, 0), true, false, true);
        FastAddProperty("toJSON", new jint.runtime.interop.ClrFunctionInstance(Engine, ToJSON, 1), true, false, true);
    }
    private function ValueOf(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return EnsureDateInstance(thisObj).PrimitiveValue;
    }
    private function EnsureDateInstance(thisObj:jint.native.JsValue):jint.native.date.DateInstance
    {
        return thisObj.TryCast(function (value:jint.native.JsValue):Void
        {
            throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "Invalid Date");
        }
        );
    }
    override public function toString(thisObj:jint.native.JsValue, arg2:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return ToLocalTime(EnsureDateInstance(thisObj).ToDateTime()).toString("ddd MMM dd yyyy HH:mm:ss 'GMT'K", system.globalization.CultureInfo.InvariantCulture);
    }
    private function ToDateString(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return ToLocalTime(EnsureDateInstance(thisObj).ToDateTime()).toString("ddd MMM dd yyyy", system.globalization.CultureInfo.InvariantCulture);
    }
    private function ToTimeString(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return ToLocalTime(EnsureDateInstance(thisObj).ToDateTime()).toString("HH:mm:ss 'GMT'K", system.globalization.CultureInfo.InvariantCulture);
    }
    private function ToLocaleString(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return ToLocalTime(EnsureDateInstance(thisObj).ToDateTime()).toString("F", Engine.Options.GetCulture());
    }
    private function ToLocaleDateString(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return ToLocalTime(EnsureDateInstance(thisObj).ToDateTime()).toString("D", Engine.Options.GetCulture());
    }
    private function ToLocaleTimeString(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return ToLocalTime(EnsureDateInstance(thisObj).ToDateTime()).toString("T", Engine.Options.GetCulture());
    }
    private function GetTime(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        if (Cs2Hx.IsNaN(EnsureDateInstance(thisObj).PrimitiveValue))
        {
            return Math.NaN;
        }
        return EnsureDateInstance(thisObj).PrimitiveValue;
    }
    private function GetFullYear(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        if (Cs2Hx.IsNaN(t))
        {
            return Math.NaN;
        }
        return YearFromTime(LocalTime(t));
    }
    private function GetYear(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        if (Cs2Hx.IsNaN(t))
        {
            return Math.NaN;
        }
        return YearFromTime(LocalTime(t)) - 1900;
    }
    private function GetUTCFullYear(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        if (Cs2Hx.IsNaN(t))
        {
            return Math.NaN;
        }
        return YearFromTime(t);
    }
    private function GetMonth(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        if (Cs2Hx.IsNaN(t))
        {
            return Math.NaN;
        }
        return MonthFromTime(LocalTime(t));
    }
    private function GetUTCMonth(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        if (Cs2Hx.IsNaN(t))
        {
            return Math.NaN;
        }
        return MonthFromTime(t);
    }
    private function GetDate(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        if (Cs2Hx.IsNaN(t))
        {
            return Math.NaN;
        }
        return DateFromTime(LocalTime(t));
    }
    private function GetUTCDate(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        if (Cs2Hx.IsNaN(t))
        {
            return Math.NaN;
        }
        return DateFromTime(t);
    }
    private function GetDay(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        if (Cs2Hx.IsNaN(t))
        {
            return Math.NaN;
        }
        return WeekDay(LocalTime(t));
    }
    private function GetUTCDay(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        if (Cs2Hx.IsNaN(t))
        {
            return Math.NaN;
        }
        return WeekDay(t);
    }
    private function GetHours(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        if (Cs2Hx.IsNaN(t))
        {
            return Math.NaN;
        }
        return HourFromTime(LocalTime(t));
    }
    private function GetUTCHours(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        if (Cs2Hx.IsNaN(t))
        {
            return Math.NaN;
        }
        return HourFromTime(t);
    }
    private function GetMinutes(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        if (Cs2Hx.IsNaN(t))
        {
            return Math.NaN;
        }
        return MinFromTime(LocalTime(t));
    }
    private function GetUTCMinutes(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        if (Cs2Hx.IsNaN(t))
        {
            return Math.NaN;
        }
        return MinFromTime(t);
    }
    private function GetSeconds(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = thisObj.TryCast().PrimitiveValue;
        if (Cs2Hx.IsNaN(t))
        {
            return Math.NaN;
        }
        return SecFromTime(LocalTime(t));
    }
    private function GetUTCSeconds(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        if (Cs2Hx.IsNaN(t))
        {
            return Math.NaN;
        }
        return SecFromTime(t);
    }
    private function GetMilliseconds(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        if (Cs2Hx.IsNaN(t))
        {
            return Math.NaN;
        }
        return MsFromTime(LocalTime(t));
    }
    private function GetUTCMilliseconds(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        if (Cs2Hx.IsNaN(t))
        {
            return Math.NaN;
        }
        return MsFromTime(t);
    }
    private function GetTimezoneOffset(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        if (Cs2Hx.IsNaN(t))
        {
            return Math.NaN;
        }
        return (t - LocalTime(t)) / MsPerMinute;
    }
    private function SetTime(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return EnsureDateInstance(thisObj).PrimitiveValue = TimeClip(jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0)));
    }
    private function SetMilliseconds(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = LocalTime(EnsureDateInstance(thisObj).PrimitiveValue);
        var time:Float = MakeTime(HourFromTime(t), MinFromTime(t), SecFromTime(t), jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0)));
        var u:Float = TimeClip(Utc(MakeDate(Day(t), time)));
        thisObj.As().PrimitiveValue = u;
        return u;
    }
    private function SetUTCMilliseconds(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        var time:Float = MakeTime(HourFromTime(t), MinFromTime(t), SecFromTime(t), jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0)));
        var u:Float = TimeClip(MakeDate(Day(t), time));
        thisObj.As().PrimitiveValue = u;
        return u;
    }
    private function SetSeconds(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = LocalTime(EnsureDateInstance(thisObj).PrimitiveValue);
        var s:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        var milli:Float = arguments.length <= 1 ? MsFromTime(t) : jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 1));
        var date:Float = MakeDate(Day(t), MakeTime(HourFromTime(t), MinFromTime(t), s, milli));
        var u:Float = TimeClip(Utc(date));
        thisObj.As().PrimitiveValue = u;
        return u;
    }
    private function SetUTCSeconds(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        var s:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        var milli:Float = arguments.length <= 1 ? MsFromTime(t) : jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 1));
        var date:Float = MakeDate(Day(t), MakeTime(HourFromTime(t), MinFromTime(t), s, milli));
        var u:Float = TimeClip(date);
        thisObj.As().PrimitiveValue = u;
        return u;
    }
    private function SetMinutes(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = LocalTime(EnsureDateInstance(thisObj).PrimitiveValue);
        var m:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        var s:Float = arguments.length <= 1 ? SecFromTime(t) : jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 1));
        var milli:Float = arguments.length <= 2 ? MsFromTime(t) : jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 2));
        var date:Float = MakeDate(Day(t), MakeTime(HourFromTime(t), m, s, milli));
        var u:Float = TimeClip(Utc(date));
        thisObj.As().PrimitiveValue = u;
        return u;
    }
    private function SetUTCMinutes(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        var m:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        var s:Float = arguments.length <= 1 ? SecFromTime(t) : jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 1));
        var milli:Float = arguments.length <= 2 ? MsFromTime(t) : jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 2));
        var date:Float = MakeDate(Day(t), MakeTime(HourFromTime(t), m, s, milli));
        var u:Float = TimeClip(date);
        thisObj.As().PrimitiveValue = u;
        return u;
    }
    private function SetHours(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = LocalTime(EnsureDateInstance(thisObj).PrimitiveValue);
        var h:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        var m:Float = arguments.length <= 1 ? MinFromTime(t) : jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 1));
        var s:Float = arguments.length <= 2 ? SecFromTime(t) : jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 2));
        var milli:Float = arguments.length <= 3 ? MsFromTime(t) : jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 3));
        var date:Float = MakeDate(Day(t), MakeTime(h, m, s, milli));
        var u:Float = TimeClip(Utc(date));
        thisObj.As().PrimitiveValue = u;
        return u;
    }
    private function SetUTCHours(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        var h:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        var m:Float = arguments.length <= 1 ? MinFromTime(t) : jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 1));
        var s:Float = arguments.length <= 2 ? SecFromTime(t) : jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 2));
        var milli:Float = arguments.length <= 3 ? MsFromTime(t) : jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 3));
        var date:Float = MakeDate(Day(t), MakeTime(h, m, s, milli));
        var u:Float = TimeClip(date);
        thisObj.As().PrimitiveValue = u;
        return u;
    }
    private function SetDate(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = LocalTime(EnsureDateInstance(thisObj).PrimitiveValue);
        var dt:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        var newDate:Float = MakeDate(MakeDay(YearFromTime(t), MonthFromTime(t), dt), TimeWithinDay(t));
        var u:Float = TimeClip(Utc(newDate));
        thisObj.As().PrimitiveValue = u;
        return u;
    }
    private function SetUTCDate(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        var dt:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        var newDate:Float = MakeDate(MakeDay(YearFromTime(t), MonthFromTime(t), dt), TimeWithinDay(t));
        var u:Float = TimeClip(newDate);
        thisObj.As().PrimitiveValue = u;
        return u;
    }
    private function SetMonth(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = LocalTime(EnsureDateInstance(thisObj).PrimitiveValue);
        var m:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        var dt:Float = arguments.length <= 1 ? DateFromTime(t) : jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 1));
        var newDate:Float = MakeDate(MakeDay(YearFromTime(t), m, dt), TimeWithinDay(t));
        var u:Float = TimeClip(Utc(newDate));
        thisObj.As().PrimitiveValue = u;
        return u;
    }
    private function SetUTCMonth(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        var m:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        var dt:Float = arguments.length <= 1 ? DateFromTime(t) : jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 1));
        var newDate:Float = MakeDate(MakeDay(YearFromTime(t), m, dt), TimeWithinDay(t));
        var u:Float = TimeClip(newDate);
        thisObj.As().PrimitiveValue = u;
        return u;
    }
    private function SetFullYear(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var thisTime:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        var t:Float = Cs2Hx.IsNaN(thisTime) ?  0 : LocalTime(thisTime);
        var y:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        var m:Float = arguments.length <= 1 ? MonthFromTime(t) : jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 1));
        var dt:Float = arguments.length <= 2 ? DateFromTime(t) : jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 2));
        var newDate:Float = MakeDate(MakeDay(y, m, dt), TimeWithinDay(t));
        var u:Float = TimeClip(Utc(newDate));
        thisObj.As().PrimitiveValue = u;
        return u;
    }
    private function SetYear(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var thisTime:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        var t:Float = Cs2Hx.IsNaN(thisTime) ?  0 : LocalTime(thisTime);
        var y:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        if (Cs2Hx.IsNaN(y))
        {
            EnsureDateInstance(thisObj).PrimitiveValue = Math.NaN;
            return Math.NaN;
        }
        var fy:Float = jint.runtime.TypeConverter.ToInteger(y);
        if (y >= 0 && y <= 99)
        {
            fy = fy + 1900;
        }
        var newDate:Float = MakeDay(fy, MonthFromTime(t), DateFromTime(t));
        var u:Float = Utc(MakeDate(newDate, TimeWithinDay(t)));
        EnsureDateInstance(thisObj).PrimitiveValue = TimeClip(u);
        return u;
    }
    private function SetUTCFullYear(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var thisTime:Float = EnsureDateInstance(thisObj).PrimitiveValue;
        var t:Float = Cs2Hx.IsNaN(thisTime) ?  0 : thisTime;
        var y:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        var m:Float = arguments.length <= 1 ? MonthFromTime(t) : jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 1));
        var dt:Float = arguments.length <= 2 ? DateFromTime(t) : jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 2));
        var newDate:Float = MakeDate(MakeDay(y, m, dt), TimeWithinDay(t));
        var u:Float = TimeClip(newDate);
        thisObj.As().PrimitiveValue = u;
        return u;
    }
    private function ToUtcString(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return thisObj.TryCast(function (x:jint.native.JsValue):Void
        {
            throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        ).ToDateTime().ToUniversalTime().toString("ddd MMM dd yyyy HH:mm:ss 'GMT'", system.globalization.CultureInfo.InvariantCulture);
    }
    private function ToISOString(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var t:Float = thisObj.TryCast(function (x:jint.native.JsValue):Void
        {
            throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        ).PrimitiveValue;
        if (Cs2Hx.IsInfinity(t) || Cs2Hx.IsNaN(t))
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.RangeError);
        }
        return Cs2Hx.Format("{0:0000}-{1:00}-{2:00}T{3:00}:{4:00}:{5:00}.{6:000}Z", [ YearFromTime(t), MonthFromTime(t) + 1, DateFromTime(t), HourFromTime(t), MinFromTime(t), SecFromTime(t), MsFromTime(t) ]);
    }
    private function ToJSON(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var tv:jint.native.JsValue = jint.runtime.TypeConverter.ToPrimitive(o, jint.runtime.Types.Number);
        if (tv.IsNumber() && Cs2Hx.IsInfinity(tv.AsNumber()))
        {
            return jint.native.JsValue.Null;
        }
        var toIso:jint.native.JsValue = o.Get("toISOString");
        if (!toIso.Is())
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        return toIso.TryCast().Call(o, jint.runtime.Arguments.Empty);
    }
    public static var HoursPerDay:Float;
    public static var MinutesPerHour:Float;
    public static var SecondsPerMinute:Float;
    public static var MsPerSecond:Float;
    public static var MsPerMinute:Float;
    public static var MsPerHour:Float;
    public static var MsPerDay:Float;
    public static function Day(t:Float):Float
    {
        return system.MathCS.Floor_Double(t / MsPerDay);
    }
    public static function TimeWithinDay(t:Float):Float
    {
        return t % MsPerDay;
    }
    public static function DaysInYear(y:Float):Float
    {
        if (!(y % 4).Equals_Double(0))
        {
            return 365;
        }
        if ((y % 4).Equals_Double(0) && !(y % 100).Equals_Double(0))
        {
            return 366;
        }
        if ((y % 100).Equals_Double(0) && !(y % 400).Equals_Double(0))
        {
            return 365;
        }
        if ((y % 400).Equals_Double(0))
        {
            return 366;
        }
        return 365;
    }
    public static function DayFromYear(y:Float):Float
    {
        return 365 * (y - 1970) + system.MathCS.Floor_Double((y - 1969) / 4) - system.MathCS.Floor_Double((y - 1901) / 100) + system.MathCS.Floor_Double((y - 1601) / 400);
    }
    public static function TimeFromYear(y:Float):Float
    {
        return MsPerDay * DayFromYear(y);
    }
    public static function YearFromTime(t:Float):Float
    {
        if (!AreFinite([ t ]))
        {
            return system.Double.NaN;
        }
        var upper:Float = 3.4028235e+38;
        var lower:Float = 1.4e-45;
        while (upper > lower + 1)
        {
            var current:Float = system.MathCS.Floor_Double((upper + lower) / 2);
            var tfy:Float = TimeFromYear(current);
            if (tfy <= t)
            {
                lower = current;
            }
            else
            {
                upper = current;
            }
        }
        return lower;
    }
    public static function InLeapYear(t:Float):Float
    {
        var daysInYear:Float = DaysInYear(YearFromTime(t));
        if (daysInYear.Equals_Double(365))
        {
            return 0;
        }
        if (daysInYear.Equals_Double(366))
        {
            return 1;
        }
        return throw new system.ArgumentException();
    }
    public static function MonthFromTime(t:Float):Float
    {
        var dayWithinYear:Float = DayWithinYear(t);
        var inLeapYear:Float = InLeapYear(t);
        if (dayWithinYear < 31)
        {
            return 0;
        }
        if (dayWithinYear < 59 + inLeapYear)
        {
            return 1;
        }
        if (dayWithinYear < 90 + inLeapYear)
        {
            return 2;
        }
        if (dayWithinYear < 120 + inLeapYear)
        {
            return 3;
        }
        if (dayWithinYear < 151 + inLeapYear)
        {
            return 4;
        }
        if (dayWithinYear < 181 + inLeapYear)
        {
            return 5;
        }
        if (dayWithinYear < 212 + inLeapYear)
        {
            return 6;
        }
        if (dayWithinYear < 243 + inLeapYear)
        {
            return 7;
        }
        if (dayWithinYear < 273 + inLeapYear)
        {
            return 8;
        }
        if (dayWithinYear < 304 + inLeapYear)
        {
            return 9;
        }
        if (dayWithinYear < 334 + inLeapYear)
        {
            return 10;
        }
        if (dayWithinYear < 365 + inLeapYear)
        {
            return 11;
        }
        return throw new system.InvalidOperationException();
    }
    public static function DayWithinYear(t:Float):Float
    {
        return Day(t) - DayFromYear(YearFromTime(t));
    }
    public static function DateFromTime(t:Float):Float
    {
        var monthFromTime:Float = MonthFromTime(t);
        var dayWithinYear:Float = DayWithinYear(t);
        if (monthFromTime.Equals_Double(0))
        {
            return dayWithinYear + 1;
        }
        if (monthFromTime.Equals_Double(1))
        {
            return dayWithinYear - 30;
        }
        if (monthFromTime.Equals_Double(2))
        {
            return dayWithinYear - 58 - InLeapYear(t);
        }
        if (monthFromTime.Equals_Double(3))
        {
            return dayWithinYear - 89 - InLeapYear(t);
        }
        if (monthFromTime.Equals_Double(4))
        {
            return dayWithinYear - 119 - InLeapYear(t);
        }
        if (monthFromTime.Equals_Double(5))
        {
            return dayWithinYear - 150 - InLeapYear(t);
        }
        if (monthFromTime.Equals_Double(6))
        {
            return dayWithinYear - 180 - InLeapYear(t);
        }
        if (monthFromTime.Equals_Double(7))
        {
            return dayWithinYear - 211 - InLeapYear(t);
        }
        if (monthFromTime.Equals_Double(8))
        {
            return dayWithinYear - 242 - InLeapYear(t);
        }
        if (monthFromTime.Equals_Double(9))
        {
            return dayWithinYear - 272 - InLeapYear(t);
        }
        if (monthFromTime.Equals_Double(10))
        {
            return dayWithinYear - 303 - InLeapYear(t);
        }
        if (monthFromTime.Equals_Double(11))
        {
            return dayWithinYear - 333 - InLeapYear(t);
        }
        return throw new system.InvalidOperationException();
    }
    public static function WeekDay(t:Float):Float
    {
        return (Day(t) + 4) % 7;
    }
    public var LocalTza(get_LocalTza, never):Float;
    public function get_LocalTza():Float
    {
        return Engine.Options.GetBaseUtcOffset().TotalMilliseconds;
    }

    public function DaylightSavingTa(t:Float):Float
    {
        var timeInYear:Float = t - TimeFromYear(YearFromTime(t));
        if (Cs2Hx.IsInfinity(timeInYear) || Cs2Hx.IsNaN(timeInYear))
        {
            return 0;
        }
        var year:Float = YearFromTime(t);
        if (year < 9999 && year > -9999)
        {
        }
        else
        {
            var isLeapYear:Bool = InLeapYear(t).Equals_Double(1);
            year = isLeapYear ? 2000 : 1999;
        }
        var dateTime:Date = new Date(Std.int(year), 1, 1).AddMilliseconds(timeInYear);
        return Engine.Options.IsDaylightSavingTime(dateTime) ? MsPerHour : 0;
    }
    public function ToLocalTime(t:Date):Date
    {
        if (t.Kind == DateKind.Unspecified)
        {
            return t;
        }
        var offset:system.TimeSpan = Engine.Options.GetBaseUtcOffset();
        return new DateOffset(t.Ticks + offset.Ticks, offset);
    }
    public function LocalTime(t:Float):Float
    {
        return t + LocalTza + DaylightSavingTa(t);
    }
    public function Utc(t:Float):Float
    {
        return t - LocalTza - DaylightSavingTa(t - LocalTza);
    }
    public static function HourFromTime(t:Float):Float
    {
        return system.MathCS.Floor_Double(t / MsPerHour) % HoursPerDay;
    }
    public static function MinFromTime(t:Float):Float
    {
        return system.MathCS.Floor_Double(t / MsPerMinute) % MinutesPerHour;
    }
    public static function SecFromTime(t:Float):Float
    {
        return system.MathCS.Floor_Double(t / MsPerSecond) % SecondsPerMinute;
    }
    public static function MsFromTime(t:Float):Float
    {
        return t % MsPerSecond;
    }
    public static function DayFromMonth(year:Float, month:Float):Float
    {
        var day:Float = month * 30;
        if (month >= 7)
        {
            day += month / 2 - 1;
        }
        else if (month >= 2)
        {
            day += (month - 1) / 2 - 1;
        }
        else
        {
            day += month;
        }
        if (month >= 2 && InLeapYear(year).Equals_Double(1))
        {
            day++;
        }
        return day;
    }
    public static function DaysInMonth(month:Float, leap:Float):Float
    {
        month = month % 12;
        switch (month)
        {
            case 0, 2, 4, 6, 7, 9, 11:
                return 31;
            case 3, 5, 8, 10:
                return 30;
            case 1:
                return 28 + leap;
            default:
                return throw new system.ArgumentOutOfRangeException("month");
        }
    }
    public static function MakeTime(hour:Float, min:Float, sec:Float, ms:Float):Float
    {
        if (!AreFinite([ hour, min, sec, ms ]))
        {
            return Math.NaN;
        }
        var h:Float = hour;
        var m:Float = min;
        var s:Float = sec;
        var milli:Float = ms;
        var t:Float = h * MsPerHour + m * MsPerMinute + s * MsPerSecond + milli;
        return t;
    }
    public static function MakeDay(year:Float, month:Float, date:Float):Float
    {
        if (!AreFinite([ year, month, date ]))
        {
            return Math.NaN;
        }
        year = jint.runtime.TypeConverter.ToInteger(year);
        month = jint.runtime.TypeConverter.ToInteger(month);
        date = jint.runtime.TypeConverter.ToInteger(date);
        var sign:Int = (year < 1970) ? -1 : 1;
        var t:Float = (year < 1970) ? 1 : 0;
        var y:Int;
        if (sign == -1)
        {
            { //for
                y = 1969;
                while (y >= year)
                {
                    t += sign * DaysInYear(y) * MsPerDay;
                    y += sign;
                }
            } //end for
        }
        else
        {
            { //for
                y = 1970;
                while (y < year)
                {
                    t += sign * DaysInYear(y) * MsPerDay;
                    y += sign;
                }
            } //end for
        }
        { //for
            var m:Int = 0;
            while (m < month)
            {
                t += DaysInMonth(m, InLeapYear(t)) * MsPerDay;
                m++;
            }
        } //end for
        return Day(t) + date - 1;
    }
    public static function MakeDate(day:Float, time:Float):Float
    {
        if (!AreFinite([ day, time ]))
        {
            return Math.NaN;
        }
        return day * MsPerDay + time;
    }
    public static function TimeClip(time:Float):Float
    {
        if (!AreFinite([ time ]))
        {
            return Math.NaN;
        }
        if (system.MathCS.Abs_Double(time) > 8640000000000000)
        {
            return Math.NaN;
        }
        return time + 0;
    }
    private static function AreFinite(values:Array<Float>):Bool
    {
        { //for
            var index:Int = 0;
            while (index < values.length)
            {
                var value:Float = values[index];
                if (Cs2Hx.IsNaN(value) || Cs2Hx.IsInfinity(value))
                {
                    return false;
                }
                index++;
            }
        } //end for
        return true;
    }
    public static function cctor():Void
    {
        HoursPerDay = 24;
        MinutesPerHour = 60;
        SecondsPerMinute = 60;
        MsPerSecond = 1000;
        MsPerMinute = 60000;
        MsPerHour = 3600000;
        MsPerDay = 86400000;
    }
}
