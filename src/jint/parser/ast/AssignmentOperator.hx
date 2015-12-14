package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class AssignmentOperator
{
    public static inline var Assign:Int = 1;
    public static inline var PlusAssign:Int = 2;
    public static inline var MinusAssign:Int = 3;
    public static inline var TimesAssign:Int = 4;
    public static inline var DivideAssign:Int = 5;
    public static inline var ModuloAssign:Int = 6;
    public static inline var BitwiseAndAssign:Int = 7;
    public static inline var BitwiseOrAssign:Int = 8;
    public static inline var BitwiseXOrAssign:Int = 9;
    public static inline var LeftShiftAssign:Int = 10;
    public static inline var RightShiftAssign:Int = 11;
    public static inline var UnsignedRightShiftAssign:Int = 12;

    public static function ToString(e:Int):String
    {
        switch (e)
        {
            case 1: return "Assign";
            case 2: return "PlusAssign";
            case 3: return "MinusAssign";
            case 4: return "TimesAssign";
            case 5: return "DivideAssign";
            case 6: return "ModuloAssign";
            case 7: return "BitwiseAndAssign";
            case 8: return "BitwiseOrAssign";
            case 9: return "BitwiseXOrAssign";
            case 10: return "LeftShiftAssign";
            case 11: return "RightShiftAssign";
            case 12: return "UnsignedRightShiftAssign";
            default: throw new InvalidOperationException(Std.string(e));
        }
    }

    public static function Parse(s:String):Int
    {
        switch (s)
        {
            case "Assign": return 1;
            case "PlusAssign": return 2;
            case "MinusAssign": return 3;
            case "TimesAssign": return 4;
            case "DivideAssign": return 5;
            case "ModuloAssign": return 6;
            case "BitwiseAndAssign": return 7;
            case "BitwiseOrAssign": return 8;
            case "BitwiseXOrAssign": return 9;
            case "LeftShiftAssign": return 10;
            case "RightShiftAssign": return 11;
            case "UnsignedRightShiftAssign": return 12;
            default: throw new InvalidOperationException(s);
        }
    }

    public static function Values():Array<Int>
    {
        return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    }
}
