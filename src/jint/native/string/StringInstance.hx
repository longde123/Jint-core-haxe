package jint.native.string;
using StringTools;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;
class StringInstance extends jint.native.object.ObjectInstance implements jint.native.IPrimitiveInstance
{
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    override public function get_JClass():String
    {
        return "String";
    }

    public var JType(get, never):Int;
    function get_JType():Int
    {
        return jint.runtime.Types.String;
    }

  

    public var PrimitiveValue:jint.native.JsValue;
    private static function IsInt(d:Float):Bool
    {
        if (d >= -9223372036854775808 && d <= 999900000000000000)
        {
            var l:Float = d;
            return l >= -2147483648 && l <= 2147483647;
        }
        else
        {
            return false;
        }
    }
    override public function GetOwnProperty(propertyName:String):jint.runtime.descriptors.PropertyDescriptor
    {
        if (propertyName == "Infinity")
        {
            return jint.runtime.descriptors.PropertyDescriptor.Undefined;
        }
        var desc:jint.runtime.descriptors.PropertyDescriptor = super.GetOwnProperty(propertyName);
        if (desc != jint.runtime.descriptors.PropertyDescriptor.Undefined)
        {
            return desc;
        }
        if (propertyName != Std.string(system.MathCS.Abs_Double(jint.runtime.TypeConverter.ToInteger(propertyName))))
        {
            return jint.runtime.descriptors.PropertyDescriptor.Undefined;
        }
        var str:jint.native.JsValue = PrimitiveValue;
        var dIndex:Float = jint.runtime.TypeConverter.ToInteger(propertyName);
        if (!IsInt(dIndex))
        {
            return jint.runtime.descriptors.PropertyDescriptor.Undefined;
        }
        var index:Int = Std.int(dIndex);
        var len:Int = str.AsString().length;
        if (len <= index || index < 0)
        {
            return jint.runtime.descriptors.PropertyDescriptor.Undefined;
        }
        var resultStr:String = String.fromCharCode(str.AsString().charCodeAt(index));
        return new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(resultStr,  (false),(true),(false));
    }
}
