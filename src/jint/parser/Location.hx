package jint.parser;
using StringTools;
import system.*;
import anonymoustypes.*;

class Location
{
    public var Start:jint.parser.Position;
    public var End:jint.parser.Position;
    public var Source:String;
    public function new()
    {
        Start = new jint.parser.Position();
        End = new jint.parser.Position();
    }
}
