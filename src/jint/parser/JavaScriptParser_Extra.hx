package jint.parser;
using StringTools;
import system.*;
import anonymoustypes.*;

class JavaScriptParser_Extra
{
    public var LocHasValue:Bool;
    public var Loc:Int;
    public var Range:Array<Int>;
    public var Source:String;
    public var Comments:Array<jint.parser.Comment>;
    public var Tokens:Array<jint.parser.Token>;
    public var Errors:Array<jint.parser.ParserException>;
    public function new()
    {
        LocHasValue = false;
        Loc = 0;
    }
}
