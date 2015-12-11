package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class Program extends jint.parser.ast.Statement implements jint.parser.IVariableScope implements jint.parser.IFunctionScope
{
    public function new()
    {
        super();
        Strict = false;
        VariableDeclarations = new Array<jint.parser.ast.VariableDeclaration>();
    }
    public var Body:Array<jint.parser.ast.Statement>;
    public var Comments:Array<jint.parser.Comment>;
    public var Tokens:Array<jint.parser.Token>;
    public var Errors:Array<jint.parser.ParserException>;
    public var Strict:Bool;
    public var VariableDeclarations:Array<jint.parser.ast.VariableDeclaration>;
    public var FunctionDeclarations:Array<jint.parser.ast.FunctionDeclaration>;
}
