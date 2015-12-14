package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class ObjectExpression extends jint.parser.ast.Expression
{
    public var Properties:Array<jint.parser.ast.Property>;
    public function new()
    {
        super();
    }
}
