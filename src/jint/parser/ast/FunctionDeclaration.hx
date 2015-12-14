package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class FunctionDeclaration extends jint.parser.ast.Statement implements jint.parser.IFunctionDeclaration
{
    public function new()
    {
        super();
        Generator = false;
        Expression = false;
        VariableDeclarations = new Array<jint.parser.ast.VariableDeclaration>();
    }
    public var Id:jint.parser.ast.Identifier;
    public var Parameters:Array<jint.parser.ast.Identifier>;
    public var Body:jint.parser.ast.Statement;
    public var Strict:Bool;
    public var VariableDeclarations:Array<jint.parser.ast.VariableDeclaration>;
    public var Defaults:Array<jint.parser.ast.Expression>;
    public var Rest:jint.parser.ast.SyntaxNode;
    public var Generator:Bool;
    public var Expression:Bool;
    public var FunctionDeclarations:Array<jint.parser.ast.FunctionDeclaration>;
}
