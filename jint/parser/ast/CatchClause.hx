package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class CatchClause extends jint.parser.ast.Statement
{
    public var Param:jint.parser.ast.Identifier;
    public var Body:jint.parser.ast.BlockStatement;
    public function new()
    {
        super();
    }
}
