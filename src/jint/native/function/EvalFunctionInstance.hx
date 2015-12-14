package jint.native.function;
using StringTools;
import system.*;
import anonymoustypes.*;

class EvalFunctionInstance extends jint.native.function.FunctionInstance
{
    private var _engine:jint.Engine;
    public function new(engine:jint.Engine, parameters:Array<String>, scope:jint.runtime.environments.LexicalEnvironment, strict:Bool)
    {
        super(engine, parameters, scope, strict);
        _engine = engine;
        Prototype = Engine.Function.PrototypeObject;
        FastAddProperty("length", 1, false, false, false);
    }
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return Call_JsValue__Boolean(thisObject, arguments, false);
    }
    public function Call_JsValue__Boolean(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>, directCall:Bool):jint.native.JsValue
    {
        if (jint.runtime.Arguments.At(arguments, 0).Type != jint.runtime.Types.String)
        {
            return jint.runtime.Arguments.At(arguments, 0);
        }
        var code:String = jint.runtime.TypeConverter.toString(jint.runtime.Arguments.At(arguments, 0));
        try
        {
            var parser:jint.parser.JavaScriptParser = new jint.parser.JavaScriptParser().Creator(jint.StrictModeScope.IsStrictModeCode);
            var program:jint.parser.ast.Program = parser.Parse(code);
            var strictModeScope:jint.StrictModeScope = (new jint.StrictModeScope(program.Strict));
            var evalCodeScope:jint.EvalCodeScope = (new jint.EvalCodeScope());
            var strictVarEnv:jint.runtime.environments.LexicalEnvironment = null;
            if (!directCall)
            {
                Engine.EnterExecutionContext(Engine.GlobalEnvironment, Engine.GlobalEnvironment, Engine.Global);
            }
            if (jint.StrictModeScope.IsStrictModeCode)
            {
                strictVarEnv = jint.runtime.environments.LexicalEnvironment.NewDeclarativeEnvironment(Engine, Engine.ExecutionContext.LexicalEnvironment);
                Engine.EnterExecutionContext(strictVarEnv, strictVarEnv, Engine.ExecutionContext.ThisBinding);
            }
            Engine.DeclarationBindingInstantiation(jint.DeclarationBindingType.EvalCode, program.FunctionDeclarations, program.VariableDeclarations, this, arguments);
            var result:jint.runtime.Completion = _engine.ExecuteStatement(program);
            if (result.Type == jint.runtime.Completion.Throw)
            {
                return throw new jint.runtime.JavaScriptException().Creator_JsValue(result.GetValueOrDefault());
            }
            else
            {
                return result.GetValueOrDefault();
            }
            if (strictVarEnv != null)
            {
                Engine.LeaveExecutionContext();
            }
            if (!directCall)
            {
                Engine.LeaveExecutionContext();
            }
        }
        catch (__ex:jint.parser.ParserException)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.SyntaxError);
        }
    }
}
