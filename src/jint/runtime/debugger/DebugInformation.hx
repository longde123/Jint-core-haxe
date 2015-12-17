package jint.runtime.debugger;
using StringTools;
import system.*;
import anonymoustypes.*;
import haxe.ds.StringMap
class DebugInformation extends system.EventArgs
{
    public var CallStack:Array<String>;
    public var CurrentStatement:jint.parser.ast.Statement;
    public var Locals:StringMap< jint.native.JsValue>;
    public var Globals:StringMap< jint.native.JsValue>;
    public function new()
    {
        super();
    }
}
