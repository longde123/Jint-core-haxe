package jint.native.functions;
using StringTools;
import system.*;
import anonymoustypes.*;
using jint.native.StaticJsValue;

class FunctionConstructor extends jint.native.functions.FunctionInstance implements jint.native.IConstructor
{
    public function new(engine:jint.Engine)
    {
        super(engine, null, null, false);
    }
    public static function CreateFunctionConstructor(engine:jint.Engine):jint.native.functions.FunctionConstructor
    {
        var obj:jint.native.functions.FunctionConstructor = new jint.native.functions.FunctionConstructor(engine);
        obj.Extensible = true;
        obj.PrototypeObject = jint.native.functions.FunctionPrototype.CreatePrototypeObject(engine);
        obj.Prototype = obj.PrototypeObject;
        obj.FastAddProperty("prototype", obj.PrototypeObject, false, false, false);
        obj.FastAddProperty("length", 1, false, false, false);
        return obj;
    }
    public function Configure():Void
    {
    }
    public var PrototypeObject:jint.native.functions.FunctionPrototype;
    override public function Call(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        return Construct(arguments);
    }
    private function ParseArgumentNames(parameterDeclaration:String):Array<String>
    {
        var values:Array<String> = system.Cs2Hx.Split__StringSplitOptions(parameterDeclaration, [ 44 ], system.StringSplitOptions.RemoveEmptyEntries);
        var newValues:Array<String> = [  ];
        { //for
            var i:Int = 0;
            while (i < values.length)
            {
                newValues[i] = system.Cs2Hx.Trim(values[i]);
                i++;
            }
        } //end for
        return newValues;
    }
    public function Construct(arguments:Array<jint.native.JsValue>):jint.native.object.ObjectInstance
    {
        var argCount:Int = arguments.length;
        var p:String = "";
        var body:String = "";
        if (argCount == 1)
        {
            body = jint.runtime.TypeConverter.toString(arguments[0]);
        }
        else if (argCount > 1)
        {
            var firstArg:jint.native.JsValue = arguments[0];
            p = jint.runtime.TypeConverter.toString(firstArg);
            { //for
                var k:Int = 1;
                while (k < argCount - 1)
                {
                    var nextArg:jint.native.JsValue = arguments[k];
                    p += "," + jint.runtime.TypeConverter.toString(nextArg);
                    k++;
                }
            } //end for
            body = jint.runtime.TypeConverter.toString(arguments[argCount - 1]);
        }
        var parameters:Array<String> = this.ParseArgumentNames(p);
        var parser:jint.parser.JavaScriptParser = new jint.parser.JavaScriptParser();
        var function_:jint.parser.ast.FunctionExpression;
        try
        {
            var functionExpression:String = "function(" + p + ") { " + body + "}";
            function_ = parser.ParseFunctionExpression_String(functionExpression);
        }
        catch (__ex:jint.parser.ParserException)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.SyntaxError);
        }
        var functionDeclaration:jint.parser.ast.FunctionDeclaration = new jint.parser.ast.FunctionDeclaration();
        functionDeclaration.Type = jint.parser.ast.SyntaxNodes.FunctionDeclaration;
        var blockStatement:jint.parser.ast.BlockStatement = new jint.parser.ast.BlockStatement();
        blockStatement.Type = jint.parser.ast.SyntaxNodes.BlockStatement;
        blockStatement.Body = [ function_.Body ];
        functionDeclaration.Body = blockStatement;
        functionDeclaration.Parameters = parameters.map( function (x:String):jint.parser.ast.Identifier
        {
            var identifier:jint.parser.ast.Identifier = new jint.parser.ast.Identifier();
            identifier.Type = jint.parser.ast.SyntaxNodes.Identifier;
            identifier.Name = x;
            return identifier;
        }
        );
        functionDeclaration.FunctionDeclarations = function_.FunctionDeclarations;
        functionDeclaration.VariableDeclarations = function_.VariableDeclarations;
        var functionObject:jint.native.functions.ScriptFunctionInstance = new jint.native.functions.ScriptFunctionInstance(Engine, functionDeclaration, jint.runtime.environments.LexicalEnvironment.NewDeclarativeEnvironment(Engine, Engine.ExecutionContext.LexicalEnvironment), function_.Strict);
        functionObject.Extensible = true;
        return functionObject;
    }
    public function CreateFunctionObject(functionDeclaration:jint.parser.ast.FunctionDeclaration):jint.native.functions.FunctionInstance
    {
        var functionObject:jint.native.functions.ScriptFunctionInstance = new jint.native.functions.ScriptFunctionInstance(Engine, functionDeclaration, jint.runtime.environments.LexicalEnvironment.NewDeclarativeEnvironment(Engine, Engine.ExecutionContext.LexicalEnvironment), functionDeclaration.Strict);
        return functionObject;
    }
    private var _throwTypeError:jint.native.functions.FunctionInstance;
    public var ThrowTypeError(get_ThrowTypeError, never):jint.native.functions.FunctionInstance;
    public function get_ThrowTypeError():jint.native.functions.FunctionInstance
    {
        if (_throwTypeError != null)
        {
            return _throwTypeError;
        }
        _throwTypeError = new jint.native.functions.ThrowTypeError(Engine);
        return _throwTypeError;
    }

    public function Apply(thisObject:jint.native.JsValue, arguments:Array<jint.native.JsValue>):Dynamic
    {
        if (arguments.length != 2)
        {
            return throw new system.ArgumentException("Apply has to be called with two arguments.");
        }
        var func:jint.native.ICallable = thisObject.TryCast(jint.native.ICallable);
        var thisArg:jint.native.JsValue = arguments[0];
        var argArray:jint.native.JsValue = arguments[1];
        if (func == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        if (argArray.Equals(jint.native.Null.Instance) || argArray.Equals(jint.native.Undefined.Instance))
        {
            return func.Call(thisArg, jint.runtime.Arguments.Empty);
        }
        var argArrayObj:jint.native.object.ObjectInstance = argArray.TryCast(jint.native.object.ObjectInstance);
        if (argArrayObj == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        var len:jint.native.JsValue = argArrayObj.Get("length");
        var n:Int = jint.runtime.TypeConverter.ToUint32(len);
        var argList:Array<jint.native.JsValue> = new Array<jint.native.JsValue>();
        { //for
            var index:Int = 0;
            while (index < n)
            {
                var indexName:String = Std.string(index);
                var nextArg:jint.native.JsValue = argArrayObj.Get(indexName);
                argList.push(nextArg);
                index++;
            }
        } //end for
        return func.Call(thisArg, system.Cs2Hx.ToArray(argList));
    }
}
