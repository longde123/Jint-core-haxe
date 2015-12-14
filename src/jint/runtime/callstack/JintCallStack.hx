package jint.runtime.callstack;
using StringTools;
import system.*;
import anonymoustypes.*;

class JintCallStack
{
    private var _stack:Array<jint.runtime.CallStackElement>;
    private var _statistics:system.collections.generic.Dictionary<jint.runtime.CallStackElement, Int>;
    public function Push(item:jint.runtime.CallStackElement):Int
    {
        _stack.push(item);
        if (_statistics.ContainsKey(item))
        {
            return ++_statistics.GetValue_TKey(item);
        }
        else
        {
            _statistics.Add(item, 0);
            return 0;
        }
    }
    public function Pop():jint.runtime.CallStackElement
    {
        var item:jint.runtime.CallStackElement = _stack.pop();
        if (_statistics.GetValue_TKey(item) == 0)
        {
            _statistics.Remove(item);
        }
        else
        {
            _statistics.SetValue(item, _statistics.GetValue_TKey(item) - 1);
        }
        return item;
    }
    public function Clear():Void
    {
        _stack.Clear();
        _statistics.Clear();
    }
    public function toString():String
    {
        return system.Cs2Hx.Join("->", system.linq.Enumerable.ToArray(system.linq.Enumerable.Reverse(system.linq.Enumerable.Select(_stack, function (cse:jint.runtime.CallStackElement):String { return cse.toString(); } ))));
    }
    public function new()
    {
        _stack = new Array<jint.runtime.CallStackElement>();
        _statistics = new system.collections.generic.Dictionary<jint.runtime.CallStackElement, Int>(new jint.runtime.callstack.CallStackElementComparer());
    }
}
