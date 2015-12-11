package jint.parser.ast;
using StringTools;
import system.*;
import anonymoustypes.*;

class Identifier extends jint.parser.ast.Expression implements jint.parser.ast.IPropertyKeyExpression
{
    public var Name:String;
    public function GetKey():String
    {
        return Name;
    }
    public function new()
    {
        super();
    }
}
