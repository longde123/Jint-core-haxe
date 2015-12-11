package jint.runtime.interop;
using StringTools;
import system.*;
import anonymoustypes.*;

interface ITypeConverter
{
    function Convert(value:Dynamic, type:system.TypeCS, formatProvider:system.IFormatProvider):Dynamic;
    function TryConvert(value:Dynamic, type:system.TypeCS, formatProvider:system.IFormatProvider):system.collections.generic.KeyValuePair<Bool, Dynamic>;
}
