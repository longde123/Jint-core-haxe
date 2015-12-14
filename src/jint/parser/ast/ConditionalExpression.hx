package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class ConditionalExpression extends jint.parser.ast.Expression
{
    public var Test:jint.parser.ast.Expression;
    public var Consequent:jint.parser.ast.Expression;
    public var Alternate:jint.parser.ast.Expression;
    public function new()
    {
        super();
    }
}
