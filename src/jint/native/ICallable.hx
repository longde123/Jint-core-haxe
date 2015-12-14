package jint.native;
using StringTools;
import system.*;
import anonymoustypes.*;

interface ICallable
{
    function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue;
}
