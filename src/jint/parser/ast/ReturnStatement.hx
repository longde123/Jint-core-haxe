package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class ReturnStatement extends jint.parser.ast.Statement
{
    public var Argument:jint.parser.ast.Expression;
    public function new()
    {
        super();
    }
}
