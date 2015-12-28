package jint.runtime;
using StringTools;
import system.*;
import anonymoustypes.*;

class StatementInterpreter
{
    private var _engine:jint.Engine;
    public function new(engine:jint.Engine)
    {
        _engine = engine;
    }
    private function ExecuteStatement(statement:jint.parser.ast.Statement):jint.runtime.Completion
    {
        return _engine.ExecuteStatement(statement);
    }
    public function ExecuteEmptyStatement(emptyStatement:jint.parser.ast.EmptyStatement):jint.runtime.Completion
    {
        return new jint.runtime.Completion(jint.runtime.Completion.Normal, null, null);
    }
    public function ExecuteExpressionStatement(expressionStatement:jint.parser.ast.ExpressionStatement):jint.runtime.Completion
    {
        var exprRef:Dynamic = _engine.EvaluateExpression(expressionStatement.Expression);
        return new jint.runtime.Completion(jint.runtime.Completion.Normal, _engine.GetValue(exprRef), null);
    }
    public function ExecuteIfStatement(ifStatement:jint.parser.ast.IfStatement):jint.runtime.Completion
    {
        var exprRef:Dynamic = _engine.EvaluateExpression(ifStatement.Test);
        var result:jint.runtime.Completion;
        if (jint.runtime.TypeConverter.ToBoolean(_engine.GetValue(exprRef)))
        {
            result = ExecuteStatement(ifStatement.Consequent);
        }
        else if (ifStatement.Alternate != null)
        {
            result = ExecuteStatement(ifStatement.Alternate);
        }
        else
        {
            return new jint.runtime.Completion(jint.runtime.Completion.Normal, null, null);
        }
        return result;
    }
    public function ExecuteLabelledStatement(labelledStatement:jint.parser.ast.LabelledStatement):jint.runtime.Completion
    {
        labelledStatement.Body.LabelSet = labelledStatement.Label.Name;
        var result:jint.runtime.Completion = ExecuteStatement(labelledStatement.Body);
        if (result.Type == jint.runtime.Completion.Break && result.Identifier == labelledStatement.Label.Name)
        {
            return new jint.runtime.Completion(jint.runtime.Completion.Normal, result.Value, null);
        }
        return result;
    }
    public function ExecuteDoWhileStatement(doWhileStatement:jint.parser.ast.DoWhileStatement):jint.runtime.Completion
    {
        var v:jint.native.JsValue = jint.native.Undefined.Instance;
        var iterating:Bool;
        do
        {
            var stmt:jint.runtime.Completion = ExecuteStatement(doWhileStatement.Body);
            if (stmt.Value != null)
            {
                v = stmt.Value;
            }
            if (stmt.Type != jint.runtime.Completion.Continue || stmt.Identifier != doWhileStatement.LabelSet)
            {
                if (stmt.Type == jint.runtime.Completion.Break && (stmt.Identifier == null || stmt.Identifier == doWhileStatement.LabelSet))
                {
                    return new jint.runtime.Completion(jint.runtime.Completion.Normal, v, null);
                }
                if (stmt.Type != jint.runtime.Completion.Normal)
                {
                    return stmt;
                }
            }
            var exprRef:Dynamic = _engine.EvaluateExpression(doWhileStatement.Test);
            iterating = jint.runtime.TypeConverter.ToBoolean(_engine.GetValue(exprRef));
        }
        while (iterating);
        return new jint.runtime.Completion(jint.runtime.Completion.Normal, v, null);
    }
    public function ExecuteWhileStatement(whileStatement:jint.parser.ast.WhileStatement):jint.runtime.Completion
    {
        var v:jint.native.JsValue = jint.native.Undefined.Instance;
        while (true)
        {
            var exprRef:Dynamic = _engine.EvaluateExpression(whileStatement.Test);
            if (!jint.runtime.TypeConverter.ToBoolean(_engine.GetValue(exprRef)))
            {
                return new jint.runtime.Completion(jint.runtime.Completion.Normal, v, null);
            }
            var stmt:jint.runtime.Completion = ExecuteStatement(whileStatement.Body);
            if (stmt.Value != null)
            {
                v = stmt.Value;
            }
            if (stmt.Type != jint.runtime.Completion.Continue || stmt.Identifier != whileStatement.LabelSet)
            {
                if (stmt.Type == jint.runtime.Completion.Break && (stmt.Identifier == null || stmt.Identifier == whileStatement.LabelSet))
                {
                    return new jint.runtime.Completion(jint.runtime.Completion.Normal, v, null);
                }
                if (stmt.Type != jint.runtime.Completion.Normal)
                {
                    return stmt;
                }
            }
        }
    }
    public function ExecuteForStatement(forStatement:jint.parser.ast.ForStatement):jint.runtime.Completion
    {
        if (forStatement.Init != null)
        {
            if (forStatement.Init.Type == jint.parser.ast.SyntaxNodes.VariableDeclaration)
            {
                ExecuteStatement(forStatement.Init.As());
            }
            else
            {
                _engine.GetValue(_engine.EvaluateExpression(forStatement.Init.As()));
            }
        }
        var v:jint.native.JsValue = jint.native.Undefined.Instance;
        while (true)
        {
            if (forStatement.Test != null)
            {
                var testExprRef:Dynamic = _engine.EvaluateExpression(forStatement.Test);
                if (!jint.runtime.TypeConverter.ToBoolean(_engine.GetValue(testExprRef)))
                {
                    return new jint.runtime.Completion(jint.runtime.Completion.Normal, v, null);
                }
            }
            var stmt:jint.runtime.Completion = ExecuteStatement(forStatement.Body);
            if (stmt.Value != null)
            {
                v = stmt.Value;
            }
            if (stmt.Type == jint.runtime.Completion.Break && (stmt.Identifier == null || stmt.Identifier == forStatement.LabelSet))
            {
                return new jint.runtime.Completion(jint.runtime.Completion.Normal, v, null);
            }
            if (stmt.Type != jint.runtime.Completion.Continue || ((stmt.Identifier != null) && stmt.Identifier != forStatement.LabelSet))
            {
                if (stmt.Type != jint.runtime.Completion.Normal)
                {
                    return stmt;
                }
            }
            if (forStatement.Update != null)
            {
                var incExprRef:Dynamic = _engine.EvaluateExpression(forStatement.Update);
                _engine.GetValue(incExprRef);
            }
        }
    }
    public function ExecuteForInStatement(forInStatement:jint.parser.ast.ForInStatement):jint.runtime.Completion
    {
        var identifier:jint.parser.ast.Identifier = forInStatement.Left.Type == jint.parser.ast.SyntaxNodes.VariableDeclaration ? system.linq.Enumerable.First(forInStatement.Left.As().Declarations).Id : forInStatement.Left.As();
        var varRef:jint.runtime.references.Reference = _engine.EvaluateExpression(identifier);
        var exprRef:Dynamic = _engine.EvaluateExpression(forInStatement.Right);
        var experValue:jint.native.JsValue = _engine.GetValue(exprRef);
        if (experValue.Equals(jint.native.Undefined.Instance) || experValue.Equals(jint.native.Null.Instance))
        {
            return new jint.runtime.Completion(jint.runtime.Completion.Normal, null, null);
        }
        var obj:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(_engine, experValue);
        var v:jint.native.JsValue = jint.native.Null.Instance;
        var cursor:jint.native.object.ObjectInstance = obj;
        var processedKeys:system.collections.generic.HashSet<String> = new system.collections.generic.HashSet<String>();
        while (cursor != null)
        {
            var keys:Array<String> = system.linq.Enumerable.ToArray(system.linq.Enumerable.Select(cursor.GetOwnProperties(), function (x:system.collections.generic.KeyValuePair<String, jint.runtime.descriptors.PropertyDescriptor>):String { return x.Key; } ));
            for (p in keys)
            {
                if (processedKeys.Contains(p))
                {
                    continue;
                }
                processedKeys.Add(p);
                if (!cursor.HasOwnProperty(p))
                {
                    continue;
                }
                var value:jint.runtime.descriptors.PropertyDescriptor = cursor.GetOwnProperty(p);
                if (!value.Enumerable.HasValue || !value.Enumerable.Value)
                {
                    continue;
                }
                _engine.PutValue(varRef, p);
                var stmt:jint.runtime.Completion = ExecuteStatement(forInStatement.Body);
                if (stmt.Value != null)
                {
                    v = stmt.Value;
                }
                if (stmt.Type == jint.runtime.Completion.Break)
                {
                    return new jint.runtime.Completion(jint.runtime.Completion.Normal, v, null);
                }
                if (stmt.Type != jint.runtime.Completion.Continue)
                {
                    if (stmt.Type != jint.runtime.Completion.Normal)
                    {
                        return stmt;
                    }
                }
            }
            cursor = cursor.Prototype;
        }
        return new jint.runtime.Completion(jint.runtime.Completion.Normal, v, null);
    }
    public function ExecuteContinueStatement(continueStatement:jint.parser.ast.ContinueStatement):jint.runtime.Completion
    {
        return new jint.runtime.Completion(jint.runtime.Completion.Continue, null, continueStatement.Label != null ? continueStatement.Label.Name : null);
    }
    public function ExecuteBreakStatement(breakStatement:jint.parser.ast.BreakStatement):jint.runtime.Completion
    {
        return new jint.runtime.Completion(jint.runtime.Completion.Break, null, breakStatement.Label != null ? breakStatement.Label.Name : null);
    }
    public function ExecuteReturnStatement(statement:jint.parser.ast.ReturnStatement):jint.runtime.Completion
    {
        if (statement.Argument == null)
        {
            return new jint.runtime.Completion(jint.runtime.Completion.Return, jint.native.Undefined.Instance, null);
        }
        var exprRef:Dynamic = _engine.EvaluateExpression(statement.Argument);
        return new jint.runtime.Completion(jint.runtime.Completion.Return, _engine.GetValue(exprRef), null);
    }
    public function ExecuteWithStatement(withStatement:jint.parser.ast.WithStatement):jint.runtime.Completion
    {
        var val:Dynamic = _engine.EvaluateExpression(withStatement.Object);
        var obj:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(_engine, _engine.GetValue(val));
        var oldEnv:jint.runtime.environments.LexicalEnvironment = _engine.ExecutionContext.LexicalEnvironment;
        var newEnv:jint.runtime.environments.LexicalEnvironment = jint.runtime.environments.LexicalEnvironment.NewObjectEnvironment(_engine, obj, oldEnv, true);
        _engine.ExecutionContext.LexicalEnvironment = newEnv;
        var c:jint.runtime.Completion;
        try
        {
            c = ExecuteStatement(withStatement.Body);
        }
        catch (e:jint.runtime.JavaScriptException)
        {
            c = new jint.runtime.Completion(jint.runtime.Completion.Throw, e.Error, null);
            c.Location = withStatement.Location;
        }
        _engine.ExecutionContext.LexicalEnvironment = oldEnv;
        return c;
    }
    public function ExecuteSwitchStatement(switchStatement:jint.parser.ast.SwitchStatement):jint.runtime.Completion
    {
        var exprRef:Dynamic = _engine.EvaluateExpression(switchStatement.Discriminant);
        var r:jint.runtime.Completion = ExecuteSwitchBlock(switchStatement.Cases, _engine.GetValue(exprRef));
        if (r.Type == jint.runtime.Completion.Break && r.Identifier == switchStatement.LabelSet)
        {
            return new jint.runtime.Completion(jint.runtime.Completion.Normal, r.Value, null);
        }
        return r;
    }
    public function ExecuteSwitchBlock(switchBlock:Array<jint.parser.ast.SwitchCase>, input:jint.native.JsValue):jint.runtime.Completion
    {
        var v:jint.native.JsValue = jint.native.Undefined.Instance;
        var defaultCase:jint.parser.ast.SwitchCase = null;
        var hit:Bool = false;
        for (clause in switchBlock)
        {
            if (clause.Test == null)
            {
                defaultCase = clause;
            }
            else
            {
                var clauseSelector:jint.native.JsValue = _engine.GetValue(_engine.EvaluateExpression(clause.Test));
                if (jint.runtime.ExpressionInterpreter.StrictlyEqual(clauseSelector, input))
                {
                    hit = true;
                }
            }
            if (hit && clause.Consequent != null)
            {
                var r:jint.runtime.Completion = ExecuteStatementList(clause.Consequent);
                if (r.Type != jint.runtime.Completion.Normal)
                {
                    return r;
                }
                v = r.Value != null ? r.Value : jint.native.Undefined.Instance;
            }
        }
        if (hit == false && defaultCase != null)
        {
            var r:jint.runtime.Completion = ExecuteStatementList(defaultCase.Consequent);
            if (r.Type != jint.runtime.Completion.Normal)
            {
                return r;
            }
            v = r.Value != null ? r.Value : jint.native.Undefined.Instance;
        }
        return new jint.runtime.Completion(jint.runtime.Completion.Normal, v, null);
    }
    public function ExecuteStatementList(statementList:Array<jint.parser.ast.Statement>):jint.runtime.Completion
    {
        var c:jint.runtime.Completion = new jint.runtime.Completion(jint.runtime.Completion.Normal, null, null);
        var sl:jint.runtime.Completion = c;
        var s:jint.parser.ast.Statement = null;
        try
        {
            for (statement in statementList)
            {
                s = statement;
                c = ExecuteStatement(statement);
                if (c.Type != jint.runtime.Completion.Normal)
                {
                    var completion:jint.runtime.Completion = new jint.runtime.Completion(c.Type, c.Value != null ? c.Value : sl.Value, c.Identifier);
                    completion.Location = c.Location;
                }
                sl = c;
            }
        }
        catch (v:jint.runtime.JavaScriptException)
        {
            c = new jint.runtime.Completion(jint.runtime.Completion.Throw, v.Error, null);
            c.Location = s.Location;
            return c;
        }
        return new jint.runtime.Completion(c.Type, c.GetValueOrDefault(), c.Identifier);
    }
    public function ExecuteThrowStatement(throwStatement:jint.parser.ast.ThrowStatement):jint.runtime.Completion
    {
        var exprRef:Dynamic = _engine.EvaluateExpression(throwStatement.Argument);
        var c:jint.runtime.Completion = new jint.runtime.Completion(jint.runtime.Completion.Throw, _engine.GetValue(exprRef), null);
        c.Location = throwStatement.Location;
        return c;
    }
    public function ExecuteTryStatement(tryStatement:jint.parser.ast.TryStatement):jint.runtime.Completion
    {
        var b:jint.runtime.Completion = ExecuteStatement(tryStatement.Block);
        if (b.Type == jint.runtime.Completion.Throw)
        {
            if (system.linq.Enumerable.Any(tryStatement.Handlers))
            {
                for (catchClause in tryStatement.Handlers)
                {
                    var c:jint.native.JsValue = _engine.GetValue(b);
                    var oldEnv:jint.runtime.environments.LexicalEnvironment = _engine.ExecutionContext.LexicalEnvironment;
                    var catchEnv:jint.runtime.environments.LexicalEnvironment = jint.runtime.environments.LexicalEnvironment.NewDeclarativeEnvironment(_engine, oldEnv);
                    catchEnv.Record.CreateMutableBinding(catchClause.Param.Name);
                    catchEnv.Record.SetMutableBinding(catchClause.Param.Name, c, false);
                    _engine.ExecutionContext.LexicalEnvironment = catchEnv;
                    b = ExecuteStatement(catchClause.Body);
                    _engine.ExecutionContext.LexicalEnvironment = oldEnv;
                }
            }
        }
        if (tryStatement.Finalizer != null)
        {
            var f:jint.runtime.Completion = ExecuteStatement(tryStatement.Finalizer);
            if (f.Type == jint.runtime.Completion.Normal)
            {
                return b;
            }
            return f;
        }
        return b;
    }
    public function ExecuteProgram(program:jint.parser.ast.Program):jint.runtime.Completion
    {
        return ExecuteStatementList(program.Body);
    }
    public function ExecuteVariableDeclaration(statement:jint.parser.ast.VariableDeclaration):jint.runtime.Completion
    {
        for (declaration in statement.Declarations)
        {
            if (declaration.Init != null)
            {
                var lhs:jint.runtime.references.Reference = _engine.EvaluateExpression(declaration.Id);
                if (lhs == null)
                {
                    return throw new system.ArgumentException();
                }
                if (lhs.IsStrict() && lhs.GetBase().TryCast() != null && (lhs.GetReferencedName() == "eval" || lhs.GetReferencedName() == "arguments"))
                {
                    return throw new jint.runtime.JavaScriptException().Creator(_engine.SyntaxError);
                }
                lhs.GetReferencedName();
                var value:jint.native.JsValue = _engine.GetValue(_engine.EvaluateExpression(declaration.Init));
                _engine.PutValue(lhs, value);
            }
        }
        return new jint.runtime.Completion(jint.runtime.Completion.Normal, jint.native.Undefined.Instance, null);
    }
    public function ExecuteBlockStatement(blockStatement:jint.parser.ast.BlockStatement):jint.runtime.Completion
    {
        return ExecuteStatementList(blockStatement.Body);
    }
    public function ExecuteDebuggerStatement(debuggerStatement:jint.parser.ast.DebuggerStatement):jint.runtime.Completion
    {
        if (_engine.Options.IsDebuggerStatementAllowed())
        {
          //todo
        }
        return new jint.runtime.Completion(jint.runtime.Completion.Normal, null, null);
    }
}
