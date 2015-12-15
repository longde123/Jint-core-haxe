using System;
using Jint.Native;
using Jint.Native.Functions;

namespace Jint.Runtime.Interop
{
    /// <summary>
    /// Wraps a Clr method into a FunctionInstance
    /// </summary>
    public sealed class ClrFunctionInstance : FunctionInstance
    {
        private readonly Func<JsValue, JsValue[], JsValue> _func;

        public ClrFunctionInstance(Engine engine, Func<JsValue, JsValue[], JsValue> func, int length=0)
            : base(engine, null, null, false)
        {
            _func = func;
            Prototype = engine.Function.PrototypeObject; 
            FastAddProperty("length", length, false, false, false);
            Extensible = true;
        }

    
        public override JsValue Call(JsValue thisObject, JsValue[] arguments)
        {
            try
            {
                var result = _func(thisObject, arguments);
                return result;
            }
            catch (InvalidCastException)
            {
                throw new JavaScriptException().Creator(Engine.TypeError);
            }
        }
    }
}
