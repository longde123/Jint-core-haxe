package jint.native.object;
using StringTools;
import system.*;
import anonymoustypes.*;

class ObjectConstructor extends jint.native.functions.FunctionInstance implements jint.native.IConstructor
{
    private var _engine:jint.Engine;
    public function new(engine:jint.Engine)
    {
        super(engine, null, null, false);
        _engine = engine;
    }
    public static function CreateObjectConstructor(engine:jint.Engine):jint.native.object.ObjectConstructor
    {
        var obj:jint.native.object.ObjectConstructor = new jint.native.object.ObjectConstructor(engine);
        obj.Extensible = true;
        obj.PrototypeObject = jint.native.object.ObjectPrototype.CreatePrototypeObject(engine, obj);
        obj.FastAddProperty("length", 1, false, false, false);
        obj.FastAddProperty("prototype", obj.PrototypeObject, false, false, false);
        return obj;
    }
    public function Configure():Void
    {
        Prototype = Engine.JFunction.PrototypeObject;
        FastAddProperty("getPrototypeOf", new jint.runtime.interop.ClrFunctionInstance(Engine, GetPrototypeOf, 1), true, false, true);
        FastAddProperty("getOwnPropertyDescriptor", new jint.runtime.interop.ClrFunctionInstance(Engine, GetOwnPropertyDescriptor, 2), true, false, true);
        FastAddProperty("getOwnPropertyNames", new jint.runtime.interop.ClrFunctionInstance(Engine, GetOwnPropertyNames, 1), true, false, true);
        FastAddProperty("create", new jint.runtime.interop.ClrFunctionInstance(Engine, Create, 2), true, false, true);
        FastAddProperty("defineProperty", new jint.runtime.interop.ClrFunctionInstance(Engine, DefineProperty, 3), true, false, true);
        FastAddProperty("defineProperties", new jint.runtime.interop.ClrFunctionInstance(Engine, DefineProperties, 2), true, false, true);
        FastAddProperty("seal", new jint.runtime.interop.ClrFunctionInstance(Engine, Seal, 1), true, false, true);
        FastAddProperty("freeze", new jint.runtime.interop.ClrFunctionInstance(Engine, Freeze, 1), true, false, true);
        FastAddProperty("preventExtensions", new jint.runtime.interop.ClrFunctionInstance(Engine, PreventExtensions, 1), true, false, true);
        FastAddProperty("isSealed", new jint.runtime.interop.ClrFunctionInstance(Engine, IsSealed, 1), true, false, true);
        FastAddProperty("isFrozen", new jint.runtime.interop.ClrFunctionInstance(Engine, IsFrozen, 1), true, false, true);
        FastAddProperty("isExtensible", new jint.runtime.interop.ClrFunctionInstance(Engine, IsExtensible, 1), true, false, true);
        FastAddProperty("keys", new jint.runtime.interop.ClrFunctionInstance(Engine, Keys, 1), true, false, true);
    }
    public var PrototypeObject:jint.native.object.ObjectPrototype;
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        if (arguments.length == 0)
        {
            return Construct(arguments);
        }
        if (arguments[0].Equals(jint.native.Null.Instance) || arguments[0].Equals(jint.native.Undefined.Instance))
        {
            return Construct(arguments);
        }
        return jint.runtime.TypeConverter.ToObject(_engine, arguments[0]);
    }
    public function Construct(arguments:Array<jint.native.JsValue>):jint.native.object.ObjectInstance
    {
        if (arguments.length > 0)
        {
            var value:jint.native.JsValue = arguments[0];
            var valueObj:jint.native.object.ObjectInstance = value.TryCast();
            if (valueObj != null)
            {
                return valueObj;
            }
            var type:Int = value.Type;
            if (type == jint.runtime.Types.String || type == jint.runtime.Types.Number || type == jint.runtime.Types.Boolean)
            {
                return jint.runtime.TypeConverter.ToObject(_engine, value);
            }
        }
        var obj:jint.native.object.ObjectInstance = new jint.native.object.ObjectInstance(_engine);
        return obj;
    }
    public function GetPrototypeOf(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var oArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var o:jint.native.object.ObjectInstance = oArg.TryCast();
        if (o == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        return Cs2Hx.Coalesce(o.Prototype, jint.native.Null.Instance);
    }
    public function GetOwnPropertyDescriptor(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var oArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var o:jint.native.object.ObjectInstance = oArg.TryCast();
        if (o == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        var p:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 1);
        var name:String = jint.runtime.TypeConverter.toString(p);
        var desc:jint.runtime.descriptors.PropertyDescriptor = o.GetOwnProperty(name);
        return jint.runtime.descriptors.PropertyDescriptor.FromPropertyDescriptor(Engine, desc);
    }
    public function GetOwnPropertyNames(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var oArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var o:jint.native.object.ObjectInstance = oArg.TryCast();
        if (o == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        var array:jint.native.object.ObjectInstance = Engine.JArray.Construct(jint.runtime.Arguments.Empty);
        var n:Int = 0;
        var s:jint.native.string.StringInstance = (Std.is(o, jint.native.string.StringInstance) ? cast(o, jint.native.string.StringInstance) : null);
        if (s != null)
        {
            { //for
                var i:Int = 0;
                while (i < s.PrimitiveValue.AsString().length)
                {
                    array.DefineOwnProperty(Std.string(n), new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(Std.string(i), new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
                    n++;
                    i++;
                }
            } //end for
        }
        for (p in o.GetOwnProperties())
        {
            array.DefineOwnProperty(Std.string(n), new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(p.Key, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
            n++;
        }
        return array;
    }
    public function Create(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var oArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var o:jint.native.object.ObjectInstance = oArg.TryCast();
        if (o == null && !oArg.Equals(jint.native.Null.Instance))
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        var obj:jint.native.object.ObjectInstance = Engine.JObject.Construct(jint.runtime.Arguments.Empty);
        obj.Prototype = o;
        var properties:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 1);
        if (!properties.Equals(jint.native.Undefined.Instance))
        {
            DefineProperties(thisObject, [ obj, properties ]);
        }
        return obj;
    }
    public function DefineProperty(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var oArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var o:jint.native.object.ObjectInstance = oArg.TryCast();
        if (o == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        var p:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 1);
        var name:String = jint.runtime.TypeConverter.toString(p);
        var attributes:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 2);
        var desc:jint.runtime.descriptors.PropertyDescriptor = jint.runtime.descriptors.PropertyDescriptor.ToPropertyDescriptor(Engine, attributes);
        o.DefineOwnProperty(name, desc, true);
        return o;
    }
    public function DefineProperties(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var oArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var o:jint.native.object.ObjectInstance = oArg.TryCast();
        if (o == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        var properties:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 1);
        var props:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, properties);
        var descriptors:Array<system.collections.generic.KeyValuePair<String, jint.runtime.descriptors.PropertyDescriptor>> = new Array<system.collections.generic.KeyValuePair<String, jint.runtime.descriptors.PropertyDescriptor>>();
        for (p in props.GetOwnProperties())
        {
            if (!p.Value.Enumerable.HasValue || !p.Value.Enumerable.Value)
            {
                continue;
            }
            var descObj:jint.native.JsValue = props.Get(p.Key);
            var desc:jint.runtime.descriptors.PropertyDescriptor = jint.runtime.descriptors.PropertyDescriptor.ToPropertyDescriptor(Engine, descObj);
            descriptors.push(new system.collections.generic.KeyValuePair<String, jint.runtime.descriptors.PropertyDescriptor>(p.Key, desc));
        }
        for (pair in descriptors)
        {
            o.DefineOwnProperty(pair.Key, pair.Value, true);
        }
        return o;
    }
    public function Seal(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var oArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var o:jint.native.object.ObjectInstance = oArg.TryCast();
        if (o == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        for (prop in o.GetOwnProperties())
        {
            if (prop.Value.Configurable.HasValue && prop.Value.Configurable.Value)
            {
                prop.Value.Configurable = new Nullable_Bool(false);
            }
            o.DefineOwnProperty(prop.Key, prop.Value, true);
        }
        o.Extensible = false;
        return o;
    }
    public function Freeze(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var oArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var o:jint.native.object.ObjectInstance = oArg.TryCast();
        if (o == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        var keys:Array<String> = system.linq.Enumerable.Select(o.GetOwnProperties(), function (x:system.collections.generic.KeyValuePair<String, jint.runtime.descriptors.PropertyDescriptor>):String { return x.Key; } );
        for (p in keys)
        {
            var desc:jint.runtime.descriptors.PropertyDescriptor = o.GetOwnProperty(p);
            if (desc.IsDataDescriptor())
            {
                if (desc.Writable.HasValue && desc.Writable.Value)
                {
                    desc.Writable = new Nullable_Bool(false);
                }
            }
            if (desc.Configurable.HasValue && desc.Configurable.Value)
            {
                desc.Configurable = new Nullable_Bool(false);
            }
            o.DefineOwnProperty(p, desc, true);
        }
        o.Extensible = false;
        return o;
    }
    public function PreventExtensions(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var oArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var o:jint.native.object.ObjectInstance = oArg.TryCast();
        if (o == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        o.Extensible = false;
        return o;
    }
    public function IsSealed(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var oArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var o:jint.native.object.ObjectInstance = oArg.TryCast();
        if (o == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        for (prop in o.GetOwnProperties())
        {
            if (prop.Value.Configurable.Value == true)
            {
                return false;
            }
        }
        if (o.Extensible == false)
        {
            return true;
        }
        return false;
    }
    public function IsFrozen(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var oArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var o:jint.native.object.ObjectInstance = oArg.TryCast();
        if (o == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        for (p in system.linq.Enumerable.Select(o.GetOwnProperties(), function (x:system.collections.generic.KeyValuePair<String, jint.runtime.descriptors.PropertyDescriptor>):String { return x.Key; } ))
        {
            var desc:jint.runtime.descriptors.PropertyDescriptor = o.GetOwnProperty(p);
            if (desc.IsDataDescriptor())
            {
                if (desc.Writable.HasValue && desc.Writable.Value)
                {
                    return false;
                }
            }
            if (desc.Configurable.HasValue && desc.Configurable.Value)
            {
                return false;
            }
        }
        if (o.Extensible == false)
        {
            return true;
        }
        return false;
    }
    public function IsExtensible(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var oArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var o:jint.native.object.ObjectInstance = oArg.TryCast();
        if (o == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        return o.Extensible;
    }
    public function Keys(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var oArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var o:jint.native.object.ObjectInstance = oArg.TryCast();
        if (o == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        var enumerableProperties:Array<system.collections.generic.KeyValuePair<String, jint.runtime.descriptors.PropertyDescriptor>> = system.linq.Enumerable.ToArray(system.linq.Enumerable.Where(o.GetOwnProperties(), function (x:system.collections.generic.KeyValuePair<String, jint.runtime.descriptors.PropertyDescriptor>):Bool { return x.Value.Enumerable.HasValue && x.Value.Enumerable.Value; } ));
        var n:Int = enumerableProperties.length;
        var array:jint.native.object.ObjectInstance = Engine.JArray.Construct([ n ]);
        var index:Int = 0;
        for (prop in enumerableProperties)
        {
            var p:String = prop.Key;
            array.DefineOwnProperty(jint.runtime.TypeConverter.toString(index), new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(p, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
            index++;
        }
        return array;
    }
}
