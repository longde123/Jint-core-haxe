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
                genericTypes[i] = jint.runtime.Arguments.At(arguments, i).As().Type;
                i++;
            }
        } //end for
        var typeReference:jint.runtime.interop.TypeReference = GetPath(_path + "`" + jint.runtime.TypeConverter.toString(arguments.length, system.globalization.CultureInfo.InvariantCulture)).As();
        if (typeReference == null)
        {
            return jint.native.Undefined.Instance;
        }
        var genericType:system.TypeCS = typeReference.Type.MakeGenericType(genericTypes);
        return jint.runtime.interop.TypeReference.CreateTypeReference(Engine, genericType);
    }
    override public function Get(propertyName:String):jint.native.JsValue
    {
        var newPath:String = _path + "." + propertyName;
        return GetPath(newPath);
    }
    public function GetPath(path:String):jint.native.JsValue
    {
        var type:CsRef<system.TypeCS> = new CsRef<system.TypeCS>(null);
        if (Engine.TypeCache.TryGetValue(path, type))
        {
            if (type.Value == null)
            {
                return new jint.runtime.interop.NamespaceReference(Engine, path);
            }
            return jint.runtime.interop.TypeReference.CreateTypeReference(Engine, type.Value);
        }
        type.Value = system.Cs2Hx.GetType_String(Type, path);
        if (type.Value != null)
        {
            Engine.TypeCache.Add(path, type.Value);
            return jint.runtime.interop.TypeReference.CreateTypeReference(Engine, type.Value);
        }
        for (assembly in system.linq.Enumerable.Distinct([ system.reflection.Assembly.GetCallingAssembly(), system.reflection.Assembly.GetExecutingAssembly() ]))
        {
            type.Value = system.Cs2Hx.GetType(assembly, path);
            if (type.Value != null)
            {
                Engine.TypeCache.Add(path, type.Value);
                return jint.runtime.interop.TypeReference.CreateTypeReference(Engine, type.Value);
            }
        }
        for (assembly in Engine.Options.GetLookupAssemblies())
        {
            type.Value = system.Cs2Hx.GetType(assembly, path);
            if (type.Value != null)
            {
                Engine.TypeCache.Add(path, type.Value);
                return jint.runtime.interop.TypeReference.CreateTypeReference(Engine, type.Value);
            }
            var lastPeriodPos:Int = path.lastIndexOf(".", system.StringComparison.Ordinal);
            var trimPath:String = path.substr(0, lastPeriodPos);
            type.Value = system.Cs2Hx.GetType(assembly, trimPath);
            if (type.Value != null)
            {
                for (nType in GetAllNestedTypes(type.Value))
                {
                    if (system.Cs2Hx.Equals_String(nType.FullName.replace("+", "."), path.replace("+", ".")))
                    {
                        Engine.TypeCache.Add(path.replace("+", "."), nType);
                        return jint.runtime.interop.TypeReference.CreateTypeReference(Engine, nType);
                    }
                }
            }
        }
        Engine.TypeCache.Add(path, null);
        return new jint.runtime.interop.NamespaceReference(Engine, path);
    }
    private static function GetType(assembly:system.reflection.Assembly, typeName:String):system.TypeCS
    {
        var types:Array<system.TypeCS> = assembly.GetTypes();
        for (t in types)
        {
            if (t.FullName.replace("+", ".") == typeName.replace("+", "."))
            {
                return t;
            }
        }
        return null;
    }
    private static function GetAllNestedTypes(type:system.TypeCS):Array<system.TypeCS>
    {
        var types:Array<system.TypeCS> = new Array<system.TypeCS>();
        AddNestedTypesRecursively(types, type);
        return system.Cs2Hx.ToArray(types);
    }
    private static function AddNestedTypesRecursively(types:Array<system.TypeCS>, type:system.TypeCS):Void
    {
        var nestedTypes:Array<system.TypeCS> = type.GetNestedTypes_BindingFlags(system.reflection.BindingFlags.Public);
        for (nestedType in nestedTypes)
        {
            types.push(nestedType);
            AddNestedTypesRecursively(types, nestedType);
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
