package jint.native.object;
using StringTools;
import system.*;
import anonymoustypes.*;
import haxe.ds.StringMap;
class ObjectInstance
{
    public function new(engine:jint.Engine)
    {
        Engine = engine;
        Properties = new jint.runtime.MruPropertyCache<String, jint.runtime.descriptors.PropertyDescriptor>();
    }
    public var Engine:jint.Engine;
    public var Properties:jint.runtime.MruPropertyCache<String, jint.runtime.descriptors.PropertyDescriptor>;
    public var Prototype:jint.native.object.ObjectInstance;
    public var Extensible:Bool;
    public var Class(get_Class, never):String;
    public function get_Class():String
    {
        return "Object";
    }

    public function GetOwnProperties():haxe.ds.HashMap<String, jint.runtime.descriptors.PropertyDescriptor>
    {
        return Properties.iterator();
    }
    public function HasOwnProperty(p:String):Bool
    {
        return Properties.ContainsKey(p);
    }
    public function RemoveOwnProperty(p:String):Void
    {
        Properties.Remove(p);
    }
    public function Get(propertyName:String):jint.native.JsValue
    {
        var desc:jint.runtime.descriptors.PropertyDescriptor = GetProperty(propertyName);
        if (desc == jint.runtime.descriptors.PropertyDescriptor.Undefined)
        {
            return jint.native.JsValue.Undefined;
        }
        if (desc.IsDataDescriptor())
        {
            return desc.Value != null ? desc.Value : jint.native.Undefined.Instance;
        }
        var getter:jint.native.JsValue = desc.JGet != null ? desc.JGet : jint.native.Undefined.Instance;
        if (getter.IsUndefined())
        {
            return jint.native.Undefined.Instance;
        }
        var callable:jint.native.ICallable = getter.TryCast();
        return callable.Call(this, jint.runtime.Arguments.Empty);
    }
    public function GetOwnProperty(propertyName:String):jint.runtime.descriptors.PropertyDescriptor
    {
        var x:CsRef<jint.runtime.descriptors.PropertyDescriptor> = new CsRef<jint.runtime.descriptors.PropertyDescriptor>(null);
        if (Properties.TryGetValue(propertyName, x))
        {
            return x.Value;
        }
        return jint.runtime.descriptors.PropertyDescriptor.Undefined;
    }
    public function SetOwnProperty(propertyName:String, desc:jint.runtime.descriptors.PropertyDescriptor):Void
    {
        Properties.SetValue(propertyName, desc);
    }
    public function GetProperty(propertyName:String):jint.runtime.descriptors.PropertyDescriptor
    {
        var prop:jint.runtime.descriptors.PropertyDescriptor = GetOwnProperty(propertyName);
        if (prop != jint.runtime.descriptors.PropertyDescriptor.Undefined)
        {
            return prop;
        }
        if (Prototype == null)
        {
            return jint.runtime.descriptors.PropertyDescriptor.Undefined;
        }
        return Prototype.GetProperty(propertyName);
    }
    public function Put(propertyName:String, value:jint.native.JsValue, throwOnError:Bool):Void
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
            ownDesc.Value = value;
            return;
        }
        var desc:jint.runtime.descriptors.PropertyDescriptor = GetProperty(propertyName);
        if (desc.IsAccessorDescriptor())
        {
            var setter:jint.native.ICallable = desc.JSet.TryCast();
            setter.Call(new jint.native.JsValue().Creator_ObjectInstance(this), [ value ]);
        }
        else
        {
            var newDesc:jint.runtime.descriptors.PropertyDescriptor = new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(value, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true));
            DefineOwnProperty(propertyName, newDesc, throwOnError);
        }
    }
    public function CanPut(propertyName:String):Bool
    {
        var desc:jint.runtime.descriptors.PropertyDescriptor = GetOwnProperty(propertyName);
        if (desc != jint.runtime.descriptors.PropertyDescriptor.Undefined)
        {
            if (desc.IsAccessorDescriptor())
            {
                if (desc.JSet == null || desc.JSet.IsUndefined())
                {
                    return false;
                }
                return true;
            }
            return desc.Writable.HasValue && desc.Writable.Value;
        }
        if (Prototype == null)
        {
            return Extensible;
        }
        var inherited:jint.runtime.descriptors.PropertyDescriptor = Prototype.GetProperty(propertyName);
        if (inherited == jint.runtime.descriptors.PropertyDescriptor.Undefined)
        {
            return Extensible;
        }
        if (inherited.IsAccessorDescriptor())
        {
            if (inherited.JSet == null || inherited.JSet.IsUndefined())
            {
                return false;
            }
            return true;
        }
        if (!Extensible)
        {
            return false;
        }
        else
        {
            return inherited.Writable.HasValue && inherited.Writable.Value;
        }
    }
    public function HasProperty(propertyName:String):Bool
    {
        return GetProperty(propertyName) != jint.runtime.descriptors.PropertyDescriptor.Undefined;
    }
    public function Delete(propertyName:String, throwOnError:Bool):Bool
    {
        var desc:jint.runtime.descriptors.PropertyDescriptor = GetOwnProperty(propertyName);
        if (desc == jint.runtime.descriptors.PropertyDescriptor.Undefined)
        {
            return true;
        }
        if (desc.Configurable.HasValue && desc.Configurable.Value)
        {
            RemoveOwnProperty(propertyName);
            return true;
        }
        else
        {
            if (throwOnError)
            {
                return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
            }
            return false;
        }
    }
    public function DefaultValue(hint:Int):jint.native.JsValue
    {
        if (hint == jint.runtime.Types.String || (hint == jint.runtime.Types.None && Class == "Date"))
        {
            var toString:jint.native.ICallable = Get("toString").TryCast();
            if (toString != null)
            {
                var str:jint.native.JsValue = toString.Call(new jint.native.JsValue().Creator_ObjectInstance(this), jint.runtime.Arguments.Empty);
                if (str.IsPrimitive())
                {
                    return str;
                }
            }
            var valueOf:jint.native.ICallable = Get("valueOf").TryCast();
            if (valueOf != null)
            {
                var val:jint.native.JsValue = valueOf.Call(new jint.native.JsValue().Creator_ObjectInstance(this), jint.runtime.Arguments.Empty);
                if (val.IsPrimitive())
                {
                    return val;
                }
            }
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        if (hint == jint.runtime.Types.Number || hint == jint.runtime.Types.None)
        {
            var valueOf:jint.native.ICallable = Get("valueOf").TryCast();
            if (valueOf != null)
            {
                var val:jint.native.JsValue = valueOf.Call(new jint.native.JsValue().Creator_ObjectInstance(this), jint.runtime.Arguments.Empty);
                if (val.IsPrimitive())
                {
                    return val;
                }
            }
            var toString:jint.native.ICallable = Get("toString").TryCast();
            if (toString != null)
            {
                var str:jint.native.JsValue = toString.Call(new jint.native.JsValue().Creator_ObjectInstance(this), jint.runtime.Arguments.Empty);
                if (str.IsPrimitive())
                {
                    return str;
                }
            }
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        return toString();
    }
    public function DefineOwnProperty(propertyName:String, desc:jint.runtime.descriptors.PropertyDescriptor, throwOnError:Bool):Bool
    {
        var current:jint.runtime.descriptors.PropertyDescriptor = GetOwnProperty(propertyName);
        if (current == desc)
        {
            return true;
        }
        if (current == jint.runtime.descriptors.PropertyDescriptor.Undefined)
        {
            if (!Extensible)
            {
                if (throwOnError)
                {
                    return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
                }
                return false;
            }
            else
            {
                if (desc.IsGenericDescriptor() || desc.IsDataDescriptor())
                {
                    SetOwnProperty(propertyName, new jint.runtime.descriptors.PropertyDescriptor().Creator(desc).Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(desc.Value != null ? desc.Value : jint.native.JsValue.Undefined, new Nullable_Bool(desc.Writable.HasValue ? desc.Writable.Value : false), new Nullable_Bool(desc.Enumerable.HasValue ? desc.Enumerable.Value : false), new Nullable_Bool(desc.Configurable.HasValue ? desc.Configurable.Value : false)));
                }
                else
                {
                    SetOwnProperty(propertyName, new jint.runtime.descriptors.PropertyDescriptor().Creator(desc).Creator_JsValue_JsValue_NullableBoolean_NullableBoolean(desc.JGet, desc.JSet, desc.Enumerable.HasValue ? desc.Enumerable : new Nullable_Bool(false), desc.Configurable.HasValue ? desc.Configurable : new Nullable_Bool(false)));
                }
            }
            return true;
        }
        if (!current.Configurable.HasValue && !current.Enumerable.HasValue && !current.Writable.HasValue && current.JGet == null && current.JSet == null && current.Value == null)
        {
            return true;
        }
        if (current.Configurable.Value == desc.Configurable.Value && current.Writable.Value == desc.Writable.Value && current.Enumerable.Value == desc.Enumerable.Value && ((current.JGet == null && desc.JGet == null) || (current.JGet != null && desc.JGet != null && jint.runtime.ExpressionInterpreter.SameValue(current.JGet, desc.JGet))) && ((current.JSet == null && desc.JSet == null) || (current.JSet != null && desc.JSet != null && jint.runtime.ExpressionInterpreter.SameValue(current.JSet, desc.JSet))) && ((current.Value == null && desc.Value == null) || (current.Value != null && desc.Value != null && jint.runtime.ExpressionInterpreter.StrictlyEqual(current.Value, desc.Value))))
        {
            return true;
        }
        if (!current.Configurable.HasValue || !current.Configurable.Value)
        {
            if (desc.Configurable.HasValue && desc.Configurable.Value)
            {
                if (throwOnError)
                {
                    return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
                }
                return false;
            }
            if (desc.Enumerable.HasValue && (!current.Enumerable.HasValue || desc.Enumerable.Value != current.Enumerable.Value))
            {
                if (throwOnError)
                {
                    return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
                }
                return false;
            }
        }
        if (!desc.IsGenericDescriptor())
        {
            if (current.IsDataDescriptor() != desc.IsDataDescriptor())
            {
                if (!current.Configurable.HasValue || !current.Configurable.Value)
                {
                    if (throwOnError)
                    {
                        return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
                    }
                    return false;
                }
                if (current.IsDataDescriptor())
                {
                    SetOwnProperty(propertyName, current = new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_JsValue_NullableBoolean_NullableBoolean(jint.native.Undefined.Instance, jint.native.Undefined.Instance, current.Enumerable, current.Configurable));
                }
                else
                {
                    SetOwnProperty(propertyName, current = new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(jint.native.Undefined.Instance, new Nullable_Bool(), current.Enumerable, current.Configurable));
                }
            }
            else if (current.IsDataDescriptor() && desc.IsDataDescriptor())
            {
                if (!current.Configurable.HasValue || current.Configurable.Value == false)
                {
                    if (!current.Writable.HasValue || !current.Writable.Value && desc.Writable.HasValue && desc.Writable.Value)
                    {
                        if (throwOnError)
                        {
                            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
                        }
                        return false;
                    }
                    if (!current.Writable.Value)
                    {
                        if (desc.Value != null && !jint.runtime.ExpressionInterpreter.SameValue(desc.Value, current.Value))
                        {
                            if (throwOnError)
                            {
                                return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
                            }
                            return false;
                        }
                    }
                }
            }
            else if (current.IsAccessorDescriptor() && desc.IsAccessorDescriptor())
            {
                if (!current.Configurable.HasValue || !current.Configurable.Value)
                {
                    if ((desc.JSet != null && !jint.runtime.ExpressionInterpreter.SameValue(desc.JSet, current.JSet != null ? current.JSet : jint.native.Undefined.Instance)) || (desc.JGet != null && !jint.runtime.ExpressionInterpreter.SameValue(desc.JGet, current.JGet != null ? current.JGet : jint.native.Undefined.Instance)))
                    {
                        if (throwOnError)
                        {
                            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
                        }
                        return false;
                    }
                }
            }
        }
        if (desc.Value != null)
        {
            current.Value = desc.Value;
        }
        if (desc.Writable.HasValue)
        {
            current.Writable = desc.Writable;
        }
        if (desc.Enumerable.HasValue)
        {
            current.Enumerable = desc.Enumerable;
        }
        if (desc.Configurable.HasValue)
        {
            current.Configurable = desc.Configurable;
        }
        if (desc.JGet != null)
        {
            current.JGet = desc.JGet;
        }
        if (desc.JSet != null)
        {
            current.JSet = desc.JSet;
        }
        return true;
    }
    public function FastAddProperty(name:String, value:jint.native.JsValue, writable:Bool, enumerable:Bool, configurable:Bool):Void
    {
        SetOwnProperty(name, new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(value, new Nullable_Bool(writable), new Nullable_Bool(enumerable), new Nullable_Bool(configurable)));
    }
    public function FastSetProperty(name:String, value:jint.runtime.descriptors.PropertyDescriptor):Void
    {
        SetOwnProperty(name, value);
    }
    public function toString():String
    {
        return jint.runtime.TypeConverter.toString(this);
    }
}
