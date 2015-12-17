package jint.runtime.descriptors.specialized;
using StringTools;
import system.*;
import anonymoustypes.*;

class PropertyInfoDescriptor extends jint.runtime.descriptors.PropertyDescriptor
{
    private var _engine:jint.Engine;
    private var _propertyInfo:String;
    private var _item:Dynamic;
    public function new(engine:jint.Engine, propertyInfo:String, item:Dynamic)
    {
        super();
        _engine = engine;
        _propertyInfo = propertyInfo;
        _item = item;
        Writable = false;// new Null<Bool>(propertyInfo.CanWrite);
    }
    override public function get_Value():jint.native.JsValue
    {
        return jint.native.JsValue.FromObject(_engine,  Reflect.getProperty(_item,_propertyInfo));
    }

    override public function set_Value(value:jint.native.JsValue):jint.native.JsValue
    {
        var currentValue:jint.native.JsValue = value;
        var obj:Dynamic;
        if (Type.typeof(_item) == Type.typeof(jint.native.JsValue))
        {
            obj = currentValue;
        }
        else
        {
            obj = currentValue.ToObject();
            if (obj != null && system.Cs2Hx.GetType(obj) != Type.typeof(_item) )
            {
                obj = _engine.ClrTypeConverter.Convert(obj, Type.typeof(_item)  );
            }
        }
		_item=obj;
        return null;
    }

}
