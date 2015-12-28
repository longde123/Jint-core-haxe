package jint.runtime.interop;
using StringTools;
import jint.native.Null;
import system.*;
import anonymoustypes.*;

class ObjectWrapper extends jint.native.object.ObjectInstance implements jint.runtime.interop.IObjectWrapper
{
    public  var Target(get , never):Dynamic;
	var _Target:Dynamic;
	public function get_Target():Dynamic
    {
        return _Target;
    }

   
    public function new(engine:jint.Engine, obj:Dynamic)
    {
        super(engine);
        _Target = obj;
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
        var x:jint.runtime.descriptors.PropertyDescriptor = (null);
        if (Properties.Contains(propertyName))
        {
            return x=Properties.Get(propertyName);
        }
		var JType = Type.getClass(Target);
        if (Reflect.isEnumValue(JType))
        {
			//todo
			
            var enumValues= Type.enumIndex(Type.createEnum(cast JType, propertyName));
           
		//	if (enumValues!= null)
			{
				var descriptor =  new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(enumValues,  (false), (false),  (false));
				Properties.Add(propertyName, descriptor);
				return descriptor;
			}
               
            return jint.runtime.descriptors.PropertyDescriptor.Undefined;
        }
        var propertyInfo = Lambda.find(Type.getInstanceFields(JType),function(p) return p==propertyName);
        if (propertyInfo!=null )
        {
            var descriptor =  new jint.runtime.descriptors.specialized.PropertyInfoDescriptor(Engine, propertyName, JType);
			Properties.Add(propertyName, descriptor);
			return descriptor;
        }
        var fieldInfo =Lambda.find(Type.getClassFields(JType),function(p) return p==propertyName);
        if (fieldInfo !=null )
        {
            var descriptor =  new jint.runtime.descriptors.specialized.FieldInfoDescriptor(Engine, propertyName, JType);
			Properties.Add(propertyName, descriptor);
			return descriptor;
        }
		var IndexInfo =Lambda.find(Reflect.fields(JType),function(p) return p==propertyName);
        if (IndexInfo!=null  )
        {
            var descriptor =  new jint.runtime.descriptors.specialized.IndexDescriptor(Engine, propertyName, JType);
			Properties.Add(propertyName, descriptor);
			return descriptor;
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
