package jint.runtime.interop;
using StringTools;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
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
		//todo 
        return  null;
    }
    override public function Get(propertyName:String):jint.native.JsValue
    {
        var newPath:String = _path + "." + propertyName;
        return null;//todo GetPath(newPath);
    }
    public function GetPath(  path:String):jint.native.JsValue
	{
		var type:Class<Dynamic>;

		if (Engine.TypeCache.exists(path   ))
		{
			type = Engine.TypeCache.get(path);
			if (type == null)
			{
				return new NamespaceReference(Engine, path);
			}

			return TypeReference.CreateTypeReference(Engine, type);
		}

		// search for type in mscorlib
		type = Type.resolveClass(path);
		if (type != null)
		{
			Engine.TypeCache.set(path, type);
			return TypeReference.CreateTypeReference(Engine, type);
		}
		
		return null;//todo 
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
