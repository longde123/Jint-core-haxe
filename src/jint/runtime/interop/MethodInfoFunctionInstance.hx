package jint.runtime.interop;
using StringTools;
import system.*;
import anonymoustypes.*;

class MethodInfoFunctionInstance extends jint.native.functions.FunctionInstance
{
    private var _methods:Array<system.reflection.MethodInfo>;
    public function new(engine:jint.Engine, methods:Array<system.reflection.MethodInfo>)
    {
        super(engine, null, null, false);
        _methods = methods;
        Prototype = engine.JFunction.PrototypeObject;
    }
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return Invoke(_methods, thisObject, arguments);
    }
    public function Invoke(methodInfos:Array<system.reflection.MethodInfo>, thisObject:jint.native.JsValue, jsArguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var arguments:Array<jint.native.JsValue> = ProcessParamsArrays(jsArguments, methodInfos);
        var methods:Array<system.reflection.MethodBase> = system.linq.Enumerable.ToList(jint.runtime.TypeConverter.FindBestMatch(Engine, methodInfos, arguments));
        var converter:jint.runtime.interop.ITypeConverter = Engine.ClrTypeConverter;
        for (method in methods)
        {
            var parameters:Array<Dynamic> = [  ];
            var argumentsMatch:Bool = true;
            { //for
                var i:Int = 0;
                while (i < arguments.length)
                {
                    var parameterType:system.TypeCS = method.GetParameters()[i].ParameterType;
                    if (parameterType == typeof(jint.native.JsValue))
                    {
                        parameters[i] = arguments[i];
                    }
                    else if (parameterType == typeof(Array<jint.native.JsValue>) && arguments[i].IsArray())
                    {
                        var arrayInstance:jint.native.array.ArrayInstance = arguments[i].AsArray();
                        var len:Int = jint.runtime.TypeConverter.ToInt32(arrayInstance.Get("length"));
                        var result:Array<jint.native.JsValue> = [  ];
                        { //for
                            var k:Int = 0;
                            while (k < len)
                            {
                                var pk:String = Std.string(k);
                                result[k] = arrayInstance.HasProperty(pk) ? arrayInstance.Get(pk) : jint.native.JsValue.Undefined;
                                k++;
                            }
                        } //end for
                        parameters[i] = result;
                    }
                    else
                    {
                        var converter_:system.collections.generic.KeyValuePair<Bool, Dynamic> = converter.TryConvert(arguments[i].ToObject(), parameterType, system.globalization.CultureInfo.InvariantCulture);
                        parameters[i] = converter_.Value;
                        if (!converter_.Key)
                        {
                            argumentsMatch = false;
                            break;
                        }
                        var lambdaExpression:system.linq.expressions.LambdaExpression = parameters[i];
                        if (lambdaExpression != null)
                        {
                            parameters[i] = lambdaExpression.Compile();
                        }
                    }
                    i++;
                }
            } //end for
            if (!argumentsMatch)
            {
                continue;
            }
            return jint.native.JsValue.FromObject(Engine, method.Invoke(thisObject.ToObject(), system.linq.Enumerable.ToArray(parameters)));
        }
        return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "No public methods with the specified arguments were found.");
    }
    private function ProcessParamsArrays(jsArguments:Array<jint.native.JsValue>, methodInfos:Array<system.reflection.MethodInfo>):Array<jint.native.JsValue>
    {
        for (methodInfo in methodInfos)
        {
            var parameters:Array<system.reflection.ParameterInfo> = methodInfo.GetParameters();
            if (!system.linq.Enumerable.Any_IEnumerable_FuncBoolean(parameters, function (p:system.reflection.ParameterInfo):Bool { return system.Attribute.IsDefined_ParameterInfo_Type(p, typeof(system.ParamArrayAttribute)); } ))
            {
                continue;
            }
            var nonParamsArgumentsCount:Int = parameters.length - 1;
            if (jsArguments.length < nonParamsArgumentsCount)
            {
                continue;
            }
            var newArgumentsCollection:Array<jint.native.JsValue> = system.linq.Enumerable.ToList(system.linq.Enumerable.Take(jsArguments, nonParamsArgumentsCount));
            var argsToTransform:Array<jint.native.JsValue> = system.linq.Enumerable.ToList(system.linq.Enumerable.Skip(jsArguments, nonParamsArgumentsCount));
            if (argsToTransform.length == 1 && system.linq.Enumerable.FirstOrDefault(argsToTransform).IsArray())
            {
                continue;
            }
            var jsArray:jint.native.object.ObjectInstance = Engine.JArray.Construct(jint.runtime.Arguments.Empty);
            Engine.JArray.PrototypeObject.Push(jsArray, system.Cs2Hx.ToArray(argsToTransform));
            newArgumentsCollection.push(new jint.native.JsValue().Creator_ObjectInstance(jsArray));
            return system.Cs2Hx.ToArray(newArgumentsCollection);
        }
        return jsArguments;
    }
}
