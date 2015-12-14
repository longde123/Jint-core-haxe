package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class ExpressionStatement extends jint.parser.ast.Statement
{
    public var Expression:jint.parser.ast.Expression;
    public function new()
    {
        super();
    }
}
