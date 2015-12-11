package jint.native.date;
using StringTools;
import system.*;
import anonymoustypes.*;

class DateInstance extends jint.native.object.ObjectInstance
{
    public static inline var Max:Float = (system.DateTime.MaxValue - new system.DateTime(1970, 1, 1, 0, 0, 0, system.DateTimeKind.Utc)).TotalMilliseconds;
    public static inline var Min:Float = -(new system.DateTime(1970, 1, 1, 0, 0, 0, system.DateTimeKind.Utc) - system.DateTime.MinValue).TotalMilliseconds;
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    override public function get_Class():String
    {
        return "Date";
    }

    public function ToDateTime():system.DateTime
    {
        if (Cs2Hx.IsNaN(PrimitiveValue) || PrimitiveValue > Max || PrimitiveValue < Min)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.RangeError);
        }
        else
        {
            return jint.native.date.DateConstructor.Epoch.AddMilliseconds(PrimitiveValue);
        }
    }
    public var PrimitiveValue:Float;
}
