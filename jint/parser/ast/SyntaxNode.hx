package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class SyntaxNode
{
    public var Type:Int;
    public var Range:Array<Int>;
    public var Location:jint.parser.Location;
    public function As<T: (jint.parser.ast.SyntaxNode)>():T
    {
        return this;
    }
    public function new()
    {
        Type = 0;
    }
}
