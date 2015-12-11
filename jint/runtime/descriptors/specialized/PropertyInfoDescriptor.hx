package jint.runtime.descriptors.specialized;
using StringTools;
import system.*;
import anonymoustypes.*;

class PropertyInfoDescriptor extends jint.runtime.descriptors.PropertyDescriptor
{
    private var _engine:jint.Engine;
    private var _propertyInfo:system.reflection.PropertyInfo;
    private var _item:Dynamic;
    public function new(engine:jint.Engine, propertyInfo:system.reflection.PropertyInfo, item:Dynamic)
    {
        super();
        _engine = engine;
        _propertyInfo = propertyInfo;
        _item = item;
        Writable = new Nullable_Bool(propertyInfo.CanWrite);
    }
    override public function get_Value():jint.native.JsValue
    {
        return jint.native.JsValue.FromObject(_engine, _propertyInfo.GetValue_Object_(_item, null));
    }

    override public function set_Value(value:jint.native.JsValue):jint.native.JsValue
    {
        var currentValue:jint.native.JsValue = value;
        var obj:Dynamic;
        if (_propertyInfo.PropertyType == typeof(jint.native.JsValue))
        {
            obj = currentValue;
        }
        else
        {
            obj = currentValue.ToObject();
            if (obj != null && system.Cs2Hx.GetType(obj) != _propertyInfo.PropertyType)
            {
                obj = _engine.ClrTypeConverter.Convert(obj, _propertyInfo.PropertyType, system.globalization.CultureInfo.InvariantCulture);
            }
        }
        _propertyInfo.SetValue_Object_Object_(_item, obj, null);
        return null;
    }

}
