package jint.runtime.interop;
using StringTools;
import system.*;
import anonymoustypes.*; 


interface ITypeConverter
{
    function Convert(value:Dynamic, type:Class<Dynamic>):Dynamic;
    function TryConvert(value:Dynamic, type:Class<Dynamic>):Array< Dynamic>;
}
