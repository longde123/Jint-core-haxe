package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class WithStatement extends jint.parser.ast.Statement
{
    public var Object:jint.parser.ast.Expression;
    public var Body:jint.parser.ast.Statement;
    public function new()
    {
        super();
    }
}
