package jint.runtime;

/**
 * ...
 * @author paling
 */
 
using StringTools;
import haxe.ds.StringMap;
import jint.native.Null;
import system.*;
import anonymoustypes.*;
import haxe.ds.IntMap;
class IntMruPropertyCache<TValue>   
{
    private var _dictionary : IntMap<TValue> ;
    private var _set:Bool;
    private var _key:Int;
    private var _value:TValue;
	 
	/**
		See `Map.toString`
	**/
	public function toString() : String return "" ;
    public function new()
    {
        _dictionary = new IntMap<TValue>();
        _set = false;
		 
    }
	public inline function  Cache() :IntMap<TValue>{
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

    public var Keys(get, never):Iterator<Int>;
    public function get_Keys():Iterator<Int>
    {
        return _dictionary.keys();
    }

    public var Values(get_Values, never):Iterator<TValue>;
    public function get_Values():Iterator<TValue>
    {
        return _dictionary.iterator() ;
    }

 
    public function Add(key:Int, value:TValue):Void
    {
        _set = true;
        _key = key;
        _value = value;
        _dictionary.set(key, value);
    }
    public function Clear():Void
    {
        _set = false;
        _key = 0;// null;
        _value = null;
        _dictionary=   new IntMap< TValue >();
    }
   
    public function Contains(key:Int):Bool
    {
        if (_set && key==(_key))
        {
            return true;
        }
        return _dictionary.exists(key);
    }
 
 
    public function Remove(key:Int):Bool
    {
        if (_set && key==(_key))
        {
            _set = false;
            _key = 0;//null; //todo
            _value = null;
        }
        return _dictionary.remove(key);
    }
    public function TryGetValue(key:Int, value:TValue):Bool
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
