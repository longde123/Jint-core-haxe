package jint.runtime.descriptors.specialized;
using StringTools;
import system.*;
import anonymoustypes.*;

class FieldInfoDescriptor extends jint.runtime.descriptors.PropertyDescriptor
{
    private var _engine:jint.Engine;
    private var _fieldInfo:system.reflection.FieldInfo;
    private var _item:Dynamic;
    public function new(engine:jint.Engine, fieldInfo:system.reflection.FieldInfo, item:Dynamic)
    {
        super();
        _engine = engine;
        _fieldInfo = fieldInfo;
        _item = item;
        Writable = new Nullable_Bool(!fieldInfo.Attributes.HasFlag(system.reflection.FieldAttributes.InitOnly));
    }
    override public function get_Value():jint.native.JsValue
    {
        return jint.native.JsValue.FromObject(_engine, _fieldInfo.GetValue(_item));
    }

    override public function set_Value(value:jint.native.JsValue):jint.native.JsValue
    {
        var currentValue:jint.native.JsValue = value;
        var obj:Dynamic;
        if (_fieldInfo.FieldType == typeof(jint.native.JsValue))
        {
            obj = currentValue;
        }
        else
        {
            obj = currentValue.ToObject();
            if (system.Cs2Hx.GetType(obj) != _fieldInfo.FieldType)
            {
                obj = _engine.ClrTypeConverter.Convert(obj, _fieldInfo.FieldType, system.globalization.CultureInfo.InvariantCulture);
            }
        }
        _fieldInfo.SetValue(_item, obj);
        return null;
    }

}
