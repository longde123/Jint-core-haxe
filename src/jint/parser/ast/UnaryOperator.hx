package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class UnaryOperator
{
    public static inline var Plus:Int = 1;
    public static inline var Minus:Int = 2;
    public static inline var BitwiseNot:Int = 3;
    public static inline var LogicalNot:Int = 4;
    public static inline var Delete:Int = 5;
    public static inline var Void:Int = 6;
    public static inline var TypeOf:Int = 7;
    public static inline var Increment:Int = 8;
    public static inline var Decrement:Int = 9;

    public static function ToString(e:Int):String
    {
        switch (e)
        {
            case 1: return "Plus";
            case 2: return "Minus";
            case 3: return "BitwiseNot";
            case 4: return "LogicalNot";
            case 5: return "Delete";
            case 6: return "Void";
            case 7: return "TypeOf";
            case 8: return "Increment";
            case 9: return "Decrement";
            default: throw new InvalidOperationException(Std.string(e));
        }
    }

    public static function Parse(s:String):Int
    {
        switch (s)
        {
            case "Plus": return 1;
            case "Minus": return 2;
            case "BitwiseNot": return 3;
            case "LogicalNot": return 4;
            case "Delete": return 5;
            case "Void": return 6;
            case "TypeOf": return 7;
            case "Increment": return 8;
            case "Decrement": return 9;
            default: throw new InvalidOperationException(s);
        }
    }

    public static function Values():Array<Int>
    {
        return [1, 2, 3, 4, 5, 6, 7, 8, 9];
    }
}
