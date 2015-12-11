package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class AssignmentExpression extends jint.parser.ast.Expression
{
    public var Operator:Int;
    public var Left:jint.parser.ast.Expression;
    public var Right:jint.parser.ast.Expression;
    public static function ParseAssignmentOperator(op:String):Int
    {
        switch (op)
        {
            case "=":
                return jint.parser.ast.AssignmentOperator.Assign;
            case "+=":
                return jint.parser.ast.AssignmentOperator.PlusAssign;
            case "-=":
                return jint.parser.ast.AssignmentOperator.MinusAssign;
            case "*=":
                return jint.parser.ast.AssignmentOperator.TimesAssign;
            case "/=":
                return jint.parser.ast.AssignmentOperator.DivideAssign;
            case "%=":
                return jint.parser.ast.AssignmentOperator.ModuloAssign;
            case "&=":
                return jint.parser.ast.AssignmentOperator.BitwiseAndAssign;
            case "|=":
                return jint.parser.ast.AssignmentOperator.BitwiseOrAssign;
            case "^=":
                return jint.parser.ast.AssignmentOperator.BitwiseXOrAssign;
            case "<<=":
                return jint.parser.ast.AssignmentOperator.LeftShiftAssign;
            case ">>=":
                return jint.parser.ast.AssignmentOperator.RightShiftAssign;
            case ">>>=":
                return jint.parser.ast.AssignmentOperator.UnsignedRightShiftAssign;
            default:
                return throw new system.ArgumentOutOfRangeException("Invalid assignment operator: " + op);
        }
    }
    public function new()
    {
        super();
        Operator = 0;
    }
}
