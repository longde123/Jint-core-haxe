package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class LabelledStatement extends jint.parser.ast.Statement
{
    public var Label:jint.parser.ast.Identifier;
    public var Body:jint.parser.ast.Statement;
    public function new()
    {
        super();
    }
}
