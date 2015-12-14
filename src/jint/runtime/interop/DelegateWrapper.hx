package jint.runtime.interop;
using StringTools;
import system.*;
import anonymoustypes.*;

class DelegateWrapper extends jint.native.function.FunctionInstance
{
    private var _d:system.Delegate;
    public function new(engine:jint.Engine, d:system.Delegate)
    {
        super(engine, null, null, false);
        _d = d;
    }
    override public function Call(thisObject:jint.native.JsValue, jsArguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var parameterInfos:Array<system.reflection.ParameterInfo> = _d.Method.GetParameters();
        var delegateContainsParamsArgument:Bool = system.linq.Enumerable.Any_IEnumerable_FuncBoolean(parameterInfos, function (p:system.reflection.ParameterInfo):Bool { return system.Attribute.IsDefined_ParameterInfo_Type(p, typeof(system.ParamArrayAttribute)); } );
        var delegateArgumentsCount:Int = parameterInfos.length;
        var delegateNonParamsArgumentsCount:Int = delegateContainsParamsArgument ? delegateArgumentsCount - 1 : delegateArgumentsCount;
        var jsArgumentsCount:Int = jsArguments.length;
        var jsArgumentsWithoutParamsCount:Int = system.MathCS.Min_Int32_Int32(jsArgumentsCount, delegateNonParamsArgumentsCount);
        var parameters:Array<Dynamic> = [  ];
        { //for
            var i:Int = 0;
            while (i < jsArgumentsWithoutParamsCount)
            {
                var parameterType:system.TypeCS = parameterInfos[i].ParameterType;
                if (parameterType == typeof(jint.native.JsValue))
                {
                    parameters[i] = jsArguments[i];
                }
                else
                {
                    parameters[i] = Engine.ClrTypeConverter.Convert(jsArguments[i].ToObject(), parameterType, system.globalization.CultureInfo.InvariantCulture);
                }
                i++;
            }
        } //end for
        { //for
            var i:Int = jsArgumentsWithoutParamsCount;
            while (i < delegateNonParamsArgumentsCount)
            {
                if (parameterInfos[i].ParameterType.IsValueType)
                {
                    parameters[i] = system.Activator.CreateInstance_Type(parameterInfos[i].ParameterType);
                }
                else
                {
                    parameters[i] = null;
                }
                i++;
            }
        } //end for
        if (delegateContainsParamsArgument)
        {
            var paramsArgumentIndex:Int = delegateArgumentsCount - 1;
            var paramsCount:Int = system.MathCS.Max_Int32_Int32(0, jsArgumentsCount - delegateNonParamsArgumentsCount);
            var paramsParameter:Array<Dynamic> = [  ];
            var paramsParameterType:system.TypeCS = parameterInfos[paramsArgumentIndex].ParameterType.GetElementType();
            { //for
                var i:Int = paramsArgumentIndex;
                while (i < jsArgumentsCount)
                {
                    var paramsIndex:Int = i - paramsArgumentIndex;
                    if (paramsParameterType == typeof(jint.native.JsValue))
                    {
                        paramsParameter[paramsIndex] = jsArguments[i];
                    }
                    else
                    {
                        paramsParameter[paramsIndex] = Engine.ClrTypeConverter.Convert(jsArguments[i].ToObject(), paramsParameterType, system.globalization.CultureInfo.InvariantCulture);
                    }
                    i++;
                }
            } //end for
            parameters[paramsArgumentIndex] = paramsParameter;
        }
        return jint.native.JsValue.FromObject(Engine, _d.DynamicInvoke(parameters));
    }
}
