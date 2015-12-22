package jint.native.array;
using StringTools;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
class ArrayPrototype extends jint.native.array.ArrayInstance
{
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    public static function CreatePrototypeObject(engine:jint.Engine, arrayConstructor:jint.native.array.ArrayConstructor):jint.native.array.ArrayPrototype
    {
        var obj:jint.native.array.ArrayPrototype = new jint.native.array.ArrayPrototype(engine);
        obj.Extensible = true;
        obj.Prototype = engine.JObject.PrototypeObject;
        obj.FastAddProperty("length", 0, true, false, false);
        obj.FastAddProperty("constructor", arrayConstructor, true, false, true);
        return obj;
    }
    public function Configure():Void
    {
        FastAddProperty("toString", new jint.runtime.interop.ClrFunctionInstance(Engine, ToString, 0), true, false, true);
        FastAddProperty("toLocaleString", new jint.runtime.interop.ClrFunctionInstance(Engine, ToLocaleString), true, false, true);
        FastAddProperty("concat", new jint.runtime.interop.ClrFunctionInstance(Engine, Concat, 1), true, false, true);
        FastAddProperty("join", new jint.runtime.interop.ClrFunctionInstance(Engine, Join, 1), true, false, true);
        FastAddProperty("pop", new jint.runtime.interop.ClrFunctionInstance(Engine, Pop), true, false, true);
        FastAddProperty("push", new jint.runtime.interop.ClrFunctionInstance(Engine, Push, 1), true, false, true);
        FastAddProperty("reverse", new jint.runtime.interop.ClrFunctionInstance(Engine, Reverse), true, false, true);
        FastAddProperty("shift", new jint.runtime.interop.ClrFunctionInstance(Engine, Shift), true, false, true);
        FastAddProperty("slice", new jint.runtime.interop.ClrFunctionInstance(Engine, Slice, 2), true, false, true);
        FastAddProperty("sort", new jint.runtime.interop.ClrFunctionInstance(Engine, Sort, 1), true, false, true);
        FastAddProperty("splice", new jint.runtime.interop.ClrFunctionInstance(Engine, Splice, 2), true, false, true);
        FastAddProperty("unshift", new jint.runtime.interop.ClrFunctionInstance(Engine, Unshift, 1), true, false, true);
        FastAddProperty("indexOf", new jint.runtime.interop.ClrFunctionInstance(Engine, IndexOf, 1), true, false, true);
        FastAddProperty("lastIndexOf", new jint.runtime.interop.ClrFunctionInstance(Engine, LastIndexOf, 1), true, false, true);
        FastAddProperty("every", new jint.runtime.interop.ClrFunctionInstance(Engine, Every, 1), true, false, true);
        FastAddProperty("some", new jint.runtime.interop.ClrFunctionInstance(Engine, Some, 1), true, false, true);
        FastAddProperty("forEach", new jint.runtime.interop.ClrFunctionInstance(Engine, ForEach, 1), true, false, true);
        FastAddProperty("map", new jint.runtime.interop.ClrFunctionInstance(Engine, Map, 1), true, false, true);
        FastAddProperty("filter", new jint.runtime.interop.ClrFunctionInstance(Engine, Filter, 1), true, false, true);
        FastAddProperty("reduce", new jint.runtime.interop.ClrFunctionInstance(Engine, Reduce, 1), true, false, true);
        FastAddProperty("reduceRight", new jint.runtime.interop.ClrFunctionInstance(Engine, ReduceRight, 1), true, false, true);
    }
    private function LastIndexOf(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var lenValue:jint.native.JsValue = o.Get("length");
        var len:Int = jint.runtime.TypeConverter.ToUint32(lenValue);
        if (len == 0)
        {
            return -1;
        }
        var n:Float = arguments.length > 1 ? jint.runtime.TypeConverter.ToInteger(arguments[1]) : len - 1;
        var k:Float;
        if (n >= 0)
        {
            k = system.MathCS.Min_Double_Double(n, len - 1);
        }
        else
        {
            k = len - system.MathCS.Abs_Double(n);
        }
        var searchElement:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        { //for
            while (k >= 0)
            {
                var kString:String = jint.runtime.TypeConverter.toString(k);
                var kPresent:Bool = o.HasProperty(kString);
                if (kPresent)
                {
                    var elementK:jint.native.JsValue = o.Get(kString);
                    var same:Bool = jint.runtime.ExpressionInterpreter.StrictlyEqual(elementK, searchElement);
                    if (same)
                    {
                        return k;
                    }
                }
                k--;
            }
        } //end for
        return -1;
    }
    private function Reduce(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var callbackfn:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var initialValue:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 1);
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var lenValue:jint.native.JsValue = o.Get("length");
        var len:Int = jint.runtime.TypeConverter.ToUint32(lenValue);
        var callable:jint.native.ICallable = callbackfn.TryCast(function (x:jint.native.JsValue):Void
        {
            throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "Argument must be callable");
        }
        );
        if (len == 0 && arguments.length < 2)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        var k:Int = 0;
        var accumulator:jint.native.JsValue = jint.native.Undefined.Instance;
        if (arguments.length > 1)
        {
            accumulator = initialValue;
        }
        else
        {
            var kPresent:Bool = false;
            while (kPresent == false && k < len)
            {
                var pk:String = Std.string(k);
                kPresent = o.HasProperty(pk);
                if (kPresent)
                {
                    accumulator = o.Get(pk);
                }
                k++;
            }
            if (kPresent == false)
            {
                return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
            }
        }
        while (k < len)
        {
            var pk:String = Std.string(k);
            var kPresent:Bool = o.HasProperty(pk);
            if (kPresent)
            {
                var kvalue:jint.native.JsValue = o.Get(pk);
                accumulator = callable.Call(jint.native.Undefined.Instance, [ accumulator, kvalue, k, o ]);
            }
            k++;
        }
        return accumulator;
    }
    private function Filter(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var callbackfn:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var thisArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 1);
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var lenValue:jint.native.JsValue = o.Get("length");
        var len:Int = jint.runtime.TypeConverter.ToUint32(lenValue);
        var callable:jint.native.ICallable = callbackfn.TryCast(function (x:jint.native.JsValue):Void
        {
            throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "Argument must be callable");
        }
        );
        var a:jint.native.array.ArrayInstance = cast(Engine.JArray.Construct(jint.runtime.Arguments.Empty), jint.native.array.ArrayInstance);
        var to:Int = 0;
        { //for
            var k:Int = 0;
            while (k < len)
            {
                var pk:String = Std.string(k);
                var kpresent:Bool = o.HasProperty(pk);
                if (kpresent)
                {
                    var kvalue:jint.native.JsValue = o.Get(pk);
                    var selected:jint.native.JsValue = callable.Call(thisArg, [ kvalue, k, o ]);
                    if (jint.runtime.TypeConverter.ToBoolean(selected))
                    {
                        a.DefineOwnProperty(Std.string(to), new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(kvalue, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
                        to++;
                    }
                }
                k++;
            }
        } //end for
        return a;
    }
    private function Map(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var callbackfn:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var thisArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 1);
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var lenValue:jint.native.JsValue = o.Get("length");
        var len:Int = jint.runtime.TypeConverter.ToUint32(lenValue);
        var callable:jint.native.ICallable = callbackfn.TryCast(function (x:jint.native.JsValue):Void
        {
            throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "Argument must be callable");
        }
        );
        var a:jint.native.object.ObjectInstance = Engine.JArray.Construct([ len ]);
        { //for
            var k:Int = 0;
            while (k < len)
            {
                var pk:String = Std.string(k);
                var kpresent:Bool = o.HasProperty(pk);
                if (kpresent)
                {
                    var kvalue:jint.native.JsValue = o.Get(pk);
                    var mappedValue:jint.native.JsValue = callable.Call(thisArg, [ kvalue, k, o ]);
                    a.DefineOwnProperty(pk, new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(mappedValue, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
                }
                k++;
            }
        } //end for
        return a;
    }
    private function ForEach(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var callbackfn:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var thisArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 1);
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var lenValue:jint.native.JsValue = o.Get("length");
        var len:Int = jint.runtime.TypeConverter.ToUint32(lenValue);
        var callable:jint.native.ICallable = callbackfn.TryCast(function (x:jint.native.JsValue):Void
        {
            throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "Argument must be callable");
        }
        );
        { //for
            var k:Int = 0;
            while (k < len)
            {
                var pk:String = Std.string(k);
                var kpresent:Bool = o.HasProperty(pk);
                if (kpresent)
                {
                    var kvalue:jint.native.JsValue = o.Get(pk);
                    callable.Call(thisArg, [ kvalue, k, o ]);
                }
                k++;
            }
        } //end for
        return jint.native.Undefined.Instance;
    }
    private function Some(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var callbackfn:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var thisArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 1);
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var lenValue:jint.native.JsValue = o.Get("length");
        var len:Int = jint.runtime.TypeConverter.ToUint32(lenValue);
        var callable:jint.native.ICallable = callbackfn.TryCast(function (x:jint.native.JsValue):Void
        {
            throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "Argument must be callable");
        }
        );
        { //for
            var k:Int = 0;
            while (k < len)
            {
                var pk:String = Std.string(k);
                var kpresent:Bool = o.HasProperty(pk);
                if (kpresent)
                {
                    var kvalue:jint.native.JsValue = o.Get(pk);
                    var testResult:jint.native.JsValue = callable.Call(thisArg, [ kvalue, k, o ]);
                    if (jint.runtime.TypeConverter.ToBoolean(testResult))
                    {
                        return true;
                    }
                }
                k++;
            }
        } //end for
        return false;
    }
    private function Every(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var callbackfn:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var thisArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 1);
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var lenValue:jint.native.JsValue = o.Get("length");
        var len:Int = jint.runtime.TypeConverter.ToUint32(lenValue);
        var callable:jint.native.ICallable = callbackfn.TryCast(function (x:jint.native.JsValue):Void
        {
            throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "Argument must be callable");
        }
        );
        { //for
            var k:Int = 0;
            while (k < len)
            {
                var pk:String = Std.string(k);
                var kpresent:Bool = o.HasProperty(pk);
                if (kpresent)
                {
                    var kvalue:jint.native.JsValue = o.Get(pk);
                    var testResult:jint.native.JsValue = callable.Call(thisArg, [ kvalue, k, o ]);
                    if (false == jint.runtime.TypeConverter.ToBoolean(testResult))
                    {
                        return jint.native.JsValue.False;
                    }
                }
                k++;
            }
        } //end for
        return jint.native.JsValue.True;
    }
    private function IndexOf(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var lenValue:jint.native.JsValue = o.Get("length");
        var len:Int = jint.runtime.TypeConverter.ToUint32(lenValue);
        if (len == 0)
        {
            return -1;
        }
        var n:Float = arguments.length > 1 ? jint.runtime.TypeConverter.ToInteger(arguments[1]) : 0;
        if (n >= len)
        {
            return -1;
        }
        var k:Float;
        if (n >= 0)
        {
            k = n;
        }
        else
        {
            k = len - system.MathCS.Abs_Double(n);
            if (k < 0)
            {
                k = 0;
            }
        }
        var searchElement:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        { //for
            while (k < len)
            {
                var kString:String = jint.runtime.TypeConverter.toString(k);
                var kPresent:Bool = o.HasProperty(kString);
                if (kPresent)
                {
                    var elementK:jint.native.JsValue = o.Get(kString);
                    var same:Bool = jint.runtime.ExpressionInterpreter.StrictlyEqual(elementK, searchElement);
                    if (same)
                    {
                        return k;
                    }
                }
                k++;
            }
        } //end for
        return -1;
    }
    private function Splice(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var start:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var deleteCount:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 1);
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var a:jint.native.object.ObjectInstance = Engine.JArray.Construct(jint.runtime.Arguments.Empty);
        var lenVal:jint.native.JsValue = o.Get("length");
        var len:Int = jint.runtime.TypeConverter.ToUint32(lenVal);
        var relativeStart:Float = jint.runtime.TypeConverter.ToInteger(start);
        var actualStart:Int;
        if (relativeStart < 0)
        {
            actualStart = Std.int(system.MathCS.Max_Double_Double(len + relativeStart, 0));
        }
        else
        {
            actualStart = Std.int(system.MathCS.Min_Double_Double(relativeStart, len));
        }
        var actualDeleteCount:Float = system.MathCS.Min_Double_Double(system.MathCS.Max_Double_Double(jint.runtime.TypeConverter.ToInteger(deleteCount), 0), len - actualStart);
        { //for
            var k:Int = 0;
            while (k < actualDeleteCount)
            {
                var from:String = Std.string(actualStart + k);
                var fromPresent:Bool = o.HasProperty(from);
                if (fromPresent)
                {
                    var fromValue:jint.native.JsValue = o.Get(from);
                    a.DefineOwnProperty(Std.string(k), new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(fromValue, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
                }
                k++;
            }
        } //end for
        var items:Array<jint.native.JsValue> = system.linq.Enumerable.ToArray(system.linq.Enumerable.Skip(arguments, 2));
        if (items.length < actualDeleteCount)
        {
            { //for
                var k:Int = actualStart;
                while (k < len - actualDeleteCount)
                {
                    var from:String = Std.string(k + actualDeleteCount);
                    var to:String = Std.string(k + items.length);
                    var fromPresent:Bool = o.HasProperty(from);
                    if (fromPresent)
                    {
                        var fromValue:jint.native.JsValue = o.Get(from);
                        o.Put(to, fromValue, true);
                    }
                    else
                    {
                        o.Delete(to, true);
                    }
                    k++;
                }
            } //end for
            { //for
                var k:Int = len;
                while (k > len - actualDeleteCount + items.length)
                {
                    o.Delete(Std.string(k - 1), true);
                    k--;
                }
            } //end for
        }
        else if (items.length > actualDeleteCount)
        {
            { //for
                var k:Float = len - actualDeleteCount;
                while (k > actualStart)
                {
                    var from:String = Std.string(k + actualDeleteCount - 1);
                    var to:String = Std.string(k + items.length - 1);
                    var fromPresent:Bool = o.HasProperty(from);
                    if (fromPresent)
                    {
                        var fromValue:jint.native.JsValue = o.Get(from);
                        o.Put(to, fromValue, true);
                    }
                    else
                    {
                        o.Delete(to, true);
                    }
                    k--;
                }
            } //end for
        }
        { //for
            var k:Int = 0;
            while (k < items.length)
            {
                var e:jint.native.JsValue = items[k];
                o.Put(Std.string(k + actualStart), e, true);
                k++;
            }
        } //end for
        o.Put("length", len - actualDeleteCount + items.length, true);
        return a;
    }
    private function Unshift(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var lenVal:jint.native.JsValue = o.Get("length");
        var len:Int = jint.runtime.TypeConverter.ToUint32(lenVal);
        var argCount:Int = arguments.length;
        { //for
            var k:Int = len;
            while (k > 0)
            {
                var from:String = Std.string(k - 1);
                var to:String = Std.string(k + argCount - 1);
                var fromPresent:Bool = o.HasProperty(from);
                if (fromPresent)
                {
                    var fromValue:jint.native.JsValue = o.Get(from);
                    o.Put(to, fromValue, true);
                }
                else
                {
                    o.Delete(to, true);
                }
                k--;
            }
        } //end for
        { //for
            var j:Int = 0;
            while (j < argCount)
            {
                o.Put(Std.string(j), arguments[j], true);
                j++;
            }
        } //end for
        o.Put("length", len + argCount, true);
        return len + argCount;
    }
    private function Sort(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        if (!thisObj.IsObject())
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "Array.prorotype.sort can only be applied on objects");
        }
        var obj:jint.native.object.ObjectInstance = thisObj.AsObject();
        var len:jint.native.JsValue = obj.Get("length");
        var lenVal:Int = jint.runtime.TypeConverter.ToInt32(len);
        if (lenVal <= 1)
        {
            return obj;
        }
        var compareArg:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var compareFn:jint.native.ICallable = null;
        if (!compareArg.Equals(jint.native.Undefined.Instance))
        {
            compareFn = compareArg.TryCast(function (x:jint.native.JsValue):Void
            {
                throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "The sort argument must be a function");
            }
            );
        }
        var comparer:(jint.native.JsValue -> jint.native.JsValue -> Int) = function (x:jint.native.JsValue, y:jint.native.JsValue):Int
        {
            if (x.Equals(jint.native.Undefined.Instance) && y.Equals(jint.native.Undefined.Instance))
            {
                return 0;
            }
            if (x.Equals(jint.native.Undefined.Instance))
            {
                return 1;
            }
            if (y.Equals(jint.native.Undefined.Instance))
            {
                return -1;
            }
            if (compareFn != null)
            {
                var s:Float = jint.runtime.TypeConverter.ToNumber(compareFn.Call(jint.native.Undefined.Instance, [ x, y ]));
                if (s < 0)
                {
                    return -1;
                }
                if (s > 0)
                {
                    return 1;
                }
                return 0;
            }
            var xString:String = jint.runtime.TypeConverter.toString(x);
            var yString:String = jint.runtime.TypeConverter.toString(y);
            var r:Int = system.String.CompareOrdinal(xString, yString);
            return r;
        }
        ;
        var array:Array<jint.native.JsValue> = system.linq.Enumerable.ToArray(system.linq.Enumerable.Select(system.linq.Enumerable.Range(0, lenVal), function (i:Int):jint.native.JsValue { return obj.Get(Std.string(i)); } ));
        try
        {
            system.Array.sort(array, comparer);
        }
        catch (e:system.InvalidOperationException)
        {
            return throw e.InnerException;
        }
        for (i in system.linq.Enumerable.Range(0, lenVal))
        {
            obj.Put(Std.string(i), array[i], false);
        }
        return obj;
    }
    private function Slice(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var start:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var end:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 1);
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var a:jint.native.object.ObjectInstance = Engine.JArray.Construct(jint.runtime.Arguments.Empty);
        var lenVal:jint.native.JsValue = o.Get("length");
        var len:Int = jint.runtime.TypeConverter.ToUint32(lenVal);
        var relativeStart:Float = jint.runtime.TypeConverter.ToInteger(start);
        var k:Int;
        if (relativeStart < 0)
        {
            k = Std.int(system.MathCS.Max_Double_Double(len + relativeStart, 0));
        }
        else
        {
            k = Std.int(system.MathCS.Min_Double_Double(jint.runtime.TypeConverter.ToInteger(start), len));
        }
        var final:Int;
        if (end.Equals(jint.native.Undefined.Instance))
        {
            final = jint.runtime.TypeConverter.ToUint32(len);
        }
        else
        {
            var relativeEnd:Float = jint.runtime.TypeConverter.ToInteger(end);
            if (relativeEnd < 0)
            {
                final = Std.int(system.MathCS.Max_Double_Double(len + relativeEnd, 0));
            }
            else
            {
                final = Std.int(system.MathCS.Min_Double_Double(jint.runtime.TypeConverter.ToInteger(relativeEnd), len));
            }
        }
        var n:Int = 0;
        { //for
            while (k < final)
            {
                var pk:String = jint.runtime.TypeConverter.toString(k);
                var kPresent:Bool = o.HasProperty(pk);
                if (kPresent)
                {
                    var kValue:jint.native.JsValue = o.Get(pk);
                    a.DefineOwnProperty(jint.runtime.TypeConverter.toString(n), new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(kValue, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
                }
                n++;
                k++;
            }
        } //end for
        return a;
    }
    private function Shift(thisObj:jint.native.JsValue, arg2:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var lenVal:jint.native.JsValue = o.Get("length");
        var len:Int = jint.runtime.TypeConverter.ToUint32(lenVal);
        if (len == 0)
        {
            o.Put("length", 0, true);
            return jint.native.Undefined.Instance;
        }
        var first:jint.native.JsValue = o.Get("0");
        { //for
            var k:Int = 1;
            while (k < len)
            {
                var from:String = jint.runtime.TypeConverter.toString(k);
                var to:String = jint.runtime.TypeConverter.toString(k - 1);
                var fromPresent:Bool = o.HasProperty(from);
                if (fromPresent)
                {
                    var fromVal:jint.native.JsValue = o.Get(from);
                    o.Put(to, fromVal, true);
                }
                else
                {
                    o.Delete(to, true);
                }
                k++;
            }
        } //end for
        o.Delete(jint.runtime.TypeConverter.toString(len - 1), true);
        o.Put("length", len - 1, true);
        return first;
    }
    private function Reverse(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var lenVal:jint.native.JsValue = o.Get("length");
        var len:Int = jint.runtime.TypeConverter.ToUint32(lenVal);
        var middle:Int = Std.int(system.MathCS.Floor(cast(len, system.Decimal) / 2));
        var lower:Int = 0;
        while (lower != middle)
        {
            var upper:Int = len - lower - 1;
            var upperP:String = jint.runtime.TypeConverter.toString(upper);
            var lowerP:String = jint.runtime.TypeConverter.toString(lower);
            var lowerValue:jint.native.JsValue = o.Get(lowerP);
            var upperValue:jint.native.JsValue = o.Get(upperP);
            var lowerExists:Bool = o.HasProperty(lowerP);
            var upperExists:Bool = o.HasProperty(upperP);
            if (lowerExists && upperExists)
            {
                o.Put(lowerP, upperValue, true);
                o.Put(upperP, lowerValue, true);
            }
            if (!lowerExists && upperExists)
            {
                o.Put(lowerP, upperValue, true);
                o.Delete(upperP, true);
            }
            if (lowerExists && !upperExists)
            {
                o.Delete(lowerP, true);
                o.Put(upperP, lowerValue, true);
            }
            lower++;
        }
        return o;
    }
    private function Join(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var separator:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var lenVal:jint.native.JsValue = o.Get("length");
        var len:Int = jint.runtime.TypeConverter.ToUint32(lenVal);
        if (separator.Equals(jint.native.Undefined.Instance))
        {
            separator = ",";
        }
        var sep:String = jint.runtime.TypeConverter.toString(separator);
        if (len == 0)
        {
            return "";
        }
        var element0:jint.native.JsValue = o.Get("0");
        var r:String = element0.Equals(jint.native.Undefined.Instance) || element0.Equals(jint.native.Null.Instance) ? "" : jint.runtime.TypeConverter.toString(element0);
        { //for
            var k:Int = 1;
            while (k < len)
            {
                var s:String = r + sep;
                var element:jint.native.JsValue = o.Get(Std.string(k));
                var next:String = element.Equals(jint.native.Undefined.Instance) || element.Equals(jint.native.Null.Instance) ? "" : jint.runtime.TypeConverter.toString(element);
                r = s + next;
                k++;
            }
        } //end for
        return r;
    }
    private function ToLocaleString(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var array:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var arrayLen:jint.native.JsValue = array.Get("length");
        var len:Int = jint.runtime.TypeConverter.ToUint32(arrayLen);
        var separator:String = ",";
        if (len == 0)
        {
            return "";
        }
        var r:jint.native.JsValue;
        var firstElement:jint.native.JsValue = array.Get("0");
        if (firstElement.Equals(jint.native.Null.Instance) || firstElement.Equals(jint.native.Undefined.Instance))
        {
            r = "";
        }
        else
        {
            var elementObj:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, firstElement);
            var func:jint.native.ICallable = elementObj.Get("toLocaleString").TryCast(function (x:jint.native.JsValue):Void
            {
                throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
            }
            );
            r = func.Call(elementObj, jint.runtime.Arguments.Empty);
        }
        { //for
            var k:Int = 1;
            while (k < len)
            {
                var s:String = r + separator;
                var nextElement:jint.native.JsValue = array.Get(Std.string(k));
                if (nextElement.Equals(jint.native.Undefined.Instance) || nextElement.Equals(jint.native.Null.Instance))
                {
                    r = "";
                }
                else
                {
                    var elementObj:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, nextElement);
                    var func:jint.native.ICallable = elementObj.Get("toLocaleString").TryCast(function (x:jint.native.JsValue):Void
                    {
                        throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
                    }
                    );
                    r = func.Call(elementObj, jint.runtime.Arguments.Empty);
                }
                r = s + r;
                k++;
            }
        } //end for
        return r;
    }
    private function Concat(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var a:jint.native.object.ObjectInstance = Engine.JArray.Construct(jint.runtime.Arguments.Empty);
        var n:Int = 0;
        var items:Array<jint.native.JsValue> = new Array<jint.native.JsValue>();
        system.Cs2Hx.AddRange(items, arguments);
        for (e in items)
        {
            var eArray:jint.native.array.ArrayInstance = e.TryCast();
            if (eArray != null)
            {
                var len:Int = jint.runtime.TypeConverter.ToUint32(eArray.Get("length"));
                { //for
                    var k:Int = 0;
                    while (k < len)
                    {
                        var p:String = Std.string(k);
                        var exists:Bool = eArray.HasProperty(p);
                        if (exists)
                        {
                            var subElement:jint.native.JsValue = eArray.Get(p);
                            a.DefineOwnProperty(jint.runtime.TypeConverter.toString(n), new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(subElement, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
                        }
                        n++;
                        k++;
                    }
                } //end for
            }
            else
            {
                a.DefineOwnProperty(jint.runtime.TypeConverter.toString(n), new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(e, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
                n++;
            }
        }
        a.DefineOwnProperty("length", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(n, new Nullable_Bool(), new Nullable_Bool(), new Nullable_Bool()), false);
        return a;
    }
    override private function toString(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var array:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var func:jint.native.ICallable;
        func = array.Get("join").TryCast(function (x:jint.native.JsValue):Void
        {
            func = Engine.JObject.PrototypeObject.Get("toString").TryCast(function (y:jint.native.JsValue):Void
            {
                throw new system.ArgumentException();
            }
            );
        }
        );
        return func.Call(array, jint.runtime.Arguments.Empty);
    }
    private function ReduceRight(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var callbackfn:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var initialValue:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 1);
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObj);
        var lenValue:jint.native.JsValue = o.Get("length");
        var len:Int = jint.runtime.TypeConverter.ToUint32(lenValue);
        var callable:jint.native.ICallable = callbackfn.TryCast(function (x:jint.native.JsValue):Void
        {
            throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(Engine.TypeError, "Argument must be callable");
        }
        );
        if (len == 0 && arguments.length < 2)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        var k:Int = len - 1;
        var accumulator:jint.native.JsValue = jint.native.Undefined.Instance;
        if (arguments.length > 1)
        {
            accumulator = initialValue;
        }
        else
        {
            var kPresent:Bool = false;
            while (kPresent == false && k >= 0)
            {
                var pk:String = Std.string(k);
                kPresent = o.HasProperty(pk);
                if (kPresent)
                {
                    accumulator = o.Get(pk);
                }
                k--;
            }
            if (kPresent == false)
            {
                return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
            }
        }
        { //for
            while (k >= 0)
            {
                var pk:String = Std.string(k);
                var kPresent:Bool = o.HasProperty(pk);
                if (kPresent)
                {
                    var kvalue:jint.native.JsValue = o.Get(pk);
                    accumulator = callable.Call(jint.native.Undefined.Instance, [ accumulator, kvalue, k, o ]);
                }
                k--;
            }
        } //end for
        return accumulator;
    }
    public function Push(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObject);
        var lenVal:Float = jint.runtime.TypeConverter.ToNumber(o.Get("length"));
        var n:Float = jint.runtime.TypeConverter.ToUint32(lenVal);
        for (e in arguments)
        {
            o.Put(jint.runtime.TypeConverter.toString(n), e, true);
            n++;
        }
        o.Put("length", n, true);
        return n;
    }
    public function Pop(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var o:jint.native.object.ObjectInstance = jint.runtime.TypeConverter.ToObject(Engine, thisObject);
        var lenVal:Float = jint.runtime.TypeConverter.ToNumber(o.Get("length"));
        var len:Int = jint.runtime.TypeConverter.ToUint32(lenVal);
        if (len == 0)
        {
            o.Put("length", 0, true);
            return jint.native.Undefined.Instance;
        }
        else
        {
            len = len - 1;
            var indx:String = jint.runtime.TypeConverter.toString(len);
            var element:jint.native.JsValue = o.Get(indx);
            o.Delete(indx, true);
            o.Put("length", len, true);
            return element;
        }
    }
}
