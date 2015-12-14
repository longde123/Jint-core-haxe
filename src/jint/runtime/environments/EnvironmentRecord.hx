package jint.runtime.environments;
using StringTools;
import system.*;
import anonymoustypes.*;

class EnvironmentRecord extends jint.native.object.ObjectInstance
{
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    public function HasBinding(name:String):Bool
    {
        return throw new Exception("Abstract item called");
    }
    public function CreateMutableBinding(name:String, canBeDeleted:Bool = false):Void
    {
        throw new Exception("Abstract item called");
    }
    public function SetMutableBinding(name:String, value:jint.native.JsValue, strict:Bool):Void
    {
        throw new Exception("Abstract item called");
    }
    public function GetBindingValue(name:String, strict:Bool):jint.native.JsValue
    {
        return throw new Exception("Abstract item called");
    }
    public function DeleteBinding(name:String):Bool
    {
        return throw new Exception("Abstract item called");
    }
    public function ImplicitThisValue():jint.native.JsValue
    {
        return throw new Exception("Abstract item called");
    }
    public function GetAllBindingNames():Array<String>
    {
        return throw new Exception("Abstract item called");
    }
}
