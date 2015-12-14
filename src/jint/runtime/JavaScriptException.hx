package jint.runtime;
using StringTools;
import system.*;
import anonymoustypes.*;

class JavaScriptException extends system.Exception
{
    private var _errorObject:jint.native.JsValue;
    public var _Message:String;
    override public function get_Message():String
    {
        return _Message;
    }

    public function new()
    {
        super("");
    }
    public function Creator(errorConstructor:jint.native.error.ErrorConstructor):jint.runtime.JavaScriptException
    {
        _errorObject = errorConstructor.Construct(jint.runtime.Arguments.Empty);
        return this;
    }
    public function Creator_ErrorConstructor_String(errorConstructor:jint.native.error.ErrorConstructor, message:String):jint.runtime.JavaScriptException
    {
        _Message = message;
        _errorObject = errorConstructor.Construct([ message ]);
        return this;
    }
    public function Creator_JsValue(error:jint.native.JsValue):jint.runtime.JavaScriptException
    {
        _Message = GetErrorMessage(error);
        _errorObject = error;
        return this;
    }
    private static function GetErrorMessage(error:jint.native.JsValue):String
    {
        if (error.IsObject())
        {
            var oi:jint.native.object.ObjectInstance = error.AsObject();
            var message:String = oi.Get("message").AsString();
            return message;
        }
        else
        {
            return "";
        }
    }
    public var Error(get_Error, never):jint.native.JsValue;
    public function get_Error():jint.native.JsValue
    {
        return _errorObject;
    }

    override public function toString():String
    {
        return _errorObject.toString();
    }
    public var Location:jint.parser.Location;
    public var LineNumber(get_LineNumber, never):Int;
    public function get_LineNumber():Int
    {
        return null == Location ? 0 : Location.Start.Line;
    }

    public var Column(get_Column, never):Int;
    public function get_Column():Int
    {
        return null == Location ? 0 : Location.Start.Column;
    }

}
