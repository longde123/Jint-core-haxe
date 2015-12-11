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
    private var _timeoutInterval:system.TimeSpan;
    private var _culture:system.globalization.CultureInfo;
    private var _localTimeZone:system.TimeZone;
    private var _lookupAssemblies:Array<system.reflection.Assembly>;
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
    public function AllowClr(assemblies:Array<system.reflection.Assembly>):jint.Options
    {
        _allowClr = true;
        system.Cs2Hx.AddRange(_lookupAssemblies, assemblies);
        _lookupAssemblies = system.linq.Enumerable.ToList(system.linq.Enumerable.Distinct(_lookupAssemblies));
        return this;
    }
    public function MaxStatements(maxStatements:Int = 0):jint.Options
    {
        _maxStatements = maxStatements;
        return this;
    }
    public function TimeoutInterval(timeoutInterval:system.TimeSpan):jint.Options
    {
        _timeoutInterval = timeoutInterval;
        return this;
    }
    public function LimitRecursion(maxRecursionDepth:Int = 0):jint.Options
    {
        _maxRecursionDepth = maxRecursionDepth;
        return this;
    }
    public function Culture(cultureInfo:system.globalization.CultureInfo):jint.Options
    {
        _culture = cultureInfo;
        return this;
    }
    public function LocalTimeZone(timeZoneInfo:system.TimeZone):jint.Options
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
    public function GetLookupAssemblies():Array<system.reflection.Assembly>
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
    public function GetTimeoutInterval():system.TimeSpan
    {
        return _timeoutInterval;
    }
    public function GetCulture():system.globalization.CultureInfo
    {
        return _culture;
    }
    public function IsDaylightSavingTime(dateTime:system.DateTime):Bool
    {
        return _localTimeZone.IsDaylightSavingTime(dateTime);
    }
    public function GetBaseUtcOffset():system.TimeSpan
    {
        return _localTimeZone.GetUtcOffset(system.DateTime.Now);
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
        _timeoutInterval = new system.TimeSpan();
        _culture = system.globalization.CultureInfo.CurrentCulture;
        _localTimeZone = system.TimeZone.CurrentTimeZone;
        _lookupAssemblies = new Array<system.reflection.Assembly>();
    }
}
