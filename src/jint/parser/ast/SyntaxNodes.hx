package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class SyntaxNodes
{
    public static inline var AssignmentExpression:Int = 1;
    public static inline var ArrayExpression:Int = 2;
    public static inline var BlockStatement:Int = 3;
    public static inline var BinaryExpression:Int = 4;
    public static inline var BreakStatement:Int = 5;
    public static inline var CallExpression:Int = 6;
    public static inline var CatchClause:Int = 7;
    public static inline var ConditionalExpression:Int = 8;
    public static inline var ContinueStatement:Int = 9;
    public static inline var DoWhileStatement:Int = 10;
    public static inline var DebuggerStatement:Int = 11;
    public static inline var EmptyStatement:Int = 12;
    public static inline var ExpressionStatement:Int = 13;
    public static inline var ForStatement:Int = 14;
    public static inline var ForInStatement:Int = 15;
    public static inline var FunctionDeclaration:Int = 16;
    public static inline var FunctionExpression:Int = 17;
    public static inline var Identifier:Int = 18;
    public static inline var IfStatement:Int = 19;
    public static inline var Literal:Int = 20;
    public static inline var RegularExpressionLiteral:Int = 21;
    public static inline var LabeledStatement:Int = 22;
    public static inline var LogicalExpression:Int = 23;
    public static inline var MemberExpression:Int = 24;
    public static inline var NewExpression:Int = 25;
    public static inline var ObjectExpression:Int = 26;
    public static inline var Program:Int = 27;
    public static inline var Property:Int = 28;
    public static inline var ReturnStatement:Int = 29;
    public static inline var SequenceExpression:Int = 30;
    public static inline var SwitchStatement:Int = 31;
    public static inline var SwitchCase:Int = 32;
    public static inline var ThisExpression:Int = 33;
    public static inline var ThrowStatement:Int = 34;
    public static inline var TryStatement:Int = 35;
    public static inline var UnaryExpression:Int = 36;
    public static inline var UpdateExpression:Int = 37;
    public static inline var VariableDeclaration:Int = 38;
    public static inline var VariableDeclarator:Int = 39;
    public static inline var WhileStatement:Int = 40;
    public static inline var WithStatement:Int = 41;

    public static function ToString(e:Int):String
    {
        switch (e)
        {
            case 1: return "AssignmentExpression";
            case 2: return "ArrayExpression";
            case 3: return "BlockStatement";
            case 4: return "BinaryExpression";
            case 5: return "BreakStatement";
            case 6: return "CallExpression";
            case 7: return "CatchClause";
            case 8: return "ConditionalExpression";
            case 9: return "ContinueStatement";
            case 10: return "DoWhileStatement";
            case 11: return "DebuggerStatement";
            case 12: return "EmptyStatement";
            case 13: return "ExpressionStatement";
            case 14: return "ForStatement";
            case 15: return "ForInStatement";
            case 16: return "FunctionDeclaration";
            case 17: return "FunctionExpression";
            case 18: return "Identifier";
            case 19: return "IfStatement";
            case 20: return "Literal";
            case 21: return "RegularExpressionLiteral";
            case 22: return "LabeledStatement";
            case 23: return "LogicalExpression";
            case 24: return "MemberExpression";
            case 25: return "NewExpression";
            case 26: return "ObjectExpression";
            case 27: return "Program";
            case 28: return "Property";
            case 29: return "ReturnStatement";
            case 30: return "SequenceExpression";
            case 31: return "SwitchStatement";
            case 32: return "SwitchCase";
            case 33: return "ThisExpression";
            case 34: return "ThrowStatement";
            case 35: return "TryStatement";
            case 36: return "UnaryExpression";
            case 37: return "UpdateExpression";
            case 38: return "VariableDeclaration";
            case 39: return "VariableDeclarator";
            case 40: return "WhileStatement";
            case 41: return "WithStatement";
            default: throw new InvalidOperationException(Std.string(e));
        }
    }

    public static function Parse(s:String):Int
    {
        switch (s)
        {
            case "AssignmentExpression": return 1;
            case "ArrayExpression": return 2;
            case "BlockStatement": return 3;
            case "BinaryExpression": return 4;
            case "BreakStatement": return 5;
            case "CallExpression": return 6;
            case "CatchClause": return 7;
            case "ConditionalExpression": return 8;
            case "ContinueStatement": return 9;
            case "DoWhileStatement": return 10;
            case "DebuggerStatement": return 11;
            case "EmptyStatement": return 12;
            case "ExpressionStatement": return 13;
            case "ForStatement": return 14;
            case "ForInStatement": return 15;
            case "FunctionDeclaration": return 16;
            case "FunctionExpression": return 17;
            case "Identifier": return 18;
            case "IfStatement": return 19;
            case "Literal": return 20;
            case "RegularExpressionLiteral": return 21;
            case "LabeledStatement": return 22;
            case "LogicalExpression": return 23;
            case "MemberExpression": return 24;
            case "NewExpression": return 25;
            case "ObjectExpression": return 26;
            case "Program": return 27;
            case "Property": return 28;
            case "ReturnStatement": return 29;
            case "SequenceExpression": return 30;
            case "SwitchStatement": return 31;
            case "SwitchCase": return 32;
            case "ThisExpression": return 33;
            case "ThrowStatement": return 34;
            case "TryStatement": return 35;
            case "UnaryExpression": return 36;
            case "UpdateExpression": return 37;
            case "VariableDeclaration": return 38;
            case "VariableDeclarator": return 39;
            case "WhileStatement": return 40;
            case "WithStatement": return 41;
            default: throw new InvalidOperationException(s);
        }
    }

    public static function Values():Array<Int>
    {
        return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41];
    }
}
