package jint;
using StringTools;
import system.*;
import anonymoustypes.*;

class EvalCodeScope implements system.IDisposable
{
    private var _eval:Bool;
    private var _force:Bool;
    private var _forcedRefCount:Int;
    private static var _refCount:Int;
    public function new(eval:Bool = true, force:Bool = false)
    {
        _eval = false;
        _force = false;
        _forcedRefCount = 0;
        _eval = eval;
        _force = force;
        if (_force)
        {
            _forcedRefCount = _refCount;
            _refCount = 0;
        }
        if (_eval)
        {
            _refCount++;
        }
    }
    public function Dispose():Void
    {
        if (_eval)
        {
            _refCount--;
        }
        if (_force)
        {
            _refCount = _forcedRefCount;
        }
    }
    public static var IsEvalCode(get_IsEvalCode, never):Bool;
    public static function get_IsEvalCode():Bool
    {
        return _refCount > 0;
    }

    public static var RefCount(get_RefCount, set_RefCount):Int;
    public static function get_RefCount():Int
    {
        return _refCount;
    }

    public static function set_RefCount(value:Int):Int
    {
        _refCount = value;
        return 0;
    }

    public static function cctor():Void
    {
        _refCount = 0;
    }
}
