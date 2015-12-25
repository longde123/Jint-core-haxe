package jint.native.regexp;
using StringTools;
import system.*;
import anonymoustypes.*;
class RegMatch
{
	public var Success:Bool;
	public var Index: Int;
	public var Length: Int;
	public var Groups:Array<String> = [];
	public function new()
    {
		
    }
	static public function getMatches(ereg:EReg,text:String):Array<String> {
		var matches:Array<String> = [];
		while (ereg.match(text)) { 
			var t = ereg.matched(1);
			matches.push( t ); 
			text = ereg.matchedRight(); 
		}
		return matches;
	}
 
	static public function getGroupMatches(ereg:EReg, text:String, groupCount:UInt = 0):Array<String> {
		
		var matches:Array<String> = [];
		if (!ereg.match(text)) return matches;
		var m:UInt = 0;
		var t;
		if (groupCount == 0){
			while ((t = ereg.matched(m++))!=null) { 
				groupCount++;
			}
		}
		m = 0;
		var completed:Bool = false;
		while (!completed && (t = ereg.matched(m++))!=null) { 
			matches.push( t );
			if (groupCount!=0 && m>groupCount) completed=true; 
		}
		return matches;
	}
}
class RegExpInstance extends jint.native.object.ObjectInstance
{
    public function new(engine:jint.Engine)
    {
        super(engine);
    }
    override public function get_JClass():String
    {
        return "RegExp";
    }

    public var Value:EReg;
    public var Source:String;
    public var Flags:String;
    public var Global:Bool;
    public var IgnoreCase:Bool;
    public var Multiline:Bool;
    public function Match(input:String, start:Float=0):RegMatch
    {
		
		var m = new RegMatch();
		m.Success = Value.matchSub(input, Std.int(start));
		m.Index = Value.matchedPos().pos;
		m.Length = Value.matchedPos().len;
		m.Groups = RegMatch.getGroupMatches(Value,input,0);
		return m;
    }
}
