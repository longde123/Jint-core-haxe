package jint.native;
using StringTools;
import system.*;
import anonymoustypes.*;

interface IPrimitiveInstance
{
    var JType(get, never):Int;
    var PrimitiveValue:jint.native.JsValue;
}
