package jint.runtime.descriptors;
using StringTools;
import system.*;
import anonymoustypes.*;

class PropertyDescriptor
{
    public static var Undefined:jint.runtime.descriptors.PropertyDescriptor;
    public function new()
    {
    }
    public function Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(value:jint.native.JsValue, writable:Nullable_Bool, enumerable:Nullable_Bool, configurable:Nullable_Bool):jint.runtime.descriptors.PropertyDescriptor
    {
        Value = value;
        if (writable.HasValue)
        {
            Writable = new Nullable_Bool(writable.Value);
        }
        if (enumerable.HasValue)
        {
            Enumerable = new Nullable_Bool(enumerable.Value);
        }
        if (configurable.HasValue)
        {
            Configurable = new Nullable_Bool(configurable.Value);
        }
        return this;
    }
    public function Creator_JsValue_JsValue_NullableBoolean_NullableBoolean(jget:jint.native.JsValue, jset:jint.native.JsValue, enumerable:Nullable_Bool = null, configurable:Nullable_Bool = null):jint.runtime.descriptors.PropertyDescriptor
    {
        if (enumerable == null)
            enumerable = new Nullable_Bool();
        if (configurable == null)
            configurable = new Nullable_Bool();
        JGet = jget;
        JSet = jset;
        if (enumerable.HasValue)
        {
            Enumerable = new Nullable_Bool(enumerable.Value);
        }
        if (configurable.HasValue)
        {
            Configurable = new Nullable_Bool(configurable.Value);
        }
        return this;
    }
    public function Creator(descriptor:jint.runtime.descriptors.PropertyDescriptor):jint.runtime.descriptors.PropertyDescriptor
    {
        JGet = descriptor.JGet;
        JSet = descriptor.JSet;
        Value = descriptor.Value;
        Enumerable = descriptor.Enumerable;
        Configurable = descriptor.Configurable;
        Writable = descriptor.Writable;
        return this;
    }
    public var JGet:jint.native.JsValue;
    public var JSet:jint.native.JsValue;
    public var Enumerable:Nullable_Bool;
    public var Writable:Nullable_Bool;
    public var Configurable:Nullable_Bool;
    public var Value:jint.native.JsValue;
    public function IsAccessorDescriptor():Bool
    {
        if (JGet == null && JSet == null)
        {
            return false;
        }
        return true;
    }
    public function IsDataDescriptor():Bool
    {
        if (!Writable.HasValue && Value == null)
        {
            return false;
        }
        return true;
    }
    public function IsGenericDescriptor():Bool
    {
        return !IsDataDescriptor() && !IsAccessorDescriptor();
    }
    public static function ToPropertyDescriptor(engine:jint.Engine, o:jint.native.JsValue):jint.runtime.descriptors.PropertyDescriptor
    {
        var obj:jint.native.object.ObjectInstance = o.TryCast();
        if (obj == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(engine.TypeError);
        }
        if ((obj.HasProperty("value") || obj.HasProperty("writable")) && (obj.HasProperty("get") || obj.HasProperty("set")))
        {
            return throw new jint.runtime.JavaScriptException().Creator(engine.TypeError);
        }
        var desc:jint.runtime.descriptors.PropertyDescriptor = new jint.runtime.descriptors.PropertyDescriptor();
        if (obj.HasProperty("enumerable"))
        {
            desc.Enumerable = new Nullable_Bool(jint.runtime.TypeConverter.ToBoolean(obj.Get("enumerable")));
        }
        if (obj.HasProperty("configurable"))
        {
            desc.Configurable = new Nullable_Bool(jint.runtime.TypeConverter.ToBoolean(obj.Get("configurable")));
        }
        if (obj.HasProperty("value"))
        {
            var value:jint.native.JsValue = obj.Get("value");
            desc.Value = value;
        }
        if (obj.HasProperty("writable"))
        {
            desc.Writable = new Nullable_Bool(jint.runtime.TypeConverter.ToBoolean(obj.Get("writable")));
        }
        if (obj.HasProperty("get"))
        {
            var getter:jint.native.JsValue = obj.Get("get");
            if (!getter.Equals(jint.native.JsValue.Undefined) && getter.TryCast() == null)
            {
                return throw new jint.runtime.JavaScriptException().Creator(engine.TypeError);
            }
            desc.JGet = getter;
        }
        if (obj.HasProperty("set"))
        {
            var setter:jint.native.JsValue = obj.Get("set");
            if (!setter.Equals(jint.native.Undefined.Instance) && setter.TryCast() == null)
            {
                return throw new jint.runtime.JavaScriptException().Creator(engine.TypeError);
            }
            desc.JSet = setter;
        }
        if (desc.JGet != null || desc.JGet != null)
        {
            if (desc.Value != null || desc.Writable.HasValue)
            {
                return throw new jint.runtime.JavaScriptException().Creator(engine.TypeError);
            }
        }
        return desc;
    }
    public static function FromPropertyDescriptor(engine:jint.Engine, desc:jint.runtime.descriptors.PropertyDescriptor):jint.native.JsValue
    {
        if (desc == Undefined)
        {
            return jint.native.Undefined.Instance;
        }
        var obj:jint.native.object.ObjectInstance = engine.JObject.Construct(jint.runtime.Arguments.Empty);
        if (desc.IsDataDescriptor())
        {
            obj.DefineOwnProperty("value", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(desc.Value != null ? desc.Value : jint.native.Undefined.Instance, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
            obj.DefineOwnProperty("writable", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(desc.Writable.HasValue && desc.Writable.Value, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
        }
        else
        {
            obj.DefineOwnProperty("get", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(desc.JGet != null ? desc.JGet : jint.native.Undefined.Instance, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
            obj.DefineOwnProperty("set", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(desc.JSet != null ? desc.JSet : jint.native.Undefined.Instance, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
        }
        obj.DefineOwnProperty("enumerable", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(desc.Enumerable.HasValue && desc.Enumerable.Value, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
        obj.DefineOwnProperty("configurable", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(desc.Configurable.HasValue && desc.Configurable.Value, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
        return obj;
    }
    public static function cctor():Void
    {
        Undefined = new jint.runtime.descriptors.PropertyDescriptor();
    }
}
