package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class IfStatement extends jint.parser.ast.Statement
{
    public var Test:jint.parser.ast.Expression;
    public var Consequent:jint.parser.ast.Statement;
    public var Alternate:jint.parser.ast.Statement;
    public function new()
    {
        super();
    }
}
