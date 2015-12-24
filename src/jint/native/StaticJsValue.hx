package jint.native;

/**
 * ...
 * @author paling
 */
class StaticJsValue
{
    
    static public function IsPrimitive(me:JsValue):Bool
    {
		var self:AbstractJsValue = me;
        return self.IsPrimitive();
    }
    static public function IsUndefined(me:JsValue):Bool
    {
        var self:AbstractJsValue = me;
        return self.IsUndefined();
    }
    static public function IsArray(me:JsValue):Bool
    {
       var self:AbstractJsValue = me;
       return self.IsArray();
    }
    static public function IsDate(me:JsValue):Bool
    {
       var self:AbstractJsValue = me;
       return self.IsDate();
    }
    static public function IsRegExp(me:JsValue):Bool
    {
       var self:AbstractJsValue = me;
       return self.IsRegExp();
    }
    static public function IsObject(me:JsValue):Bool
    {
        var self:AbstractJsValue = me;
       return self.IsObject();
    }
    static public function IsString(me:JsValue):Bool
    {
       var self:AbstractJsValue = me;
       return self.IsString();
    }
    static public function IsNumber(me:JsValue):Bool
    {
       var self:AbstractJsValue = me;
       return self.IsNumber();
    }
    static public function IsBoolean(me:JsValue):Bool
    {
       var self:AbstractJsValue = me;
       return self.IsBoolean();
    }
    static public function IsNull(me:JsValue):Bool
    {
       var self:AbstractJsValue = me;
       return self.IsNull();
    }
    static public function AsObject(me:JsValue):jint.native.object.ObjectInstance
    { 
       var self:AbstractJsValue = me;
       return self.AsObject();
    }
    static public function AsArray(me:JsValue):jint.native.array.ArrayInstance
    {
       var self:AbstractJsValue = me;
       return self.AsArray();
    }
    static public function AsDate(me:JsValue):jint.native.date.DateInstance
    {
      var self:AbstractJsValue = me;
       return self.AsDate();
    }
    static public function AsRegExp(me:JsValue):jint.native.regexp.RegExpInstance
    {
        var self:AbstractJsValue = me;
       return self.AsRegExp();
    }
    static public function TryCast<T: ()>(me:JsValue,TClass:Class<T>,fail:(jint.native.AbstractJsValue -> Void) = null):T
    {
       var self:AbstractJsValue = me;
       return self.TryCast(TClass,fail);
    }
    static public function Is<T>(me:JsValue,TClass:Class<T>):Bool
    {
        var self:AbstractJsValue = me;
       return self.Is(TClass);
    }
    static public function As<T: (jint.native.object.ObjectInstance)>(me:JsValue,TClass:Class<T>):T
    {
        var self:AbstractJsValue = me;
       return self.As(TClass);
    }
    static public function AsBoolean(me:JsValue):Bool
    {
       var self:AbstractJsValue = me;
       return self.AsBoolean();
    }
    static public function AsString(me:JsValue):String
    {
       var self:AbstractJsValue = me;
       return self.AsString();
    }
    static public function AsNumber(me:JsValue):Float
    {
       var self:AbstractJsValue = me;
       return self.AsNumber();
    }
    static public function Equals(me:JsValue,other:jint.native.AbstractJsValue):Bool
    {
       var self:AbstractJsValue = me;
       return self.Equals(other);
    }
    
    static public function ToObject(me:JsValue):Dynamic
    {
        var self:AbstractJsValue = me;
       return self.ToObject();
   
    }
    static public function Invoke(me:JsValue,arguments:Array<jint.native.AbstractJsValue>):jint.native.AbstractJsValue
    {
        return Invoke_AbstractJsValue_(me,Undefined, arguments);
    }
    static public function Invoke_AbstractJsValue_(me:JsValue,thisObj:jint.native.AbstractJsValue, arguments:Array<jint.native.AbstractJsValue>):jint.native.AbstractJsValue
    {
      var self:AbstractJsValue = me;
       return self.Invoke_AbstractJsValue_(thisObj, arguments);
    }
    static public function toString(me:JsValue):String
    {
		var self:AbstractJsValue = me;
       return self.toString();
    }
	static	public function GetJType(me:JsValue):Int
    {
       	var self:AbstractJsValue = me;
       return self.GetJType();
    }
    static public function Equals_Object(me:JsValue,obj:Dynamic):Bool
    {
       var self:AbstractJsValue = me;
       return self.Equals_Object(obj);
    }
    static public function GetHashCode(me:JsValue):Int
    {
       var self:AbstractJsValue = me;
       return self.GetHashCode();
    }
}