package jint.runtime;
using StringTools;
import system.*;
import anonymoustypes.*;

class MruPropertyCache<TKey, TValue: ()> implements system.collections.generic.IDictionary<TKey, TValue>
{
    private var _dictionary:system.collections.generic.IDictionary<TKey, TValue>;
    private var _set:Bool;
    private var _key:TKey;
    private var _value:TValue;
    public function new()
    {
        _dictionary = new system.collections.generic.Dictionary<TKey, TValue>();
        _set = false;
    }
    public var Count(get_Count, never):Int;
    public function get_Count():Int
    {
        return _dictionary.Count;
    }

    public var IsReadOnly(get_IsReadOnly, never):Bool;
    public function get_IsReadOnly():Bool
    {
        return _dictionary.IsReadOnly;
    }

    public var Keys(get_Keys, never):Array<TKey>;
    public function get_Keys():Array<TKey>
    {
        return _dictionary.Keys;
    }

    public var Values(get_Values, never):Array<TValue>;
    public function get_Values():Array<TValue>
    {
        return _dictionary.Values;
    }

    public function Add(item:system.collections.generic.KeyValuePair<TKey, TValue>):Void
    {
        _set = true;
        _key = item.Key;
        _value = item.Value;
        _dictionary.Add(item);
    }
    public function Add_TKey_TValue(key:TKey, value:TValue):Void
    {
        _set = true;
        _key = key;
        _value = value;
        _dictionary.Add(key, value);
    }
    public function Clear():Void
    {
        _set = false;
        _key = null;
        _value = null;
        _dictionary.Clear();
    }
    public function Contains(item:system.collections.generic.KeyValuePair<TKey, TValue>):Bool
    {
        if (_set && item.Key.Equals(_key))
        {
            return true;
        }
        return _dictionary.Contains(item);
    }
    public function ContainsKey(key:TKey):Bool
    {
        if (_set && key.Equals(_key))
        {
            return true;
        }
        return _dictionary.ContainsKey(key);
    }
    public function CopyTo(array:Array<system.collections.generic.KeyValuePair<TKey, TValue>>, arrayIndex:Int):Void
    {
        _dictionary.CopyTo(array, arrayIndex);
    }
    public function Remove(item:system.collections.generic.KeyValuePair<TKey, TValue>):Bool
    {
        if (_set && item.Key.Equals(_key))
        {
            _set = false;
            _key = null;
            _value = null;
        }
        return _dictionary.Remove(item);
    }
    public function Remove_TKey(key:TKey):Bool
    {
        if (_set && key.Equals(_key))
        {
            _set = false;
            _key = null;
            _value = null;
        }
        return _dictionary.Remove(key);
    }
    public function TryGetValue(key:TKey, value:CsRef<TValue>):Bool
    {
        if (_set && key.Equals(_key))
        {
            value.Value = _value;
            return true;
        }
        return _dictionary.TryGetValue(key, value);
    }
}
