package jint.native.json;
using StringTools;
import system.*;
import anonymoustypes.*;

class JsonSerializer
{
    private var _engine:jint.Engine;
    public function new(engine:jint.Engine)
    {
        _replacerFunction = jint.native.Undefined.Instance;
        _engine = engine;
    }
    var _stack:Array<Dynamic>;
    var _indent:String;
    var _gap:String;
    var _propertyList:Array<String>;
    var _replacerFunction:jint.native.JsValue;
    public function Serialize(value:jint.native.JsValue, replacer:jint.native.JsValue, space:jint.native.JsValue):jint.native.JsValue
    {
        _stack = new Array<Dynamic>();
        if (value.Is() && replacer.Equals(jint.native.Undefined.Instance))
        {
            return jint.native.Undefined.Instance;
        }
        if (replacer.IsObject())
        {
            if (replacer.Is())
            {
                _replacerFunction = replacer;
            }
            else
            {
                var replacerObj:jint.native.object.ObjectInstance = replacer.AsObject();
                if (replacerObj.Class == "Array")
                {
                    _propertyList = new Array<String>();
                }
                for (property in system.linq.Enumerable.Select(replacerObj.GetOwnProperties(), function (x:system.collections.generic.KeyValuePair<String, jint.runtime.descriptors.PropertyDescriptor>):jint.runtime.descriptors.PropertyDescriptor { return x.Value; } ))
                {
                    var v:jint.native.JsValue = _engine.GetValue(property);
                    var item:String = null;
                    if (v.IsString())
                    {
                        item = v.AsString();
                    }
                    else if (v.IsNumber())
                    {
                        item = jint.runtime.TypeConverter.toString(v);
                    }
                    else if (v.IsObject())
                    {
                        var propertyObj:jint.native.object.ObjectInstance = v.AsObject();
                        if (propertyObj.Class == "String" || propertyObj.Class == "Number")
                        {
                            item = jint.runtime.TypeConverter.toString(v);
                        }
                    }
                    if (item != null && !system.Cs2Hx.Contains(_propertyList, item))
                    {
                        _propertyList.push(item);
                    }
                }
            }
        }
        if (space.IsObject())
        {
            var spaceObj:jint.native.object.ObjectInstance = space.AsObject();
            if (spaceObj.Class == "Number")
            {
                space = jint.runtime.TypeConverter.ToNumber(spaceObj);
            }
            else if (spaceObj.Class == "String")
            {
                space = jint.runtime.TypeConverter.toString(spaceObj);
            }
        }
        if (space.IsNumber())
        {
            if (space.AsNumber() > 0)
            {
                _gap = new String(32, Std.int(system.MathCS.Min_Double_Double(10, space.AsNumber())));
            }
            else
            {
                _gap = "";
            }
        }
        else if (space.IsString())
        {
            var stringSpace:String = space.AsString();
            _gap = stringSpace.length <= 10 ? stringSpace : stringSpace.substr(0, 10);
        }
        else
        {
            _gap = "";
        }
        var wrapper:jint.native.object.ObjectInstance = _engine.JObject.Construct(jint.runtime.Arguments.Empty);
        wrapper.DefineOwnProperty("", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(value, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
        return Str("", wrapper);
    }
    private function Str(key:String, holder:jint.native.object.ObjectInstance):jint.native.JsValue
    {
        var value:jint.native.JsValue = holder.Get(key);
        if (value.IsObject())
        {
            var toJson:jint.native.JsValue = value.AsObject().Get("toJSON");
            if (toJson.IsObject())
            {
                var callableToJson:jint.native.ICallable = cast(toJson.AsObject(), jint.native.ICallable);
                if (callableToJson != null)
                {
                    value = callableToJson.Call(value, jint.runtime.Arguments.From([ key ]));
                }
            }
        }
        if (!_replacerFunction.Equals(jint.native.Undefined.Instance))
        {
            var replacerFunctionCallable:jint.native.ICallable = cast(_replacerFunction.AsObject(), jint.native.ICallable);
            value = replacerFunctionCallable.Call(holder, jint.runtime.Arguments.From([ key, value ]));
        }
        if (value.IsObject())
        {
            var valueObj:jint.native.object.ObjectInstance = value.AsObject();
            switch (valueObj.Class)
            {
                case "Number":
                    value = jint.runtime.TypeConverter.ToNumber(value);
                case "String":
                    value = jint.runtime.TypeConverter.toString(value);
                case "Boolean":
                    value = jint.runtime.TypeConverter.ToPrimitive(value);
                case "Array":
                    value = SerializeArray(value.As());
                    return value;
                case "Object":
                    value = SerializeObject(value.AsObject());
                    return value;
            }
        }
        if (value.Equals(jint.native.Null.Instance))
        {
            return "null";
        }
        if (value.IsBoolean() && value.AsBoolean())
        {
            return "true";
        }
        if (value.IsBoolean() && !value.AsBoolean())
        {
            return "false";
        }
        if (value.IsString())
        {
            return Quote(value.AsString());
        }
        if (value.IsNumber())
        {
            if (jint.native.global.GlobalObject.IsFinite(jint.native.Undefined.Instance, jint.runtime.Arguments.From([ value ])).AsBoolean())
            {
                return jint.runtime.TypeConverter.toString(value);
            }
            return "null";
        }
        var isCallable:Bool = value.IsObject() && Std.is(value.AsObject(), jint.native.ICallable);
        if (value.IsObject() && isCallable == false)
        {
            if (value.AsObject().Class == "Array")
            {
                return SerializeArray(value.As());
            }
            return SerializeObject(value.AsObject());
        }
        return jint.native.JsValue.Undefined;
    }
    private function Quote(value:String):String
    {
        var product:String = "\"";
        for (c in Cs2Hx.ToCharArray(value))
        {
            switch (c)
            {
                case 34:
                    product += "\\\"";
                case 92:
                    product += "\\\\";
                case 98:
                    product += "\\b";
                case 102:
                    product += "\\f";
                case 110:
                    product += "\\n";
                case 114:
                    product += "\\r";
                case 116:
                    product += "\\t";
                default:
                    if (c < 0x20)
                    {
                        product += "\\u";
                        product += jint.runtime.TypeConverter.toString(c, "x4");
                    }
                    else
                    {
                        product += c;
                    }
            }
        }
        product += "\"";
        return product;
    }
    private function SerializeArray(value:jint.native.array.ArrayInstance):String
    {
        EnsureNonCyclicity(value);
        _stack.push(value);
        var stepback:String = _indent;
        _indent = _indent + _gap;
        var partial:Array<String> = new Array<String>();
        var len:Int = jint.runtime.TypeConverter.ToUint32(value.Get("length"));
        { //for
            var i:Int = 0;
            while (i < len)
            {
                var strP:jint.native.JsValue = Str(jint.runtime.TypeConverter.toString(i), value);
                if (strP.Equals(jint.native.JsValue.Undefined))
                {
                    strP = "null";
                }
                partial.push(strP.AsString());
                i++;
            }
        } //end for
        if (partial.length == 0)
        {
            return "[]";
        }
        var final:String;
        if (_gap == "")
        {
            var separator:String = ",";
            var properties:String = system.Cs2Hx.Join(separator, system.Cs2Hx.ToArray(partial));
            final = "[" + properties + "]";
        }
        else
        {
            var separator:String = ",\n" + _indent;
            var properties:String = system.Cs2Hx.Join(separator, system.Cs2Hx.ToArray(partial));
            final = "[\n" + _indent + properties + "\n" + stepback + "]";
        }
        _stack.pop();
        _indent = stepback;
        return final;
    }
    private function EnsureNonCyclicity(value:Dynamic):Void
    {
        if (value == null)
        {
            throw new system.ArgumentNullException("value");
        }
        if (_stack.Contains(value))
        {
            throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(_engine.TypeError, "Cyclic reference detected.");
        }
    }
    private function SerializeObject(value:jint.native.object.ObjectInstance):String
    {
        var final:String;
        EnsureNonCyclicity(value);
        _stack.push(value);
        var stepback:String = _indent;
        _indent += _gap;
        var k:Array<String> = Cs2Hx.Coalesce(_propertyList, system.linq.Enumerable.ToList(system.linq.Enumerable.Select(system.linq.Enumerable.Where(value.GetOwnProperties(), function (x:system.collections.generic.KeyValuePair<String, jint.runtime.descriptors.PropertyDescriptor>):Bool { return x.Value.Enumerable.HasValue && x.Value.Enumerable.Value == true; } ), function (x:system.collections.generic.KeyValuePair<String, jint.runtime.descriptors.PropertyDescriptor>):String { return x.Key; } )));
        var partial:Array<String> = new Array<String>();
        for (p in k)
        {
            var strP:jint.native.JsValue = Str(p, value);
            if (!strP.Equals(jint.native.JsValue.Undefined))
            {
                var member:String = Quote(p) + ":";
                if (_gap != "")
                {
                    member += " ";
                }
                member += strP.AsString();
                partial.push(member);
            }
        }
        if (partial.length == 0)
        {
            final = "{}";
        }
        else
        {
            if (_gap == "")
            {
                var separator:String = ",";
                var properties:String = system.Cs2Hx.Join(separator, system.Cs2Hx.ToArray(partial));
                final = "{" + properties + "}";
            }
            else
            {
                var separator:String = ",\n" + _indent;
                var properties:String = system.Cs2Hx.Join(separator, system.Cs2Hx.ToArray(partial));
                final = "{\n" + _indent + properties + "\n" + stepback + "}";
            }
        }
        _stack.pop();
        _indent = stepback;
        return final;
    }
}
