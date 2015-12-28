package jint.runtime.environments;
using StringTools;
import jint.native.AbstractJsValue;
import system.*;
import anonymoustypes.*;
import haxe.ds.StringMap;
using jint.native.StaticJsValue;
class DeclarativeEnvironmentRecord extends jint.runtime.environments.EnvironmentRecord
{
    private var _engine:jint.Engine;
    private var _bindings:StringMap< jint.runtime.environments.Binding>;
    public function new(engine:jint.Engine)
    {
        super(engine);
        _bindings = new StringMap< jint.runtime.environments.Binding>();
        _engine = engine;
    }
    override public function HasBinding(name:String):Bool
    {
        return _bindings.exists(name);
    }
    override public function CreateMutableBinding(name:String, canBeDeleted:Bool = false):Void
    {
        var binding:jint.runtime.environments.Binding = new jint.runtime.environments.Binding();
        binding.Value = jint.native.Undefined.Instance;
        binding.CanBeDeleted = canBeDeleted;
        binding.Mutable = true;
        _bindings.set(name, binding);
    }
    override public function SetMutableBinding(name:String, value:jint.native.JsValue, strict:Bool):Void
    {
        var binding:jint.runtime.environments.Binding = _bindings.get(name);
        if (binding.Mutable)
        {
            binding.Value = value;
        }
        else
        {
            if (strict)
            {
                throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(_engine.TypeError, "Can't update the value of an immutable binding.");
            }
        }
    }
    override public function GetBindingValue(name:String, strict:Bool):jint.native.JsValue
    {
        var binding:jint.runtime.environments.Binding = _bindings.get(name);
        if (!binding.Mutable && binding.Value.Equals(jint.native.Undefined.Instance))
        {
            if (strict)
            {
                return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(_engine.ReferenceError, "Can't access anm uninitiazed immutable binding.");
            }
            return jint.native.Undefined.Instance;
        }
        return binding.Value;
    }
    override public function DeleteBinding(name:String):Bool
    {
        var binding:jint.runtime.environments.Binding =null;
        if (!_bindings.exists(name ))
        {
			 
            return true;
        }
		binding = _bindings.get(name);
		var value:AbstractJsValue = binding.Value;
		//todo deleted
      //  if (!value.CanBeDeleted)
        {
         //   return false;
        }
        _bindings.remove(name);
        return true;
    }
    override public function ImplicitThisValue():jint.native.JsValue
    {
        return jint.native.Undefined.Instance;
    }
    public function CreateImmutableBinding(name:String):Void
    {
        var binding:jint.runtime.environments.Binding = new jint.runtime.environments.Binding();
        binding.Value = jint.native.Undefined.Instance;
        binding.Mutable = false;
        binding.CanBeDeleted = false;
        _bindings.set(name, binding);
    }
    public function InitializeImmutableBinding(name:String, value:jint.native.JsValue):Void
    {
        var binding:jint.runtime.environments.Binding = _bindings.get(name);
        binding.Value = value;
    }
    override public function GetAllBindingNames():Array<String>
    {
        return [for (key in _bindings.keys()) key] ;
    }
}
