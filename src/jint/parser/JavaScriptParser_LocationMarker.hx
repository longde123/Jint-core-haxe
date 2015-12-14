package jint.parser;
using StringTools;
import system.*;
import anonymoustypes.*;

class JavaScriptParser_LocationMarker
{
    private var _marker:Array<Int>;
    public function new(index:Int, lineNumber:Int, lineStart:Int)
    {
        _marker = [ index, lineNumber, index - lineStart, 0, 0, 0 ];
    }
    public function End(index:Int, lineNumber:Int, lineStart:Int):Void
    {
        _marker[3] = index;
        _marker[4] = lineNumber;
        _marker[5] = index - lineStart;
    }
    public function Apply(node:jint.parser.ast.SyntaxNode, extra:jint.parser.JavaScriptParser_Extra, postProcess:(jint.parser.ast.SyntaxNode -> jint.parser.ast.SyntaxNode)):Void
    {
        if (extra.Range.length > 0)
        {
            node.Range = [ _marker[0], _marker[3] ];
        }
        if (extra.LocHasValue)
        {
            node.Location = new jint.parser.Location();
            node.Location.Start = new jint.parser.Position();
            node.Location.Start.Line = _marker[1];
            node.Location.Start.Column = _marker[2];
            node.Location.End = new jint.parser.Position();
            node.Location.End.Line = _marker[4];
            node.Location.End.Column = _marker[5];
        }
        node = postProcess(node);
    }
}
