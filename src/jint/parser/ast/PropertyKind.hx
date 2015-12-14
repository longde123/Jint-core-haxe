package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class PropertyKind
{
    public static inline var Data:Int = 1;
    public static inline var Get:Int = 2;
    public static inline var Set:Int = 4;

    public static function ToString(e:Int):String
    {
        switch (e)
        {
            case 1: return "Data";
            case 2: return "Get";
            case 4: return "Set";
            default: throw new InvalidOperationException(Std.string(e));
        }
    }

    public static function Parse(s:String):Int
    {
        switch (s)
        {
            case "Data": return 1;
            case "Get": return 2;
            case "Set": return 4;
            default: throw new InvalidOperationException(s);
        }
    }

    public static function Values():Array<Int>
    {
        return [1, 2, 4];
    }
}
