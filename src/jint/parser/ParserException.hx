package jint.parser;
using StringTools;
import system.*;
import anonymoustypes.*;

class ParserException extends system.Exception
{
    public var Column:Int;
    public var Description:String;
    public var Index:Int;
    public var LineNumber:Int;
    public var Source:String;
    public function new(message:String)
    {
        super(message);
        Column = 0;
        Index = 0;
        LineNumber = 0;
    }
}
