package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class BinaryExpression extends jint.parser.ast.Expression
{
    public var Operator:Int;
    public var Left:jint.parser.ast.Expression;
    public var Right:jint.parser.ast.Expression;
    public static function ParseBinaryOperator(op:String):Int
    {
        switch (op)
        {
            case "+":
                return jint.parser.ast.BinaryOperator.Plus;
            case "-":
                return jint.parser.ast.BinaryOperator.Minus;
            case "*":
                return jint.parser.ast.BinaryOperator.Times;
            case "/":
                return jint.parser.ast.BinaryOperator.Divide;
            case "%":
                return jint.parser.ast.BinaryOperator.Modulo;
            case "==":
                return jint.parser.ast.BinaryOperator.Equal;
            case "!=":
                return jint.parser.ast.BinaryOperator.NotEqual;
            case ">":
                return jint.parser.ast.BinaryOperator.Greater;
            case ">=":
                return jint.parser.ast.BinaryOperator.GreaterOrEqual;
            case "<":
                return jint.parser.ast.BinaryOperator.Less;
            case "<=":
                return jint.parser.ast.BinaryOperator.LessOrEqual;
            case "===":
                return jint.parser.ast.BinaryOperator.StrictlyEqual;
            case "!==":
                return jint.parser.ast.BinaryOperator.StricltyNotEqual;
            case "&":
                return jint.parser.ast.BinaryOperator.BitwiseAnd;
            case "|":
                return jint.parser.ast.BinaryOperator.BitwiseOr;
            case "^":
                return jint.parser.ast.BinaryOperator.BitwiseXOr;
            case "<<":
                return jint.parser.ast.BinaryOperator.LeftShift;
            case ">>":
                return jint.parser.ast.BinaryOperator.RightShift;
            case ">>>":
                return jint.parser.ast.BinaryOperator.UnsignedRightShift;
            case "instanceof":
                return jint.parser.ast.BinaryOperator.InstanceOf;
            case "in":
                return jint.parser.ast.BinaryOperator.In;
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
