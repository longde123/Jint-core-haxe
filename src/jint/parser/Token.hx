package jint.parser;
using StringTools;
import system.*;
import anonymoustypes.*;

class Token
{
    public static var Empty:jint.parser.Token;
    public var Type:Int;
    public var Literal:String;
    public var Value:Dynamic;
    public var Range:Array<Int>;
    public var LineNumber:Null<Int>;
    public var LineStart:Int;
    public var Octal:Bool;
    public var Location:jint.parser.Location;
    public var Precedence:Int;
    public static function cctor():Void
    {
        Empty = new jint.parser.Token();
    }
    public function new()
    {
        Type = 0;
        LineNumber =null;
        LineStart = 0;
        Octal = false;
        Precedence = 0;
    }
}
