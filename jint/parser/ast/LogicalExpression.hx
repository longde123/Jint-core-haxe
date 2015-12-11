package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class LogicalExpression extends jint.parser.ast.Expression
{
    public var Operator:Int;
    public var Left:jint.parser.ast.Expression;
    public var Right:jint.parser.ast.Expression;
    public static function ParseLogicalOperator(op:String):Int
    {
        switch (op)
        {
            case "&&":
                return jint.parser.ast.LogicalOperator.LogicalAnd;
            case "||":
                return jint.parser.ast.LogicalOperator.LogicalOr;
            default:
                return throw new system.ArgumentOutOfRangeException("Invalid binary operator: " + op);
        }
    }
    public function new()
    {
        super();
        Operator = 0;
    }
}
