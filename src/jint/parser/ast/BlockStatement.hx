package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class BlockStatement extends jint.parser.ast.Statement
{
    public var Body:Array<jint.parser.ast.Statement>;
    public function new()
    {
        super();
    }
}
