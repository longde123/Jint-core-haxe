package jint.native;
using StringTools;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
class JsValue_JsValueDebugView
{
    public var Value:String;
    public function new(value:jint.native.JsValue)
    {
        switch (value.GetJType())
        {
            case jint.runtime.Types.None:
                Value = "None";
            case jint.runtime.Types.Undefined:
                Value = "undefined";
            case jint.runtime.Types.Null:
                Value = "null";
            case jint.runtime.Types.Boolean:
                Value = value.AsBoolean() + " (bool)";
            case jint.runtime.Types.String:
                Value = value.AsString() + " (string)";
            case jint.runtime.Types.Number:
                Value = value.AsNumber() + " (number)";
            case jint.runtime.Types.Object:
                Value = system.Cs2Hx.GetType(value.AsObject()).Name;
            default:
                Value = "Unknown";
        }
    }
}
