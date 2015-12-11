package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class ForInStatement extends jint.parser.ast.Statement
{
    public var Left:jint.parser.ast.SyntaxNode;
    public var Right:jint.parser.ast.Expression;
    public var Body:jint.parser.ast.Statement;
    public var Each:Bool;
    public function new()
    {
        super();
        Each = false;
    }
}
