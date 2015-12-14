package jint.native.number.dtoa;
using StringTools;
import system.*;
import anonymoustypes.*;

class FastDtoaBuilder
{
    private var _chars:Array<Int>;
    public var End:Int;
    public var Point:Int;
    private var _formatted:Bool;
    public function Append(c:Int):Void
    {
        _chars[End++] = c;
    }
    public function DecreaseLast():Void
    {
        _chars[End - 1]--;
    }
    public function Reset():Void
    {
        End = 0;
        _formatted = false;
    }
    public function toString():String
    {
        return "[chars:" + new String(_chars, 0, End) + ", point:" + Point + "]";
    }
    public function Format():String
    {
        if (!_formatted)
        {
            var firstDigit:Int = _chars[0] == 45 ? 1 : 0;
            var decPoint:Int = Point - firstDigit;
            if (decPoint < -5 || decPoint > 21)
            {
                ToExponentialFormat(firstDigit, decPoint);
            }
            else
            {
                ToFixedFormat(firstDigit, decPoint);
            }
            _formatted = true;
        }
        return new String(_chars, 0, End);
    }
    private function ToFixedFormat(firstDigit:Int, decPoint:Int):Void
    {
        if (Point < End)
        {
            if (decPoint > 0)
            {
                system.Array.Copy_Array_Int32_Array_Int32_Int32(_chars, Point, _chars, Point + 1, End - Point);
                _chars[Point] = 46;
                End++;
            }
            else
            {
                var target:Int = firstDigit + 2 - decPoint;
                system.Array.Copy_Array_Int32_Array_Int32_Int32(_chars, firstDigit, _chars, target, End - firstDigit);
                _chars[firstDigit] = 48;
                _chars[firstDigit + 1] = 46;
                if (decPoint < 0)
                {
                    Fill(_chars, firstDigit + 2, target, 48);
                }
                End += 2 - decPoint;
            }
        }
        else if (Point > End)
        {
            Fill(_chars, End, Point, 48);
            End += Point - End;
        }
    }
    private function ToExponentialFormat(firstDigit:Int, decPoint:Int):Void
    {
        if (End - firstDigit > 1)
        {
            var dot:Int = firstDigit + 1;
            system.Array.Copy_Array_Int32_Array_Int32_Int32(_chars, dot, _chars, dot + 1, End - dot);
            _chars[dot] = 46;
            End++;
        }
        _chars[End++] = 101;
        var sign:Int = 43;
        var exp:Int = decPoint - 1;
        if (exp < 0)
        {
            sign = 45;
            exp = -exp;
        }
        _chars[End++] = sign;
        var charPos:Int = exp > 99 ? End + 2 : exp > 9 ? End + 1 : End;
        End = charPos + 1;
        { //for
            while (true)
            {
                var r:Int = exp % 10;
                _chars[charPos--] = Digits[r];
                exp = exp / 10;
                if (exp == 0)
                {
                    break;
                }
            }
        } //end for
    }
    private static var Digits:Array<Int>;
    private function Fill<T>(array:Array<T>, fromIndex:Int, toIndex:Int, val:T):Void
    {
        { //for
            var i:Int = fromIndex;
            while (i < toIndex)
            {
                array[i] = val;
                i++;
            }
        } //end for
    }
    public static function cctor():Void
    {
        Digits = [ 48, 49, 50, 51, 52, 53, 54, 55, 56, 57 ];
    }
    public function new()
    {
        _chars = [  ];
        End = 0;
        Point = 0;
        _formatted = false;
    }
}
