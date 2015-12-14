package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class Property extends jint.parser.ast.Expression
{
    public var Kind:Int;
    public var Key:jint.parser.ast.IPropertyKeyExpression;
    public var Value:jint.parser.ast.Expression;
    public function new()
    {
        super();
        Kind = 0;
    }
}
