package jint.runtime.interop;
using StringTools;
import system.*;
import anonymoustypes.*;

class TypeReference extends jint.native.functions.FunctionInstance implements jint.native.IConstructor implements jint.runtime.interop.IObjectWrapper
{
    public function new(engine:jint.Engine)
    {
        super(engine, null, null, false);
    }
    public var Type:system.TypeCS;
    public static function CreateTypeReference(engine:jint.Engine, type:system.TypeCS):jint.runtime.interop.TypeReference
    {
        var obj:jint.runtime.interop.TypeReference = new jint.runtime.interop.TypeReference(engine);
        obj.Extensible = false;
        obj.Type = type;
        obj.Prototype = engine.Function.PrototypeObject;
        obj.FastAddProperty("length", 0, false, false, false);
        obj.FastAddProperty("prototype", engine.Object.PrototypeObject, false, false, false);
        return obj;
    }
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return Construct(arguments);
    }
    public function Construct(arguments:Array<jint.native.JsValue>):jint.native.object.ObjectInstance
    {
        var constructors:Array<system.reflection.ConstructorInfo> = Type.GetConstructors_BindingFlags(system.reflection.BindingFlags.Public | system.reflection.BindingFlags.Instance);
        var methods:Array<system.reflection.MethodBase> = system.linq.Enumerable.ToList(jint.runtime.TypeConverter.FindBestMatch(Engine, constructors, arguments));
        for (method in methods)
        {
            var parameters:Array<Dynamic> = [  ];
            try
            {
                { //for
                    var i:Int = 0;
                    while (i < arguments.length)
                    {
                        var parameterType:system.TypeCS = method.GetParameters()[i].ParameterType;
                        if (parameterType == typeof(jint.native.JsValue))
                        {
                            parameters[i] = arguments[i];
                        }
                        else
                        {
                            parameters[i] = Engine.ClrTypeConverter.Convert(arguments[i].ToObject(), parameterType, system.globalization.CultureInfo.InvariantCulture);
                        }
                        i++;
                    }
                } //end for
                var constructor:system.reflection.ConstructorInfo = cast(method, system.reflection.ConstructorInfo);
                var result:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, jint.native.JsValue.FromObject(Engine, constructor.Invoke(system.linq.Enumerable.ToArray(parameters))));
                return result;
            }
            catch (__ex:Dynamic)
            {
            }
        }
        return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "No public methods with the specified arguments were found.");
    }
    override public function DefineOwnProperty(propertyName:String, desc:jint.runtime.descriptors.PropertyDescriptor, throwOnError:Bool):Bool
    {
        if (throwOnError)
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "Can't define a property of a TypeReference");
        }
        return false;
    }
    override public function Delete(propertyName:String, throwOnError:Bool):Bool
    {
        if (throwOnError)
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "Can't delete a property of a TypeReference");
        }
        return false;
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
        if (Type.IsEnum)
        {
            var enumValues = null;
            var enumNames = null;
            { //for
                var i:Int = 0;
                while (i < enumValues.length)
                {
                    if (enumNames.GetValue_Int32(i) == propertyName)
                    {
                        return new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(jint.native.JsValue.op_Explicit_Int(enumValues.GetValue_Int32(i)), new Nullable_Bool(false), new Nullable_Bool(false), new Nullable_Bool(false));
                    }
                    i++;
                }
            } //end for
            return jint.runtime.descriptors.PropertyDescriptor.Undefined;
        }
        var propertyInfo:system.reflection.PropertyInfo = Type.GetProperty_String_BindingFlags(propertyName, system.reflection.BindingFlags.Public | system.reflection.BindingFlags.Static);
        if (propertyInfo != null)
        {
            return new jint.runtime.descriptors.specialized.PropertyInfoDescriptor(Engine, propertyInfo, Type);
        }
        var fieldInfo:system.reflection.FieldInfo = Type.GetField_String_BindingFlags(propertyName, system.reflection.BindingFlags.Public | system.reflection.BindingFlags.Static);
        if (fieldInfo != null)
        {
            return new jint.runtime.descriptors.specialized.FieldInfoDescriptor(Engine, fieldInfo, Type);
        }
        var methodInfo:Array<system.reflection.MethodInfo> = system.linq.Enumerable.ToArray(system.linq.Enumerable.Where(Type.GetMethods_BindingFlags(system.reflection.BindingFlags.Public | system.reflection.BindingFlags.Static), function (mi:system.reflection.MethodInfo):Bool { return mi.Name == propertyName; } ));
        if (methodInfo.length == 0)
        {
            return jint.runtime.descriptors.PropertyDescriptor.Undefined;
        }
        return new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(new jint.runtime.interop.MethodInfoFunctionInstance(Engine, methodInfo), new Nullable_Bool(false), new Nullable_Bool(false), new Nullable_Bool(false));
    }
    public var Target(get_Target, never):Dynamic;
    public function get_Target():Dynamic
    {
        return Type;
    }

    override public function get_Class():String
    {
        return "TypeReference";
    }

}
