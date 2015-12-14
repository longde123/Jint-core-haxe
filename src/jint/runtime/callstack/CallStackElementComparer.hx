package jint.runtime.callstack;
using StringTools;
import system.*;
import anonymoustypes.*;

class CallStackElementComparer implements system.collections.generic.IEqualityComparer<jint.runtime.CallStackElement>
{
    public function Equals(x:jint.runtime.CallStackElement, y:jint.runtime.CallStackElement):Bool
    {
        return x.Function.Equals(y.Function);
    }
    public function GetHashCode(obj:jint.runtime.CallStackElement):Int
    {
        return obj.Function.GetHashCode();
    }
    public function new()
    {
    }
}
