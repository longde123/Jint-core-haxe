package jint.runtime.references;
using StringTools;
import system.*;
import anonymoustypes.*;

class Reference
{
    private var _baseValue:jint.native.JsValue;
    private var _name:String;
    private var _strict:Bool;
    public function new(baseValue:jint.native.JsValue, name:String, strict:Bool)
    {
        _strict = false;
        _baseValue = baseValue;
        _name = name;
        _strict = strict;
    }
    public function GetBase():jint.native.JsValue
    {
        return _baseValue;
    }
    public function GetReferencedName():String
    {
        return _name;
    }
    public function IsStrict():Bool
    {
        return _strict;
    }
    public function HasPrimitiveBase():Bool
    {
        return _baseValue.IsPrimitive();
    }
    public function IsUnresolvableReference():Bool
    {
        return _baseValue.IsUndefined();
    }
    public function IsPropertyReference():Bool
    {
        return (_baseValue.IsObject() && _baseValue.TryCast() == null) || HasPrimitiveBase();
    }
}
