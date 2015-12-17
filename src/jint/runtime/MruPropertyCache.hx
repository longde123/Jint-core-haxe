package jint.runtime;
using StringTools;
import system.*;
import anonymoustypes.*;
import haxe.ds.HashMap;
class MruPropertyCache<TKey:{ function hashCode():Int; },TValue>   
{
    private var _dictionary : HashMap<TKey, TValue > ;
    private var _set:Bool;
    private var _key:TKey;
    private var _value:TValue;
	 
	/**
		See `Map.toString`
	**/
	public function toString() : String return "" ;
    public function new()
    {
        _dictionary = new HashMap<TKey, TValue >();
        _set = false;
		 
    }
	public inline function iterator() : HashMap<TKey, TValue >{
		return _dictionary;
	}
    public var Count(get, never):Int;
    public function get_Count():Int
    {
		var Count = 0;
		for ( v in _dictionary ) Count++;
        return Count;
    }

    public var IsReadOnly:Bool;

    public var Keys(get, never):Iterator<TKey>;
    public function get_Keys():Iterator<TKey>
    {
        return _dictionary.keys();
    }

    public var Values(get_Values, never):Iterator<TValue>;
    public function get_Values():Iterator<TValue>
    {
        return _dictionary.iterator() ;
    }

 
    public function Add(key:TKey, value:TValue):Void
    {
        _set = true;
        _key = key;
        _value = value;
        _dictionary.set(key, value);
    }
    public function Clear():Void
    {
        _set = false;
        _key = null;
        _value = null;
        _dictionary=   new HashMap<TKey, TValue >();
    }
   
    public function Contains(key:TKey):Bool
    {
        if (_set && key==(_key))
        {
            return true;
        }
        return _dictionary.exists(key);
    }
 
 
    public function Remove(key:TKey):Bool
    {
        if (_set && key==(_key))
        {
            _set = false;
            _key = null;
            _value = null;
        }
        return _dictionary.remove(key);
    }
    public function TryGetValue(key:TKey, value:TValue):Bool
    {
        if (_set && key==(_key))
        {
            value = _value;
            return true;
        }
         value = _dictionary.get(key);
		 return true;
    }
}
