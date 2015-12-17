package jint.runtime.callstack;
using StringTools;
import system.*;
import anonymoustypes.*;
import haxe.ds.ObjectMap;
class JintCallStack
{
    private var _stack:Array<jint.runtime.CallStackElement>;
    private var _statistics:ObjectMap<jint.runtime.CallStackElement, Int>;
    public function Push(item:jint.runtime.CallStackElement):Int
    {
        _stack.push(item);
        if (_statistics.exits(item))
        {
            var count = _statistics.get(item);
			count++;
			_statistics.set(item,count);
			return count;
        }
        else
        {
            _statistics.set(item, 0);
            return 0;
        }
    }
    public function Pop():jint.runtime.CallStackElement
    {
        var item:jint.runtime.CallStackElement = _stack.pop();
        if (_statistics.exits(item) == 0)
        {
            _statistics.remove(item);
        }
        else
        {
            _statistics.set(item, _statistics.get(item) - 1);
        }
        return item;
    }
    public function Clear():Void
    {
        _stack = new Array<jint.runtime.CallStackElement>();
        _statistics = new ObjectMap<jint.runtime.CallStackElement, Int>();
    }
    public function toString():String
    {
        return  _stack.toString();
    }
    public function new()
    {
        _stack = new Array<jint.runtime.CallStackElement>();
        _statistics = new ObjectMap<jint.runtime.CallStackElement, Int>();
		//new jint.runtime.callstack.CallStackElementComparer());
    }
}
