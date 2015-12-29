package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import flash.media.AVPeriodInfo;
import jint.native.AbstractJsValue;
  

  /*
import test.parser.JavascriptParserTests;
import jint.parser.*;
import jint.parser.ast.*;
 
import jint.DeclarationBindingType; 
import jint.EvalCodeScope;
import jint.StrictModeScope;

import jint.runtime.Arguments;
import jint.runtime.callstack.CallStackElementComparer;
import jint.runtime.callstack.JintCallStack;
import jint.runtime.CallStackElement;
import jint.runtime.Completion;
import jint.runtime.debugger.BreakPoint;
import jint.runtime.debugger.DebugHandler;
import jint.runtime.debugger.DebugInformation;
import jint.runtime.debugger.StepMode;
import jint.runtime.descriptors.PropertyDescriptor;
import jint.runtime.descriptors.specialized.ClrAccessDescriptor;
import jint.runtime.descriptors.specialized.FieldInfoDescriptor;
import jint.runtime.descriptors.specialized.IndexDescriptor;
import jint.runtime.descriptors.specialized.PropertyInfoDescriptor;
import jint.runtime.environments.Binding;
import jint.runtime.environments.DeclarativeEnvironmentRecord;
import jint.runtime.environments.EnvironmentRecord;
import jint.runtime.environments.ExecutionContext;
import jint.runtime.environments.LexicalEnvironment;
import jint.runtime.environments.ObjectEnvironmentRecord;
import jint.runtime.ExpressionInterpreter;
import jint.runtime.interop.ClrFunctionInstance;
import jint.runtime.interop.DefaultTypeConverter;
import jint.runtime.interop.DelegateWrapper;
import jint.runtime.interop.GetterFunctionInstance;
import jint.runtime.interop.IObjectConverter;
import jint.runtime.interop.IObjectWrapper;
import jint.runtime.interop.ITypeConverter; 
import jint.runtime.interop.ObjectWrapper;
import jint.runtime.interop.SetterFunctionInstance;
import jint.runtime.interop.TypeReference;
import jint.runtime.JavaScriptException;
import jint.runtime.MruPropertyCache;
import jint.runtime.RecursionDepthOverflowException;
import jint.runtime.references.Reference;
import jint.runtime.StatementInterpreter;
import jint.runtime.StatementsCountOverflowException;
import jint.runtime.TypeConverter;
import jint.runtime.Types;
 */
import jint.StrictModeScope;
import jint.native.JsValue; 
using  jint.native.StaticJsValue;
import jint.Engine;
import jint.parser.*;
import jint.parser.ast.*;
import test.parser.JavascriptParserTests;
class Main 
{
	 
 
	static function main() 
	{ 
		 
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT; 
	 
		Constructors.init();
		 
		var square = new Engine().SetValue_String_Double("x", 3).Execute("x* x").GetCompletionValue();
		// .Execute("x * x")
        trace("square.ToObject()", square.ToObject());
		var arguments:Array<jint.native.JsValue> = [];
		arguments.push(1);
		arguments.push(2);
		var add= new Engine().Execute("function add(a, b) { return a + b; }").GetValue_String("add").Invoke(arguments); // -> 3

 
		
		  trace("add.ToObject()",add.ToObject());
		 /*
	 
		var r = new haxe.unit.TestRunner();
		r.add(new JavascriptParserTests());
		// add other TestCases here

		// finally, run the tests
		
		
		r.run();
		
			var tmp = [1, 1];
 
		trace(Reflect.fields( tmp));
		trace(Type.getInstanceFields(Array));
		 
		trace(Type.getClassFields(Array));
	*/
	}
	
}