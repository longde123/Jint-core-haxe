package jint.runtime;
using StringTools;
import system.*;
import anonymoustypes.*;

class Types
{
    public static inline var None:Int = 1;
    public static inline var Undefined:Int = 2;
    public static inline var Null:Int = 3;
    public static inline var Boolean:Int = 4;
    public static inline var String:Int = 5;
    public static inline var Number:Int = 6;
    public static inline var Object:Int = 7;

    public static function ToString(e:Int):String
    {
        switch (e)
        {
            case 1: return "None";
            case 2: return "Undefined";
            case 3: return "Null";
            case 4: return "Boolean";
            case 5: return "String";
            case 6: return "Number";
            case 7: return "Object";
            default: throw new InvalidOperationException(Std.string(e));
        }
    }

    public static function Parse(s:String):Int
    {
        switch (s)
        {
            case "None": return 1;
            case "Undefined": return 2;
            case "Null": return 3;
            case "Boolean": return 4;
            case "String": return 5;
            case "Number": return 6;
            case "Object": return 7;
            default: throw new InvalidOperationException(s);
        }
    }

    public static function Values():Array<Int>
    {
        return [1, 2, 3, 4, 5, 6, 7];
    }
}
