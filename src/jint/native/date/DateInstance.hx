package jint.native.date;
using StringTools;
import system.*;
import anonymoustypes.*;

class DateInstance extends jint.native.object.ObjectInstance
{
    public static var Max:Float = DateTools.makeUtc(10000, 1, 1, 1, 1, 0);
    public static  var Min:Float = DateTools.makeUtc(1970, 1, 1, 0, 0, 0);
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    override public function get_JClass():String
    {
        return "Date";
    }

    public function ToDateTime():Date
    {
        if (Cs2Hx.IsNaN(PrimitiveValue) || PrimitiveValue > Max || PrimitiveValue < Min)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.RangeError);
        }
        else
        { 
		
            return  Date.fromTime(jint.native.date.DateConstructor.Epoch.getTime()+PrimitiveValue);
        }
    }
    public var PrimitiveValue:Float;
}
