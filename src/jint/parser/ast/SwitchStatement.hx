package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class SwitchStatement extends jint.parser.ast.Statement
{
    public var Discriminant:jint.parser.ast.Expression;
    public var Cases:Array<jint.parser.ast.SwitchCase>;
    public function new()
    {
        super();
    }
}
