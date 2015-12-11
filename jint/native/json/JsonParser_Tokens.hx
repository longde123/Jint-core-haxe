package jint.native.json;
using StringTools;
import system.*;
import anonymoustypes.*;

class JsonParser_Tokens
{
    public static inline var NullLiteral:Int = 1;
    public static inline var BooleanLiteral:Int = 2;
    public static inline var String:Int = 3;
    public static inline var Number:Int = 4;
    public static inline var Punctuator:Int = 5;
    public static inline var EOF:Int = 6;

    public static function ToString(e:Int):String
    {
        switch (e)
        {
            case 1: return "NullLiteral";
            case 2: return "BooleanLiteral";
            case 3: return "String";
            case 4: return "Number";
            case 5: return "Punctuator";
            case 6: return "EOF";
            default: throw new InvalidOperationException(Std.string(e));
        }
    }

    public static function Parse(s:String):Int
    {
        switch (s)
        {
            case "NullLiteral": return 1;
            case "BooleanLiteral": return 2;
            case "String": return 3;
            case "Number": return 4;
            case "Punctuator": return 5;
            case "EOF": return 6;
            default: throw new InvalidOperationException(s);
        }
    }

    public static function Values():Array<Int>
    {
        return [1, 2, 3, 4, 5, 6];
    }
}
