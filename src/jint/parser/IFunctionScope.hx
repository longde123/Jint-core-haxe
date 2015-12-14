package jint.parser;
using StringTools;
import system.*;
import anonymoustypes.*;

interface IFunctionScope extends jint.parser.IVariableScope
{
    var FunctionDeclarations:Array<jint.parser.ast.FunctionDeclaration>;
}
