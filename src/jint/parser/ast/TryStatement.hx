package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class TryStatement extends jint.parser.ast.Statement
{
    public var Block:jint.parser.ast.Statement;
    public var GuardedHandlers:Array<jint.parser.ast.Statement>;
    public var Handlers:Array<jint.parser.ast.CatchClause>;
    public var Finalizer:jint.parser.ast.Statement;
    public function new()
    {
        super();
    }
}
