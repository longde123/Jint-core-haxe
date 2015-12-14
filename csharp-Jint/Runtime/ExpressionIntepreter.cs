﻿using System;
using System.Linq;
using Jint.Native;
using Jint.Native.Function;
using Jint.Native.Number;
using Jint.Parser.Ast;
using Jint.Runtime.Descriptors;
using Jint.Runtime.Environments;
using Jint.Runtime.References;

namespace Jint.Runtime
{
    public class ExpressionInterpreter
    {
        private readonly Engine _engine;

        public ExpressionInterpreter(Engine engine)
        {
            _engine = engine;
        }

        private object EvaluateExpression(Expression expression)
        {
            return _engine.EvaluateExpression(expression);
        }

        public JsValue EvaluateConditionalExpression(ConditionalExpression conditionalExpression)
        {
            var lref = _engine.EvaluateExpression(conditionalExpression.Test);
            if (TypeConverter.ToBoolean(_engine.GetValue(lref)))
            {
                var trueRef = _engine.EvaluateExpression(conditionalExpression.Consequent);
                return _engine.GetValue(trueRef);
            }
            else
            {
                var falseRef = _engine.EvaluateExpression(conditionalExpression.Alternate);
                return _engine.GetValue(falseRef);
            }
        }

        public JsValue EvaluateAssignmentExpression(AssignmentExpression assignmentExpression)
        {
            var lref = (Reference)EvaluateExpression(assignmentExpression.Left);
            JsValue rval = _engine.GetValue(EvaluateExpression(assignmentExpression.Right));

            if (lref == null)
            {
                throw new JavaScriptException().Creator(_engine.ReferenceError);
            }

            if (assignmentExpression.Operator == AssignmentOperator.Assign) // "="
            {
 
                if(lref.IsStrict() && lref.GetBase().TryCast<EnvironmentRecord>() != null && (lref.GetReferencedName() == "eval" || lref.GetReferencedName() == "arguments"))
                {
                    throw new JavaScriptException().Creator(_engine.SyntaxError);
                }

                _engine.PutValue(lref, rval);
                return rval;
            }

            JsValue lval = _engine.GetValue(lref);

            switch (assignmentExpression.Operator)
            {
                case AssignmentOperator.PlusAssign:
                    var lprim = TypeConverter.ToPrimitive(lval);
                    var rprim = TypeConverter.ToPrimitive(rval);
                    if (lprim.IsString() || rprim.IsString())
                    {
                        lval = TypeConverter.ToString(lprim) + TypeConverter.ToString(rprim);
                    }
                    else
                    {
                        lval = TypeConverter.ToNumber(lprim) + TypeConverter.ToNumber(rprim);
                    }
                    break;

                case AssignmentOperator.MinusAssign:
                    lval = TypeConverter.ToNumber(lval) - TypeConverter.ToNumber(rval);
                    break;

                case AssignmentOperator.TimesAssign:
                    if (lval.Equals( Undefined.Instance) || rval.Equals(Undefined.Instance))
                    {
                        lval = Undefined.Instance;
                    }
                    else
                    {
                        lval = TypeConverter.ToNumber(lval) * TypeConverter.ToNumber(rval);
                    }
                    break;

                case AssignmentOperator.DivideAssign:
                    lval = Divide(lval, rval);
                    break;

                case AssignmentOperator.ModuloAssign:
                    if (lval.Equals(Undefined.Instance) || rval.Equals(Undefined.Instance))
                    {
                        lval = Undefined.Instance;
                    }
                    else
                    {
                        lval = TypeConverter.ToNumber(lval) % TypeConverter.ToNumber(rval);
                    }
                    break;

                case AssignmentOperator.BitwiseAndAssign:
                    lval = TypeConverter.ToInt32(lval) & TypeConverter.ToInt32(rval);
                    break;

                case AssignmentOperator.BitwiseOrAssign:
                    lval = TypeConverter.ToInt32(lval) | TypeConverter.ToInt32(rval);
                    break;

                case AssignmentOperator.BitwiseXOrAssign:
                    lval = TypeConverter.ToInt32(lval) ^ TypeConverter.ToInt32(rval);
                    break;

                case AssignmentOperator.LeftShiftAssign:
                    lval = TypeConverter.ToInt32(lval) << (int)(TypeConverter.ToUint32(rval) & 0x1F);
                    break;

                case AssignmentOperator.RightShiftAssign:
                    lval = TypeConverter.ToInt32(lval) >> (int)(TypeConverter.ToUint32(rval) & 0x1F);
                    break;

                case AssignmentOperator.UnsignedRightShiftAssign:
                    lval = (uint)TypeConverter.ToInt32(lval) >> (int)(TypeConverter.ToUint32(rval) & 0x1F);
                    break;
                
                default:
                    throw new NotImplementedException();

            }

            _engine.PutValue(lref, lval);

            return lval;
        }

        private JsValue Divide(JsValue lval, JsValue rval)
        {
            if (lval.Equals( Undefined.Instance) || rval.Equals( Undefined.Instance))
            {
                return Undefined.Instance;
            }
            else
            {
                var lN = TypeConverter.ToNumber(lval);
                var rN = TypeConverter.ToNumber(rval);

                if (double.IsNaN(rN) || double.IsNaN(lN))
                {
                    return double.NaN;
                }

                if (double.IsInfinity(lN) && double.IsInfinity(rN))
                {
                    return double.NaN;
                }

                if (double.IsInfinity(lN) && rN.Equals(0))
                {
                    if (NumberInstance.IsNegativeZero(rN))
                    {
                        return -lN;
                    }

                    return lN;
                }

                if (lN.Equals(0) && rN.Equals(0))
                {
                    return double.NaN;
                }

                if (rN.Equals(0))
                {
                    if (NumberInstance.IsNegativeZero(rN))
                    {
                        return lN > 0 ? -double.PositiveInfinity : -double.NegativeInfinity;
                    }

                    return lN > 0 ? double.PositiveInfinity : double.NegativeInfinity;
                }

                return lN/rN;
            }
        }

        public JsValue EvaluateBinaryExpression(BinaryExpression expression)
        {
            JsValue left = _engine.GetValue(EvaluateExpression(expression.Left));
            JsValue right = _engine.GetValue(EvaluateExpression(expression.Right));
            JsValue value;

              
            switch (expression.Operator)
            {
                case BinaryOperator.Plus:
                    var lprim = TypeConverter.ToPrimitive(left);
                    var rprim = TypeConverter.ToPrimitive(right);
                    if (lprim.IsString() || rprim.IsString())
                    {
                        value = TypeConverter.ToString(lprim) + TypeConverter.ToString(rprim);
                    }
                    else
                    {
                        value = TypeConverter.ToNumber(lprim) + TypeConverter.ToNumber(rprim);
                    }
                    break;
                
                case BinaryOperator.Minus:
                    value = TypeConverter.ToNumber(left) - TypeConverter.ToNumber(right);
                    break;
                
                case BinaryOperator.Times:
                    if (left.Equals(Undefined.Instance) || right.Equals(Undefined.Instance))
                    {
                        value = Undefined.Instance;
                    }
                    else
                    {
                        value = TypeConverter.ToNumber(left) * TypeConverter.ToNumber(right);
                    }
                    break;
                
                case BinaryOperator.Divide:
                    value = Divide(left, right);
                    break;

                case BinaryOperator.Modulo:
                    if (left.Equals( Undefined.Instance) || right.Equals(Undefined.Instance))
                    {
                        value = Undefined.Instance;
                    }
                    else
                    {
                        value = TypeConverter.ToNumber(left) % TypeConverter.ToNumber(right);
                    }
                    break;

                case BinaryOperator.Equal:
                    value = Equal(left, right);
                    break;
                
                case BinaryOperator.NotEqual:
                    value = !Equal(left, right);
                    break;
                
                case BinaryOperator.Greater:
                    value = Compare(right, left, false);
                    if (value.Equals(Undefined.Instance))
                    {
                        value = false;
                    }
                    break;

                case BinaryOperator.GreaterOrEqual:
                    value = Compare(left, right);
                    if (value.Equals( Undefined.Instance) || value.AsBoolean())
                    {
                        value = false;
                    }
                    else
                    {
                        value = true;
                    }
                    break;
                
                case BinaryOperator.Less:
                    value = Compare(left, right);
                    if (value.Equals( Undefined.Instance))
                    {
                        value = false;
                    }
                    break;
                
                case BinaryOperator.LessOrEqual:
                    value = Compare(right, left, false);
                    if (value.Equals( Undefined.Instance) || value.AsBoolean())
                    {
                        value = false;
                    }
                    else
                    {
                        value = true;
                    }
                    break;
                
                case BinaryOperator.StrictlyEqual:
                    return StrictlyEqual(left, right);
                
                case BinaryOperator.StricltyNotEqual:
                    return !StrictlyEqual(left, right);

                case BinaryOperator.BitwiseAnd:
                    return TypeConverter.ToInt32(left) & TypeConverter.ToInt32(right);

                case BinaryOperator.BitwiseOr:
                    return TypeConverter.ToInt32(left) | TypeConverter.ToInt32(right);

                case BinaryOperator.BitwiseXOr:
                    return TypeConverter.ToInt32(left) ^ TypeConverter.ToInt32(right);

                case BinaryOperator.LeftShift:
                    return TypeConverter.ToInt32(left) << (int)(TypeConverter.ToUint32(right) & 0x1F);

                case BinaryOperator.RightShift:
                    return TypeConverter.ToInt32(left) >> (int)(TypeConverter.ToUint32(right) & 0x1F);

                case BinaryOperator.UnsignedRightShift:
                    return (uint)TypeConverter.ToInt32(left) >> (int)(TypeConverter.ToUint32(right) & 0x1F);

                case BinaryOperator.InstanceOf:
                    var f = right.TryCast<FunctionInstance>();

                    if (f == null)
                    {
                        throw new JavaScriptException().Creator(_engine.TypeError, "instanceof can only be used with a function object");
                    }

                    value = f.HasInstance(left);
                    break;
                
                case BinaryOperator.In:
                    if (!right.IsObject())
                    {
                        throw new JavaScriptException().Creator(_engine.TypeError, "in can only be used with an object");
                    }

                    value = right.AsObject().HasProperty(TypeConverter.ToString(left));
                    break;
                
                default:
                    throw new NotImplementedException();
            }

            return value;
        }

        public JsValue EvaluateLogicalExpression(LogicalExpression logicalExpression)
        {
            var left = _engine.GetValue(EvaluateExpression(logicalExpression.Left));

            switch (logicalExpression.Operator)
            {

                case LogicalOperator.LogicalAnd:
                    if (!TypeConverter.ToBoolean(left))
                    {
                        return left;
                    }

                    return _engine.GetValue(EvaluateExpression(logicalExpression.Right));

                case LogicalOperator.LogicalOr:
                    if (TypeConverter.ToBoolean(left))
                    {
                        return left;
                    }

                    return _engine.GetValue(EvaluateExpression(logicalExpression.Right));

                default:
                    throw new NotImplementedException();
            }
        }

        public static bool Equal(JsValue x, JsValue y)
        {
            var typex = x.Type;
            var typey = y.Type;

            if (typex == typey)
            {
                if (typex == Types.Undefined || typex == Types.Null)
                {
                    return true;
                }

                if (typex == Types.Number)
                {
                    var nx = TypeConverter.ToNumber(x);
                    var ny = TypeConverter.ToNumber(y);

                    if (double.IsNaN(nx) || double.IsNaN(ny))
                    {
                        return false;
                    }

                    if (nx.Equals(ny))
                    {
                        return true;
                    }

                    return false;
                }

                if (typex == Types.String)
                {
                    return TypeConverter.ToString(x) == TypeConverter.ToString(y);
                }

                if (typex == Types.Boolean)
                {
                    return x.AsBoolean() == y.AsBoolean();
                }

                return x.Equals(y);
            }

            if (x.Equals( Null.Instance) && y.Equals(Undefined.Instance))
            {
                return true;
            }

            if (x.Equals(Undefined.Instance) && y.Equals( Null.Instance))
            {
                return true;
            }

            if (typex == Types.Number && typey == Types.String)
            {
                return Equal(x, TypeConverter.ToNumber(y));
            }

            if (typex == Types.String && typey == Types.Number)
            {
                return Equal(TypeConverter.ToNumber(x), y);
            }

            if (typex == Types.Boolean)
            {
                return Equal(TypeConverter.ToNumber(x), y);
            }

            if (typey == Types.Boolean)
            {
                return Equal(x, TypeConverter.ToNumber(y));
            }

            if (typey == Types.Object && (typex == Types.String || typex == Types.Number))
            {
                return Equal(x, TypeConverter.ToPrimitive(y));
            }

            if (typex == Types.Object && (typey == Types.String || typey == Types.Number))
            {
                return Equal(TypeConverter.ToPrimitive(x), y);
            }

            return false;
        }

        public static bool StrictlyEqual(JsValue x, JsValue y)
        {
            var typea = x.Type;
            var typeb = y.Type;

            if (typea != typeb)
            {
                return false;
            }

            if (typea == Types.Undefined || typea == Types.Null)
            {
                return true;
            }

            if (typea == Types.None)
            {
                return true;
            }
            if (typea == Types.Number)
            {
                var nx = TypeConverter.ToNumber(x);
                var ny = TypeConverter.ToNumber(y);

                if (double.IsNaN(nx) || double.IsNaN(ny))
                {
                    return false;
                }

                if (nx.Equals(ny))
                {
                    return true;
                }

                return false;
            }
            if (typea == Types.String)
            {
                return TypeConverter.ToString(x) == TypeConverter.ToString(y);
            }
            if (typea == Types.Boolean)
            {
                return TypeConverter.ToBoolean(x) == TypeConverter.ToBoolean(y);
            }
            return x.Equals( y);
        }

        public static bool SameValue(JsValue x, JsValue y)
        {
            var typea = TypeConverter.GetPrimitiveType(x);
            var typeb = TypeConverter.GetPrimitiveType(y);

            if (typea != typeb)
            {
                return false;
            }

            if (typea == Types.None)
            {
                return true;
            }
            if (typea == Types.Number)
            {
                var nx = TypeConverter.ToNumber(x);
                var ny = TypeConverter.ToNumber(y);

                if (double.IsNaN(nx) && double.IsNaN(ny))
                {
                    return true;
                }

                if (nx.Equals(ny))
                {
                    if (nx.Equals(0))
                    {
                        // +0 !== -0
                        return NumberInstance.IsNegativeZero(nx) == NumberInstance.IsNegativeZero(ny);
                    }

                    return true;
                }

                return false;
            }
            if (typea == Types.String)
            {
                return TypeConverter.ToString(x) == TypeConverter.ToString(y);
            }
            if (typea == Types.Boolean)
            {
                return TypeConverter.ToBoolean(x) == TypeConverter.ToBoolean(y);
            }
            return x.Equals( y);
        }

        public static JsValue Compare(JsValue x, JsValue y, bool leftFirst = true)
        {
            JsValue px, py;
            if (leftFirst)
            {
                px = TypeConverter.ToPrimitive(x, Types.Number);
                py = TypeConverter.ToPrimitive(y, Types.Number);
            }
            else
            {
                py = TypeConverter.ToPrimitive(y, Types.Number);
                px = TypeConverter.ToPrimitive(x, Types.Number);
            }

            var typea = px.Type;
            var typeb = py.Type;

            if (typea != Types.String || typeb != Types.String)
            {
                var nx = TypeConverter.ToNumber(px);
                var ny = TypeConverter.ToNumber(py);

                if (double.IsNaN(nx) || double.IsNaN(ny))
                {
                    return Undefined.Instance;
                }

                if (nx.Equals(ny))
                {
                    return false;
                }

                if (double.IsPositiveInfinity(nx))
                {
                    return false;
                }

                if (double.IsPositiveInfinity(ny))
                {
                    return true;
                }

                if (double.IsNegativeInfinity(ny))
                {
                    return false;
                }

                if (double.IsNegativeInfinity(nx))
                {
                    return true;
                }

                return nx < ny;
            }
            else
            {
                return String.CompareOrdinal(TypeConverter.ToString(x), TypeConverter.ToString(y)) < 0;
            }
        }

        public Reference EvaluateIdentifier(Identifier identifier)
        {
            var env = _engine.ExecutionContext.LexicalEnvironment;
            var strict = StrictModeScope.IsStrictModeCode;

            return LexicalEnvironment.GetIdentifierReference(env, identifier.Name, strict);
        }

        public JsValue EvaluateLiteral(Literal literal)
        {
            if (literal.Type == SyntaxNodes.RegularExpressionLiteral)
            {
                return _engine.RegExp.Construct(literal.Raw);
            }

            return JsValue.FromObject(_engine, literal.Value);
        }

        public JsValue EvaluateObjectExpression(ObjectExpression objectExpression)
        {
            // http://www.ecma-international.org/ecma-262/5.1/#sec-11.1.5

            var obj = _engine.Object.Construct(Arguments.Empty);
            
            foreach (var property in objectExpression.Properties)
            {
                var propName = property.Key.GetKey();
                var previous = obj.GetOwnProperty(propName);
                PropertyDescriptor propDesc;

                switch (property.Kind)
                {
                    case PropertyKind.Data:
                        var exprValue = _engine.EvaluateExpression(property.Value);
                        var propValue = _engine.GetValue(exprValue);
                        propDesc = new PropertyDescriptor().Creator(propValue, true, true, true);
                        break;

                    case PropertyKind.Get:
                        var getter = (FunctionExpression)property.Value;

                        if (getter == null)
                        {
                            throw new JavaScriptException().Creator(_engine.SyntaxError);
                        }

                        ScriptFunctionInstance get=null;
                        var strictModeScope = (new StrictModeScope(getter.Strict));
                        
                            get = new ScriptFunctionInstance(
                                _engine,
                                getter,
                                _engine.ExecutionContext.LexicalEnvironment, 
                                StrictModeScope.IsStrictModeCode
                            );
                  
                        //todo propDesc = new PropertyDescriptor(get:get,  set:null, enumerable: true, configurable: true);
                        propDesc = new PropertyDescriptor().Creator(get, null, enumerable: true, configurable: true);
                        break;
                    
                    case PropertyKind.Set:
                        var setter = (FunctionExpression)property.Value;

                        if (setter == null)
                        {
                            throw new JavaScriptException().Creator(_engine.SyntaxError);
                        }

                        ScriptFunctionInstance set;
                        var strictModeScope_ = (new StrictModeScope(setter.Strict));
                    
                            
                            set = new ScriptFunctionInstance(
                                _engine,
                                setter,
                                _engine.ExecutionContext.LexicalEnvironment,
                                StrictModeScope.IsStrictModeCode
                                );
                    
                        propDesc = new PropertyDescriptor().Creator(get: null, set: set, enumerable: true, configurable: true);
                        break;

                    default:
                        throw new ArgumentOutOfRangeException();
                }

                if (previous != PropertyDescriptor.Undefined)
                {
                    if (StrictModeScope.IsStrictModeCode && previous.IsDataDescriptor() && propDesc.IsDataDescriptor())
                    {
                        throw new JavaScriptException().Creator(_engine.SyntaxError);
                    }

                    if (previous.IsDataDescriptor() && propDesc.IsAccessorDescriptor())
                    {
                        throw new JavaScriptException().Creator(_engine.SyntaxError);
                    }

                    if (previous.IsAccessorDescriptor() && propDesc.IsDataDescriptor())
                    {
                        throw new JavaScriptException().Creator(_engine.SyntaxError);
                    }

                    if (previous.IsAccessorDescriptor() && propDesc.IsAccessorDescriptor())
                    {
                        if (propDesc.Set != null && previous.Set != null)
                        {
                            throw new JavaScriptException().Creator(_engine.SyntaxError);
                        }

                        if (propDesc.Get != null && previous.Get != null)
                        {
                            throw new JavaScriptException().Creator(_engine.SyntaxError);
                        }
                    }
                }

                obj.DefineOwnProperty(propName, propDesc, false);
            }
       
            return obj;
        }

        /// <summary>
        /// http://www.ecma-international.org/ecma-262/5.1/#sec-11.2.1
        /// </summary>
        /// <param name="memberExpression"></param>
        /// <returns></returns>
        public Reference EvaluateMemberExpression(MemberExpression memberExpression)
        {
            var baseReference = EvaluateExpression(memberExpression.Object);
            var baseValue = _engine.GetValue(baseReference);
            Expression expression = memberExpression.Property;

            
            if (!memberExpression.Computed) // index accessor ?
            {
                var literal = new Literal();
                literal.Type = SyntaxNodes.Literal;
                literal.Value = memberExpression.Property.As<Identifier>().Name;
                expression=literal;
            }

            var propertyNameReference = EvaluateExpression(expression);
            var propertyNameValue = _engine.GetValue(propertyNameReference);
            TypeConverter.CheckObjectCoercible(_engine, baseValue);
            var propertyNameString = TypeConverter.ToString(propertyNameValue);

            return new Reference(baseValue, propertyNameString, StrictModeScope.IsStrictModeCode);
        }

        public JsValue EvaluateFunctionExpression(FunctionExpression functionExpression)
        {
            var funcEnv = LexicalEnvironment.NewDeclarativeEnvironment(_engine, _engine.ExecutionContext.LexicalEnvironment);
            var envRec = (DeclarativeEnvironmentRecord)funcEnv.Record;

            if (functionExpression.Id != null && !String.IsNullOrEmpty(functionExpression.Id.Name))
            {
                envRec.CreateMutableBinding(functionExpression.Id.Name);
            }

            var closure = new ScriptFunctionInstance(
                _engine,
                functionExpression,
                funcEnv,
                functionExpression.Strict
                );

            if (functionExpression.Id != null && !String.IsNullOrEmpty(functionExpression.Id.Name))
            {
                envRec.InitializeImmutableBinding(functionExpression.Id.Name, closure);
            }

            return closure;
        }

        public JsValue EvaluateCallExpression(CallExpression callExpression)
        { 
     
            var callee = EvaluateExpression(callExpression.Callee);

            if (_engine.Options.IsDebugMode())
            {
                _engine.DebugHandler.AddToDebugCallStack(callExpression);
            }

            JsValue thisObject;
            JsValue[] arguments = null;
            //var arguments = (from y  in (from x in callExpression.Arguments select EvaluateExpression(x)) select _engine.GetValue(y) ).ToArray();

            // todo: implement as in http://www.ecma-international.org/ecma-262/5.1/#sec-11.2.4
            //todo var arguments = callExpression.Arguments.Select(EvaluateExpression).Select(_engine.GetValue).ToArray();
           
            var func = _engine.GetValue(callee);

            var r = (Reference)callee;

            var isRecursionHandled = _engine.Options.GetMaxRecursionDepth() >= 0;
            if (isRecursionHandled)
            {
                var stackItem = new CallStackElement(callExpression, func, r != null ? r.GetReferencedName() : "anonymous function");

                var recursionDepth = _engine.CallStack.Push(stackItem);

                if (recursionDepth > _engine.Options.GetMaxRecursionDepth())
                {
                    _engine.CallStack.Pop();
                    throw new RecursionDepthOverflowException(_engine.CallStack, stackItem.ToString());
                }
            }

            if (func.Equals( Undefined.Instance))
            {
                throw new JavaScriptException().Creator(_engine.TypeError, r == null ? "" : string.Format("Object has no method '{0}'", ((Reference)callee).GetReferencedName()));
            }

            if (!func.IsObject())
            {
                throw new JavaScriptException().Creator(_engine.TypeError, r == null ? "" : string.Format("Property '{0}' of object is not a function", ((Reference)callee).GetReferencedName()));
            }

            var callable = func.TryCast<ICallable>();
            if (callable == null)
            {
                throw new JavaScriptException().Creator(_engine.TypeError);
            }
            
            if (r != null)
            {
                if (r.IsPropertyReference())
                {
                    thisObject = r.GetBase();
                }
                else
                {
                    var env = r.GetBase().TryCast<EnvironmentRecord>();
                    thisObject = env.ImplicitThisValue();
                }
            }
            else
            {
                thisObject = Undefined.Instance;
            }

            // is it a direct call to eval ? http://www.ecma-international.org/ecma-262/5.1/#sec-15.1.2.1.1
            if (r != null && r.GetReferencedName() == "eval" && callable is EvalFunctionInstance)
            {
                 return ((EvalFunctionInstance) callable).Call(thisObject, arguments, true);
            }
            
            var result = callable.Call(thisObject, arguments);

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

        public JsValue EvaluateSequenceExpression(SequenceExpression sequenceExpression)
        {
            var result = Undefined.Instance;
            foreach (var expression in sequenceExpression.Expressions)
            {
                result = _engine.GetValue(_engine.EvaluateExpression(expression));
            }

            return result;
        }

        public JsValue EvaluateUpdateExpression(UpdateExpression updateExpression)
        {
            var value = _engine.EvaluateExpression(updateExpression.Argument);
            Reference r;

            switch (updateExpression.Operator)
            {
                case UnaryOperator.Increment:
                    r = (Reference)value;
                    if (r != null
                        && r.IsStrict()
                        && (r.GetBase().TryCast<EnvironmentRecord>() != null)
                        && (Array.IndexOf(new[] { "eval", "arguments" }, r.GetReferencedName()) != -1))
                    {
                        throw new JavaScriptException().Creator(_engine.SyntaxError);
                    }

                    var oldValue = TypeConverter.ToNumber(_engine.GetValue(value));
                    var newValue = oldValue + 1;
                    _engine.PutValue(r, newValue);

                    return updateExpression.Prefix ? newValue : oldValue;

                case UnaryOperator.Decrement:
                    r = (Reference)value;
                    if (r != null
                        && r.IsStrict()
                        && (r.GetBase().TryCast<EnvironmentRecord>() != null)
                        && (Array.IndexOf(new[] { "eval", "arguments" }, r.GetReferencedName()) != -1))
                    {
                        throw new JavaScriptException().Creator(_engine.SyntaxError);
                    }

                    oldValue = TypeConverter.ToNumber(_engine.GetValue(value));
                    newValue = oldValue - 1;
                    _engine.PutValue(r, newValue);

                    return updateExpression.Prefix ? newValue : oldValue;
                default:
                    throw new ArgumentException();
            }

        }

        public JsValue EvaluateThisExpression(ThisExpression thisExpression)
        {
            return _engine.ExecutionContext.ThisBinding;
        }

        //todo return JsValue
        public JsValue  EvaluateNewExpression(NewExpression newExpression)
        {

            JsValue[] arguments = null;
             //todo  var  arguments = newExpression.Arguments.Select(EvaluateExpression).Select(_engine.GetValue).ToArray();
           // var arguments = (from y in (from x in newExpression.Arguments select EvaluateExpression(x)) select _engine.GetValue(y)).ToArray();
            // todo: optimize by defining a common abstract class or interface
            var callee = _engine.GetValue(EvaluateExpression(newExpression.Callee)).TryCast<IConstructor>();
            
            if (callee == null)
            {
                throw new JavaScriptException().Creator(_engine.TypeError, "The object can't be used as constructor.");
            }

            // construct the new instance using the Function's constructor method 

            var instance = callee.Construct(arguments);

           return instance;
         
        }

        public JsValue EvaluateArrayExpression(ArrayExpression arrayExpression)
        {
            var a = _engine.Array.Construct(new JsValue[] { arrayExpression.Elements.Count() });
            var n = 0;
            foreach (var expr in arrayExpression.Elements)
            {
                if (expr != null)
                {
                    var value = _engine.GetValue(EvaluateExpression(expr));
                    a.DefineOwnProperty(n.ToString(),
                        new PropertyDescriptor().Creator(value, true, true, true), false);
                }
                n++;
            }
            
            return a;
        }

        public JsValue EvaluateUnaryExpression(UnaryExpression unaryExpression)
        {
            var value = _engine.EvaluateExpression(unaryExpression.Argument);
            Reference r;

            switch (unaryExpression.Operator)
            {
                case UnaryOperator.Plus:
                    return TypeConverter.ToNumber(_engine.GetValue(value));
                    
                case UnaryOperator.Minus:
                    var n = TypeConverter.ToNumber(_engine.GetValue(value));
                    return double.IsNaN(n) ? double.NaN : n*-1;
                
                case UnaryOperator.BitwiseNot:
                    return ~TypeConverter.ToInt32(_engine.GetValue(value));
                
                case UnaryOperator.LogicalNot:
                    return !TypeConverter.ToBoolean(_engine.GetValue(value));
                
                case UnaryOperator.Delete:
                    r = (Reference)value;
                    if (r == null)
                    {
                        return true;
                    }
                    if (r.IsUnresolvableReference())
                    {
                        if (r.IsStrict())
                        {
                            throw new JavaScriptException().Creator(_engine.SyntaxError);
                        }

                        return true;
                    }
                    if (r.IsPropertyReference())
                    {
                        var o = TypeConverter.ToObject(_engine, r.GetBase());
                        return o.Delete(r.GetReferencedName(), r.IsStrict());
                    }
                    if (r.IsStrict())
                    {
                        throw new JavaScriptException().Creator(_engine.SyntaxError);
                    }
                    var bindings = r.GetBase().TryCast<EnvironmentRecord>();
                    return bindings.DeleteBinding(r.GetReferencedName());
                
                case UnaryOperator.Void:
                    _engine.GetValue(value);
                    return Undefined.Instance;

                case UnaryOperator.TypeOf:
                    r = (Reference)value;
                    if (r != null)
                    {
                        if (r.IsUnresolvableReference())
                        {
                            return "undefined";
                        }
                    }
                    var v = _engine.GetValue(value);
                    if (v.Equals(Undefined.Instance))
                    {
                        return "undefined";
                    }
                    if (v.Equals( Null.Instance))
                    {
                        return "object";
                    }
                    switch (v.Type)
                    {
                        case Types.Boolean: return "boolean";
                        case Types.Number: return "number";
                        case Types.String: return "string";
                    }
                    if (v.TryCast<ICallable>() != null)
                    {
                        return "function";
                    }
                    return "object";

                default:
                    throw new ArgumentException();
            }
        }
    }
}