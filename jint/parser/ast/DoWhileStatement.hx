package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class DoWhileStatement extends jint.parser.ast.Statement
{
    public var Body:jint.parser.ast.Statement;
    public var Test:jint.parser.ast.Expression;
    public function new()
    {
        super();
    }
}
