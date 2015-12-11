package jint.parser;
using StringTools;
import system.*;
import anonymoustypes.*;

class Tokens
{
    public static inline var BooleanLiteral:Int = 1;
    public static inline var EOF:Int = 2;
    public static inline var Identifier:Int = 3;
    public static inline var Keyword:Int = 4;
    public static inline var NullLiteral:Int = 5;
    public static inline var NumericLiteral:Int = 6;
    public static inline var Punctuator:Int = 7;
    public static inline var StringLiteral:Int = 8;
    public static inline var RegularExpression:Int = 9;

    public static function ToString(e:Int):String
    {
        switch (e)
        {
            case 1: return "BooleanLiteral";
            case 2: return "EOF";
            case 3: return "Identifier";
            case 4: return "Keyword";
            case 5: return "NullLiteral";
            case 6: return "NumericLiteral";
            case 7: return "Punctuator";
            case 8: return "StringLiteral";
            case 9: return "RegularExpression";
            default: throw new InvalidOperationException(Std.string(e));
        }
    }

    public static function Parse(s:String):Int
    {
        switch (s)
        {
            case "BooleanLiteral": return 1;
            case "EOF": return 2;
            case "Identifier": return 3;
            case "Keyword": return 4;
            case "NullLiteral": return 5;
            case "NumericLiteral": return 6;
            case "Punctuator": return 7;
            case "StringLiteral": return 8;
            case "RegularExpression": return 9;
            default: throw new InvalidOperationException(s);
        }
    }

    public static function Values():Array<Int>
    {
        return [1, 2, 3, 4, 5, 6, 7, 8, 9];
    }
}
