package jint.runtime.debugger;
using StringTools;
import system.*;
import anonymoustypes.*;

class StepMode
{
    public static inline var None:Int = 1;
    public static inline var Over:Int = 2;
    public static inline var Into:Int = 3;
    public static inline var Out:Int = 4;

    public static function ToString(e:Int):String
    {
        switch (e)
        {
            case 1: return "None";
            case 2: return "Over";
            case 3: return "Into";
            case 4: return "Out";
            default: throw new InvalidOperationException(Std.string(e));
        }
    }

    public static function Parse(s:String):Int
    {
        switch (s)
        {
            case "None": return 1;
            case "Over": return 2;
            case "Into": return 3;
            case "Out": return 4;
            default: throw new InvalidOperationException(s);
        }
    }

    public static function Values():Array<Int>
    {
        return [1, 2, 3, 4];
    }
}
