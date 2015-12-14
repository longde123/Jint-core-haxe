package jint.native;
using StringTools;
import system.*;
import anonymoustypes.*;

interface IPrimitiveInstance
{
    var Type(get_Type, never):Int;
    var PrimitiveValue(get_PrimitiveValue, never):jint.native.JsValue;
}
