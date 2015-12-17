package jint.runtime.descriptors.specialized;
using StringTools;
import jint.native.Null;
import system.*;
import anonymoustypes.*;

class IndexDescriptor extends jint.runtime.descriptors.PropertyDescriptor
{
	//todo
    private var _engine:jint.Engine;
    private var _key:String;
    private var _item:Dynamic; 
    public function new(engine:jint.Engine, targetType:Class<Dynamic>, key:String, item:Dynamic)
    {
        super();
        _engine = engine;
        _item = item; 
        Writable = new Null<Bool>(true);
    }
    override public function get_Value():jint.native.JsValue
    { 
		try{
            var invokeValue:Bool =Lambda.has( Reflect.fields(_item),function(k) return k==_key);
            if (invokeValue != true)
            {
                return jint.native.JsValue.Undefined;
            }
       
            return jint.native.JsValue.FromObject(_engine,Reflect.field(_item, _key));
        }
        catch (__ex:Dynamic)
        {
            return jint.native.JsValue.Undefined;
        }
	 
		return null;
    }

    override public function set_Value(value:jint.native.JsValue):jint.native.JsValue
    { 
        var parameters:Dynamic=   value != null ? value.ToObject() : null  ;
        Reflect.setField(_item,_key, parameters); 
        return null;
    }

}
