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
    override public function get_Class():String
    {
        return "Boolean";
    }

    var Type(get_Type, never):Int;
    function get_Type():Int
    {
        return jint.runtime.Types.Boolean;
    }

    var PrimitiveValue(get_PrimitiveValue, never):jint.native.JsValue;
    function get_PrimitiveValue():jint.native.JsValue
    {
        return PrimitiveValue;
    }

    public var PrimitiveValue:jint.native.JsValue;
}
