package jint.runtime.environments;
using StringTools;
import system.*;
import anonymoustypes.*;

class DeclarativeEnvironmentRecord extends jint.runtime.environments.EnvironmentRecord
{
    private var _engine:jint.Engine;
    private var _bindings:system.collections.generic.IDictionary<String, jint.runtime.environments.Binding>;
    public function new(engine:jint.Engine)
    {
        super(engine);
        _bindings = new system.collections.generic.Dictionary<String, jint.runtime.environments.Binding>();
        _engine = engine;
    }
    override public function HasBinding(name:String):Bool
    {
        return _bindings.ContainsKey(name);
    }
    override public function CreateMutableBinding(name:String, canBeDeleted:Bool = false):Void
    {
        var binding:jint.runtime.environments.Binding = new jint.runtime.environments.Binding();
        binding.Value = jint.native.Undefined.Instance;
        binding.CanBeDeleted = canBeDeleted;
        binding.Mutable = true;
        _bindings.Add(name, binding);
    }
    override public function SetMutableBinding(name:String, value:jint.native.JsValue, strict:Bool):Void
    {
        var binding:jint.runtime.environments.Binding = _bindings.GetValue_TKey(name);
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
        var binding:jint.runtime.environments.Binding = _bindings.GetValue_TKey(name);
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
        var binding:CsRef<jint.runtime.environments.Binding> = new CsRef<jint.runtime.environments.Binding>(null);
        if (!_bindings.TryGetValue(name, binding))
        {
            return true;
        }
        if (!binding.Value.CanBeDeleted)
        {
            return false;
        }
        _bindings.Remove(name);
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
        _bindings.Add(name, binding);
    }
    public function InitializeImmutableBinding(name:String, value:jint.native.JsValue):Void
    {
        var binding:jint.runtime.environments.Binding = _bindings.GetValue_TKey(name);
        binding.Value = value;
    }
    override public function GetAllBindingNames():Array<String>
    {
        return system.linq.Enumerable.ToArray(_bindings.Keys);
    }
}
