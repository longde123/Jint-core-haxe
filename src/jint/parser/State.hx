package jint.parser;
using StringTools;
import system.*;
import anonymoustypes.*;

class State
{
    public var LastCommentStart:Int;
    public var AllowIn:Bool;
    public var LabelSet:system.collections.generic.HashSet<String>;
    public var InFunctionBody:Bool;
    public var InIteration:Bool;
    public var InSwitch:Bool;
    public var MarkerStack:Array<Int>;
    public function new()
    {
        LastCommentStart = 0;
        AllowIn = false;
        InFunctionBody = false;
        InIteration = false;
        InSwitch = false;
    }
}
