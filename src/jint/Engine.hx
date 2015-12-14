package jint;
using StringTools;
import system.*;
import anonymoustypes.*;

class Engine
{
    private var _expressions:jint.runtime.ExpressionInterpreter;
    private var _statements:jint.runtime.StatementInterpreter;
    private var _executionContexts:Array<jint.runtime.environments.ExecutionContext>;
    private var _completionValue:jint.native.JsValue;
    private var _statementsCount:Int;
    private var _timeoutTicks:Float;
    private var _lastSyntaxNode:jint.parser.ast.SyntaxNode;
    public var ClrTypeConverter:jint.runtime.interop.ITypeConverter;
    public var TypeCache:system.collections.generic.Dictionary<String, system.TypeCS>;
    public var CallStack:jint.runtime.callstack.JintCallStack;
    public function new()
    {
        _completionValue = jint.native.JsValue.Undefined;
        _statementsCount = 0;
        _timeoutTicks = 0;
        _lastSyntaxNode = null;
        TypeCache = new system.collections.generic.Dictionary<String, system.TypeCS>();
        CallStack = new jint.runtime.callstack.JintCallStack();
        Step = new CsEvent<(Dynamic -> jint.runtime.debugger.DebugInformation -> Int)>();
        Break = new CsEvent<(Dynamic -> jint.runtime.debugger.DebugInformation -> Int)>();
        Creator(null);
    }
    public function Creator(options:(jint.Options -> Void)):jint.Engine
    {
        _executionContexts = new Array<jint.runtime.environments.ExecutionContext>();
        Global = jint.native.global.GlobalObject.CreateGlobalObject(this);
        Object = jint.native.object.ObjectConstructor.CreateObjectConstructor(this);
        Function = jint.native.function.FunctionConstructor.CreateFunctionConstructor(this);
        Array = jint.native.array.ArrayConstructor.CreateArrayConstructor(this);
        String = jint.native.string.StringConstructor.CreateStringConstructor(this);
        RegExp = jint.native.regexp.RegExpConstructor.CreateRegExpConstructor(this);
        Number = jint.native.number.NumberConstructor.CreateNumberConstructor(this);
        Boolean = jint.native.boolean.BooleanConstructor.CreateBooleanConstructor(this);
        Date = jint.native.date.DateConstructor.CreateDateConstructor(this);
        Math = jint.native.math.MathInstance.CreateMathObject(this);
        Json = jint.native.json.JsonInstance.CreateJsonObject(this);
        Error = jint.native.error.ErrorConstructor.CreateErrorConstructor(this, "Error");
        EvalError = jint.native.error.ErrorConstructor.CreateErrorConstructor(this, "EvalError");
        RangeError = jint.native.error.ErrorConstructor.CreateErrorConstructor(this, "RangeError");
        ReferenceError = jint.native.error.ErrorConstructor.CreateErrorConstructor(this, "ReferenceError");
        SyntaxError = jint.native.error.ErrorConstructor.CreateErrorConstructor(this, "SyntaxError");
        TypeError = jint.native.error.ErrorConstructor.CreateErrorConstructor(this, "TypeError");
        UriError = jint.native.error.ErrorConstructor.CreateErrorConstructor(this, "URIError");
        Global.Configure();
        Object.Configure();
        Object.PrototypeObject.Configure();
        Function.Configure();
        Function.PrototypeObject.Configure();
        Array.Configure();
        Array.PrototypeObject.Configure();
        String.Configure();
        String.PrototypeObject.Configure();
        RegExp.Configure();
        RegExp.PrototypeObject.Configure();
        Number.Configure();
        Number.PrototypeObject.Configure();
        Boolean.Configure();
        Boolean.PrototypeObject.Configure();
        Date.Configure();
        Date.PrototypeObject.Configure();
        Math.Configure();
        Json.Configure();
        Error.Configure();
        Error.PrototypeObject.Configure();
        GlobalEnvironment = jint.runtime.environments.LexicalEnvironment.NewObjectEnvironment(this, Global, null, false);
        EnterExecutionContext(GlobalEnvironment, GlobalEnvironment, Global);
        Options = new jint.Options();
        if (options != null)
        {
            options(Options);
        }
        Eval = new jint.native.function.EvalFunctionInstance(this, [  ], jint.runtime.environments.LexicalEnvironment.NewDeclarativeEnvironment(this, ExecutionContext.LexicalEnvironment), jint.StrictModeScope.IsStrictModeCode);
        Global.FastAddProperty("eval", Eval, true, false, true);
        _statements = new jint.runtime.StatementInterpreter(this);
        _expressions = new jint.runtime.ExpressionInterpreter(this);
        if (Options.IsClrAllowed())
        {
            Global.FastAddProperty("System", new jint.runtime.interop.NamespaceReference(this, "System"), false, false, false);
            Global.FastAddProperty("importNamespace", new jint.runtime.interop.ClrFunctionInstance(this, function (thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
            {
                return new jint.runtime.interop.NamespaceReference(this, jint.runtime.TypeConverter.toString(jint.runtime.Arguments.At(arguments, 0)));
            }
            ), false, false, false);
        }
        ClrTypeConverter = new jint.runtime.interop.DefaultTypeConverter(this);
        BreakPoints = new Array<jint.runtime.debugger.BreakPoint>();
        DebugHandler = new jint.runtime.debugger.DebugHandler(this);
        return this;
    }
    public var GlobalEnvironment:jint.runtime.environments.LexicalEnvironment;
    public var Global:jint.native.global.GlobalObject;
    public var Object:jint.native.object.ObjectConstructor;
    public var Function:jint.native.function.FunctionConstructor;
    public var Array:jint.native.array.ArrayConstructor;
    public var String:jint.native.string.StringConstructor;
    public var RegExp:jint.native.regexp.RegExpConstructor;
    public var Boolean:jint.native.boolean.BooleanConstructor;
    public var Number:jint.native.number.NumberConstructor;
    public var Date:jint.native.date.DateConstructor;
    public var Math:jint.native.math.MathInstance;
    public var Json:jint.native.json.JsonInstance;
    public var Eval:jint.native.function.EvalFunctionInstance;
    public var Error:jint.native.error.ErrorConstructor;
    public var EvalError:jint.native.error.ErrorConstructor;
    public var SyntaxError:jint.native.error.ErrorConstructor;
    public var TypeError:jint.native.error.ErrorConstructor;
    public var RangeError:jint.native.error.ErrorConstructor;
    public var ReferenceError:jint.native.error.ErrorConstructor;
    public var UriError:jint.native.error.ErrorConstructor;
    public var ExecutionContext(get_ExecutionContext, never):jint.runtime.environments.ExecutionContext;
    public function get_ExecutionContext():jint.runtime.environments.ExecutionContext
    {
        return _executionContexts.Peek();
    }

    public var Options:jint.Options;
    public var DebugHandler:jint.runtime.debugger.DebugHandler;
    public var BreakPoints:Array<jint.runtime.debugger.BreakPoint>;
    public function InvokeStepEvent(info:jint.runtime.debugger.DebugInformation):Nullable_Int
    {
        if (Step != null)
        {
            return new Nullable_Int(Step.Invoke(this, info));
        }
        return new Nullable_Int();
    }
    public function InvokeBreakEvent(info:jint.runtime.debugger.DebugInformation):Nullable_Int
    {
        if (Break != null)
        {
            return new Nullable_Int(Break.Invoke(this, info));
        }
        return new Nullable_Int();
    }
    public function EnterExecutionContext(lexicalEnvironment:jint.runtime.environments.LexicalEnvironment, variableEnvironment:jint.runtime.environments.LexicalEnvironment, thisBinding:jint.native.JsValue):jint.runtime.environments.ExecutionContext
    {
        var executionContext:jint.runtime.environments.ExecutionContext = new jint.runtime.environments.ExecutionContext();
        executionContext.LexicalEnvironment = lexicalEnvironment;
        executionContext.VariableEnvironment = variableEnvironment;
        executionContext.ThisBinding = thisBinding;
        _executionContexts.push(executionContext);
        return executionContext;
    }
    public function SetValue(name:String, value:system.Delegate):jint.Engine
    {
        Global.FastAddProperty(name, new jint.runtime.interop.DelegateWrapper(this, value), true, false, true);
        return this;
    }
    public function SetValue_String_String(name:String, value:String):jint.Engine
    {
        return SetValue_String_JsValue(name, new jint.native.JsValue().Creator_String(value));
    }
    public function SetValue_String_Double(name:String, value:Float):jint.Engine
    {
        return SetValue_String_JsValue(name, new jint.native.JsValue().Creator_Double(value));
    }
    public function SetValue_String_Boolean(name:String, value:Bool):jint.Engine
    {
        return SetValue_String_JsValue(name, new jint.native.JsValue().Creator(value));
    }
    public function SetValue_String_JsValue(name:String, value:jint.native.JsValue):jint.Engine
    {
        Global.Put(name, value, false);
        return this;
    }
    public function SetValue_String_Object(name:String, obj:Dynamic):jint.Engine
    {
        return SetValue_String_JsValue(name, jint.native.JsValue.FromObject(this, obj));
    }
    public function LeaveExecutionContext():Void
    {
        _executionContexts.pop();
    }
    public function ResetStatementsCount():Void
    {
        _statementsCount = 0;
    }
    public function ResetTimeoutTicks():Void
    {
        var timeoutIntervalTicks:Float = Options.GetTimeoutInterval().Ticks;
        _timeoutTicks = timeoutIntervalTicks > 0 ? system.DateTime.UtcNow.Ticks + timeoutIntervalTicks : 0;
    }
    public function ResetCallStack():Void
    {
        CallStack.Clear();
    }
    public function Execute(source:String):jint.Engine
    {
        var parser:jint.parser.JavaScriptParser = new jint.parser.JavaScriptParser();
        return Execute_Program(parser.Parse(source));
    }
    public function Execute_String_ParserOptions(source:String, parserOptions:jint.parser.ParserOptions):jint.Engine
    {
        var parser:jint.parser.JavaScriptParser = new jint.parser.JavaScriptParser();
        return Execute_Program(parser.Parse_String_ParserOptions(source, parserOptions));
    }
    public function Execute_Program(program:jint.parser.ast.Program):jint.Engine
    {
        ResetStatementsCount();
        ResetTimeoutTicks();
        ResetLastStatement();
        ResetCallStack();
        var strictModeScope:jint.StrictModeScope = (new jint.StrictModeScope(Options.IsStrict() || program.Strict));
        DeclarationBindingInstantiation(jint.DeclarationBindingType.GlobalCode, program.FunctionDeclarations, program.VariableDeclarations, null, null);
        var result:jint.runtime.Completion = _statements.ExecuteProgram(program);
        if (result.Type == jint.runtime.Completion.Throw)
        {
            var javaScriptException:jint.runtime.JavaScriptException = new jint.runtime.JavaScriptException().Creator_JsValue(result.GetValueOrDefault());
            javaScriptException.Location = result.Location;
            return throw javaScriptException;
        }
        _completionValue = result.GetValueOrDefault();
        return this;
    }
    private function ResetLastStatement():Void
    {
        _lastSyntaxNode = null;
    }
    public function GetCompletionValue():jint.native.JsValue
    {
        return _completionValue;
    }
    public function ExecuteStatement(statement:jint.parser.ast.Statement):jint.runtime.Completion
    {
        var maxStatements:Int = Options.GetMaxStatements();
        if (maxStatements > 0 && _statementsCount++ > maxStatements)
        {
            return throw new jint.runtime.StatementsCountOverflowException();
        }
        if (_timeoutTicks > 0 && _timeoutTicks < system.DateTime.UtcNow.Ticks)
        {
            return throw new system.TimeoutException();
        }
        _lastSyntaxNode = statement;
        if (Options.IsDebugMode())
        {
            DebugHandler.OnStep(statement);
        }
        switch (statement.Type)
        {
            case jint.parser.ast.SyntaxNodes.BlockStatement:
                return _statements.ExecuteBlockStatement(statement.As());
            case jint.parser.ast.SyntaxNodes.BreakStatement:
                return _statements.ExecuteBreakStatement(statement.As());
            case jint.parser.ast.SyntaxNodes.ContinueStatement:
                return _statements.ExecuteContinueStatement(statement.As());
            case jint.parser.ast.SyntaxNodes.DoWhileStatement:
                return _statements.ExecuteDoWhileStatement(statement.As());
            case jint.parser.ast.SyntaxNodes.DebuggerStatement:
                return _statements.ExecuteDebuggerStatement(statement.As());
            case jint.parser.ast.SyntaxNodes.EmptyStatement:
                return _statements.ExecuteEmptyStatement(statement.As());
            case jint.parser.ast.SyntaxNodes.ExpressionStatement:
                return _statements.ExecuteExpressionStatement(statement.As());
            case jint.parser.ast.SyntaxNodes.ForStatement:
                return _statements.ExecuteForStatement(statement.As());
            case jint.parser.ast.SyntaxNodes.ForInStatement:
                return _statements.ExecuteForInStatement(statement.As());
            case jint.parser.ast.SyntaxNodes.FunctionDeclaration:
                return new jint.runtime.Completion(jint.runtime.Completion.Normal, null, null);
            case jint.parser.ast.SyntaxNodes.IfStatement:
                return _statements.ExecuteIfStatement(statement.As());
            case jint.parser.ast.SyntaxNodes.LabeledStatement:
                return _statements.ExecuteLabelledStatement(statement.As());
            case jint.parser.ast.SyntaxNodes.ReturnStatement:
                return _statements.ExecuteReturnStatement(statement.As());
            case jint.parser.ast.SyntaxNodes.SwitchStatement:
                return _statements.ExecuteSwitchStatement(statement.As());
            case jint.parser.ast.SyntaxNodes.ThrowStatement:
                return _statements.ExecuteThrowStatement(statement.As());
            case jint.parser.ast.SyntaxNodes.TryStatement:
                return _statements.ExecuteTryStatement(statement.As());
            case jint.parser.ast.SyntaxNodes.VariableDeclaration:
                return _statements.ExecuteVariableDeclaration(statement.As());
            case jint.parser.ast.SyntaxNodes.WhileStatement:
                return _statements.ExecuteWhileStatement(statement.As());
            case jint.parser.ast.SyntaxNodes.WithStatement:
                return _statements.ExecuteWithStatement(statement.As());
            case jint.parser.ast.SyntaxNodes.Program:
                return _statements.ExecuteProgram(statement.As());
            default:
                return throw new system.ArgumentOutOfRangeException();
        }
    }
    public function EvaluateExpression(expression:jint.parser.ast.Expression):Dynamic
    {
        _lastSyntaxNode = expression;
        switch (expression.Type)
        {
            case jint.parser.ast.SyntaxNodes.AssignmentExpression:
                return _expressions.EvaluateAssignmentExpression(expression.As());
            case jint.parser.ast.SyntaxNodes.ArrayExpression:
                return _expressions.EvaluateArrayExpression(expression.As());
            case jint.parser.ast.SyntaxNodes.BinaryExpression:
                return _expressions.EvaluateBinaryExpression(expression.As());
            case jint.parser.ast.SyntaxNodes.CallExpression:
                return _expressions.EvaluateCallExpression(expression.As());
            case jint.parser.ast.SyntaxNodes.ConditionalExpression:
                return _expressions.EvaluateConditionalExpression(expression.As());
            case jint.parser.ast.SyntaxNodes.FunctionExpression:
                return _expressions.EvaluateFunctionExpression(expression.As());
            case jint.parser.ast.SyntaxNodes.Identifier:
                return _expressions.EvaluateIdentifier(expression.As());
            case jint.parser.ast.SyntaxNodes.Literal:
                return _expressions.EvaluateLiteral(expression.As());
            case jint.parser.ast.SyntaxNodes.RegularExpressionLiteral:
                return _expressions.EvaluateLiteral(expression.As());
            case jint.parser.ast.SyntaxNodes.LogicalExpression:
                return _expressions.EvaluateLogicalExpression(expression.As());
            case jint.parser.ast.SyntaxNodes.MemberExpression:
                return _expressions.EvaluateMemberExpression(expression.As());
            case jint.parser.ast.SyntaxNodes.NewExpression:
                return _expressions.EvaluateNewExpression(expression.As());
            case jint.parser.ast.SyntaxNodes.ObjectExpression:
                return _expressions.EvaluateObjectExpression(expression.As());
            case jint.parser.ast.SyntaxNodes.SequenceExpression:
                return _expressions.EvaluateSequenceExpression(expression.As());
            case jint.parser.ast.SyntaxNodes.ThisExpression:
                return _expressions.EvaluateThisExpression(expression.As());
            case jint.parser.ast.SyntaxNodes.UpdateExpression:
                return _expressions.EvaluateUpdateExpression(expression.As());
            case jint.parser.ast.SyntaxNodes.UnaryExpression:
                return _expressions.EvaluateUnaryExpression(expression.As());
            default:
                return throw new system.ArgumentOutOfRangeException();
        }
    }
    public function GetValue(value:Dynamic):jint.native.JsValue
    {
        var reference:jint.runtime.references.Reference = (Std.is(value, jint.runtime.references.Reference) ? cast(value, jint.runtime.references.Reference) : null);
        if (reference == null)
        {
            var completion:jint.runtime.Completion = (Std.is(value, jint.runtime.Completion) ? cast(value, jint.runtime.Completion) : null);
            if (completion != null)
            {
                return GetValue(completion.Value);
            }
            return value;
        }
        if (reference.IsUnresolvableReference())
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(ReferenceError, reference.GetReferencedName() + " is not defined");
        }
        var baseValue:jint.native.JsValue = reference.GetBase();
        if (reference.IsPropertyReference())
        {
            if (reference.HasPrimitiveBase() == false)
            {
                var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(this, baseValue);
                return o.Get(reference.GetReferencedName());
            }
            else
            {
                var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(this, baseValue);
                var desc:jint.runtime.descriptors.PropertyDescriptor = o.GetProperty(reference.GetReferencedName());
                if (desc == jint.runtime.descriptors.PropertyDescriptor.Undefined)
                {
                    return jint.native.JsValue.Undefined;
                }
                if (desc.IsDataDescriptor())
                {
                    return desc.Value;
                }
                var getter:jint.native.JsValue = desc.Get;
                if (getter.Equals(jint.native.Undefined.Instance))
                {
                    return jint.native.Undefined.Instance;
                }
                var callable:jint.native.ICallable = cast(getter.AsObject(), jint.native.ICallable);
                return callable.Call(baseValue, jint.runtime.Arguments.Empty);
            }
        }
        else
        {
            var record:jint.runtime.environments.EnvironmentRecord = baseValue.As();
            if (record == null)
            {
                return throw new system.ArgumentException();
            }
            return record.GetBindingValue(reference.GetReferencedName(), reference.IsStrict());
        }
    }
    public function PutValue(reference:jint.runtime.references.Reference, value:jint.native.JsValue):Void
    {
        if (reference.IsUnresolvableReference())
        {
            if (reference.IsStrict())
            {
                throw new jint.runtime.JavaScriptException().Creator(ReferenceError);
            }
            Global.Put(reference.GetReferencedName(), value, false);
        }
        else if (reference.IsPropertyReference())
        {
            var baseValue:jint.native.JsValue = reference.GetBase();
            if (!reference.HasPrimitiveBase())
            {
                baseValue.AsObject().Put(reference.GetReferencedName(), value, reference.IsStrict());
            }
            else
            {
                PutPrimitiveBase(baseValue, reference.GetReferencedName(), value, reference.IsStrict());
            }
        }
        else
        {
            var baseValue:jint.native.JsValue = reference.GetBase();
            var record:jint.runtime.environments.EnvironmentRecord = baseValue.As();
            if (record == null)
            {
                throw new system.ArgumentNullException();
            }
            record.SetMutableBinding(reference.GetReferencedName(), value, reference.IsStrict());
        }
    }
    public function PutPrimitiveBase(b:jint.native.JsValue, name:String, value:jint.native.JsValue, throwOnError:Bool):Void
    {
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(this, b);
        if (!o.CanPut(name))
        {
            if (throwOnError)
            {
                throw new jint.runtime.JavaScriptException().Creator(TypeError);
            }
            return;
        }
        var ownDesc:jint.runtime.descriptors.PropertyDescriptor = o.GetOwnProperty(name);
        if (ownDesc.IsDataDescriptor())
        {
            if (throwOnError)
            {
                throw new jint.runtime.JavaScriptException().Creator(TypeError);
            }
            return;
        }
        var desc:jint.runtime.descriptors.PropertyDescriptor = o.GetProperty(name);
        if (desc.IsAccessorDescriptor())
        {
            var setter:jint.native.ICallable = cast(desc.Set.AsObject(), jint.native.ICallable);
            setter.Call(b, [ value ]);
        }
        else
        {
            if (throwOnError)
            {
                throw new jint.runtime.JavaScriptException().Creator(TypeError);
            }
        }
    }
    public function Invoke(propertyName:String, arguments:Array<Dynamic>):jint.native.JsValue
    {
        return Invoke_String_Object_(propertyName, null, arguments);
    }
    public function Invoke_String_Object_(propertyName:String, thisObj:Dynamic, arguments:Array<Dynamic>):jint.native.JsValue
    {
        var value:jint.native.JsValue = GetValue_String(propertyName);
        var callable:jint.native.ICallable = value.TryCast();
        if (callable == null)
        {
            return throw new system.ArgumentException("Can only invoke functions");
        }
        return callable.Call(jint.native.JsValue.FromObject(this, thisObj), system.linq.Enumerable.ToArray(system.linq.Enumerable.Select(arguments, function (x:Dynamic):jint.native.JsValue { return jint.native.JsValue.FromObject(this, x); } )));
    }
    public function GetValue_String(propertyName:String):jint.native.JsValue
    {
        return GetValue_JsValue_String(Global, propertyName);
    }
    public function GetLastSyntaxNode():jint.parser.ast.SyntaxNode
    {
        return _lastSyntaxNode;
    }
    public function GetValue_JsValue_String(scope:jint.native.JsValue, propertyName:String):jint.native.JsValue
    {
        if (system.Cs2Hx.IsNullOrEmpty(propertyName))
        {
            return throw new system.ArgumentException("propertyName");
        }
        var reference:jint.runtime.references.Reference = new jint.runtime.references.Reference(scope, propertyName, Options.IsStrict());
        return GetValue(reference);
    }
    public function DeclarationBindingInstantiation(declarationBindingType:Int, functionDeclarations:Array<jint.parser.ast.FunctionDeclaration>, variableDeclarations:Array<jint.parser.ast.VariableDeclaration>, functionInstance:jint.native.function.FunctionInstance, arguments:Array<jint.native.JsValue>):Void
    {
        var env:jint.runtime.environments.EnvironmentRecord = ExecutionContext.VariableEnvironment.Record;
        var configurableBindings:Bool = declarationBindingType == jint.DeclarationBindingType.EvalCode;
        var strict:Bool = jint.StrictModeScope.IsStrictModeCode;
        if (declarationBindingType == jint.DeclarationBindingType.FunctionCode)
        {
            var argCount:Int = arguments.length;
            var n:Int = 0;
            for (argName in functionInstance.FormalParameters)
            {
                n++;
                var v:jint.native.JsValue = n > argCount ? jint.native.Undefined.Instance : arguments[n - 1];
                var argAlreadyDeclared:Bool = env.HasBinding(argName);
                if (!argAlreadyDeclared)
                {
                    env.CreateMutableBinding(argName);
                }
                env.SetMutableBinding(argName, v, strict);
            }
        }
        for (f in functionDeclarations)
        {
            var fn:String = f.Id.Name;
            var fo:jint.native.function.FunctionInstance = Function.CreateFunctionObject(f);
            var funcAlreadyDeclared:Bool = env.HasBinding(fn);
            if (!funcAlreadyDeclared)
            {
                env.CreateMutableBinding(fn, configurableBindings);
            }
            else
            {
                if (env == GlobalEnvironment.Record)
                {
                    var go:jint.native.global.GlobalObject = Global;
                    var existingProp:jint.runtime.descriptors.PropertyDescriptor = go.GetProperty(fn);
                    if (existingProp.Configurable.Value)
                    {
                        go.DefineOwnProperty(fn, new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(jint.native.Undefined.Instance, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(configurableBindings)), true);
                    }
                    else
                    {
                        if (existingProp.IsAccessorDescriptor() || (!existingProp.Enumerable.Value))
                        {
                            throw new jint.runtime.JavaScriptException().Creator(TypeError);
                        }
                    }
                }
            }
            env.SetMutableBinding(fn, fo, strict);
        }
        var argumentsAlreadyDeclared:Bool = env.HasBinding("arguments");
        if (declarationBindingType == jint.DeclarationBindingType.FunctionCode && !argumentsAlreadyDeclared)
        {
            var argsObj:jint.native.argument.ArgumentsInstance = jint.native.argument.ArgumentsInstance.CreateArgumentsObject(this, functionInstance, functionInstance.FormalParameters, arguments, env, strict);
            if (strict)
            {
                var declEnv:jint.runtime.environments.DeclarativeEnvironmentRecord = (Std.is(env, jint.runtime.environments.DeclarativeEnvironmentRecord) ? cast(env, jint.runtime.environments.DeclarativeEnvironmentRecord) : null);
                if (declEnv == null)
                {
                    throw new system.ArgumentException();
                }
                declEnv.CreateImmutableBinding("arguments");
                declEnv.InitializeImmutableBinding("arguments", argsObj);
            }
            else
            {
                env.CreateMutableBinding("arguments");
                env.SetMutableBinding("arguments", argsObj, false);
            }
        }
        for (d in system.linq.Enumerable.SelectMany(variableDeclarations, function (x:jint.parser.ast.VariableDeclaration):Array<jint.parser.ast.VariableDeclarator> { return x.Declarations; } ))
        {
            var dn:String = d.Id.Name;
            var varAlreadyDeclared:Bool = env.HasBinding(dn);
            if (!varAlreadyDeclared)
            {
                env.CreateMutableBinding(dn, configurableBindings);
                env.SetMutableBinding(dn, jint.native.Undefined.Instance, strict);
            }
        }
    }
}