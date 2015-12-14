package jint;
using StringTools;
import system.*;
import anonymoustypes.*;

class StrictModeScope implements system.IDisposable
{
    private var _strict:Bool;
    private var _force:Bool;
    private var _forcedRefCount:Int;
    private static var _refCount:Int;
    public function new(strict:Bool = true, force:Bool = false)
    {
        _strict = false;
        _force = false;
        _forcedRefCount = 0;
        _strict = strict;
        _force = force;
        if (_force)
        {
            _forcedRefCount = _refCount;
            _refCount = 0;
        }
        if (_strict)
        {
            _refCount++;
        }
    }
    public function Dispose():Void
    {
        if (_strict)
        {
            _refCount--;
        }
        if (_force)
        {
            _refCount = _forcedRefCount;
        }
    }
    public static var IsStrictModeCode(get_IsStrictModeCode, never):Bool;
    public static function get_IsStrictModeCode():Bool
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
