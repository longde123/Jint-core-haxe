package jint.runtime.interop;
using StringTools;
import system.*;
import anonymoustypes.*;

class ObjectWrapper extends jint.native.object.ObjectInstance implements jint.runtime.interop.IObjectWrapper
{
    public var Target:Dynamic;
    public function new(engine:jint.Engine, obj:Dynamic)
    {
        super(engine);
        Target = obj;
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
        if (ownDesc == null)
        {
            if (throwOnError)
            {
                throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "Unknown member: " + propertyName);
            }
            else
            {
                return;
            }
        }
        ownDesc.Value = value;
    }
    override public function GetOwnProperty(propertyName:String):jint.runtime.descriptors.PropertyDescriptor
    {
        var x:CsRef<jint.runtime.descriptors.PropertyDescriptor> = new CsRef<jint.runtime.descriptors.PropertyDescriptor>(null);
        if (Properties.TryGetValue(propertyName, x))
        {
            return x.Value;
        }
        var type:system.TypeCS = system.Cs2Hx.GetType(Target);
        var property:system.reflection.PropertyInfo = system.linq.Enumerable.FirstOrDefault(system.linq.Enumerable.Where(type.GetProperties_BindingFlags(system.reflection.BindingFlags.Static | system.reflection.BindingFlags.Instance | system.reflection.BindingFlags.Public), function (p:system.reflection.PropertyInfo):Bool { return EqualsIgnoreCasing(p.Name, propertyName); } ));
        if (property != null)
        {
            var descriptor:jint.runtime.descriptors.specialized.PropertyInfoDescriptor = new jint.runtime.descriptors.specialized.PropertyInfoDescriptor(Engine, property, Target);
            Properties.Add(propertyName, descriptor);
            return descriptor;
        }
        var field:system.reflection.FieldInfo = system.linq.Enumerable.FirstOrDefault(system.linq.Enumerable.Where(type.GetFields_BindingFlags(system.reflection.BindingFlags.Static | system.reflection.BindingFlags.Instance | system.reflection.BindingFlags.Public), function (f:system.reflection.FieldInfo):Bool { return EqualsIgnoreCasing(f.Name, propertyName); } ));
        if (field != null)
        {
            var descriptor:jint.runtime.descriptors.specialized.FieldInfoDescriptor = new jint.runtime.descriptors.specialized.FieldInfoDescriptor(Engine, field, Target);
            Properties.Add(propertyName, descriptor);
            return descriptor;
        }
        var methods:Array<system.reflection.MethodInfo> = system.linq.Enumerable.ToArray(system.linq.Enumerable.Where(type.GetMethods_BindingFlags(system.reflection.BindingFlags.Static | system.reflection.BindingFlags.Instance | system.reflection.BindingFlags.Public), function (m:system.reflection.MethodInfo):Bool { return EqualsIgnoreCasing(m.Name, propertyName); } ));
        if (system.linq.Enumerable.Any(methods))
        {
            var descriptor:jint.runtime.descriptors.PropertyDescriptor = new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(new jint.runtime.interop.MethodInfoFunctionInstance(Engine, methods), new Nullable_Bool(false), new Nullable_Bool(true), new Nullable_Bool(false));
            Properties.Add(propertyName, descriptor);
            return descriptor;
        }
        if (system.linq.Enumerable.FirstOrDefault(system.linq.Enumerable.Where(type.GetProperties(), function (p:system.reflection.PropertyInfo):Bool { return p.GetIndexParameters().length != 0; } )) != null)
        {
            return new jint.runtime.descriptors.specialized.IndexDescriptor(Engine, system.Cs2Hx.GetType(Target), propertyName, Target);
        }
        var interfaces:Array<system.TypeCS> = type.GetInterfaces();
        var explicitProperties:Array<system.reflection.PropertyInfo> = null;
        if (explicitProperties.length == 1)
        {
            var descriptor:jint.runtime.descriptors.specialized.PropertyInfoDescriptor = new jint.runtime.descriptors.specialized.PropertyInfoDescriptor(Engine, explicitProperties[0], Target);
            Properties.Add(propertyName, descriptor);
            return descriptor;
        }
        var explicitMethods:Array<system.reflection.MethodInfo> = null;
        if (explicitMethods.length > 0)
        {
            var descriptor:jint.runtime.descriptors.PropertyDescriptor = new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(new jint.runtime.interop.MethodInfoFunctionInstance(Engine, explicitMethods), new Nullable_Bool(false), new Nullable_Bool(true), new Nullable_Bool(false));
            Properties.Add(propertyName, descriptor);
            return descriptor;
        }
        var explicitIndexers:Array<system.reflection.PropertyInfo> = null;
        if (explicitIndexers.length == 1)
        {
            return new jint.runtime.descriptors.specialized.IndexDescriptor(Engine, explicitIndexers[0].DeclaringType, propertyName, Target);
        }
        return jint.runtime.descriptors.PropertyDescriptor.Undefined;
    }
    private function EqualsIgnoreCasing(s1:String, s2:String):Bool
    {
        var equals:Bool = false;
        if (s1.length == s2.length)
        {
            if (s1.length > 0 && s2.length > 0)
            {
                equals = (s1.toLowerCase().charCodeAt(0) == s2.toLowerCase().charCodeAt(0));
            }
            if (s1.length > 1 && s2.length > 1)
            {
                equals = equals && (s1.substr(1) == s2.substr(1));
            }
        }
        return equals;
    }
}
