package jint.runtime.descriptors;
using StringTools;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
class PropertyDescriptor
{
    public static var Undefined:jint.runtime.descriptors.PropertyDescriptor;
    public function new()
    {
    }
    public function Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(value:jint.native.JsValue, writable:Null<Bool>, enumerable:Null<Bool>, configurable:Null<Bool>):jint.runtime.descriptors.PropertyDescriptor
    {
        Value = value;
        if (writable!=null)
        {
            Writable = (writable);
        }
        if (enumerable!=null)
        {
            Enumerable = (enumerable);
        }
        if (configurable!=null)
        {
            Configurable = (configurable);
        }
        return this;
    }
    public function Creator_JsValue_JsValue_NullableBoolean_NullableBoolean(jget:jint.native.JsValue, jset:jint.native.JsValue, enumerable:Null<Bool> = null, configurable:Null<Bool> = null):jint.runtime.descriptors.PropertyDescriptor
    {
        //if (enumerable == null)
        //    enumerable = ();
       // if (configurable == null)
        //    configurable = ();
        JGet = jget;
        JSet = jset;
        if (enumerable!=null)
        {
            Enumerable = enumerable;
        }
        if (configurable!=null)
        {
            Configurable = configurable;
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
    public var Enumerable:Null<Bool>;
    public var Writable:Null<Bool>;
    public var Configurable:Null<Bool>;
    public var Value(get, set):jint.native.JsValue;
	var __Value:jint.native.JsValue;
	public function get_Value():jint.native.JsValue
    {  
		return __Value;
    }

    public function set_Value(value:jint.native.JsValue):jint.native.JsValue
    { 
		__Value = value;
        return __Value;
    }
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
		//todo
        if (Writable!=null && Value == null)
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
        var obj:jint.native.object.ObjectInstance = o.TryCast(jint.native.object.ObjectInstance);
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
            desc.Enumerable = (jint.runtime.TypeConverter.ToBoolean(obj.Get("enumerable")));
        }
        if (obj.HasProperty("configurable"))
        {
            desc.Configurable =(jint.runtime.TypeConverter.ToBoolean(obj.Get("configurable")));
        }
        if (obj.HasProperty("value"))
        {
            var value:jint.native.JsValue = obj.Get("value");
            desc.Value = value;
        }
        if (obj.HasProperty("writable"))
        {
            desc.Writable =(jint.runtime.TypeConverter.ToBoolean(obj.Get("writable")));
        }
        if (obj.HasProperty("get"))
        {
            var getter:jint.native.JsValue = obj.Get("get");
            if (!getter.Equals(jint.native.JsValue.Undefined) && getter.TryCast(null) == null)
            {
                return throw new jint.runtime.JavaScriptException().Creator(engine.TypeError);
            }
            desc.JGet = getter;
        }
        if (obj.HasProperty("set"))
        {
            var setter:jint.native.JsValue = obj.Get("set");
            if (!setter.Equals(jint.native.Undefined.Instance) && setter.TryCast(null) == null)
            {
                return throw new jint.runtime.JavaScriptException().Creator(engine.TypeError);
            }
            desc.JSet = setter;
        }
        if (desc.JGet != null || desc.JGet != null)
        {
            if (desc.Value != null || desc.Writable!=null)
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
            obj.DefineOwnProperty("value", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(desc.Value != null ? desc.Value : jint.native.Undefined.Instance, (true), (true), (true)), false);
            obj.DefineOwnProperty("writable", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(desc.Writable!=null && desc.Writable, (true), (true), (true)), false);
        }
        else
        {
            obj.DefineOwnProperty("get", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(desc.JGet != null ? desc.JGet : jint.native.Undefined.Instance, (true), (true), (true)), false);
            obj.DefineOwnProperty("set", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(desc.JSet != null ? desc.JSet : jint.native.Undefined.Instance, (true), (true), (true)), false);
        }
        obj.DefineOwnProperty("enumerable", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(desc.Enumerable!=null && desc.Enumerable, (true), (true), (true)), false);
        obj.DefineOwnProperty("configurable", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(desc.Configurable!=null && desc.Configurable, (true), (true), (true)), false);
        return obj;
    }
    public static function cctor():Void
    {
        Undefined = new jint.runtime.descriptors.PropertyDescriptor();
    }
}
