package jint.native.string;
using StringTools;
import system.*;
import anonymoustypes.*;

class StringPrototype extends jint.native.string.StringInstance
{
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    public static function CreatePrototypeObject(engine:jint.Engine, stringConstructor:jint.native.string.StringConstructor):jint.native.string.StringPrototype
    {
        var obj:jint.native.string.StringPrototype = new jint.native.string.StringPrototype(engine);
        obj.Prototype = engine.Object.PrototypeObject;
        obj.PrimitiveValue = "";
        obj.Extensible = true;
        obj.FastAddProperty("length", 0, false, false, false);
        obj.FastAddProperty("constructor", stringConstructor, true, false, true);
        return obj;
    }
    public function Configure():Void
    {
        FastAddProperty("toString", new jint.runtime.interop.ClrFunctionInstance(Engine, ToStringString), true, false, true);
        FastAddProperty("valueOf", new jint.runtime.interop.ClrFunctionInstance(Engine, ValueOf), true, false, true);
        FastAddProperty("charAt", new jint.runtime.interop.ClrFunctionInstance(Engine, CharAt, 1), true, false, true);
        FastAddProperty("charCodeAt", new jint.runtime.interop.ClrFunctionInstance(Engine, CharCodeAt, 1), true, false, true);
        FastAddProperty("concat", new jint.runtime.interop.ClrFunctionInstance(Engine, Concat, 1), true, false, true);
        FastAddProperty("indexOf", new jint.runtime.interop.ClrFunctionInstance(Engine, IndexOf, 1), true, false, true);
        FastAddProperty("lastIndexOf", new jint.runtime.interop.ClrFunctionInstance(Engine, LastIndexOf, 1), true, false, true);
        FastAddProperty("localeCompare", new jint.runtime.interop.ClrFunctionInstance(Engine, LocaleCompare, 1), true, false, true);
        FastAddProperty("match", new jint.runtime.interop.ClrFunctionInstance(Engine, Match, 1), true, false, true);
        FastAddProperty("replace", new jint.runtime.interop.ClrFunctionInstance(Engine, Replace, 2), true, false, true);
        FastAddProperty("search", new jint.runtime.interop.ClrFunctionInstance(Engine, Search, 1), true, false, true);
        FastAddProperty("slice", new jint.runtime.interop.ClrFunctionInstance(Engine, Slice, 2), true, false, true);
        FastAddProperty("split", new jint.runtime.interop.ClrFunctionInstance(Engine, Split, 2), true, false, true);
        FastAddProperty("substr", new jint.runtime.interop.ClrFunctionInstance(Engine, Substr, 2), true, false, true);
        FastAddProperty("substring", new jint.runtime.interop.ClrFunctionInstance(Engine, Substring, 2), true, false, true);
        FastAddProperty("toLowerCase", new jint.runtime.interop.ClrFunctionInstance(Engine, ToLowerCase), true, false, true);
        FastAddProperty("toLocaleLowerCase", new jint.runtime.interop.ClrFunctionInstance(Engine, ToLocaleLowerCase), true, false, true);
        FastAddProperty("toUpperCase", new jint.runtime.interop.ClrFunctionInstance(Engine, ToUpperCase), true, false, true);
        FastAddProperty("toLocaleUpperCase", new jint.runtime.interop.ClrFunctionInstance(Engine, ToLocaleUpperCase), true, false, true);
        FastAddProperty("trim", new jint.runtime.interop.ClrFunctionInstance(Engine, Trim), true, false, true);
    }
    private function ToStringString(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var s:jint.native.string.StringInstance = cast(jint.runtime.TypeConverter.ToObject(Engine, thisObj), jint.native.string.StringInstance);
        if (s == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        return s.PrimitiveValue;
    }
    static inline var BOM_CHAR:Int = 102;
    private static function IsWhiteSpaceEx(c:Int):Bool
    {
        return Cs2Hx.IsWhiteSpace(c) || c == BOM_CHAR;
    }
    private static function TrimEndEx(s:String):String
    {
        if (s.length == 0)
        {
            return "";
        }
        var i:Int = s.length - 1;
        while (i >= 0)
        {
            if (IsWhiteSpaceEx(s.charCodeAt(i)))
            {
                i--;
            }
            else
            {
                break;
            }
        }
        if (i >= 0)
        {
            return s.substr(0, i + 1);
        }
        else
        {
            return "";
        }
    }
    private static function TrimStartEx(s:String):String
    {
        if (s.length == 0)
        {
            return "";
        }
        var i:Int = 0;
        while (i < s.length)
        {
            if (IsWhiteSpaceEx(s.charCodeAt(i)))
            {
                i++;
            }
            else
            {
                break;
            }
        }
        if (i >= s.length)
        {
            return "";
        }
        else
        {
            return s.substr(i);
        }
    }
    private static function TrimEx(s:String):String
    {
        return TrimEndEx(TrimStartEx(s));
    }
    private function Trim(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        jint.runtime.TypeConverter.CheckObjectCoercible(Engine, thisObj);
        var s:String = jint.runtime.TypeConverter.toString(thisObj);
        return TrimEx(s);
    }
    private static function ToLocaleUpperCase(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var s:String = jint.runtime.TypeConverter.toString(thisObj);
        return s.toUpperCase();
    }
    private static function ToUpperCase(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var s:String = jint.runtime.TypeConverter.toString(thisObj);
        return s.ToUpperInvariant();
    }
    private static function ToLocaleLowerCase(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var s:String = jint.runtime.TypeConverter.toString(thisObj);
        return s.toLowerCase();
    }
    private static function ToLowerCase(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var s:String = jint.runtime.TypeConverter.toString(thisObj);
        return s.ToLowerInvariant();
    }
    private static function ToIntegerSupportInfinity(numberVal:jint.native.JsValue):Int
    {
        var doubleVal:Float = jint.runtime.TypeConverter.ToInteger(numberVal);
        var intVal:Int = Std.int(doubleVal);
        if (Cs2Hx.IsPositiveInfinity(doubleVal))
        {
            intVal = 2147483647;
        }
        else if (Cs2Hx.IsNegativeInfinity(doubleVal))
        {
            intVal = -2147483648;
        }
        else
        {
            intVal = Std.int(doubleVal);
        }
        return intVal;
    }
    private function Substring(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        jint.runtime.TypeConverter.CheckObjectCoercible(Engine, thisObj);
        var s:String = jint.runtime.TypeConverter.toString(thisObj);
        var start:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        var end:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 1));
        if (Cs2Hx.IsNaN(start) || start < 0)
        {
            start = 0;
        }
        if (Cs2Hx.IsNaN(end) || end < 0)
        {
            end = 0;
        }
        var len:Int = s.length;
        var intStart:Int = ToIntegerSupportInfinity(start);
        var intEnd:Int = jint.runtime.Arguments.At(arguments, 1).Equals(jint.native.Undefined.Instance) ? len : ToIntegerSupportInfinity(end);
        var finalStart:Int = system.MathCS.Min_Int32_Int32(len, system.MathCS.Max_Int32_Int32(intStart, 0));
        var finalEnd:Int = system.MathCS.Min_Int32_Int32(len, system.MathCS.Max_Int32_Int32(intEnd, 0));
        var from:Int = system.MathCS.Min_Int32_Int32(finalStart, finalEnd);
        var to:Int = system.MathCS.Max_Int32_Int32(finalStart, finalEnd);
        return s.substr(from, to - from);
    }
    private function Substr(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var s:String = jint.runtime.TypeConverter.toString(thisObj);
        var start:Float = jint.runtime.TypeConverter.ToInteger(jint.runtime.Arguments.At(arguments, 0));
        var length:Float = jint.runtime.Arguments.At(arguments, 1).Equals(jint.native.JsValue.Undefined) ? 正无穷大 : jint.runtime.TypeConverter.ToInteger(jint.runtime.Arguments.At(arguments, 1));
        start = start >= 0 ? start : system.MathCS.Max_Double_Double(s.length + start, 0);
        length = system.MathCS.Min_Double_Double(system.MathCS.Max_Double_Double(length, 0), s.length - start);
        if (length <= 0)
        {
            return "";
        }
        return s.substr(jint.runtime.TypeConverter.ToInt32(start), jint.runtime.TypeConverter.ToInt32(length));
    }
    private function Split(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        jint.runtime.TypeConverter.CheckObjectCoercible(Engine, thisObj);
        var s:String = jint.runtime.TypeConverter.toString(thisObj);
        var separator:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var l:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 1);
        var a:jint.native.array.ArrayInstance = cast(Engine.Array.Construct(jint.runtime.Arguments.Empty), jint.native.array.ArrayInstance);
        var limit:Int = l.Equals(jint.native.Undefined.Instance) ? system.UInt32.MaxValue : jint.runtime.TypeConverter.ToUint32(l);
        var len:Int = s.length;
        if (limit == 0)
        {
            return a;
        }
        if (separator.Equals(jint.native.Null.Instance))
        {
            separator = jint.native.Null.Text;
        }
        else if (separator.Equals(jint.native.Undefined.Instance))
        {
            return jint.native.JsValue.op_Explicit_jint_native_array_ArrayInstance(Engine.Array.Construct(jint.runtime.Arguments.From([ s ])));
        }
        else
        {
            if (!separator.IsRegExp())
            {
                separator = jint.runtime.TypeConverter.toString(separator);
            }
        }
        var rx:jint.native.regexp.RegExpInstance = cast(jint.runtime.TypeConverter.ToObject(Engine, separator), jint.native.regexp.RegExpInstance);
        var regExpForMatchingAllCharactere:String = "(?:)";
        if (rx != null && rx.Source != regExpForMatchingAllCharactere)
        {
            var match:system.text.regularexpressions.Match = rx.Value.Match_String_Int32(s, 0);
            if (!match.Success)
            {
                a.DefineOwnProperty("0", new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(s, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
                return a;
            }
            var lastIndex:Int = 0;
            var index:Int = 0;
            while (match.Success && index < limit)
            {
                if (match.Length == 0 && (match.Index == 0 || match.Index == len || match.Index == lastIndex))
                {
                    match = match.NextMatch();
                    continue;
                }
                a.DefineOwnProperty(Std.string(index++), new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(s.substr(lastIndex, match.Index - lastIndex), new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
                if (index >= limit)
                {
                    return a;
                }
                lastIndex = match.Index + match.Length;
                { //for
                    var i:Int = 1;
                    while (i < match.Groups.Count)
                    {
                        var group:system.text.regularexpressions.Group = match.Groups.GetValue_Int32(i);
                        var item:jint.native.JsValue = jint.native.Undefined.Instance;
                        if (group.Captures.Count > 0)
                        {
                            item = match.Groups.GetValue_Int32(i).Value;
                        }
                        a.DefineOwnProperty(Std.string(index++), new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(item, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
                        if (index >= limit)
                        {
                            return a;
                        }
                        i++;
                    }
                } //end for
                match = match.NextMatch();
                if (!match.Success)
                {
                    a.DefineOwnProperty(Std.string(index++), new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(s.substr(lastIndex), new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
                }
            }
            return a;
        }
        else
        {
            var segments:Array<String> = new Array<String>();
            var sep:String = jint.runtime.TypeConverter.toString(separator);
            if (sep == "" || (rx != null && rx.Source == regExpForMatchingAllCharactere))
            {
                for (c in Cs2Hx.ToCharArray(s))
                {
                    segments.push(Cs2Hx.CharToString(c));
                }
            }
            else
            {
                segments = system.linq.Enumerable.ToList(system.Cs2Hx.Split__StringSplitOptions(s, [ sep ], system.StringSplitOptions.None));
            }
            { //for
                var i:Int = 0;
                while (i < segments.length && i < limit)
                {
                    a.DefineOwnProperty(Std.string(i), new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(segments[i], new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
                    i++;
                }
            } //end for
            return a;
        }
    }
    private function Slice(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        jint.runtime.TypeConverter.CheckObjectCoercible(Engine, thisObj);
        var s:String = jint.runtime.TypeConverter.toString(thisObj);
        var start:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 0));
        if (负无穷大.Equals_Double(start))
        {
            start = 0;
        }
        if (正无穷大.Equals_Double(start))
        {
            return "";
        }
        var end:Float = jint.runtime.TypeConverter.ToNumber(jint.runtime.Arguments.At(arguments, 1));
        if (正无穷大.Equals_Double(end))
        {
            end = s.length;
        }
        var len:Int = s.length;
        var intStart:Int = Std.int(jint.runtime.TypeConverter.ToInteger(start));
        var intEnd:Int = jint.runtime.Arguments.At(arguments, 1).Equals(jint.native.Undefined.Instance) ? len : Std.int(jint.runtime.TypeConverter.ToInteger(end));
        var from:Int = intStart < 0 ? system.MathCS.Max_Int32_Int32(len + intStart, 0) : system.MathCS.Min_Int32_Int32(intStart, len);
        var to:Int = intEnd < 0 ? system.MathCS.Max_Int32_Int32(len + intEnd, 0) : system.MathCS.Min_Int32_Int32(intEnd, len);
        var span:Int = system.MathCS.Max_Int32_Int32(to - from, 0);
        return s.substr(from, span);
    }
    private function Search(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        jint.runtime.TypeConverter.CheckObjectCoercible(Engine, thisObj);
        var s:String = jint.runtime.TypeConverter.toString(thisObj);
        var regex:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        if (regex.IsUndefined())
        {
            regex = "";
        }
        else if (regex.IsNull())
        {
            regex = jint.native.Null.Text;
        }
        var rx:jint.native.regexp.RegExpInstance = Cs2Hx.Coalesce(cast(jint.runtime.TypeConverter.ToObject(Engine, regex), jint.native.regexp.RegExpInstance), cast(Engine.RegExp.Construct([ regex ]), jint.native.regexp.RegExpInstance));
        var match:system.text.regularexpressions.Match = rx.Value.Match(s);
        if (!match.Success)
        {
            return -1;
        }
        return match.Index;
    }
    private function Replace(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        jint.runtime.TypeConverter.CheckObjectCoercible(Engine, thisObj);
        var thisString:String = jint.runtime.TypeConverter.toString(thisObj);
        var searchValue:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var replaceValue:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 1);
        var replaceFunction:jint.native.function.FunctionInstance = replaceValue.TryCast();
        if (replaceFunction == null)
        {
            replaceFunction = new jint.runtime.interop.ClrFunctionInstance(Engine, function (self:jint.native.JsValue, args:Array<jint.native.JsValue>):jint.native.JsValue
            {
                var replaceString:String = jint.runtime.TypeConverter.toString(replaceValue);
                var matchValue:String = jint.runtime.TypeConverter.toString(jint.runtime.Arguments.At(args, 0));
                var matchIndex:Int = Std.int(jint.runtime.TypeConverter.ToInteger(jint.runtime.Arguments.At(args, args.length - 2)));
                var replaceTextContainsPattern:Bool = system.Cs2Hx.IndexOfChar(replaceString, 36) >= 0;
                if (replaceTextContainsPattern == false)
                {
                    return replaceString;
                }
                var replacementBuilder:system.text.StringBuilder = new system.text.StringBuilder();
                { //for
                    var i:Int = 0;
                    while (i < replaceString.length)
                    {
                        var c:Int = replaceString.charCodeAt(i);
                        if (c == 36 && i < replaceString.length - 1)
                        {
                            c = replaceString.charCodeAt(++i);
                            if (c == 36)
                            {
                                replacementBuilder.Append_Char(36);
                            }
                            else if (c == 38)
                            {
                                replacementBuilder.Append(matchValue);
                            }
                            else if (c == 96)
                            {
                                replacementBuilder.Append(thisString.substr(0, matchIndex));
                            }
                            else if (c == 39)
                            {
                                replacementBuilder.Append(thisString.substr(matchIndex + matchValue.length));
                            }
                            else if (c >= 48 && c <= 57)
                            {
                                var matchNumber1:Int = c - 48;
                                var matchNumber2:Int = 0;
                                if (i < replaceString.length - 1 && replaceString.charCodeAt(i + 1) >= 48 && replaceString.charCodeAt(i + 1) <= 57)
                                {
                                    matchNumber2 = matchNumber1 * 10 + (replaceString.charCodeAt(i + 1) - 48);
                                }
                                if (matchNumber2 > 0 && matchNumber2 < args.length - 2)
                                {
                                    replacementBuilder.Append(jint.runtime.TypeConverter.toString(args[matchNumber2]));
                                    i++;
                                }
                                else if (matchNumber1 > 0 && matchNumber1 < args.length - 2)
                                {
                                    replacementBuilder.Append(jint.runtime.TypeConverter.toString(args[matchNumber1]));
                                }
                                else
                                {
                                    replacementBuilder.Append_Char(36);
                                    i--;
                                }
                            }
                            else
                            {
                                replacementBuilder.Append_Char(36);
                                replacementBuilder.Append_Char(c);
                            }
                        }
                        else
                        {
                            replacementBuilder.Append_Char(c);
                        }
                        i++;
                    }
                } //end for
                return replacementBuilder.toString();
            }
            );
        }
        if (searchValue.IsNull())
        {
            searchValue = new jint.native.JsValue().Creator_String(jint.native.Null.Text);
        }
        if (searchValue.IsUndefined())
        {
            searchValue = new jint.native.JsValue().Creator_String(jint.native.Undefined.Text);
        }
        var rx:jint.native.regexp.RegExpInstance = cast(jint.runtime.TypeConverter.ToObject(Engine, searchValue), jint.native.regexp.RegExpInstance);
        if (rx != null)
        {
            var result:String = rx.Value.Replace_String_MatchEvaluator_Int32(thisString, function (match:system.text.regularexpressions.Match):String
            {
                var args:Array<jint.native.JsValue> = new Array<jint.native.JsValue>();
                { //for
                    var k:Int = 0;
                    while (k < match.Groups.Count)
                    {
                        var group:system.text.regularexpressions.Group = match.Groups.GetValue_Int32(k);
                        args.push(group.Value);
                        k++;
                    }
                } //end for
                args.push(match.Index);
                args.push(thisString);
                var v:String = jint.runtime.TypeConverter.toString(replaceFunction.Call(jint.native.Undefined.Instance, system.Cs2Hx.ToArray(args)));
                return v;
            }
            , rx.Global == true ? -1 : 1);
            return result;
        }
        else
        {
            var substr:String = jint.runtime.TypeConverter.toString(searchValue);
            var start:Int = thisString.indexOf(substr, system.StringComparison.Ordinal);
            if (start == -1)
            {
                return thisString;
            }
            var end:Int = start + substr.length;
            var args:Array<jint.native.JsValue> = new Array<jint.native.JsValue>();
            args.push(substr);
            args.push(start);
            args.push(thisString);
            var replaceString:String = jint.runtime.TypeConverter.toString(replaceFunction.Call(jint.native.Undefined.Instance, system.Cs2Hx.ToArray(args)));
            var result:system.text.StringBuilder = new system.text.StringBuilder(thisString.length + (substr.length - substr.length));
            result.Append_String_Int32_Int32(thisString, 0, start);
            result.Append(replaceString);
            result.Append_String_Int32_Int32(thisString, end, thisString.length - end);
            return result.toString();
        }
    }
    private function Match(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        jint.runtime.TypeConverter.CheckObjectCoercible(Engine, thisObj);
        var s:String = jint.runtime.TypeConverter.toString(thisObj);
        var regex:jint.native.JsValue = jint.runtime.Arguments.At(arguments, 0);
        var rx:jint.native.regexp.RegExpInstance = regex.TryCast();
        rx = Cs2Hx.Coalesce(rx, cast(Engine.RegExp.Construct([ regex ]), jint.native.regexp.RegExpInstance));
        var global:Bool = rx.Get("global").AsBoolean();
        if (!global)
        {
            return Engine.RegExp.PrototypeObject.Exec(rx, jint.runtime.Arguments.From([ s ]));
        }
        else
        {
            rx.Put("lastIndex", 0, false);
            var a:jint.native.object.ObjectInstance = Engine.Array.Construct(jint.runtime.Arguments.Empty);
            var previousLastIndex:Float = 0;
            var n:Int = 0;
            var lastMatch:Bool = true;
            while (lastMatch)
            {
                var result:jint.native.object.ObjectInstance = Engine.RegExp.PrototypeObject.Exec(rx, jint.runtime.Arguments.From([ s ])).TryCast();
                if (result == null)
                {
                    lastMatch = false;
                }
                else
                {
                    var thisIndex:Float = rx.Get("lastIndex").AsNumber();
                    if (thisIndex == previousLastIndex)
                    {
                        rx.Put("lastIndex", thisIndex + 1, false);
                        previousLastIndex = thisIndex;
                    }
                    var matchStr:jint.native.JsValue = result.Get("0");
                    a.DefineOwnProperty(jint.runtime.TypeConverter.toString(n), new jint.runtime.descriptors.PropertyDescriptor().Creator_JsValue_NullableBoolean_NullableBoolean_NullableBoolean(matchStr, new Nullable_Bool(true), new Nullable_Bool(true), new Nullable_Bool(true)), false);
                    n++;
                }
            }
            if (n == 0)
            {
                return jint.native.Null.Instance;
            }
            return a;
        }
    }
    private function LocaleCompare(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        jint.runtime.TypeConverter.CheckObjectCoercible(Engine, thisObj);
        var s:String = jint.runtime.TypeConverter.toString(thisObj);
        var that:String = jint.runtime.TypeConverter.toString(jint.runtime.Arguments.At(arguments, 0));
        return Cs2Hx.CompareOrdinal(s, that);
    }
    private function LastIndexOf(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        jint.runtime.TypeConverter.CheckObjectCoercible(Engine, thisObj);
        var s:String = jint.runtime.TypeConverter.toString(thisObj);
        var searchStr:String = jint.runtime.TypeConverter.toString(jint.runtime.Arguments.At(arguments, 0));
        var numPos:Float = Math.NaN;
        if (arguments.length > 1 && !arguments[1].Equals(jint.native.Undefined.Instance))
        {
            numPos = jint.runtime.TypeConverter.ToNumber(arguments[1]);
        }
        var pos:Float = Cs2Hx.IsNaN(numPos) ? 正无穷大 : jint.runtime.TypeConverter.ToInteger(numPos);
        var len:Int = s.length;
        var start:Int = Std.int(system.MathCS.Min_Double_Double(system.MathCS.Max_Double_Double(pos, 0), len));
        var searchLen:Int = searchStr.length;
        var i:Int = start;
        var found:Bool;
        do
        {
            found = true;
            var j:Int = 0;
            while (found && j < searchLen)
            {
                if ((i + searchLen > len) || (s.charCodeAt(i + j) != searchStr.charCodeAt(j)))
                {
                    found = false;
                }
                else
                {
                    j++;
                }
            }
            if (!found)
            {
                i--;
            }
        }
        while (!found && i >= 0);
        return i;
    }
    private function IndexOf(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        jint.runtime.TypeConverter.CheckObjectCoercible(Engine, thisObj);
        var s:String = jint.runtime.TypeConverter.toString(thisObj);
        var searchStr:String = jint.runtime.TypeConverter.toString(jint.runtime.Arguments.At(arguments, 0));
        var pos:Float = 0;
        if (arguments.length > 1 && !arguments[1].Equals(jint.native.Undefined.Instance))
        {
            pos = jint.runtime.TypeConverter.ToInteger(arguments[1]);
        }
        if (pos >= s.length)
        {
            return -1;
        }
        if (pos < 0)
        {
            pos = 0;
        }
        return s.indexOf(searchStr, Std.int(pos), system.StringComparison.Ordinal);
    }
    private function Concat(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        jint.runtime.TypeConverter.CheckObjectCoercible(Engine, thisObj);
        var s:String = jint.runtime.TypeConverter.toString(thisObj);
        var sb:system.text.StringBuilder = new system.text.StringBuilder(s);
        { //for
            var i:Int = 0;
            while (i < arguments.length)
            {
                sb.Append(jint.runtime.TypeConverter.toString(arguments[i]));
                i++;
            }
        } //end for
        return sb.toString();
    }
    private function CharCodeAt(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        jint.runtime.TypeConverter.CheckObjectCoercible(Engine, thisObj);
        var pos:jint.native.JsValue = arguments.length > 0 ? arguments[0] : 0;
        var s:String = jint.runtime.TypeConverter.toString(thisObj);
        var position:Int = Std.int(jint.runtime.TypeConverter.ToInteger(pos));
        if (position < 0 || position >= s.length)
        {
            return Math.NaN;
        }
        return s.charCodeAt(position);
    }
    private function CharAt(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        jint.runtime.TypeConverter.CheckObjectCoercible(Engine, thisObj);
        var s:String = jint.runtime.TypeConverter.toString(thisObj);
        var position:Float = jint.runtime.TypeConverter.ToInteger(jint.runtime.Arguments.At(arguments, 0));
        var size:Int = s.length;
        if (position >= size || position < 0)
        {
            return "";
        }
        return Cs2Hx.CharToString(s.charCodeAt(Std.int(position)));
    }
    private function ValueOf(thisObj:jint.native.JsValue, arguments:Array<jint.native.JsValue>):jint.native.JsValue
    {
        var s:jint.native.string.StringInstance = thisObj.TryCast();
        if (s == null)
        {
            return throw new jint.runtime.JavaScriptException().Creator(Engine.TypeError);
        }
        return s.PrimitiveValue;
    }
}
