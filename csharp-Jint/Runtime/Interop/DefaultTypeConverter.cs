using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Linq.Expressions;
using Jint.Native;
using System.Collections.Generic;
using System.Reflection;

namespace Jint.Runtime.Interop
{
    public class DefaultTypeConverter : ITypeConverter
    {
        private readonly Engine _engine;
        private static readonly Dictionary<string, bool> _knownConversions = new Dictionary<string, bool>();
        private static readonly object _lockObject = new object();

        private static MethodInfo convertChangeType = typeof(System.Convert).GetMethod("ChangeType", new Type[] { typeof(object), typeof(Type), typeof(IFormatProvider) } );
        private static MethodInfo jsValueFromObject = typeof(JsValue).GetMethod("FromObject");
        private static MethodInfo jsValueToObject = typeof(JsValue).GetMethod("ToObject");

        public DefaultTypeConverter(Engine engine)
        {
            _engine = engine;
        }

        public virtual object Convert(object value, Type type, IFormatProvider formatProvider)
        {
           
           //todo
            if (value == null)
            {
                if (TypeConverter.TypeIsNullable(type))
                {
                    return null;
                }

                throw new NotSupportedException(string.Format("Unable to convert null to '{0}'", type.FullName));
            }

            // don't try to convert if value is derived from type
            if (type.IsInstanceOfType(value))
            {
                return value;
            }

            if (type.IsEnum)
            {
                var integer = System.Convert.ChangeType(value, typeof(int), formatProvider);
                if (integer == null)
                {
                    throw new ArgumentOutOfRangeException();
                }

                return Enum.ToObject(type, integer);
            }

            var valueType = value.GetType();
            // is the javascript value an ICallable instance ?
            if (valueType == typeof(Func<JsValue, JsValue[], JsValue>))
            {
                var function_ = (Func<JsValue, JsValue[], JsValue>)value;

                if (type.IsGenericType)
                {
                    var genericType = type.GetGenericTypeDefinition();

                    // create the requested Delegate
                    if (genericType.Name.StartsWith("Action"))
                    {
                        var genericArguments = type.GetGenericArguments();

                        var @params = new ParameterExpression[genericArguments.Count()];
                        for (var i = 0; i < @params.Count(); i++)
                        {
                            @params[i] = Expression.Parameter(genericArguments[i], genericArguments[i].Name + i);
                        }
                        var tmpVars = new Expression[@params.Length];
                        for (var i = 0; i < @params.Count(); i++)
                        {
                            var param = @params[i];
                            if (param.Type.IsValueType)
                            {
                                var boxing = Expression.Convert(param, typeof(object));
                                tmpVars[i] = Expression.Call(null, jsValueFromObject, Expression.Constant(_engine, typeof(Engine)), boxing);
                            }
                            else
                            {
                                tmpVars[i] = Expression.Call(null, jsValueFromObject, Expression.Constant(_engine, typeof(Engine)), param);
                            }
                        }
                        var @vars = Expression.NewArrayInit(typeof(JsValue), tmpVars);
                        //todo 

                        var callExpresionBlock = Expression.Call(
                                               Expression.Call(Expression.Constant(function_.Target),
                                                   function_.Method,
                                                   Expression.Constant(JsValue.Undefined, typeof(JsValue)),
                                                   @vars),
                                               jsValueToObject);

                          

                        /*
                        var callExpresion = Expression.Block(Expression.Call(
                                                Expression.Call(Expression.Constant(function.Target),
                                                    function.Method,
                                                    Expression.Constant(JsValue.Undefined, typeof(JsValue)),
                                                    @vars),
                                                jsValueToObject), Expression.Empty());
                        */
                        return Expression.Lambda(callExpresionBlock,  @params );
                    }
                    else if (genericType.Name.StartsWith("Func"))
                    {
                        var genericArguments = type.GetGenericArguments();
                        var returnType = genericArguments.Last();

                        var @params = new ParameterExpression[genericArguments.Count() - 1];
                        for (var i = 0; i < @params.Count(); i++)
                        {
                            @params[i] = Expression.Parameter(genericArguments[i], genericArguments[i].Name + i);
                        }


                        var tmpVars =  @params.Select(p => {
                                    var boxingExpression = Expression.Convert(p, typeof(object));
                                    return Expression.Call(null, jsValueFromObject, Expression.Constant(_engine, typeof(Engine)), boxingExpression);
                                }).ToArray();


                        var @vars = Expression.NewArrayInit(typeof(JsValue), tmpVars);

                        // the final result's type needs to be changed before casting,
                        // for instance when a function returns a number (double) but C# expects an integer

                        var callExpresion = Expression.Convert(
                                                Expression.Call(null,
                                                    convertChangeType,
                                                    Expression.Call(
                                                            Expression.Call(Expression.Constant(function_.Target),
                                                                    function_.Method,
                                                                    Expression.Constant(JsValue.Undefined, typeof(JsValue)),
                                                                    @vars),
                                                            jsValueToObject),
                                                        Expression.Constant(returnType, typeof(Type)),
                                                        Expression.Constant(System.Globalization.CultureInfo.InvariantCulture, typeof(IFormatProvider))
                                                        ),                            
                                                    returnType);
                        return Expression.Lambda(callExpresion, @params);
                       // return Expression.Lambda(callExpresion, new ReadOnlyCollection<ParameterExpression>(@params));
                         
                    }
                }
                else
                {
                    if (type == typeof(Action))
                    {
                        return (Action)(() => function_(JsValue.Undefined, new JsValue[0]));
                    }
                    else if (type.IsSubclassOf(typeof(System.MulticastDelegate)))
                    {
                        var method = type.GetMethod("Invoke");
                        var arguments = method.GetParameters();

                        var @params = new ParameterExpression[arguments.Count()];
                        for (var i = 0; i < @params.Count(); i++)
                        {
                            @params[i] = Expression.Parameter(typeof(object), arguments[i].Name);
                        }

                        var tmpVars =  @params.Select(p => Expression.Call(null, typeof(JsValue).GetMethod("FromObject"), Expression.Constant(_engine, typeof(Engine)), p)).ToArray();
                        var @vars = Expression.NewArrayInit(typeof(JsValue), tmpVars);

                        var callExpresionBlock = Expression.Call(
                                                  Expression.Call(Expression.Constant(function_.Target),
                                                      function_.Method,
                                                      Expression.Constant(JsValue.Undefined, typeof(JsValue)),
                                                      @vars),
                                                  typeof(JsValue).GetMethod("ToObject"));
                        
                        /*
                        var callExpression = Expression.Block(
                                                Expression.Call(
                                                    Expression.Call(Expression.Constant(function.Target),
                                                        function.Method,
                                                        Expression.Constant(JsValue.Undefined, typeof(JsValue)),
                                                        @vars),
                                                    typeof(JsValue).GetMethod("ToObject")),
                                                Expression.Empty());
                        */

                        var lambdaExpression = Expression.Lambda(callExpresionBlock,  @params );

                        var dynamicExpression = Expression.Invoke(lambdaExpression, @params );

                        return Expression.Lambda(type, dynamicExpression, @params );
                    }
                }

            }

            if (type.IsArray)
            {
                var source = value as object[];
                if (source == null)
                    throw new ArgumentException(String.Format("Value of object[] type is expected, but actual type is {0}.", value.GetType()));

                var targetElementType = type.GetElementType();
                var itemsConverted = source.Select(o => Convert(o, targetElementType, formatProvider)).ToArray();
                var result = Array.CreateInstance(targetElementType, source.Length);
                itemsConverted.CopyTo(result, 0);
                return result;
            }

            return System.Convert.ChangeType(value, type, formatProvider);
          
        }

        public virtual KeyValuePair<bool, object> TryConvert(object value, Type type, IFormatProvider formatProvider )
        {
            bool canConvert;
            var key = value == null ? String.Format("Null->{0}", type) : String.Format("{0}->{1}", value.GetType(), type);
            object converted = null;
            if (!_knownConversions.TryGetValue(key, out canConvert))
            {
                //lock (_lockObject)
                {
                    if (!_knownConversions.TryGetValue(key, out canConvert))
                    {
                        try
                        {
                            converted = Convert(value, type, formatProvider);
                            _knownConversions.Add(key, true);
                            return new KeyValuePair<bool, object>(true, converted);
                        }
                        catch
                        {
                            converted = null;
                            _knownConversions.Add(key, false);
                            return new KeyValuePair<bool, object>(false, null);
                        }
                    }
                }
            }

            if (canConvert)
            {
                converted = Convert(value, type, formatProvider);
                return new KeyValuePair<bool, object>(true, converted); ;
            }

            converted = null;
            return   new KeyValuePair<bool, object>(false, null);
        }
    }
}
