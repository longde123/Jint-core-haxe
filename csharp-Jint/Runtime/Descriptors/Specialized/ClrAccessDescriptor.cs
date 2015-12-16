using System;
using Jint.Native;
using Jint.Runtime.Interop;

namespace Jint.Runtime.Descriptors.Specialized
{
    public sealed class ClrAccessDescriptor : PropertyDescriptor
    {
      
        public ClrAccessDescriptor   (Engine engine, Func<JsValue, JsValue> get, Action<JsValue, JsValue> set)
        {
           Creator(
                  jget: new GetterFunctionInstance(engine, get),
                  jset: set == null ? Native.Undefined.Instance : new SetterFunctionInstance(engine, set)
                  );

     
        }
    }
}
