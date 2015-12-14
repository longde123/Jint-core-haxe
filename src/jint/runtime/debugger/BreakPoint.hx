package jint.runtime.debugger;
using StringTools;
import system.*;
import anonymoustypes.*;

class BreakPoint
{
    public var Line:Int;
    public var Char:Int;
    public var Condition:String;
    public function new(line:Int, character:Int, condition:String)
    {
        Line = line;
        Char = character;
        Condition = condition;
    }
}
