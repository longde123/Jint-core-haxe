package jint.runtime.descriptors.specialized;
using StringTools;
import system.*;
import anonymoustypes.*;

class IndexDescriptor extends jint.runtime.descriptors.PropertyDescriptor
{
    private var _engine:jint.Engine;
    private var _key:Dynamic;
    private var _item:Dynamic;
    private var _indexer:system.reflection.PropertyInfo;
    private var _containsKey:system.reflection.MethodInfo;
    public function new(engine:jint.Engine, targetType:system.TypeCS, key:String, item:Dynamic)
    {
        super();
        _engine = engine;
        _item = item;
        var indexers:Array<system.reflection.PropertyInfo> = targetType.GetProperties_BindingFlags(system.reflection.BindingFlags.Instance | system.reflection.BindingFlags.NonPublic | system.reflection.BindingFlags.Public);
        for (indexer in indexers)
        {
            if (indexer.GetIndexParameters().length != 1)
            {
                continue;
            }
            if (indexer.GetGetMethod() != null || indexer.GetSetMethod() != null)
            {
                var paramType:system.TypeCS = indexer.GetIndexParameters()[0].ParameterType;
                var converter:system.collections.generic.KeyValuePair<Bool, Dynamic> = _engine.ClrTypeConverter.TryConvert(key, paramType, system.globalization.CultureInfo.InvariantCulture);
                if (converter.Key)
                {
                    _key = converter.Value;
                    _indexer = indexer;
                    _containsKey = targetType.GetMethod_String_("ContainsKey", [ paramType ]);
                    break;
                }
            }
        }
        if (_indexer == null)
        {
            throw new system.InvalidOperationException("No matching indexer found.");
        }
        Writable = new Nullable_Bool(true);
    }
    override public function get_Value():jint.native.JsValue
    {
        var getter:system.reflection.MethodInfo = _indexer.GetGetMethod();
        if (getter == null)
        {
            return throw new system.InvalidOperationException("Indexer has no public getter.");
        }
        var parameters:Array<Dynamic> = [ _key ];
        if (_containsKey != null)
        {
            var invokeValue:Nullable_Bool = new Nullable_Bool(_containsKey.Invoke(_item, parameters));
            if (invokeValue.Value != true)
            {
                return jint.native.JsValue.Undefined;
            }
        }
        try
        {
            return jint.native.JsValue.FromObject(_engine, getter.Invoke(_item, parameters));
        }
        catch (__ex:Dynamic)
        {
            return jint.native.JsValue.Undefined;
        }
    }

    override public function set_Value(value:jint.native.JsValue):jint.native.JsValue
    {
        var setter:system.reflection.MethodInfo = _indexer.GetSetMethod();
        if (setter == null)
        {
            return throw new system.InvalidOperationException("Indexer has no public setter.");
        }
        var parameters:Array<Dynamic> = [ _key, value != null ? value.ToObject() : null ];
        setter.Invoke(_item, parameters);
        return null;
    }

}
