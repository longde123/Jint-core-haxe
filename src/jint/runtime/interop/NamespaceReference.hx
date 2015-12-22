package jint.runtime.interop;
using StringTools;
import system.*;
import anonymoustypes.*;

class NamespaceReference extends jint.native.object.ObjectInstance implements jint.native.ICallable
{
    private var _path:String;
    public function new(engine:jint.Engine, path:String)
    {
        super(engine);
        _path = path;
    }
    override public function DefineOwnProperty(propertyName:String, desc:jint.runtime.descriptors.PropertyDescriptor, throwOnError:Bool):Bool
    {
        if (throwOnError)
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "Can't define a property of a NamespaceReference");
        }
        return false;
    }
    override public function Delete(propertyName:String, throwOnError:Bool):Bool
    {
        if (throwOnError)
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "Can't delete a property of a NamespaceReference");
        }
        return false;
    }
    public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var genericTypes:Array<system.TypeCS> = [  ];
        { //for
            var i:Int = 0;
            while (i < arguments.length)
            {
                var genericTypeReference:jint.native.JsValue = jint.runtime.Arguments.At(arguments, i);
                if (genericTypeReference.Equals(jint.native.Undefined.Instance) || !genericTypeReference.IsObject() || genericTypeReference.AsObject().Class != "TypeReference")
                {
                    return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "Invalid generic type parameter");
                }
                genericTypes[i] = jint.runtime.Arguments.At(arguments, i).As(TypeReference).JType;
                i++;
            }
        } //end for
        var typeReference:jint.runtime.interop.TypeReference = GetPath(_path + "`" + jint.runtime.TypeConverter.toString(arguments.length, system.globalization.CultureInfo.InvariantCulture)).As();
        if (typeReference == null)
        {
            return jint.native.Undefined.Instance;
        }
        var genericType:system.TypeCS = typeReference.JType.MakeGenericType(genericTypes);
        return jint.runtime.interop.TypeReference.CreateTypeReference(Engine, genericType);
    }
    override public function Get(propertyName:String):jint.native.JsValue
    {
        var newPath:String = _path + "." + propertyName;
        return GetPath(newPath);
    }
    public function GetPath(  path:String):JsValue
	{
		Type type;

		if (Engine.TypeCache.TryGetValue(path, out type))
		{
			if (type == null)
			{
				return new NamespaceReference(Engine, path);
			}

			return TypeReference.CreateTypeReference(Engine, type);
		}

		// search for type in mscorlib
		type = Type.GetType(path);
		if (type != null)
		{
			Engine.TypeCache.Add(path, type);
			return TypeReference.CreateTypeReference(Engine, type);
		}
	}
    override public function GetOwnProperty(propertyName:String):jint.runtime.descriptors.PropertyDescriptor
    {
        return jint.runtime.descriptors.PropertyDescriptor.Undefined;
    }
    override public function toString():String
    {
        return "[Namespace: " + _path + "]";
    }
}
