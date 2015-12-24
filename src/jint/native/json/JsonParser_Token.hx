package jint.native.json;
using StringTools;
import system.*;
import anonymoustypes.*;

class JsonParser_Token
{
    public var Type:Int;
    public var Value:Dynamic;
    public var Range:Array<Int>;
    public var LineNumber:Null<Int>;
    public var LineStart:Int;
    public function new()
    {
        Type = 0;
        LineNumber = null;
        LineStart = 0;
    }
}
