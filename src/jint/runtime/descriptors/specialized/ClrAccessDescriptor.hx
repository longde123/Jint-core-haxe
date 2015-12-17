package jint.runtime.descriptors.specialized;
using StringTools;
import system.*;
import anonymoustypes.*;

class ClrAccessDescriptor extends jint.runtime.descriptors.PropertyDescriptor
{
    public function new(engine:jint.Engine, _get:(jint.native.JsValue -> jint.native.JsValue), _set:(jint.native.JsValue -> jint.native.JsValue -> Void))
    {
        super();
        Creator_JsValue_JsValue_NullableBoolean_NullableBoolean(new jint.runtime.interop.GetterFunctionInstance(engine, _get), _set == null ? jint.native.Undefined.Instance : new jint.runtime.interop.SetterFunctionInstance(engine, _set));
    }
}
