package jint;
using StringTools;
import system.*;
import anonymoustypes.*;

class DeclarationBindingType
{
    public static inline var GlobalCode:Int = 1;
    public static inline var FunctionCode:Int = 2;
    public static inline var EvalCode:Int = 3;

    public static function ToString(e:Int):String
    {
        switch (e)
        {
            case 1: return "GlobalCode";
            case 2: return "FunctionCode";
            case 3: return "EvalCode";
            default: throw new InvalidOperationException(Std.string(e));
        }
    }

    public static function Parse(s:String):Int
    {
        switch (s)
        {
            case "GlobalCode": return 1;
            case "FunctionCode": return 2;
            case "EvalCode": return 3;
            default: throw new InvalidOperationException(s);
        }
    }

    public static function Values():Array<Int>
    {
        return [1, 2, 3];
    }
}
