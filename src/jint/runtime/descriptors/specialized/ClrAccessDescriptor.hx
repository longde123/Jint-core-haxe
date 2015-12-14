package jint.runtime.descriptors.specialized;
using StringTools;
import system.*;
import anonymoustypes.*;

class ClrAccessDescriptor extends jint.runtime.descriptors.PropertyDescriptor
{
    public function new(engine:jint.Engine, get:(jint.native.JsValue -> jint.native.JsValue), set:(jint.native.JsValue -> jint.native.JsValue -> Void))
    {
        super();
        Creator_JsValue_JsValue_NullableBoolean_NullableBoolean(new jint.runtime.interop.GetterFunctionInstance(engine, get), set == null ? jint.native.Undefined.Instance : new jint.runtime.interop.SetterFunctionInstance(engine, set));
    }
}
