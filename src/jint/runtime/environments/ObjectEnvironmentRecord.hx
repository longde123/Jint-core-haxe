package jint.runtime.environments;
using StringTools;
import system.*;
import anonymoustypes.*;

class ObjectEnvironmentRecord extends jint.runtime.environments.EnvironmentRecord
{
    private var _engine:jint.Engine;
    private var _bindingObject:jint.native.object.ObjectInstance;
    private var _provideThis:Bool;
    public function new(engine:jint.Engine, bindingObject:jint.native.object.ObjectInstance, provideThis:Bool)
    {
        super(engine);
        _provideThis = false;
        _engine = engine;
        _bindingObject = bindingObject;
        _provideThis = provideThis;
    }
    override public function HasBinding(name:String):Bool
    {
        return _bindingObject.HasProperty(name);
    }
    override public function CreateMutableBinding(name:String, configurable:Bool = true):Void
    {
        _bindingObject.DefineOwnProperty(name, new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(jint.native.Undefined.Instance, (true), (true), (configurable)), true);
    }
    override public function SetMutableBinding(name:String, value:jint.native.JsValue, strict:Bool):Void
    {
        _bindingObject.Put(name, value, strict);
    }
    override public function GetBindingValue(name:String, strict:Bool):jint.native.JsValue
    {
        if (!_bindingObject.HasProperty(name))
        {
            if (!strict)
            {
                return jint.native.Undefined.Instance;
            }
            return throw new jint.runtime.JavaScriptException().Creator(_engine.ReferenceError);
        }
        return _bindingObject.Get(name);
    }
    override public function DeleteBinding(name:String):Bool
    {
        return _bindingObject.Delete(name, false);
    }
    override public function ImplicitThisValue():jint.native.JsValue
    {
        if (_provideThis)
        {
            return _bindingObject;
        }
        return jint.native.Undefined.Instance;
    }
    override public function GetAllBindingNames():Array<String>
    {
        if (_bindingObject != null)
        {
            return  [for (key in _bindingObject.GetOwnProperties().keys()) key];
        }
        return [  ];
    }
}
