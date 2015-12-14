package jint.parser;
using StringTools;
import system.*;
import anonymoustypes.*;

class ParserExtensions
{
    public static function Slice(source:String, start:Int, end:Int):String
    {
        return source.substr(start, system.MathCS.Min_Int32_Int32(source.length, end) - start);
    }
    public static function CharCodeAt(source:String, index:Int):Int
    {
        if (index < 0 || index > source.length - 1)
        {
            return Char.MinValue;
        }
        return source.charCodeAt(index);
    }
    public static function Pop<T>(list:Array<T>):T
    {
        var lastIndex:Int = list.length - 1;
        var last:T = list[lastIndex];
        list.splice(lastIndex, 1);
        return last;
    }
    public static function Push<T>(list:Array<T>, item:T):Void
    {
        list.push(item);
    }
    public function new()
    {
    }
}
