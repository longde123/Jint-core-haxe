package jint.native;
using StringTools;
import system.*;
import anonymoustypes.*;

class Undefined
{
    public static var Instance:jint.native.JsValue;
    public static inline var Text:String = "undefined";
    public static function cctor():Void
    {
        Instance = jint.native.JsValue.Undefined;
    }
    public function new()
    {
    }
}
