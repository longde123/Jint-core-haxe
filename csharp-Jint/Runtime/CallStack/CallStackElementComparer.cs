namespace Jint.Runtime.CallStack
{
    using System.Collections.Generic;

    public class CallStackElementComparer: IEqualityComparer<CallStackElement>
    {
        public bool Equals(CallStackElement x, CallStackElement y)
        {
            return x.CallFunction.Equals( y.CallFunction);
        }

        public int GetHashCode(CallStackElement obj)
        {
            return obj.CallFunction.GetHashCode();
        }
    }
}
