package jint.runtime.interop;
using StringTools;
import system.*;
import anonymoustypes.*;

class DefaultTypeConverter implements jint.runtime.interop.ITypeConverter
{
    private var _engine:jint.Engine;
    private static var _knownConversions:system.collections.generic.Dictionary<String, Bool>;
    private static var _lockObject:Dynamic;
    private static var convertChangeType:system.reflection.MethodInfo;
    private static var jsValueFromObject:system.reflection.MethodInfo;
    private static var jsValueToObject:system.reflection.MethodInfo;
    public function new(engine:jint.Engine)
    {
        _engine = engine;
    }
    public function Convert(value:Dynamic, type:system.TypeCS, formatProvider:system.IFormatProvider):Dynamic
    {
        if (value == null)
        {
            if (jint.runtime.TypeConverter.TypeIsNullable(type))
            {
                return null;
            }
            return throw new system.NotSupportedException(Cs2Hx.Format("Unable to convert null to '{0}'", type.FullName));
        }
        if (type.IsInstanceOfType(value))
        {
            return value;
        }
        if (type.IsEnum)
        {
            var integer:Dynamic = system.Convert.ChangeType_Object_Type_IFormatProvider(value, typeof(Int), formatProvider);
            if (integer == null)
            {
                return throw new system.ArgumentOutOfRangeException();
            }
            return system.Enum.ToObject(type, integer);
        }
        var valueType:system.TypeCS = system.Cs2Hx.GetType(value);
        if (valueType == typeof((jint.native.JsValue -> Array<jint.native.JsValue> -> jint.native.JsValue)))
        {
            var function:(jint.native.JsValue -> Array<jint.native.JsValue> -> jint.native.JsValue) = value;
            if (type.IsGenericType)
            {
                var genericType:system.TypeCS = type.GetGenericTypeDefinition();
                if (system.Cs2Hx.StartsWith(genericType.Name, "Action"))
                {
                    var genericArguments:Array<system.TypeCS> = type.GetGenericArguments();
                    var params:Array<system.linq.expressions.ParameterExpression> = [  ];
                    { //for
                        var i:Int = 0;
                        while (i < system.linq.Enumerable.Count(@params))
                        {
                            @params[i] = system.linq.expressions.Expression.Parameter_Type_String(genericArguments[i], genericArguments[i].Name + i);
                            i++;
                        }
                    } //end for
                    var tmpVars:Array<system.linq.expressions.Expression> = [  ];
                    { //for
                        var i:Int = 0;
                        while (i < system.linq.Enumerable.Count(@params))
                        {
                            var param:system.linq.expressions.ParameterExpression = @params[i];
                            if (param.Type.IsValueType)
                            {
                                var boxing:system.linq.expressions.UnaryExpression = system.linq.expressions.Expression.Convert(param, typeof(Dynamic));
                                tmpVars[i] = system.linq.expressions.Expression.Call_Expression_MethodInfo_Expression_Expression(null, jsValueFromObject, system.linq.expressions.Expression.Constant_Object_Type(_engine, typeof(jint.Engine)), boxing);
                            }
                            else
                            {
                                tmpVars[i] = system.linq.expressions.Expression.Call_Expression_MethodInfo_Expression_Expression(null, jsValueFromObject, system.linq.expressions.Expression.Constant_Object_Type(_engine, typeof(jint.Engine)), param);
                            }
                            i++;
                        }
                    } //end for
                    var vars:system.linq.expressions.NewArrayExpression = system.linq.expressions.Expression.NewArrayInit(typeof(jint.native.JsValue), tmpVars);
                    var callExpresionBlock:system.linq.expressions.MethodCallExpression = system.linq.expressions.Expression.Call_Expression_MethodInfo(system.linq.expressions.Expression.Call_Expression_MethodInfo_Expression_Expression(system.linq.expressions.Expression.Constant(function.Target), function.Method, system.linq.expressions.Expression.Constant_Object_Type(jint.native.JsValue.Undefined, typeof(jint.native.JsValue)), @vars), jsValueToObject);
                    return system.linq.expressions.Expression.Lambda_Expression_(callExpresionBlock, @params);
                }
                else if (system.Cs2Hx.StartsWith(genericType.Name, "Func"))
                {
                    var genericArguments:Array<system.TypeCS> = type.GetGenericArguments();
                    var returnType:system.TypeCS = system.linq.Enumerable.Last(genericArguments);
                    var params:Array<system.linq.expressions.ParameterExpression> = [  ];
                    { //for
                        var i:Int = 0;
                        while (i < system.linq.Enumerable.Count(@params))
                        {
                            @params[i] = system.linq.expressions.Expression.Parameter_Type_String(genericArguments[i], genericArguments[i].Name + i);
                            i++;
                        }
                    } //end for
                    var tmpVars:Array<system.linq.expressions.MethodCallExpression> = system.linq.Enumerable.ToArray(system.linq.Enumerable.Select(@params, function (p:system.linq.expressions.ParameterExpression):system.linq.expressions.MethodCallExpression
                    {
                        var boxingExpression:system.linq.expressions.UnaryExpression = system.linq.expressions.Expression.Convert(p, typeof(Dynamic));
                        return system.linq.expressions.Expression.Call_Expression_MethodInfo_Expression_Expression(null, jsValueFromObject, system.linq.expressions.Expression.Constant_Object_Type(_engine, typeof(jint.Engine)), boxingExpression);
                    }
                    ));
                    var vars:system.linq.expressions.NewArrayExpression = system.linq.expressions.Expression.NewArrayInit(typeof(jint.native.JsValue), tmpVars);
                    var callExpresion:system.linq.expressions.UnaryExpression = system.linq.expressions.Expression.Convert(system.linq.expressions.Expression.Call_Expression_MethodInfo_Expression_Expression_Expression(null, convertChangeType, system.linq.expressions.Expression.Call_Expression_MethodInfo(system.linq.expressions.Expression.Call_Expression_MethodInfo_Expression_Expression(system.linq.expressions.Expression.Constant(function.Target), function.Method, system.linq.expressions.Expression.Constant_Object_Type(jint.native.JsValue.Undefined, typeof(jint.native.JsValue)), @vars), jsValueToObject), system.linq.expressions.Expression.Constant_Object_Type(returnType, typeof(system.TypeCS)), system.linq.expressions.Expression.Constant_Object_Type(system.globalization.CultureInfo.InvariantCulture, typeof(system.IFormatProvider))), returnType);
                    return system.linq.expressions.Expression.Lambda_Expression_(callExpresion, @params);
                }
            }
            else
            {
                if (type == typeof((Void -> Void)))
                {
                    return (function ():Void { function(jint.native.JsValue.Undefined, [  ]); } );
                }
                else if (type.IsSubclassOf(typeof(Dynamic)))
                {
                    var method:system.reflection.MethodInfo = type.GetMethod("Invoke");
                    var arguments:Array<system.reflection.ParameterInfo> = method.GetParameters();
                    var params:Array<system.linq.expressions.ParameterExpression> = [  ];
                    { //for
                        var i:Int = 0;
                        while (i < system.linq.Enumerable.Count(@params))
                        {
                            @params[i] = system.linq.expressions.Expression.Parameter_Type_String(typeof(Dynamic), arguments[i].Name);
                            i++;
                        }
                    } //end for
                    var tmpVars:Array<system.linq.expressions.MethodCallExpression> = system.linq.Enumerable.ToArray(system.linq.Enumerable.Select(@params, function (p:system.linq.expressions.ParameterExpression):system.linq.expressions.MethodCallExpression { return system.linq.expressions.Expression.Call_Expression_MethodInfo_Expression_Expression(null, typeof(jint.native.JsValue).GetMethod("FromObject"), system.linq.expressions.Expression.Constant_Object_Type(_engine, typeof(jint.Engine)), p); } ));
                    var vars:system.linq.expressions.NewArrayExpression = system.linq.expressions.Expression.NewArrayInit(typeof(jint.native.JsValue), tmpVars);
                    var callExpresionBlock:system.linq.expressions.MethodCallExpression = system.linq.expressions.Expression.Call_Expression_MethodInfo(system.linq.expressions.Expression.Call_Expression_MethodInfo_Expression_Expression(system.linq.expressions.Expression.Constant(function.Target), function.Method, system.linq.expressions.Expression.Constant_Object_Type(jint.native.JsValue.Undefined, typeof(jint.native.JsValue)), @vars), typeof(jint.native.JsValue).GetMethod("ToObject"));
                    var lambdaExpression:system.linq.expressions.LambdaExpression = system.linq.expressions.Expression.Lambda_Expression_(callExpresionBlock, @params);
                    var dynamicExpression:system.linq.expressions.InvocationExpression = system.linq.expressions.Expression.Invoke(lambdaExpression, @params);
                    return system.linq.expressions.Expression.Lambda_Type_Expression_(type, dynamicExpression, @params);
                }
            }
        }
        if (type.IsArray)
        {
            var source:Array<Dynamic> = (Std.is(value, Array<Dynamic>) ? cast(value, Array<Dynamic>) : null);
            if (source == null)
            {
                return throw new system.ArgumentException(system.String.Format("Value of object[] type is expected, but actual type is {0}.", system.Cs2Hx.GetType(value)));
            }
            var targetElementType:system.TypeCS = type.GetElementType();
            var itemsConverted:Array<Dynamic> = system.linq.Enumerable.ToArray(system.linq.Enumerable.Select(source, function (o:Dynamic):Dynamic { return Convert(o, targetElementType, formatProvider); } ));
            var result = system.Array.CreateInstance(targetElementType, source.length);
            itemsConverted.CopyTo(result, 0);
            return result;
        }
        return system.Convert.ChangeType_Object_Type_IFormatProvider(value, type, formatProvider);
    }
    public function TryConvert(value:Dynamic, type:system.TypeCS, formatProvider:system.IFormatProvider):system.collections.generic.KeyValuePair<Bool, Dynamic>
    {
        var canConvert:CsRef<Bool> = new CsRef<Bool>(false);
        var key:String = value == null ? system.String.Format("Null->{0}", type) : system.String.Format_String_Object_Object("{0}->{1}", system.Cs2Hx.GetType(value), type);
        var converted:Dynamic = null;
        if (!_knownConversions.TryGetValue(key, canConvert))
        {
            {
                if (!_knownConversions.TryGetValue(key, canConvert))
                {
                    try
                    {
                        converted = Convert(value, type, formatProvider);
                        _knownConversions.Add(key, true);
                        return new system.collections.generic.KeyValuePair<Bool, Dynamic>(true, converted);
                    }
                    catch (__ex:Dynamic)
                    {
                        converted = null;
                        _knownConversions.Add(key, false);
                        return new system.collections.generic.KeyValuePair<Bool, Dynamic>(false, null);
                    }
                }
            }
        }
        if (canConvert.Value)
        {
            converted = Convert(value, type, formatProvider);
            return new system.collections.generic.KeyValuePair<Bool, Dynamic>(true, converted);
        }
        converted = null;
        return new system.collections.generic.KeyValuePair<Bool, Dynamic>(false, null);
    }
    public static function cctor():Void
    {
        _knownConversions = new system.collections.generic.Dictionary<String, Bool>();
        _lockObject = new CsObject();
        convertChangeType = typeof(system.Convert).GetMethod_String_("ChangeType", [ typeof(Dynamic), typeof(system.TypeCS), typeof(system.IFormatProvider) ]);
        jsValueFromObject = typeof(jint.native.JsValue).GetMethod("FromObject");
        jsValueToObject = typeof(jint.native.JsValue).GetMethod("ToObject");
    }
}
