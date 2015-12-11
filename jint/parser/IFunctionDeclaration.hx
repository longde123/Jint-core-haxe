package jint.parser;
using StringTools;
import system.*;
import anonymoustypes.*;

interface IFunctionDeclaration implements jint.parser.IFunctionScope
{
    var Id:jint.parser.ast.Identifier;
    var Parameters:Array<jint.parser.ast.Identifier>;
    var Body:jint.parser.ast.Statement;
    var Strict:Bool;
}
