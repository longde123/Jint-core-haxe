using Jint.Parser;
using Jint.Runtime;
using Jint.Runtime.Environments;

namespace Jint.Native.Functions
{
    public class EvalFunctionInstance : FunctionInstance
    {
        private readonly Engine _engine;

        public EvalFunctionInstance(Engine engine, string[] parameters, LexicalEnvironment scope, bool strict)
            : base(engine, parameters, scope, strict)
        {
            _engine = engine;
            Prototype = Engine.Function.PrototypeObject;
            FastAddProperty("length", 1, false, false, false);
        }

        public override JsValue Call(JsValue thisObject, JsValue[] arguments)
        {
            return Call(thisObject, arguments, false);
        }

        public JsValue Call(JsValue thisObject, JsValue[] arguments, bool directCall)
        {
            if (arguments.At(0).Type != Types.String)
            {
                return arguments.At(0);
            }

            var code = TypeConverter.ToString(arguments.At(0));

            try
            {
                var parser = new JavaScriptParser().Creator(StrictModeScope.IsStrictModeCode);
                var program = parser.Parse(code);
                StrictModeScope strictModeScope = (new StrictModeScope(program.Strict));

                EvalCodeScope evalCodeScope = (new EvalCodeScope());

                LexicalEnvironment strictVarEnv = null;


                if (!directCall)
                {
                    Engine.EnterExecutionContext(Engine.GlobalEnvironment, Engine.GlobalEnvironment, Engine.Global);
                }

                if (StrictModeScope.IsStrictModeCode)
                {
                    strictVarEnv = LexicalEnvironment.NewDeclarativeEnvironment(Engine, Engine.ExecutionContext.LexicalEnvironment);
                    Engine.EnterExecutionContext(strictVarEnv, strictVarEnv, Engine.ExecutionContext.ThisBinding);
                }

                Engine.DeclarationBindingInstantiation(DeclarationBindingType.EvalCode, program.FunctionDeclarations, program.VariableDeclarations, this, arguments);

                var result = _engine.ExecuteStatement(program);

                if (result.Type == Completion.Throw)
                {
                    throw new JavaScriptException().Creator(result.GetValueOrDefault());
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
            catch (ParserException)
            {
                throw new JavaScriptException().Creator(Engine.SyntaxError);
            }
        }
    }
}
