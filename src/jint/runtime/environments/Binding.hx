package jint.runtime.environments;
using StringTools;
import system.*;
import anonymoustypes.*;

class Binding
{
    public var Value:jint.native.JsValue;
    public var CanBeDeleted:Bool;
    public var Mutable:Bool;
    public function new()
    {
        CanBeDeleted = false;
        Mutable = false;
    }
}
