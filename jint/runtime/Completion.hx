package jint.runtime;
using StringTools;
import system.*;
import anonymoustypes.*;

class Completion
{
    public static var Normal:String;
    public static var Break:String;
    public static var Continue:String;
    public static var Return:String;
    public static var Throw:String;
    public function new(type:String, value:jint.native.JsValue, identifier:String)
    {
        Type = type;
        Value = value;
        Identifier = identifier;
    }
    public var Type:String;
    public var Value:jint.native.JsValue;
    public var Identifier:String;
    public function GetValueOrDefault():jint.native.JsValue
    {
        return Value != null ? Value : jint.native.Undefined.Instance;
    }
    public var Location:jint.parser.Location;
    public static function cctor():Void
    {
        Normal = "normal";
        Break = "break";
        Continue = "continue";
        Return = "return";
        Throw = "throw";
    }
}
