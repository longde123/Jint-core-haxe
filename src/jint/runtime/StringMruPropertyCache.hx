package jint.runtime;
using StringTools;
import haxe.ds.StringMap;
import system.*;
import anonymoustypes.*;
import haxe.ds.HashMap;
class StringMruPropertyCache<TValue>   
{
    private var _dictionary : StringMap<TValue> ;
    private var _set:Bool;
    private var _key:String;
    private var _value:TValue;
	 
	/**
		See `Map.toString`
	**/
	public function toString() : String return "" ;
    public function new()
    {
        _dictionary = new StringMap<TValue>();
        _set = false;
		 
    }
	public inline function  Cache() :StringMap<TValue>{
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

    public var Keys(get, never):Iterator<String>;
    public function get_Keys():Iterator<String>
    {
        return _dictionary.keys();
    }

    public var Values(get_Values, never):Iterator<TValue>;
    public function get_Values():Iterator<TValue>
    {
        return _dictionary.iterator() ;
    }

 
    public function Add(key:String, value:TValue):Void
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
        _dictionary=   new StringMap< TValue >();
    }
   
    public function Contains(key:String):Bool
    {
        if (_set && key==(_key))
        {
            return true;
        }
        return _dictionary.exists(key);
    }
 
 
    public function Remove(key:String):Bool
    {
        if (_set && key==(_key))
        {
            _set = false;
            _key = null;
            _value = null;
        }
        return _dictionary.remove(key);
    }
	
	public function Get(key:String):TValue
    {
		if (_set && key==(_key))
        { 
            return _value;
        }
		 return  _dictionary.get(key);
    }
   
}
