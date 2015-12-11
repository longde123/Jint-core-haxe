package jint.parser;
using StringTools;
import system.*;
import anonymoustypes.*;

class Position
{
    public var Line:Int;
    public var Column:Int;
    public function new()
    {
        Line = 0;
        Column = 0;
    }
}
