package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class CallExpression extends jint.parser.ast.Expression
{
    public var Callee:jint.parser.ast.Expression;
    public var Arguments:Array<jint.parser.ast.Expression>;
    public function new()
    {
        super();
    }
}
