package jint.native;
using StringTools;
import system.*;
import anonymoustypes.*;

interface IConstructor
{
    function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue;
    function Construct(arguments:Array<jint.native.JsValue>):jint.native.object.ObjectInstance;
}
