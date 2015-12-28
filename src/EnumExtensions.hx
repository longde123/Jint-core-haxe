package ;
using StringTools;
import system.*;
import anonymoustypes.*;

class EnumExtensions
{
    public static function HasFlag(variable , value ):Bool
    {
      
        var num:Int = Std.parseInt(value);
        var num2:Int = Std.parseInt(variable);
        return (num2 & num) == num;
    }
    public function new()
    {
    }
}
