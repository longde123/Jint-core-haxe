package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class ForStatement extends jint.parser.ast.Statement
{
    public var Init:jint.parser.ast.SyntaxNode;
    public var Test:jint.parser.ast.Expression;
    public var Update:jint.parser.ast.Expression;
    public var Body:jint.parser.ast.Statement;
    public function new()
    {
        super();
    }
}
