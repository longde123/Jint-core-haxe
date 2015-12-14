package jint.runtime;
using StringTools;
import system.*;
import anonymoustypes.*;

class Arguments
{
    public static var Empty:Array<jint.native.JsValue>;
    public static function From(o:Array<jint.native.JsValue>):Array<jint.native.JsValue>
    {
        return o;
    }
    public static function At__Int32_JsValue(args:Array<jint.native.JsValue>, index:Int, undefinedValue:jint.native.JsValue):jint.native.JsValue
    {
        return args.length > index ? args[index] : undefinedValue;
    }
    public static function At(args:Array<jint.native.JsValue>, index:Int):jint.native.JsValue
    {
        return jint.runtime.Arguments.At__Int32_JsValue(args, index, jint.native.Undefined.Instance);
    }
    public static function cctor():Void
    {
        Empty = [  ];
    }
    public function new()
    {
    }
}
