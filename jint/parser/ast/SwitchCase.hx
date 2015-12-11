package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class SwitchCase extends jint.parser.ast.SyntaxNode
{
    public var Test:jint.parser.ast.Expression;
    public var Consequent:Array<jint.parser.ast.Statement>;
    public function new()
    {
        super();
    }
}
