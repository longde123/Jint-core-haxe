package jint.runtime.interop;
using StringTools;
import system.*;
import anonymoustypes.*;

interface IObjectConverter
{
    function TryConvert(value:Dynamic, result:jint.native.JsValue):Bool;
}
