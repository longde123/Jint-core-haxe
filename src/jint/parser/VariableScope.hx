package jint.parser;
using StringTools;
import system.*;
import anonymoustypes.*;

class VariableScope implements jint.parser.IVariableScope
{
    public function new()
    {
        VariableDeclarations = new Array<jint.parser.ast.VariableDeclaration>();
    }
    public var VariableDeclarations:Array<jint.parser.ast.VariableDeclaration>;
}
