package jint.runtime;
using StringTools;
import system.*;
import anonymoustypes.*;

class RecursionDepthOverflowException extends system.Exception
{
    public var CallChain:String;
    public var CallExpressionReference:String;
    public function new(currentStack:jint.runtime.callstack.JintCallStack, currentExpressionReference:String)
    {
        super("The recursion is forbidden by script host.");
        CallExpressionReference = currentExpressionReference;
        CallChain = currentStack.toString();
    }
}
