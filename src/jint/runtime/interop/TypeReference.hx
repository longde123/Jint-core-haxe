package jint.runtime.interop;
using StringTools;
import jint.native.JsValue;
import jint.runtime.descriptors.specialized.IndexDescriptor;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
class TypeReference extends jint.native.functions.FunctionInstance implements jint.native.IConstructor implements jint.runtime.interop.IObjectWrapper
{
    public function new(engine:jint.Engine)
    {
        super(engine, null, null, false);
    }
    public var JType:Class<Dynamic>;
    public static function CreateTypeReference(engine:jint.Engine, type:Class<Dynamic>):jint.runtime.interop.TypeReference
    {
        var obj:jint.runtime.interop.TypeReference = new jint.runtime.interop.TypeReference(engine);
        obj.Extensible = false;
        obj.JType = type;
        obj.Prototype = engine.JFunction.PrototypeObject;
        obj.FastAddProperty("length", 0, false, false, false);
        obj.FastAddProperty("prototype", engine.JObject.PrototypeObject, false, false, false);
        return obj;
    }
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return Construct(arguments);
    }
    public function Construct(arguments:Array<jint.native.JsValue>):jint.native.object.ObjectInstance
    {
       
            var parameters:Array<Dynamic> = [  ];
            try
            {
                { //for
                    var i:Int = 0;
                    while (i < arguments.length)
                    {
                            parameters[i] = arguments[i].ToObject() ;
                   
                        i++;
                    }
                } //end for
                var constructor =Type.createInstance(JType,parameters);
                var result:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, jint.native.JsValue.FromObject(Engine, constructor));
                return result;
            }
            catch (__ex:Dynamic)
            {
            }
       
         throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "No public methods with the specified arguments were found.");
		return null;
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
        if (Reflect.isEnumValue(JType))
        {
			
            var enumValues =Type.resolveEnum(propertyName);
           
			if (enumValues!= null)
			{
				//todo
				//return new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(enumValues,  (false), (false),  (false));
			}
               
            return jint.runtime.descriptors.PropertyDescriptor.Undefined;
        }
        var propertyInfo = Lambda.has(Type.getInstanceFields(JType),propertyName);
        if (propertyInfo )
        {
            return new jint.runtime.descriptors.specialized.PropertyInfoDescriptor(Engine, propertyName, JType);
        }
        var fieldInfo =Lambda.has(Type.getClassFields(JType), propertyName);
        if (fieldInfo  )
        {
            return new jint.runtime.descriptors.specialized.FieldInfoDescriptor(Engine, propertyName, JType);
        }
		var IndexInfo =Lambda.has(Reflect.fields(JType), propertyName);
        if (IndexInfo  )
        {
            return new jint.runtime.descriptors.specialized.IndexDescriptor(Engine, propertyName, JType);
        }
        return jint.runtime.descriptors.PropertyDescriptor.Undefined;
    }
    public var Target(get_Target, never):Dynamic;
    public function get_Target():Dynamic
    {
        return JType;
    }

    override public function get_JClass():String
    {
        return "TypeReference";
    }

}
