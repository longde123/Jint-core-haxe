package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class ArrayExpression extends jint.parser.ast.Expression
{
    public var Elements:Array<jint.parser.ast.Expression>;
    public function new()
    {
        super();
    }
}
