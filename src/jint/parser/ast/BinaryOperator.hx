package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class BinaryOperator
{
    public static inline var Plus:Int = 1;
    public static inline var Minus:Int = 2;
    public static inline var Times:Int = 3;
    public static inline var Divide:Int = 4;
    public static inline var Modulo:Int = 5;
    public static inline var Equal:Int = 6;
    public static inline var NotEqual:Int = 7;
    public static inline var Greater:Int = 8;
    public static inline var GreaterOrEqual:Int = 9;
    public static inline var Less:Int = 10;
    public static inline var LessOrEqual:Int = 11;
    public static inline var StrictlyEqual:Int = 12;
    public static inline var StricltyNotEqual:Int = 13;
    public static inline var BitwiseAnd:Int = 14;
    public static inline var BitwiseOr:Int = 15;
    public static inline var BitwiseXOr:Int = 16;
    public static inline var LeftShift:Int = 17;
    public static inline var RightShift:Int = 18;
    public static inline var UnsignedRightShift:Int = 19;
    public static inline var InstanceOf:Int = 20;
    public static inline var In:Int = 21;

    public static function ToString(e:Int):String
    {
        switch (e)
        {
            case 1: return "Plus";
            case 2: return "Minus";
            case 3: return "Times";
            case 4: return "Divide";
            case 5: return "Modulo";
            case 6: return "Equal";
            case 7: return "NotEqual";
            case 8: return "Greater";
            case 9: return "GreaterOrEqual";
            case 10: return "Less";
            case 11: return "LessOrEqual";
            case 12: return "StrictlyEqual";
            case 13: return "StricltyNotEqual";
            case 14: return "BitwiseAnd";
            case 15: return "BitwiseOr";
            case 16: return "BitwiseXOr";
            case 17: return "LeftShift";
            case 18: return "RightShift";
            case 19: return "UnsignedRightShift";
            case 20: return "InstanceOf";
            case 21: return "In";
            default: throw new InvalidOperationException(Std.string(e));
        }
    }

    public static function Parse(s:String):Int
    {
        switch (s)
        {
            case "Plus": return 1;
            case "Minus": return 2;
            case "Times": return 3;
            case "Divide": return 4;
            case "Modulo": return 5;
            case "Equal": return 6;
            case "NotEqual": return 7;
            case "Greater": return 8;
            case "GreaterOrEqual": return 9;
            case "Less": return 10;
            case "LessOrEqual": return 11;
            case "StrictlyEqual": return 12;
            case "StricltyNotEqual": return 13;
            case "BitwiseAnd": return 14;
            case "BitwiseOr": return 15;
            case "BitwiseXOr": return 16;
            case "LeftShift": return 17;
            case "RightShift": return 18;
            case "UnsignedRightShift": return 19;
            case "InstanceOf": return 20;
            case "In": return 21;
            default: throw new InvalidOperationException(s);
        }
    }

    public static function Values():Array<Int>
    {
        return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21];
    }
}
