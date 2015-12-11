package jint.runtime.debugger;
using StringTools;
import system.*;
import anonymoustypes.*;

class DebugInformation extends system.EventArgs
{
    public var CallStack:Array<String>;
    public var CurrentStatement:jint.parser.ast.Statement;
    public var Locals:system.collections.generic.Dictionary<String, jint.native.JsValue>;
    public var Globals:system.collections.generic.Dictionary<String, jint.native.JsValue>;
    public function new()
    {
        super();
    }
}
