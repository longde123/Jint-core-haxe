package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class MemberExpression extends jint.parser.ast.Expression
{
    public var Object:jint.parser.ast.Expression;
    public var Property:jint.parser.ast.Expression;
    public var Computed:Bool;
    public function new()
    {
        super();
        Computed = false;
    }
}
