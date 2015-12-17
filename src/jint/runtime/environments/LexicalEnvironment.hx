package jint.runtime.environments;
using StringTools;
import system.*;
import anonymoustypes.*;

class LexicalEnvironment
{
    private var _record:jint.runtime.environments.EnvironmentRecord;
    private var _outer:jint.runtime.environments.LexicalEnvironment;
    public function new(record:jint.runtime.environments.EnvironmentRecord, outer:jint.runtime.environments.LexicalEnvironment)
    {
        _record = record;
        _outer = outer;
    }
    public var Record(get, never):jint.runtime.environments.EnvironmentRecord;
    public function get_Record():jint.runtime.environments.EnvironmentRecord
    {
        return _record;
    }

    public var Outer(get, never):jint.runtime.environments.LexicalEnvironment;
    public function get_Outer():jint.runtime.environments.LexicalEnvironment
    {
        return _outer;
    }

    public static function GetIdentifierReference(lex:jint.runtime.environments.LexicalEnvironment, name:String, strict:Bool):jint.runtime.references.Reference
    {
        if (lex == null)
        {
            return new jint.runtime.references.Reference(jint.native.Undefined.Instance, name, strict);
        }
        if (lex.Record.HasBinding(name))
        {
            return new jint.runtime.references.Reference(lex.Record, name, strict);
        }
        if (lex.Outer == null)
        {
            return new jint.runtime.references.Reference(jint.native.Undefined.Instance, name, strict);
        }
        return GetIdentifierReference(lex.Outer, name, strict);
    }
    public static function NewDeclarativeEnvironment(engine:jint.Engine, outer:jint.runtime.environments.LexicalEnvironment = null):jint.runtime.environments.LexicalEnvironment
    {
        return new jint.runtime.environments.LexicalEnvironment(new jint.runtime.environments.DeclarativeEnvironmentRecord(engine), outer);
    }
    public static function NewObjectEnvironment(engine:jint.Engine, objectInstance:jint.native.object.ObjectInstance, outer:jint.runtime.environments.LexicalEnvironment, provideThis:Bool):jint.runtime.environments.LexicalEnvironment
    {
        return new jint.runtime.environments.LexicalEnvironment(new jint.runtime.environments.ObjectEnvironmentRecord(engine, objectInstance, provideThis), outer);
    }
}
