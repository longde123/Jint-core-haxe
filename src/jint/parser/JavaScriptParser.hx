package jint.parser;
using StringTools;
import haxe.ds.StringMap;
import jint.parser.ast.*; 
import system.*;
import anonymoustypes.*;
 

class JavaScriptParser
{
    private static var Keywords:Array<String>;
    private static var StrictModeReservedWords:Array<String>;
    private static var FutureReservedWords:Array<String>;
    private var _extra:jint.parser.JavaScriptParser_Extra;
    private var _index:Int;
    private var _length:Int;
    private var _lineNumber:Int;
    private var _lineStart:Int;
    private var _location:jint.parser.Location;
    private var _lookahead:jint.parser.Token;
    private var _source:String;
    private var _state:jint.parser.State;
    private var _strict:Bool;
    private var _variableScopes:Array<jint.parser.IVariableScope>;
    private var _functionScopes:Array<jint.parser.IFunctionScope>;
    public function new()
    {
        _index = 0;
        _length = 0;
        _lineNumber = 0;
        _lineStart = 0;
        _state = new jint.parser.State();
        _strict = false;
        _variableScopes = new Array<jint.parser.IVariableScope>();
        _functionScopes = new Array<jint.parser.IFunctionScope>();
    }
    public function Creator(strict:Bool):jint.parser.JavaScriptParser
    {
        _strict = strict;
        return this;
    }
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
        return (ch == 32) || (ch == 9) || (ch == 0xB) || (ch == 0xC) || (ch == 0xA0) || (ch >= 0x1680 && (ch == 0x1680 || ch == 0x180E || (ch >= 0x2000 && ch <= 0x200A) || ch == 0x202F || ch == 0x205F || ch == 0x3000 || ch == 0xFEFF));
    }
    private static function IsLineTerminator(ch:Int):Bool
    {
        return (ch == 10) || (ch == 13) || (ch == 0x2028) || (ch == 0x2029);
    }
    private static function IsIdentifierStart(ch:Int):Bool
    {
        return (ch == 36) || (ch == 95) || (ch >= 65 && ch <= 90) || (ch >= 97 && ch <= 122) || (ch == 92) || ((ch >= 0x80) && jint.parser.JavaScriptParser_Regexes.NonAsciiIdentifierStart.match(Cs2Hx.CharToString(ch)));
    }
    private static function IsIdentifierPart(ch:Int):Bool
    {
        return (ch == 36) || (ch == 95) || (ch >= 65 && ch <= 90) || (ch >= 97 && ch <= 122) || (ch >= 48 && ch <= 57) || (ch == 92) || ((ch >= 0x80) && jint.parser.JavaScriptParser_Regexes.NonAsciiIdentifierPart.match(Cs2Hx.CharToString(ch)));
    }
	
	
    private static function IsFutureReservedWord(id:String):Bool
    {
        return system.Cs2Hx.Contains(FutureReservedWords, id);
    }
    private static function IsStrictModeReservedWord(id:String):Bool
    {
        return system.Cs2Hx.Contains(StrictModeReservedWords, id);
    }
    private static function IsRestrictedWord(id:String):Bool
    {
        return system.Cs2Hx.Equals_String("eval", id) || system.Cs2Hx.Equals_String("arguments", id);
    }
    private function IsKeyword(id:String):Bool
    {
        if (_strict && IsStrictModeReservedWord(id))
        {
            return true;
        }
        return system.Cs2Hx.Contains(Keywords, id);
    }
    private function AddComment(type:String, value:String, start:Int, end:Int, location:jint.parser.Location):Void
    {
        if (_state.LastCommentStart >= start)
        {
            return;
        }
        _state.LastCommentStart = start;
        var comment:jint.parser.Comment = new jint.parser.Comment();
        comment.Type = type;
        comment.Value = value;
        if (_extra.Range != null)
        {
            comment.Range = [ start, end ];
        }
        if (_extra.LocHasValue)
        {
            comment.Location = location;
        }
        _extra.Comments.push(comment);
    }
    private function SkipSingleLineComment(offset:Int):Void
    {
        var start:Int = _index - offset;
        _location = new jint.parser.Location();
        _location.Start = new jint.parser.Position();
        _location.Start.Line = _lineNumber;
        _location.Start.Column = _index - _lineStart - offset;
        while (_index < _length)
        {
            var ch:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
            ++_index;
            if (IsLineTerminator(ch))
            {
                if (_extra.Comments != null)
                {
                    var comment:String = jint.parser.ParserExtensions.Slice(_source, start + 2, _index - 1);
                    _location.End = new jint.parser.Position();
                    _location.End.Line = _lineNumber;
                    _location.End.Column = _index - _lineStart - 1;
                    AddComment("Line", comment, start, _index - 1, _location);
                }
                if (ch == 13 && jint.parser.ParserExtensions.CharCodeAt(_source, _index) == 10)
                {
                    ++_index;
                }
                ++_lineNumber;
                _lineStart = _index;
                return;
            }
        }
        if (_extra.Comments != null)
        {
            var comment:String = jint.parser.ParserExtensions.Slice(_source, start + offset, _index);
            _location.End = new jint.parser.Position();
            _location.End.Line = _lineNumber;
            _location.End.Column = _index - _lineStart;
            AddComment("Line", comment, start, _index, _location);
        }
    }
    private function SkipMultiLineComment():Void
    {
        var start:Int = 0;
        if (_extra.Comments != null)
        {
            start = _index - 2;
            _location = new jint.parser.Location();
            _location.Start = new jint.parser.Position();
            _location.Start.Line = _lineNumber;
            _location.Start.Column = _index - _lineStart - 2;
        }
        while (_index < _length)
        {
            var ch:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
            if (IsLineTerminator(ch))
            {
                if (ch == 13 && jint.parser.ParserExtensions.CharCodeAt(_source, _index + 1) == 10)
                {
                    ++_index;
                }
                ++_lineNumber;
                ++_index;
                _lineStart = _index;
                if (_index >= _length)
                {
                    ThrowError(null, jint.parser.Messages.UnexpectedToken, [ "ILLEGAL" ]);
                }
            }
            else if (ch == 42)
            {
                if (jint.parser.ParserExtensions.CharCodeAt(_source, _index + 1) == 47)
                {
                    ++_index;
                    ++_index;
                    if (_extra.Comments != null)
                    {
                        var comment:String = jint.parser.ParserExtensions.Slice(_source, start + 2, _index - 2);
                        _location.End = new jint.parser.Position();
                        _location.End.Line = _lineNumber;
                        _location.End.Column = _index - _lineStart;
                        AddComment("Block", comment, start, _index, _location);
                    }
                    return;
                }
                ++_index;
            }
            else
            {
                ++_index;
            }
        }
        ThrowError(null, jint.parser.Messages.UnexpectedToken, [ "ILLEGAL" ]);
    }
    private function SkipComment():Void
    {
        var start:Bool = _index == 0;
        while (_index < _length)
        {
            var ch:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
            if (IsWhiteSpace(ch))
            {
                ++_index;
            }
            else if (IsLineTerminator(ch))
            {
                ++_index;
                if (ch == 13 && jint.parser.ParserExtensions.CharCodeAt(_source, _index) == 10)
                {
                    ++_index;
                }
                ++_lineNumber;
                _lineStart = _index;
                start = true;
            }
            else if (ch == 47)
            {
                ch = jint.parser.ParserExtensions.CharCodeAt(_source, _index + 1);
                if (ch == 47)
                {
                    ++_index;
                    ++_index;
                    SkipSingleLineComment(2);
                    start = true;
                }
                else if (ch == 42)
                {
                    ++_index;
                    ++_index;
                    SkipMultiLineComment();
                }
                else
                {
                    break;
                }
            }
            else if (start && ch == 45)
            {
                if (jint.parser.ParserExtensions.CharCodeAt(_source, _index + 1) == 45 && jint.parser.ParserExtensions.CharCodeAt(_source, _index + 2) == 62)
                {
                    _index += 3;
                    SkipSingleLineComment(3);
                }
                else
                {
                    break;
                }
            }
            else if (ch == 60)
            {
                if (jint.parser.ParserExtensions.Slice(_source, _index + 1, _index + 4) == "!--")
                {
                    ++_index;
                    ++_index;
                    ++_index;
                    ++_index;
                    SkipSingleLineComment(4);
                }
                else
                {
                    break;
                }
            }
            else
            {
                break;
            }
        }
    }
    private function ScanHexEscape(prefix:Int, result:Null<Int>):Bool
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
                    result = Char.MinValue;
                    return false;
                }
                ++i;
            }
        } //end for
        result = code;
        return true;
    }
    private function GetEscapedIdentifier():String
    {
        var ch:Null<Int> = jint.parser.ParserExtensions.CharCodeAt(_source, _index++);
        var id:system.text.StringBuilder = new system.text.StringBuilder(Cs2Hx.CharToString(ch));
        if (ch == 92)
        {
            if (jint.parser.ParserExtensions.CharCodeAt(_source, _index) != 117)
            {
                ThrowError(null, jint.parser.Messages.UnexpectedToken, [ "ILLEGAL" ]);
            }
            ++_index;
            if (!ScanHexEscape(117, ch) || ch == 92 || !IsIdentifierStart(ch))
            {
                ThrowError(null, jint.parser.Messages.UnexpectedToken, [ "ILLEGAL" ]);
            }
            id = new system.text.StringBuilder(Cs2Hx.CharToString(ch));
        }
        while (_index < _length)
        {
            ch = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
            if (!IsIdentifierPart(ch))
            {
                break;
            }
            ++_index;
            if (ch == 92)
            {
                if (jint.parser.ParserExtensions.CharCodeAt(_source, _index) != 117)
                {
                    ThrowError(null, jint.parser.Messages.UnexpectedToken, [ "ILLEGAL" ]);
                }
                ++_index;
                if (!ScanHexEscape(117, ch) || ch == 92 || !IsIdentifierPart(ch))
                {
                    ThrowError(null, jint.parser.Messages.UnexpectedToken, [ "ILLEGAL" ]);
                }
                id.Append_Char(ch);
            }
            else
            {
                id.Append_Char(ch);
            }
        }
        return id.toString();
    }
    private function GetIdentifier():String
    {
        var start:Int = _index++;
        while (_index < _length)
        {
            var ch:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
            if (ch == 92)
            {
                _index = start;
                return GetEscapedIdentifier();
            }
            if (IsIdentifierPart(ch))
            {
                ++_index;
            }
            else
            {
                break;
            }
        }
        return jint.parser.ParserExtensions.Slice(_source, start, _index);
    }
    private function ScanIdentifier():jint.parser.Token
    {
        var start:Int = _index;
        var type:Int;
        var id:String = (jint.parser.ParserExtensions.CharCodeAt(_source, _index) == 92) ? GetEscapedIdentifier() : GetIdentifier();
        if (id.length == 1)
        {
            type = jint.parser.Tokens.Identifier;
        }
        else if (IsKeyword(id))
        {
            type = jint.parser.Tokens.Keyword;
        }
        else if (system.Cs2Hx.Equals_String("null", id))
        {
            type = jint.parser.Tokens.NullLiteral;
        }
        else if (system.Cs2Hx.Equals_String("true", id) || system.Cs2Hx.Equals_String("false", id))
        {
            type = jint.parser.Tokens.BooleanLiteral;
        }
        else
        {
            type = jint.parser.Tokens.Identifier;
        }
        var token:jint.parser.Token = new jint.parser.Token();
        token.Type = type;
        token.Value = id;
        token.LineNumber = _lineNumber;
        token.LineStart = _lineStart;
        token.Range = [ start, _index ];
        return token;
    }
    private function ScanPunctuator():jint.parser.Token
    {
        var start:Int = _index;
        var code:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
        var ch1:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
        switch (code)
        {
            case 46, 40, 41, 59, 44, 123, 125, 91, 93, 58, 63, 126:
                {
                    ++_index;
                    var token:jint.parser.Token = new jint.parser.Token();
                    token.Type = jint.parser.Tokens.Punctuator;
                    token.Value = Cs2Hx.CharToString(code);
                    token.LineNumber = (_lineNumber);
                    token.LineStart = _lineStart;
                    token.Range = [ start, _index ];
                    return token;
                }
            default:
                var code2:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index + 1);
                if (code2 == 61)
                {
                    switch (code)
                    {
                        case 37, 38, 42, 43, 45, 47, 60, 62, 94, 124:
                            {
                                _index += 2;
                                var token:jint.parser.Token = new jint.parser.Token();
                                token.Type = jint.parser.Tokens.Punctuator;
                                token.Value = Cs2Hx.CharToString(code) + Cs2Hx.CharToString(code2);
                                token.LineNumber = (_lineNumber);
                                token.LineStart = _lineStart;
                                token.Range = [ start, _index ];
                                return token;
                            }
                        case 33, 61:
                            {
                                _index += 2;
                                if (jint.parser.ParserExtensions.CharCodeAt(_source, _index) == 61)
                                {
                                    ++_index;
                                }
                                var token:jint.parser.Token = new jint.parser.Token();
                                token.Type = jint.parser.Tokens.Punctuator;
                                token.Value = jint.parser.ParserExtensions.Slice(_source, start, _index);
                                token.LineNumber = (_lineNumber);
                                token.LineStart = _lineStart;
                                token.Range = [ start, _index ];
                                return token;
                            }
                    }
                }
        }
        var ch2:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index + 1);
        var ch3:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index + 2);
        var ch4:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index + 3);
        if (ch1 == 62 && ch2 == 62 && ch3 == 62)
        {
            if (ch4 == 61)
            {
                _index += 4;
                var token:jint.parser.Token = new jint.parser.Token();
                token.Type = jint.parser.Tokens.Punctuator;
                token.Value = ">>>=";
                token.LineNumber = (_lineNumber);
                token.LineStart = _lineStart;
                token.Range = [ start, _index ];
                return token;
            }
        }
        if (ch1 == 62 && ch2 == 62 && ch3 == 62)
        {
            _index += 3;
            var token:jint.parser.Token = new jint.parser.Token();
            token.Type = jint.parser.Tokens.Punctuator;
            token.Value = ">>>";
            token.LineNumber = (_lineNumber);
            token.LineStart = _lineStart;
            token.Range = [ start, _index ];
            return token;
        }
        if (ch1 == 60 && ch2 == 60 && ch3 == 61)
        {
            _index += 3;
            var token:jint.parser.Token = new jint.parser.Token();
            token.Type = jint.parser.Tokens.Punctuator;
            token.Value = "<<=";
            token.LineNumber = (_lineNumber);
            token.LineStart = _lineStart;
            token.Range = [ start, _index ];
            return token;
        }
        if (ch1 == 62 && ch2 == 62 && ch3 == 61)
        {
            _index += 3;
            var token:jint.parser.Token = new jint.parser.Token();
            token.Type = jint.parser.Tokens.Punctuator;
            token.Value = ">>=";
            token.LineNumber = (_lineNumber);
            token.LineStart = _lineStart;
            token.Range = [ start, _index ];
            return token;
        }
        if (ch1 == ch2 && (system.Cs2Hx.IndexOfChar("+-<>&|", ch1) >= 0))
        {
            _index += 2;
            var token:jint.parser.Token = new jint.parser.Token();
            token.Type = jint.parser.Tokens.Punctuator;
            token.Value = Cs2Hx.CharToString(ch1) + Cs2Hx.CharToString(ch2);
            token.LineNumber = (_lineNumber);
            token.LineStart = _lineStart;
            token.Range = [ start, _index ];
            return token;
        }
        if (system.Cs2Hx.IndexOfChar("<>=!+-*%&|^/", ch1) >= 0)
        {
            ++_index;
            var token:jint.parser.Token = new jint.parser.Token();
            token.Type = jint.parser.Tokens.Punctuator;
            token.Value = Cs2Hx.CharToString(ch1);
            token.LineNumber = (_lineNumber);
            token.LineStart = _lineStart;
            token.Range = [ start, _index ];
            return token;
        }
        ThrowError(null, jint.parser.Messages.UnexpectedToken, [ "ILLEGAL" ]);
        return null;
    }
    private function ScanHexLiteral(start:Int):jint.parser.Token
    {
        var number:String = "";
        while (_index < _length)
        {
            if (!IsHexDigit(jint.parser.ParserExtensions.CharCodeAt(_source, _index)))
            {
                break;
            }
            number += Cs2Hx.CharToString(jint.parser.ParserExtensions.CharCodeAt(_source, _index++));
        }
        if (number.length == 0)
        {
            ThrowError(null, jint.parser.Messages.UnexpectedToken, [ "ILLEGAL" ]);
        }
        if (IsIdentifierStart(jint.parser.ParserExtensions.CharCodeAt(_source, _index)))
        {
            ThrowError(null, jint.parser.Messages.UnexpectedToken, [ "ILLEGAL" ]);
        }
        var token:jint.parser.Token = new jint.parser.Token();
        token.Type = jint.parser.Tokens.NumericLiteral;
		//todo Convert.ToInt64(number, 16);;
        token.Value = Ints.parseInt(number,16);
        token.LineNumber = (_lineNumber);
        token.LineStart = _lineStart;
        token.Range = [ start, _index ];
        return token;
    }
    private function ScanOctalLiteral(start:Int):jint.parser.Token
    {
        var number:String = "0" + Cs2Hx.CharToString(jint.parser.ParserExtensions.CharCodeAt(_source, _index++));
        while (_index < _length)
        {
            if (!IsOctalDigit(jint.parser.ParserExtensions.CharCodeAt(_source, _index)))
            {
                break;
            }
            number += Cs2Hx.CharToString(jint.parser.ParserExtensions.CharCodeAt(_source, _index++));
        }
        if (IsIdentifierStart(jint.parser.ParserExtensions.CharCodeAt(_source, _index)) || IsDecimalDigit(jint.parser.ParserExtensions.CharCodeAt(_source, _index)))
        {
            ThrowError(null, jint.parser.Messages.UnexpectedToken, [ "ILLEGAL" ]);
        }
        var token:jint.parser.Token = new jint.parser.Token();
        token.Type = jint.parser.Tokens.NumericLiteral;
		//todo Convert.ToInt32(number, 8),
        token.Value =Ints.parseInt(number,8);
        token.Octal = true;
        token.LineNumber = (_lineNumber);
        token.LineStart = _lineStart;
        token.Range = [ start, _index ];
        return token;
    }
    private function ScanNumericLiteral():jint.parser.Token
    {
        var ch:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
        var start:Int = _index;
        var number:String = "";
        if (ch != 46)
        {
            number = Cs2Hx.CharToString(jint.parser.ParserExtensions.CharCodeAt(_source, _index++));
            ch = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
            if (number == "0")
            {
                if (ch == 120 || ch == 88)
                {
                    ++_index;
                    return ScanHexLiteral(start);
                }
                if (IsOctalDigit(ch))
                {
                    return ScanOctalLiteral(start);
                }
                if (ch > 0 && IsDecimalDigit(ch))
                {
                    ThrowError(null, jint.parser.Messages.UnexpectedToken, [ "ILLEGAL" ]);
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
                ThrowError(null, jint.parser.Messages.UnexpectedToken, [ "ILLEGAL" ]);
            }
        }
        if (IsIdentifierStart(jint.parser.ParserExtensions.CharCodeAt(_source, _index)))
        {
            ThrowError(null, jint.parser.Messages.UnexpectedToken, [ "ILLEGAL" ]);
        }
        var n:Float;
        try
        {
            n = Std.parseFloat(number);
            if (n > 3.4028235e+38)
            {
                n = Math.POSITIVE_INFINITY;
            }
            else if (n < -3.4028235e+38)
            {
                n = Math.NEGATIVE_INFINITY;
            }
        }
        catch (__ex:system.OverflowException)
        {
            n = system.Cs2Hx.StartsWith(system.Cs2Hx.Trim(number), "-") ? Math.NEGATIVE_INFINITY : Math.POSITIVE_INFINITY;
        }
        catch (__ex:Dynamic)
        {
            n = Math.NaN;
        }
        var token:jint.parser.Token = new jint.parser.Token();
        token.Type = jint.parser.Tokens.NumericLiteral;
        token.Value = n;
        token.LineNumber = (_lineNumber);
        token.LineStart = _lineStart;
        token.Range = [ start, _index ];
        return token;
    }
    private function ScanStringLiteral():jint.parser.Token
    {
        var str:system.text.StringBuilder = new system.text.StringBuilder();
        var octal:Bool = false;
        var startLineStart:Int = _lineStart;
        var startLineNumber:Int = _lineNumber;
        var quote:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
        var start:Int = _index;
        ++_index;
        while (_index < _length)
        {
            var ch:Int = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
			_index++;
            if (ch == quote)
            {
                quote = Char.MinValue;
                break;
            }
            if (ch == 92)
            {
                ch = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
				_index++;
                if (ch ==Char.MinValue || !IsLineTerminator(ch))
                {
                    switch (ch)
                    {
                        case 110:
                            str.Append_Char(110);
                        case 114:
                            str.Append_Char(114);
                        case 116:
                            str.Append_Char(116);
                        case 117, 120:
                            var restore:Int = _index;
                            var unescaped:Null<Int> = 0;
                            if (ScanHexEscape(ch, unescaped))
                            {
                                str.Append_Char(unescaped);
                            }
                            else
                            {
                                _index = restore;
                                str.Append_Char(ch);
                            }
                        case 98:
                            str.Append("\\b");
                        case 102:
                            str.Append("\\f");
                        case 118:
                            str.Append("\\x0B");
                        default:
                            if (IsOctalDigit(ch))
                            {
                                var code:Int = system.Cs2Hx.IndexOfChar("01234567", ch);
                                if (code != 0)
                                {
                                    octal = true;
                                }
                                if (_index < _length && IsOctalDigit(jint.parser.ParserExtensions.CharCodeAt(_source, _index)))
                                {
                                    octal = true;
                                    code = code * 8 + system.Cs2Hx.IndexOfChar("01234567", jint.parser.ParserExtensions.CharCodeAt(_source, _index++));
                                    if (system.Cs2Hx.IndexOfChar("0123", ch) >= 0 && _index < _length && IsOctalDigit(jint.parser.ParserExtensions.CharCodeAt(_source, _index)))
                                    {
                                        code = code * 8 + system.Cs2Hx.IndexOfChar("01234567", jint.parser.ParserExtensions.CharCodeAt(_source, _index++));
                                    }
                                }
                                str.Append_Char(code);
                            }
                            else
                            {
                                str.Append_Char(ch);
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
                    _lineStart = _index;
                }
            }
            else if ( IsLineTerminator(ch)  )
            { 
                break;
            }
            else
            {
                str.Append_Char(ch);
            }
			  
        }
        if (quote != 0)
        {
            ThrowError(null, jint.parser.Messages.UnexpectedToken, [ "ILLEGAL" ]);
        }
        var token:jint.parser.Token = new jint.parser.Token();
        token.Type = jint.parser.Tokens.StringLiteral;
        token.Value = str.toString();
        token.Octal = octal;
        token.LineNumber = (_lineNumber);
        token.LineStart = _lineStart;
        token.Range = [ start, _index ];
        return token;
    }
    private function ScanRegExp():jint.parser.Token
    {
        var classMarker:Bool = false;
        var terminated:Bool = false;
        SkipComment();
        var start:Int = _index;
        var ch:Null<Int> = 0;
        var str:system.text.StringBuilder = new system.text.StringBuilder(Cs2Hx.CharToString(jint.parser.ParserExtensions.CharCodeAt(_source, _index++)));
        while (_index < _length)
        {
            ch = jint.parser.ParserExtensions.CharCodeAt(_source, _index++);
            str.Append_Char(ch);
            if (ch == 92)
            {
                ch = jint.parser.ParserExtensions.CharCodeAt(_source, _index++);
                if (IsLineTerminator(ch))
                {
                    ThrowError(null, jint.parser.Messages.UnterminatedRegExp);
                }
                str.Append_Char(ch);
            }
            else if (IsLineTerminator(ch))
            {
                ThrowError(null, jint.parser.Messages.UnterminatedRegExp);
            }
            else if (classMarker)
            {
                if (ch == 93)
                {
                    classMarker = false;
                }
            }
            else
            {
                if (ch == 47)
                {
                    terminated = true;
                    break;
                }
                if (ch == 91)
                {
                    classMarker = true;
                }
            }
        }
        if (!terminated)
        {
            ThrowError(null, jint.parser.Messages.UnterminatedRegExp);
        }
        var pattern:String = str.toString().substr(1, str.Length - 2);
        var flags:String = "";
        while (_index < _length)
        {
            ch = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
            if (!IsIdentifierPart(ch))
            {
                break;
            }
            ++_index;
            if (ch == 92 && _index < _length)
            {
                ch = jint.parser.ParserExtensions.CharCodeAt(_source, _index);
                if (ch == 117)
                {
                    ++_index;
                    var restore:Int = _index;
                    if (ScanHexEscape(117, ch))
                    {
                        flags += Cs2Hx.CharToString(ch);
                        { //for
                            str.Append("\\u");
                            while (restore < _index)
                            {
                                str.Append(Cs2Hx.CharToString(jint.parser.ParserExtensions.CharCodeAt(_source, restore)));
                                ++restore;
                            }
                        } //end for
                    }
                    else
                    {
                        _index = restore;
                        flags += "u";
                        str.Append("\\u");
                    }
                }
                else
                {
                    str.Append("\\");
                }
            }
            else
            {
                flags += Cs2Hx.CharToString(ch);
                str.Append(Cs2Hx.CharToString(ch));
            }
        }
        Peek();
        var token:jint.parser.Token = new jint.parser.Token();
        token.Type = jint.parser.Tokens.RegularExpression;
        token.Literal = str.toString();
        token.Value = pattern + flags;
        token.Range = [ start, _index ];
        return token;
    }
    private function CollectRegex():jint.parser.Token
    {
        SkipComment();
        var pos:Int = _index;
        var loc:jint.parser.Location = new jint.parser.Location();
        loc.Start = new jint.parser.Position();
        loc.Start.Line = _lineNumber;
        loc.Start.Column = _index - _lineStart;
        var regex:jint.parser.Token = ScanRegExp();
        loc.End = new jint.parser.Position();
        loc.End.Line = _lineNumber;
        loc.End.Column = _index - _lineStart;
        if (_extra.Tokens != null)
        {
            var token:jint.parser.Token = _extra.Tokens[_extra.Tokens.length - 1];
            if (token.Range[0] == pos && token.Type == jint.parser.Tokens.Punctuator)
            {
                if (system.Cs2Hx.Equals_String("/", token.Value) || system.Cs2Hx.Equals_String("/=", token.Value))
                {
                    _extra.Tokens.splice(_extra.Tokens.length - 1, 1);
                }
            }
            var token_:jint.parser.Token = new jint.parser.Token();
            token_.Type = jint.parser.Tokens.RegularExpression;
            token_.Value = regex.Literal;
            token_.Range = [ pos, _index ];
            token_.Location = loc;
            _extra.Tokens.push(token_);
        }
        return regex;
    }
    private function IsIdentifierName(token:jint.parser.Token):Bool
    {
        return token.Type == jint.parser.Tokens.Identifier || token.Type == jint.parser.Tokens.Keyword || token.Type == jint.parser.Tokens.BooleanLiteral || token.Type == jint.parser.Tokens.NullLiteral;
    }
    private function Advance():jint.parser.Token
    {
        SkipComment();
        if (_index >= _length)
        {
            var token:jint.parser.Token = new jint.parser.Token();
            token.Type = jint.parser.Tokens.EOF;
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
        if (ch == 39 || ch == 34)
        {
            return ScanStringLiteral();
        }
        if (IsIdentifierStart(ch))
        {
            return ScanIdentifier();
        }
        if (ch == 46)
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
        return ScanPunctuator();
    }
    private function CollectToken():jint.parser.Token
    {
        SkipComment();
        _location = new jint.parser.Location();
        _location.Start = new jint.parser.Position();
        _location.Start.Line = _lineNumber;
        _location.Start.Column = _index - _lineStart;
        var token:jint.parser.Token = Advance();
        _location.End = new jint.parser.Position();
        _location.End.Line = _lineNumber;
        _location.End.Column = _index - _lineStart;
        if (token.Type != jint.parser.Tokens.EOF)
        {
            var range:Array<Int> = [ token.Range[0], token.Range[1] ];
            var value:String = jint.parser.ParserExtensions.Slice(_source, token.Range[0], token.Range[1]);
            var token_:jint.parser.Token = new jint.parser.Token();
            token_.Type = token.Type;
            token_.Value = value;
            token_.Range = range;
            token_.Location = _location;
            _extra.Tokens.push(token_);
        }
        return token;
    }
    private function Lex():jint.parser.Token
    {
        var token:jint.parser.Token = _lookahead;
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
        SkipComment();
        if (_extra.LocHasValue)
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
        if (_extra.LocHasValue)
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
            if (_extra.LocHasValue)
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
    public function CreateArrayExpression(elements:Array<jint.parser.ast.Expression>):jint.parser.ast.ArrayExpression
    {
        var arrayExpression:jint.parser.ast.ArrayExpression = new jint.parser.ast.ArrayExpression();
        arrayExpression.Type = jint.parser.ast.SyntaxNodes.ArrayExpression;
        arrayExpression.Elements = elements;
        return arrayExpression;
    }
    public function CreateAssignmentExpression(op:String, left:jint.parser.ast.Expression, right:jint.parser.ast.Expression):jint.parser.ast.AssignmentExpression
    {
        var assignmentExpression:jint.parser.ast.AssignmentExpression = new jint.parser.ast.AssignmentExpression();
        assignmentExpression.Type = jint.parser.ast.SyntaxNodes.AssignmentExpression;
        assignmentExpression.Operator = jint.parser.ast.AssignmentExpression.ParseAssignmentOperator(op);
        assignmentExpression.Left = left;
        assignmentExpression.Right = right;
        return assignmentExpression;
    }
    public function CreateBinaryExpression(op:String, left:jint.parser.ast.Expression, right:jint.parser.ast.Expression):jint.parser.ast.Expression
    { 
       
		if ((op == "||" || op == "&&") )
		{
			var logicalExpression:jint.parser.ast.LogicalExpression = new jint.parser.ast.LogicalExpression();
			logicalExpression.Type = jint.parser.ast.SyntaxNodes.LogicalExpression;
			logicalExpression.Operator = jint.parser.ast.LogicalExpression.ParseLogicalOperator(op);
			logicalExpression.Left = left;
			logicalExpression.Right = right;			
			return  cast(logicalExpression, jint.parser.ast.Expression) ;
		}
		
		var binaryExpression:jint.parser.ast.BinaryExpression = new jint.parser.ast.BinaryExpression();
		binaryExpression.Type = jint.parser.ast.SyntaxNodes.BinaryExpression;
		binaryExpression.Operator = jint.parser.ast.BinaryExpression.ParseBinaryOperator(op);
		binaryExpression.Left = left;
		binaryExpression.Right = right;
	
        return   binaryExpression;
    }
    public function CreateBlockStatement(body:Array<jint.parser.ast.Statement>):jint.parser.ast.BlockStatement
    {
        var blockStatement:jint.parser.ast.BlockStatement = new jint.parser.ast.BlockStatement();
        blockStatement.Type = jint.parser.ast.SyntaxNodes.BlockStatement;
        blockStatement.Body = body;
        return blockStatement;
    }
    public function CreateBreakStatement(label:jint.parser.ast.Identifier):jint.parser.ast.BreakStatement
    {
        var breakStatement:jint.parser.ast.BreakStatement = new jint.parser.ast.BreakStatement();
        breakStatement.Type = jint.parser.ast.SyntaxNodes.BreakStatement;
        breakStatement.Label = label;
        return breakStatement;
    }
    public function CreateCallExpression(callee:jint.parser.ast.Expression, args:Array<jint.parser.ast.Expression>):jint.parser.ast.CallExpression
    {
        var callExpression:jint.parser.ast.CallExpression = new jint.parser.ast.CallExpression();
        callExpression.Type = jint.parser.ast.SyntaxNodes.CallExpression;
        callExpression.Callee = callee;
        callExpression.Arguments = args;
        return callExpression;
    }
    public function CreateCatchClause(param:jint.parser.ast.Identifier, body:jint.parser.ast.BlockStatement):jint.parser.ast.CatchClause
    {
        var catchClause:jint.parser.ast.CatchClause = new jint.parser.ast.CatchClause();
        catchClause.Type = jint.parser.ast.SyntaxNodes.CatchClause;
        catchClause.Param = param;
        catchClause.Body = body;
        return catchClause;
    }
    public function CreateConditionalExpression(test:jint.parser.ast.Expression, consequent:jint.parser.ast.Expression, alternate:jint.parser.ast.Expression):jint.parser.ast.ConditionalExpression
    {
        var conditionalExpression:jint.parser.ast.ConditionalExpression = new jint.parser.ast.ConditionalExpression();
        conditionalExpression.Type = jint.parser.ast.SyntaxNodes.ConditionalExpression;
        conditionalExpression.Test = test;
        conditionalExpression.Consequent = consequent;
        conditionalExpression.Alternate = alternate;
        return conditionalExpression;
    }
    public function CreateContinueStatement(label:jint.parser.ast.Identifier):jint.parser.ast.ContinueStatement
    {
        var continueStatement:jint.parser.ast.ContinueStatement = new jint.parser.ast.ContinueStatement();
        continueStatement.Type = jint.parser.ast.SyntaxNodes.ContinueStatement;
        continueStatement.Label = label;
        return continueStatement;
    }
    public function CreateDebuggerStatement():jint.parser.ast.DebuggerStatement
    {
        var debuggerStatement:jint.parser.ast.DebuggerStatement = new jint.parser.ast.DebuggerStatement();
        debuggerStatement.Type = jint.parser.ast.SyntaxNodes.DebuggerStatement;
        return debuggerStatement;
    }
    public function CreateDoWhileStatement(body:jint.parser.ast.Statement, test:jint.parser.ast.Expression):jint.parser.ast.DoWhileStatement
    {
        var doWhileStatement:jint.parser.ast.DoWhileStatement = new jint.parser.ast.DoWhileStatement();
        doWhileStatement.Type = jint.parser.ast.SyntaxNodes.DoWhileStatement;
        doWhileStatement.Body = body;
        doWhileStatement.Test = test;
        return doWhileStatement;
    }
    public function CreateEmptyStatement():jint.parser.ast.EmptyStatement
    {
        var emptyStatement:jint.parser.ast.EmptyStatement = new jint.parser.ast.EmptyStatement();
        emptyStatement.Type = jint.parser.ast.SyntaxNodes.EmptyStatement;
        return emptyStatement;
    }
    public function CreateExpressionStatement(expression:jint.parser.ast.Expression):jint.parser.ast.ExpressionStatement
    {
        var expressionStatement:jint.parser.ast.ExpressionStatement = new jint.parser.ast.ExpressionStatement();
        expressionStatement.Type = jint.parser.ast.SyntaxNodes.ExpressionStatement;
        expressionStatement.Expression = expression;
        return expressionStatement;
    }
    public function CreateForStatement(init:jint.parser.ast.SyntaxNode, test:jint.parser.ast.Expression, update:jint.parser.ast.Expression, body:jint.parser.ast.Statement):jint.parser.ast.ForStatement
    {
        var forStatement:jint.parser.ast.ForStatement = new jint.parser.ast.ForStatement();
        forStatement.Type = jint.parser.ast.SyntaxNodes.ForStatement;
        forStatement.Init = init;
        forStatement.Test = test;
        forStatement.Update = update;
        forStatement.Body = body;
        return forStatement;
    }
    public function CreateForInStatement(left:jint.parser.ast.SyntaxNode, right:jint.parser.ast.Expression, body:jint.parser.ast.Statement):jint.parser.ast.ForInStatement
    {
        var forInStatement:jint.parser.ast.ForInStatement = new jint.parser.ast.ForInStatement();
        forInStatement.Type = jint.parser.ast.SyntaxNodes.ForInStatement;
        forInStatement.Left = left;
        forInStatement.Right = right;
        forInStatement.Body = body;
        forInStatement.Each = false;
        return forInStatement;
    }
    public function CreateFunctionDeclaration(id:jint.parser.ast.Identifier, parameters:Array<jint.parser.ast.Identifier>, defaults:Array<jint.parser.ast.Expression>, body:jint.parser.ast.Statement, strict:Bool):jint.parser.ast.FunctionDeclaration
    {
        var functionDeclaration:jint.parser.ast.FunctionDeclaration = new jint.parser.ast.FunctionDeclaration();
        functionDeclaration.Type = jint.parser.ast.SyntaxNodes.FunctionDeclaration;
        functionDeclaration.Id = id;
        functionDeclaration.Parameters = parameters;
        functionDeclaration.Defaults = defaults;
        functionDeclaration.Body = body;
        functionDeclaration.Strict = strict;
        functionDeclaration.Rest = null;
        functionDeclaration.Generator = false;
        functionDeclaration.Expression = false;
        functionDeclaration.VariableDeclarations = LeaveVariableScope();
        functionDeclaration.FunctionDeclarations = LeaveFunctionScope();
        _functionScopes[_functionScopes.length-1].FunctionDeclarations.push(functionDeclaration);
        return functionDeclaration;
    }
    public function CreateFunctionExpression(id:jint.parser.ast.Identifier, parameters:Array<jint.parser.ast.Identifier>, defaults:Array<jint.parser.ast.Expression>, body:jint.parser.ast.Statement, strict:Bool):jint.parser.ast.FunctionExpression
    {
        var functionExpression:jint.parser.ast.FunctionExpression = new jint.parser.ast.FunctionExpression();
        functionExpression.Type = jint.parser.ast.SyntaxNodes.FunctionExpression;
        functionExpression.Id = id;
        functionExpression.Parameters = parameters;
        functionExpression.Defaults = defaults;
        functionExpression.Body = body;
        functionExpression.Strict = strict;
        functionExpression.Rest = null;
        functionExpression.Generator = false;
        functionExpression.Expression = false;
        functionExpression.VariableDeclarations = LeaveVariableScope();
        functionExpression.FunctionDeclarations = LeaveFunctionScope();
        return functionExpression;
    }
    public function CreateIdentifier(name:String):jint.parser.ast.Identifier
    {
        var identifier:jint.parser.ast.Identifier = new jint.parser.ast.Identifier();
        identifier.Type = jint.parser.ast.SyntaxNodes.Identifier;
        identifier.Name = name;
        return identifier;
    }
    public function CreateIfStatement(test:jint.parser.ast.Expression, consequent:jint.parser.ast.Statement, alternate:jint.parser.ast.Statement):jint.parser.ast.IfStatement
    {
        var ifStatement:jint.parser.ast.IfStatement = new jint.parser.ast.IfStatement();
        ifStatement.Type = jint.parser.ast.SyntaxNodes.IfStatement;
        ifStatement.Test = test;
        ifStatement.Consequent = consequent;
        ifStatement.Alternate = alternate;
        return ifStatement;
    }
    public function CreateLabeledStatement(label:jint.parser.ast.Identifier, body:jint.parser.ast.Statement):jint.parser.ast.LabelledStatement
    {
        var labelledStatement:jint.parser.ast.LabelledStatement = new jint.parser.ast.LabelledStatement();
        labelledStatement.Type = jint.parser.ast.SyntaxNodes.LabeledStatement;
        labelledStatement.Label = label;
        labelledStatement.Body = body;
        return labelledStatement;
    }
    public function CreateLiteral(token:jint.parser.Token):jint.parser.ast.Literal
    {
        var literal:jint.parser.ast.Literal = null;
        if (token.Type == jint.parser.Tokens.RegularExpression)
        {
            literal = new jint.parser.ast.Literal();
            literal.Type = jint.parser.ast.SyntaxNodes.RegularExpressionLiteral;
            literal.Value = token.Value;
            literal.Raw = jint.parser.ParserExtensions.Slice(_source, token.Range[0], token.Range[1]);
            return literal;
        }
        literal = new jint.parser.ast.Literal();
        literal.Type = jint.parser.ast.SyntaxNodes.Literal;
        literal.Value = token.Value;
        literal.Raw = jint.parser.ParserExtensions.Slice(_source, token.Range[0], token.Range[1]);
        return literal;
    }
    public function CreateMemberExpression(accessor:Int, obj:jint.parser.ast.Expression, property:jint.parser.ast.Expression):jint.parser.ast.MemberExpression
    {
        var memberExpression:jint.parser.ast.MemberExpression = new jint.parser.ast.MemberExpression();
        memberExpression.Type = jint.parser.ast.SyntaxNodes.MemberExpression;
        memberExpression.Computed = accessor == 91;
        memberExpression.Object = obj;
        memberExpression.Property = property;
        return memberExpression;
    }
    public function CreateNewExpression(callee:jint.parser.ast.Expression, args:Array<jint.parser.ast.Expression>):jint.parser.ast.NewExpression
    {
        var newExpression:jint.parser.ast.NewExpression = new jint.parser.ast.NewExpression();
        newExpression.Type = jint.parser.ast.SyntaxNodes.NewExpression;
        newExpression.Callee = callee;
        newExpression.Arguments = args;
        return newExpression;
    }
    public function CreateObjectExpression(properties:Array<jint.parser.ast.Property>):jint.parser.ast.ObjectExpression
    {
        var objectExpression:jint.parser.ast.ObjectExpression = new jint.parser.ast.ObjectExpression();
        objectExpression.Type = jint.parser.ast.SyntaxNodes.ObjectExpression;
        objectExpression.Properties = properties;
        return objectExpression;
    }
    public function CreatePostfixExpression(op:String, argument:jint.parser.ast.Expression):jint.parser.ast.UpdateExpression
    {
        var updateExpression:jint.parser.ast.UpdateExpression = new jint.parser.ast.UpdateExpression();
        updateExpression.Type = jint.parser.ast.SyntaxNodes.UpdateExpression;
        updateExpression.Operator = jint.parser.ast.UnaryExpression.ParseUnaryOperator(op);
        updateExpression.Argument = argument;
        updateExpression.Prefix = false;
        return updateExpression;
    }
    public function CreateProgram(body:Array<jint.parser.ast.Statement>, strict:Bool):jint.parser.ast.Program
    {
        var program:jint.parser.ast.Program = new jint.parser.ast.Program();
        program.Type = jint.parser.ast.SyntaxNodes.Program;
        program.Body = body;
        program.Strict = strict;
        program.VariableDeclarations = LeaveVariableScope();
        program.FunctionDeclarations = LeaveFunctionScope();
        return program;
    }
    public function CreateProperty(kind:Int, key:jint.parser.ast.IPropertyKeyExpression, value:jint.parser.ast.Expression):jint.parser.ast.Property
    {
        var property:jint.parser.ast.Property = new jint.parser.ast.Property();
        property.Type = jint.parser.ast.SyntaxNodes.Property;
        property.Key = key;
        property.Value = value;
        property.Kind = kind;
        return property;
    }
    public function CreateReturnStatement(argument:jint.parser.ast.Expression):jint.parser.ast.ReturnStatement
    {
        var returnStatement:jint.parser.ast.ReturnStatement = new jint.parser.ast.ReturnStatement();
        returnStatement.Type = jint.parser.ast.SyntaxNodes.ReturnStatement;
        returnStatement.Argument = argument;
        return returnStatement;
    }
    public function CreateSequenceExpression(expressions:Array<jint.parser.ast.Expression>):jint.parser.ast.SequenceExpression
    {
        var sequenceExpression:jint.parser.ast.SequenceExpression = new jint.parser.ast.SequenceExpression();
        sequenceExpression.Type = jint.parser.ast.SyntaxNodes.SequenceExpression;
        sequenceExpression.Expressions = expressions;
        return sequenceExpression;
    }
    public function CreateSwitchCase(test:jint.parser.ast.Expression, consequent:Array<jint.parser.ast.Statement>):jint.parser.ast.SwitchCase
    {
        var switchCase:jint.parser.ast.SwitchCase = new jint.parser.ast.SwitchCase();
        switchCase.Type = jint.parser.ast.SyntaxNodes.SwitchCase;
        switchCase.Test = test;
        switchCase.Consequent = consequent;
        return switchCase;
    }
    public function CreateSwitchStatement(discriminant:jint.parser.ast.Expression, cases:Array<jint.parser.ast.SwitchCase>):jint.parser.ast.SwitchStatement
    {
        var switchStatement:jint.parser.ast.SwitchStatement = new jint.parser.ast.SwitchStatement();
        switchStatement.Type = jint.parser.ast.SyntaxNodes.SwitchStatement;
        switchStatement.Discriminant = discriminant;
        switchStatement.Cases = cases;
        return switchStatement;
    }
    public function CreateThisExpression():jint.parser.ast.ThisExpression
    {
        var thisExpression:jint.parser.ast.ThisExpression = new jint.parser.ast.ThisExpression();
        thisExpression.Type = jint.parser.ast.SyntaxNodes.ThisExpression;
        return thisExpression;
    }
    public function CreateThrowStatement(argument:jint.parser.ast.Expression):jint.parser.ast.ThrowStatement
    {
        var throwStatement:jint.parser.ast.ThrowStatement = new jint.parser.ast.ThrowStatement();
        throwStatement.Type = jint.parser.ast.SyntaxNodes.ThrowStatement;
        throwStatement.Argument = argument;
        return throwStatement;
    }
    public function CreateTryStatement(block:jint.parser.ast.Statement, guardedHandlers:Array<jint.parser.ast.Statement>, handlers:Array<jint.parser.ast.CatchClause>, finalizer:jint.parser.ast.Statement):jint.parser.ast.TryStatement
    {
        var tryStatement:jint.parser.ast.TryStatement = new jint.parser.ast.TryStatement();
        tryStatement.Type = jint.parser.ast.SyntaxNodes.TryStatement;
        tryStatement.Block = block;
        tryStatement.GuardedHandlers = guardedHandlers;
        tryStatement.Handlers = handlers;
        tryStatement.Finalizer = finalizer;
        return tryStatement;
    }
    public function CreateUnaryExpression(op:String, argument:jint.parser.ast.Expression):jint.parser.ast.UnaryExpression
    {
        if (op == "++" || op == "--")
        {
            var updateExpression:jint.parser.ast.UpdateExpression = new jint.parser.ast.UpdateExpression();
            updateExpression.Type = jint.parser.ast.SyntaxNodes.UpdateExpression;
            updateExpression.Operator = jint.parser.ast.UnaryExpression.ParseUnaryOperator(op);
            updateExpression.Argument = argument;
            updateExpression.Prefix = true;
            return updateExpression;
        }
        var unaryExpression:jint.parser.ast.UnaryExpression = new jint.parser.ast.UnaryExpression();
        unaryExpression.Type = jint.parser.ast.SyntaxNodes.UnaryExpression;
        unaryExpression.Operator = jint.parser.ast.UnaryExpression.ParseUnaryOperator(op);
        unaryExpression.Argument = argument;
        unaryExpression.Prefix = true;
        return unaryExpression;
    }
    public function CreateVariableDeclaration(declarations:Array<jint.parser.ast.VariableDeclarator>, kind:String):jint.parser.ast.VariableDeclaration
    {
        var variableDeclaration:jint.parser.ast.VariableDeclaration = new jint.parser.ast.VariableDeclaration();
        variableDeclaration.Type = jint.parser.ast.SyntaxNodes.VariableDeclaration;
        variableDeclaration.Declarations = declarations;
        variableDeclaration.Kind = kind;
        _variableScopes[_variableScopes.length-1].VariableDeclarations.push(variableDeclaration);
        return variableDeclaration;
    }
    public function CreateVariableDeclarator(id:jint.parser.ast.Identifier, init:jint.parser.ast.Expression):jint.parser.ast.VariableDeclarator
    {
        var variableDeclarator:jint.parser.ast.VariableDeclarator = new jint.parser.ast.VariableDeclarator();
        variableDeclarator.Type = jint.parser.ast.SyntaxNodes.VariableDeclarator;
        variableDeclarator.Id = id;
        variableDeclarator.Init = init;
        return variableDeclarator;
    }
    public function CreateWhileStatement(test:jint.parser.ast.Expression, body:jint.parser.ast.Statement):jint.parser.ast.WhileStatement
    {
        var whileStatement:jint.parser.ast.WhileStatement = new jint.parser.ast.WhileStatement();
        whileStatement.Type = jint.parser.ast.SyntaxNodes.WhileStatement;
        whileStatement.Test = test;
        whileStatement.Body = body;
        return whileStatement;
    }
    public function CreateWithStatement(obj:jint.parser.ast.Expression, body:jint.parser.ast.Statement):jint.parser.ast.WithStatement
    {
        var withStatement:jint.parser.ast.WithStatement = new jint.parser.ast.WithStatement();
        withStatement.Type = jint.parser.ast.SyntaxNodes.WithStatement;
        withStatement.Object = obj;
        withStatement.Body = body;
        return withStatement;
    }
    private function PeekLineTerminator():Bool
    {
        var pos:Int = _index;
        var line:Int = _lineNumber;
        var start:Int = _lineStart;
        SkipComment();
        var found:Bool = _lineNumber != line;
        _index = pos;
        _lineNumber = line;
        _lineStart = start;
        return found;
    }
    private function ThrowError(token:jint.parser.Token, messageFormat:String, ?arguments:Array<Dynamic>):Void
    {
        var exception:jint.parser.ParserException;
        var msg:String = Std.string(arguments);
        if (token != null && token.LineNumber!=null)
        {
            exception = new jint.parser.ParserException("Line " + token.LineNumber + ": " + msg);
        }
        else
        {
            exception = new jint.parser.ParserException("Line " + _lineNumber + ": " + msg);
        }
        exception.Description = msg;
        throw exception;
    }
    private function ThrowErrorTolerant(token:jint.parser.Token, messageFormat:String, ?arguments:Array<Dynamic>):Void
    {
        try
        {
            ThrowError(token, messageFormat, arguments);
        }
        catch (e:Dynamic)
        {
            if (_extra.Errors != null)
            {
                _extra.Errors.push(new jint.parser.ParserException(e.Message));
            }
            else
            {
                throw e;
            }
        }
    }
    private function ThrowUnexpected(token:jint.parser.Token):Void
    {
        if (token.Type == jint.parser.Tokens.EOF)
        {
            ThrowError(token, jint.parser.Messages.UnexpectedEOS);
        }
        if (token.Type == jint.parser.Tokens.NumericLiteral)
        {
            ThrowError(token, jint.parser.Messages.UnexpectedNumber);
        }
        if (token.Type == jint.parser.Tokens.StringLiteral)
        {
            ThrowError(token, jint.parser.Messages.UnexpectedString);
        }
        if (token.Type == jint.parser.Tokens.Identifier)
        {
            ThrowError(token, jint.parser.Messages.UnexpectedIdentifier);
        }
        if (token.Type == jint.parser.Tokens.Keyword)
        {
            if (IsFutureReservedWord(token.Value))
            {
                ThrowError(token, jint.parser.Messages.UnexpectedReserved);
            }
            else if (_strict && IsStrictModeReservedWord(token.Value))
            {
                ThrowErrorTolerant(token, jint.parser.Messages.StrictReservedWord);
                return;
            }
            ThrowError(token, jint.parser.Messages.UnexpectedToken, [ token.Value ]);
        }
        ThrowError(token, jint.parser.Messages.UnexpectedToken, [ token.Value ]);
    }
    private function Expect(value:String):Void
    {
        var token:jint.parser.Token = Lex();
        if (token.Type != jint.parser.Tokens.Punctuator || !system.Cs2Hx.Equals_String(value, token.Value))
        {
            ThrowUnexpected(token);
        }
    }
    private function ExpectKeyword(keyword:String):Void
    {
        var token:jint.parser.Token = Lex();
        if (token.Type != jint.parser.Tokens.Keyword || !system.Cs2Hx.Equals_String(keyword, token.Value))
        {
            ThrowUnexpected(token);
        }
    }
    private function Match(value:String):Bool
    {
        return _lookahead.Type == jint.parser.Tokens.Punctuator && system.Cs2Hx.Equals_String(value, _lookahead.Value);
    }
    private function MatchKeyword(keyword:Dynamic):Bool
    {
        return _lookahead.Type == jint.parser.Tokens.Keyword && system.Cs2Hx.Equals_String(keyword,_lookahead.Value);
    }
    private function MatchAssign():Bool
    {
        if (_lookahead.Type != jint.parser.Tokens.Punctuator)
        {
            return false;
        }
        var op:String = _lookahead.Value;
        return op == "=" || op == "*=" || op == "/=" || op == "%=" || op == "+=" || op == "-=" || op == "<<=" || op == ">>=" || op == ">>>=" || op == "&=" || op == "^=" || op == "|=";
    }
    private function ConsumeSemicolon():Void
    {
        if (jint.parser.ParserExtensions.CharCodeAt(_source, _index) == 59)
        {
            Lex();
            return;
        }
        var line:Int = _lineNumber;
        SkipComment();
        if (_lineNumber != line)
        {
            return;
        }
        if (Match(";"))
        {
            Lex();
            return;
        }
        if (_lookahead.Type != jint.parser.Tokens.EOF && !Match("}"))
        {
            ThrowUnexpected(_lookahead);
        }
    }
    private function isLeftHandSide(expr:jint.parser.ast.Expression):Bool
    {
        return expr.Type == jint.parser.ast.SyntaxNodes.Identifier || expr.Type == jint.parser.ast.SyntaxNodes.MemberExpression;
    }
    private function ParseArrayInitialiser():jint.parser.ast.ArrayExpression
    {
        var elements:Array<jint.parser.ast.Expression> = new Array<jint.parser.ast.Expression>();
        Expect("[");
        while (!Match("]"))
        {
            if (Match(","))
            {
                Lex();
                elements.push(null);
            }
            else
            {
                elements.push(ParseAssignmentExpression());
                if (!Match("]"))
                {
                    Expect(",");
                }
            }
        }
        Expect("]");
        return CreateArrayExpression(elements);
    }
    private function ParsePropertyFunction(parameters:Array<jint.parser.ast.Identifier>, first:jint.parser.Token = null):jint.parser.ast.FunctionExpression
    {
        EnterVariableScope();
        EnterFunctionScope();
        var previousStrict:Bool = _strict;
        MarkStart();
        var body:jint.parser.ast.Statement = ParseFunctionSourceElements();
        if (first != null && _strict && IsRestrictedWord(parameters[0].Name))
        {
            ThrowErrorTolerant(first, jint.parser.Messages.StrictParamName);
        }
        var functionStrict:Bool = _strict;
        _strict = previousStrict;
        return MarkEnd(CreateFunctionExpression(null, parameters, [  ], body, functionStrict));
    }
    private function ParseObjectPropertyKey():jint.parser.ast.IPropertyKeyExpression
    {
        MarkStart();
        var token:jint.parser.Token = Lex();
        if (token.Type == jint.parser.Tokens.StringLiteral || token.Type == jint.parser.Tokens.NumericLiteral)
        {
            if (_strict && token.Octal)
            {
                ThrowErrorTolerant(token, jint.parser.Messages.StrictOctalLiteral);
            }
            return MarkEnd(CreateLiteral(token));
        }
        return MarkEnd(CreateIdentifier(token.Value));
    }
    private function ParseObjectProperty():jint.parser.ast.Property
    {
        var value:jint.parser.ast.Expression;
        var token:jint.parser.Token = _lookahead;
        MarkStart();
        if (token.Type == jint.parser.Tokens.Identifier)
        {
            var id:jint.parser.ast.IPropertyKeyExpression = ParseObjectPropertyKey();
            if (system.Cs2Hx.Equals_String("get", token.Value) && !Match(":"))
            {
                var key:jint.parser.ast.IPropertyKeyExpression = ParseObjectPropertyKey();
                Expect("(");
                Expect(")");
                value = ParsePropertyFunction([  ]);
                return MarkEnd(CreateProperty(jint.parser.ast.PropertyKind.Get, key, value));
            }
            if (system.Cs2Hx.Equals_String("set", token.Value) && !Match(":"))
            {
                var key:jint.parser.ast.IPropertyKeyExpression = ParseObjectPropertyKey();
                Expect("(");
                token = _lookahead;
                if (token.Type != jint.parser.Tokens.Identifier)
                {
                    Expect(")");
                    ThrowErrorTolerant(token, jint.parser.Messages.UnexpectedToken, [ token.Value ]);
                    value = ParsePropertyFunction([  ]);
                }
                else
                {
                    var param:Array<jint.parser.ast.Identifier> = [ ParseVariableIdentifier() ];
                    Expect(")");
                    value = ParsePropertyFunction(param, token);
                }
                return MarkEnd(CreateProperty(jint.parser.ast.PropertyKind.Set, key, value));
            }
            Expect(":");
            value = ParseAssignmentExpression();
            return MarkEnd(CreateProperty(jint.parser.ast.PropertyKind.Data, id, value));
        }
        if (token.Type == jint.parser.Tokens.EOF || token.Type == jint.parser.Tokens.Punctuator)
        {
            ThrowUnexpected(token);
            return null;
        }
        else
        {
            var key:jint.parser.ast.IPropertyKeyExpression = ParseObjectPropertyKey();
            Expect(":");
            value = ParseAssignmentExpression();
            return MarkEnd(CreateProperty(jint.parser.ast.PropertyKind.Data, key, value));
        }
    }
    private function ParseObjectInitialiser():jint.parser.ast.ObjectExpression
    {
        var properties:Array<jint.parser.ast.Property> = new Array<jint.parser.ast.Property>();
        var map:StringMap<Int> = new StringMap<Int>();
        Expect("{");
        while (!Match("}"))
        {
            var property:jint.parser.ast.Property = ParseObjectProperty();
            var name:String = property.Key.GetKey();
            var kind:Int = property.Kind;
            var key:String = "$" + name;
		  
            if (map.exists(key))
            {
                if (map.get(key) == jint.parser.ast.PropertyKind.Data)
                {
                    if (_strict && kind == jint.parser.ast.PropertyKind.Data)
                    {
                        ThrowErrorTolerant(jint.parser.Token.Empty, jint.parser.Messages.StrictDuplicateProperty);
                    }
                    else if (kind != jint.parser.ast.PropertyKind.Data)
                    {
                        ThrowErrorTolerant(jint.parser.Token.Empty, jint.parser.Messages.AccessorDataProperty);
                    }
                }
                else
                {
                    if (kind == jint.parser.ast.PropertyKind.Data)
                    {
                        ThrowErrorTolerant(jint.parser.Token.Empty, jint.parser.Messages.AccessorDataProperty);
                    }
                    else if ((map.get(key) & kind) == kind)
                    {
                        ThrowErrorTolerant(jint.parser.Token.Empty, jint.parser.Messages.AccessorGetSet);
                    }
                }
				var map_value = map.get(key);
                map.set(key, map_value|= kind);
            }
            else
            {
                map.set(key, kind);
            }
            properties.push(property);
            if (!Match("}"))
            {
                Expect(",");
            }
        }
        Expect("}");
        return CreateObjectExpression(properties);
    }
    private function ParseGroupExpression():jint.parser.ast.Expression
    {
        Expect("(");
        var expr:jint.parser.ast.Expression = ParseExpression();
        Expect(")");
        return expr;
    }
    private function ParsePrimaryExpression():jint.parser.ast.Expression
    {
        var expr:jint.parser.ast.Expression = null;
        if (Match("("))
        {
            return ParseGroupExpression();
        }
        var type:Int = _lookahead.Type;
        MarkStart();
        if (type == jint.parser.Tokens.Identifier)
        {
            expr = CreateIdentifier(Lex().Value);
        }
        else if (type == jint.parser.Tokens.StringLiteral || type == jint.parser.Tokens.NumericLiteral)
        {
            if (_strict && _lookahead.Octal)
            {
                ThrowErrorTolerant(_lookahead, jint.parser.Messages.StrictOctalLiteral);
            }
            expr = CreateLiteral(Lex());
        }
        else if (type == jint.parser.Tokens.Keyword)
        {
            if (MatchKeyword("this"))
            {
                Lex();
                expr = CreateThisExpression();
            }
            else if (MatchKeyword("function"))
            {
                expr = ParseFunctionExpression();
            }
        }
        else if (type == jint.parser.Tokens.BooleanLiteral)
        {
            var token:jint.parser.Token = Lex();
            token.Value = (system.Cs2Hx.Equals_String("true", token.Value));
            expr = CreateLiteral(token);
        }
        else if (type == jint.parser.Tokens.NullLiteral)
        {
            var token:jint.parser.Token = Lex();
            token.Value = null;
            expr = CreateLiteral(token);
        }
        else if (Match("["))
        {
            expr = ParseArrayInitialiser();
        }
        else if (Match("{"))
        {
            expr = ParseObjectInitialiser();
        }
        else if (Match("/") || Match("/="))
        {
            expr = CreateLiteral(_extra.Tokens != null ? CollectRegex() : ScanRegExp());
        }
        if (expr != null)
        {
            return MarkEnd(expr);
        }
        ThrowUnexpected(Lex());
        return null;
    }
    private function ParseArguments():Array<jint.parser.ast.Expression>
    {
        var args:Array<jint.parser.ast.Expression> = new Array<jint.parser.ast.Expression>();
        Expect("(");
        if (!Match(")"))
        {
            while (_index < _length)
            {
                args.push(ParseAssignmentExpression());
                if (Match(")"))
                {
                    break;
                }
                Expect(",");
            }
        }
        Expect(")");
        return args;
    }
    private function ParseNonComputedProperty():jint.parser.ast.Identifier
    {
        MarkStart();
        var token:jint.parser.Token = Lex();
        if (!IsIdentifierName(token))
        {
            ThrowUnexpected(token);
        }
        return MarkEnd(CreateIdentifier(token.Value));
    }
    private function ParseNonComputedMember():jint.parser.ast.Identifier
    {
        Expect(".");
        return ParseNonComputedProperty();
    }
    private function ParseComputedMember():jint.parser.ast.Expression
    {
        Expect("[");
        var expr:jint.parser.ast.Expression = ParseExpression();
        Expect("]");
        return expr;
    }
    private function ParseNewExpression():jint.parser.ast.NewExpression
    {
        MarkStart();
        ExpectKeyword("new");
        var callee:jint.parser.ast.Expression = ParseLeftHandSideExpression();
        var args:Array<jint.parser.ast.Expression> = Match("(") ? ParseArguments() : [  ];
        return MarkEnd(CreateNewExpression(callee, args));
    }
    private function ParseLeftHandSideExpressionAllowCall():jint.parser.ast.Expression
    {
        var marker:jint.parser.JavaScriptParser_LocationMarker = CreateLocationMarker();
        var previousAllowIn:Bool = _state.AllowIn;
        _state.AllowIn = true;
        var expr:jint.parser.ast.Expression = MatchKeyword("new") ? ParseNewExpression() : ParsePrimaryExpression();
        _state.AllowIn = previousAllowIn;
        while (Match(".") || Match("[") || Match("("))
        {
            if (Match("("))
            {
                var args:Array<jint.parser.ast.Expression> = ParseArguments();
                expr = CreateCallExpression(expr, args);
            }
            else if (Match("["))
            {
                var property:jint.parser.ast.Expression = ParseComputedMember();
                expr = CreateMemberExpression(91, expr, property);
            }
            else
            {
                var property:jint.parser.ast.Identifier = ParseNonComputedMember();
                expr = CreateMemberExpression(46, expr, property);
            }
            if (marker != null)
            {
                marker.End(_index, _lineNumber, _lineStart);
                marker.Apply(expr, _extra, PostProcess);
            }
        }
        return expr;
    }
    private function ParseLeftHandSideExpression():jint.parser.ast.Expression
    {
        var marker:jint.parser.JavaScriptParser_LocationMarker = CreateLocationMarker();
        var previousAllowIn:Bool = _state.AllowIn;
        var expr:jint.parser.ast.Expression = MatchKeyword("new") ? ParseNewExpression() : ParsePrimaryExpression();
        _state.AllowIn = previousAllowIn;
        while (Match(".") || Match("["))
        {
            if (Match("["))
            {
                var property:jint.parser.ast.Expression = ParseComputedMember();
                expr = CreateMemberExpression(91, expr, property);
            }
            else
            {
                var property:jint.parser.ast.Identifier = ParseNonComputedMember();
                expr = CreateMemberExpression(46, expr, property);
            }
            if (marker != null)
            {
                marker.End(_index, _lineNumber, _lineStart);
                marker.Apply(expr, _extra, PostProcess);
            }
        }
        return expr;
    }
    private function ParsePostfixExpression():jint.parser.ast.Expression
    {
        MarkStart();
        var expr:jint.parser.ast.Expression = ParseLeftHandSideExpressionAllowCall();
        if (_lookahead.Type == jint.parser.Tokens.Punctuator)
        {
            if ((Match("++") || Match("--")) && !PeekLineTerminator())
            {
                if (_strict && expr.Type == jint.parser.ast.SyntaxNodes.Identifier && IsRestrictedWord((cast(expr, jint.parser.ast.Identifier)).Name))
                {
                    ThrowErrorTolerant(jint.parser.Token.Empty, jint.parser.Messages.StrictLHSPostfix);
                }
                if (!isLeftHandSide(expr))
                {
                    ThrowErrorTolerant(jint.parser.Token.Empty, jint.parser.Messages.InvalidLHSInAssignment);
                }
                var token:jint.parser.Token = Lex();
                expr = CreatePostfixExpression(token.Value, expr);
            }
        }
        return MarkEndIf(expr);
    }
    private function ParseUnaryExpression():jint.parser.ast.Expression
    {
        var expr:jint.parser.ast.Expression;
        MarkStart();
        if (_lookahead.Type != jint.parser.Tokens.Punctuator && _lookahead.Type != jint.parser.Tokens.Keyword)
        {
            expr = ParsePostfixExpression();
        }
        else if (Match("++") || Match("--"))
        {
            var token:jint.parser.Token = Lex();
            expr = ParseUnaryExpression();
            if (_strict && expr.Type == jint.parser.ast.SyntaxNodes.Identifier && IsRestrictedWord((cast(expr, jint.parser.ast.Identifier)).Name))
            {
                ThrowErrorTolerant(jint.parser.Token.Empty, jint.parser.Messages.StrictLHSPrefix);
            }
            if (!isLeftHandSide(expr))
            {
                ThrowErrorTolerant(jint.parser.Token.Empty, jint.parser.Messages.InvalidLHSInAssignment);
            }
            expr = CreateUnaryExpression(token.Value, expr);
        }
        else if (Match("+") || Match("-") || Match("~") || Match("!"))
        {
            var token:jint.parser.Token = Lex();
            expr = ParseUnaryExpression();
            expr = CreateUnaryExpression(token.Value, expr);
        }
        else if (MatchKeyword("delete") || MatchKeyword("void") || MatchKeyword("typeof"))
        {
            var token:jint.parser.Token = Lex();
            expr = ParseUnaryExpression();
            var unaryExpr:jint.parser.ast.UnaryExpression = CreateUnaryExpression(token.Value, expr);
            if (_strict && unaryExpr.Operator == jint.parser.ast.UnaryOperator.Delete && unaryExpr.Argument.Type == jint.parser.ast.SyntaxNodes.Identifier)
            {
                ThrowErrorTolerant(jint.parser.Token.Empty, jint.parser.Messages.StrictDelete);
            }
            expr = unaryExpr;
        }
        else
        {
            expr = ParsePostfixExpression();
        }
        return MarkEndIf(expr);
    }
    private function binaryPrecedence(token:jint.parser.Token, allowIn:Bool):Int
    {
        var prec:Int = 0;
        if (token.Type != jint.parser.Tokens.Punctuator && token.Type != jint.parser.Tokens.Keyword)
        {
            return 0;
        }
        switch (token.Value)
        {
            case "||":
                prec = 1;
            case "&&":
                prec = 2;
            case "|":
                prec = 3;
            case "^":
                prec = 4;
            case "&":
                prec = 5;
            case "==", "!=", "===", "!==":
                prec = 6;
            case "<", ">", "<=", ">=", "instanceof":
                prec = 7;
            case "in":
                prec = allowIn ? 7 : 0;
            case "<<", ">>", ">>>":
                prec = 8;
            case "+", "-":
                prec = 9;
            case "*", "/", "%":
                prec = 11;
        }
        return prec;
    }
    private function ParseBinaryExpression():jint.parser.ast.Expression
    {
        var expr:jint.parser.ast.Expression;
        var marker:jint.parser.JavaScriptParser_LocationMarker = CreateLocationMarker();
        var left:jint.parser.ast.Expression = ParseUnaryExpression();
        var token:jint.parser.Token = _lookahead;
        var prec:Int = binaryPrecedence(token, _state.AllowIn);
        if (prec == 0)
        {
            return left;
        }
        token.Precedence = prec;
        Lex();
        var markers:Array<jint.parser.JavaScriptParser_LocationMarker> = new Array<jint.parser.JavaScriptParser_LocationMarker>();
        var right:jint.parser.ast.Expression = ParseUnaryExpression();
        var stack:Array<Dynamic> = [left, token, right];
        while ((prec = binaryPrecedence(_lookahead, _state.AllowIn)) > 0)
        {
            while ((stack.length > 2) && (prec <= (stack[stack.length - 2]).Precedence))
            {
                right = jint.parser.ParserExtensions.Pop(stack);
                var op:String = (jint.parser.ParserExtensions.Pop(stack)).Value;
                left = jint.parser.ParserExtensions.Pop(stack);
                expr = CreateBinaryExpression(op, left, right);
                markers.pop();
                marker = markers.pop();
                if (marker != null)
                {
                    marker.End(_index, _lineNumber, _lineStart);
                    marker.Apply(expr, _extra, PostProcess);
                }
                jint.parser.ParserExtensions.Push(stack, expr);
                markers.push(marker);
            }
            token = Lex();
            token.Precedence = prec;
            jint.parser.ParserExtensions.Push(stack, token);
            markers.push(CreateLocationMarker());
            expr = ParseUnaryExpression();
            jint.parser.ParserExtensions.Push(stack, expr);
        }
        var i:Int = stack.length - 1;
        expr = stack[i];
        markers.pop();
        while (i > 1)
        {
            expr = CreateBinaryExpression((stack[i - 1]).Value, stack[i - 2], expr);
            i -= 2;
            marker = markers.pop();
            if (marker != null)
            {
                marker.End(_index, _lineNumber, _lineStart);
                marker.Apply(expr, _extra, PostProcess);
            }
        }
        return expr;
    }
    private function ParseConditionalExpression():jint.parser.ast.Expression
    {
        MarkStart();
        var expr:jint.parser.ast.Expression = ParseBinaryExpression();
        if (Match("?"))
        {
            Lex();
            var previousAllowIn:Bool = _state.AllowIn;
            _state.AllowIn = true;
            var consequent:jint.parser.ast.Expression = ParseAssignmentExpression();
            _state.AllowIn = previousAllowIn;
            Expect(":");
            var alternate:jint.parser.ast.Expression = ParseAssignmentExpression();
            expr = MarkEnd(CreateConditionalExpression(expr, consequent, alternate));
        }
        else
        {
            MarkEnd(new jint.parser.ast.SyntaxNode());
        }
 
        return expr;
    }
    private function ParseAssignmentExpression():jint.parser.ast.Expression
    {
        var left:jint.parser.ast.Expression;
        var token:jint.parser.Token = _lookahead;
        MarkStart();
        var expr:jint.parser.ast.Expression = left = ParseConditionalExpression();
        if (MatchAssign())
        {
            if (_strict && left.Type == jint.parser.ast.SyntaxNodes.Identifier && IsRestrictedWord((cast(left, jint.parser.ast.Identifier)).Name))
            {
                ThrowErrorTolerant(token, jint.parser.Messages.StrictLHSAssignment);
            }
            token = Lex();
            var right:jint.parser.ast.Expression = ParseAssignmentExpression();
            expr = CreateAssignmentExpression(token.Value, left, right);
        }
        return MarkEndIf(expr);
    }
    private function ParseExpression():jint.parser.ast.Expression
    {
        MarkStart();
        var expr:jint.parser.ast.Expression = ParseAssignmentExpression();
        if (Match(","))
        {
            var list:Array<jint.parser.ast.Expression> = new Array<jint.parser.ast.Expression>();
            list.push(expr);
            expr = CreateSequenceExpression(list);
            while (_index < _length)
            {
                if (!Match(","))
                {
                    break;
                }
                Lex();
				var sequenceExpression:SequenceExpression = (cast(expr, jint.parser.ast.SequenceExpression)); 
                sequenceExpression.Expressions.push(ParseAssignmentExpression());
            }
        }
        return MarkEndIf(expr);
    }
    private function ParseStatementList():Array<jint.parser.ast.Statement>
    {
        var list:Array<jint.parser.ast.Statement> = new Array<jint.parser.ast.Statement>();
        while (_index < _length)
        {
            if (Match("}"))
            {
                break;
            }
            var statement:jint.parser.ast.Statement = ParseSourceElement();
            if (statement == null)
            {
                break;
            }
            list.push(statement);
        }
        return list;
    }
    private function ParseBlock():jint.parser.ast.BlockStatement
    {
        MarkStart();
        Expect("{");
        var block:Array<jint.parser.ast.Statement> = ParseStatementList();
        Expect("}");
        return MarkEnd(CreateBlockStatement(block));
    }
    private function ParseVariableIdentifier():jint.parser.ast.Identifier
    {
        MarkStart();
        var token:jint.parser.Token = Lex();
        if (token.Type != jint.parser.Tokens.Identifier)
        {
            ThrowUnexpected(token);
        }
        return MarkEnd(CreateIdentifier(token.Value));
    }
    private function ParseVariableDeclaration(kind:String):jint.parser.ast.VariableDeclarator
    {
        var init:jint.parser.ast.Expression = null;
        MarkStart();
        var id:jint.parser.ast.Identifier = ParseVariableIdentifier();
        if (_strict && IsRestrictedWord(id.Name))
        {
            ThrowErrorTolerant(jint.parser.Token.Empty, jint.parser.Messages.StrictVarName);
        }
        if (system.Cs2Hx.Equals_String("const", kind))
        {
            Expect("=");
            init = ParseAssignmentExpression();
        }
        else if (Match("="))
        {
            Lex();
            init = ParseAssignmentExpression();
        }
        return MarkEnd(CreateVariableDeclarator(id, init));
    }
    private function ParseVariableDeclarationList(kind:String):Array<jint.parser.ast.VariableDeclarator>
    {
        var list:Array<jint.parser.ast.VariableDeclarator> = new Array<jint.parser.ast.VariableDeclarator>();
        do
        {
            list.push(ParseVariableDeclaration(kind));
            if (!Match(","))
            {
                break;
            }
            Lex();
        }
        while (_index < _length);
        return list;
    }
    private function ParseVariableStatement():jint.parser.ast.VariableDeclaration
    {
        ExpectKeyword("var");
        var declarations:Array<jint.parser.ast.VariableDeclarator> = ParseVariableDeclarationList(null);
        ConsumeSemicolon();
        return CreateVariableDeclaration(declarations, "var");
    }
    private function ParseConstLetDeclaration(kind:String):jint.parser.ast.VariableDeclaration
    {
        MarkStart();
        ExpectKeyword(kind);
        var declarations:Array<jint.parser.ast.VariableDeclarator> = ParseVariableDeclarationList(kind);
        ConsumeSemicolon();
        return MarkEnd(CreateVariableDeclaration(declarations, kind));
    }
    private function ParseEmptyStatement():jint.parser.ast.EmptyStatement
    {
        Expect(";");
        return CreateEmptyStatement();
    }
    private function ParseExpressionStatement():jint.parser.ast.ExpressionStatement
    {
        var expr:jint.parser.ast.Expression = ParseExpression();
        ConsumeSemicolon();
        return CreateExpressionStatement(expr);
    }
    private function ParseIfStatement():jint.parser.ast.IfStatement
    {
        var alternate:jint.parser.ast.Statement;
        ExpectKeyword("if");
        Expect("(");
        var test:jint.parser.ast.Expression = ParseExpression();
        Expect(")");
        var consequent:jint.parser.ast.Statement = ParseStatement();
        if (MatchKeyword("else"))
        {
            Lex();
            alternate = ParseStatement();
        }
        else
        {
            alternate = null;
        }
        return CreateIfStatement(test, consequent, alternate);
    }
    private function ParseDoWhileStatement():jint.parser.ast.DoWhileStatement
    {
        ExpectKeyword("do");
        var oldInIteration:Bool = _state.InIteration;
        _state.InIteration = true;
        var body:jint.parser.ast.Statement = ParseStatement();
        _state.InIteration = oldInIteration;
        ExpectKeyword("while");
        Expect("(");
        var test:jint.parser.ast.Expression = ParseExpression();
        Expect(")");
        if (Match(";"))
        {
            Lex();
        }
        return CreateDoWhileStatement(body, test);
    }
    private function ParseWhileStatement():jint.parser.ast.WhileStatement
    {
        ExpectKeyword("while");
        Expect("(");
        var test:jint.parser.ast.Expression = ParseExpression();
        Expect(")");
        var oldInIteration:Bool = _state.InIteration;
        _state.InIteration = true;
        var body:jint.parser.ast.Statement = ParseStatement();
        _state.InIteration = oldInIteration;
        return CreateWhileStatement(test, body);
    }
    private function ParseForVariableDeclaration():jint.parser.ast.VariableDeclaration
    {
        MarkStart();
        var token:jint.parser.Token = Lex();
        var declarations:Array<jint.parser.ast.VariableDeclarator> = ParseVariableDeclarationList(null);
        return MarkEnd(CreateVariableDeclaration(declarations, token.Value));
    }
    private function ParseForStatement():jint.parser.ast.Statement
    {
        var init:jint.parser.ast.SyntaxNode = null;
        var left:jint.parser.ast.SyntaxNode = null;
        var right:jint.parser.ast.Expression = null;
        var test:jint.parser.ast.Expression = null;
        var update:jint.parser.ast.Expression = null;
        ExpectKeyword("for");
        Expect("(");
        if (Match(";"))
        {
            Lex();
        }
        else
        {
            if (MatchKeyword("var") || MatchKeyword("let"))
            {
                _state.AllowIn = false;
                init = ParseForVariableDeclaration();
                _state.AllowIn = true;
                if (system.linq.Enumerable.Count(init.As(VariableDeclaration).Declarations) == 1 && MatchKeyword("in"))
                {
                    Lex();
                    left = init;
                    right = ParseExpression();
                    init = null;
                }
            }
            else
            {
                _state.AllowIn = false;
                init = ParseExpression();
                _state.AllowIn = true;
                if (MatchKeyword("in"))
                {
                    if (!isLeftHandSide(cast(init, jint.parser.ast.Expression)))
                    {
                        ThrowErrorTolerant(jint.parser.Token.Empty, jint.parser.Messages.InvalidLHSInForIn);
                    }
                    Lex();
                    left = init;
                    right = ParseExpression();
                    init = null;
                }
            }
            if (left == null)
            {
                Expect(";");
            }
        }
        if (left == null)
        {
            if (!Match(";"))
            {
                test = ParseExpression();
            }
            Expect(";");
            if (!Match(")"))
            {
                update = ParseExpression();
            }
        }
        Expect(")");
        var oldInIteration:Bool = _state.InIteration;
        _state.InIteration = true;
        var body:jint.parser.ast.Statement = ParseStatement();
        _state.InIteration = oldInIteration;
        return (left == null) ? cast(CreateForStatement(init, test, update, body), jint.parser.ast.Statement) : CreateForInStatement(left, right, body);
    }
    private function ParseContinueStatement():jint.parser.ast.Statement
    {
        var label:jint.parser.ast.Identifier = null;
        ExpectKeyword("continue");
        if (jint.parser.ParserExtensions.CharCodeAt(_source, _index) == 59)
        {
            Lex();
            if (!_state.InIteration)
            {
                ThrowError(jint.parser.Token.Empty, jint.parser.Messages.IllegalContinue);
            }
            return CreateContinueStatement(null);
        }
        if (PeekLineTerminator())
        {
            if (!_state.InIteration)
            {
                ThrowError(jint.parser.Token.Empty, jint.parser.Messages.IllegalContinue);
            }
            return CreateContinueStatement(null);
        }
        if (_lookahead.Type == jint.parser.Tokens.Identifier)
        {
            label = ParseVariableIdentifier();
            var key:String = "$" + label.Name;
            if (!_state.LabelSet.Contains(key))
            {
                ThrowError(jint.parser.Token.Empty, jint.parser.Messages.UnknownLabel, [ label.Name ]);
            }
        }
        ConsumeSemicolon();
        if (label == null && !_state.InIteration)
        {
            ThrowError(jint.parser.Token.Empty, jint.parser.Messages.IllegalContinue);
        }
        return CreateContinueStatement(label);
    }
    private function ParseBreakStatement():jint.parser.ast.BreakStatement
    {
        var label:jint.parser.ast.Identifier = null;
        ExpectKeyword("break");
        if (jint.parser.ParserExtensions.CharCodeAt(_source, _index) == 59)
        {
            Lex();
            if (!(_state.InIteration || _state.InSwitch))
            {
                ThrowError(jint.parser.Token.Empty, jint.parser.Messages.IllegalBreak);
            }
            return CreateBreakStatement(null);
        }
        if (PeekLineTerminator())
        {
            if (!(_state.InIteration || _state.InSwitch))
            {
                ThrowError(jint.parser.Token.Empty, jint.parser.Messages.IllegalBreak);
            }
            return CreateBreakStatement(null);
        }
        if (_lookahead.Type == jint.parser.Tokens.Identifier)
        {
            label = ParseVariableIdentifier();
            var key:String = "$" + label.Name;
            if (!_state.LabelSet.Contains(key))
            {
                ThrowError(jint.parser.Token.Empty, jint.parser.Messages.UnknownLabel, [ label.Name ]);
            }
        }
        ConsumeSemicolon();
        if (label == null && !(_state.InIteration || _state.InSwitch))
        {
            ThrowError(jint.parser.Token.Empty, jint.parser.Messages.IllegalBreak);
        }
        return CreateBreakStatement(label);
    }
    private function ParseReturnStatement():jint.parser.ast.ReturnStatement
    {
        var argument:jint.parser.ast.Expression = null;
        ExpectKeyword("return");
        if (!_state.InFunctionBody)
        {
            ThrowErrorTolerant(jint.parser.Token.Empty, jint.parser.Messages.IllegalReturn);
        }
        if (jint.parser.ParserExtensions.CharCodeAt(_source, _index) == 32)
        {
            if (IsIdentifierStart(jint.parser.ParserExtensions.CharCodeAt(_source, _index + 1)))
            {
                argument = ParseExpression();
                ConsumeSemicolon();
                return CreateReturnStatement(argument);
            }
        }
        if (PeekLineTerminator())
        {
            return CreateReturnStatement(null);
        }
        if (!Match(";"))
        {
            if (!Match("}") && _lookahead.Type != jint.parser.Tokens.EOF)
            {
                argument = ParseExpression();
            }
        }
        ConsumeSemicolon();
        return CreateReturnStatement(argument);
    }
    private function ParseWithStatement():jint.parser.ast.WithStatement
    {
        if (_strict)
        {
            ThrowErrorTolerant(jint.parser.Token.Empty, jint.parser.Messages.StrictModeWith);
        }
        ExpectKeyword("with");
        Expect("(");
        var obj:jint.parser.ast.Expression = ParseExpression();
        Expect(")");
        var body:jint.parser.ast.Statement = ParseStatement();
        return CreateWithStatement(obj, body);
    }
    private function ParseSwitchCase():jint.parser.ast.SwitchCase
    {
        var test:jint.parser.ast.Expression;
        var consequent:Array<jint.parser.ast.Statement> = new Array<jint.parser.ast.Statement>();
        MarkStart();
        if (MatchKeyword("default"))
        {
            Lex();
            test = null;
        }
        else
        {
            ExpectKeyword("case");
            test = ParseExpression();
        }
        Expect(":");
        while (_index < _length)
        {
            if (Match("}") || MatchKeyword("default") || MatchKeyword("case"))
            {
                break;
            }
            var statement:jint.parser.ast.Statement = ParseStatement();
            consequent.push(statement);
        }
        return MarkEnd(CreateSwitchCase(test, consequent));
    }
    private function ParseSwitchStatement():jint.parser.ast.SwitchStatement
    {
        ExpectKeyword("switch");
        Expect("(");
        var discriminant:jint.parser.ast.Expression = ParseExpression();
        Expect(")");
        Expect("{");
        var cases:Array<jint.parser.ast.SwitchCase> = new Array<jint.parser.ast.SwitchCase>();
        if (Match("}"))
        {
            Lex();
            return CreateSwitchStatement(discriminant, cases);
        }
        var oldInSwitch:Bool = _state.InSwitch;
        _state.InSwitch = true;
        var defaultFound:Bool = false;
        while (_index < _length)
        {
            if (Match("}"))
            {
                break;
            }
            var clause:jint.parser.ast.SwitchCase = ParseSwitchCase();
            if (clause.Test == null)
            {
                if (defaultFound)
                {
                    ThrowError(jint.parser.Token.Empty, jint.parser.Messages.MultipleDefaultsInSwitch);
                }
                defaultFound = true;
            }
            cases.push(clause);
        }
        _state.InSwitch = oldInSwitch;
        Expect("}");
        return CreateSwitchStatement(discriminant, cases);
    }
    private function ParseThrowStatement():jint.parser.ast.ThrowStatement
    {
        ExpectKeyword("throw");
        if (PeekLineTerminator())
        {
            ThrowError(jint.parser.Token.Empty, jint.parser.Messages.NewlineAfterThrow);
        }
        var argument:jint.parser.ast.Expression = ParseExpression();
        ConsumeSemicolon();
        return CreateThrowStatement(argument);
    }
    private function ParseCatchClause():jint.parser.ast.CatchClause
    {
        MarkStart();
        ExpectKeyword("catch");
        Expect("(");
        if (Match(")"))
        {
            ThrowUnexpected(_lookahead);
        }
        var param:jint.parser.ast.Identifier = ParseVariableIdentifier();
        if (_strict && IsRestrictedWord(param.Name))
        {
            ThrowErrorTolerant(jint.parser.Token.Empty, jint.parser.Messages.StrictCatchVariable);
        }
        Expect(")");
        var body:jint.parser.ast.BlockStatement = ParseBlock();
        return MarkEnd(CreateCatchClause(param, body));
    }
    private function ParseTryStatement():jint.parser.ast.TryStatement
    {
        var handlers:Array<jint.parser.ast.CatchClause> = new Array<jint.parser.ast.CatchClause>();
        var finalizer:jint.parser.ast.Statement = null;
        ExpectKeyword("try");
        var block:jint.parser.ast.BlockStatement = ParseBlock();
        if (MatchKeyword("catch"))
        {
            handlers.push(ParseCatchClause());
        }
        if (MatchKeyword("finally"))
        {
            Lex();
            finalizer = ParseBlock();
        }
        if (handlers.length == 0 && finalizer == null)
        {
            ThrowError(jint.parser.Token.Empty, jint.parser.Messages.NoCatchOrFinally);
        }
        return CreateTryStatement(block, [  ], handlers, finalizer);
    }
    private function ParseDebuggerStatement():jint.parser.ast.DebuggerStatement
    {
        ExpectKeyword("debugger");
        ConsumeSemicolon();
        return CreateDebuggerStatement();
    }
    private function ParseStatement():jint.parser.ast.Statement
    {
        var type:Int = _lookahead.Type;
        if (type == jint.parser.Tokens.EOF)
        {
            ThrowUnexpected(_lookahead);
        }
        MarkStart();
        if (type == jint.parser.Tokens.Punctuator)
        {
            switch (_lookahead.Value)
            {
                case ";":
                    return MarkEnd(ParseEmptyStatement());
                case "{":
                    return MarkEnd(ParseBlock());
                case "(":
                    return MarkEnd(ParseExpressionStatement());
            }
        }
        if (type == jint.parser.Tokens.Keyword)
        {
            switch (_lookahead.Value)
            {
                case "break":
                    return MarkEnd(ParseBreakStatement());
                case "continue":
                    return MarkEnd(ParseContinueStatement());
                case "debugger":
                    return MarkEnd(ParseDebuggerStatement());
                case "do":
                    return MarkEnd(ParseDoWhileStatement());
                case "for":
                    return MarkEnd(ParseForStatement());
                case "function":
                    return MarkEnd(ParseFunctionDeclaration());
                case "if":
                    return MarkEnd(ParseIfStatement());
                case "return":
                    return MarkEnd(ParseReturnStatement());
                case "switch":
                    return MarkEnd(ParseSwitchStatement());
                case "throw":
                    return MarkEnd(ParseThrowStatement());
                case "try":
                    return MarkEnd(ParseTryStatement());
                case "var":
                    return MarkEnd(ParseVariableStatement());
                case "while":
                    return MarkEnd(ParseWhileStatement());
                case "with":
                    return MarkEnd(ParseWithStatement());
            }
        }
        var expr:jint.parser.ast.Expression = ParseExpression();
        if ((expr.Type == jint.parser.ast.SyntaxNodes.Identifier) && Match(":"))
        {
            Lex();
            var key:String = "$" + (cast(expr, jint.parser.ast.Identifier)).Name;
            if (_state.LabelSet.Contains(key))
            {
                ThrowError(jint.parser.Token.Empty, jint.parser.Messages.Redeclaration, [ "Label", (cast(expr, jint.parser.ast.Identifier)).Name ]);
            }
            _state.LabelSet.Add(key);
            var labeledBody:jint.parser.ast.Statement = ParseStatement();
            _state.LabelSet.Remove(key);
            return MarkEnd(CreateLabeledStatement(cast(expr, jint.parser.ast.Identifier), labeledBody));
        }
        ConsumeSemicolon();
        return MarkEnd(CreateExpressionStatement(expr));
    }
    private function ParseFunctionSourceElements():jint.parser.ast.Statement
    {
        var firstRestricted:jint.parser.Token = jint.parser.Token.Empty;
        var sourceElements:Array<jint.parser.ast.Statement> = new Array<jint.parser.ast.Statement>();
        MarkStart();
        Expect("{");
        while (_index < _length)
        {
            if (_lookahead.Type != jint.parser.Tokens.StringLiteral)
            {
                break;
            }
            var token:jint.parser.Token = _lookahead;
            var sourceElement:jint.parser.ast.Statement = ParseSourceElement();
            sourceElements.push(sourceElement);
            if ((cast(sourceElement, jint.parser.ast.ExpressionStatement)).Expression.Type != jint.parser.ast.SyntaxNodes.Literal)
            {
                break;
            }
            var directive:String = jint.parser.ParserExtensions.Slice(_source, token.Range[0] + 1, token.Range[1] - 1);
            if (directive == "use strict")
            {
                _strict = true;
                if (firstRestricted != jint.parser.Token.Empty)
                {
                    ThrowErrorTolerant(firstRestricted, jint.parser.Messages.StrictOctalLiteral);
                }
            }
            else
            {
                if (firstRestricted == jint.parser.Token.Empty && token.Octal)
                {
                    firstRestricted = token;
                }
            }
        }
        var oldLabelSet:system.collections.generic.HashSet<String> = _state.LabelSet;
        var oldInIteration:Bool = _state.InIteration;
        var oldInSwitch:Bool = _state.InSwitch;
        var oldInFunctionBody:Bool = _state.InFunctionBody;
        _state.LabelSet = new system.collections.generic.HashSet<String>();
        _state.InIteration = false;
        _state.InSwitch = false;
        _state.InFunctionBody = true;
        while (_index < _length)
        {
            if (Match("}"))
            {
                break;
            }
            var sourceElement:jint.parser.ast.Statement = ParseSourceElement();
            if (sourceElement == null)
            {
                break;
            }
            sourceElements.push(sourceElement);
        }
        Expect("}");
        _state.LabelSet = oldLabelSet;
        _state.InIteration = oldInIteration;
        _state.InSwitch = oldInSwitch;
        _state.InFunctionBody = oldInFunctionBody;
        return MarkEnd(CreateBlockStatement(sourceElements));
    }
    private function ParseParams(firstRestricted:jint.parser.Token):jint.parser.JavaScriptParser_ParsedParameters
    {
        var message:String = null;
        var stricted:jint.parser.Token = jint.parser.Token.Empty;
        var parameters:Array<jint.parser.ast.Identifier> = new Array<jint.parser.ast.Identifier>();
        Expect("(");
        if (!Match(")"))
        {
            var paramSet:system.collections.generic.HashSet<String> = new system.collections.generic.HashSet<String>();
            while (_index < _length)
            {
                var token:jint.parser.Token = _lookahead;
                var param:jint.parser.ast.Identifier = ParseVariableIdentifier();
                var key:String = Cs2Hx.CharToString(36) + token.Value;
                if (_strict)
                {
                    if (IsRestrictedWord(token.Value))
                    {
                        stricted = token;
                        message = jint.parser.Messages.StrictParamName;
                    }
                    if (paramSet.Contains(key))
                    {
                        stricted = token;
                        message = jint.parser.Messages.StrictParamDupe;
                    }
                }
                else if (firstRestricted == jint.parser.Token.Empty)
                {
                    if (IsRestrictedWord(token.Value))
                    {
                        firstRestricted = token;
                        message = jint.parser.Messages.StrictParamName;
                    }
                    else if (IsStrictModeReservedWord(token.Value))
                    {
                        firstRestricted = token;
                        message = jint.parser.Messages.StrictReservedWord;
                    }
                    else if (paramSet.Contains(key))
                    {
                        firstRestricted = token;
                        message = jint.parser.Messages.StrictParamDupe;
                    }
                }
                parameters.push(param);
                paramSet.Add(key);
                if (Match(")"))
                {
                    break;
                }
                Expect(",");
            }
        }
        Expect(")");
        var parsedParameters:jint.parser.JavaScriptParser_ParsedParameters = new jint.parser.JavaScriptParser_ParsedParameters();
        parsedParameters.Parameters = parameters;
        parsedParameters.Stricted = stricted;
        parsedParameters.FirstRestricted = firstRestricted;
        parsedParameters.Message = message;
        return parsedParameters;
    }
    private function ParseFunctionDeclaration():jint.parser.ast.Statement
    {
        EnterVariableScope();
        EnterFunctionScope();
        var firstRestricted:jint.parser.Token = jint.parser.Token.Empty;
        var message:String = null;
        MarkStart();
        ExpectKeyword("function");
        var token:jint.parser.Token = _lookahead;
        var id:jint.parser.ast.Identifier = ParseVariableIdentifier();
        if (_strict)
        {
            if (IsRestrictedWord(token.Value))
            {
                ThrowErrorTolerant(token, jint.parser.Messages.StrictFunctionName);
            }
        }
        else
        {
            if (IsRestrictedWord(token.Value))
            {
                firstRestricted = token;
                message = jint.parser.Messages.StrictFunctionName;
            }
            else if (IsStrictModeReservedWord(token.Value))
            {
                firstRestricted = token;
                message = jint.parser.Messages.StrictReservedWord;
            }
        }
        var tmp:jint.parser.JavaScriptParser_ParsedParameters = ParseParams(firstRestricted);
        var parameters:Array<jint.parser.ast.Identifier> = tmp.Parameters;
        var stricted:jint.parser.Token = tmp.Stricted;
        firstRestricted = tmp.FirstRestricted;
        if (tmp.Message != null)
        {
            message = tmp.Message;
        }
        var previousStrict:Bool = _strict;
        var body:jint.parser.ast.Statement = ParseFunctionSourceElements();
        if (_strict && firstRestricted != jint.parser.Token.Empty)
        {
            ThrowError(firstRestricted, message);
        }
        if (_strict && stricted != jint.parser.Token.Empty)
        {
            ThrowErrorTolerant(stricted, message);
        }
        var functionStrict:Bool = _strict;
        _strict = previousStrict;
        return MarkEnd(CreateFunctionDeclaration(id, parameters, [  ], body, functionStrict));
    }
    private function EnterVariableScope():Void
    {
        _variableScopes.push(new jint.parser.VariableScope());
    }
    private function LeaveVariableScope():Array<jint.parser.ast.VariableDeclaration>
    {
        return _variableScopes.pop().VariableDeclarations;
    }
    private function EnterFunctionScope():Void
    {
        _functionScopes.push(new jint.parser.FunctionScope());
    }
    private function LeaveFunctionScope():Array<jint.parser.ast.FunctionDeclaration>
    {
        return _functionScopes.pop().FunctionDeclarations;
    }
    private function ParseFunctionExpression():jint.parser.ast.FunctionExpression
    {
        EnterVariableScope();
        EnterFunctionScope();
        var firstRestricted:jint.parser.Token = jint.parser.Token.Empty;
        var message:String = null;
        var id:jint.parser.ast.Identifier = null;
        MarkStart();
        ExpectKeyword("function");
        if (!Match("("))
        {
            var token:jint.parser.Token = _lookahead;
            id = ParseVariableIdentifier();
            if (_strict)
            {
                if (IsRestrictedWord(token.Value))
                {
                    ThrowErrorTolerant(token, jint.parser.Messages.StrictFunctionName);
                }
            }
            else
            {
                if (IsRestrictedWord(token.Value))
                {
                    firstRestricted = token;
                    message = jint.parser.Messages.StrictFunctionName;
                }
                else if (IsStrictModeReservedWord(token.Value))
                {
                    firstRestricted = token;
                    message = jint.parser.Messages.StrictReservedWord;
                }
            }
        }
        var tmp:jint.parser.JavaScriptParser_ParsedParameters = ParseParams(firstRestricted);
        var parameters:Array<jint.parser.ast.Identifier> = tmp.Parameters;
        var stricted:jint.parser.Token = tmp.Stricted;
        firstRestricted = tmp.FirstRestricted;
        if (tmp.Message != null)
        {
            message = tmp.Message;
        }
        var previousStrict:Bool = _strict;
        var body:jint.parser.ast.Statement = ParseFunctionSourceElements();
        if (_strict && firstRestricted != jint.parser.Token.Empty)
        {
            ThrowError(firstRestricted, message);
        }
        if (_strict && stricted != jint.parser.Token.Empty)
        {
            ThrowErrorTolerant(stricted, message);
        }
        var functionStrict:Bool = _strict;
        _strict = previousStrict;
        return MarkEnd(CreateFunctionExpression(id, parameters, [  ], body, functionStrict));
    }
    private function ParseSourceElement():jint.parser.ast.Statement
    {
        if (_lookahead.Type == jint.parser.Tokens.Keyword)
        {
            switch (_lookahead.Value)
            {
                case "const", "let":
                    return ParseConstLetDeclaration(_lookahead.Value);
                case "function":
                    return ParseFunctionDeclaration();
                default:
                    return ParseStatement();
            }
        }
        if (_lookahead.Type != jint.parser.Tokens.EOF)
        {
            return ParseStatement();
        }
        return null;
    }
    private function ParseSourceElements():Array<jint.parser.ast.Statement>
    {
        var sourceElements:Array<jint.parser.ast.Statement> = new Array<jint.parser.ast.Statement>();
        var firstRestricted:jint.parser.Token = jint.parser.Token.Empty;
        var sourceElement:jint.parser.ast.Statement;
        while (_index < _length)
        {
            var token:jint.parser.Token = _lookahead;
            if (token.Type != jint.parser.Tokens.StringLiteral)
            {
                break;
            }
            sourceElement = ParseSourceElement();
            sourceElements.push(sourceElement);
            if ((cast(sourceElement, jint.parser.ast.ExpressionStatement)).Expression.Type != jint.parser.ast.SyntaxNodes.Literal)
            {
                break;
            }
            var directive:String = jint.parser.ParserExtensions.Slice(_source, token.Range[0] + 1, token.Range[1] - 1);
            if (directive == "use strict")
            {
                _strict = true;
                if (firstRestricted != jint.parser.Token.Empty)
                {
                    ThrowErrorTolerant(firstRestricted, jint.parser.Messages.StrictOctalLiteral);
                }
            }
            else
            {
                if (firstRestricted == jint.parser.Token.Empty && token.Octal)
                {
                    firstRestricted = token;
                }
            }
        }
        while (_index < _length)
        {
            sourceElement = ParseSourceElement();
            if (sourceElement == null)
            {
                break;
            }
            sourceElements.push(sourceElement);
        }
        return sourceElements;
    }
    private function ParseProgram():jint.parser.ast.Program
    {
        EnterVariableScope();
        EnterFunctionScope();
        MarkStart();
        Peek();
        var body:Array<jint.parser.ast.Statement> = ParseSourceElements();
        return MarkEnd(CreateProgram(body, _strict));
    }
    private function CreateLocationMarker():jint.parser.JavaScriptParser_LocationMarker
    {
        if (!_extra.LocHasValue && _extra.Range.length == 0)
        {
            return null;
        }
        SkipComment();
        return new jint.parser.JavaScriptParser_LocationMarker(_index, _lineNumber, _lineStart);
    }
    public function Parse(code:String):jint.parser.ast.Program
    {
        return Parse_String_ParserOptions(code, null);
    }
    public function Parse_String_ParserOptions(code:String, options:jint.parser.ParserOptions):jint.parser.ast.Program
    {
        var program:jint.parser.ast.Program;
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
        _extra = new jint.parser.JavaScriptParser_Extra();
        _extra.Range = [  ];
        _extra.Loc = 0;
        _extra.LocHasValue = true;
        if (options != null)
        {
            if (!system.Cs2Hx.IsNullOrEmpty(options.Source))
            {
                _extra.Source = options.Source;
            }
            if (options.Tokens)
            {
                _extra.Tokens = new Array<jint.parser.Token>();
            }
            if (options.Comment)
            {
                _extra.Comments = new Array<jint.parser.Comment>();
            }
            if (options.Tolerant)
            {
                _extra.Errors = new Array<jint.parser.ParserException>();
            }
        }
        program = ParseProgram();
        if (_extra.Comments != null)
        {
            program.Comments = _extra.Comments;
        }
        if (_extra.Tokens != null)
        {
            program.Tokens = _extra.Tokens;
        }
        if (_extra.Errors != null)
        {
            program.Errors = _extra.Errors;
        }
        _extra = new jint.parser.JavaScriptParser_Extra();
        return program;
    }
    public function ParseFunctionExpression_String(functionExpression:String):jint.parser.ast.FunctionExpression
    {
        _source = functionExpression;
        _index = 0;
        _lineNumber = (_source.length > 0) ? 1 : 0;
        _lineStart = 0;
        _length = _source.length;
        _lookahead = null;
        _state = new jint.parser.State();
        _state.AllowIn = true;
        _state.LabelSet = new system.collections.generic.HashSet<String>();
        _state.InFunctionBody = true;
        _state.InIteration = false;
        _state.InSwitch = false;
        _state.LastCommentStart = -1;
        _state.MarkerStack = new Array<Int>();
        _extra = new jint.parser.JavaScriptParser_Extra();
        _extra.Range = [  ];
        _extra.Loc = 0;
        _extra.LocHasValue = true;
        _strict = false;
        Peek();
        return ParseFunctionExpression();
    }
    public static function cctor():Void
    {
        Keywords = [ "if", "in", "do", "var", "for", "new", "try", "let", "this", "else", "case", "void", "with", "enum", "while", "break", "catch", "throw", "const", "yield", "class", "super", "return", "typeof", "delete", "switch", "export", "import", "default", "finally", "extends", "function", "continue", "debugger", "instanceof" ];
        StrictModeReservedWords = [ "implements", "interface", "package", "private", "protected", "public", "static", "yield", "let" ];
        FutureReservedWords = [ "class", "enum", "export", "extends", "import", "super" ];
    }
}
