package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class Literal extends jint.parser.ast.Expression implements jint.parser.ast.IPropertyKeyExpression
{
    public var Value:Dynamic;
    public var Raw:String;
    public function GetKey():String
    {
        return Value.toString();
    }
    public function new()
    {
        super();
    }
}
