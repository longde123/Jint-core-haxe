package jint.native.array;
using StringTools;
import haxe.ds.*;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
import jint.runtime.IntMruPropertyCache;
class ArrayInstance extends jint.native.object.ObjectInstance
{
    private var _engine:jint.Engine;
    private var _array:jint.runtime.IntMruPropertyCache< jint.runtime.descriptors.PropertyDescriptor>;
    private var _length:jint.runtime.descriptors.PropertyDescriptor;
    public function new(engine:jint.Engine)
    {
        super(engine);
        _array = new jint.runtime.IntMruPropertyCache< jint.runtime.descriptors.PropertyDescriptor>();
        _engine = engine;
    }
    override public function get_JClass():String
    {
        return "Array";
    }

    override public function Put(propertyName:String, value:jint.native.JsValue, throwOnError:Bool):Void
    {
        if (!CanPut(propertyName))
        {
            if (throwOnError)
            {
                throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
            }
            return;
        }
        var ownDesc:jint.runtime.descriptors.PropertyDescriptor = GetOwnProperty(propertyName);
        if (ownDesc.IsDataDescriptor())
        {
            var valueDesc:jint.runtime.descriptors.PropertyDescriptor = new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(value, null, null, null);
            DefineOwnProperty(propertyName, valueDesc, throwOnError);
            return;
        }
        var desc:jint.runtime.descriptors.PropertyDescriptor = GetProperty(propertyName);
        if (desc.IsAccessorDescriptor())
        {
            var setter:jint.native.ICallable = desc.JSet.TryCast(jint.native.ICallable);
            setter.Call(this, [ value ]);
        }
        else
        {
            var newDesc:jint.runtime.descriptors.PropertyDescriptor = new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(value, (true), (true), (true));
            DefineOwnProperty(propertyName, newDesc, throwOnError);
        }
    }
    override public function DefineOwnProperty(propertyName:String, desc:jint.runtime.descriptors.PropertyDescriptor, throwOnError:Bool):Bool
    {
        var oldLenDesc:jint.runtime.descriptors.PropertyDescriptor = GetOwnProperty("length");
        var oldLen:Int = Std.int(jint.runtime.TypeConverter.ToNumber(oldLenDesc.Value));
        var index:Null<Int> =(0);
        if (propertyName == "length")
        {
            if (desc.Value == null)
            {
                return super.DefineOwnProperty("length", desc, throwOnError);
            }
            var newLenDesc:jint.runtime.descriptors.PropertyDescriptor = new jint.runtime.descriptors.PropertyDescriptor().Creator(desc);
            var newLen:Int = jint.runtime.TypeConverter.ToUint32(desc.Value);
            if (newLen != jint.runtime.TypeConverter.ToNumber(desc.Value))
            {
                return throw new jint.runtime.JavaScriptException().Creator(_engine.RangeError);
            }
            newLenDesc.Value = newLen;
            if (newLen >= oldLen)
            {
                return super.DefineOwnProperty("length", _length = newLenDesc, throwOnError);
            }
            if (!oldLenDesc.Writable)
            {
                if (throwOnError)
                {
                    return throw new jint.runtime.JavaScriptException().Creator(_engine.TypeError);
                }
                return false;
            }
            var newWritable:Bool;
            if (newLenDesc.Writable==null || newLenDesc.Writable)
            {
                newWritable = true;
            }
            else
            {
                newWritable = false;
                newLenDesc.Writable =  (true);
            }
            var succeeded:Bool = super.DefineOwnProperty("length", _length = newLenDesc, throwOnError);
            if (!succeeded)
            {
                return false;
            }
            if (_array.Count < oldLen - newLen)
            { 
                for (key in _array.Keys)
                {
                    var keyIndex:Null<Int> =(0);
                    if (IsArrayIndex(key, keyIndex) && keyIndex >= newLen && keyIndex < oldLen)
                    {
                        var deleteSucceeded:Bool = Delete(Std.string(key), false);
                        if (!deleteSucceeded)
                        {
                            newLenDesc.Value = keyIndex + 1;
                            if (!newWritable)
                            {
                                newLenDesc.Writable = (false);
                            }
                            super.DefineOwnProperty("length", _length = newLenDesc, false);
                            if (throwOnError)
                            {
                                return throw new jint.runtime.JavaScriptException().Creator(_engine.TypeError);
                            }
                            return false;
                        }
                    }
                }
            }
            else
            {
                while (newLen < oldLen)
                {
                    oldLen--;
                    var deleteSucceeded:Bool = Delete(jint.runtime.TypeConverter.toString(oldLen), false);
                    if (!deleteSucceeded)
                    {
                        newLenDesc.Value = oldLen + 1;
                        if (!newWritable)
                        {
                            newLenDesc.Writable = (false);
                        }
                        super.DefineOwnProperty("length", _length = newLenDesc, false);
                        if (throwOnError)
                        {
                            return throw new jint.runtime.JavaScriptException().Creator(_engine.TypeError);
                        }
                        return false;
                    }
                }
            }
            if (!newWritable)
            {
                DefineOwnProperty("length", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(null, (false), null, null), false);
            }
            return true;
        }
        else if (IsArrayIndex(propertyName, index))
        {
            if (index >= oldLen && !oldLenDesc.Writable)
            {
                if (throwOnError)
                {
                    return throw new jint.runtime.JavaScriptException().Creator(_engine.TypeError);
                }
                return false;
            }
            var succeeded:Bool = super.DefineOwnProperty(propertyName, desc, false);
            if (!succeeded)
            {
                if (throwOnError)
                {
                    return throw new jint.runtime.JavaScriptException().Creator(_engine.TypeError);
                }
                return false;
            }
            if (index >= oldLen)
            {
                oldLenDesc.Value = index + 1;
                super.DefineOwnProperty("length", _length = oldLenDesc, false);
            }
            return true;
        }
        return super.DefineOwnProperty(propertyName, desc, throwOnError);
    }
    private function GetLength():Int
    {
        return jint.runtime.TypeConverter.ToUint32(_length.Value);
    }
    override public function GetOwnProperties():haxe.ds.StringMap<jint.runtime.descriptors.PropertyDescriptor>
    { 
        var properties:StringMap<jint.runtime.descriptors.PropertyDescriptor> = new StringMap<jint.runtime.descriptors.PropertyDescriptor>();
        var cache = _array.Cache();
		for (entry in cache.keys())
        {
            properties.set(Std.string(entry), cache.get(entry));
        }
		var cache2 = super.GetOwnProperties();
        for (entry in cache2.keys())
        {
            properties.set(entry,  cache2.get(entry));
        }
        return properties;
    }
    override public function GetOwnProperty(propertyName:String):jint.runtime.descriptors.PropertyDescriptor
    {
        var index:Null<Int> = (0);
        if (IsArrayIndex(propertyName, index))
        {
            var result:jint.runtime.descriptors.PropertyDescriptor = null;
            if (_array.TryGetValue(index, result))
            {
                return result;
            }
            else
            {
                return jint.runtime.descriptors.PropertyDescriptor.Undefined;
            }
        }
        return super.GetOwnProperty(propertyName);
    }
    override public function SetOwnProperty(propertyName:String, desc:jint.runtime.descriptors.PropertyDescriptor):Void
    {
        var index:Null<Int> = (0);
        if (IsArrayIndex(propertyName, index))
        {
            _array.Add(index, desc);
        }
        else
        {
            if (propertyName == "length")
            {
                _length = desc;
            }
            super.SetOwnProperty(propertyName, desc);
        }
    }
    override public function HasOwnProperty(p:String):Bool
    {
        var index:Null<Int> = (0);
        if (IsArrayIndex(p, index))
        {
            return index < GetLength() && _array.Contains(index);
        }
        return super.HasOwnProperty(p);
    }
    override public function RemoveOwnProperty(p:String):Void
    {
        var index:Null<Int> =(0);
        if (IsArrayIndex(p, index))
        {
            _array.Remove(index);
        }
        super.RemoveOwnProperty(p);
    }
    public static function IsArrayIndex(p:jint.native.JsValue, index:Null<Int>):Bool
    {
        index = ParseArrayIndex(jint.runtime.TypeConverter.toString(p));
        return index>0&&index<Math.POSITIVE_INFINITY;
    }
    public static function ParseArrayIndex(p:String):Int
    {
        
        return Std.parseInt(p);
    }
}
