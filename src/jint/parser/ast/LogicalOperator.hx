package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class LogicalOperator
{
    public static inline var LogicalAnd:Int = 1;
    public static inline var LogicalOr:Int = 2;

    public static function ToString(e:Int):String
    {
        switch (e)
        {
            case 1: return "LogicalAnd";
            case 2: return "LogicalOr";
            default: throw new InvalidOperationException(Std.string(e));
        }
    }

    public static function Parse(s:String):Int
    {
        switch (s)
        {
            case "LogicalAnd": return 1;
            case "LogicalOr": return 2;
            default: throw new InvalidOperationException(s);
        }
    }

    public static function Values():Array<Int>
    {
        return [1, 2];
    }
}
