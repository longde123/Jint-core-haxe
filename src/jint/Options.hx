package jint;
using StringTools;
import system.*;
import anonymoustypes.*;

class Options
{
    private var _discardGlobal:Bool;
    private var _strict:Bool;
    private var _allowDebuggerStatement:Bool;
    private var _debugMode:Bool;
    private var _allowClr:Bool;
    private var _objectConverters:Array<jint.runtime.interop.IObjectConverter>;
    private var _maxStatements:Int;
    private var _maxRecursionDepth:Int;
    private var _timeoutInterval:Date;
    private var _culture:Date;
    private var _localTimeZone:Date;
    private var _lookupAssemblies:Array<Dynamic>;
    public function DiscardGlobal(discard:Bool = true):jint.Options
    {
	 
        _discardGlobal = discard;
		
		 
        return this;
    }
    public function Strict(strict:Bool = true):jint.Options
    {
        _strict = strict;
        return this;
    }
    public function AllowDebuggerStatement(allowDebuggerStatement:Bool = true):jint.Options
    {
        _allowDebuggerStatement = allowDebuggerStatement;
        return this;
    }
    public function DebugMode(debugMode:Bool = true):jint.Options
    {
        _debugMode = debugMode;
        return this;
    }
    public function AddObjectConverter(objectConverter:jint.runtime.interop.IObjectConverter):jint.Options
    {
        _objectConverters.push(objectConverter);
        return this;
    }
    public function AllowClr(assemblies:Array<Dynamic>):jint.Options
    {
        _allowClr = true;
		_lookupAssemblies=_lookupAssemblies.concat(assemblies);
        return this;
    }
    public function MaxStatements(maxStatements:Int = 0):jint.Options
    {
        _maxStatements = maxStatements;
        return this;
    }
    public function TimeoutInterval(timeoutInterval:Date):jint.Options
    {
        _timeoutInterval = timeoutInterval;
        return this;
    }
    public function LimitRecursion(maxRecursionDepth:Int = 0):jint.Options
    {
        _maxRecursionDepth = maxRecursionDepth;
        return this;
    }
    public function Culture(cultureInfo:Date):jint.Options
    {
        _culture = cultureInfo;
        return this;
    }
    public function LocalTimeZone(timeZoneInfo:Date):jint.Options
    {
        _localTimeZone = timeZoneInfo;
        return this;
    }
    public function GetDiscardGlobal():Bool
    {
        return _discardGlobal;
    }
    public function IsStrict():Bool
    {
        return _strict;
    }
    public function IsDebuggerStatementAllowed():Bool
    {
        return _allowDebuggerStatement;
    }
    public function IsDebugMode():Bool
    {
        return _debugMode;
    }
    public function IsClrAllowed():Bool
    {
        return _allowClr;
    }
    public function GetLookupAssemblies():Array<Dynamic>
    {
        return _lookupAssemblies;
    }
    public function GetObjectConverters():Array<jint.runtime.interop.IObjectConverter>
    {
        return _objectConverters;
    }
    public function GetMaxStatements():Int
    {
        return _maxStatements;
    }
    public function GetMaxRecursionDepth():Int
    {
        return _maxRecursionDepth;
    }
    public function GetTimeoutInterval():Date
    {
        return _timeoutInterval;
    }
    public function GetCulture():Date
    {
        return _culture;
    }
    public function IsDaylightSavingTime(dateTime:Date):Bool
    {
        return __IsDaylightSavingTime(_localTimeZone,dateTime);
    }
	function __IsDaylightSavingTime(_localTimeZone:Date, dateTime:Date):Bool
	{
		//todo
		return false;
	}
    public function GetBaseUtcOffset():Date
    {
        return __GetUtcOffset(_localTimeZone,Date.now());
    }
	function __GetUtcOffset(_localTimeZone:Date, dateTime:Date):Date
	{
		//todo
		return null;
	}
    public function new()
    {
        _discardGlobal = false;
        _strict = false;
        _allowDebuggerStatement = false;
        _debugMode = false;
        _allowClr = false;
        _objectConverters = new Array<jint.runtime.interop.IObjectConverter>();
        _maxStatements = 0;
        _maxRecursionDepth = -1;
        _timeoutInterval = new Date();
		//todo
        _culture = new Date();
        _localTimeZone = new Date();
        _lookupAssemblies = new Array<Dynamic>();
    }
}
