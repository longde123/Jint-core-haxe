package jint.runtime;
using StringTools;
import system.*;
import anonymoustypes.*;

class ExpressionInterpreter
{
    private var _engine:jint.Engine;
    public function new(engine:jint.Engine)
    {
        _engine = engine;
    }
    private function EvaluateExpression(expression:jint.parser.ast.Expression):Dynamic
    {
        return _engine.EvaluateExpression(expression);
    }
    public function EvaluateConditionalExpression(conditionalExpression:jint.parser.ast.ConditionalExpression):jint.native.JsValue
    {
        var lref:Dynamic = _engine.EvaluateExpression(conditionalExpression.Test);
        if (jint.runtime.TypeConverter.ToBoolean(_engine.GetValue(lref)))
        {
            var trueRef:Dynamic = _engine.EvaluateExpression(conditionalExpression.Consequent);
            return _engine.GetValue(trueRef);
        }
        else
        {
            var falseRef:Dynamic = _engine.EvaluateExpression(conditionalExpression.Alternate);
            return _engine.GetValue(falseRef);
        }
    }
    public function EvaluateAssignmentExpression(assignmentExpression:jint.parser.ast.AssignmentExpression):jint.native.JsValue
    {
        var lref:jint.runtime.references.Reference = EvaluateExpression(assignmentExpression.Left);
        var rval:jint.native.JsValue = _engine.GetValue(EvaluateExpression(assignmentExpression.Right));
        if (lref == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(_engine.ReferenceError);
        }
        if (assignmentExpression.Operator == jint.parser.ast.AssignmentOperator.Assign)
        {
            if (lref.IsStrict() && lref.GetBase().TryCast() != null && (lref.GetReferencedName() == "eval" || lref.GetReferencedName() == "arguments"))
            {
                return throw new jint.runtime.JavaScriptException().Creator(_engine.SyntaxError);
            }
            _engine.PutValue(lref, rval);
            return rval;
        }
        var lval:jint.native.JsValue = _engine.GetValue(lref);
        switch (assignmentExpression.Operator)
        {
            case jint.parser.ast.AssignmentOperator.PlusAssign:
                var lprim:jint.native.JsValue = jint.runtime.TypeConverter.ToPrimitive(lval);
                var rprim:jint.native.JsValue = jint.runtime.TypeConverter.ToPrimitive(rval);
                if (lprim.IsString() || rprim.IsString())
                {
                    lval = jint.runtime.TypeConverter.toString(lprim) + jint.runtime.TypeConverter.toString(rprim);
                }
                else
                {
                    lval = jint.runtime.TypeConverter.ToNumber(lprim) + jint.runtime.TypeConverter.ToNumber(rprim);
                }
            case jint.parser.ast.AssignmentOperator.MinusAssign:
                lval = jint.runtime.TypeConverter.ToNumber(lval) - jint.runtime.TypeConverter.ToNumber(rval);
            case jint.parser.ast.AssignmentOperator.TimesAssign:
                if (lval.Equals(jint.native.Undefined.Instance) || rval.Equals(jint.native.Undefined.Instance))
                {
                    lval = jint.native.Undefined.Instance;
                }
                else
                {
                    lval = jint.runtime.TypeConverter.ToNumber(lval) * jint.runtime.TypeConverter.ToNumber(rval);
                }
            case jint.parser.ast.AssignmentOperator.DivideAssign:
                lval = Divide(lval, rval);
            case jint.parser.ast.AssignmentOperator.ModuloAssign:
                if (lval.Equals(jint.native.Undefined.Instance) || rval.Equals(jint.native.Undefined.Instance))
                {
                    lval = jint.native.Undefined.Instance;
                }
                else
                {
                    lval = jint.runtime.TypeConverter.ToNumber(lval) % jint.runtime.TypeConverter.ToNumber(rval);
                }
            case jint.parser.ast.AssignmentOperator.BitwiseAndAssign:
                lval = jint.runtime.TypeConverter.ToInt32(lval) & jint.runtime.TypeConverter.ToInt32(rval);
            case jint.parser.ast.AssignmentOperator.BitwiseOrAssign:
                lval = jint.runtime.TypeConverter.ToInt32(lval) | jint.runtime.TypeConverter.ToInt32(rval);
            case jint.parser.ast.AssignmentOperator.BitwiseXOrAssign:
                lval = jint.runtime.TypeConverter.ToInt32(lval) ^ jint.runtime.TypeConverter.ToInt32(rval);
            case jint.parser.ast.AssignmentOperator.LeftShiftAssign:
                lval = jint.runtime.TypeConverter.ToInt32(lval) << (jint.runtime.TypeConverter.ToUint32(rval) & 0x1F);
            case jint.parser.ast.AssignmentOperator.RightShiftAssign:
                lval = jint.runtime.TypeConverter.ToInt32(lval) >> (jint.runtime.TypeConverter.ToUint32(rval) & 0x1F);
            case jint.parser.ast.AssignmentOperator.UnsignedRightShiftAssign:
                lval = jint.runtime.TypeConverter.ToInt32(lval) >> (jint.runtime.TypeConverter.ToUint32(rval) & 0x1F);
            default:
                return throw new system.NotImplementedException();
        }
        _engine.PutValue(lref, lval);
        return lval;
    }
    private function Divide(lval:jint.native.JsValue, rval:jint.native.JsValue):jint.native.JsValue
    {
        if (lval.Equals(jint.native.Undefined.Instance) || rval.Equals(jint.native.Undefined.Instance))
        {
            return jint.native.Undefined.Instance;
        }
        else
        {
            var lN:Float = jint.runtime.TypeConverter.ToNumber(lval);
            var rN:Float = jint.runtime.TypeConverter.ToNumber(rval);
            if (Cs2Hx.IsNaN(rN) || Cs2Hx.IsNaN(lN))
            {
                return Math.NaN;
            }
            if (Cs2Hx.IsInfinity(lN) && Cs2Hx.IsInfinity(rN))
            {
                return Math.NaN;
            }
            if (Cs2Hx.IsInfinity(lN) && rN.Equals_Double(0))
            {
                if (jint.native.number.NumberInstance.IsNegativeZero(rN))
                {
                    return -lN;
                }
                return lN;
            }
            if (lN.Equals_Double(0) && rN.Equals_Double(0))
            {
                return Math.NaN;
            }
            if (rN.Equals_Double(0))
            {
                if (jint.native.number.NumberInstance.IsNegativeZero(rN))
                {
                    return lN > 0 ? -正无穷大 : -负无穷大;
                }
                return lN > 0 ? 正无穷大 : 负无穷大;
            }
            return lN / rN;
        }
    }
    public function EvaluateBinaryExpression(expression:jint.parser.ast.BinaryExpression):jint.native.JsValue
    {
        var left:jint.native.JsValue = _engine.GetValue(EvaluateExpression(expression.Left));
        var right:jint.native.JsValue = _engine.GetValue(EvaluateExpression(expression.Right));
        var value:jint.native.JsValue;
        switch (expression.Operator)
        {
            case jint.parser.ast.BinaryOperator.Plus:
                var lprim:jint.native.JsValue = jint.runtime.TypeConverter.ToPrimitive(left);
                var rprim:jint.native.JsValue = jint.runtime.TypeConverter.ToPrimitive(right);
                if (lprim.IsString() || rprim.IsString())
                {
                    value = jint.runtime.TypeConverter.toString(lprim) + jint.runtime.TypeConverter.toString(rprim);
                }
                else
                {
                    value = jint.runtime.TypeConverter.ToNumber(lprim) + jint.runtime.TypeConverter.ToNumber(rprim);
                }
            case jint.parser.ast.BinaryOperator.Minus:
                value = jint.runtime.TypeConverter.ToNumber(left) - jint.runtime.TypeConverter.ToNumber(right);
            case jint.parser.ast.BinaryOperator.Times:
                if (left.Equals(jint.native.Undefined.Instance) || right.Equals(jint.native.Undefined.Instance))
                {
                    value = jint.native.Undefined.Instance;
                }
                else
                {
                    value = jint.runtime.TypeConverter.ToNumber(left) * jint.runtime.TypeConverter.ToNumber(right);
                }
            case jint.parser.ast.BinaryOperator.Divide:
                value = Divide(left, right);
            case jint.parser.ast.BinaryOperator.Modulo:
                if (left.Equals(jint.native.Undefined.Instance) || right.Equals(jint.native.Undefined.Instance))
                {
                    value = jint.native.Undefined.Instance;
                }
                else
                {
                    value = jint.runtime.TypeConverter.ToNumber(left) % jint.runtime.TypeConverter.ToNumber(right);
                }
            case jint.parser.ast.BinaryOperator.Equal:
                value = Equal(left, right);
            case jint.parser.ast.BinaryOperator.NotEqual:
                value = !Equal(left, right);
            case jint.parser.ast.BinaryOperator.Greater:
                value = Compare(right, left, false);
                if (value.Equals(jint.native.Undefined.Instance))
                {
                    value = false;
                }
            case jint.parser.ast.BinaryOperator.GreaterOrEqual:
                value = Compare(left, right);
                if (value.Equals(jint.native.Undefined.Instance) || value.AsBoolean())
                {
                    value = false;
                }
                else
                {
                    value = true;
                }
            case jint.parser.ast.BinaryOperator.Less:
                value = Compare(left, right);
                if (value.Equals(jint.native.Undefined.Instance))
                {
                    value = false;
                }
            case jint.parser.ast.BinaryOperator.LessOrEqual:
                value = Compare(right, left, false);
                if (value.Equals(jint.native.Undefined.Instance) || value.AsBoolean())
                {
                    value = false;
                }
                else
                {
                    value = true;
                }
            case jint.parser.ast.BinaryOperator.StrictlyEqual:
                return StrictlyEqual(left, right);
            case jint.parser.ast.BinaryOperator.StricltyNotEqual:
                return !StrictlyEqual(left, right);
            case jint.parser.ast.BinaryOperator.BitwiseAnd:
                return jint.runtime.TypeConverter.ToInt32(left) & jint.runtime.TypeConverter.ToInt32(right);
            case jint.parser.ast.BinaryOperator.BitwiseOr:
                return jint.runtime.TypeConverter.ToInt32(left) | jint.runtime.TypeConverter.ToInt32(right);
            case jint.parser.ast.BinaryOperator.BitwiseXOr:
                return jint.runtime.TypeConverter.ToInt32(left) ^ jint.runtime.TypeConverter.ToInt32(right);
            case jint.parser.ast.BinaryOperator.LeftShift:
                return jint.runtime.TypeConverter.ToInt32(left) << (jint.runtime.TypeConverter.ToUint32(right) & 0x1F);
            case jint.parser.ast.BinaryOperator.RightShift:
                return jint.runtime.TypeConverter.ToInt32(left) >> (jint.runtime.TypeConverter.ToUint32(right) & 0x1F);
            case jint.parser.ast.BinaryOperator.UnsignedRightShift:
                return jint.runtime.TypeConverter.ToInt32(left) >> (jint.runtime.TypeConverter.ToUint32(right) & 0x1F);
            case jint.parser.ast.BinaryOperator.InstanceOf:
                var f:jint.native.functions.FunctionInstance = right.TryCast();
                if (f == null)
                {
                    return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(_engine.TypeError, "instanceof can only be used with a function object");
                }
                value = f.HasInstance(left);
            case jint.parser.ast.BinaryOperator.In:
                if (!right.IsObject())
                {
                    return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(_engine.TypeError, "in can only be used with an object");
                }
                value = right.AsObject().HasProperty(jint.runtime.TypeConverter.toString(left));
            default:
                return throw new system.NotImplementedException();
        }
        return value;
    }
    public function EvaluateLogicalExpression(logicalExpression:jint.parser.ast.LogicalExpression):jint.native.JsValue
    {
        var left:jint.native.JsValue = _engine.GetValue(EvaluateExpression(logicalExpression.Left));
        switch (logicalExpression.Operator)
        {
            case jint.parser.ast.LogicalOperator.LogicalAnd:
                if (!jint.runtime.TypeConverter.ToBoolean(left))
                {
                    return left;
                }
                return _engine.GetValue(EvaluateExpression(logicalExpression.Right));
            case jint.parser.ast.LogicalOperator.LogicalOr:
                if (jint.runtime.TypeConverter.ToBoolean(left))
                {
                    return left;
                }
                return _engine.GetValue(EvaluateExpression(logicalExpression.Right));
            default:
                return throw new system.NotImplementedException();
        }
    }
    public static function Equal(x:jint.native.JsValue, y:jint.native.JsValue):Bool
    {
        var typex:Int = x.Type;
        var typey:Int = y.Type;
        if (typex == typey)
        {
            if (typex == jint.runtime.Types.Undefined || typex == jint.runtime.Types.Null)
            {
                return true;
            }
            if (typex == jint.runtime.Types.Number)
            {
                var nx:Float = jint.runtime.TypeConverter.ToNumber(x);
                var ny:Float = jint.runtime.TypeConverter.ToNumber(y);
                if (Cs2Hx.IsNaN(nx) || Cs2Hx.IsNaN(ny))
                {
                    return false;
                }
                if (nx.Equals_Double(ny))
                {
                    return true;
                }
                return false;
            }
            if (typex == jint.runtime.Types.String)
            {
                return jint.runtime.TypeConverter.toString(x) == jint.runtime.TypeConverter.toString(y);
            }
            if (typex == jint.runtime.Types.Boolean)
            {
                return x.AsBoolean() == y.AsBoolean();
            }
            return x.Equals(y);
        }
        if (x.Equals(jint.native.Null.Instance) && y.Equals(jint.native.Undefined.Instance))
        {
            return true;
        }
        if (x.Equals(jint.native.Undefined.Instance) && y.Equals(jint.native.Null.Instance))
        {
            return true;
        }
        if (typex == jint.runtime.Types.Number && typey == jint.runtime.Types.String)
        {
            return Equal(x, jint.runtime.TypeConverter.ToNumber(y));
        }
        if (typex == jint.runtime.Types.String && typey == jint.runtime.Types.Number)
        {
            return Equal(jint.runtime.TypeConverter.ToNumber(x), y);
        }
        if (typex == jint.runtime.Types.Boolean)
        {
            return Equal(jint.runtime.TypeConverter.ToNumber(x), y);
        }
        if (typey == jint.runtime.Types.Boolean)
        {
            return Equal(x, jint.runtime.TypeConverter.ToNumber(y));
        }
        if (typey == jint.runtime.Types.Object && (typex == jint.runtime.Types.String || typex == jint.runtime.Types.Number))
        {
            return Equal(x, jint.runtime.TypeConverter.ToPrimitive(y));
        }
        if (typex == jint.runtime.Types.Object && (typey == jint.runtime.Types.String || typey == jint.runtime.Types.Number))
        {
            return Equal(jint.runtime.TypeConverter.ToPrimitive(x), y);
        }
        return false;
    }
    public static function StrictlyEqual(x:jint.native.JsValue, y:jint.native.JsValue):Bool
    {
        var typea:Int = x.Type;
        var typeb:Int = y.Type;
        if (typea != typeb)
        {
            return false;
        }
        if (typea == jint.runtime.Types.Undefined || typea == jint.runtime.Types.Null)
        {
            return true;
        }
        if (typea == jint.runtime.Types.None)
        {
            return true;
        }
        if (typea == jint.runtime.Types.Number)
        {
            var nx:Float = jint.runtime.TypeConverter.ToNumber(x);
            var ny:Float = jint.runtime.TypeConverter.ToNumber(y);
            if (Cs2Hx.IsNaN(nx) || Cs2Hx.IsNaN(ny))
            {
                return false;
            }
            if (nx.Equals_Double(ny))
            {
                return true;
            }
            return false;
        }
        if (typea == jint.runtime.Types.String)
        {
            return jint.runtime.TypeConverter.toString(x) == jint.runtime.TypeConverter.toString(y);
        }
        if (typea == jint.runtime.Types.Boolean)
        {
            return jint.runtime.TypeConverter.ToBoolean(x) == jint.runtime.TypeConverter.ToBoolean(y);
        }
        return x.Equals(y);
    }
    public static function SameValue(x:jint.native.JsValue, y:jint.native.JsValue):Bool
    {
        var typea:Int = jint.runtime.TypeConverter.GetPrimitiveType(x);
        var typeb:Int = jint.runtime.TypeConverter.GetPrimitiveType(y);
        if (typea != typeb)
        {
            return false;
        }
        if (typea == jint.runtime.Types.None)
        {
            return true;
        }
        if (typea == jint.runtime.Types.Number)
        {
            var nx:Float = jint.runtime.TypeConverter.ToNumber(x);
            var ny:Float = jint.runtime.TypeConverter.ToNumber(y);
            if (Cs2Hx.IsNaN(nx) && Cs2Hx.IsNaN(ny))
            {
                return true;
            }
            if (nx.Equals_Double(ny))
            {
                if (nx.Equals_Double(0))
                {
                    return jint.native.number.NumberInstance.IsNegativeZero(nx) == jint.native.number.NumberInstance.IsNegativeZero(ny);
                }
                return true;
            }
            return false;
        }
        if (typea == jint.runtime.Types.String)
        {
            return jint.runtime.TypeConverter.toString(x) == jint.runtime.TypeConverter.toString(y);
        }
        if (typea == jint.runtime.Types.Boolean)
        {
            return jint.runtime.TypeConverter.ToBoolean(x) == jint.runtime.TypeConverter.ToBoolean(y);
        }
        return x.Equals(y);
    }
    public static function Compare(x:jint.native.JsValue, y:jint.native.JsValue, leftFirst:Bool = true):jint.native.JsValue
    {
        var px:jint.native.JsValue;
        var py:jint.native.JsValue;
        if (leftFirst)
        {
            px = jint.runtime.TypeConverter.ToPrimitive(x, jint.runtime.Types.Number);
            py = jint.runtime.TypeConverter.ToPrimitive(y, jint.runtime.Types.Number);
        }
        else
        {
            py = jint.runtime.TypeConverter.ToPrimitive(y, jint.runtime.Types.Number);
            px = jint.runtime.TypeConverter.ToPrimitive(x, jint.runtime.Types.Number);
        }
        var typea:Int = px.Type;
        var typeb:Int = py.Type;
        if (typea != jint.runtime.Types.String || typeb != jint.runtime.Types.String)
        {
            var nx:Float = jint.runtime.TypeConverter.ToNumber(px);
            var ny:Float = jint.runtime.TypeConverter.ToNumber(py);
            if (Cs2Hx.IsNaN(nx) || Cs2Hx.IsNaN(ny))
            {
                return jint.native.Undefined.Instance;
            }
            if (nx.Equals_Double(ny))
            {
                return false;
            }
            if (Cs2Hx.IsPositiveInfinity(nx))
            {
                return false;
            }
            if (Cs2Hx.IsPositiveInfinity(ny))
            {
                return true;
            }
            if (Cs2Hx.IsNegativeInfinity(ny))
            {
                return false;
            }
            if (Cs2Hx.IsNegativeInfinity(nx))
            {
                return true;
            }
            return nx < ny;
        }
        else
        {
            return system.String.CompareOrdinal(jint.runtime.TypeConverter.toString(x), jint.runtime.TypeConverter.toString(y)) < 0;
        }
    }
    public function EvaluateIdentifier(identifier:jint.parser.ast.Identifier):jint.runtime.references.Reference
    {
        var env:jint.runtime.environments.LexicalEnvironment = _engine.ExecutionContext.LexicalEnvironment;
        var strict:Bool = jint.StrictModeScope.IsStrictModeCode;
        return jint.runtime.environments.LexicalEnvironment.GetIdentifierReference(env, identifier.Name, strict);
    }
    public function EvaluateLiteral(literal:jint.parser.ast.Literal):jint.native.JsValue
    {
        if (literal.Type == jint.parser.ast.SyntaxNodes.RegularExpressionLiteral)
        {
            return _engine.JRegExp.Construct_String(literal.Raw);
        }
        return jint.native.JsValue.FromObject(_engine, literal.Value);
    }
    public function EvaluateObjectExpression(objectExpression:jint.parser.ast.ObjectExpression):jint.native.JsValue
    {
        var obj:jint.native.object.ObjectInstance = _engine.JObject.Construct(jint.runtime.Arguments.Empty);
        for (property in objectExpression.Properties)
        {
            var propName:String = property.Key.GetKey();
            var previous:jint.runtime.descriptors.PropertyDescriptor = obj.GetOwnProperty(propName);
            var propDesc:jint.runtime.descriptors.PropertyDescriptor;
            switch (property.Kind)
            {
                case jint.parser.ast.PropertyKind.Data:
                    var exprValue:Dynamic = _engine.EvaluateExpression(property.Value);
                    var propValue:jint.native.JsValue = _engine.GetValue(exprValue);
                    propDesc = new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(propValue, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true));
                case jint.parser.ast.PropertyKind.Get:
                    var getter:jint.parser.ast.FunctionExpression = cast(property.Value, jint.parser.ast.FunctionExpression);
                    if (getter == null)
                    {
                        return throw new jint.runtime.JavaScriptException().Creator(_engine.SyntaxError);
                    }
                    var get:jint.native.functions.ScriptFunctionInstance = null;
                    var strictModeScope:jint.StrictModeScope = (new jint.StrictModeScope(getter.Strict));
                    get = new jint.native.functions.ScriptFunctionInstance(_engine, getter, _engine.ExecutionContext.LexicalEnvironment, jint.StrictModeScope.IsStrictModeCode);
                    propDesc = new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(get, new Nullable_Bool(), new Nullable_Bool(true), new Nullable_Bool(true));
                case jint.parser.ast.PropertyKind.Set:
                    var setter:jint.parser.ast.FunctionExpression = cast(property.Value, jint.parser.ast.FunctionExpression);
                    if (setter == null)
                    {
                        return throw new jint.runtime.JavaScriptException().Creator(_engine.SyntaxError);
                    }
                    var set:jint.native.functions.ScriptFunctionInstance;
                    var strictModeScope_:jint.StrictModeScope = (new jint.StrictModeScope(setter.Strict));
                    set = new jint.native.functions.ScriptFunctionInstance(_engine, setter, _engine.ExecutionContext.LexicalEnvironment, jint.StrictModeScope.IsStrictModeCode);
                    propDesc = new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_JsValue_NullableBoolean_NullableBoolean(null, set, new Nullable_Bool(true), new Nullable_Bool(true));
                default:
                    return throw new system.ArgumentOutOfRangeException();
            }
            if (previous != jint.runtime.descriptors.PropertyDescriptor.Undefined)
            {
                if (jint.StrictModeScope.IsStrictModeCode && previous.IsDataDescriptor() && propDesc.IsDataDescriptor())
                {
                    return throw new jint.runtime.JavaScriptException().Creator(_engine.SyntaxError);
                }
                if (previous.IsDataDescriptor() && propDesc.IsAccessorDescriptor())
                {
                    return throw new jint.runtime.JavaScriptException().Creator(_engine.SyntaxError);
                }
                if (previous.IsAccessorDescriptor() && propDesc.IsDataDescriptor())
                {
                    return throw new jint.runtime.JavaScriptException().Creator(_engine.SyntaxError);
                }
                if (previous.IsAccessorDescriptor() && propDesc.IsAccessorDescriptor())
                {
                    if (propDesc.Set != null && previous.Set != null)
                    {
                        return throw new jint.runtime.JavaScriptException().Creator(_engine.SyntaxError);
                    }
                    if (propDesc.Get != null && previous.Get != null)
                    {
                        return throw new jint.runtime.JavaScriptException().Creator(_engine.SyntaxError);
                    }
                }
            }
            obj.DefineOwnProperty(propName, propDesc, false);
        }
        return obj;
    }
    public function EvaluateMemberExpression(memberExpression:jint.parser.ast.MemberExpression):jint.runtime.references.Reference
    {
        var baseReference:Dynamic = EvaluateExpression(memberExpression.Object);
        var baseValue:jint.native.JsValue = _engine.GetValue(baseReference);
        var expression:jint.parser.ast.Expression = memberExpression.Property;
        if (!memberExpression.Computed)
        {
            var literal:jint.parser.ast.Literal = new jint.parser.ast.Literal();
            literal.Type = jint.parser.ast.SyntaxNodes.Literal;
            literal.Value = memberExpression.Property.As().Name;
            expression = literal;
        }
        var propertyNameReference:Dynamic = EvaluateExpression(expression);
        var propertyNameValue:jint.native.JsValue = _engine.GetValue(propertyNameReference);
        jint.runtime.TypeConverter.CheckObjectCoercible(_engine, baseValue);
        var propertyNameString:String = jint.runtime.TypeConverter.toString(propertyNameValue);
        return new jint.runtime.references.Reference(baseValue, propertyNameString, jint.StrictModeScope.IsStrictModeCode);
    }
    public function EvaluateFunctionExpression(functionExpression:jint.parser.ast.FunctionExpression):jint.native.JsValue
    {
        var funcEnv:jint.runtime.environments.LexicalEnvironment = jint.runtime.environments.LexicalEnvironment.NewDeclarativeEnvironment(_engine, _engine.ExecutionContext.LexicalEnvironment);
        var envRec:jint.runtime.environments.DeclarativeEnvironmentRecord = cast(funcEnv.Record, jint.runtime.environments.DeclarativeEnvironmentRecord);
        if (functionExpression.Id != null && !system.Cs2Hx.IsNullOrEmpty(functionExpression.Id.Name))
        {
            envRec.CreateMutableBinding(functionExpression.Id.Name);
        }
        var closure:jint.native.functions.ScriptFunctionInstance = new jint.native.functions.ScriptFunctionInstance(_engine, functionExpression, funcEnv, functionExpression.Strict);
        if (functionExpression.Id != null && !system.Cs2Hx.IsNullOrEmpty(functionExpression.Id.Name))
        {
            envRec.InitializeImmutableBinding(functionExpression.Id.Name, closure);
        }
        return closure;
    }
    public function EvaluateCallExpression(callExpression:jint.parser.ast.CallExpression):jint.native.JsValue
    {
        var callee:Dynamic = EvaluateExpression(callExpression.Callee);
        if (_engine.Options.IsDebugMode())
        {
            _engine.DebugHandler.AddToDebugCallStack(callExpression);
        }
        var thisObject:jint.native.JsValue;
        var arguments:Array<jint.native.JsValue> = null;
        var func:jint.native.JsValue = _engine.GetValue(callee);
        var r:jint.runtime.references.Reference = callee;
        var isRecursionHandled:Bool = _engine.Options.GetMaxRecursionDepth() >= 0;
        if (isRecursionHandled)
        {
            var stackItem:jint.runtime.CallStackElement = new jint.runtime.CallStackElement(callExpression, func, r != null ? r.GetReferencedName() : "anonymous function");
            var recursionDepth:Int = _engine.CallStack.Push(stackItem);
            if (recursionDepth > _engine.Options.GetMaxRecursionDepth())
            {
                _engine.CallStack.Pop();
                return throw new jint.runtime.RecursionDepthOverflowException(_engine.CallStack, stackItem.toString());
            }
        }
        if (func.Equals(jint.native.Undefined.Instance))
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(_engine.TypeError, r == null ? "" : Cs2Hx.Format("Object has no method '{0}'", (callee).GetReferencedName()));
        }
        if (!func.IsObject())
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(_engine.TypeError, r == null ? "" : Cs2Hx.Format("Property '{0}' of object is not a function", (callee).GetReferencedName()));
        }
        var callable:jint.native.ICallable = func.TryCast();
        if (callable == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(_engine.TypeError);
        }
        if (r != null)
        {
            if (r.IsPropertyReference())
            {
                thisObject = r.GetBase();
            }
            else
            {
                var env:jint.runtime.environments.EnvironmentRecord = r.GetBase().TryCast();
                thisObject = env.ImplicitThisValue();
            }
        }
        else
        {
            thisObject = jint.native.Undefined.Instance;
        }
        if (r != null && r.GetReferencedName() == "eval" && Std.is(callable, jint.native.functions.EvalFunctionInstance))
        {
            return (cast(callable, jint.native.functions.EvalFunctionInstance)).Call_JsValue__Boolean(thisObject, arguments, true);
        }
        var result:jint.native.JsValue = callable.Call(thisObject, arguments);
        if (_engine.Options.IsDebugMode())
        {
            _engine.DebugHandler.PopDebugCallStack();
        }
        if (isRecursionHandled)
        {
            _engine.CallStack.Pop();
        }
        return result;
    }
    public function EvaluateSequenceExpression(sequenceExpression:jint.parser.ast.SequenceExpression):jint.native.JsValue
    {
        var result:jint.native.JsValue = jint.native.Undefined.Instance;
        for (expression in sequenceExpression.Expressions)
        {
            result = _engine.GetValue(_engine.EvaluateExpression(expression));
        }
        return result;
    }
    public function EvaluateUpdateExpression(updateExpression:jint.parser.ast.UpdateExpression):jint.native.JsValue
    {
        var value:Dynamic = _engine.EvaluateExpression(updateExpression.Argument);
        var r:jint.runtime.references.Reference;
        switch (updateExpression.Operator)
        {
            case jint.parser.ast.UnaryOperator.Increment:
                r = value;
                if (r != null && r.IsStrict() && (r.GetBase().TryCast() != null) && (system.Array.IndexOf__T([ "eval", "arguments" ], r.GetReferencedName()) != -1))
                {
                    return throw new jint.runtime.JavaScriptException().Creator(_engine.SyntaxError);
                }
                var oldValue:Float = jint.runtime.TypeConverter.ToNumber(_engine.GetValue(value));
                var newValue:Float = oldValue + 1;
                _engine.PutValue(r, newValue);
                return updateExpression.Prefix ? newValue : oldValue;
            case jint.parser.ast.UnaryOperator.Decrement:
                r = value;
                if (r != null && r.IsStrict() && (r.GetBase().TryCast() != null) && (system.Array.IndexOf__T([ "eval", "arguments" ], r.GetReferencedName()) != -1))
                {
                    return throw new jint.runtime.JavaScriptException().Creator(_engine.SyntaxError);
                }
                oldValue = jint.runtime.TypeConverter.ToNumber(_engine.GetValue(value));
                newValue = oldValue - 1;
                _engine.PutValue(r, newValue);
                return updateExpression.Prefix ? newValue : oldValue;
            default:
                return throw new system.ArgumentException();
        }
    }
    public function EvaluateThisExpression(thisExpression:jint.parser.ast.ThisExpression):jint.native.JsValue
    {
        return _engine.ExecutionContext.ThisBinding;
    }
    public function EvaluateNewExpression(newExpression:jint.parser.ast.NewExpression):jint.native.JsValue
    {
        var arguments:Array<jint.native.JsValue> = null;
        var callee:jint.native.IConstructor = _engine.GetValue(EvaluateExpression(newExpression.Callee)).TryCast();
        if (callee == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(_engine.TypeError, "The object can't be used as constructor.");
        }
        var instance:jint.native.object.ObjectInstance = callee.Construct(arguments);
        return instance;
    }
    public function EvaluateArrayExpression(arrayExpression:jint.parser.ast.ArrayExpression):jint.native.JsValue
    {
        var a:jint.native.object.ObjectInstance = _engine.JArray.Construct([ system.linq.Enumerable.Count(arrayExpression.Elements) ]);
        var n:Int = 0;
        for (expr in arrayExpression.Elements)
        {
            if (expr != null)
            {
                var value:jint.native.JsValue = _engine.GetValue(EvaluateExpression(expr));
                a.DefineOwnProperty(Std.string(n), new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(value, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
            }
            n++;
        }
        return a;
    }
    public function EvaluateUnaryExpression(unaryExpression:jint.parser.ast.UnaryExpression):jint.native.JsValue
    {
        var value:Dynamic = _engine.EvaluateExpression(unaryExpression.Argument);
        var r:jint.runtime.references.Reference;
        switch (unaryExpression.Operator)
        {
            case jint.parser.ast.UnaryOperator.Plus:
                return jint.runtime.TypeConverter.ToNumber(_engine.GetValue(value));
            case jint.parser.ast.UnaryOperator.Minus:
                var n:Float = jint.runtime.TypeConverter.ToNumber(_engine.GetValue(value));
                return Cs2Hx.IsNaN(n) ? Math.NaN : n * -1;
            case jint.parser.ast.UnaryOperator.BitwiseNot:
                return ~jint.runtime.TypeConverter.ToInt32(_engine.GetValue(value));
            case jint.parser.ast.UnaryOperator.LogicalNot:
                return !jint.runtime.TypeConverter.ToBoolean(_engine.GetValue(value));
            case jint.parser.ast.UnaryOperator.Delete:
                r = value;
                if (r == null)
                {
                    return true;
                }
                if (r.IsUnresolvableReference())
                {
                    if (r.IsStrict())
                    {
                        return throw new jint.runtime.JavaScriptException().Creator(_engine.SyntaxError);
                    }
                    return true;
                }
                if (r.IsPropertyReference())
                {
                    var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(_engine, r.GetBase());
                    return o.Delete(r.GetReferencedName(), r.IsStrict());
                }
                if (r.IsStrict())
                {
                    return throw new jint.runtime.JavaScriptException().Creator(_engine.SyntaxError);
                }
                var bindings:jint.runtime.environments.EnvironmentRecord = r.GetBase().TryCast();
                return bindings.DeleteBinding(r.GetReferencedName());
            case jint.parser.ast.UnaryOperator.Void:
                _engine.GetValue(value);
                return jint.native.Undefined.Instance;
            case jint.parser.ast.UnaryOperator.TypeOf:
                r = value;
                if (r != null)
                {
                    if (r.IsUnresolvableReference())
                    {
                        return "undefined";
                    }
                }
                var v:jint.native.JsValue = _engine.GetValue(value);
                if (v.Equals(jint.native.Undefined.Instance))
                {
                    return "undefined";
                }
                if (v.Equals(jint.native.Null.Instance))
                {
                    return "object";
                }
                switch (v.Type)
                {
                    case jint.runtime.Types.Boolean:
                        return "boolean";
                    case jint.runtime.Types.Number:
                        return "number";
                    case jint.runtime.Types.String:
                        return "string";
                }
                if (v.TryCast() != null)
                {
                    return "function";
                }
                return "object";
            default:
                return throw new system.ArgumentException();
        }
    }
}
