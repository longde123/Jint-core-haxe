package jint.native;
using StringTools;
import system.*;
import anonymoustypes.*;

class Null
{
    public static var Instance:jint.native.JsValue;
    public static inline var Text:String = "null";
    public static function cctor():Void
    {
        Instance = jint.native.AbstractJsValue.Null;
    }
    public function new()
    {
    }
}
