package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class BreakStatement extends jint.parser.ast.Statement
{
    public var Label:jint.parser.ast.Identifier;
    public function new()
    {
        super();
    }
}
