package jint.parser;
using StringTools;
import system.*;
import anonymoustypes.*;

class FunctionScope implements jint.parser.IFunctionScope
{
    public function new()
    {
        FunctionDeclarations = new Array<jint.parser.ast.FunctionDeclaration>();
    }
    public var FunctionDeclarations:Array<jint.parser.ast.FunctionDeclaration>;
    public var VariableDeclarations:Array<jint.parser.ast.VariableDeclaration>;
}
