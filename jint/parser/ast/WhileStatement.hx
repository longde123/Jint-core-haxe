package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class WhileStatement extends jint.parser.ast.Statement
{
    public var Test:jint.parser.ast.Expression;
    public var Body:jint.parser.ast.Statement;
    public function new()
    {
        super();
    }
}
