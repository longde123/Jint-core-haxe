package jint.native.json;
using StringTools;
import system.*;
import anonymoustypes.*;

class JsonParser
{
    private var _engine:jint.Engine;
    public function new(engine:jint.Engine)
    {
        _index = 0;
        _length = 0;
        _lineNumber = 0;
        _lineStart = 0;
        _state = new jint.parser.State();
        _engine = engine;
    }
    private var _extra:jint.native.json.JsonParser_Extra;
    private var _index:Int;
    private var _length:Int;
    private var _lineNumber:Int;
    private var _lineStart:Int;
    private var _location:jint.parser.Location;
    private var _lookahead:jint.native.json.JsonParser_Token;
    private var _source:String;
    private var _state:jint.parser.State;
    private static function IsDecimalDigit(ch:Int):Bool
    {
        return (ch >= 48 && ch <= 57);
    }
    private static function IsHexDigit(ch:Int):Bool
    {
        return ch >= 48 && ch <= 57 || ch >= 97 && ch <= 102 || ch >= 65 && ch <= 70;
    }
    private static function IsOctalDigit(ch:Int):Bool
    {
        return ch >= 48 && ch <= 55;
    }
    private static function IsWhiteSpace(ch:Int):Bool
    {
        return (ch == 32) || (ch == 116) || (ch == 110) || (ch == 114);
    }
    private static function IsLineTerminator(ch:Int):Bool
    {
        return (ch == 10) || (ch == 13) || (ch == 0x2028) || (ch == 0x2029);
    }
    private static function IsNullChar(ch:Int):Bool
    {
        return ch == 110 || ch == 117 || ch == 108 || ch == 108;
    }
    private static function IsTrueOrFalseChar(ch:Int):Bool
    {
        return ch == 116 || ch == 114 || ch == 117 || ch == 101 || ch == 102 || ch == 97 || ch == 108 || ch == 115;
    }
    private function ScanHexEscape(prefix:Int):Int
    {
        var code:Int = Char.MinValue; 
        var len:Int = (prefix == 117) ? 4 : 2;
        { //for
            var i:Int = 0;
            while (i < len)
            {
                if (_index < _length && IsHexDigit(jint.parser.ParserExtensions.CharCodeAt(_source, _index)))
                {
                    var ch:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index++);
                    code = code * 16 + "0123456789abcdef".indexOf(Cs2Hx.CharToString(ch), system.StringComparison.OrdinalIgnoreCase);
                }
                else
                {
                    return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(_engine.SyntaxError, Cs2Hx.Format("Expected hexadecimal digit:{0}", [_source]));
                }
                ++i;
            }
        } //end for
        return code;
    }
    private function SkipWhiteSpace():Void
    {
        while (_index < _length)
        {
            var ch:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
            if (IsWhiteSpace(ch))
            {
                ++_index;
            }
            else
            {
                break;
            }
        }
    }
    private function ScanPunctuator():jint.native.json.JsonParser_Token
    {
        var start:Int = _index;
        var code:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
        switch (code)
        {
            case 46, 40, 41, 59, 44, 123, 125, 91, 93, 58, 63, 126:
                ++_index;
                var token:jint.native.json.JsonParser_Token = new jint.native.json.JsonParser_Token();
                token.Type = jint.native.json.JsonParser_Tokens.Punctuator;
                token.Value = Cs2Hx.CharToString(code);
                token.LineNumber = (_lineNumber);
                token.LineStart = _lineStart;
                token.Range = [ start, _index ];
                return token;
        }
        return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(_engine.SyntaxError, Cs2Hx.Format(jint.native.json.JsonParser_Messages.UnexpectedToken, [code]));
    }
    private function ScanNumericLiteral():jint.native.json.JsonParser_Token
    {
        var ch:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
        var start:Int = _index;
        var number:String = "";
        if (ch == 45)
        {
            number += Cs2Hx.CharToString(jint.parser.ParserExtensions.CharCodeAt(_source, _index++));
            ch = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
        }
        if (ch != 46)
        {
            number += Cs2Hx.CharToString(jint.parser.ParserExtensions.CharCodeAt(_source, _index++));
            ch = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
            if (number == "0")
            {
                if (ch > 0 && IsDecimalDigit(ch))
                {
                    return throw new system.Exception(jint.native.json.JsonParser_Messages.UnexpectedToken);
                }
            }
            while (IsDecimalDigit(jint.parser.ParserExtensions.CharCodeAt(_source, _index)))
            {
                number += Cs2Hx.CharToString(jint.parser.ParserExtensions.CharCodeAt(_source, _index++));
            }
            ch = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
        }
        if (ch == 46)
        {
            number += Cs2Hx.CharToString(jint.parser.ParserExtensions.CharCodeAt(_source, _index++));
            while (IsDecimalDigit(jint.parser.ParserExtensions.CharCodeAt(_source, _index)))
            {
                number += Cs2Hx.CharToString(jint.parser.ParserExtensions.CharCodeAt(_source, _index++));
            }
            ch = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
        }
        if (ch == 101 || ch == 69)
        {
            number += Cs2Hx.CharToString(jint.parser.ParserExtensions.CharCodeAt(_source, _index++));
            ch = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
            if (ch == 43 || ch == 45)
            {
                number += Cs2Hx.CharToString(jint.parser.ParserExtensions.CharCodeAt(_source, _index++));
            }
            if (IsDecimalDigit(jint.parser.ParserExtensions.CharCodeAt(_source, _index)))
            {
                while (IsDecimalDigit(jint.parser.ParserExtensions.CharCodeAt(_source, _index)))
                {
                    number += Cs2Hx.CharToString(jint.parser.ParserExtensions.CharCodeAt(_source, _index++));
                }
            }
            else
            {
                return throw new system.Exception(jint.native.json.JsonParser_Messages.UnexpectedToken);
            }
        }
        var token:jint.native.json.JsonParser_Token = new jint.native.json.JsonParser_Token();
        token.Type = jint.native.json.JsonParser_Tokens.Number;
        token.Value = Std.parseFloat(number);
        token.LineNumber = (_lineNumber);
        token.LineStart = _lineStart;
        token.Range = [ start, _index ];
        return token;
    }
    private function ScanBooleanLiteral():jint.native.json.JsonParser_Token
    {
        var start:Int = _index;
        var s:String = "";
        while (IsTrueOrFalseChar(jint.parser.ParserExtensions.CharCodeAt(_source, _index)))
        {
            s += Cs2Hx.CharToString(jint.parser.ParserExtensions.CharCodeAt(_source, _index++));
        }
        if (s == "true" || s == "false")
        {
            var token:jint.native.json.JsonParser_Token = new jint.native.json.JsonParser_Token();
            token.Type = jint.native.json.JsonParser_Tokens.BooleanLiteral;
            token.Value = s == "true";
            token.LineNumber = (_lineNumber);
            token.LineStart = _lineStart;
            token.Range = [ start, _index ];
            return token;
        }
        else
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(_engine.SyntaxError, Cs2Hx.Format(jint.native.json.JsonParser_Messages.UnexpectedToken,[ s]));
        }
    }
    private function ScanNullLiteral():jint.native.json.JsonParser_Token
    {
        var start:Int = _index;
        var s:String = "";
        while (IsNullChar(jint.parser.ParserExtensions.CharCodeAt(_source, _index)))
        {
            s += Cs2Hx.CharToString(jint.parser.ParserExtensions.CharCodeAt(_source, _index++));
        }
        if (s == jint.native.Null.Text)
        {
            var token:jint.native.json.JsonParser_Token = new jint.native.json.JsonParser_Token();
            token.Type = jint.native.json.JsonParser_Tokens.NullLiteral;
            token.Value = jint.native.Null.Instance;
            token.LineNumber = (_lineNumber);
            token.LineStart = _lineStart;
            token.Range = [ start, _index ];
            return token;
        }
        else
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(_engine.SyntaxError, Cs2Hx.Format(jint.native.json.JsonParser_Messages.UnexpectedToken, [s]));
        }
    }
    private function ScanStringLiteral():jint.native.json.JsonParser_Token
    {
        var str:String = "";
        var quote:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
        var start:Int = _index;
        ++_index;
        while (_index < _length)
        {
            var ch:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index++);
            if (ch == quote)
            {
                quote = Char.MinValue; 
                break;
            }
            if (ch <= 31)
            {
                return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(_engine.SyntaxError, Cs2Hx.Format("Invalid character '{0}', position:{1}, string:{2}", [ch, _index, _source]));
            }
            if (ch == 92)
            {
                ch = jint.parser.ParserExtensions.CharCodeAt(_source, _index++);
                if (ch > 0 || !IsLineTerminator(ch))
                {
                    switch (ch)
                    {
                        case 110:
                            str += 110;
                        case 114:
                            str += 114;
                        case 116:
                            str += 116;
                        case 117, 120:
                            var restore:Int = _index;
                            var unescaped:Int = ScanHexEscape(ch);
                            if (unescaped > 0)
                            {
                                str += Cs2Hx.CharToString(unescaped);
                            }
                            else
                            {
                                _index = restore;
                                str += Cs2Hx.CharToString(ch);
                            }
                        case 98:
                            str += "\\b";
                        case 102:
                            str += "\\f";
                        case 118:
                            str += "\\x0B";
                        default:
                            if (IsOctalDigit(ch))
                            {
                                var code:Int = system.Cs2Hx.IndexOfChar("01234567", ch);
                                if (_index < _length && IsOctalDigit(jint.parser.ParserExtensions.CharCodeAt(_source, _index)))
                                {
                                    code = code * 8 + system.Cs2Hx.IndexOfChar("01234567", jint.parser.ParserExtensions.CharCodeAt(_source, _index++));
                                    if (system.Cs2Hx.IndexOfChar("0123", ch) >= 0 && _index < _length && IsOctalDigit(jint.parser.ParserExtensions.CharCodeAt(_source, _index)))
                                    {
                                        code = code * 8 + system.Cs2Hx.IndexOfChar("01234567", jint.parser.ParserExtensions.CharCodeAt(_source, _index++));
                                    }
                                }
                                str += Cs2Hx.CharToString((code));
                            }
                            else
                            {
                                str += Cs2Hx.CharToString(ch);
                            }
                    }
                }
                else
                {
                    ++_lineNumber;
                    if (ch == 114 && jint.parser.ParserExtensions.CharCodeAt(_source, _index) == 110)
                    {
                        ++_index;
                    }
                }
            }
            else if (IsLineTerminator(ch))
            {
                break;
            }
            else
            {
                str += Cs2Hx.CharToString(ch);
            }
        }
        if (quote != 0)
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(_engine.SyntaxError, Cs2Hx.Format(jint.native.json.JsonParser_Messages.UnexpectedToken, [_source]));
        }
        var token:jint.native.json.JsonParser_Token = new jint.native.json.JsonParser_Token();
        token.Type = jint.native.json.JsonParser_Tokens.String;
        token.Value = str;
        token.LineNumber = (_lineNumber);
        token.LineStart = _lineStart;
        token.Range = [ start, _index ];
        return token;
    }
    private function Advance():jint.native.json.JsonParser_Token
    {
        SkipWhiteSpace();
        if (_index >= _length)
        {
            var token:jint.native.json.JsonParser_Token = new jint.native.json.JsonParser_Token();
            token.Type = jint.native.json.JsonParser_Tokens.EOF;
            token.LineNumber = (_lineNumber);
            token.LineStart = _lineStart;
            token.Range = [ _index, _index ];
            return token;
        }
        var ch:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
        if (ch == 40 || ch == 41 || ch == 58)
        {
            return ScanPunctuator();
        }
        if (ch == 34)
        {
            return ScanStringLiteral();
        }
        if (ch == 46)
        {
            if (IsDecimalDigit(jint.parser.ParserExtensions.CharCodeAt(_source, _index + 1)))
            {
                return ScanNumericLiteral();
            }
            return ScanPunctuator();
        }
        if (ch == 45)
        {
            if (IsDecimalDigit(jint.parser.ParserExtensions.CharCodeAt(_source, _index + 1)))
            {
                return ScanNumericLiteral();
            }
            return ScanPunctuator();
        }
        if (IsDecimalDigit(ch))
        {
            return ScanNumericLiteral();
        }
        if (ch == 116 || ch == 102)
        {
            return ScanBooleanLiteral();
        }
        if (ch == 110)
        {
            return ScanNullLiteral();
        }
        return ScanPunctuator();
    }
    private function CollectToken():jint.native.json.JsonParser_Token
    {
        _location = new jint.parser.Location();
        _location.Start = new jint.parser.Position();
        _location.Start.Line = _lineNumber;
        _location.Start.Column = _index - _lineStart;
        var token:jint.native.json.JsonParser_Token = Advance();
        _location.End = new jint.parser.Position();
        _location.End.Line = _lineNumber;
        _location.End.Column = _index - _lineStart;
        if (token.Type != jint.native.json.JsonParser_Tokens.EOF)
        {
            var range:Array<Int> = [ token.Range[0], token.Range[1] ];
            var value:String = jint.parser.ParserExtensions.Slice(_source, token.Range[0], token.Range[1]);
            var token_:jint.native.json.JsonParser_Token = new jint.native.json.JsonParser_Token();
            token_.Type = token.Type;
            token_.Value = value;
            token_.Range = range;
            _extra.Tokens.push(token_);
        }
        return token;
    }
    private function Lex():jint.native.json.JsonParser_Token
    {
        var token:jint.native.json.JsonParser_Token = _lookahead;
        _index = token.Range[1];
        _lineNumber = token.LineNumber!=null ? token.LineNumber : 0;
        _lineStart = token.LineStart;
        _lookahead = (_extra.Tokens != null) ? CollectToken() : Advance();
        _index = token.Range[1];
        _lineNumber = token.LineNumber!=null ? token.LineNumber : 0;
        _lineStart = token.LineStart;
        return token;
    }
    private function Peek():Void
    {
        var pos:Int = _index;
        var line:Int = _lineNumber;
        var start:Int = _lineStart;
        _lookahead = (_extra.Tokens != null) ? CollectToken() : Advance();
        _index = pos;
        _lineNumber = line;
        _lineStart = start;
    }
    private function MarkStart():Void
    {
        if (_extra.Loc!=null)
        {
            _state.MarkerStack.push(_index - _lineStart);
            _state.MarkerStack.push(_lineNumber);
        }
        if (_extra.Range != null)
        {
            _state.MarkerStack.push(_index);
        }
    }
    private function MarkEnd<T: (jint.parser.ast.SyntaxNode)>(node:T):T
    {
        if (_extra.Range != null)
        {
            node.Range = [ _state.MarkerStack.pop(), _index ];
        }
        if (_extra.Loc!=null)
        {
            node.Location = new jint.parser.Location();
            node.Location.Start = new jint.parser.Position();
            node.Location.Start.Line = _state.MarkerStack.pop();
            node.Location.Start.Column = _state.MarkerStack.pop();
            node.Location.End = new jint.parser.Position();
            node.Location.End.Line = _lineNumber;
            node.Location.End.Column = _index - _lineStart;
            PostProcess(node);
        }
        return node;
    }
    public function MarkEndIf<T: (jint.parser.ast.SyntaxNode)>(node:T):T
    {
        if (node.Range != null || node.Location != null)
        {
            if (_extra.Loc!=null)
            {
                _state.MarkerStack.pop();
                _state.MarkerStack.pop();
            }
            if (_extra.Range != null)
            {
                _state.MarkerStack.pop();
            }
        }
        else
        {
            MarkEnd(node);
        }
        return node;
    }
    public function PostProcess(node:jint.parser.ast.SyntaxNode):jint.parser.ast.SyntaxNode
    {
        if (_extra.Source != null)
        {
            node.Location.Source = _extra.Source;
        }
        return node;
    }
    public function CreateArrayInstance(values:Array<jint.native.JsValue>):jint.native.object.ObjectInstance
    {
        var jsArray:jint.native.object.ObjectInstance = _engine.JArray.Construct(jint.runtime.Arguments.Empty);
        _engine.JArray.PrototypeObject.Push(jsArray,  (values));
        return jsArray;
    }
    private function ThrowError(token:jint.native.json.JsonParser_Token, messageFormat:String, ?arguments:Array<Dynamic>):Void
    {
        var exception:jint.parser.ParserException;
        var msg:String = Cs2Hx.Format(messageFormat, arguments);
        if (token.LineNumber!=null)
        {
            exception = new jint.parser.ParserException("Line " + token.LineNumber + ": " + msg);
            exception.Index = token.Range[0];
            exception.LineNumber = token.LineNumber;
            exception.Column = token.Range[0] - _lineStart + 1;
        }
        else
        {
            exception = new jint.parser.ParserException("Line " + _lineNumber + ": " + msg);
            exception.Index = _index;
            exception.LineNumber = _lineNumber;
            exception.Column = _index - _lineStart + 1;
        }
        exception.Description = msg;
        throw exception;
    }
    private function ThrowUnexpected(token:jint.native.json.JsonParser_Token):Void
    {
        if (token.Type == jint.native.json.JsonParser_Tokens.EOF)
        {
            ThrowError(token, jint.native.json.JsonParser_Messages.UnexpectedEOS);
        }
        if (token.Type == jint.native.json.JsonParser_Tokens.Number)
        {
            ThrowError(token, jint.native.json.JsonParser_Messages.UnexpectedNumber);
        }
        if (token.Type == jint.native.json.JsonParser_Tokens.String)
        {
            ThrowError(token, jint.native.json.JsonParser_Messages.UnexpectedString);
        }
        ThrowError(token, jint.native.json.JsonParser_Messages.UnexpectedToken, [ token.Value ]);
    }
    private function Expect(value:String):Void
    {
        var token:jint.native.json.JsonParser_Token = Lex();
        if (token.Type != jint.native.json.JsonParser_Tokens.Punctuator || (value!= token.Value))
        {
            ThrowUnexpected(token);
        }
    }
    private function Match(value:String):Bool
    {
        return _lookahead.Type == jint.native.json.JsonParser_Tokens.Punctuator && (value== _lookahead.Value);
    }
    private function ParseJsonArray():jint.native.object.ObjectInstance
    {
        var elements:Array<jint.native.JsValue> = new Array<jint.native.JsValue>();
        Expect("[");
        while (!Match("]"))
        {
            if (Match(","))
            {
                Lex();
                elements.push(jint.native.Null.Instance);
            }
            else
            {
                elements.push(ParseJsonValue());
                if (!Match("]"))
                {
                    Expect(",");
                }
            }
        }
        Expect("]");
        return CreateArrayInstance(elements);
    }
    public function ParseJsonObject():jint.native.object.ObjectInstance
    {
        Expect("{");
        var obj:jint.native.object.ObjectInstance = _engine.JObject.Construct(jint.runtime.Arguments.Empty);
        while (!Match("}"))
        {
            var type:Int = _lookahead.Type;
            if (type != jint.native.json.JsonParser_Tokens.String)
            {
                ThrowUnexpected(Lex());
            }
            var name:String = Lex().Value.toString();
            if (PropertyNameContainsInvalidChar0To31(name))
            {
                return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(_engine.SyntaxError, Cs2Hx.Format("Invalid character in property name '{0}'",[ name]));
            }
            Expect(":");
            var value:jint.native.JsValue = ParseJsonValue();
            obj.FastAddProperty(name, value, true, true, true);
            if (!Match("}"))
            {
                Expect(",");
            }
        }
        Expect("}");
        return obj;
    }
    private function PropertyNameContainsInvalidChar0To31(s:String):Bool
    {
        var max:Int = 31;
        { //for
            var i:Int = 0;
            while (i < s.length)
            {
                var val:Int = s.charCodeAt(i);
                if (val <= max)
                {
                    return true;
                }
                i++;
            }
        } //end for
        return false;
    }
    private function ParseJsonValue():jint.native.JsValue
    {
        var type:Int = _lookahead.Type;
        MarkStart();
        switch (type)
        {
            case jint.native.json.JsonParser_Tokens.NullLiteral:
                var v:Dynamic = Lex().Value;
                return jint.native.Null.Instance;
            case jint.native.json.JsonParser_Tokens.BooleanLiteral:
                return (Lex().Value);
            case jint.native.json.JsonParser_Tokens.String:
                return (Lex().Value);
            case jint.native.json.JsonParser_Tokens.Number:
                return (Lex().Value);
        }
        if (Match("["))
        {
            return ParseJsonArray();
        }
        if (Match("{"))
        {
            return ParseJsonObject();
        }
        ThrowUnexpected(Lex());
        return jint.native.Null.Instance;
    }
    public function Parse(code:String):jint.native.JsValue
    {
        return Parse_String_ParserOptions(code, null);
    }
    public function Parse_String_ParserOptions(code:String, options:jint.parser.ParserOptions):jint.native.JsValue
    {
        _source = code;
        _index = 0;
        _lineNumber = (_source.length > 0) ? 1 : 0;
        _lineStart = 0;
        _length = _source.length;
        _lookahead = null;
        _state = new jint.parser.State();
        _state.AllowIn = true;
        _state.LabelSet = new system.collections.generic.HashSet<String>();
        _state.InFunctionBody = false;
        _state.InIteration = false;
        _state.InSwitch = false;
        _state.LastCommentStart = -1;
        _state.MarkerStack = new Array<Int>();
        _extra = new jint.native.json.JsonParser_Extra();
        _extra.Range = [  ];
        _extra.Loc = (0);
        if (options != null)
        {
            if (!system.Cs2Hx.IsNullOrEmpty(options.Source))
            {
                _extra.Source = options.Source;
            }
            if (options.Tokens)
            {
                _extra.Tokens = new Array<jint.native.json.JsonParser_Token>();
            }
        }
        MarkStart();
        Peek();
        var jsv:jint.native.JsValue = ParseJsonValue();
        Peek();
        var type:Int = _lookahead.Type;
        var value:Dynamic = _lookahead.Value;
        if (_lookahead.Type != jint.native.json.JsonParser_Tokens.EOF)
        {
            return throw new jint.runtime.JavaScriptException().Creator_ErrorConstructor_String(_engine.SyntaxError, Cs2Hx.Format("Unexpected {0} {1}", [_lookahead.Type, _lookahead.Value]));
        }
        return jsv;
        _extra = new jint.native.json.JsonParser_Extra();
    }
}
