package jint.native.array;
using StringTools;
import system.*;
import anonymoustypes.*;

class ArrayInstance extends jint.native.object.ObjectInstance
{
    private var _engine:jint.Engine;
    private var _array:system.collections.generic.IDictionary<Int, jint.runtime.descriptors.PropertyDescriptor>;
    private var _length:jint.runtime.descriptors.PropertyDescriptor;
    public function new(engine:jint.Engine)
    {
        super(engine);
        _array = new jint.runtime.MruPropertyCache<Int, jint.runtime.descriptors.PropertyDescriptor>();
        _engine = engine;
    }
    override public function get_Class():String
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
            var valueDesc:jint.runtime.descriptors.PropertyDescriptor = new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(value, new Nullable_Bool(), new Nullable_Bool(), new Nullable_Bool());
            DefineOwnProperty(propertyName, valueDesc, throwOnError);
            return;
        }
        var desc:jint.runtime.descriptors.PropertyDescriptor = GetProperty(propertyName);
        if (desc.IsAccessorDescriptor())
        {
            var setter:jint.native.ICallable = desc.Set.TryCast();
            setter.Call(new jint.native.JsValue().Creator_ObjectInstance(this), [ value ]);
        }
        else
        {
            var newDesc:jint.runtime.descriptors.PropertyDescriptor = new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(value, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true));
            DefineOwnProperty(propertyName, newDesc, throwOnError);
        }
    }
    override public function DefineOwnProperty(propertyName:String, desc:jint.runtime.descriptors.PropertyDescriptor, throwOnError:Bool):Bool
    {
        var oldLenDesc:jint.runtime.descriptors.PropertyDescriptor = GetOwnProperty("length");
        var oldLen:Int = Std.int(jint.runtime.TypeConverter.ToNumber(oldLenDesc.Value));
        var index:CsRef<Int> = new CsRef<Int>(0);
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
            if (!oldLenDesc.Writable.Value)
            {
                if (throwOnError)
                {
                    return throw new jint.runtime.JavaScriptException().Creator(_engine.TypeError);
                }
                return false;
            }
            var newWritable:Bool;
            if (!newLenDesc.Writable.HasValue || newLenDesc.Writable.Value)
            {
                newWritable = true;
            }
            else
            {
                newWritable = false;
                newLenDesc.Writable = new Nullable_Bool(true);
            }
            var succeeded:Bool = super.DefineOwnProperty("length", _length = newLenDesc, throwOnError);
            if (!succeeded)
            {
                return false;
            }
            if (_array.Count < oldLen - newLen)
            {
                var keys:Array<Int> = system.linq.Enumerable.ToArray(_array.Keys);
                for (key in keys)
                {
                    var keyIndex:CsRef<Int> = new CsRef<Int>(0);
                    if (IsArrayIndex(key, keyIndex) && keyIndex.Value >= newLen && keyIndex.Value < oldLen)
                    {
                        var deleteSucceeded:Bool = Delete(Std.string(key), false);
                        if (!deleteSucceeded)
                        {
                            newLenDesc.Value = new jint.native.JsValue().Creator_Double(keyIndex.Value + 1);
                            if (!newWritable)
                            {
                                newLenDesc.Writable = new Nullable_Bool(false);
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
                            newLenDesc.Writable = new Nullable_Bool(false);
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
                DefineOwnProperty("length", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(null, new Nullable_Bool(false), new Nullable_Bool(), new Nullable_Bool()), false);
            }
            return true;
        }
        else if (IsArrayIndex(propertyName, index))
        {
            if (index.Value >= oldLen && !oldLenDesc.Writable.Value)
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
            if (index.Value >= oldLen)
            {
                oldLenDesc.Value = index.Value + 1;
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
    override public function GetOwnProperties():Array<system.collections.generic.KeyValuePair<String, jint.runtime.descriptors.PropertyDescriptor>>
    {
        var properties:system.collections.generic.Dictionary<String, jint.runtime.descriptors.PropertyDescriptor> = new system.collections.generic.Dictionary<String, jint.runtime.descriptors.PropertyDescriptor>();
        for (entry in _array.GetEnumerator())
        {
            properties.Add(Std.string(entry.Key), entry.Value);
        }
        for (entry in super.GetOwnProperties())
        {
            properties.Add(entry.Key, entry.Value);
        }
        return properties;
    }
    override public function GetOwnProperty(propertyName:String):jint.runtime.descriptors.PropertyDescriptor
    {
        var index:CsRef<Int> = new CsRef<Int>(0);
        if (IsArrayIndex(propertyName, index))
        {
            var result:CsRef<jint.runtime.descriptors.PropertyDescriptor> = new CsRef<jint.runtime.descriptors.PropertyDescriptor>(null);
            if (_array.TryGetValue(index.Value, result))
            {
                return result.Value;
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
        var index:CsRef<Int> = new CsRef<Int>(0);
        if (IsArrayIndex(propertyName, index))
        {
            _array.SetValue(index.Value, desc);
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
        var index:CsRef<Int> = new CsRef<Int>(0);
        if (IsArrayIndex(p, index))
        {
            return index.Value < GetLength() && _array.ContainsKey(index.Value);
        }
        return super.HasOwnProperty(p);
    }
    override public function RemoveOwnProperty(p:String):Void
    {
        var index:CsRef<Int> = new CsRef<Int>(0);
        if (IsArrayIndex(p, index))
        {
            _array.Remove(index.Value);
        }
        super.RemoveOwnProperty(p);
    }
    public static function IsArrayIndex(p:jint.native.JsValue, index:CsRef<Int>):Bool
    {
        index.Value = ParseArrayIndex(jint.runtime.TypeConverter.toString(p));
        return index.Value != 4294967295;
    }
    public static function ParseArrayIndex(p:String):Int
    {
        var d:Int = p.charCodeAt(0) - 48;
        if (d < 0 || d > 9)
        {
            return 4294967295;
        }
        if (d == 0 && p.length > 1)
        {
            return 4294967295;
        }
        var result:Float = d;
        { //for
            var i:Int = 1;
            while (i < p.length)
            {
                d = p.charCodeAt(i) - 48;
                if (d < 0 || d > 9)
                {
                    return 4294967295;
                }
                result = result * 10 + d;
                if (result >= 4294967295)
                {
                    return 4294967295;
                }
                i++;
            }
        } //end for
        return Std.int(result);
    }
}
