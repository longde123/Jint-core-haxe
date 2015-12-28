package jint.runtime.descriptors.specialized;
using StringTools;
import jint.native.AbstractJsValue;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
class FieldInfoDescriptor extends jint.runtime.descriptors.PropertyDescriptor
{
    private var _engine:jint.Engine;
    private var _fieldInfo:String;
    private var _item:Dynamic;
    public function new(engine:jint.Engine, fieldInfo:String, item:Dynamic)
    {
        super();
        _engine = engine;
        _fieldInfo = fieldInfo;
        _item = item;
        Writable = false;//todo new Null<Bool>(!fieldInfo.Attributes.HasFlag(system.reflection.FieldAttributes.InitOnly));
    }
    override public function get_Value():jint.native.JsValue
    {
        return jint.native.JsValue.FromObject(_engine,Reflect.field(_item, _fieldInfo));
    }

    override public function set_Value(value:jint.native.JsValue):jint.native.JsValue
    {
		//todo 
        var currentValue:jint.native.JsValue = value;
        var obj:Dynamic;
        if (Std.is(_item, AbstractJsValue))
        {
            obj = currentValue;
        }
        else
        {
            obj = currentValue.ToObject();
            if (Type.getClass(obj) != Type.getClass(_item))
            {
                obj = _engine.ClrTypeConverter.Convert(obj,Type.getClass(_item) );
            }
        }
        _item=obj;
        return null;
    }

}
