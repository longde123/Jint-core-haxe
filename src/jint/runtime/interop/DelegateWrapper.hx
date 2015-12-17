package jint.runtime.interop;
using StringTools;
import system.*;
import anonymoustypes.*;

class DelegateWrapper extends jint.native.functions.FunctionInstance
{
	//todo about this
    private var _d:Dynamic;
	private var _item:Dynamic;
    public function new(engine:jint.Engine, d:Dynamic,item:Dynamic)
    {
        super(engine, null, null, false);
        _d = d;
		_item = item;
    }
    override public function Call(thisObject:jint.native.JsValue, jsArguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
		var jsArgumentsWithoutParamsCount = jsArguments.length;
        var parameters:Array<Dynamic> = [  ];
        { //for
            var i:Int = 0;
            while (i < jsArgumentsWithoutParamsCount)
            {
            
                    parameters[i] =  jsArguments[i].ToObject() ;
               
                i++;
            }
        } //end for
      
       // change the "this" scope in a Haxe object
        return jint.native.JsValue.FromObject(Engine, Reflect.callMethod(_item!=null?_item:this,_d,parameters);
    }
}
