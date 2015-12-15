package jint.native.argument;
using StringTools;
import system.*;
import anonymoustypes.*;

class ArgumentsInstance extends jint.native.object.ObjectInstance
{
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    public var Strict:Bool;
    public static function CreateArgumentsObject(engine:jint.Engine, func:jint.native.functions.FunctionInstance, names:Array<String>, args:Array<jint.native.JsValue>, env:jint.runtime.environments.EnvironmentRecord, strict:Bool):jint.native.argument.ArgumentsInstance
    {
        var len:Int = args.length;
        var obj:jint.native.argument.ArgumentsInstance = new jint.native.argument.ArgumentsInstance(engine);
        obj.Prototype = engine.Object.PrototypeObject;
        obj.Extensible = true;
        obj.FastAddProperty("length", len, true, false, true);
        obj.Strict = strict;
        var map:jint.native.object.ObjectInstance = engine.Object.Construct(jint.runtime.Arguments.Empty);
        var mappedNamed:Array<String> = new Array<String>();
        var indx:Int = 0;
        while (indx <= len - 1)
        {
            var indxStr:String = jint.runtime.TypeConverter.toString(indx);
            var val:jint.native.JsValue = args[indx];
            obj.FastAddProperty(indxStr, val, true, true, true);
            if (indx < names.length)
            {
                var name:String = names[indx];
                if (!strict && !system.Cs2Hx.Contains(mappedNamed, name))
                {
                    mappedNamed.push(name);
                    var g:(jint.native.JsValue -> jint.native.JsValue) = function (n:jint.native.JsValue):jint.native.JsValue { return env.GetBindingValue(name, false); } ;
                    var p:(jint.native.JsValue -> jint.native.JsValue -> Void) = new (jint.native.JsValue -> jint.native.JsValue -> Void)(function (n:jint.native.JsValue, o:jint.native.JsValue):Void { env.SetMutableBinding(name, o, true); } );
                    map.DefineOwnProperty(indxStr, new jint.runtime.descriptors.specialized.ClrAccessDescriptor(engine, g, p), false);
                }
            }
            indx++;
        }
        if (mappedNamed.length > 0)
        {
            obj.ParameterMap = map;
        }
        if (!strict)
        {
            obj.FastAddProperty("callee", func, true, false, true);
        }
        else
        {
            var thrower:jint.native.functions.FunctionInstance = engine.Function.ThrowTypeError;
            obj.DefineOwnProperty("caller", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_JsValue_NullableBoolean_NullableBoolean(thrower, thrower, new Nullable_Bool(false), new Nullable_Bool(false)), false);
            obj.DefineOwnProperty("callee", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_JsValue_NullableBoolean_NullableBoolean(thrower, thrower, new Nullable_Bool(false), new Nullable_Bool(false)), false);
        }
        return obj;
    }
    public var ParameterMap:jint.native.object.ObjectInstance;
    override public function get_Class():String
    {
        return "Arguments";
    }

    override public function GetOwnProperty(propertyName:String):jint.runtime.descriptors.PropertyDescriptor
    {
        if (!Strict && ParameterMap != null)
        {
            var desc:jint.runtime.descriptors.PropertyDescriptor = super.GetOwnProperty(propertyName);
            if (desc == jint.runtime.descriptors.PropertyDescriptor.Undefined)
            {
                return desc;
            }
            var isMapped:jint.runtime.descriptors.PropertyDescriptor = ParameterMap.GetOwnProperty(propertyName);
            if (isMapped != jint.runtime.descriptors.PropertyDescriptor.Undefined)
            {
                desc.Value = ParameterMap.Get(propertyName);
            }
            return desc;
        }
        return super.GetOwnProperty(propertyName);
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
        if (!Strict && ParameterMap != null)
        {
            var map:jint.native.object.ObjectInstance = ParameterMap;
            var isMapped:jint.runtime.descriptors.PropertyDescriptor = map.GetOwnProperty(propertyName);
            var allowed:Bool = super.DefineOwnProperty(propertyName, desc, false);
            if (!allowed)
            {
                if (throwOnError)
                {
                    return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
                }
            }
            if (isMapped != jint.runtime.descriptors.PropertyDescriptor.Undefined)
            {
                if (desc.IsAccessorDescriptor())
                {
                    map.Delete(propertyName, false);
                }
                else
                {
                    if (desc.Value != null && !desc.Value.Equals(jint.native.Undefined.Instance))
                    {
                        map.Put(propertyName, desc.Value, throwOnError);
                    }
                    if (desc.Writable.HasValue && desc.Writable.Value == false)
                    {
                        map.Delete(propertyName, false);
                    }
                }
            }
            return true;
        }
        return super.DefineOwnProperty(propertyName, desc, throwOnError);
    }
    override public function Delete(propertyName:String, throwOnError:Bool):Bool
    {
        if (!Strict && ParameterMap != null)
        {
            var map:jint.native.object.ObjectInstance = ParameterMap;
            var isMapped:jint.runtime.descriptors.PropertyDescriptor = map.GetOwnProperty(propertyName);
            var result:Bool = super.Delete(propertyName, throwOnError);
            if (result && isMapped != jint.runtime.descriptors.PropertyDescriptor.Undefined)
            {
                map.Delete(propertyName, false);
            }
            return result;
        }
        return super.Delete(propertyName, throwOnError);
    }
}
