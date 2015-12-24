package jint.native.boolean;
using StringTools;
import system.*;
import anonymoustypes.*;

class BooleanInstance extends jint.native.object.ObjectInstance implements jint.native.IPrimitiveInstance
{
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    override public function get_JClass():String
    {
        return "Boolean";
    }

    public var JType(get, never):Int;
    public function get_JType():Int
    {
        return jint.runtime.Types.Boolean;
    }

 
    public var PrimitiveValue:jint.native.JsValue;
}
