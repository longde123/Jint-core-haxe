package jint.native.regexp;
using StringTools;
import system.*;
import anonymoustypes.*;

class RegExpInstance extends jint.native.object.ObjectInstance
{
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    override public function get_Class():String
    {
        return "RegExp";
    }

    public var Value:system.text.regularexpressions.Regex;
    public var Source:String;
    public var Flags:String;
    public var Global:Bool;
    public var IgnoreCase:Bool;
    public var Multiline:Bool;
    public function Match(input:String, start:Float):system.text.regularexpressions.Match
    {
        return Value.Match_String_Int32(input, Std.int(start));
    }
}
