package jint.native.math;
using StringTools;
import system.*;
import anonymoustypes.*;

class MathInstance extends jint.native.object.ObjectInstance
{
    private static var _random:system.Random;
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    override public function get_JClass():String
    {
        return "Math";
    }

    public static function CreateMathObject(engine:jint.Engine):jint.native.math.MathInstance
    {
        var math:jint.native.math.MathInstance = new jint.native.math.MathInstance(engine);
        math.Extensible = true;
        math.Prototype = engine.JObject.PrototypeObject;
        return math;
    }
    public function Configure():Void
    {
        FastAddProperty("abs", new jint.runtime.interop.ClrFunctionInstance(Engine, Abs), true, false, true);
        FastAddProperty("acos", new jint.runtime.interop.ClrFunctionInstance(Engine, Acos), true, false, true);
        FastAddProperty("asin", new jint.runtime.interop.ClrFunctionInstance(Engine, Asin), true, false, true);
        FastAddProperty("atan", new jint.runtime.interop.ClrFunctionInstance(Engine, Atan), true, false, true);
        FastAddProperty("atan2", new jint.runtime.interop.ClrFunctionInstance(Engine, Atan2), true, false, true);
        FastAddProperty("ceil", new jint.runtime.interop.ClrFunctionInstance(Engine, Ceil), true, false, true);
        FastAddProperty("cos", new jint.runtime.interop.ClrFunctionInstance(Engine, Cos), true, false, true);
        FastAddProperty("exp", new jint.runtime.interop.ClrFunctionInstance(Engine, Exp), true, false, true);
        FastAddProperty("floor", new jint.runtime.interop.ClrFunctionInstance(Engine, Floor), true, false, true);
        FastAddProperty("log", new jint.runtime.interop.ClrFunctionInstance(Engine, Log), true, false, true);
        FastAddProperty("max", new jint.runtime.interop.ClrFunctionInstance(Engine, Max, 2), true, false, true);
        FastAddProperty("min", new jint.runtime.interop.ClrFunctionInstance(Engine, Min, 2), true, false, true);
        FastAddProperty("pow", new jint.runtime.interop.ClrFunctionInstance(Engine, Pow, 2), true, false, true);
        FastAddProperty("random", new jint.runtime.interop.ClrFunctionInstance(Engine, Random), true, false, true);
        FastAddProperty("round", new jint.runtime.interop.ClrFunctionInstance(Engine, Round), true, false, true);
        FastAddProperty("sin", new jint.runtime.interop.ClrFunctionInstance(Engine, Sin), true, false, true);
        FastAddProperty("sqrt", new jint.runtime.interop.ClrFunctionInstance(Engine, Sqrt), true, false, true);
        FastAddProperty("tan", new jint.runtime.interop.ClrFunctionInstance(Engine, Tan), true, false, true);
        //FastAddProperty("E", system.MathCS.E, false, false, false);
        FastAddProperty("LN10", system.MathCS.Log(10), false, false, false);
        FastAddProperty("LN2", system.MathCS.Log(2), false, false, false);
		//FastAddProperty("LOG2E", system.MathCS.Log_Double_Double(system.MathCS.E, 2), false, false, false);
		//FastAddProperty("LOG10E", system.MathCS.Log_Double_Double(system.MathCS.E, 10), false, false, false);
        FastAddProperty("PI", system.MathCS.PI, false, false, false);
        FastAddProperty("SQRT1_2", system.MathCS.Sqrt(0.5), false, false, false);
        FastAddProperty("SQRT2", system.MathCS.Sqrt(2), false, false, false);
    }
    private static function Abs(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var x:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        return system.MathCS.Abs_Double(x);
    }
    private static function Acos(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var x:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        return system.MathCS.Acos(x);
    }
    private static function Asin(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var x:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        return system.MathCS.Asin(x);
    }
    private static function Atan(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var x:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        return system.MathCS.Atan(x);
    }
    private static function Atan2(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var y:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        var x:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 1));
        if (Cs2Hx.IsNaN(x) || Cs2Hx.IsNaN(y))
        {
            return Math.NaN;
        }
        if (y > 0 && x==(0))
        {
            return system.MathCS.PI / 2;
        }
        if (jint.native.number.NumberInstance.IsPositiveZero(y))
        {
            if (x > 0)
            {
                return 0;
            }
            if (jint.native.number.NumberInstance.IsPositiveZero(x))
            {
                return 0;
            }
            if (jint.native.number.NumberInstance.IsNegativeZero(x))
            {
                return system.MathCS.PI;
            }
            if (x < 0)
            {
                return system.MathCS.PI;
            }
        }
        if (jint.native.number.NumberInstance.IsNegativeZero(y))
        {
            if (x > 0)
            {
                return -0;
            }
            if (jint.native.number.NumberInstance.IsPositiveZero(x))
            {
                return -0;
            }
            if (jint.native.number.NumberInstance.IsNegativeZero(x))
            {
                return -system.MathCS.PI;
            }
            if (x < 0)
            {
                return -system.MathCS.PI;
            }
        }
        if (y < 0 && x==(0))
        {
            return -system.MathCS.PI / 2;
        }
        if (y > 0 && !Cs2Hx.IsInfinity(y))
        {
            if (Cs2Hx.IsPositiveInfinity(x))
            {
                return 0;
            }
            if (Cs2Hx.IsNegativeInfinity(x))
            {
                return system.MathCS.PI;
            }
        }
        if (y < 0 && !Cs2Hx.IsInfinity(y))
        {
            if (Cs2Hx.IsPositiveInfinity(x))
            {
                return -0;
            }
            if (Cs2Hx.IsNegativeInfinity(x))
            {
                return -system.MathCS.PI;
            }
        }
        if (Cs2Hx.IsPositiveInfinity(y) && !Cs2Hx.IsInfinity(x))
        {
            return system.MathCS.PI / 2;
        }
        if (Cs2Hx.IsNegativeInfinity(y) && !Cs2Hx.IsInfinity(x))
        {
            return -system.MathCS.PI / 2;
        }
        if (Cs2Hx.IsPositiveInfinity(y) && Cs2Hx.IsPositiveInfinity(x))
        {
            return system.MathCS.PI / 4;
        }
        if (Cs2Hx.IsPositiveInfinity(y) && Cs2Hx.IsNegativeInfinity(x))
        {
            return 3 * system.MathCS.PI / 4;
        }
        if (Cs2Hx.IsNegativeInfinity(y) && Cs2Hx.IsPositiveInfinity(x))
        {
            return -system.MathCS.PI / 4;
        }
        if (Cs2Hx.IsNegativeInfinity(y) && Cs2Hx.IsNegativeInfinity(x))
        {
            return -3 * system.MathCS.PI / 4;
        }
        return system.MathCS.Atan2(y, x);
    }
    private static function Ceil(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var x:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        return system.MathCS.Ceiling_Double(x);
    }
    private static function Cos(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var x:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        return system.MathCS.Cos(x);
    }
    private static function Exp(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var x:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        return system.MathCS.Exp(x);
    }
    private static function Floor(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var x:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        return Math.floor(x);
    }
    private static function Log(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var x:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        return system.MathCS.Log(x);
    }
    private static function Max(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        if (arguments.length == 0)
        {
            return Math.NEGATIVE_INFINITY;
        }
        var max:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        { //for
            var i:Int = 0;
            while (i < arguments.length)
            {
                max = system.MathCS.Max_Double_Double(max, jint.runtime.TypeConverter.ToNumber(arguments[i]));
                i++;
            }
        } //end for
        return max;
    }
    private static function Min(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        if (arguments.length == 0)
        {
            return Math.POSITIVE_INFINITY;
        }
        var min:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        { //for
            var i:Int = 0;
            while (i < arguments.length)
            {
                min = system.MathCS.Min_Double_Double(min, jint.runtime.TypeConverter.ToNumber(arguments[i]));
                i++;
            }
        } //end for
        return min;
    }
    private static function Pow(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var x:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        var y:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 1));
        if (Cs2Hx.IsNaN(y))
        {
            return Math.NaN;
        }
        if (y==(0))
        {
            return 1;
        }
        if (Cs2Hx.IsNaN(x) && y!=(0))
        {
            return Math.NaN;
        }
        if (system.MathCS.Abs_Double(x) > 1)
        {
            if (Cs2Hx.IsPositiveInfinity(y))
            {
                return Math.POSITIVE_INFINITY;
            }
            if (Cs2Hx.IsNegativeInfinity(y))
            {
                return  0;
            }
        }
        if (system.MathCS.Abs_Double(x)==(1))
        {
            if (Cs2Hx.IsInfinity(y))
            {
                return Math.NaN;
            }
        }
        if (system.MathCS.Abs_Double(x) < 1)
        {
            if (Cs2Hx.IsPositiveInfinity(y))
            {
                return 0;
            }
            if (Cs2Hx.IsNegativeInfinity(y))
            {
                return Math.POSITIVE_INFINITY;
            }
        }
        if (Cs2Hx.IsPositiveInfinity(x))
        {
            if (y > 0)
            {
                return Math.POSITIVE_INFINITY;
            }
            if (y < 0)
            {
                return 0;
            }
        }
        if (Cs2Hx.IsNegativeInfinity(x))
        {
            if (y > 0)
            {
                if (system.MathCS.Abs_Double(y % 2)==(1))
                {
                    return Math.NEGATIVE_INFINITY;
                }
                return Math.POSITIVE_INFINITY;
            }
            if (y < 0)
            {
                if (system.MathCS.Abs_Double(y % 2)==(1))
                {
                    return -0;
                }
                return 0;
            }
        }
        if (jint.native.number.NumberInstance.IsPositiveZero(x))
        {
            if (y > 0)
            {
                return 0;
            }
            if (y < 0)
            {
                return Math.POSITIVE_INFINITY;
            }
        }
        if (jint.native.number.NumberInstance.IsNegativeZero(x))
        {
            if (y > 0)
            {
                if (system.MathCS.Abs_Double(y % 2)==(1))
                {
                    return -0;
                }
                return 0;
            }
            if (y < 0)
            {
                if (system.MathCS.Abs_Double(y % 2)==(1))
                {
                    return Math.NEGATIVE_INFINITY;
                }
                return Math.POSITIVE_INFINITY;
            }
        }
        if (x < 0 && !Cs2Hx.IsInfinity(x) && !Cs2Hx.IsInfinity(y) && y!=(Std.int(y)))
        {
            return Math.NaN;
        }
        return Math.pow(x, y);
    }
    private static function Random(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return _random.NextDouble();
    }
    private static function Round(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var x:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        var round:Float = Math.round(x);
        if (round==(x - 0.5))
        {
            return round + 1;
        }
        return round;
    }
    private static function Sin(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var x:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        return system.MathCS.Sin(x);
    }
    private static function Sqrt(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var x:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        return system.MathCS.Sqrt(x);
    }
    private static function Tan(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var x:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        return system.MathCS.Tan(x);
    }
    public static function cctor():Void
    {
        _random = new system.Random();
    }
}
