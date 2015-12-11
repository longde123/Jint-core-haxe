package ;
using StringTools;
import system.*;
import anonymoustypes.*;

class EnumExtensions
{
    public static function HasFlag(variable:system.Enum, value:system.Enum):Bool
    {
        if (system.Cs2Hx.GetType(variable) != system.Cs2Hx.GetType(value))
        {
            return throw new system.ArgumentException("The checked flag is not from the same type as the checked variable.");
        }
        var num:Float = system.Convert.ToUInt64(value);
        var num2:Float = system.Convert.ToUInt64(variable);
        return (num2 & num) == num;
    }
    public function new()
    {
    }
}
