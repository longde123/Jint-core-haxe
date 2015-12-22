package jint.native; 
/**
 * ...
 * @author paling
 */

class  AbstractJsValue  { 
 
 
	public    function new()
    {
	 
        _double = 0;
        _type = 0;
    }
    public function Creator(value:Bool):jint.native.AbstractJsValue
    {
        _double = value ? 1.0 : 0.0;
        _object = null;
        _type = jint.runtime.Types.Boolean;
        return this;
    }
    public function Creator_Double(value:Float):jint.native.AbstractJsValue
    {
        _object = null;
        _type = jint.runtime.Types.Number;
        _double = value;
        return this;
    }
    public function Creator_String(value:String):jint.native.AbstractJsValue
    {
        _double = Math.NaN;
        _object = value;
        _type = jint.runtime.Types.String;
        return this;
    }
    public function Creator_ObjectInstance(value:jint.native.object.ObjectInstance):jint.native.AbstractJsValue
    {
        _double = Math.NaN;
        _type = jint.runtime.Types.Object;
        _object = value;
        return this;
    }
    public function Creator_Types(type:Int):jint.native.AbstractJsValue
    {
        _double = Math.NaN;
        _object = null;
        _type = type;
        return this;
    }
    private var _double:Float;
    private var _object:Dynamic;
    private var _type:Int;
    public function IsPrimitive():Bool
    {
        return _type != jint.runtime.Types.Object && _type != jint.runtime.Types.None;
    }
    public function IsUndefined():Bool
    {
        return _type == jint.runtime.Types.Undefined;
    }
    public function IsArray():Bool
    {
        return IsObject() && Std.is(AsObject(), jint.native.array.ArrayInstance);
    }
    public function IsDate():Bool
    {
        return IsObject() && Std.is(AsObject(), jint.native.date.DateInstance);
    }
    public function IsRegExp():Bool
    {
        return IsObject() && Std.is(AsObject(), jint.native.regexp.RegExpInstance);
    }
    public function IsObject():Bool
    {
        return _type == jint.runtime.Types.Object;
    }
    public function IsString():Bool
    {
        return _type == jint.runtime.Types.String;
    }
    public function IsNumber():Bool
    {
        return _type == jint.runtime.Types.Number;
    }
    public function IsBoolean():Bool
    {
        return _type == jint.runtime.Types.Boolean;
    }
    public function IsNull():Bool
    {
        return _type == jint.runtime.Types.Null;
    }
    public function AsObject():jint.native.object.ObjectInstance
    {
        if (_type != jint.runtime.Types.Object)
        {
            return throw new system.ArgumentException("The value is not an object");
        }
        return (Std.is(_object, jint.native.object.ObjectInstance) ? cast(_object, jint.native.object.ObjectInstance) : null);
    }
    public function AsArray():jint.native.array.ArrayInstance
    {
        if (!IsArray())
        {
            return throw new system.ArgumentException("The value is not an array");
        }
        return (Std.is(_object, jint.native.array.ArrayInstance) ? cast(_object, jint.native.array.ArrayInstance) : null);
    }
    public function AsDate():jint.native.date.DateInstance
    {
        if (!IsDate())
        {
            return throw new system.ArgumentException("The value is not a date");
        }
        return (Std.is(_object, jint.native.date.DateInstance) ? cast(_object, jint.native.date.DateInstance) : null);
    }
    public function AsRegExp():jint.native.regexp.RegExpInstance
    {
        if (!IsRegExp())
        {
            return throw new system.ArgumentException("The value is not a date");
        }
        return (Std.is(_object, jint.native.regexp.RegExpInstance) ? cast(_object, jint.native.regexp.RegExpInstance) : null);
    }
    public function TryCast<T: ()>(TClass:Class<T>,fail:(jint.native.AbstractJsValue -> Void) = null):T
    {
        if (IsObject())
        {
            var o:jint.native.object.ObjectInstance = AsObject();
            var t:T = (Std.is(o, TClass) ? cast(o, TClass) : null);
            if (t != null)
            {
                return t;
            }
        }
        if (fail != null)
        {
            fail(this);
        }
        return null;
    }
    public function Is<T>(TClass:Class<T>):Bool
    {
        return IsObject() && Std.is(AsObject(), TClass);
    }
    public function As<T: (jint.native.object.ObjectInstance)>(TClass:Class<T>):T
    {
        return (Std.is(_object, TClass) ? cast(_object, TClass) : null);
    }
    public function AsBoolean():Bool
    {
        if (_type != jint.runtime.Types.Boolean)
        {
            return throw new system.ArgumentException("The value is not a boolean");
        }
        return _double != 0;
    }
    public function AsString():String
    {
        if (_type != jint.runtime.Types.String)
        {
            return throw new system.ArgumentException("The value is not a string");
        }
        if (_object == null)
        {
            return throw new system.ArgumentException("The value is not defined");
        }
        return (Std.is(_object, String) ? cast(_object, String) : null);
    }
    public function AsNumber():Float
    {
        if (_type != jint.runtime.Types.Number)
        {
            return throw new system.ArgumentException("The value is not a number");
        }
        return _double;
    }
    public function Equals(other:jint.native.AbstractJsValue):Bool
    {
        if (_type != other._type)
        {
            return false;
        }
        switch (_type)
        {
            case jint.runtime.Types.None:
                return false;
            case jint.runtime.Types.Undefined:
                return true;
            case jint.runtime.Types.Null:
                return true;
            case jint.runtime.Types.Boolean, jint.runtime.Types.Number:
                return _double == other._double;
            case jint.runtime.Types.String, jint.runtime.Types.Object:
                return _object == other._object;
            default:
                return throw new system.ArgumentOutOfRangeException();
        }
    }
    public var Type(get, never):Int;
    public function get_Type():Int
    {
        return _type;
    }

    public static function FromObject(engine:jint.Engine, value:Dynamic):jint.native.AbstractJsValue
    {
        if (value == null)
        {
            return Null;
        }
        for (converter in engine.Options.GetObjectConverters())
        {
            var result:CsRef<jint.native.AbstractJsValue> = new CsRef<jint.native.AbstractJsValue>(null);
            if (converter.TryConvert(value, result))
            {
                return result.Value;
            }
        }
        var typeCode:Int = system.TypeCS.GetTypeCode(system.Cs2Hx.GetType(value));
        switch (typeCode)
        {
            case system.TypeCode.Boolean:
                return new jint.native.AbstractJsValue().Creator(value);
            case system.TypeCode.Byte:
                return new jint.native.AbstractJsValue().Creator_Double(value);
            case system.TypeCode.Char:
                return new jint.native.AbstractJsValue().Creator_String(value.toString());
            case system.TypeCode.DateTime:
                return engine.JDate.Construct_DateTime(value);
            case system.TypeCode.Decimal:
                return new jint.native.AbstractJsValue().Creator_Double(cast(value, Float));
            case system.TypeCode.Double:
                return new jint.native.AbstractJsValue().Creator_Double(value);
            case system.TypeCode.Int16:
                return new jint.native.AbstractJsValue().Creator_Double(value);
            case system.TypeCode.Int32:
                return new jint.native.AbstractJsValue().Creator_Double(value);
            case system.TypeCode.Int64:
                return new jint.native.AbstractJsValue().Creator_Double(value);
            case system.TypeCode.SByte:
                return new jint.native.AbstractJsValue().Creator_Double(value);
            case system.TypeCode.Single:
                return new jint.native.AbstractJsValue().Creator_Double(value);
            case system.TypeCode.String:
                return new jint.native.AbstractJsValue().Creator_String(value);
            case system.TypeCode.UInt16:
                return new jint.native.AbstractJsValue().Creator_Double(value);
            case system.TypeCode.UInt32:
                return new jint.native.AbstractJsValue().Creator_Double(value);
            case system.TypeCode.UInt64:
                return new jint.native.AbstractJsValue().Creator_Double(value);
            case system.TypeCode.Object:
            case system.TypeCode.Empty:
            default:
                return throw new system.ArgumentOutOfRangeException();
        }
        if (Std.is(value, system.DateTimeOffset))
        {
            return engine.JDate.Construct_DateTimeOffset(value);
        }
        var instance:jint.native.object.ObjectInstance = (Std.is(value, jint.native.object.ObjectInstance) ? cast(value, jint.native.object.ObjectInstance) : null);
        if (instance != null)
        {
            return new jint.native.AbstractJsValue().Creator_ObjectInstance(instance);
        }
        if (Std.is(value, jint.native.AbstractJsValue))
        {
            return value;
        }
        var array = cast(value);
        if (array != null)
        {
            var jsArray:jint.native.object.ObjectInstance = engine.JArray.Construct(jint.runtime.Arguments.Empty);
            for (item in array)
            {
                var jsItem:jint.native.AbstractJsValue = FromObject(engine, item);
                engine.JArray.PrototypeObject.Push(jsArray, jint.runtime.Arguments.From([ jsItem ]));
            }
            return jsArray;
        }
        var regex:system.text.regularexpressions.Regex = value;
        if (regex != null)
        {
            var jsRegex:jint.native.regexp.RegExpInstance = engine.JRegExp.Construct_String(system.Cs2Hx.Trim_(regex.toString(), [ 47 ]));
            return jsRegex;
        }
        var d:system.Delegate = value;
        if (d != null)
        {
            return new jint.runtime.interop.DelegateWrapper(engine, d);
        }
        if (system.Cs2Hx.GetType(value).IsEnum)
        {
            return new jint.native.AbstractJsValue().Creator_Double(value);
        }
        return new jint.runtime.interop.ObjectWrapper(engine, value);
    }
    public function ToObject():Dynamic
    {
        switch (_type)
        {
            case jint.runtime.Types.None, jint.runtime.Types.Undefined, jint.runtime.Types.Null:
                return null;
            case jint.runtime.Types.String:
                return _object;
            case jint.runtime.Types.Boolean:
                return _double != 0;
            case jint.runtime.Types.Number:
                return _double;
            case jint.runtime.Types.Object:
                var wrapper:jint.runtime.interop.IObjectWrapper = _object;
                if (wrapper != null)
                {
                    return wrapper.Target;
                }
                switch ((_object).Class)
                {
                    case "Array":
                        var arrayInstance:jint.native.array.ArrayInstance = _object;
                        if (arrayInstance != null)
                        {
                            var len:Int = jint.runtime.TypeConverter.ToInt32(arrayInstance.Get("length"));
                            var result:Array<Dynamic> = [  ];
                            { //for
                                var k:Int = 0;
                                while (k < len)
                                {
                                    var pk:String = Std.string(k);
                                    var kpresent:Bool = arrayInstance.HasProperty(pk);
                                    if (kpresent)
                                    {
                                        var kvalue:jint.native.AbstractJsValue = arrayInstance.Get(pk);
                                        result[k] = kvalue.ToObject();
                                    }
                                    else
                                    {
                                        result[k] = null;
                                    }
                                    k++;
                                }
                            } //end for
                            return result;
                        }
                    case "String":
                        var stringInstance:jint.native.string.StringInstance = _object;
                        if (stringInstance != null)
                        {
                            return stringInstance.PrimitiveValue.AsString();
                        }
                    case "Date":
                        var dateInstance:jint.native.date.DateInstance = _object;
                        if (dateInstance != null)
                        {
                            return dateInstance.ToDateTime();
                        }
                    case "Boolean":
                        var booleanInstance:jint.native.boolean.BooleanInstance = _object;
                        if (booleanInstance != null)
                        {
                            return booleanInstance.PrimitiveValue.AsBoolean();
                        }
                    case "Function":
                        var function_:jint.native.functions.FunctionInstance = _object;
                        if (function_ != null)
                        {
                            return function_.Call ;
                        }
                    case "Number":
                        var numberInstance:jint.native.number.NumberInstance = _object;
                        if (numberInstance != null)
                        {
                            return numberInstance.PrimitiveValue.AsNumber();
                        }
                    case "RegExp":
                        var regeExpInstance:jint.native.regexp.RegExpInstance = _object;
                        if (regeExpInstance != null)
                        {
                            return regeExpInstance.Value;
                        }
                    case "Object":
                        var o:system.collections.generic.IDictionary<String, Dynamic> = new system.collections.generic.Dictionary<String, Dynamic>();
                        for (p in ((Std.is(_object, jint.native.object.ObjectInstance) ? cast(_object, jint.native.object.ObjectInstance) : null)).GetOwnProperties())
                        {
                            if (!p.Value.Enumerable.HasValue || p.Value.Enumerable.Value == false)
                            {
                                continue;
                            }
                            o.Add(p.Key, ((Std.is(_object, jint.native.object.ObjectInstance) ? cast(_object, jint.native.object.ObjectInstance) : null)).Get(p.Key).ToObject());
                        }
                        return o;
                }
                return _object;
            default:
                return throw new system.ArgumentOutOfRangeException();
        }
    }
    public function Invoke(arguments:Array<jint.native.AbstractJsValue>):jint.native.AbstractJsValue
    {
        return Invoke_AbstractJsValue_(Undefined, arguments);
    }
    public function Invoke_AbstractJsValue_(thisObj:jint.native.AbstractJsValue, arguments:Array<jint.native.AbstractJsValue>):jint.native.AbstractJsValue
    {
        var callable:jint.native.ICallable = TryCast();
        if (callable == null)
        {
            return throw new system.ArgumentException("Can only invoke functions");
        }
        return callable.Call(thisObj, arguments);
    }
    public function toString():String
    {
        switch (Type)
        {
            case jint.runtime.Types.None:
                return "None";
            case jint.runtime.Types.Undefined:
                return "undefined";
            case jint.runtime.Types.Null:
                return "null";
            case jint.runtime.Types.Boolean:
                return _double != 0 ? "True" : "False";
            case jint.runtime.Types.Number:
                return Std.string(_double);
            case jint.runtime.Types.String, jint.runtime.Types.Object:
                return _object.toString();
            default:
                return "";
        }
    }
		
    public function Equals_Object(obj:Dynamic):Bool
    {
        if (ReferenceEquals(null, obj))
        {
            return false;
        }
        return Std.is(obj, jint.native.AbstractJsValue) && Equals(obj);
    }
    public function GetHashCode():Int
    {
        var hashCode:Int = 0;
        hashCode = (hashCode * 397) ^ _double.GetHashCode();
        hashCode = (hashCode * 397) ^ (_object != null ? _object.GetHashCode() : 0);
        hashCode = (hashCode * 397) ^ _type;
        return hashCode;
    }
    public static function cctor():Void
    {
        Undefined = new jint.native.AbstractJsValue().Creator_Types(jint.runtime.Types.Undefined);
        Null = new jint.native.AbstractJsValue().Creator_Types(jint.runtime.Types.Null);
        False = new jint.native.AbstractJsValue().Creator(false);
        True = new jint.native.AbstractJsValue().Creator(true);
    }
   
}
