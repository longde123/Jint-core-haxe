package jint.runtime.debugger;
using StringTools;
import system.*;
import anonymoustypes.*;

class DebugHandler
{
    private var _debugCallStack:Array<String>;
    private var _stepMode:Int;
    private var _callBackStepOverDepth:Int;
    private var _engine:jint.Engine;
    public function new(engine:jint.Engine)
    {
        _stepMode = 0;
        _callBackStepOverDepth = 0;
        _engine = engine;
        _debugCallStack = new Array<String>();
        _stepMode = jint.runtime.debugger.StepMode.Into;
    }
    public function PopDebugCallStack():Void
    {
        if (_debugCallStack.Count > 0)
        {
            _debugCallStack.pop();
        }
        if (_stepMode == jint.runtime.debugger.StepMode.Out && _debugCallStack.Count < _callBackStepOverDepth)
        {
            _callBackStepOverDepth = _debugCallStack.Count;
            _stepMode = jint.runtime.debugger.StepMode.Into;
        }
        else if (_stepMode == jint.runtime.debugger.StepMode.Over && _debugCallStack.Count == _callBackStepOverDepth)
        {
            _callBackStepOverDepth = _debugCallStack.Count;
            _stepMode = jint.runtime.debugger.StepMode.Into;
        }
    }
    public function AddToDebugCallStack(callExpression:jint.parser.ast.CallExpression):Void
    {
        var identifier:jint.parser.ast.Identifier = cast(callExpression.Callee, jint.parser.ast.Identifier);
        if (identifier != null)
        {
            var stack:String = identifier.Name + "(";
            var paramStrings:Array<String> = new Array<String>();
            for (argument in callExpression.Arguments)
            {
                if (argument != null)
                {
                    var argIdentifier:jint.parser.ast.Identifier = cast(argument, jint.parser.ast.Identifier);
                    paramStrings.push(argIdentifier != null ? argIdentifier.Name : "null");
                }
                else
                {
                    paramStrings.push("null");
                }
            }
            stack += system.Cs2Hx.Join(", ", system.linq.Enumerable.ToArray(paramStrings));
            stack += ")";
            _debugCallStack.push(stack);
        }
    }
    public function OnStep(statement:jint.parser.ast.Statement):Void
    {
        var old:Int = _stepMode;
        if (statement == null)
        {
            return;
        }
        var breakpoint:jint.runtime.debugger.BreakPoint = system.linq.Enumerable.FirstOrDefault_IEnumerable_FuncBoolean(_engine.BreakPoints, function (breakPoint:jint.runtime.debugger.BreakPoint):Bool { return BpTest(statement, breakPoint); } );
        var breakpointFound:Bool = false;
        if (breakpoint != null)
        {
            var info:jint.runtime.debugger.DebugInformation = CreateDebugInformation(statement);
            var result:Nullable_Int = _engine.InvokeBreakEvent(info);
            if (result.HasValue)
            {
                _stepMode = result.Value;
                breakpointFound = true;
            }
        }
        if (breakpointFound == false && _stepMode == jint.runtime.debugger.StepMode.Into)
        {
            var info:jint.runtime.debugger.DebugInformation = CreateDebugInformation(statement);
            var result:Nullable_Int = _engine.InvokeStepEvent(info);
            if (result.HasValue)
            {
                _stepMode = result.Value;
            }
        }
        if (old == jint.runtime.debugger.StepMode.Into && _stepMode == jint.runtime.debugger.StepMode.Out)
        {
            _callBackStepOverDepth = _debugCallStack.Count;
        }
        else if (old == jint.runtime.debugger.StepMode.Into && _stepMode == jint.runtime.debugger.StepMode.Over)
        {
            var expressionStatement:jint.parser.ast.ExpressionStatement = cast(statement, jint.parser.ast.ExpressionStatement);
            if (expressionStatement != null && Std.is(expressionStatement.Expression, jint.parser.ast.CallExpression))
            {
                _callBackStepOverDepth = _debugCallStack.Count;
            }
            else
            {
                _stepMode = jint.runtime.debugger.StepMode.Into;
            }
        }
    }
    private function BpTest(statement:jint.parser.ast.Statement, breakpoint:jint.runtime.debugger.BreakPoint):Bool
    {
        var afterStart:Bool;
        var beforeEnd:Bool;
        afterStart = (breakpoint.Line == statement.Location.Start.Line && breakpoint.Char >= statement.Location.Start.Column);
        if (!afterStart)
        {
            return false;
        }
        beforeEnd = breakpoint.Line < statement.Location.End.Line || (breakpoint.Line == statement.Location.End.Line && breakpoint.Char <= statement.Location.End.Column);
        if (!beforeEnd)
        {
            return false;
        }
        if (!system.Cs2Hx.IsNullOrEmpty(breakpoint.Condition))
        {
            return _engine.Execute(breakpoint.Condition).GetCompletionValue().AsBoolean();
        }
        return true;
    }
    private function CreateDebugInformation(statement:jint.parser.ast.Statement):jint.runtime.debugger.DebugInformation
    {
        var info:jint.runtime.debugger.DebugInformation = new jint.runtime.debugger.DebugInformation();
        info.CurrentStatement = statement;
        info.CallStack = _debugCallStack;
        if (_engine.ExecutionContext != null && _engine.ExecutionContext.LexicalEnvironment != null)
        {
            var lexicalEnvironment:jint.runtime.environments.LexicalEnvironment = _engine.ExecutionContext.LexicalEnvironment;
            info.Locals = GetLocalVariables(lexicalEnvironment);
            info.Globals = GetGlobalVariables(lexicalEnvironment);
        }
        return info;
    }
    private static function GetLocalVariables(lex:jint.runtime.environments.LexicalEnvironment):system.collections.generic.Dictionary<String, jint.native.JsValue>
    {
        var locals:system.collections.generic.Dictionary<String, jint.native.JsValue> = new system.collections.generic.Dictionary<String, jint.native.JsValue>();
        if (lex != null && lex.Record != null)
        {
            AddRecordsFromEnvironment(lex, locals);
        }
        return locals;
    }
    private static function GetGlobalVariables(lex:jint.runtime.environments.LexicalEnvironment):system.collections.generic.Dictionary<String, jint.native.JsValue>
    {
        var globals:system.collections.generic.Dictionary<String, jint.native.JsValue> = new system.collections.generic.Dictionary<String, jint.native.JsValue>();
        var tempLex:jint.runtime.environments.LexicalEnvironment = lex;
        while (tempLex != null && tempLex.Record != null)
        {
            AddRecordsFromEnvironment(tempLex, globals);
            tempLex = tempLex.Outer;
        }
        return globals;
    }
    private static function AddRecordsFromEnvironment(lex:jint.runtime.environments.LexicalEnvironment, locals:system.collections.generic.Dictionary<String, jint.native.JsValue>):Void
    {
        var bindings:Array<String> = lex.Record.GetAllBindingNames();
        for (binding in bindings)
        {
            if (locals.ContainsKey(binding) == false)
            {
                var jsValue:jint.native.JsValue = lex.Record.GetBindingValue(binding, false);
                if (jsValue.TryCast() == null)
                {
                    locals.Add(binding, jsValue);
                }
            }
        }
    }
}
