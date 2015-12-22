package jint.runtime;
using StringTools;
import system.*;
import anonymoustypes.*;

class CallStackElement
{
    private var _shortDescription:String;
    public function new(callExpression:jint.parser.ast.CallExpression, _function:jint.native.JsValue, shortDescription:String)
    {
        _shortDescription = shortDescription;
        CallExpression = callExpression;
        CallFunction = _function;
    }
    public var CallExpression:jint.parser.ast.CallExpression;
    public var CallFunction:jint.native.JsValue;
    public function toString():String
    {
        return _shortDescription;
    }
}
