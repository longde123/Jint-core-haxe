package jint.native.functions;
using StringTools;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
class ScriptFunctionInstance extends jint.native.functions.FunctionInstance implements jint.native.IConstructor
{
    private var _functionDeclaration:jint.parser.IFunctionDeclaration;
    public function new(engine:jint.Engine, functionDeclaration:jint.parser.IFunctionDeclaration, scope:jint.runtime.environments.LexicalEnvironment, strict:Bool)
    {
        super(engine,  functionDeclaration.Parameters.map( function (x:jint.parser.ast.Identifier):String { return x.Name; } ), scope, strict);
        _functionDeclaration = functionDeclaration;
        Engine = engine;
        Extensible = true;
        Prototype = engine.JFunction.PrototypeObject;
        DefineOwnProperty("length", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean((FormalParameters.length), (false), (false), (false)), false);
        var proto:jint.native.object.ObjectInstance = engine.JObject.Construct(jint.runtime.Arguments.Empty);
        proto.DefineOwnProperty("constructor", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(this, (true), (false), (true)), false);
        DefineOwnProperty("prototype", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(proto, (true), (false), (false)), false);
        if (_functionDeclaration.Id != null)
        {
            DefineOwnProperty("name", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(_functionDeclaration.Id.Name, null,null, null), false);
        }
        if (strict)
        {
            var thrower:jint.native.functions.FunctionInstance = engine.JFunction.ThrowTypeError;
            DefineOwnProperty("caller", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_JsValue_NullableBoolean_NullableBoolean(thrower, thrower, (false), (false)), false);
            DefineOwnProperty("arguments", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_JsValue_NullableBoolean_NullableBoolean(thrower, thrower, (false), (false)), false);
        }
    }
    override public function Call(thisArg:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var strictModeScope:jint.StrictModeScope = (new jint.StrictModeScope(Strict, true));
        var thisBinding:jint.native.JsValue;
        if (jint.StrictModeScope.IsStrictModeCode)
        {
            thisBinding = thisArg;
        }
        else if (thisArg.Equals(jint.native.Undefined.Instance) || thisArg.Equals(jint.native.Null.Instance))
        {
            thisBinding = Engine.Global;
        }
        else if (!thisArg.IsObject())
        {
            thisBinding = jint.runtime.TypeConverter.ToObject(Engine, thisArg);
        }
        else
        {
            thisBinding = thisArg;
        }
        var localEnv:jint.runtime.environments.LexicalEnvironment = jint.runtime.environments.LexicalEnvironment.NewDeclarativeEnvironment(Engine, Scope);
        Engine.EnterExecutionContext(localEnv, localEnv, thisBinding);
        Engine.DeclarationBindingInstantiation(jint.DeclarationBindingType.FunctionCode, _functionDeclaration.FunctionDeclarations, _functionDeclaration.VariableDeclarations, this, arguments);
        var result:jint.runtime.Completion = Engine.ExecuteStatement(_functionDeclaration.Body);
        if (result.Type == jint.runtime.Completion.Throw)
        {
            var ex:jint.runtime.JavaScriptException = new jint.runtime.JavaScriptException().Creator_JsValue(result.GetValueOrDefault());
            ex.Location = result.Location;
            return throw ex;
        }
        if (result.Type == jint.runtime.Completion.Return)
        {
            return result.GetValueOrDefault();
        }
        Engine.LeaveExecutionContext();
        return jint.native.Undefined.Instance;
    }
    public function Construct(arguments:Array<jint.native.JsValue>):jint.native.object.ObjectInstance
    {
        var proto:jint.native.object.ObjectInstance = Get("prototype").TryCast(jint.native.object.ObjectInstance);
        var obj:jint.native.object.ObjectInstance = new jint.native.object.ObjectInstance(Engine);
        obj.Extensible = true;
        obj.Prototype = Cs2Hx.Coalesce(proto, Engine.JObject.PrototypeObject);
        var result:jint.native.object.ObjectInstance = Call(obj, arguments).TryCast(jint.native.object.ObjectInstance);
        if (result != null)
        {
            return result;
        }
        return obj;
    }
    public var PrototypeObject:jint.native.object.ObjectInstance;
}
