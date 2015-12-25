package jint.runtime.callstack;
using StringTools;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
class CallStackElementComparer  
{
    public function Equals(x:jint.runtime.CallStackElement, y:jint.runtime.CallStackElement):Bool
    {
        return x.CallFunction.Equals(y.CallFunction);
    }
    public function GetHashCode(obj:jint.runtime.CallStackElement):Int
    {
        return obj.CallFunction.GetHashCode();
    }
    public function new()
    {
    }
}
