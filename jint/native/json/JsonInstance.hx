package jint.native.json;
using StringTools;
import system.*;
import anonymoustypes.*;

class JsonInstance extends jint.native.object.ObjectInstance
{
    private var _engine:jint.Engine;
    public function new(engine:jint.Engine)
    {
        super(engine);
        _engine = engine;
        Extensible = true;
    }
    override public function get_Class():String
    {
        return "JSON";
    }

    public static function CreateJsonObject(engine:jint.Engine):jint.native.json.JsonInstance
    {
        var json:jint.native.json.JsonInstance = new jint.native.json.JsonInstance(engine);
        json.Prototype = engine.Object.PrototypeObject;
        return json;
    }
    public function Configure():Void
    {
        FastAddProperty("parse", new jint.runtime.interop.ClrFunctionInstance(Engine, Parse, 2), true, false, true);
        FastAddProperty("stringify", new jint.runtime.interop.ClrFunctionInstance(Engine, Stringify, 3), true, false, true);
    }
    public function Parse(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var parser:jint.native.json.JsonParser = new jint.native.json.JsonParser(_engine);
        return parser.Parse(arguments[0].AsString());
    }
    public function Stringify(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var value:jint.native.JsValue = jint.native.Undefined.Instance;
        var replacer:jint.native.JsValue = jint.native.Undefined.Instance;
        var space:jint.native.JsValue = jint.native.Undefined.Instance;
        if (arguments.length > 2)
        {
            space = arguments[2];
        }
        if (arguments.length > 1)
        {
            replacer = arguments[1];
        }
        if (arguments.length > 0)
        {
            value = arguments[0];
        }
        var serializer:jint.native.json.JsonSerializer = new jint.native.json.JsonSerializer(_engine);
        if (value.Equals(jint.native.Undefined.Instance) && replacer.Equals(jint.native.Undefined.Instance))
        {
            return jint.native.Undefined.Instance;
        }
        else
        {
            return serializer.Serialize(value, replacer, space);
        }
    }
}
