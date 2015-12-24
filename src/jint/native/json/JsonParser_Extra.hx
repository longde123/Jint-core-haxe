package jint.native.json;
using StringTools;
import system.*;
import anonymoustypes.*;

class JsonParser_Extra
{
    public var Loc:Null<Int>;
    public var Range:Array<Int>;
    public var Source:String;
    public var Tokens:Array<jint.native.json.JsonParser_Token>;
    public function new()
    {
        Loc = null;
    }
}
