package jint.native.error;
using StringTools;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
class ErrorInstance extends jint.native.object.ObjectInstance
{
    public function new(engine:jint.Engine, name:String)
    {
        super(engine);
        FastAddProperty("name", name, true, false, true);
    }
    override public function get_Class():String
    {
        return "Error";
    }

    override public function toString():String
    {
        return Engine.Error.PrototypeObject.toString(this, jint.runtime.Arguments.Empty).ToObject().toString();
    }
}
