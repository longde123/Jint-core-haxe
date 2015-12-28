package jint.runtime.interop;
using StringTools;
import haxe.ds.StringMap.StringMap;
import system.*;
import anonymoustypes.*;

class DefaultTypeConverter implements jint.runtime.interop.ITypeConverter
{
    private var _engine:jint.Engine;
    private static var _knownConversions: StringMap< Bool>;
    private static var convertChangeType:String;//"ChangeType"
    private static var jsValueFromObject:String;//"FromObject"
    private static var jsValueToObject:String;//"ToObject"
    public function new(engine:jint.Engine)
    {
        _engine = engine;
    }
    public function Convert(value:Dynamic, type:Class<Dynamic> ):Dynamic
    {
        if (value == null)
        {
            if (jint.runtime.TypeConverter.TypeIsNullable(type))
            {
                return null;
            }
            return throw new ArgumentNullException("Unable to convert null to '{0}'");
        }
        if (Type.getSuperClass(value)==type )
        {
            return value;
        }
			/*
        if (Std.is(type,Enum))
        {
            var integer:Dynamic = cast value ;
            if (integer == null)
            {
                return throw new system.ArgumentOutOfRangeException();
            }
            return Type.createEnumIndex(type,integer);
        }
	
        var valueType:system.TypeCS = system.Cs2Hx.GetType(value);
        if (valueType == Type.typeof((jint.native.JsValue -> Array<jint.native.JsValue> -> jint.native.JsValue)))
        {
            var function_:(jint.native.JsValue -> Array<jint.native.JsValue> -> jint.native.JsValue) = value;
            if (type.IsGenericType)
            {
                var genericType:system.TypeCS = type.GetGenericTypeDefinition();
                if (system.Cs2Hx.StartsWith(genericType.Name, "Action"))
                {
                  
                }
                else if (system.Cs2Hx.StartsWith(genericType.Name, "Func"))
                {
                 
                }
            }
            else
            {
                if (type == typeof((Void -> Void)))
                {
                    return (function ():Void { function(jint.native.JsValue.Undefined, [  ]); } );
                }
                else if (type.IsSubclassOf(typeof(Dynamic)))
                {
                    //var method:system.reflection.MethodInfo = type.GetMethod("Invoke"); 
                }
            }
        }

        if (Std.is(type,Array))
        {
            var source:Array<Dynamic> = (Std.is(value, Array ) ? cast(value, Array ) : null);
            if (source == null)
            {
                return throw new system.ArgumentException(system.String.Format("Value of object[] type is expected, but actual type is {0}.", system.Cs2Hx.GetType(value)));
            } 
            var result = Lambda.map( source, function(x) return Convert(o, type) ); 
            return result;
        }
        return system.Convert.ChangeType_Object_Type_IFormatProvider(value, type, formatProvider);
				*/
		return null;
    }
    public function TryConvert(value:Dynamic, type:Class<Dynamic>):Array<Dynamic>
    {
        var canConvert:Null<Bool> = true;
        var key:String = "";// value == null ?"Null":  ("{0}->{1}", system.Cs2Hx.GetType(value), type);
        var converted:Dynamic = null;
		/*
        if (!_knownConversions.TryGetValue(key, canConvert))
        {
            {
                if (!_knownConversions.TryGetValue(key, canConvert))
                {
                    try
                    {
                        converted = Convert(value, type );
                        _knownConversions.Add(key, true);
                        return new system.collections.generic.KeyValuePair<Bool, Dynamic>(true, converted);
                    }
                    catch (__ex:Dynamic)
                    {
                        converted = null;
                        _knownConversions.Add(key, false);
                        return new system.collections.generic.KeyValuePair<Bool, Dynamic>(false, null);
                    }
                }
            }
        }
		*/
		//todo 
        if (!canConvert)
        {
            converted = Convert(value, type);
            return [true, converted];
        }
        converted = null;
        return [false, null];
    }
    public static function cctor():Void
    {
        _knownConversions = new StringMap< Bool>();
  
        convertChangeType = "ChangeType";
        jsValueFromObject ="FromObject";
        jsValueToObject ="ToObject";
    }
}
