package jint.runtime.environments;
using StringTools;
import system.*;
import anonymoustypes.*;

class ExecutionContext
{
    public var LexicalEnvironment:jint.runtime.environments.LexicalEnvironment;
    public var VariableEnvironment:jint.runtime.environments.LexicalEnvironment;
    public var ThisBinding:jint.native.JsValue;
    public function new()
    {
    }
}
