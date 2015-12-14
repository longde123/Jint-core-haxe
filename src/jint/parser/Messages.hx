package jint.parser;
using StringTools;
import system.*;
import anonymoustypes.*;

class Messages
{
    public static var UnexpectedToken:String;
    public static var UnexpectedNumber:String;
    public static var UnexpectedString:String;
    public static var UnexpectedIdentifier:String;
    public static var UnexpectedReserved:String;
    public static var UnexpectedEOS:String;
    public static var NewlineAfterThrow:String;
    public static var InvalidRegExp:String;
    public static var UnterminatedRegExp:String;
    public static var InvalidLHSInAssignment:String;
    public static var InvalidLHSInForIn:String;
    public static var MultipleDefaultsInSwitch:String;
    public static var NoCatchOrFinally:String;
    public static var UnknownLabel:String;
    public static var Redeclaration:String;
    public static var IllegalContinue:String;
    public static var IllegalBreak:String;
    public static var IllegalReturn:String;
    public static var StrictModeWith:String;
    public static var StrictCatchVariable:String;
    public static var StrictVarName:String;
    public static var StrictParamName:String;
    public static var StrictParamDupe:String;
    public static var StrictFunctionName:String;
    public static var StrictOctalLiteral:String;
    public static var StrictDelete:String;
    public static var StrictDuplicateProperty:String;
    public static var AccessorDataProperty:String;
    public static var AccessorGetSet:String;
    public static var StrictLHSAssignment:String;
    public static var StrictLHSPostfix:String;
    public static var StrictLHSPrefix:String;
    public static var StrictReservedWord:String;
    public static function cctor():Void
    {
        UnexpectedToken = "Unexpected token {0}";
        UnexpectedNumber = "Unexpected number";
        UnexpectedString = "Unexpected string";
        UnexpectedIdentifier = "Unexpected identifier";
        UnexpectedReserved = "Unexpected reserved word";
        UnexpectedEOS = "Unexpected end of input";
        NewlineAfterThrow = "Illegal newline after throw";
        InvalidRegExp = "Invalid regular expression";
        UnterminatedRegExp = "Invalid regular expression= missing /";
        InvalidLHSInAssignment = "Invalid left-hand side in assignment";
        InvalidLHSInForIn = "Invalid left-hand side in for-in";
        MultipleDefaultsInSwitch = "More than one default clause in switch statement";
        NoCatchOrFinally = "Missing catch or finally after try";
        UnknownLabel = "Undefined label \"{0}\"";
        Redeclaration = "{0} \"{1}\" has already been declared";
        IllegalContinue = "Illegal continue statement";
        IllegalBreak = "Illegal break statement";
        IllegalReturn = "Illegal return statement";
        StrictModeWith = "Strict mode code may not include a with statement";
        StrictCatchVariable = "Catch variable may not be eval or arguments in strict mode";
        StrictVarName = "Variable name may not be eval or arguments in strict mode";
        StrictParamName = "Parameter name eval or arguments is not allowed in strict mode";
        StrictParamDupe = "Strict mode function may not have duplicate parameter names";
        StrictFunctionName = "Function name may not be eval or arguments in strict mode";
        StrictOctalLiteral = "Octal literals are not allowed in strict mode.";
        StrictDelete = "Delete of an unqualified identifier in strict mode.";
        StrictDuplicateProperty = "Duplicate data property in object literal not allowed in strict mode";
        AccessorDataProperty = "Object literal may not have data and accessor property with the same name";
        AccessorGetSet = "Object literal may not have multiple get/set accessors with the same name";
        StrictLHSAssignment = "Assignment to eval or arguments is not allowed in strict mode";
        StrictLHSPostfix = "Postfix increment/decrement may not have eval or arguments operand in strict mode";
        StrictLHSPrefix = "Prefix increment/decrement may not have eval or arguments operand in strict mode";
        StrictReservedWord = "Use of future reserved word in strict mode";
    }
    public function new()
    {
    }
}
