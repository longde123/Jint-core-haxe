package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class VariableDeclaration extends jint.parser.ast.Statement
{
    public var Declarations:Array<jint.parser.ast.VariableDeclarator>;
    public var Kind:String;
    public function new()
    {
        super();
    }
}
