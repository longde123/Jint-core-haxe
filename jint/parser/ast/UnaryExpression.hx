package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class UnaryExpression extends jint.parser.ast.Expression
{
    public var Operator:Int;
    public var Argument:jint.parser.ast.Expression;
    public var Prefix:Bool;
    public static function ParseUnaryOperator(op:String):Int
    {
        switch (op)
        {
            case "+":
                return jint.parser.ast.UnaryOperator.Plus;
            case "-":
                return jint.parser.ast.UnaryOperator.Minus;
            case "++":
                return jint.parser.ast.UnaryOperator.Increment;
            case "--":
                return jint.parser.ast.UnaryOperator.Decrement;
            case "~":
                return jint.parser.ast.UnaryOperator.BitwiseNot;
            case "!":
                return jint.parser.ast.UnaryOperator.LogicalNot;
            case "delete":
                return jint.parser.ast.UnaryOperator.Delete;
            case "void":
                return jint.parser.ast.UnaryOperator.Void;
            case "typeof":
                return jint.parser.ast.UnaryOperator.TypeOf;
            default:
                return throw new system.ArgumentOutOfRangeException("Invalid unary operator: " + op);
        }
    }
    public function new()
    {
        super();
        Operator = 0;
        Prefix = false;
    }
}
