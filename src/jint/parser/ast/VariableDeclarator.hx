package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class VariableDeclarator extends jint.parser.ast.Expression
{
    public var Id:jint.parser.ast.Identifier;
    public var Init:jint.parser.ast.Expression;
    public function new()
    {
        super();
    }
}
